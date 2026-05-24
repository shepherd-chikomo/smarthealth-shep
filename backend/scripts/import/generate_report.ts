import { writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import type { ImportReport } from './types.js';
import { logger } from './logger.js';

export function createEmptyReport(
  batchId: string,
  sourceFile: string,
  dryRun: boolean,
): ImportReport {
  return {
    batchId,
    sourceFile,
    dryRun,
    startedAt: new Date().toISOString(),
    completedAt: '',
    totalRows: 0,
    imported: 0,
    failed: 0,
    duplicatesMerged: 0,
    facilitiesCreated: 0,
    providersCreated: 0,
    linksCreated: 0,
    specialtiesUnmatched: [],
    missingCities: [],
    unmatchedSpecialtyCount: 0,
    geocodedCount: 0,
    failedRows: [],
    duplicateReviews: [],
  };
}

export function finalizeReport(report: ImportReport): ImportReport {
  report.completedAt = new Date().toISOString();
  report.unmatchedSpecialtyCount = report.specialtiesUnmatched.length;
  return report;
}

function escapeCsv(value: unknown): string {
  const str = String(value ?? '');
  if (str.includes(',') || str.includes('"') || str.includes('\n')) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

export function reportToCsv(report: ImportReport): string {
  const lines: string[] = [
    'section,key,value',
    `summary,batch_id,${escapeCsv(report.batchId)}`,
    `summary,source_file,${escapeCsv(report.sourceFile)}`,
    `summary,dry_run,${report.dryRun}`,
    `summary,total_rows,${report.totalRows}`,
    `summary,imported,${report.imported}`,
    `summary,failed,${report.failed}`,
    `summary,duplicates_merged,${report.duplicatesMerged}`,
    `summary,facilities_created,${report.facilitiesCreated}`,
    `summary,providers_created,${report.providersCreated}`,
    `summary,links_created,${report.linksCreated}`,
    `summary,geocoded,${report.geocodedCount}`,
    `summary,unmatched_specialties,${report.unmatchedSpecialtyCount}`,
    `summary,missing_cities,${report.missingCities.length}`,
    '',
    'failed_rows,row_number,error_code,error_message',
  ];

  for (const row of report.failedRows) {
    lines.push(
      `failed,${row.rowNumber},${escapeCsv(row.errorCode)},${escapeCsv(row.errorMessage)}`,
    );
  }

  lines.push('', 'unmatched_specialties,specialty');
  for (const spec of report.specialtiesUnmatched) {
    lines.push(`specialty,${escapeCsv(spec)}`);
  }

  lines.push('', 'missing_cities,city');
  for (const city of report.missingCities) {
    lines.push(`city,${escapeCsv(city)}`);
  }

  lines.push('', 'duplicate_reviews,entity_type,source,target,confidence,score,reason');
  for (const review of report.duplicateReviews) {
    lines.push(
      `review,${escapeCsv(review.entityType)},${escapeCsv(review.sourceName)},${escapeCsv(review.targetName)},${review.confidence},${review.score},${escapeCsv(review.reason)}`,
    );
  }

  return lines.join('\n');
}

export interface ExportPaths {
  jsonPath: string;
  csvPath: string;
}

export function exportReport(
  report: ImportReport,
  outputDir?: string,
): ExportPaths {
  const dir = outputDir ?? resolve(process.cwd(), 'import-reports');
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });

  const timestamp = report.completedAt.replace(/[:.]/g, '-');
  const baseName = `import-${report.batchId.slice(0, 8)}-${timestamp}`;
  const jsonPath = resolve(dir, `${baseName}.json`);
  const csvPath = resolve(dir, `${baseName}.csv`);

  writeFileSync(jsonPath, JSON.stringify(report, null, 2), 'utf-8');
  writeFileSync(csvPath, reportToCsv(report), 'utf-8');

  logger.info('Import report exported', { jsonPath, csvPath });
  return { jsonPath, csvPath };
}

export function printReportSummary(report: ImportReport): void {
  console.log('\n========== SmartHealth Import Report ==========');
  console.log(`Batch ID:           ${report.batchId}`);
  console.log(`Source file:        ${report.sourceFile}`);
  console.log(`Dry run:            ${report.dryRun}`);
  console.log(`Total rows:         ${report.totalRows}`);
  console.log(`Imported:           ${report.imported}`);
  console.log(`Failed:             ${report.failed}`);
  console.log(`Duplicates merged:  ${report.duplicatesMerged}`);
  console.log(`Facilities created: ${report.facilitiesCreated}`);
  console.log(`Providers created:  ${report.providersCreated}`);
  console.log(`Links created:      ${report.linksCreated}`);
  console.log(`Geocoded:           ${report.geocodedCount}`);
  console.log(`Unmatched specs:    ${report.unmatchedSpecialtyCount}`);
  console.log(`Missing cities:     ${report.missingCities.length}`);
  console.log(`Duplicate reviews:  ${report.duplicateReviews.length}`);
  console.log('================================================\n');
}
