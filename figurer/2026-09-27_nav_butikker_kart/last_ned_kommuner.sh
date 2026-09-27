#!/usr/bin/env bash
# Laster ned kommunepolygoner (ETRS89 lon/lat) fra Kartverkets kommuneinfo-API
# til data/kommuner/<nr>.json. Hopper over filer som finnes. Kjør fra mappa.
cd "$(dirname "$0")/data" || exit 1
for nr in $(python3 -c "import json; print(' '.join(k['kommunenummer'] for k in json.load(open('kommuner.json'))))"); do
  f="kommuner/$nr.json"
  [ -s "$f" ] && continue
  curl -sL --retry 3 "https://api.kartverket.no/kommuneinfo/v1/kommuner/$nr/omrade?utkoordsys=4258" -o "$f" || echo "feil: $nr"
  sleep 0.2
done
echo "ferdig: $(ls kommuner | wc -l) filer"
