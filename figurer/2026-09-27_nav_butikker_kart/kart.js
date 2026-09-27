// kart.js — kommuner etter Nav-tilstedeværelse, dagligvarebutikker og
// Nav-kontor/mottak (Leaflet 1.9).
// Data i data/: kommuner.geojson og fylker.geojson (Kartverket, forenklet),
// kommune_stat.json, butikker.json (helper::dagligvare), navpunkter.json
// (helper::nav_mottak + helper::nav_kontor). Pipeline: lag_data.R i
// div/figurer/2026-09-27_nav_butikker_kart/.
// Brukes av index.qmd (innlegg) og kart.html (fullskjerm).

(function () {
  "use strict";

  var el = document.getElementById("nk-kart");
  if (!el || typeof L === "undefined") return;
  var standalone = el.classList.contains("nk-fullside");
  var sti = el.getAttribute("data-sti") || "data/";
  var smal = el.clientWidth < 600;

  // Tekster --------------------------------------------------------------

  var T = {
    en: {
      norge: "Norway", sok: "Find a municipality…", sok_ingen: "No municipality matches",
      aria: "Interactive map of Nav offices, grocery stores and municipalities",
      tittel: "37 municipalities have a grocery store but no Nav",
      l_status: "Municipality has", l_kontor: "a Nav office", l_mottak: "a reception point only", l_ingen: "no Nav",
      l_butikk: "Grocery stores", l_butikk_rad: "grocery store (from zoom level 8)",
      l_nav: "Nav", l_nav_kontor: "Nav office", l_nav_mottak: "reception point outside the office",
      p_kontor: "Nav office in the municipality", p_mottak: "Reception point only, office elsewhere", p_ingen: "No Nav office or reception point",
      butikker: "grocery stores", kiosker: "kiosks", median: "Median distance from a store to Nav",
      naermeste: "Nearest Nav", km: "km", dager: "days open a week", dropin: "with walk-in service",
      ansatte: "employees", kontor: "Nav office", mottak: "Reception point of", legend: "Legend",
      hint: "Click the map to zoom with the scroll wheel", full: "Full screen", feil: "Could not load the map data",
      kilde: "Data: nav.no, Enhetsregisteret (Sept 2026)"
    },
    no: {
      norge: "Norge", sok: "Finn en kommune…", sok_ingen: "Ingen kommune passer",
      aria: "Interaktivt kart over Nav-kontor, dagligvarebutikker og kommuner",
      tittel: "37 kommuner har dagligvarebutikk, men ikke Nav",
      l_status: "Kommunen har", l_kontor: "Nav-kontor", l_mottak: "bare publikumsmottak", l_ingen: "ikke Nav",
      l_butikk: "Dagligvarebutikker", l_butikk_rad: "dagligvarebutikk (fra zoomnivå 8)",
      l_nav: "Nav", l_nav_kontor: "Nav-kontor", l_nav_mottak: "mottak utenfor kontoret",
      p_kontor: "Nav-kontor i kommunen", p_mottak: "Bare publikumsmottak, kontoret ligger et annet sted", p_ingen: "Verken Nav-kontor eller mottak",
      butikker: "dagligvarebutikker", kiosker: "kiosker", median: "Medianavstand fra butikk til Nav",
      naermeste: "Nærmeste Nav", km: "km", dager: "dager åpent i uka", dropin: "med drop-in",
      ansatte: "ansatte", kontor: "Nav-kontor", mottak: "Publikumsmottak for", legend: "Tegnforklaring",
      hint: "Klikk i kartet for å zoome med musehjulet", full: "Fullskjerm", feil: "Kunne ikke laste kartdataene",
      kilde: "Data: nav.no, Enhetsregisteret (sept. 2026)"
    }
  };
  var lang = "en";
  if (standalone && /^(nb|nn|no)/i.test(navigator.language || "")) lang = "no";
  function t(k) { return T[lang][k]; }
  function esc(s) {
    return String(s == null ? "" : s).replace(/[&<>"]/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
    });
  }
  function fmt(n) { return n == null ? "–" : String(n).replace(".", lang === "no" ? "," : "."); }

  // Farger og størrelser -------------------------------------------------

  // De 37 kommunene uten Nav er figuren; kontor og mottak er grunn.
  var farge_status      = { kontor: "#a7c2b3", mottak: "#e4eae6", ingen: "#D55E00" };
  var farge_status_kant = { kontor: "#8fa79a", mottak: "#b5c3bb", ingen: "#7a3a1e" };
  var farge_butikk = "#5d6d66";
  var farge_nav    = "#1C2B3A";
  var farge_fylke  = "#7c8891";

  function skala(z) { return Math.max(0.7, Math.min(2.2, 0.9 * Math.pow(1.12, z - 5))); }
  function r_butikk(z) { return z < 10 ? 2.0 : 2.6; }
  function r_nav(z)    { return z < 8 ? 2.0 : Math.min(6, 3.0 * skala(z)); }
  function visButikker(z) { return z >= 8; }

  // Kart -----------------------------------------------------------------

  var mobil = L.Browser.mobile && !standalone;
  var map = L.map(el, {
    zoomControl: true, scrollWheelZoom: standalone, dragging: !mobil, touchZoom: !mobil,
    minZoom: 4, maxZoom: 17, zoomSnap: 0.25, wheelPxPerZoomLevel: 90
  });
  map.attributionControl.setPrefix(false);
  el.setAttribute("aria-label", t("aria"));

  L.tileLayer("https://cache.kartverket.no/v1/wmts/1.0.0/topograatone/default/webmercator/{z}/{y}/{x}.png",
    { attribution: '&copy; <a href="https://www.kartverket.no/">Kartverket</a>', maxZoom: 18, maxNativeZoom: 17 }).addTo(map);

  map.createPane("demp");     map.getPane("demp").style.zIndex = 350;  map.getPane("demp").style.pointerEvents = "none";
  map.createPane("kommuner"); map.getPane("kommuner").style.zIndex = 400;
  map.createPane("fylker");   map.getPane("fylker").style.zIndex = 410;  map.getPane("fylker").style.pointerEvents = "none";
  map.createPane("nav");      map.getPane("nav").style.zIndex = 430;

  var demp = L.rectangle([[-90, -180], [90, 180]], { pane: "demp", fillColor: "#f6f6f4", fillOpacity: 0.25, stroke: false, interactive: false }).addTo(map);
  function dempOpasitet(z) { demp.setStyle({ fillOpacity: 0.25 + (Math.min(Math.max(z, 6), 10) - 6) / 4 * 0.25 }); }

  L.control.scale({ imperial: false, position: "bottomleft", maxWidth: 120 }).addTo(map);

  var norge_bounds = L.latLngBounds([57.6, 4.0], [71.4, 31.5]);
  var flyr = false;
  function fitPadding() {
    return el.clientWidth > 700 ? { paddingTopLeft: [10, 10], paddingBottomRight: [290, 10] } : { padding: [10, 10] };
  }
  map.fitBounds(norge_bounds, fitPadding());
  dempOpasitet(map.getZoom());

  var byer = [
    { navn: "Oslo", lat: 59.918, lon: 10.745, zoom: 11 }, { navn: "Bergen", lat: 60.385, lon: 5.330, zoom: 11 },
    { navn: "Trondheim", lat: 63.425, lon: 10.410, zoom: 11.5 }, { navn: "Stavanger", lat: 58.950, lon: 5.730, zoom: 11 },
    { navn: "Tromsø", lat: 69.655, lon: 18.960, zoom: 11.5 }
  ];
  function flyTilBy(navn) {
    map.closePopup(); flyr = true;
    if (navn === "norge") { map.flyToBounds(norge_bounds, L.extend({ duration: 0.9 }, fitPadding())); return; }
    var b = byer.find(function (x) { return x.navn === navn; });
    if (b) map.flyTo([b.lat, b.lon], b.zoom, { duration: 1.1 });
  }

  // Scroll-hjul og fullskjerm ---------------------------------------------

  if (!standalone) {
    var hint = L.DomUtil.create("div", "nk-hint", el), hint_timer = null;
    el.addEventListener("wheel", function () {
      if (map.scrollWheelZoom.enabled()) return;
      hint.textContent = t("hint"); hint.classList.add("nk-vis");
      clearTimeout(hint_timer); hint_timer = setTimeout(function () { hint.classList.remove("nk-vis"); }, 1600);
    }, { passive: true });
    map.on("click", function () { map.scrollWheelZoom.enable(); hint.classList.remove("nk-vis"); });
    el.addEventListener("mouseleave", function () { map.scrollWheelZoom.disable(); });

    var full_kontroll = L.control({ position: "topleft" });
    full_kontroll.onAdd = function () {
      var div = L.DomUtil.create("div", "leaflet-bar nk-fullknapp");
      var a = L.DomUtil.create("a", "", div);
      a.href = "kart.html"; a.target = "_blank"; a.rel = "noopener"; a.innerHTML = "⤢";
      a.setAttribute("data-rolle", "full"); a.title = t("full"); a.setAttribute("aria-label", t("full"));
      L.DomEvent.disableClickPropagation(div);
      return div;
    };
    full_kontroll.addTo(map);
  }

  // Panel: søk og byer -------------------------------------------------------

  var by_knapper = [], by_select, sok_input, datalist;
  var panel = L.control({ position: "topright" });
  panel.onAdd = function () {
    var div = L.DomUtil.create("div", "nk-panel");
    L.DomEvent.disableClickPropagation(div); L.DomEvent.disableScrollPropagation(div);
    var sok = L.DomUtil.create("div", "nk-sok", div);
    sok_input = L.DomUtil.create("input", "", sok);
    sok_input.type = "search"; sok_input.setAttribute("list", "nk-kommuneliste");
    sok_input.setAttribute("aria-label", t("sok")); sok_input.placeholder = t("sok"); sok_input.autocomplete = "off";
    datalist = L.DomUtil.create("datalist", "", sok); datalist.id = "nk-kommuneliste";

    if (smal) {
      // Smal skjerm: nedtrekksliste i stedet for seks knapper
      by_select = L.DomUtil.create("select", "nk-byvalg", div);
      by_select.setAttribute("aria-label", t("norge"));
      [{ navn: "norge" }].concat(byer).forEach(function (b) {
        var o = L.DomUtil.create("option", "", by_select);
        o.value = b.navn; o.textContent = b.navn === "norge" ? t("norge") : b.navn;
      });
      by_select.addEventListener("change", function () { flyTilBy(by_select.value); });
    } else {
      var byer_div = L.DomUtil.create("div", "nk-byer", div);
      [{ navn: "norge" }].concat(byer).forEach(function (b) {
        var btn = L.DomUtil.create("button", "", byer_div);
        btn.type = "button"; btn.setAttribute("data-by", b.navn);
        btn.textContent = b.navn === "norge" ? t("norge") : b.navn;
        btn.addEventListener("click", function () { settAktiv(b.navn); flyTilBy(b.navn); });
        by_knapper.push(btn);
      });
    }
    return div;
  };
  panel.addTo(map);

  function settAktiv(navn) {
    by_knapper.forEach(function (btn) { btn.classList.toggle("nk-aktiv", btn.getAttribute("data-by") === navn); });
  }
  settAktiv("norge");
  map.on("movestart", function () { if (!flyr) settAktiv(null); });
  map.on("moveend", function () { flyr = false; });

  // Tittel (fullskjerm) -----------------------------------------------------

  var tittel_div;
  if (standalone) {
    var tittel_kontroll = L.control({ position: "topleft" });
    tittel_kontroll.onAdd = function () { tittel_div = L.DomUtil.create("div", "nk-tittel"); L.DomEvent.disableClickPropagation(tittel_div); return tittel_div; };
    tittel_kontroll.addTo(map);
  }
  function tegnTittel() {
    if (!tittel_div) return;
    tittel_div.innerHTML = '<div class="nk-tittel-hoved">' + t("tittel") + "</div>" +
                           '<div class="nk-tittel-kilde">' + t("kilde") + ". © Kartverket</div>";
  }

  // Tegnforklaring med lagvalg ---------------------------------------------

  var legend_div;
  var lag_paa = { kommuner: true, butikker: !smal, nav: true };
  var legend = L.control({ position: "bottomright" });
  legend.onAdd = function () {
    legend_div = L.DomUtil.create("div", "nk-legend");
    L.DomEvent.disableClickPropagation(legend_div); L.DomEvent.disableScrollPropagation(legend_div);
    if (smal) legend_div.classList.add("nk-legend-kompakt");
    return legend_div;
  };
  legend.addTo(map);

  function tegnLegend() {
    function rute(f, k) { return '<span class="nk-legend-rute" style="background:' + f + ';border-color:' + k + '"></span>'; }
    function prikk(fill, stroke, r, w) {
      return '<svg width="14" height="14" viewBox="0 0 14 14"><circle cx="7" cy="7" r="' + r + '" fill="' + fill + '" stroke="' + stroke + '" stroke-width="' + (w || 1.2) + '"/></svg>';
    }
    function seksjon(k, tittel, rader) {
      return '<div class="nk-legend-seksjon"><label class="nk-legend-tittel"><input type="checkbox" data-lag="' + k + '"' +
             (lag_paa[k] ? " checked" : "") + "> " + tittel + "</label>" + rader + "</div>";
    }
    var h = "";
    if (smal) h += '<div class="nk-legend-knapp" role="button" tabindex="0">' + t("legend") + ' <span class="nk-legend-pil">▸</span></div>';
    h += '<div class="nk-legend-innhold">' +
      seksjon("kommuner", t("l_status"),
        '<div class="nk-legend-rad">' + rute(farge_status.kontor, farge_status_kant.kontor) + t("l_kontor") + "</div>" +
        '<div class="nk-legend-rad">' + rute(farge_status.mottak, farge_status_kant.mottak) + t("l_mottak") + "</div>" +
        '<div class="nk-legend-rad">' + rute(farge_status.ingen,  farge_status_kant.ingen)  + t("l_ingen")  + "</div>") +
      seksjon("nav", t("l_nav"),
        '<div class="nk-legend-rad">' + prikk(farge_nav, "#fff", 5) + t("l_nav_kontor") + "</div>" +
        '<div class="nk-legend-rad">' + prikk("#fff", farge_nav, 4.5, 1.8) + t("l_nav_mottak") + "</div>") +
      seksjon("butikker", t("l_butikk"),
        '<div class="nk-legend-rad">' + prikk(farge_butikk, "#fff", 3.5) + t("l_butikk_rad") + "</div>") +
      "</div>";
    legend_div.innerHTML = h;
    legend_div.querySelectorAll('input[data-lag]').forEach(function (box) {
      box.addEventListener("change", function () { lag_paa[box.getAttribute("data-lag")] = box.checked; visLag(); });
    });
    var knapp = legend_div.querySelector(".nk-legend-knapp");
    if (knapp) {
      var toggle = function () { legend_div.classList.toggle("nk-utvidet"); };
      knapp.addEventListener("click", toggle);
      knapp.addEventListener("keydown", function (e) { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); toggle(); } });
    }
  }

  // Data -----------------------------------------------------------------

  var kommune_lag, fylke_lag, butikk_lag, nav_lag, ingen_ringer;
  var kommune_stat = {}, kommune_features = {}, butikk_markers = [], nav_markers = [], kommuner_gj;
  // Kommuner og butikker deler ett canvas i samme pane, slik at klikk treffer
  // begge (øverste vinner). Et canvas over SVG-en ville ellers skjule polygonene.
  var canvas = L.canvas({ pane: "kommuner", padding: 0.3 });

  function statusTekst(s) { return s === "kontor" ? t("p_kontor") : s === "mottak" ? t("p_mottak") : t("p_ingen"); }
  function kommuneLabel(p) { return p.kommune + " (" + p.fylke + ")"; }

  function popupKommune(p) {
    var s = kommune_stat[p.knr] || {};
    return '<div class="nk-popup-navn">' + esc(p.kommune) + ' <span class="nk-popup-liten">(' + esc(p.fylke) + ")</span></div>" +
      '<div class="nk-popup-rad"><span class="nk-popup-prikk" style="background:' + (farge_status[s.status] || "#eee") +
      ";border:1px solid " + (farge_status_kant[s.status] || "#999") + '"></span>' + statusTekst(s.status) + "</div>" +
      '<div class="nk-popup-rad">' + fmt(s.n_butikker) + " " + t("butikker") + (s.n_kiosk ? ", " + fmt(s.n_kiosk) + " " + t("kiosker") : "") + "</div>" +
      (s.avstand_median != null ? '<div class="nk-popup-rad">' + t("median") + ": " + fmt(s.avstand_median) + " " + t("km") + "</div>" : "") +
      (s.naermeste_navn && s.status !== "kontor" ? '<div class="nk-popup-rad nk-popup-liten">' + t("naermeste") + ": " + esc(s.naermeste_navn) + "</div>" : "");
  }
  function popupButikk(d) {
    return '<div class="nk-popup-navn">' + esc(d.navn) + "</div>" +
      '<div class="nk-popup-adresse">' + esc(d.kjede || (lang === "no" ? "Ukjent kjede" : "Unknown chain")) + " · " + esc(d.kommune) + "</div>" +
      '<div class="nk-popup-rad">' + t("naermeste") + ": " + esc(d.naermeste) + ", " + fmt(d.avstand_km) + " " + t("km") + "</div>" +
      (d.ansatte != null ? '<div class="nk-popup-rad nk-popup-liten">' + fmt(d.ansatte) + " " + t("ansatte") + "</div>" : "");
  }
  function popupNav(d) {
    var hode = d.type === "kontor" ? esc(d.kontor_navn) : t("mottak") + " " + esc(d.kontor_navn);
    return '<div class="nk-popup-navn">' + hode + "</div>" +
      '<div class="nk-popup-adresse">' + esc(d.sted || "") + (d.kommune && d.kommune !== d.sted ? " · " + esc(d.kommune) : "") + "</div>" +
      (d.n_dager_aapent != null ? '<div class="nk-popup-rad">' + fmt(d.n_dager_aapent) + " " + t("dager") + ", " + fmt(d.n_dager_dropin) + " " + t("dropin") + "</div>" : "");
  }

  function stilKommune(f) {
    var s = (kommune_stat[f.properties.knr] || {}).status || "mottak";
    var z = map.getZoom();
    var ingen = s === "ingen";
    return { pane: "kommuner", renderer: canvas,
             color: farge_status_kant[s], weight: ingen ? (z >= 8 ? 2 : 1.5) : (z >= 8 ? 1 : 0.5), opacity: 0.9,
             fillColor: farge_status[s], fillOpacity: ingen ? (z >= 10 ? 0.45 : 0.6) : (z >= 10 ? 0.2 : 0.6) };
  }
  function stilNav(d, z) {
    return d.type === "kontor"
      ? { pane: "nav", radius: r_nav(z), color: "#ffffff", weight: z < 8 ? 0.5 : 1.2, fillColor: farge_nav, fillOpacity: z < 8 ? 0.75 : 0.95 }
      : { pane: "nav", radius: r_nav(z), color: farge_nav, weight: z < 8 ? 1 : 1.8, fillColor: "#ffffff", fillOpacity: 0.95 };
  }

  function visLag() {
    var z = map.getZoom();
    function sett(lag, paa) { if (!lag) return; if (paa && !map.hasLayer(lag)) lag.addTo(map); if (!paa && map.hasLayer(lag)) map.removeLayer(lag); }
    sett(kommune_lag, lag_paa.kommuner);
    sett(ingen_ringer, lag_paa.kommuner && z < 8);
    sett(fylke_lag, lag_paa.kommuner && z < 9);
    sett(butikk_lag, lag_paa.butikker && visButikker(z));
    sett(nav_lag, lag_paa.nav);
  }

  var sist_z = null;
  function oppdater() {
    var z = map.getZoom();
    dempOpasitet(z);
    if (kommune_lag) kommune_lag.setStyle(stilKommune);
    if (fylke_lag) fylke_lag.setStyle({ weight: z >= 8 ? 1.2 : 0.8 });
    if (sist_z === null || r_butikk(z) !== r_butikk(sist_z)) butikk_markers.forEach(function (m) { m.setRadius(r_butikk(z)); });
    nav_markers.forEach(function (m) { m.setStyle(stilNav(m.nkData, z)); });
    sist_z = z;
    visLag();
  }
  map.on("zoomend", oppdater);

  function hent(fil) {
    return fetch(sti + fil).then(function (r) { if (!r.ok) throw new Error(r.status + " " + fil); return r.json(); });
  }

  Promise.all([hent("kommune_stat.json"), hent("kommuner.geojson"), hent("fylker.geojson"), hent("butikker.json"), hent("navpunkter.json")])
    .then(function (res) {
      var stat = res[0], kommuner = res[1], fylker = res[2], navpkt = res[4];
      // butikker.json er kompakt: {felt: [...], rader: [[...], ...]}
      var butikker = res[3].rader.map(function (r) {
        var o = {}; res[3].felt.forEach(function (f, i) { o[f] = r[i]; }); return o;
      });
      kommuner_gj = kommuner;
      stat.forEach(function (s) { kommune_stat[s.knr] = s; });
      var z = map.getZoom();

      // Kommuner (canvas)
      kommune_lag = L.geoJSON(kommuner, {
        pane: "kommuner", renderer: canvas, style: stilKommune,
        onEachFeature: function (f, lag) {
          kommune_features[f.properties.knr] = lag;
          lag.bindPopup(function () { return popupKommune(f.properties); }, { maxWidth: 300, closeButton: false });
          lag.on("mouseover", function () { lag.setStyle({ weight: 2.5, color: "#111" }); });
          lag.on("mouseout",  function () { kommune_lag.resetStyle(lag); });
        }
      });
      // Ringer rundt de 37 uten Nav, synlige i Norge-visning der små kommuner forsvinner
      ingen_ringer = L.layerGroup();
      kommuner.features.forEach(function (f) {
        if ((kommune_stat[f.properties.knr] || {}).status !== "ingen") return;
        var c = kommune_features[f.properties.knr].getBounds().getCenter();
        ingen_ringer.addLayer(L.circleMarker(c, { pane: "nav", radius: 5, color: farge_status_kant.ingen, weight: 1.5, fill: false, interactive: false }));
      });
      fylke_lag = L.geoJSON(fylker, { pane: "fylker", style: { color: farge_fylke, weight: 0.8, fill: false, interactive: false } });

      // Butikker (samme canvas)
      butikk_lag = L.layerGroup();
      butikker.forEach(function (d) {
        var m = L.circleMarker([d.lat, d.lon], {
          renderer: canvas, pane: "kommuner", radius: r_butikk(z), color: "#ffffff", weight: 0.6, fillColor: farge_butikk, fillOpacity: 0.9
        }).bindPopup(function () { return popupButikk(d); }, { maxWidth: 300, closeButton: false });
        butikk_markers.push(m); butikk_lag.addLayer(m);
      });

      // Nav-punkter (SVG øverst): fylt = kontor, hul = mottak utenfor kontoret
      nav_lag = L.layerGroup();
      navpkt.forEach(function (d) {
        var m = L.circleMarker([d.lat, d.lon], stilNav(d, z));
        m.nkData = d;
        m.bindTooltip(esc(d.kontor_navn), { direction: "top", offset: [0, -4], opacity: 0.95 })
         .bindPopup(function () { return popupNav(d); }, { maxWidth: 300, closeButton: false });
        nav_markers.push(m); nav_lag.addLayer(m);
      });

      // Søk etter kommune, «Navn (Fylke)» skiller Herøy og Våler
      var valg = kommuner.features.map(function (f) { return kommuneLabel(f.properties); }).sort();
      datalist.innerHTML = valg.map(function (n) { return '<option value="' + esc(n) + '">'; }).join("");
      sok_input.addEventListener("change", function () {
        var q = sok_input.value.trim().toLowerCase();
        if (!q) { sok_input.setCustomValidity(""); return; }
        var f = kommuner.features.find(function (f) { return kommuneLabel(f.properties).toLowerCase() === q; }) ||
                kommuner.features.find(function (f) { return f.properties.kommune.toLowerCase() === q; }) ||
                kommuner.features.find(function (f) { return f.properties.kommune.toLowerCase().indexOf(q) >= 0; });
        if (!f) { sok_input.setCustomValidity(t("sok_ingen")); sok_input.reportValidity(); return; }
        sok_input.setCustomValidity(""); sok_input.value = kommuneLabel(f.properties);
        settAktiv(null); flyr = true;
        var lag = kommune_features[f.properties.knr];
        if (!map.hasLayer(kommune_lag)) { lag_paa.kommuner = true; tegnLegend(); }
        map.flyToBounds(lag.getBounds(), { padding: [30, 30], maxZoom: 11, duration: 1.0 });
        map.once("moveend", function () { lag.openPopup(); });
        sok_input.blur();
      });
      sok_input.addEventListener("input", function () { sok_input.setCustomValidity(""); });

      tegnLegend(); oppdater();
    })
    .catch(function (e) {
      el.insertAdjacentHTML("beforeend", '<div class="nk-feil" role="alert">' + t("feil") + "</div>");
      console.error(e);
    });

  // Språk -----------------------------------------------------------------

  var kilde_vist = null;
  function settSprak(l) {
    if (!T[l]) return;
    lang = l;
    el.setAttribute("aria-label", t("aria"));
    if (standalone) document.documentElement.lang = lang === "no" ? "nb" : "en";
    by_knapper.forEach(function (btn) { if (btn.getAttribute("data-by") === "norge") btn.textContent = t("norge"); });
    if (by_select) by_select.options[0].textContent = t("norge");
    var full = el.querySelector('a[data-rolle="full"]');
    if (full) { full.title = t("full"); full.setAttribute("aria-label", t("full")); }
    if (sok_input) { sok_input.placeholder = t("sok"); sok_input.setAttribute("aria-label", t("sok")); }
    if (!smal) {
      if (kilde_vist) map.attributionControl.removeAttribution(kilde_vist);
      kilde_vist = t("kilde"); map.attributionControl.addAttribution(kilde_vist);
    }
    if (legend_div) tegnLegend();
    tegnTittel();
    map.closePopup();
  }
  settSprak(lang);
  if (!standalone) {
    if (typeof window.setLang === "function") {
      var orig = window.setLang;
      window.setLang = function (l) { orig(l); settSprak(l); };
    } else {
      console.warn("kart.js: fant ikke setLang(), kartet blir på engelsk");
    }
  }
})();
