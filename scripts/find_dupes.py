import re

for fname in ['d:/scholarship_app/lib/l10n/translations_en.dart', 'd:/scholarship_app/lib/l10n/translations_km.dart']:
    print(f'\n=== {fname.split("/")[-1]} ===')
    with open(fname, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    keys = {}
    for i, line in enumerate(lines, 1):
        m = re.match(r"\s*'([^']+)'\s*:", line)
        if m:
            key = m.group(1)
            if key in keys:
                keys[key].append(i)
            else:
                keys[key] = [i]
    dupes = {k: v for k, v in keys.items() if len(v) > 1}
    if not dupes:
        print("  No duplicates found.")
    for key, locs in dupes.items():
        print(f"  Key: '{key}'")
        print(f"    First:     line {locs[0]}")
        for loc in locs[1:]:
            print(f"    Duplicate: line {loc}")
    print(f"  Total duplicate keys: {len(dupes)}")
