SELECT name, city, province, address_line1, latitude, longitude, geocode_quality
FROM facilities
WHERE name ILIKE '%Claremont%';
