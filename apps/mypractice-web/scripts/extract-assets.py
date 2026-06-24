#!/usr/bin/env python3
"""Extract marketing images from Lovable mockup screenshots."""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image

ASSETS = Path('/mnt/c/Users/sheph/.cursor/projects/c-Users-sheph-Projects-smarthealth-shep/assets')
OUT = Path(__file__).resolve().parent.parent / 'public' / 'images'

# (source filename suffix, output name, crop box as % of width/height: left, top, right, bottom)
CROPS: list[tuple[str, str, tuple[float, float, float, float]]] = [
    # Hero — right visual column (doctor + phone + floating cards)
    (
        'image-bf6d0af5-9c55-474c-9a37-2bfcc0957282.png',
        'hero-visual.png',
        (0.48, 0.10, 0.98, 0.88),
    ),
    # Growth — team photo (right column)
    (
        'image-e3a6271f-b519-4490-a2c5-65cc72a7b637.png',
        'growth-team.png',
        (0.52, 0.08, 0.97, 0.92),
    ),
    # Africa hero — healthcare professionals photo (faces, minimal overlay text)
    (
        'image-10888453-c35e-4349-a3fb-9a08825c0953.png',
        'africa-hero.png',
        (0.42, 0.0, 1.0, 0.62),
    ),
    # Essentials — phone mockup (left column)
    (
        'image-154da4fa-7879-49af-9656-5c43880261da.png',
        'phone-mockup.png',
        (0.04, 0.22, 0.40, 0.95),
    ),
]


def find_source(suffix: str) -> Path:
    for path in ASSETS.iterdir():
        if path.name.endswith(suffix):
            return path
    raise FileNotFoundError(suffix)


def crop_pct(img: Image.Image, box: tuple[float, float, float, float]) -> Image.Image:
    w, h = img.size
    l, t, r, b = box
    return img.crop((int(w * l), int(h * t), int(w * r), int(h * b)))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    for suffix, out_name, box in CROPS:
        src = find_source(suffix)
        img = Image.open(src).convert('RGB')
        cropped = crop_pct(img, box)
        dest = OUT / out_name
        cropped.save(dest, optimize=True, quality=92)
        print(f'{out_name}: {cropped.size} from {src.name} ({img.size})')

    # Remove wrongly-sourced unsplash hero if present
    old = OUT.parent / 'hero-doctor.jpg'
    if old.exists():
        old.unlink()
        print('removed hero-doctor.jpg')


if __name__ == '__main__':
    main()
