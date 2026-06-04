import { pool } from '../src/lib/db.js';

const LANARK_LAT = -17.8055568;
const LANARK_LON = 31.0416504;
const FORMATTED = 'Lanark Road, Avondale West, Harare, Zimbabwe';

const result = await pool.query<{ name: string }>(
  `UPDATE public.facilities
   SET latitude = $1,
       longitude = $2,
       formatted_address = $3,
       updated_at = timezone('utc', now())
   WHERE city = 'Harare'
     AND address_line1 ILIKE '%lanark%'
   RETURNING name`,
  [LANARK_LAT, LANARK_LON, FORMATTED],
);

console.log(`Updated ${result.rowCount} Lanark Road facilities:`);
for (const row of result.rows) {
  console.log(`  - ${row.name}`);
}

await pool.end();
