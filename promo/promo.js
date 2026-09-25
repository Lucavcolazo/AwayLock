// Promo de 15 s. renderAt(t) dibuja el instante t (en segundos) de forma
// determinística: el mismo t siempre da el mismo cuadro. Sin CSS animations.
(() => {
  "use strict";

  const DURATION = 15;
  const $ = (id) => document.getElementById(id);
  const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
  const lerp = (a, b, x) => a + (b - a) * x;
  const k = (t, a, b) => clamp((t - a) / (b - a), 0, 1);
  const out = (x) => 1 - Math.pow(1 - x, 3); // ease-out
  const outStrong = (x) => 1 - Math.pow(1 - x, 5);
  const inOut = (x) => (x < 0.5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2);
  const mix = (c1, c2, x) => {
    const p = (c) => [1, 3, 5].map((i) => parseInt(c.slice(i, i + 2), 16));
    const [a, b] = [p(c1), p(c2)];
    return `rgb(${a.map((v, i) => Math.round(lerp(v, b[i], x))).join(",")})`;
  };
  const dbm = (v) => `−${Math.abs(Math.round(v))} dBm`;
  const meters = (d) => `${d.toFixed(1).replace(".", ",")} m`;

  // Entrada con desenfoque, como en la landing.
  function enter(el, x, dy = 30, blur = 14) {
    el.style.opacity = x;
    el.style.filter = x >= 1 ? "none" : `blur(${(1 - x) * blur}px)`;
    el.style.transform = `translateY(${(1 - x) * dy}px)`;
  }

  // Visibilidad de una escena en [a, b] con fundido de entrada y salida.
  function scene(el, t, a, b, fin = 0.4, fout = 0.35) {
    const vin = a <= 0 ? 1 : out(k(t, a, a + fin));
    const vout = b >= DURATION ? 0 : inOut(k(t, b - fout, b));
    const v = Math.min(vin, 1 - vout);
    el.style.opacity = v;
    el.style.visibility = v <= 0.001 ? "hidden" : "visible";
    el.style.filter = v >= 1 ? "none" : `blur(${(1 - v) * 10}px)`;
    el.style.transform = `translateY(${vout * -24 + (1 - vin) * 24}px)`;
    return v;
  }

  // Señal: −48 dBm a medio metro, cae con la distancia.
  const rssiAtDistance = (d) => -48 - 35 * Math.log10(Math.max(d, 0.5) / 0.5);
  const noise = (t) => Math.sin(t * 9.1) * 1.1 + Math.sin(t * 23.7) * 0.6;
  const LOCK = -75, NEAR = -60;

  // Escena de la Mac: distancia en el tiempo.
  const T_OUT0 = 4.9, T_OUT1 = 6.1, T_LOCK = 7.15, T_BACK0 = 8.25, T_BACK1 = 9.05;
  const distanceAt = (t) => {
    if (t < T_OUT0) return 0.5;
    if (t < T_OUT1) return lerp(0.5, 6.5, inOut(k(t, T_OUT0, T_OUT1)));
    if (t < T_BACK0) return 6.5;
    if (t < T_BACK1) return lerp(6.5, 0.5, inOut(k(t, T_BACK0, T_BACK1)));
    return 0.5;
  };
  const rssiAt = (t) => rssiAtDistance(distanceAt(t)) + noise(t);
  let T_CROSS = T_OUT0;
  for (let t = T_OUT0; t < T_OUT1; t += 0.005) {
    if (rssiAtDistance(distanceAt(t)) < LOCK) { T_CROSS = t; break; }
  }
  let T_WAKE = T_BACK1;
  for (let t = T_BACK0; t < T_BACK1; t += 0.005) {
    if (rssiAtDistance(distanceAt(t)) >= NEAR) { T_WAKE = t + 0.05; break; }
  }

  // Gráfico de señal de la escena de la Mac.
  const TW = 700, TH = 150, TMIN = -95, TMAX = -40;
  const ty = (v) => lerp(TH - 12, 12, (clamp(v, TMIN, TMAX) - TMIN) / (TMAX - TMIN));
  for (const [id, v] of [["thG", NEAR], ["thR", LOCK]]) {
    $(id).setAttribute("y1", ty(v));
    $(id).setAttribute("y2", ty(v));
  }
  const TRACE_A = 4.6, TRACE_B = 10.2;

  const el = {};
  for (const id of ["stage", "glow", "brand", "s1", "s2", "s3", "s5", "s6", "w1", "w2", "w3",
    "dot", "shackle", "pulse", "readState", "readValue", "capLeave", "capLock", "capBack",
    "roD", "roS", "traceLine", "traceHead", "panel", "badge", "icNear", "icWalk", "pTitle",
    "pDetail", "knob", "lock", "toast", "l1", "l2", "ch0", "ch1", "ch2", "ch3", "mark",
    "cr0", "cr1", "cr2", "logoText", "caret", "tag", "url"]) el[id] = $(id);
  const meterWidth = () => el.knob.parentElement.clientWidth;

  function renderAt(t) {
    t = clamp(t, 0, DURATION);

    // Fondo: el brillo se desplaza despacio para que nunca quede quieto.
    el.glow.style.transform = `translate(${Math.sin(t * 0.35) * 14 + 12}%, ${Math.cos(t * 0.28) * 8 - 4}%)`;
    const brandV = 1 - inOut(k(t, 12.3, 12.7));
    el.brand.style.opacity = brandV * out(k(t, 0, 0.5));

    // 1. Palabra por palabra
    scene(el.s1, t, 0, 2.35);
    const words = [el.w1, el.w2, el.w3];
    const starts = [0.15, 0.62, 1.09];
    words.forEach((w, i) => {
      enter(w, outStrong(k(t, starts[i], starts[i] + 0.55)), 34, 16);
      const next = starts[i + 1];
      w.style.color = next ? mix("#f4f2ff", "#736c96", out(k(t, next, next + 0.45))) : "#f4f2ff";
    });

    // 2. Radar
    scene(el.s2, t, 2.25, 4.75);
    const r = t < 2.85 ? 46 : lerp(46, 168, inOut(k(t, 2.85, 3.85)));
    const a = -0.95 + (t - 2.25) * 0.22;
    el.dot.setAttribute("cx", 200 + r * Math.cos(a));
    el.dot.setAttribute("cy", 200 + r * Math.sin(a));
    const lockX = outStrong(k(t, 3.95, 4.25));
    el.shackle.setAttribute("transform",
      `translate(${lerp(9, 0, lockX)} ${lerp(-3, 6, lockX)}) rotate(${lerp(18, 0, lockX)} 15 -6)`);
    const pulse = ((t - 2.25) % 1.6) / 1.6;
    el.pulse.setAttribute("transform", `translate(200 200) scale(${1 + pulse * 3.6}) translate(-200 -200)`);
    el.pulse.style.opacity = (1 - pulse) * 0.7;
    const radarState = t >= 3.95 ? ["Bloqueada", "#9d91ff"] : t >= 3.0 ? ["Te estás alejando", "#ffa24c"] : ["Cerca", "#4ade80"];
    el.readState.textContent = radarState[0];
    el.readState.style.color = radarState[1];
    el.readValue.textContent = dbm(-50 - ((r - 46) / 122) * 36 + noise(t) * 0.8);

    // 3 y 4. La Mac
    scene(el.s3, t, 4.65, 10.3);
    const caps = [[el.capLeave, 4.75, T_LOCK], [el.capLock, T_LOCK, T_BACK0], [el.capBack, T_BACK0, 10.4]];
    for (const [c, s, e] of caps) {
      const v = Math.min(out(k(t, s, s + 0.35)), 1 - k(t, e - 0.2, e));
      c.style.opacity = v;
      c.style.filter = v >= 1 ? "none" : `blur(${(1 - v) * 10}px)`;
      c.style.transform = `translateY(${(1 - v) * 20}px)`;
    }
    const d = distanceAt(t);
    const v = rssiAt(t);
    el.roD.textContent = meters(d);
    el.roS.textContent = dbm(v);

    const leaving = t >= T_CROSS && t < T_LOCK;
    el.badge.style.background = leaving ? "#ffa24c" : "#4ade80";
    el.icNear.style.opacity = leaving ? 0 : 1;
    el.icWalk.style.opacity = leaving ? 1 : 0;
    el.knob.style.boxShadow = `inset 0 0 0 4px ${leaving ? "#ffa24c" : "#4ade80"}, 0 2px 5px rgba(0,0,0,.4)`;
    el.pTitle.textContent = leaving ? "Te estás alejando" : "Cerca";
    const left = Math.max(1, Math.ceil(3 * (1 - (t - T_CROSS) / (T_LOCK - T_CROSS))));
    el.pDetail.textContent = leaving ? `Bloqueo en ${left} s · ${dbm(v)}` : `Tu iPhone · ${dbm(v)}`;
    el.knob.style.transform = `translateX(${clamp((v + 100) / 70, 0, 1) * meterWidth()}px)`;

    const lockV = Math.min(out(k(t, T_LOCK, T_LOCK + 0.4)), 1 - out(k(t, T_WAKE, T_WAKE + 0.35)));
    el.lock.style.opacity = lockV;
    const toastV = outStrong(k(t, T_WAKE + 0.2, T_WAKE + 0.65));
    el.toast.style.opacity = toastV;
    el.toast.style.transform = `translateY(${(1 - toastV) * -24}px) scale(${lerp(0.96, 1, toastV)})`;
    // El panel se esconde bajo la pantalla de bloqueo y cuando entra la notificación.
    el.panel.style.opacity = 1 - Math.max(out(k(t, T_LOCK, T_LOCK + 0.3)), toastV);
    el.panel.style.transform = `translateY(${toastV * -10}px)`;

    const traceEnd = clamp(t, TRACE_A, TRACE_B);
    const pts = [];
    for (let s = TRACE_A; s <= traceEnd + 1e-6; s += 0.04) {
      pts.push(`${(((s - TRACE_A) / (TRACE_B - TRACE_A)) * TW).toFixed(1)},${ty(rssiAt(s)).toFixed(1)}`);
    }
    el.traceLine.setAttribute("points", pts.join(" "));
    const hx = ((traceEnd - TRACE_A) / (TRACE_B - TRACE_A)) * TW;
    el.traceHead.setAttribute("cx", hx);
    el.traceHead.setAttribute("cy", ty(rssiAt(traceEnd)));

    // 5. Nunca toca tu contraseña
    scene(el.s5, t, 10.25, 12.75);
    enter(el.l1, outStrong(k(t, 10.35, 10.9)), 34, 16);
    enter(el.l2, outStrong(k(t, 10.7, 11.25)), 34, 16);
    [el.ch0, el.ch1, el.ch2, el.ch3].forEach((c, i) => {
      const x = outStrong(k(t, 11.2 + i * 0.14, 11.65 + i * 0.14));
      c.style.opacity = x;
      c.style.transform = `translateY(${(1 - x) * 18}px) scale(${lerp(0.92, 1, x)})`;
    });

    // 6. Cierre
    scene(el.s6, t, 12.6, DURATION);
    const markX = outStrong(k(t, 12.7, 13.2));
    el.mark.style.opacity = markX;
    el.mark.style.transform = `scale(${lerp(0.86, 1, markX)})`;
    [el.cr0, el.cr1, el.cr2].forEach((ring, i) => {
      const start = 12.95 + i * 0.5;
      const p = t < start ? -1 : ((t - start) % 1.5) / 1.5;
      ring.style.opacity = p < 0 ? 0 : (1 - p) * 0.8;
      ring.style.transform = `scale(${lerp(0.95, 2.9, out(Math.max(p, 0)))})`;
    });
    const word = "AwayLock";
    const n = Math.round(k(t, 13.0, 13.6) * word.length);
    el.logoText.textContent = word.slice(0, n);
    el.caret.style.opacity = t < 12.95 ? 0 : t < 13.9 ? (Math.floor(t * 4) % 2 === 0 || t < 13.6 ? 1 : 0) : 0;
    const tagX = outStrong(k(t, 13.75, 14.2));
    enter(el.tag, tagX, 24, 10);
    const urlX = outStrong(k(t, 14.0, 14.45));
    el.url.style.opacity = urlX;
    el.url.style.transform = `translateY(${(1 - urlX) * 20}px) scale(${lerp(0.95, 1, urlX)})`;
  }

  window.renderAt = renderAt;
  window.PROMO_DURATION = DURATION;

  // En el navegador: escala el escenario a la ventana y reproduce en loop.
  const params = new URLSearchParams(location.search);
  function fit() {
    if (params.has("render")) return;
    const s = Math.min(innerWidth / 1920, innerHeight / 1080);
    el.stage.style.transform = `scale(${s})`;
  }
  fit();
  addEventListener("resize", fit);

  if (params.has("render")) {
    renderAt(0);
  } else if (params.has("t")) {
    renderAt(parseFloat(params.get("t")));
  } else {
    const start = performance.now();
    const frame = (now) => {
      renderAt(((now - start) / 1000) % DURATION);
      requestAnimationFrame(frame);
    };
    document.fonts.ready.then(() => requestAnimationFrame(frame));
  }
})();
