#!/usr/bin/env python3
import csv
import sys
from collections import Counter

path = sys.argv[1] if len(sys.argv) > 1 else '/opt/smarthealth/pilot-results-50.csv'
rows = list(csv.DictReader(open(path, encoding='utf-8')))
rec = Counter(r['recommendation'] for r in rows)
gq = Counter(r['google_quality'] for r in rows if r['google_quality'])
gs = Counter(r['google_strategy'] for r in rows if r['google_strategy'])
dists = sorted(float(r['distance_km_between']) for r in rows if r['distance_km_between'])
print('total', len(rows))
print('recommendations', dict(rec))
print('google_quality', dict(gq))
print('google_strategy', dict(gs))
print('google_resolved_nominatim_failures', sum(1 for r in rows if not r['nominatim_lat'] and r['google_lat']))
if dists:
    print('median_distance_km_when_both', dists[len(dists) // 2])
    print('max_distance_km_when_both', max(dists))
