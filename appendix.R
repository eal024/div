

# https://www.ssb.no/statbank/table/07459/tableViewLayout1/
api_table_population_age <- '{
  "query": [
    {
      "code": "Region",
      "selection": {
        "filter": "vs:Landet",
        "values": []
      }
    },
    {
      "code": "Kjonn",
      "selection": {
        "filter": "item",
        "values": [
          "2",
          "1"
        ]
      }
    },
    {
      "code": "Alder",
      "selection": {
        "filter": "vs:AlleAldre00B",
        "values": [
          "018",
          "019",
          "020",
          "021",
          "022",
          "023",
          "024",
          "025",
          "026",
          "027",
          "028",
          "029",
          "030",
          "031",
          "032",
          "033",
          "034",
          "035",
          "036",
          "037",
          "038",
          "039",
          "040",
          "041",
          "042",
          "043",
          "044",
          "045",
          "046",
          "047",
          "048",
          "049",
          "050",
          "051",
          "052",
          "053",
          "054",
          "055",
          "056",
          "057",
          "058",
          "059",
          "060",
          "061",
          "062",
          "063",
          "064",
          "065",
          "066",
          "067"
        ]
      }
    },
    {
      "code": "Tid",
      "selection": {
        "filter": "item",
        "values": [
          "2020",
          "2021",
          "2022",
          "2023",
          "2024"
        ]
      }
    }
  ],
  "response": {
    "format": "json-stat2"
  }
}'
