# koble_kommune.py
# Gjør butikker og Nav-mottak om til punkt-GeoJSON og kobler dem til kommune
# ved romlig kobling mot Kartverkets (rå) kommunepolygoner med mapshaper.
# Kjør fra denne mappa: python3 koble_kommune.py
import json, subprocess

def til_geojson(inn, ut, id_felt):
    rader = json.load(open(inn))
    feats = []
    for r in rader:
        if r.get("lat") is None or r.get("lon") is None:
            continue
        p = {k: v for k, v in r.items() if k not in ("lat", "lon")}
        feats.append({"type": "Feature", "properties": p,
                      "geometry": {"type": "Point", "coordinates": [r["lon"], r["lat"]]}})
    json.dump({"type": "FeatureCollection", "features": feats}, open(ut, "w"), ensure_ascii=False)
    print(inn, "->", ut, len(feats), "punkter")

til_geojson("data/butikker_raa.json", "data/butikker_pkt.geojson", "orgnr")
til_geojson("data/mottak_raa.json",   "data/mottak_pkt.geojson",   "enhet_nr")

for navn in ("butikker", "mottak"):
    cmd = ["npx", "-y", "mapshaper", f"data/{navn}_pkt.geojson",
           "-join", "data/kommuner_raa.geojson", "fields=knr,kommune,fnr,fylke", "prefix=geo_",
           "-o", f"data/{navn}_koblet.geojson", "format=geojson"]
    print(subprocess.run(cmd, capture_output=True, text=True).stderr.strip()[-300:])
    d = json.load(open(f"data/{navn}_koblet.geojson"))
    n_uten = sum(1 for f in d["features"] if not f["properties"].get("geo_knr"))
    print(navn, ": uten kommune etter kobling:", n_uten, "av", len(d["features"]))
