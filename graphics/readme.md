```bash
for i in {0..7}; do
  inkscape --export-png-compression=9 "$i.svg" -o "$i.png"
done
```