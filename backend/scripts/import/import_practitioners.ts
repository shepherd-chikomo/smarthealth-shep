#!/usr/bin/env node
/**
 * SmartHealth healthcare provider import pipeline
 *
 * Usage:
 *   npm run import:providers -- practitioners.xlsx
 *   npm run import:providers -- practitioners.xlsx --dry-run
 *   npm run import:providers -- practitioners.xlsx --reset
 *   npm run import:providers -- practitioners.xlsx --skip-geocoding
 */
import { randomUUID } from 'node:crypto';
import { resolve } from 'node:path';
import type pg from 'pg';
import { closePool, query, withTransaction, normalizePhoneDb } from './db.js';
import { loadExcel } from './load_excel.js';
import { logger } from './logger.js';
import {
  normalizeSpreadsheetRow,
  inferFacilityType,
  buildFacilityKey,
} from './normalize_data.js';
import { validateProvider, isCriticalError } from './validate.js';
import { createSpecialtyMapper, loadSpecialtyData } from './specialty_mapper.js';
import { deduplicateFacilities, deduplicateProviders } from './deduplicate.js';
import { extractFacilitiesFromProviders, matchProviderToFacility, resolveCityId } from './facility_matcher.js';
import { assignSlugsAndKeywords } from './generate_slugs.js';
import { buildGeocodeQuery, geocodeBatch } from './geocode.js';
import {
  createEmptyReport,
  exportReport,
  finalizeReport,
  printReportSummary,
} from './generate_report.js';
import type {
  CityRecord,
  FacilityRecord,
  ImportOptions,
  ImportReport,
  NormalizedFacility,
  NormalizedProvider,
  ProviderRecord,
  SpecialtyRecord,
} from './types.js';

function parseArgs(argv: string[]): ImportOptions & { filePath: string } {
  const args = argv.slice(2);
  const flags = new Set(args.filter((a) => a.startsWith('--')));
  const positional = args.filter((a) => !a.startsWith('--'));

  if (positional.length === 0) {
    console.error(`
Usage: npm run import:providers -- <file.xlsx> [options]

Options:
  --dry-run          Validate and report without writing to database
  --reset            Remove records from previous import batches before importing
  --skip-geocoding   Skip Nominatim geocoding (use spreadsheet coords only)
  --source=MDPCZ     Override source type (MDPCZ|HPA|MIXED)
`);
    process.exit(1);
  }

  const sourceFlag = [...flags].find((f) => f.startsWith('--source='));
  const sourceType = (sourceFlag?.split('=')[1]?.toUpperCase() ?? 'MIXED') as ImportOptions['sourceType'];

  const filePath = resolve(positional[0]);
  return {
    filePath,
    dryRun: flags.has('--dry-run'),
    reset: flags.has('--reset'),
    skipGeocoding: flags.has('--skip-geocoding'),
    sourceFile: positional[0],
    sourceType,
  };
}

async function loadReferenceData(): Promise<{
  cities: CityRecord[];
  specialties: SpecialtyRecord[];
  specialtyMapper: ReturnType<typeof createSpecialtyMapper>;
  existingFacilities: FacilityRecord[];
  existingProviders: ProviderRecord[];
  existingProviderSlugs: Set<string>;
  existingFacilitySlugs: Set<string>;
}> {
  const { specialties, aliases } = await loadSpecialtyData(query);
  const specialtyMapper = createSpecialtyMapper(specialties, aliases);

  const citiesResult = await query<CityRecord>(
    `SELECT id, name, province, latitude, longitude FROM public.cities WHERE country_code = 'ZW' AND is_active = true`,
  );

  const facilitiesResult = await query<FacilityRecord>(
    `SELECT id, name, slug, city, province::text, phone, address_line1, import_row_hash
     FROM public.facilities WHERE deleted_at IS NULL`,
  );

  const providersResult = await query<ProviderRecord>(
    `SELECT id, name, slug, registration_number, mdpcz_number, phone, specialty, facility_id, import_row_hash
     FROM public.providers WHERE deleted_at IS NULL`,
  );

  const providerSlugsResult = await query<{ slug: string }>(
    `SELECT slug FROM public.providers WHERE slug IS NOT NULL AND deleted_at IS NULL`,
  );

  const facilitySlugsResult = await query<{ slug: string }>(
    `SELECT slug FROM public.facilities WHERE deleted_at IS NULL`,
  );

  return {
    cities: citiesResult.rows,
    specialties,
    specialtyMapper,
    existingFacilities: facilitiesResult.rows,
    existingProviders: providersResult.rows,
    existingProviderSlugs: new Set(providerSlugsResult.rows.map((r) => r.slug)),
    existingFacilitySlugs: new Set(facilitySlugsResult.rows.map((r) => r.slug)),
  };
}

async function createImportBatch(
  client: pg.PoolClient,
  options: ImportOptions,
  totalRows: number,
): Promise<string> {
  const batchId = options.batchId ?? randomUUID();
  await client.query(
    `INSERT INTO public.import_logs (
       id, source_file, source_type, status, dry_run, options, total_rows, started_by
     ) VALUES ($1, $2, $3, 'running', $4, $5, $6, $7)`,
    [
      batchId,
      options.sourceFile,
      options.sourceType,
      options.dryRun,
      JSON.stringify({
        reset: options.reset,
        skipGeocoding: options.skipGeocoding,
      }),
      totalRows,
      options.startedBy ?? null,
    ],
  );
  return batchId;
}

async function resetImportData(client: pg.PoolClient): Promise<void> {
  logger.warn('Resetting previously imported directory data...');
  await client.query(`DELETE FROM public.provider_facility_links WHERE import_batch_id IS NOT NULL`);
  await client.query(`DELETE FROM public.provider_specialties WHERE import_batch_id IS NOT NULL`);
  await client.query(`DELETE FROM public.providers WHERE import_batch_id IS NOT NULL`);
  await client.query(`DELETE FROM public.facilities WHERE import_batch_id IS NOT NULL AND is_claimed = false`);
  await client.query(`DELETE FROM public.failed_imports`);
  await client.query(`DELETE FROM public.import_duplicate_reviews WHERE status = 'pending'`);
}

async function insertFailedRow(
  client: pg.PoolClient,
  batchId: string,
  rowNumber: number,
  raw: Record<string, unknown>,
  errorCode: string,
  errorMessage: string,
): Promise<void> {
  await client.query(
    `INSERT INTO public.failed_imports (
       import_batch_id, row_number, raw_data, error_code, error_message
     ) VALUES ($1, $2, $3, $4, $5)`,
    [batchId, rowNumber, JSON.stringify(raw), errorCode, errorMessage],
  );
}

async function upsertCity(
  client: pg.PoolClient,
  cityName: string,
  province: string | null,
): Promise<string | null> {
  const result = await client.query<{ id: string }>(
    `INSERT INTO public.cities (country_code, name, province)
     VALUES ('ZW', $1, $2)
     ON CONFLICT (country_code, name, province) DO UPDATE SET name = EXCLUDED.name
     RETURNING id`,
    [cityName, province],
  );
  return result.rows[0]?.id ?? null;
}

async function runImport(options: ImportOptions): Promise<ImportReport> {
  const report = createEmptyReport(options.batchId ?? randomUUID(), options.sourceFile, options.dryRun);

  logger.info('Starting SmartHealth import', options as unknown as Record<string, unknown>);

  const rawRows = loadExcel(options.filePath);
  report.totalRows = rawRows.length;

  const ref = await loadReferenceData();
  const specialtySlugToId = new Map(ref.specialties.map((s) => [s.slug, s.id]));

  let normalizedProviders = rawRows.map((row) =>
    normalizeSpreadsheetRow(row, ref.specialtyMapper.map),
  );

  const validatedProviders: NormalizedProvider[] = [];
  const rejectedProviders: NormalizedProvider[] = [];

  for (const provider of normalizedProviders) {
    const validation = validateProvider(provider);
    provider.validationErrors = validation.errors;
    provider.warnings = validation.warnings;

    if (!validation.valid && isCriticalError(validation.errors)) {
      rejectedProviders.push(provider);
      report.failedRows.push({
        rowNumber: provider.rowNumber,
        errorCode: 'VALIDATION_FAILED',
        errorMessage: validation.errors.join('; '),
        raw: rawRows.find((r) => r.rowNumber === provider.rowNumber)?.raw ?? {},
      });
    } else {
      validatedProviders.push(provider);
    }
  }

  const { unique: dedupedProviders, merges: providerMerges, reviews: providerReviews } =
    deduplicateProviders(validatedProviders, ref.existingProviders);
  report.duplicatesMerged += providerMerges.length;

  for (const review of providerReviews) {
    report.duplicateReviews.push({
      entityType: 'provider',
      sourceName: review.source.name.fullName,
      targetName: review.target.name.fullName,
      confidence: review.confidence,
      score: review.score,
      reason: review.reason,
    });
  }

  normalizedProviders = dedupedProviders;

  let facilities = extractFacilitiesFromProviders(normalizedProviders);
  const { unique: dedupedFacilities, merges: facilityMerges } =
    deduplicateFacilities(facilities, ref.existingFacilities);
  facilities = dedupedFacilities;
  report.duplicatesMerged += facilityMerges.length;

  assignSlugsAndKeywords(
    normalizedProviders,
    facilities,
    ref.existingProviderSlugs,
    ref.existingFacilitySlugs,
  );

  const unmatchedSpecialties = ref.specialtyMapper.getUnmatched();
  report.specialtiesUnmatched = [...unmatchedSpecialties.keys()];

  const missingCitiesSet = new Set<string>();

  if (options.dryRun) {
    report.imported = normalizedProviders.length;
    report.facilitiesCreated = facilities.length;
    report.providersCreated = normalizedProviders.length;
    report.failed = rejectedProviders.length;
    return finalizeReport(report);
  }

  await withTransaction(async (client) => {
    if (options.reset) {
      await resetImportData(client);
    }

    const batchId = await createImportBatch(client, { ...options, batchId: report.batchId }, report.totalRows);
    report.batchId = batchId;

    for (const rejected of rejectedProviders) {
      await insertFailedRow(
        client,
        batchId,
        rejected.rowNumber,
        rawRows.find((r) => r.rowNumber === rejected.rowNumber)?.raw ?? {},
        'VALIDATION_FAILED',
        rejected.validationErrors.join('; '),
      );
    }

    const geocodeQueries: string[] = [];
    for (const facility of facilities) {
      if (!facility.latitude || !facility.longitude) {
        const q = buildGeocodeQuery(facility);
        if (q) geocodeQueries.push(q);
      }
    }
    for (const provider of normalizedProviders) {
      if (!provider.latitude || !provider.longitude) {
        const q = buildGeocodeQuery(provider);
        if (q) geocodeQueries.push(q);
      }
    }

    const geocodeResults = await geocodeBatch(client, geocodeQueries, options.skipGeocoding);
    report.geocodedCount = geocodeResults.size;

    const facilityIdByKey = new Map<string, string>();
    const facilitySlugToId = new Map<string, string>();

    for (const existing of ref.existingFacilities) {
      facilityIdByKey.set(
        buildFacilityKey(existing.name, existing.city, existing.address_line1),
        existing.id,
      );
      facilitySlugToId.set(existing.slug, existing.id);
    }

    for (const facility of facilities) {
      let cityId: string | null = null;
      if (facility.city) {
        const cityRes = resolveCityId(facility.city, facility.province, ref.cities);
        cityId = cityRes.cityId;
        if (cityRes.missing) {
          missingCitiesSet.add(facility.city);
          cityId = await upsertCity(client, facility.city, facility.province);
        }
      }

      const geoQuery = buildGeocodeQuery(facility);
      const geo = geoQuery ? geocodeResults.get(geoQuery) : null;
      const lat = facility.latitude ?? geo?.latitude ?? null;
      const lng = facility.longitude ?? geo?.longitude ?? null;
      const formattedAddress = geo?.formattedAddress ?? facility.formattedAddress;

      let province = facility.province ?? 'Harare';
      const validProvinces = [
        'Bulawayo', 'Harare', 'Manicaland', 'Mashonaland Central', 'Mashonaland East',
        'Mashonaland West', 'Masvingo', 'Matabeleland North', 'Matabeleland South', 'Midlands',
      ];
      if (!validProvinces.includes(province)) province = 'Harare';

      const phone = facility.phone ? await normalizePhoneDb(facility.phone) : null;
      const rowHash = `fac-${facility.key}`;

      const existingId = facilityIdByKey.get(facility.key);
      if (existingId) {
        facilitySlugToId.set(facility.slug, existingId);
        continue;
      }

      const insertResult = await client.query<{ id: string }>(
        `INSERT INTO public.facilities (
           name, slug, facility_type, address_line1, city, province, phone, email,
           latitude, longitude, city_id, search_keywords, facility_category,
           ownership_type, formatted_address, import_batch_id, import_source, imported_at,
           import_row_hash, verification_status, is_verified
         ) VALUES (
           $1, $2, $3::public.facility_type, $4, $5, $6::public.zimbabwe_province, $7, $8,
           $9, $10, $11, $12, $13, $14, $15, $16, $17, timezone('utc', now()),
           $18, 'pending_review', false
         )
         ON CONFLICT (import_row_hash) WHERE import_row_hash IS NOT NULL DO UPDATE SET
           name = EXCLUDED.name,
           updated_at = timezone('utc', now())
         RETURNING id`,
        [
          facility.name,
          facility.slug,
          inferFacilityType(facility.facilityCategory, null),
          facility.address,
          facility.city ?? 'Harare',
          province,
          phone,
          facility.email,
          lat,
          lng,
          cityId,
          facility.searchKeywords,
          facility.facilityCategory,
          facility.ownershipType,
          formattedAddress,
          batchId,
          options.sourceType,
          rowHash,
        ],
      );

      const facilityId = insertResult.rows[0].id;
      facilityIdByKey.set(facility.key, facilityId);
      facilitySlugToId.set(facility.slug, facilityId);
      report.facilitiesCreated++;
    }

    for (const review of providerReviews) {
      await client.query(
        `INSERT INTO public.import_duplicate_reviews (
           import_batch_id, entity_type, source_entity_id, target_entity_id,
           confidence, match_reason, match_score
         ) VALUES ($1, 'provider', gen_random_uuid(), gen_random_uuid(), $2, $3, $4)`,
        [batchId, review.confidence, review.reason, review.score],
      );
    }

    for (const provider of normalizedProviders) {
      const match = matchProviderToFacility(provider, facilities, ref.existingFacilities);
      let facilityId = match.facilityId;

      if (!facilityId && match.facility) {
        facilityId = facilityIdByKey.get(match.facility.key) ??
          facilitySlugToId.get(match.facility.slug) ?? null;
      }

      if (!facilityId) {
        const fallbackKey = buildFacilityKey(
          provider.facilityName ?? `${provider.name.fullName} — Independent Practice`,
          provider.city,
          provider.address,
        );
        facilityId = facilityIdByKey.get(fallbackKey) ?? null;
      }

      if (!facilityId) {
        await insertFailedRow(
          client,
          batchId,
          provider.rowNumber,
          rawRows.find((r) => r.rowNumber === provider.rowNumber)?.raw ?? {},
          'FACILITY_MATCH_FAILED',
          'Could not link provider to a facility',
        );
        report.failed++;
        continue;
      }

      const existingByHash = ref.existingProviders.find((p) => p.import_row_hash === provider.rowHash);
      if (existingByHash) {
        report.imported++;
        continue;
      }

      const existingByReg = ref.existingProviders.find(
        (p) => provider.registrationNumber &&
          (p.registration_number === provider.registrationNumber || p.mdpcz_number === provider.mdpczNumber),
      );
      if (existingByReg) {
        await client.query(
          `UPDATE public.providers SET
             phone = COALESCE($2, phone),
             email = COALESCE($3, email),
             specialty = COALESCE($4, specialty),
             updated_at = timezone('utc', now())
           WHERE id = $1`,
          [
            existingByReg.id,
            provider.phone ? await normalizePhoneDb(provider.phone) : null,
            provider.email,
            provider.specialtyNormalized,
          ],
        );
        report.imported++;
        report.duplicatesMerged++;
        continue;
      }

      if (provider.city) {
        const cityRes = resolveCityId(provider.city, provider.province, ref.cities);
        if (cityRes.missing) {
          missingCitiesSet.add(provider.city);
          await upsertCity(client, provider.city, provider.province);
        }
      }

      const specialtyId = provider.specialtySlug ? specialtySlugToId.get(provider.specialtySlug) ?? null : null;
      const phone = provider.phone ? await normalizePhoneDb(provider.phone) : null;

      if (provider.specialtyRaw && !specialtyId) {
        await client.query(
          `INSERT INTO public.import_unmatched_specialties (import_batch_id, raw_specialty, occurrence_count)
           VALUES ($1, $2, 1)
           ON CONFLICT (import_batch_id, raw_specialty) DO UPDATE SET
             occurrence_count = import_unmatched_specialties.occurrence_count + 1`,
          [batchId, provider.specialtyRaw],
        );
      }

      const providerInsert = await client.query<{ id: string }>(
        `INSERT INTO public.providers (
           facility_id, tenant_id, name, slug, title, first_name, middle_name, last_name,
           specialty, specialty_id, mdpcz_number, registration_number, phone, email,
           profession, license_status, practice_type, search_keywords,
           verified_source, verified_status, import_batch_id, import_source, imported_at,
           import_row_hash, category_id, is_verified
         ) VALUES (
           $1, $1, $2, $3, $4, $5, $6, $7, $8, $9::uuid, $10, $11, $12, $13, $14, $15, $16, $17,
           $18::public.verified_source, 'pending', $19, $20, timezone('utc', now()), $21,
           CASE WHEN $9::uuid IS NOT NULL THEN 'specialist' ELSE 'general-practice' END, false
         )
         ON CONFLICT (import_row_hash) WHERE import_row_hash IS NOT NULL DO UPDATE SET
           updated_at = timezone('utc', now())
         RETURNING id`,
        [
          facilityId,
          provider.name.fullName,
          provider.slug,
          provider.name.title,
          provider.name.firstName,
          provider.name.middleName,
          provider.name.lastName,
          provider.specialtyNormalized,
          specialtyId,
          provider.mdpczNumber,
          provider.registrationNumber,
          phone,
          provider.email,
          provider.profession,
          provider.licenseStatus,
          provider.practiceType,
          provider.searchKeywords,
          provider.source,
          batchId,
          options.sourceType,
          provider.rowHash,
        ],
      );

      const providerId = providerInsert.rows[0].id;
      report.providersCreated++;

      if (specialtyId) {
        await client.query(
          `INSERT INTO public.provider_specialties (provider_id, specialty_id, is_primary, source, import_batch_id)
           VALUES ($1, $2, true, $3, $4)
           ON CONFLICT (provider_id, specialty_id) DO NOTHING`,
          [providerId, specialtyId, options.sourceType, batchId],
        );
      }

      await client.query(
        `INSERT INTO public.provider_facility_links (
           provider_id, facility_id, link_type, is_primary, match_confidence, import_batch_id
         ) VALUES ($1, $2, 'primary', true, $3::public.dedup_confidence, $4)
         ON CONFLICT (provider_id, facility_id) DO NOTHING`,
        [providerId, facilityId, match.confidence, batchId],
      );
      report.linksCreated++;
      report.imported++;
    }

    report.missingCities = [...missingCitiesSet];
    report.failed += rejectedProviders.length;

    const paths = exportReport(finalizeReport(report));

    await client.query(
      `UPDATE public.import_logs SET
         status = 'completed',
         imported_count = $2,
         failed_count = $3,
         duplicates_merged = $4,
         facilities_created = $5,
         providers_created = $6,
         links_created = $7,
         specialties_unmatched = $8,
         cities_missing = $9,
         geocoded_count = $10,
         report_json = $11,
         report_csv_path = $12,
         report_json_path = $13,
         completed_at = timezone('utc', now())
       WHERE id = $1`,
      [
        batchId,
        report.imported,
        report.failed,
        report.duplicatesMerged,
        report.facilitiesCreated,
        report.providersCreated,
        report.linksCreated,
        report.unmatchedSpecialtyCount,
        report.missingCities.length,
        report.geocodedCount,
        JSON.stringify(report),
        paths.csvPath,
        paths.jsonPath,
      ],
    );
  });

  return finalizeReport(report);
}

async function main(): Promise<void> {
  const parsed = parseArgs(process.argv);
  const options: ImportOptions = parsed;

  try {
    const report = await runImport(options);
    printReportSummary(report);

    if (!options.dryRun) {
      exportReport(report);
    }

    process.exit(report.failed > 0 ? 1 : 0);
  } catch (error) {
    logger.error('Import failed', {
      error: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : undefined,
    });
    process.exit(1);
  } finally {
    await closePool();
  }
}

main();
