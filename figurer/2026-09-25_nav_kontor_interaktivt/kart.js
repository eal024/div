// kart.js — interaktivt kart over Navs 243 lokalkontor (Leaflet 1.9)
// Data: nav_kontor.json (fra helper::nav_kontor, se lag_data.R).
// Bakgrunn: Kartverkets topografiske kart i gråtone (WMTS, åpen), dempet
// med et halvgjennomsiktig hvitt lag som varierer med zoom.
// Brukes av index.qmd (innlegg) og kart.html (fullskjerm).

(function () {
  "use strict";

  var el = document.getElementById("nk-kart");
  if (!el || typeof L === "undefined") return;
  var standalone = el.classList.contains("nk-fullside");
  var data_url = el.getAttribute("data-kilde") || "nav_kontor.json";

  // Tekster --------------------------------------------------------------

  var T = {
    en: {
      norge: "Norway",
      sok: "Find an office…",
      sok_ingen: "No office matches",
      aria: "Interactive map of Nav's local offices",
      tittel: "Nav's 243 local offices",
      legend_storrelse: "Size: registered employees",
      legend_farge: "Colour: access",
      legend_ingen: "no count in the register",
      legend_dropin: "walk-in service",
      legend_avtale: "appointment only",
      ansatte: " employees",
      ansatte_ingen: "No employee count registered",
      dropin: "Walk-in service at least one weekday",
      avtale: "By appointment only",
      hint: "Click the map to zoom with the scroll wheel",
      full: "Full screen",
      feil: "Could not load the office data",
      kilde: "Data: nav.no, Enhetsregisteret (Sept 2026)"
    },
    no: {
      norge: "Norge",
      sok: "Finn et kontor…",
      sok_ingen: "Ingen kontor passer",
      aria: "Interaktivt kart over Navs lokalkontor",
      tittel: "Navs 243 lokalkontor",
      legend_storrelse: "Størrelse: registrerte ansatte",
      legend_farge: "Farge: tilgang",
      legend_ingen: "ikke tall i registeret",
      legend_dropin: "drop-in",
      legend_avtale: "kun timeavtale",
      ansatte: " ansatte",
      ansatte_ingen: "Antall ansatte ikke registrert",
      dropin: "Drop-in minst én ukedag",
      avtale: "Kun etter timeavtale",
      hint: "Klikk i kartet for å zoome med musehjulet",
      full: "Fullskjerm",
      feil: "Kunne ikke laste kontordataene",
      kilde: "Data: nav.no, Enhetsregisteret (sept. 2026)"
    }
  };
  var lang = "en";
  if (standalone && /^(nb|nn|no)/i.test(navigator.language || "")) lang = "no";
  function t(k) { return T[lang][k]; }

  function esc(s) {
    return String(s).replace(/[&<>"]/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
    });
  }

  // Farger (Okabe-Ito) og symbolstørrelse --------------------------------

  var farge_dropin = "#D55E00";
  var farge_avtale = "#0072B2";
  var farge_ingen  = "#7a7a7a";

  // Areal proporsjonalt med ansatte. Skalaen vokser med zoom slik at
  // symbolene er små i Norge-visning og lesbare i by-visning.
  function skala(z) {
    var k = 0.95 * Math.pow(1.09, z - 5);
    return Math.max(0.65, Math.min(1.9, k));
  }
  function radius(ansatte, z) {
    if (ansatte == null) return Math.max(2.5, 2.2 * skala(z));
    return skala(z) * Math.sqrt(ansatte);
  }

  // Kart -----------------------------------------------------------------

  var mobil = L.Browser.mobile && !standalone;
  var map = L.map(el, {
    zoomControl: true,
    scrollWheelZoom: standalone,
    dragging: !mobil,
    minZoom: 4,
    maxZoom: 17,
    zoomSnap: 0.25,
    wheelPxPerZoomLevel: 90,
    attributionControl: true
  });
  map.attributionControl.setPrefix(false);
  el.setAttribute("aria-label", t("aria"));

  L.tileLayer(
    "https://cache.kartverket.no/v1/wmts/1.0.0/topograatone/default/webmercator/{z}/{y}/{x}.png",
    {
      attribution: '&copy; <a href="https://www.kartverket.no/">Kartverket</a>',
      maxZoom: 18,
      maxNativeZoom: 17
    }
  ).addTo(map);

  // Dempelag over flisene: svakt i Norge-visning (kystlinja skal synes),
  // sterkere i by-visning der terrenget ellers konkurrerer med symbolene.
  map.createPane("demp");
  map.getPane("demp").style.zIndex = 350;
  map.getPane("demp").style.pointerEvents = "none";
  var demp = L.rectangle([[-90, -180], [90, 180]], {
    pane: "demp", fillColor: "#f6f6f4", fillOpacity: 0.2, stroke: false, interactive: false
  }).addTo(map);
  function dempOpasitet(z) {
    var a = 0.2 + (Math.min(Math.max(z, 6), 10) - 6) / 4 * 0.3;   // 0,2 ved z<=6, 0,5 ved z>=10
    demp.setStyle({ fillOpacity: a });
  }

  L.control.scale({ imperial: false, position: "bottomleft", maxWidth: 120 }).addTo(map);

  var norge_bounds = L.latLngBounds([57.6, 4.0], [71.4, 31.5]);
  var flyr = false;
  function fitPadding() {
    // Sentrer Norge i det frie feltet vest for kontrollpanelet på brede skjermer
    return el.clientWidth > 700 ? { paddingTopLeft: [10, 10], paddingBottomRight: [280, 10] }
                                : { padding: [10, 10] };
  }
  map.fitBounds(norge_bounds, fitPadding());
  dempOpasitet(map.getZoom());

  var byer = [
    { navn: "Oslo",        lat: 59.918, lon: 10.745, zoom: 11 },
    { navn: "Bergen",      lat: 60.385, lon: 5.330,  zoom: 11 },
    { navn: "Trondheim",   lat: 63.425, lon: 10.410, zoom: 11.5 },
    { navn: "Stavanger",   lat: 58.950, lon: 5.730,  zoom: 11 },
    { navn: "Tromsø", lat: 69.655, lon: 18.960, zoom: 11.5 }
  ];

  // Bynavn i Norge-visning (skjules når grunnkartets navn tar over)
  var bynavn = L.layerGroup();
  byer.forEach(function (b) {
    L.tooltip([b.lat, b.lon], {
      permanent: true, direction: "right", offset: [6, 0], className: "nk-bynavn",
      interactive: false, content: b.navn
    }).addTo(bynavn);
  });
  function visBynavn(z) {
    if (z <= 7.5) { if (!map.hasLayer(bynavn)) bynavn.addTo(map); }
    else if (map.hasLayer(bynavn)) map.removeLayer(bynavn);
  }
  visBynavn(map.getZoom());

  // Scroll-hjul: av i innlegget til leseren klikker i kartet ---------------

  if (!standalone) {
    var hint = L.DomUtil.create("div", "nk-hint", el);
    var hint_timer = null;
    el.addEventListener("wheel", function () {
      if (map.scrollWheelZoom.enabled()) return;
      hint.textContent = t("hint");
      hint.classList.add("nk-vis");
      clearTimeout(hint_timer);
      hint_timer = setTimeout(function () { hint.classList.remove("nk-vis"); }, 1600);
    }, { passive: true });
    map.on("click", function () {
      map.scrollWheelZoom.enable();
      hint.classList.remove("nk-vis");
    });
    el.addEventListener("mouseleave", function () { map.scrollWheelZoom.disable(); });
  }

  // Kontroll: fullskjerm under zoom-knappene -------------------------------

  if (!standalone) {
    var full_kontroll = L.control({ position: "topleft" });
    full_kontroll.onAdd = function () {
      var div = L.DomUtil.create("div", "leaflet-bar nk-fullknapp");
      var a = L.DomUtil.create("a", "", div);
      a.href = "kart.html";
      a.target = "_blank";
      a.rel = "noopener";
      a.innerHTML = "⤢";
      a.setAttribute("data-rolle", "full");
      a.title = t("full");
      a.setAttribute("aria-label", t("full"));
      L.DomEvent.disableClickPropagation(div);
      return div;
    };
    full_kontroll.addTo(map);
  }

  // Kontroll: søk og byknapper i ett panel ---------------------------------

  var by_knapper = [];
  var sok_input, datalist;
  var panel = L.control({ position: "topright" });
  panel.onAdd = function () {
    var div = L.DomUtil.create("div", "nk-panel");
    L.DomEvent.disableClickPropagation(div);
    L.DomEvent.disableScrollPropagation(div);

    var sok = L.DomUtil.create("div", "nk-sok", div);
    sok_input = L.DomUtil.create("input", "", sok);
    sok_input.type = "search";
    sok_input.setAttribute("list", "nk-kontorliste");
    sok_input.setAttribute("aria-label", t("sok"));
    sok_input.placeholder = t("sok");
    sok_input.autocomplete = "off";
    datalist = L.DomUtil.create("datalist", "", sok);
    datalist.id = "nk-kontorliste";

    var byer_div = L.DomUtil.create("div", "nk-byer", div);
    var hjem = L.DomUtil.create("button", "", byer_div);
    hjem.type = "button";
    hjem.setAttribute("data-by", "norge");
    hjem.textContent = t("norge");
    hjem.addEventListener("click", function () {
      settAktiv("norge");
      map.closePopup();
      flyr = true;
      map.flyToBounds(norge_bounds, L.extend({ duration: 0.9 }, fitPadding()));
    });
    by_knapper.push(hjem);
    byer.forEach(function (b) {
      var btn = L.DomUtil.create("button", "", byer_div);
      btn.type = "button";
      btn.setAttribute("data-by", b.navn);
      btn.textContent = b.navn;
      btn.addEventListener("click", function () {
        settAktiv(b.navn);
        map.closePopup();
        flyr = true;
        map.flyTo([b.lat, b.lon], b.zoom, { duration: 1.1 });
      });
      by_knapper.push(btn);
    });
    return div;
  };
  panel.addTo(map);

  function settAktiv(navn) {
    by_knapper.forEach(function (btn) {
      btn.classList.toggle("nk-aktiv", btn.getAttribute("data-by") === navn);
    });
  }
  settAktiv("norge");
  map.on("movestart", function () { if (!flyr) settAktiv(null); });
  map.on("moveend", function () { flyr = false; });

  // Kontroll: tittel (bare fullskjerm) -------------------------------------

  var tittel_div;
  if (standalone) {
    var tittel_kontroll = L.control({ position: "topleft" });
    tittel_kontroll.onAdd = function () {
      tittel_div = L.DomUtil.create("div", "nk-tittel");
      L.DomEvent.disableClickPropagation(tittel_div);
      return tittel_div;
    };
    tittel_kontroll.addTo(map);
  }
  function tegnTittel() {
    if (!tittel_div) return;
    tittel_div.innerHTML = '<div class="nk-tittel-hoved">' + t("tittel") + "</div>" +
                           '<div class="nk-tittel-kilde">' + t("kilde") + ". © Kartverket</div>";
  }

  // Kontroll: tegnforklaring ----------------------------------------------

  var legend_div;
  var legend = L.control({ position: "bottomright" });
  legend.onAdd = function () {
    legend_div = L.DomUtil.create("div", "nk-legend");
    L.DomEvent.disableClickPropagation(legend_div);
    // På smale skjermer: sammenslått til én rad, trykk for å vise størrelsesskalaen
    if (el.clientWidth < 600) {
      legend_div.classList.add("nk-legend-kompakt");
      legend_div.setAttribute("role", "button");
      legend_div.setAttribute("tabindex", "0");
      legend_div.addEventListener("click", function () { legend_div.classList.toggle("nk-utvidet"); });
    }
    return legend_div;
  };
  legend.addTo(map);

  function legendNostet(z, trinn) {
    var r_max = radius(trinn[0], z);
    var gap = 13;
    var h = Math.max(2 * r_max + 6, 3 * gap + 4);
    var cx = r_max + 2;
    var x_knekk = 2 * r_max + 10;
    var x_tekst = 2 * r_max + 22;
    var w = x_tekst + 34;
    var bunn = h - 3;
    var y_topp = trinn.map(function (n) { return bunn - 2 * radius(n, z); });
    var y_lab = y_topp.slice();
    for (var i = 1; i < y_lab.length; i++) {
      if (y_lab[i] - y_lab[i - 1] < gap) y_lab[i] = y_lab[i - 1] + gap;
    }
    var overskudd = y_lab[y_lab.length - 1] - bunn;
    if (overskudd > 0) {
      h += overskudd; bunn += overskudd;
      y_topp = y_topp.map(function (y) { return y + overskudd; });
      y_lab = y_lab.map(function (y) { return y + overskudd; });
    }
    var svg = '<svg width="' + w + '" height="' + h + '" viewBox="0 0 ' + w + " " + h + '">';
    trinn.forEach(function (n, i) {
      var r = radius(n, z);
      svg += '<circle cx="' + cx + '" cy="' + (bunn - r) + '" r="' + r +
             '" fill="none" stroke="#444" stroke-width="1"/>';
      svg += '<polyline points="' + cx + "," + y_topp[i] + " " + x_knekk + "," + y_topp[i] + " " +
             (x_tekst - 3) + "," + y_lab[i] + '" fill="none" stroke="#999" stroke-width="0.7"/>';
      svg += '<text x="' + x_tekst + '" y="' + (y_lab[i] + 4) + '">' + n + "</text>";
    });
    return svg + "</svg>";
  }

  function legendRad(z, trinn) {
    // Små sirkler side om side med tallet under, når nøsting blir uleselig
    var r_max = radius(trinn[0], z);
    var h = 2 * r_max + 18;
    var x = 2;
    var svg = "";
    trinn.slice().reverse().forEach(function (n) {
      var r = radius(n, z);
      var cx = x + Math.max(r, 9);
      svg += '<circle cx="' + cx + '" cy="' + (r_max + 1) + '" r="' + r +
             '" fill="none" stroke="#444" stroke-width="1"/>';
      svg += '<text x="' + cx + '" y="' + (2 * r_max + 14) + '" text-anchor="middle">' + n + "</text>";
      x = cx + Math.max(r, 9) + 8;
    });
    return '<svg width="' + (x + 2) + '" height="' + h + '" viewBox="0 0 ' + (x + 2) + " " + h + '">' + svg + "</svg>";
  }

  function tegnLegend() {
    var z = map.getZoom();
    var trinn = [150, 50, 10];
    var svg = radius(trinn[0], z) < 12 ? legendRad(z, trinn) : legendNostet(z, trinn);
    function prikk(fill, stroke) {
      return '<svg width="14" height="14" viewBox="0 0 14 14"><circle cx="7" cy="7" r="5" fill="' +
             fill + '" stroke="' + stroke + '" stroke-width="1.5"/></svg>';
    }
    legend_div.innerHTML =
      '<div class="nk-legend-tittel">' + t("legend_storrelse") + "</div>" + svg +
      '<div class="nk-legend-tittel nk-legend-tittel2">' + t("legend_farge") + "</div>" +
      '<div class="nk-legend-rad">' + prikk(farge_dropin, "#fff") + t("legend_dropin") + "</div>" +
      '<div class="nk-legend-rad">' + prikk(farge_avtale, "#fff") + t("legend_avtale") + "</div>" +
      '<div class="nk-legend-rad">' + prikk("#fff", farge_ingen) + t("legend_ingen") + "</div>";
  }

  // Data og symboler ------------------------------------------------------

  var kontor = [];
  var markers = [];

  function tittel(s) {
    return String(s).toLowerCase().replace(/(^|[\s\-\/])(\S)/g, function (m, p, c) {
      return p + c.toUpperCase();
    });
  }

  function popupHtml(d) {
    var farge = d.ansatte == null ? farge_ingen : (d.dropin ? farge_dropin : farge_avtale);
    var ansatte = d.ansatte == null ? t("ansatte_ingen") : d.ansatte + t("ansatte");
    var adresse = [d.gate, d.postnr + " " + tittel(d.poststed)].filter(Boolean).join(", ");
    return '<div class="nk-popup-navn">' + esc(d.navn) + "</div>" +
           '<div class="nk-popup-adresse">' + esc(adresse) + "</div>" +
           '<div class="nk-popup-rad">' + ansatte + "</div>" +
           '<div class="nk-popup-rad"><span class="nk-popup-prikk" style="background:' + farge +
           '"></span>' + (d.dropin ? t("dropin") : t("avtale")) + "</div>";
  }

  function stil(d, z) {
    if (d.ansatte == null) {
      return { radius: radius(null, z), color: farge_ingen, weight: 1.2,
               fillColor: "#ffffff", fillOpacity: 0.9, opacity: 1 };
    }
    return { radius: radius(d.ansatte, z), color: "#ffffff", weight: 1,
             fillColor: d.dropin ? farge_dropin : farge_avtale, fillOpacity: 0.78, opacity: 1 };
  }

  function oppdaterSymboler() {
    var z = map.getZoom();
    markers.forEach(function (m, i) { m.setStyle(stil(kontor[i], z)); });
    tegnLegend();
    dempOpasitet(z);
    visBynavn(z);
  }

  function leggTilData(rader) {
    // Store symboler først slik at små tegnes oppå (null-verdier sist)
    kontor = rader.slice().sort(function (a, b) {
      return (b.ansatte == null ? -1 : b.ansatte) - (a.ansatte == null ? -1 : a.ansatte);
    });
    var z = map.getZoom();
    kontor.forEach(function (d) {
      var m = L.circleMarker([d.lat, d.lon], stil(d, z))
        .bindTooltip(esc(d.navn), { direction: "top", offset: [0, -4], opacity: 0.95 })
        .bindPopup(function () { return popupHtml(d); }, { maxWidth: 280, closeButton: false });
      m.on("mouseover", function () { m.setStyle({ weight: 2.5, color: "#111111" }); });
      m.on("mouseout", function () { m.setStyle(stil(d, map.getZoom())); });
      m.addTo(map);
      markers.push(m);
    });

    var navn = kontor.map(function (d) { return d.navn; }).sort();
    datalist.innerHTML = navn.map(function (n) { return '<option value="' + esc(n) + '">'; }).join("");
    sok_input.addEventListener("change", function () {
      var q = sok_input.value.trim().toLowerCase();
      if (!q) { sok_input.removeAttribute("aria-invalid"); return; }
      var i = kontor.findIndex(function (d) { return d.navn.toLowerCase() === q; });
      if (i < 0) i = kontor.findIndex(function (d) { return d.navn.toLowerCase().indexOf(q) >= 0; });
      if (i < 0) {
        sok_input.setAttribute("aria-invalid", "true");
        sok_input.setCustomValidity(t("sok_ingen"));
        sok_input.reportValidity();
        return;
      }
      sok_input.removeAttribute("aria-invalid");
      sok_input.setCustomValidity("");
      sok_input.value = kontor[i].navn;
      settAktiv(null);
      flyr = true;
      map.flyTo([kontor[i].lat, kontor[i].lon], 13, { duration: 1.0 });
      map.once("moveend", function () { markers[i].openPopup(); });
      sok_input.blur();
    });
    sok_input.addEventListener("input", function () { sok_input.setCustomValidity(""); });

    tegnLegend();
  }

  map.on("zoomend", oppdaterSymboler);

  fetch(data_url)
    .then(function (r) {
      if (!r.ok) throw new Error(r.status + " " + data_url);
      return r.json();
    })
    .then(leggTilData)
    .catch(function (e) {
      el.insertAdjacentHTML("beforeend",
        '<div class="nk-feil" role="alert">' + t("feil") + "</div>");
      console.error(e);
    });

  // Språk -----------------------------------------------------------------

  var kilde_vist = null;
  function settSprak(l) {
    if (!T[l]) return;
    lang = l;
    el.setAttribute("aria-label", t("aria"));
    if (standalone) document.documentElement.lang = lang === "no" ? "nb" : "en";
    by_knapper.forEach(function (btn) {
      if (btn.getAttribute("data-by") === "norge") btn.textContent = t("norge");
    });
    var full = el.querySelector('a[data-rolle="full"]');
    if (full) { full.title = t("full"); full.setAttribute("aria-label", t("full")); }
    if (sok_input) { sok_input.placeholder = t("sok"); sok_input.setAttribute("aria-label", t("sok")); }
    if (kilde_vist) map.attributionControl.removeAttribution(kilde_vist);
    kilde_vist = t("kilde");
    map.attributionControl.addAttribution(kilde_vist);
    tegnLegend();
    tegnTittel();
    markers.forEach(function (m, i) {
      if (m.isPopupOpen()) m.setPopupContent(popupHtml(kontor[i]));
    });
  }
  settSprak(lang);

  // Følg språkknappen i innlegget (setLang fra _lang-toggle.html)
  if (!standalone) {
    if (typeof window.setLang === "function") {
      var orig = window.setLang;
      window.setLang = function (l) { orig(l); settSprak(l); };
    } else {
      console.warn("kart.js: fant ikke setLang(), kartet blir på engelsk");
    }
  }
})();
