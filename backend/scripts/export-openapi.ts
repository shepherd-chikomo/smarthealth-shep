import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { buildApp } from '../src/app.js';

async function exportOpenApi() {
  const app = await buildApp();
  await app.ready();
  const spec = app.swagger();
  const outputPath = resolve(process.cwd(), 'openapi.json');
  writeFileSync(outputPath, JSON.stringify(spec, null, 2));
  console.log(`OpenAPI spec written to ${outputPath}`);
  await app.close();
}

exportOpenApi().catch((error) => {
  console.error(error);
  process.exit(1);
});
