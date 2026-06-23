#!/usr/bin/env python3
import re
import json
from pathlib import Path

text = Path('/tmp/myhealth-lovable.html').read_text(errors='ignore')
m = re.search(r'<title>([^<]+)</title>', text)
print('TITLE:', m.group(1) if m else 'none')

imgs = sorted(set(re.findall(r'https://[^"\'\s>]+\.(?:png|jpg|jpeg|webp)(?:\?[^"\'\s>]*)?', text)))
print('IMAGES:', len(imgs))
for u in imgs:
    print(u)

# lovable often embeds JSON in script tags
for script in re.findall(r'<script[^>]*>(.*?)</script>', text, re.S):
    if 'MyHealth' in script or 'hero' in script.lower():
        if len(script) < 5000:
            print('SCRIPT SNIP:', script[:500])
