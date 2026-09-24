// eal_palette.js
// JS-eksport av paletten for Observable Plot via {ojs}-chunks i Quarto.
// Hold synkronisert med _lib/paletter.R.
//
// Bruk i Quarto-dokument:
//
//   ```{ojs}
//   //| file: ../_lib/eal_palette.js
//   ```
//
//   ```{ojs}
//   Plot.plot({
//     marks: [
//       Plot.lineY(data, { x: "maaned", y: "andel", stroke: "gruppe" })
//     ],
//     color: { range: ealPalette.okabeIto },
//     y: { grid: true },
//     x: { grid: false }
//   })
//   ```

const ealPalette = {
  // Okabe-Ito — Wilkes anbefaling, kolorblindt-trygg, 8 farger
  okabeIto: [
    "#E69F00",  // oransje
    "#56B4E9",  // himmelblå
    "#009E73",  // bluegreen
    "#F0E442",  // gul
    "#0072B2",  // blå
    "#D55E00",  // rødorange
    "#CC79A7",  // rosa
    "#000000"   // svart
  ],

  // Nav-branded — fargene fra eirikala.quarto.pub
  navBranded: {
    arbeidssoekere:     "#2c3e50",  // mørk blågrå
    nedsattArbeidsevne: "#1a6b4a",  // mørkegrønn
    referanse:          "#9ca3a3"   // lysegrå
  },

  // Sekvensiell — viridis (samme som scale_color_eal_sequential)
  viridis: [
    "#440154", "#482878", "#3E4989", "#31688E", "#26828E",
    "#1F9E89", "#35B779", "#6DCD59", "#B4DE2C", "#FDE725"
  ]
};
