#!/usr/bin/env python3
"""Download official Lovable assets for MyPractice marketing site."""
from __future__ import annotations

import re
import urllib.request
from pathlib import Path

BASE = 'https://mypractice-pocket-hub.lovable.app'
OUT = Path(__file__).resolve().parent.parent / 'public' / 'images'

# Mapped from Lovable bundle + site usage
ASSETS: dict[str, str] = {
    'hero-doctor-C1I4EWTa.jpg': 'hero-visual.jpg',
    'africa-healthcare-C1sBZvgf.jpg': 'africa-hero.jpg',
    'phone-mockup-QAlYaaqM.png': 'phone-mockup.png',
}


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    return urllib.request.urlopen(req, timeout=90).read()


def discover_assets() -> list[str]:
    html = fetch(f'{BASE}/').decode('utf-8', errors='ignore')
    js_paths = sorted(set(re.findall(r'/assets/[^"\']+\.js', html)))
    found: set[str] = set()
    for js_path in js_paths:
        js = fetch(f'{BASE}{js_path}').decode('utf-8', errors='ignore')
        for m in re.findall(r'/assets/([a-zA-Z0-9_-]+\.(?:png|jpg|jpeg|webp))', js):
            found.add(m)
    return sorted(found)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    discovered = discover_assets()
    print('discovered:', discovered)

    for hashed_name in discovered:
        out_name = ASSETS.get(hashed_name, hashed_name)
        url = f'{BASE}/assets/{hashed_name}'
        data = fetch(url)
        dest = OUT / out_name
        dest.write_bytes(data)
        print(f'{hashed_name} -> {out_name} ({len(data)} bytes)')

    # growth section may share hero-doctor or another asset — check for team/growth in bundle names
    for name in discovered:
        if 'team' in name.lower() or 'growth' in name.lower() or 'professional' in name.lower():
            out = OUT / 'growth-team.png' if name.endswith('.png') else OUT / 'growth-team.jpg'
            out.write_bytes(fetch(f'{BASE}/assets/{name}'))
            print(f'mapped growth: {name}')


if __name__ == '__main__':
    main()
