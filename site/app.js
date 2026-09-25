// AwayLock · landing
// Sin dependencias. Tres piezas: el radar de la portada, la caminata guiada por el
// scroll y el cambio de idioma. Todo el contenido está en el HTML; si este archivo
// no carga, la página se lee igual.

(() => {
  "use strict";

  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];
  const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
  const lerp = (a, b, t) => a + (b - a) * t;
  const easeInOut = (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);

  const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)").matches;
  document.documentElement.classList.add("js");

  // ---------------------------------------------------------------- Idioma

  const EN = {
    skip: "Skip to content",
    navHow: "How it works",
    navPrivacy: "Privacy",
    navInstall: "Install",
    h1a: "You get up.",
    h1b: "You walk away.",
    h1c: "Your Mac locks.",
    lede: "AwayLock reads your iPhone's Bluetooth signal from the menu bar. When you walk away, it locks your Mac. When you come back, your Apple Watch unlocks it.",
    download: "Download for macOS",
    seeCode: "View the code",
    mobileNote: "<strong>AwayLock is a Mac app.</strong> Open this page on your computer to download it.",
    copyLink: "Copy the link",
    meta: "v0.1.0 · free · open source (MIT) · macOS 13+",
    legendNear: "green ring: you're back",
    legendLock: "red ring: locks",
    walkTitle: "This is what happens when you leave.",
    capNearT: "You're at your desk.",
    capNearP: "Your iPhone's signal comes in strong. AwayLock does nothing.",
    capLeavingT: "You walk away.",
    capLeavingP: "The signal drops below the red threshold. It waits a few seconds, in case you just turned around.",
    capLockedT: "Locked.",
    capLockedP: "Nobody sees your screen. And it won't lock again until it sees you close by.",
    capBackT: "You come back.",
    capBackP: "The signal rises above the green threshold, the screen wakes and your Apple Watch unlocks it.",
    roDistance: "distance",
    roSignal: "signal",
    stepsAria: "Demo steps",
    stepNear: "Near",
    stepLeaving: "Leaving",
    stepLocked: "Locked",
    stepBack: "Back",
    mbFile: "File",
    mbEdit: "Edit",
    mbView: "View",
    lsHint: "Enter password",
    toastT: "Unlocked",
    toastP: "with your Apple Watch",
    synthetic: "Demo with illustrative values",
    pwTitle: "It never touches your password.",
    pwBody: "Other apps like this unlock your Mac by typing your password for you: they store it in the Keychain and type it using Accessibility access. AwayLock only locks. Unlocking is still up to macOS: your Apple Watch, Touch ID or your password, as always.",
    not1: "Doesn't store your password",
    not2: "Doesn't ask for Accessibility access",
    not3: "Doesn't fake keystrokes",
    loginName: "Your Mac",
    loginPh: "Enter password",
    loginWatch: "Unlocking with Apple Watch…",
    loginNote: "This screen belongs to macOS. AwayLock doesn't type here.",
    logicTitle: "Built not to get in your way.",
    logicBody: "An app that locks you out while you're sitting at your desk is worse than no app. So the logic has brakes. Here, someone sitting with a weak signal: it locks once and doesn't get stuck in a loop.",
    tagLock: "locks once",
    tagCalm: "weak signal: no more locks",
    tagArm: "only now does it re-arm",
    f1t: "4 s median",
    f1d: "A single signal spike doesn't count: it neither marks you present nor locks you out.",
    f2t: "Two thresholds",
    f2d: "It locks below −75 dBm and considers you back above −60 dBm. The gap between them prevents flip-flopping.",
    f3t: "5 s delay",
    f3d: "If you turned around for a second, nothing happens.",
    f4t: "20 s grace",
    f4d: "Right after you unlock, it won't lock you out.",
    f5t: "Fresh start on wake",
    f5d: "Open the lid and it won't lock you based on readings from before sleep.",
    readCode: "Read PresenceEngine.swift",
    tests: "11 tests, including the loop one",
    privacyTitle: "Everything stays on your Mac.",
    privacyBody: "No internet, no accounts, no data leaving your computer. All it does is read your iPhone's Bluetooth signal.",
    chip1: "No internet connection",
    chip2: "No accounts or sign-up",
    chip3: "No stored passwords",
    chip4: "Open source · MIT",
    chip5: "Native Swift",
    chip6: "Apple silicon and Intel",
    chip7: "Bluetooth Low Energy",
    cpu: "With the panel closed it uses <strong>~0%</strong> CPU.",
    cpuNote: "Measured on the author's Mac.",
    installTitle: "Install it in a minute.",
    st1: "Download the <code>.zip</code> from the <a class=\"link\" href=\"https://github.com/Lucavcolazo/AwayLock/releases/latest\">latest release</a> and unzip it.",
    st2: "Move <strong>AwayLock.app</strong> to <strong>Applications</strong>.",
    st3: "Open it and allow <strong>Bluetooth</strong> access.",
    gkTitle: "The first time, macOS will stop it.",
    gkBody: "AwayLock isn't signed with a paid Apple Developer account, so macOS warns that it can't verify it. That's expected and only happens once:",
    gk1: "Try to open it and dismiss the warning. Don't move it to the Trash.",
    gk2: "Go to <strong>System Settings → Privacy &amp; Security</strong>.",
    gk3: "Scroll to the message about AwayLock and click <strong>Open Anyway</strong>.",
    gkTerminal: "Or, from the Terminal:",
    copy: "Copy",
    reqTitle: "What you need",
    req1: "A Mac with Bluetooth, Apple silicon or Intel.",
    req2: "macOS 13 or later. So far it's been tested on macOS 26.",
    req3: "An iPhone on the same Apple Account as the Mac.",
    req4: "Optional: an Apple Watch with Mac unlocking turned on.",
    buildTitle: "Rather build it yourself?",
    faqTitle: "FAQ",
    q1: "What if I leave my iPhone on the desk?",
    a1: "Then your Mac won't lock, because as far as AwayLock knows you're still there. It works when you carry your iPhone with you.",
    q2: "Does it drain the battery?",
    a2: "It uses Bluetooth Low Energy, the same kind of connection your iPhone already keeps with your watch or AirPods. For the absolute minimum, turn on \"Solo escuchar (sin conectarse)\", its listen-only mode.",
    q3: "My iPhone doesn't show up in the list",
    a3: "The list only shows devices whose name includes \"iPhone\". If you renamed yours, check \"Mostrar todos los dispositivos\" (show all devices). Your iPhone also needs to be on the same Apple Account as your Mac.",
    q4: "How is it different from BLEUnlock?",
    a4: "<a class=\"link\" href=\"https://github.com/ts1/BLEUnlock\">BLEUnlock</a> is a great project that also unlocks your Mac by typing your password. AwayLock was written from scratch with a different approach: it only locks and leaves unlocking to your Apple Watch, so it never touches your password.",
    q5: "Something's wrong. Where do I report it?",
    a5: "In the <a class=\"link\" href=\"https://github.com/Lucavcolazo/AwayLock/issues/new/choose\">repo's issues</a>. The form asks for your Mac model, macOS version and the signal you see while sitting, which is what's needed to figure out what's going on.",
    closeTitle: "Get up. Don't worry.",
    closeBody: "AwayLock is free and open source.",
    star: "Star it on GitHub",
    madeBy: "Made by",
  };

  const STR = {
    es: {
      near: "Cerca",
      leaving: "Te estás alejando",
      locked: "Bloqueada",
      away: "Lejos",
      device: "Tu iPhone",
      lockIn: (s) => `Bloqueo en ${s} s`,
      toBack: (v) => `para volver: ${v} o más`,
      copied: "Copiado",
      linkCopied: "Link copiado",
      langBtn: "EN",
      langAria: "Switch to English",
      title: "AwayLock · Tu Mac se bloquea sola cuando te alejás",
      locale: "es-AR",
    },
    en: {
      near: "Near",
      leaving: "Walking away",
      locked: "Locked",
      away: "Away",
      device: "Your iPhone",
      lockIn: (s) => `Locking in ${s} s`,
      toBack: (v) => `to come back: ${v} or more`,
      copied: "Copied",
      linkCopied: "Link copied",
      langBtn: "ES",
      langAria: "Cambiar a español",
      title: "AwayLock · Your Mac locks itself when you walk away",
      locale: "en-US",
    },
  };

  let lang = "es";
  const t = () => STR[lang];

  const i18nNodes = $$("[data-i18n], [data-i18n-html], [data-i18n-alt], [data-i18n-aria]");
  const original = new Map();
  for (const el of i18nNodes) {
    original.set(el, {
      text: el.dataset.i18n ? el.textContent : null,
      html: el.dataset.i18nHtml ? el.innerHTML : null,
      alt: el.dataset.i18nAlt ? el.getAttribute("alt") : null,
      aria: el.dataset.i18nAria ? el.getAttribute("aria-label") : null,
    });
  }

  function applyLang(next) {
    lang = next;
    document.documentElement.lang = next;
    document.title = t().title;
    for (const el of i18nNodes) {
      const o = original.get(el);
      const d = el.dataset;
      if (d.i18n) el.textContent = next === "en" && EN[d.i18n] ? EN[d.i18n] : o.text;
      if (d.i18nHtml) el.innerHTML = next === "en" && EN[d.i18nHtml] ? EN[d.i18nHtml] : o.html;
      if (d.i18nAlt) el.setAttribute("alt", next === "en" && EN[d.i18nAlt] ? EN[d.i18nAlt] : o.alt);
      if (d.i18nAria) el.setAttribute("aria-label", next === "en" && EN[d.i18nAria] ? EN[d.i18nAria] : o.aria);
    }
    for (const b of $$("[data-lang-toggle]")) {
      b.textContent = t().langBtn;
      b.setAttribute("aria-label", t().langAria);
    }
    updateClock();
    renderWalk(lastWalkP, true);
    renderRadar(true);
    try { localStorage.setItem("awaylock-lang", next); } catch {}
  }

  for (const b of $$("[data-lang-toggle]")) {
    b.addEventListener("click", () => applyLang(lang === "es" ? "en" : "es"));
  }

  const fmtNum = (n, digits = 1) =>
    n.toLocaleString(t().locale, { minimumFractionDigits: digits, maximumFractionDigits: digits });
  const fmtDbm = (v) => `−${Math.abs(Math.round(v))} dBm`;

  function updateClock() {
    const now = new Date();
    // Como el reloj de macOS: 24 h en español, 12 h en inglés.
    const time = now.toLocaleTimeString(t().locale, { hour: "numeric", minute: "2-digit", hour12: lang === "en" });
    const date = now.toLocaleDateString(t().locale, { weekday: "long", day: "numeric", month: "long" });
    for (const el of $$("[data-clock]")) el.textContent = time.replace(/\s?[AP]M$/i, "");
    const d = $("[data-date]");
    if (d) d.textContent = date;
  }

  // ---------------------------------------------------------------- Modelo de señal

  // Pérdida de señal aproximada: −48 dBm a medio metro, cae con la distancia.
  const rssiAtDistance = (d) => -48 - 35 * Math.log10(Math.max(d, 0.5) / 0.5);
  const LOCK = -75;
  const NEAR = -60;
  const rssiToMeter = (v) => clamp((v + 100) / 70, 0, 1); // igual que el medidor de la app

  // ---------------------------------------------------------------- Radar de la portada

  const radar = $(".radar");
  const dot = $(".phone-dot");
  const radarState = $("[data-radar-state]");
  const radarValue = $("[data-radar-value]");
  const R_IN = 46, R_OUT = 168, R_NEAR = 78, R_LOCK = 128, PERIOD = 10;
  const radarModel = { r: R_IN, locked: false, outsideSince: null, state: "near", rssi: -50 };

  function radarRadius(time) {
    const x = time % PERIOD;
    if (x < 2.4) return R_IN;
    if (x < 4.4) return lerp(R_IN, R_OUT, easeInOut((x - 2.4) / 2));
    if (x < 6.6) return R_OUT;
    if (x < 8.6) return lerp(R_OUT, R_IN, easeInOut((x - 6.6) / 2));
    return R_IN;
  }

  function stepRadar(time) {
    const m = radarModel;
    m.r = radarRadius(time);
    if (m.r > R_LOCK) {
      m.outsideSince ??= time;
      if (time - m.outsideSince > 0.7) m.locked = true;
    } else {
      m.outsideSince = null;
    }
    if (m.r < R_NEAR) m.locked = false;
    m.state = m.locked ? "locked" : m.r > R_NEAR ? "leaving" : "near";
    const noise = Math.sin(time * 3.1) * 1.2 + Math.sin(time * 7.7) * 0.6;
    m.rssi = -50 - ((m.r - R_IN) / (R_OUT - R_IN)) * 36 + noise;
    const a = -0.85 + time * 0.22;
    dot.setAttribute("transform", `translate(${200 + m.r * Math.cos(a)} ${200 + m.r * Math.sin(a)})`);
  }

  let radarLabel = "";
  function renderRadar(force = false) {
    const m = radarModel;
    radar.classList.toggle("is-locked", m.locked);
    radar.dataset.state = m.state;
    const label = t()[m.state];
    if (force || label !== radarLabel) {
      radarState.textContent = label;
      radarLabel = label;
    }
    radarValue.textContent = fmtDbm(m.rssi);
  }

  let radarRunning = false;
  let radarStart = performance.now();
  let lastValueUpdate = 0;
  function radarFrame(now) {
    if (!radarRunning) return;
    const time = (now - radarStart) / 1000;
    stepRadar(time);
    // El número se actualiza unas veces por segundo, como el panel real.
    if (now - lastValueUpdate > 280) {
      renderRadar();
      lastValueUpdate = now;
    } else {
      radar.classList.toggle("is-locked", radarModel.locked);
      radar.dataset.state = radarModel.state;
    }
    requestAnimationFrame(radarFrame);
  }

  function setRadarRunning(on) {
    if (reduceMotion || on === radarRunning) return;
    radarRunning = on;
    if (on) {
      radarStart = performance.now() - (radarStart ? 0 : 0);
      requestAnimationFrame(radarFrame);
    }
  }

  stepRadar(0);
  renderRadar(true);
  if (!reduceMotion) {
    new IntersectionObserver(([e]) => setRadarRunning(e.isIntersecting && !document.hidden)).observe(radar);
    document.addEventListener("visibilitychange", () => {
      const r = radar.getBoundingClientRect();
      setRadarRunning(!document.hidden && r.bottom > 0 && r.top < innerHeight);
    });
  }

  // ---------------------------------------------------------------- La caminata

  const track = $("[data-walk-track]");
  const mac = $("[data-mac]");
  const panel = $("[data-panel]");
  const panelTitle = $("[data-panel-title]");
  const panelDetail = $("[data-panel-detail]");
  const knob = $("[data-knob]");
  const meter = $(".meter");
  const caps = $$("[data-captions] .cap");
  const roDistance = $("[data-ro-distance]");
  const roRssi = $("[data-ro-rssi]");
  const tracePoly = $("[data-trace]");
  const traceHead = $("[data-trace-head]");
  const rulerPhone = $("[data-ruler-phone]");
  const rulerLine = $(".ruler-line");
  const stepButtons = $$("[data-step]");

  // Línea de tiempo de la escena, en fracción del scroll.
  const OUT0 = 0.08, OUT1 = 0.34, BACK0 = 0.6, BACK1 = 0.84, FAR = 6.5;
  const LOCK_DELAY_P = 0.1; // "5 segundos" de demora
  const distanceAt = (p) => {
    if (p < OUT0) return 0.5;
    if (p < OUT1) return lerp(0.5, FAR, easeInOut((p - OUT0) / (OUT1 - OUT0)));
    if (p < BACK0) return FAR;
    if (p < BACK1) return lerp(FAR, 0.5, easeInOut((p - BACK0) / (BACK1 - BACK0)));
    return 0.5;
  };
  const noiseAt = (p) => Math.sin(p * 97) * 1.1 + Math.sin(p * 263) * 0.7;
  const rssiAt = (p) => rssiAtDistance(distanceAt(p)) + noiseAt(p);

  // Momentos clave, calculados sobre la curva sin ruido.
  let pCross = OUT0, pReturn = BACK0;
  for (let i = 0; i <= 2000; i++) {
    const p = i / 2000;
    const v = rssiAtDistance(distanceAt(p));
    if (p < BACK0 && v < LOCK && pCross === OUT0) pCross = p;
    if (p > BACK0 && v >= NEAR) { pReturn = p; break; }
  }
  const pLock = pCross + LOCK_DELAY_P;
  const pWake = pReturn + 0.015;
  const TOAST_P = 0.1;

  // Los botones de pasos saltan al medio de cada etapa.
  const stepTargets = [0.03, (pCross + pLock) / 2, (pLock + pWake) / 2, 0.95];

  const phaseAt = (p) => (p < pCross ? "near" : p < pLock ? "leaving" : p < pWake ? "locked" : "back");

  // Coordenadas del gráfico chico.
  const TW = 600, TH = 180, TMIN = -95, TMAX = -40;
  const ty = (v) => lerp(TH - 12, 12, (clamp(v, TMIN, TMAX) - TMIN) / (TMAX - TMIN));
  for (const [sel, v, label] of [["[data-th-green]", NEAR, "[data-tl-green]"], ["[data-th-red]", LOCK, "[data-tl-red]"]]) {
    const line = $(sel);
    line.setAttribute("y1", ty(v));
    line.setAttribute("y2", ty(v));
    $(label).style.top = `${(ty(v) / TH) * 100}%`;
  }
  const TRACE_N = 180;
  const traceSamples = Array.from({ length: TRACE_N + 1 }, (_, i) => {
    const p = i / TRACE_N;
    return [p * TW, ty(rssiAt(p))];
  });

  let lastWalkP = 0;
  let lastPhase = "";

  function renderWalk(p, force = false) {
    lastWalkP = p;
    const d = distanceAt(p);
    const v = rssiAt(p);
    const phase = phaseAt(p);

    roDistance.textContent = `${fmtNum(d)} m`;
    roRssi.textContent = fmtDbm(v);

    if (force || phase !== lastPhase) {
      caps.forEach((c) => c.classList.toggle("is-active", c.dataset.phase === phase));
      mac.classList.toggle("is-locked", phase === "locked");
      const idx = ["near", "leaving", "locked", "back"].indexOf(phase);
      stepButtons.forEach((b, i) => (i === idx ? b.setAttribute("aria-current", "step") : b.removeAttribute("aria-current")));
      lastPhase = phase;
    }

    const leaving = phase === "leaving";
    panel.dataset.state = leaving ? "leaving" : "near";
    panelTitle.textContent = leaving ? t().leaving : t().near;
    if (leaving) {
      const left = Math.max(1, Math.ceil(5 * (1 - (p - pCross) / LOCK_DELAY_P)));
      panelDetail.textContent = `${t().lockIn(left)} · ${fmtDbm(v)}`;
    } else {
      panelDetail.textContent = `${t().device} · ${fmtDbm(v)}`;
    }
    knob.style.transform = `translateX(${rssiToMeter(v) * meter.clientWidth}px)`;

    mac.classList.toggle("show-toast", p >= pWake && p < pWake + TOAST_P);

    const n = Math.max(1, Math.round(p * TRACE_N));
    const pts = traceSamples.slice(0, n + 1);
    tracePoly.setAttribute("points", pts.map(([x, y]) => `${x.toFixed(1)},${y.toFixed(1)}`).join(" "));
    const [hx, hy] = pts[pts.length - 1];
    traceHead.setAttribute("cx", hx);
    traceHead.setAttribute("cy", hy);

    rulerPhone.style.transform = `translateX(${(d / 8) * rulerLine.clientWidth}px)`;
  }

  function walkProgress() {
    const r = track.getBoundingClientRect();
    const total = r.height - innerHeight;
    return total > 0 ? clamp(-r.top / total, 0, 1) : 0;
  }

  let ticking = false;
  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(() => {
      ticking = false;
      renderWalk(walkProgress());
    });
  }

  if (reduceMotion) {
    // Sin scroll guiado: los botones muestran cada momento.
    renderWalk(0.04, true);
  } else {
    addEventListener("scroll", onScroll, { passive: true });
    addEventListener("resize", onScroll);
    renderWalk(walkProgress(), true);
  }

  stepButtons.forEach((b, i) => {
    b.addEventListener("click", () => {
      const p = stepTargets[i];
      if (reduceMotion) {
        renderWalk(p, true);
        return;
      }
      const top = track.getBoundingClientRect().top + scrollY;
      const total = track.offsetHeight - innerHeight;
      scrollTo({ top: top + p * total, behavior: "smooth" });
    });
  });

  // ---------------------------------------------------------------- Gráfico de la lógica

  const logicPath = $("[data-logic-path]");
  if (logicPath) {
    const LW = 1000, LH = 300, LMIN = -92, LMAX = -40, N = 100;
    const ly = (v) => lerp(LH - 22, 22, (clamp(v, LMIN, LMAX) - LMIN) / (LMAX - LMIN));
    const seated = (i) => {
      const w = Math.sin(i * 0.9) * 2.6 + Math.sin(i * 2.3) * 1.6;
      if (i < 18) return -50 + w * 0.6;
      if (i < 26) return lerp(-50, -79, easeInOut((i - 18) / 8)) + w * 0.4;
      if (i < 80) return -78.5 + w;
      if (i < 90) return lerp(-78.5, -54, easeInOut((i - 80) / 10)) + w * 0.4;
      return -53 + w * 0.6;
    };
    const pts = Array.from({ length: N }, (_, i) => [(i / (N - 1)) * LW, ly(seated(i))]);
    logicPath.setAttribute("d", pts.map(([x, y], i) => `${i ? "L" : "M"}${x.toFixed(1)} ${y.toFixed(1)}`).join(" "));
    for (const [sel, v] of [["[data-lth-green]", NEAR], ["[data-lth-red]", LOCK]]) {
      $(sel).setAttribute("y1", ly(v));
      $(sel).setAttribute("y2", ly(v));
    }
    const lockI = 29;
    const mark = $("[data-lock-mark]");
    mark.setAttribute("x1", pts[lockI][0]);
    mark.setAttribute("x2", pts[lockI][0]);
    const place = (el, i, dy) => {
      el.style.left = `${(i / (N - 1)) * 100}%`;
      el.style.top = `${(ly(seated(i)) / LH) * 100 + dy}%`;
    };
    place($("[data-tag-lock]"), lockI + 1, -34);
    place($("[data-tag-calm]"), 52, 12);
    const arm = $("[data-tag-arm]");
    arm.style.left = "60%";
    arm.style.top = `${(ly(NEAR) / LH) * 100 - 17}%`;
  }

  // ---------------------------------------------------------------- Revelados

  $$("[data-chips] li").forEach((li, i) => (li.style.transitionDelay = `${i * 60}ms`));
  const revealTargets = $$(".reveal, [data-chips], .logic-chart");
  if (reduceMotion || !("IntersectionObserver" in window)) {
    revealTargets.forEach((el) => el.classList.add("is-in"));
  } else {
    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (!e.isIntersecting) continue;
          e.target.classList.add("is-in");
          io.unobserve(e.target);
        }
      },
      { rootMargin: "0px 0px -12% 0px" }
    );
    revealTargets.forEach((el) => io.observe(el));
  }

  // ---------------------------------------------------------------- Copiar

  const copyToast = $("[data-copy-toast]");
  let toastTimer;
  function showToast(msg) {
    copyToast.textContent = msg;
    copyToast.classList.add("is-on");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => copyToast.classList.remove("is-on"), 1600);
  }
  async function copy(text) {
    try {
      await navigator.clipboard.writeText(text);
      return true;
    } catch {
      const ta = document.createElement("textarea");
      ta.value = text;
      ta.setAttribute("readonly", "");
      ta.style.position = "fixed";
      ta.style.opacity = "0";
      document.body.append(ta);
      ta.select();
      const ok = document.execCommand("copy");
      ta.remove();
      return ok;
    }
  }
  for (const b of $$("[data-copy]")) {
    b.addEventListener("click", async () => {
      if (await copy(b.dataset.copy)) showToast(t().copied);
    });
  }
  for (const b of $$("[data-copy-link]")) {
    b.addEventListener("click", async () => {
      const url = location.href.split("#")[0];
      if (await copy(url)) showToast(t().linkCopied);
    });
  }

  // ---------------------------------------------------------------- Inicio

  let saved = null;
  try { saved = localStorage.getItem("awaylock-lang"); } catch {}
  if (saved === "en") applyLang("en");
  else updateClock();
  setInterval(updateClock, 30000);
})();
