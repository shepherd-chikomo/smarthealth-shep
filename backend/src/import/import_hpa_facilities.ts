import { createHash, randomUUID } from 'node:crypto';
import type pg from 'pg';
import { loadExcel } from './load_excel.js';
import { logger } from './logger.js';
import {
  buildFacilityRegistryKey,
  buildFullNameKey,
  formatFacilityName,
  inferProvinceFromCity,
  normalizeAddress,
  requireCity,
  buildLocationDedupKey,
  buildFacilityRegistryKeyWithRoleHolder,
} from './normalize_registry.js';
import { fetchImportResolutionRule } from './import_resolution_rules.js';
import { generateFacilitySlug, ensureUniqueSlug } from './generate_slugs.js';
import { buildFacilityAddressQuery, geocodeBatch } from './geocode.js';
import { formatAddressLine } from './format_address.js';
import {
  inferFacilityTypeFromName,
  type FacilityType,
} from './infer_facility_type.js';
import type { GeocodeResult, RawSpreadsheetRow } from './types.js';

function hpaFacilityType(facilityName: string): FacilityType {
  return inferFacilityTypeFromName(facilityName) ?? 'clinic';
}

const FACILITY_TYPE_ON_CONFLICT = `
  facility_type = CASE
    WHEN facilities.facility_type = 'clinic'::public.facility_type
    THEN EXCLUDED.facility_type
    ELSE facilities.facility_type
  END`;

function collectHpaGeocodeQueries(
  rows: Array<{
    facilityName: string;
    address: string;
    city: string;
    province: string;
  }>,
): string[] {
  const queries: string[] = [];
  for (const row of rows) {
    const q = buildFacilityAddressQuery({
      name: row.facilityName,
      addressLine1: row.address,
      city: row.city,
      province: row.province,
    });
    if (q) queries.push(q);
  }
  return queries;
}

function geocodeForHpaRow(
  row: { facilityName: string; address: string; city: string; province: string },
  geocodeResults: Map<string, GeocodeResult>,
): { latitude: number | null; longitude: number | null; formattedAddress: string | null } {
  const q = buildFacilityAddressQuery({
    name: row.facilityName,
    addressLine1: row.address,
    city: row.city,
    province: row.province,
  });
  const geo = q ? geocodeResults.get(q) : null;
  return {
    latitude: geo?.latitude ?? null,
    longitude: geo?.longitude ?? null,
    formattedAddress: geo?.formattedAddress ?? null,
  };
}

export interface HpaFacilityRow {
  rowNumber: number;
  facilityName: string;
  address: string;
  city: string;
  province: string;
  practitionerFirstName: string | null;
  practitionerLastName: string | null;
  normalizedNameKey: string;
  registryKey: string;
  rowHash: string;
  raw: Record<string, unknown>;
}

export function parseHpaFacilityRows(rawRows: RawSpreadsheetRow[]): {
  valid: HpaFacilityRow[];
  failed: { rowNumber: number; error: string; raw: Record<string, unknown> }[];
  ambiguous: HpaFacilityRow[][];
} {
  const failed: { rowNumber: number; error: string; raw: Record<string, unknown> }[] = [];
  const parsed: HpaFacilityRow[] = [];

  for (const row of rawRows) {
    const facilityName = row.raw.facilityName ? String(row.raw.facilityName).trim() : '';
    const address = row.raw.address ? String(row.raw.address).trim() : '';

    if (!facilityName || !address) {
      failed.push({
        rowNumber: row.rowNumber,
        error: 'Missing facility_name or physical_address',
        raw: row.raw,
      });
      continue;
    }

    const practitionerFirstName = row.raw.practitionerFirstName
      ? String(row.raw.practitionerFirstName).trim()
      : row.raw.practitionerName
        ? String(row.raw.practitionerName).split(/\s+/)[0] ?? null
        : null;
    const practitionerLastName = row.raw.practitionerLastName
      ? String(row.raw.practitionerLastName).trim()
      : null;

    const city = requireCity(row.raw.city ? String(row.raw.city) : null);
    const province = inferProvinceFromCity(city);
    const registryKey = buildFacilityRegistryKey(facilityName, address, city);

    parsed.push({
      rowNumber: row.rowNumber,
      facilityName: formatFacilityName(facilityName),
      address: formatAddressLine(address),
      city,
      province,
      practitionerFirstName,
      practitionerLastName,
      normalizedNameKey: buildFullNameKey(practitionerFirstName, practitionerLastName),
      registryKey,
      rowHash: createHash('sha256').update(JSON.stringify(row.raw)).digest('hex'),
      raw: row.raw,
    });
  }

  const keyGroups = new Map<string, HpaFacilityRow[]>();
  for (const row of parsed) {
    const dedupKey = `${normalizeAddress(row.facilityName)}|${normalizeAddress(row.address)}|${normalizeAddress(row.city ?? '')}`;
    const group = keyGroups.get(dedupKey) ?? [];
    group.push(row);
    keyGroups.set(dedupKey, group);
  }

  const valid: HpaFacilityRow[] = [];
  const ambiguous: HpaFacilityRow[][] = [];

  for (const group of keyGroups.values()) {
    if (group.length > 1) {
      const roleHolders = new Set(
        group.map((r) => r.normalizedNameKey).filter(Boolean),
      );
      if (roleHolders.size > 1) {
        ambiguous.push(group);
        continue;
      }
    }
    valid.push(group[0]);
  }

  return { valid, failed, ambiguous };
}

export async function importHpaFacilities(
  client: pg.PoolClient,
  filePath: string,
  batchId: string,
  dryRun: boolean,
  skipGeocoding = false,
): Promise<{
  created: number;
  failed: number;
  ambiguous: number;
  manualAssociation: number;
  facilityIds: Map<string, string>;
}> {
  const rawRows = loadExcel(filePath);
  const { valid, failed, ambiguous } = parseHpaFacilityRows(rawRows);

  logger.info(`HPA: ${valid.length} unique facilities, ${failed.length} failed, ${ambiguous.length} ambiguous groups`);

  const facilityIds = new Map<string, string>();
  let created = 0;
  let manualAssociation = 0;

  if (dryRun) {
    return {
      created: valid.length,
      failed: failed.length,
      ambiguous: ambiguous.length,
      manualAssociation: valid.filter((r) => !r.normalizedNameKey).length,
      facilityIds,
    };
  }

  for (const fail of failed) {
    await client.query(
      `INSERT INTO public.failed_imports (
         import_batch_id, row_number, entity_type, raw_data, error_code, error_message
       ) VALUES ($1, $2, 'facility', $3, 'VALIDATION_FAILED', $4)`,
      [batchId, fail.rowNumber, JSON.stringify(fail.raw), fail.error],
    );
  }

  const slugUsed = new Set<string>();
  // Seed with slugs already persisted so re-imports don't collide on the
  // unique `facilities_slug_key` constraint (new rows get a -N suffix).
  const existingFacilitySlugs = await client.query<{ slug: string }>(
    `SELECT slug FROM public.facilities WHERE slug IS NOT NULL`,
  );
  for (const r of existingFacilitySlugs.rows) slugUsed.add(r.slug);

  const geocodeQueries = [
    ...collectHpaGeocodeQueries(valid),
    ...ambiguous.flatMap((group) => collectHpaGeocodeQueries(group)),
  ];
  const geocodeResults =
    dryRun || skipGeocoding
      ? new Map<string, GeocodeResult>()
      : await geocodeBatch(client, geocodeQueries, skipGeocoding);

  if (!dryRun && !skipGeocoding) {
    logger.info(`HPA geocoded ${geocodeResults.size} unique addresses`);
  }

  for (const group of ambiguous) {
    const locationKey = buildLocationDedupKey(
      group[0].facilityName,
      group[0].address,
      group[0].city,
    );

    const mergedRule = await fetchImportResolutionRule(client, 'ambiguous_merged', locationKey);
    if (mergedRule?.payload) {
      const p = mergedRule.payload as Record<string, unknown>;
      const facilityName = String(p.facilityName ?? group[0].facilityName);
      const address = String(p.address ?? group[0].address);
      const city = p.city ? String(p.city) : group[0].city;
      const registryKey = String(p.registryKey ?? buildFacilityRegistryKey(facilityName, address, city));
      const facilityType = hpaFacilityType(facilityName);
      const slug = ensureUniqueSlug(
        generateFacilitySlug({
          key: registryKey,
          name: facilityName,
          slug: '',
          facilityType,
          address,
          province: null,
          city,
          phone: null,
          email: null,
          facilityCategory: null,
          ownershipType: null,
          latitude: null,
          longitude: null,
          formattedAddress: null,
          searchKeywords: [],
          sourceRows: [group[0].rowNumber],
        }),
        slugUsed,
      );
      const mergedProvince = inferProvinceFromCity(city);
      const geo = geocodeForHpaRow(
        { facilityName, address, city, province: mergedProvince },
        geocodeResults,
      );
      const insert = await client.query<{ id: string }>(
        `INSERT INTO public.facilities (
           name, slug, facility_type, address_line1, city, province,
           latitude, longitude, formatted_address,
           is_verified, is_claimed, verification_status,
           import_batch_id, import_source, registry_key
         ) VALUES ($1, $2, $3::public.facility_type, $4, $5, $6::public.zimbabwe_province, $7, $8, $9, false, false, 'draft', $10, 'HPA', $11)
         ON CONFLICT (registry_key) WHERE registry_key IS NOT NULL AND deleted_at IS NULL
         DO UPDATE SET
           name = EXCLUDED.name,
           address_line1 = EXCLUDED.address_line1,
           city = EXCLUDED.city,
           ${FACILITY_TYPE_ON_CONFLICT},
           latitude = COALESCE(facilities.latitude, EXCLUDED.latitude),
           longitude = COALESCE(facilities.longitude, EXCLUDED.longitude),
           formatted_address = COALESCE(facilities.formatted_address, EXCLUDED.formatted_address)
         RETURNING id`,
        [
          facilityName,
          slug,
          facilityType,
          address,
          city,
          mergedProvince,
          geo.latitude,
          geo.longitude,
          geo.formattedAddress,
          batchId,
          registryKey,
        ],
      );
      const facilityId = insert.rows[0].id;
      const firstName = p.practitionerFirstName ? String(p.practitionerFirstName) : null;
      const lastName = p.practitionerLastName ? String(p.practitionerLastName) : null;
      const nameKey = buildFullNameKey(firstName, lastName);
      if (nameKey) {
        await client.query(
          `INSERT INTO public.facility_role_holder_intents (
             facility_id, practitioner_first_name, practitioner_last_name, normalized_full_name, import_batch_id
           ) VALUES ($1, $2, $3, $4, $5)
           ON CONFLICT (facility_id) DO UPDATE SET
             practitioner_first_name = EXCLUDED.practitioner_first_name,
             practitioner_last_name = EXCLUDED.practitioner_last_name,
             normalized_full_name = EXCLUDED.normalized_full_name`,
          [facilityId, firstName, lastName, nameKey, batchId],
        );
      }
      facilityIds.set(registryKey, facilityId);
      created++;
      continue;
    }

    const distinctRule = await fetchImportResolutionRule(client, 'ambiguous_distinct', locationKey);
    if (distinctRule) {
      for (const row of group) {
        const scopedKey = buildFacilityRegistryKeyWithRoleHolder(
          row.facilityName,
          row.address,
          row.city,
          row.normalizedNameKey || 'unknown',
        );
        const facilityType = hpaFacilityType(row.facilityName);
        const slug = ensureUniqueSlug(
          generateFacilitySlug({
            key: scopedKey,
            name: row.facilityName,
            slug: '',
            facilityType,
            address: row.address,
            province: null,
            city: row.city,
            phone: null,
            email: null,
            facilityCategory: null,
            ownershipType: null,
            latitude: null,
            longitude: null,
            formattedAddress: null,
            searchKeywords: [],
            sourceRows: [row.rowNumber],
          }),
          slugUsed,
        );
        const geo = geocodeForHpaRow(row, geocodeResults);
        const insert = await client.query<{ id: string }>(
          `INSERT INTO public.facilities (
             name, slug, facility_type, address_line1, city, province,
             latitude, longitude, formatted_address,
             is_verified, is_claimed, verification_status,
             import_batch_id, import_source, import_row_hash, registry_key, search_keywords
           ) VALUES ($1, $2, $3::public.facility_type, $4, $5, $6::public.zimbabwe_province, $7, $8, $9, false, false, 'draft', $10, 'HPA', $11, $12, $13)
           ON CONFLICT (registry_key) WHERE registry_key IS NOT NULL AND deleted_at IS NULL
           DO UPDATE SET
             name = EXCLUDED.name,
             address_line1 = EXCLUDED.address_line1,
             city = EXCLUDED.city,
             ${FACILITY_TYPE_ON_CONFLICT},
             latitude = COALESCE(facilities.latitude, EXCLUDED.latitude),
             longitude = COALESCE(facilities.longitude, EXCLUDED.longitude),
             formatted_address = COALESCE(facilities.formatted_address, EXCLUDED.formatted_address)
           RETURNING id`,
          [
            row.facilityName,
            slug,
            facilityType,
            row.address,
            row.city,
            row.province,
            geo.latitude,
            geo.longitude,
            geo.formattedAddress,
            batchId,
            row.rowHash,
            scopedKey,
            [row.facilityName.toLowerCase(), row.city.toLowerCase()].filter(Boolean),
          ],
        );
        const facilityId = insert.rows[0].id;
        facilityIds.set(scopedKey, facilityId);
        created++;
        if (row.normalizedNameKey) {
          await client.query(
            `INSERT INTO public.facility_role_holder_intents (
               facility_id, practitioner_first_name, practitioner_last_name,
               normalized_full_name, import_batch_id
             ) VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (facility_id) DO UPDATE SET
               practitioner_first_name = EXCLUDED.practitioner_first_name,
               practitioner_last_name = EXCLUDED.practitioner_last_name,
               normalized_full_name = EXCLUDED.normalized_full_name`,
            [
              facilityId,
              row.practitionerFirstName,
              row.practitionerLastName,
              row.normalizedNameKey,
              batchId,
            ],
          );
        }
      }
      continue;
    }

    await client.query(
      `INSERT INTO public.import_review_queue (
         queue_type, import_batch_id, row_number, raw_data, notes
       ) VALUES ('ambiguous_facility', $1, $2, $3, $4)`,
      [
        batchId,
        group[0].rowNumber,
        JSON.stringify(group.map((g) => g.raw)),
        `Ambiguous facility: ${group.length} conflicting rows for same location key`,
      ],
    );
  }

  for (const row of valid) {
    const facilityType = hpaFacilityType(row.facilityName);
    const slug = ensureUniqueSlug(
      generateFacilitySlug({
        key: row.registryKey,
        name: row.facilityName,
        slug: '',
        facilityType,
        address: row.address,
        province: null,
        city: row.city,
        phone: null,
        email: null,
        facilityCategory: null,
        ownershipType: null,
        latitude: null,
        longitude: null,
        formattedAddress: null,
        searchKeywords: [],
        sourceRows: [row.rowNumber],
      }),
      slugUsed,
    );

    const geo = geocodeForHpaRow(row, geocodeResults);
    const insert = await client.query<{ id: string }>(
      `INSERT INTO public.facilities (
         name, slug, facility_type, address_line1, city, province,
         latitude, longitude, formatted_address,
         is_verified, is_claimed, verification_status,
         import_batch_id, import_source, import_row_hash, registry_key,
         search_keywords
       ) VALUES (
         $1, $2, $3::public.facility_type, $4, $5, $6::public.zimbabwe_province,
         $7, $8, $9,
         false, false, 'draft',
         $10, 'HPA', $11, $12,
         $13
       )
       ON CONFLICT (registry_key) WHERE registry_key IS NOT NULL AND deleted_at IS NULL
       DO UPDATE SET
         name = EXCLUDED.name,
         address_line1 = EXCLUDED.address_line1,
         city = EXCLUDED.city,
         province = EXCLUDED.province,
         import_batch_id = EXCLUDED.import_batch_id,
         ${FACILITY_TYPE_ON_CONFLICT},
         latitude = COALESCE(facilities.latitude, EXCLUDED.latitude),
         longitude = COALESCE(facilities.longitude, EXCLUDED.longitude),
         formatted_address = COALESCE(facilities.formatted_address, EXCLUDED.formatted_address)
       RETURNING id`,
      [
        row.facilityName,
        slug,
        facilityType,
        row.address,
        row.city,
        row.province,
        geo.latitude,
        geo.longitude,
        geo.formattedAddress,
        batchId,
        row.rowHash,
        row.registryKey,
        [row.facilityName.toLowerCase(), row.city.toLowerCase()].filter(Boolean),
      ],
    );

    const facilityId = insert.rows[0].id;
    facilityIds.set(row.registryKey, facilityId);
    created++;

    if (row.normalizedNameKey) {
      await client.query(
        `INSERT INTO public.facility_role_holder_intents (
           facility_id, practitioner_first_name, practitioner_last_name,
           normalized_full_name, import_batch_id
         ) VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (facility_id) DO UPDATE SET
           practitioner_first_name = EXCLUDED.practitioner_first_name,
           practitioner_last_name = EXCLUDED.practitioner_last_name,
           normalized_full_name = EXCLUDED.normalized_full_name`,
        [
          facilityId,
          row.practitionerFirstName,
          row.practitionerLastName,
          row.normalizedNameKey,
          batchId,
        ],
      );
    } else {
      manualAssociation++;
      await client.query(
        `INSERT INTO public.import_review_queue (
           queue_type, facility_id, import_batch_id, row_number, raw_data, notes
         ) VALUES ('manual_association', $1, $2, $3, $4, $5)`,
        [
          facilityId,
          batchId,
          row.rowNumber,
          JSON.stringify(row.raw),
          'Missing practitioner name on HPA row',
        ],
      );
    }
  }

  return {
    created,
    failed: failed.length,
    ambiguous: ambiguous.length,
    manualAssociation,
    facilityIds,
  };
}

export function createBatchId(): string {
  return randomUUID();
}
