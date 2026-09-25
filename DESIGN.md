---
name: AwayLock
description: The signal is the interface. A dark measurement world where color means presence.
colors:
  bg: "#0a0816"
  bg-raise: "#120f26"
  bg-sunk: "#07060f"
  line: "rgba(190, 180, 255, 0.1)"
  line-strong: "rgba(190, 180, 255, 0.18)"
  grid: "rgba(155, 140, 255, 0.055)"
  ink: "#f4f2ff"
  ink-2: "#c3bde3"
  ink-3: "#928bb8"
  ink-dim: "#736c96"
  violet: "#7b6cff"
  violet-hi: "#9d91ff"
  violet-deep: "#3a2a9e"
  green: "#4ade80"
  red: "#ff5c6c"
  orange: "#ffa24c"
  green-text: "#7fe9a3"
  red-text: "#ff8b96"
typography:
  display:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(52px, 7.4vw, 96px)"
    fontWeight: 850
    lineHeight: 0.92
    letterSpacing: "-0.04em"
    fontVariation: "'wdth' 115"
  headline:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(38px, 5.4vw, 76px)"
    fontWeight: 800
    lineHeight: 0.98
    letterSpacing: "-0.035em"
    fontVariation: "'wdth' 112"
  title:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(26px, 2.6vw, 36px)"
    fontWeight: 750
    lineHeight: 1.05
    letterSpacing: "-0.025em"
    fontVariation: "'wdth' 108"
  lede:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(18px, 1.5vw, 21px)"
    fontWeight: 400
    lineHeight: 1.55
    fontVariation: "'wdth' 100"
  body:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(17px, 1.35vw, 19px)"
    fontWeight: 400
    lineHeight: 1.55
    fontVariation: "'wdth' 100"
  label:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1
  reading-lg:
    fontFamily: "Martian Mono, ui-monospace, SF Mono, Menlo, monospace"
    fontSize: "clamp(30px, 3.2vw, 46px)"
    fontWeight: 500
    letterSpacing: "-0.04em"
    fontFeature: "tnum"
  reading:
    fontFamily: "Martian Mono, ui-monospace, SF Mono, Menlo, monospace"
    fontSize: "13px"
    fontWeight: 400
    letterSpacing: "-0.01em"
    fontFeature: "tnum"
rounded:
  pill: "999px"
  instrument: "12px"
  chart: "16px"
  shot: "18px"
  callout: "20px"
  card: "24px"
  field: "28px"
spacing:
  gutter: "clamp(16px, 4vw, 56px)"
  maxw: "1240px"
  section-top: "clamp(96px, 16vh, 180px)"
  grid-cell: "56px"
components:
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "#120e2e"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "52px"
    padding: "0 24px"
  button-primary-hover:
    backgroundColor: "#ffffff"
  button-ghost:
    backgroundColor: "rgba(255, 255, 255, 0.03)"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "52px"
    padding: "0 24px"
  button-ghost-hover:
    backgroundColor: "rgba(255, 255, 255, 0.07)"
  button-sm:
    rounded: "{rounded.pill}"
    height: "36px"
    padding: "0 14px"
  link:
    textColor: "{colors.violet-hi}"
  chip:
    backgroundColor: "rgba(255, 255, 255, 0.1)"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
    padding: "10px 16px"
  tag:
    backgroundColor: "rgba(18, 15, 38, 0.92)"
    rounded: "{rounded.pill}"
    padding: "6px 10px"
  readout:
    backgroundColor: "rgba(18, 15, 38, 0.85)"
    textColor: "{colors.ink-2}"
    rounded: "{rounded.pill}"
    padding: "10px 18px"
  segmented-step:
    backgroundColor: "transparent"
    textColor: "{colors.ink-3}"
    rounded: "{rounded.pill}"
    padding: "0 14px"
  segmented-step-current:
    backgroundColor: "rgba(157, 145, 255, 0.16)"
    textColor: "{colors.ink}"
  code-well:
    backgroundColor: "{colors.bg-sunk}"
    textColor: "{colors.ink}"
    rounded: "{rounded.instrument}"
    padding: "12px 12px 12px 16px"
  callout-caution:
    backgroundColor: "rgba(255, 162, 76, 0.07)"
    rounded: "{rounded.callout}"
    padding: "28px"
  instrument-panel:
    backgroundColor: "rgba(7, 6, 15, 0.55)"
    rounded: "{rounded.instrument}"
---

# Design System: AwayLock

This records the **web landing** (`site/`). The native macOS app (SwiftUI, `Sources/AwayLock`) is a separate surface: see the note at the end of Components.

## Overview

**Creative North Star: "The Signal Is the Interface"**

AwayLock's landing is an instrument, not a brochure. The ground is a near-black violet night with a faint 56px measurement grid and one violet glow in the upper right; on it, the product explains itself by working: radar rings that are the real thresholds, a Mac that locks as you scroll away from it, a live dBm trace. Heavy, wide Archivo carries the voice; Martian Mono appears where a number is being read off a sensor. Density is low and cinematic, one idea per scene, with long vertical breathing room between scenes.

Color in this world is not decoration. Four hues are reserved as signal states, and the violet that tints the whole world doubles as the "locked" state, so the brand color and the product's core outcome are the same thing. Everything else is a violet-tinted neutral.

The build rejects the category default of hero, feature-card grid, screenshot, CTA. Facts are a definition list with drawn glyphs, not cards; proof is an animated instrument, not a bullet list.

**Key Characteristics:**
- Dark-only violet night (`bg` #0a0816) with a 56px hairline grid and a single radial violet glow.
- Signal colors with fixed meanings: green near/back, red lock threshold, orange leaving/waiting, violet locked.
- Archivo variable, pushed wide (`wdth` 108 to 115) and heavy (750 to 850) for display; normal width for reading.
- Martian Mono only for readings (dBm, meters, seconds, thresholds) and code.
- Pills for every control and readout; instruments sit in sunk, hairline-bordered wells.
- Motion demonstrates the product (scroll-scrubbed walk, radar loop, drawn charts) and collapses to static, fully readable states under reduced motion.

## Colors

A violet-tinted monochrome night carrying four semantic signal hues; nothing is colored unless it means something.

### Primary
- **Locked Violet** (`violet`, `violet-hi`, `violet-deep`): the brand and the "locked" state at once. `violet` drives the ambient glows (body radial, radar gradient, login-card wash, primary-button shadow). `violet-hi` is the legible foreground version: links, the focus ring, install-step counters, the "locked" caption and radar state, the lock marker on the logic chart. `violet-deep` is the shadowed end of gradients and the padlock keyhole.

### Signal (semantic, not decorative)
- **Presence Green** (`green`): near / "volviste". The inner radar ring, the phone dot, the near panel badge and meter knob, the "near" and "back" captions, the green threshold line, the unlock toast icon. `green-text` (#7fe9a3) is its small-text variant for threshold labels and the "re-arm" tag.
- **Threshold Red** (`red`): the lock threshold. The outer radar ring, the red threshold line, the red meter zone. It also marks explicit refusals (the "doesn't store your password" list icons on a 14% red disc). `red-text` (#ff8b96) is the small-text variant for threshold labels.
- **Leaving Orange** (`orange`): leaving, waiting, caution. The leaving caption and panel state, the delay and grace fact glyphs, and the Gatekeeper caution callout (7% fill, 30% border).

### Neutral
- **Night** (`bg`): page ground and `theme-color`.
- **Raised Night** (`bg-raise`): lifted cards (login card base).
- **Sunk Night** (`bg-sunk`): code wells; instrument wells use it at 55% alpha.
- **Hairline / Hairline Strong** (`line`, `line-strong`): all borders and dividers, violet-tinted at 10% and 18%.
- **Grid** (`grid`): the 56px background grid only.
- **Ink** (`ink`): headlines, primary-button face, trace lines.
- **Ink 2** (`ink-2`): body copy, ledes, secondary UI.
- **Ink 3** (`ink-3`): meta, legends, muted labels, inactive steps.
- **Ink Dim** (`ink-dim`): the settled color of the first two kinetic headline lines, so the third line ("Tu Mac se bloquea.") stays brightest.

### Named Rules
**The Four Signals Rule.** Green, red, orange and violet each mean exactly one state (near/back, lock threshold or refusal, leaving/caution, locked). Never use them as accent decoration, category color, or to "add variety". If a new element is green, it must mean the phone is close.

**The Tinted Neutral Rule.** Every neutral, border and overlay carries the violet hue (borders are `rgba(190,180,255,…)`, not gray). Pure white appears only as the padlock, the primary-button hover, and white strokes on signal dots.

## Typography

**Display Font:** Archivo variable (wdth 62 to 125, wght 100 to 900), with ui-sans-serif, system-ui fallback
**Body Font:** Archivo at normal width (`wdth` 100)
**Label/Mono Font:** Martian Mono 400/500, with ui-monospace, SF Mono, Menlo fallback

**Character:** One family doing two jobs through its width axis: stretched wide and near-black-weight for statements, normal width for reading. Martian Mono is the instrument's voice, never the narrator's.

### Hierarchy
- **Display** (850, clamp(52px, 7.4vw, 96px), lh 0.92, wdth 115): the kinetic hero headline, one clause per line. The closing title uses the same voice (clamp(48px, 8vw, 96px), lh 0.95).
- **Headline** (800, clamp(38px, 5.4vw, 76px), lh 0.98, wdth 112): every section h2, `text-wrap: balance`, usually capped at 18ch.
- **Title** (750, clamp(26px, 2.6vw, 36px), lh 1.05, wdth 108): walk captions, colored by phase. The CPU statement in the privacy field is a sibling (750, clamp(28px, 3.4vw, 46px), wdth 110).
- **Lede** (400, clamp(18px, 1.5vw, 21px)): the hero sentence, max 44ch.
- **Body** (400, clamp(17px, 1.35vw, 19px), lh 1.55): section copy in `ink-2`, max 58 to 60ch, `text-wrap: pretty`. Base body size is 17px (16px under 560px).
- **Subheads** (600 to 700, 18 to 23px): install steps, FAQ summaries (650), fact terms (700, 19px), Gatekeeper h3 (22px).
- **Label** (600, 16px; 14px small): buttons, chips, tags.
- **Reading** (Martian Mono, 500, clamp(30px, 3.2vw, 46px), -0.04em, tabular) for the big distance and signal readouts; 13px for the radar readout; 10 to 12px for threshold labels and ruler ticks.

### Named Rules
**The Measurement Voice Rule.** Martian Mono is reserved for values a sensor or the code produces: dBm, meters, seconds, threshold numbers, and code/terminal commands. Headlines, prose and ordinary buttons are always Archivo. Every mono number uses tabular figures.

**The Width Axis Rule.** Emphasis comes from width and weight together: the bigger the statement, the wider (`wdth` 108 → 112 → 115) and heavier (750 → 800 → 850), with tighter tracking (-0.025em → -0.04em). Body text never leaves `wdth` 100.

## Layout

- **Container:** content max width 1240px, side gutter clamp(16px, 4vw, 56px). Sections open with clamp(96px, 16vh, 180px) of top padding; the close scene gets more (clamp(120px, 20vh, 220px)).
- **Ground:** the 56px grid and violet glow are painted on `body`, so every scene sits on the same measuring surface.
- **Grids:** two-column splits are always asymmetric (hero 1.05/0.95, walk 0.8/1.2, password 1.1/0.9, app 1.55/0.9, install 1/1.15) with fluid gaps (clamp 24 to 96px). Every grid child gets `min-width: 0` so long code cannot widen the page.
- **Facts:** auto-fit columns min 260px; at 1100px and up a 6-column grid where the first two facts span 3 and the rest span 2.
- **The walk:** a 440vh scroll track with a sticky 100svh stage; scroll progress drives the scene.
- **Full-bleed moment:** the privacy field breaks the column into a 28px-radius violet slab inset by the gutter.

### Responsive
- **960px and below:** everything collapses to one column; nav links hide; the radar shrinks to 340px; the walk stage puts the visual above the copy, hides the big readouts, and tightens captions and trace.
- **700px and below:** logic-chart tags leave the chart and wrap in a row beneath it; radar legend stacks.
- **560px and below:** body 16px; brand wordmark hides (icon only); CTA buttons stretch to fill the row at 50px tall; footer stacks.
- **Input modality, not width:** `(hover: none) and (pointer: coarse)` hides the download buttons and shows a "this is a Mac app, copy the link" note with a copy-link primary button. The product cannot be installed from a phone, so the page never offers a download there.

## Elevation & Depth

Depth is tonal first: sunk wells (`bg-sunk`, or 55% alpha) for instruments and code, raised night (`bg-raise`) for cards, violet hairlines (`line`, `line-strong`) on every edge. Shadows are long, soft and negatively spread, reading as distance above the night rather than as outlines. The one colored shadow family is violet glow, used only where the brand is speaking (primary CTA, privacy slab, closing icon). Frosted glass (`backdrop-filter` blur) is used where macOS itself uses it: the sticky nav, the drawn menu bar, and the drawn lock screen.

### Shadow Vocabulary
- **Deep drop** (`box-shadow: 0 40px 80px -40px rgba(0, 0, 0, 0.9)`): screenshots, the drawn Mac screen, the login card.
- **Float** (`box-shadow: 0 18px 40px -14px rgba(0, 0, 0, 0.8)`): small floating UI inside the drawn Mac (panel, toast); the radar readout uses `0 16px 40px -18px`.
- **CTA glow** (`box-shadow: 0 10px 30px -10px rgba(123, 108, 255, 0.7), inset 0 -2px 0 rgba(58, 42, 158, 0.18)`): primary button at rest; hover grows to `0 14px 38px -10px` at 0.9.
- **Field glow** (`box-shadow: 0 50px 100px -50px rgba(58, 42, 158, 0.9)`): the privacy slab.
- **Signal halo** (`drop-shadow(0 4px 14px rgba(74, 222, 128, 0.55))`, `0 0 18px rgba(74, 222, 128, 0.6)`): the green phone dot on radar and ruler.

### Named Rules
**The Night Glow Rule.** Colored shadow is violet or signal-green, never black-on-color or offset. Violet glows only under brand moments; green glows only under the phone.

## Shapes

- **Pills everywhere you touch or read** (999px): buttons, the language toggle, the segmented step control, chips, tags, the radar readout, the copy toast, input-like fields.
- **Instrument wells** (12px): code blocks, the signal trace, the drawn menu-bar panel; the logic chart is 16px.
- **Large surfaces step up with size:** screenshots 18px, the caution callout 20px, the login card 24px, the privacy slab 28px, the closing app icon 30px.
- **Circles** for anything that is a point or a person: signal dots, the phone dot, status badges, avatars, the numbered install counters (36px, violet hairline ring).
- **Thresholds are dashed, round-capped strokes:** `3 9` on the radar rings, `4 6` on chart threshold lines, drawn with `vector-effect: non-scaling-stroke`.
- **Concentric rings** are the signature silhouette, shared with the app icon: the hero radar, the expanding pulse, and the three rings around the closing icon.

## Components

### Buttons
Confident, glowing on the dark, and physically responsive to a press.
- **Shape:** full pill (999px), 52px tall, 24px side padding, 600 weight 16px, optional 18px stroke icon with a 10px gap.
- **Primary:** `ink` face with deep violet-black text (#120e2e) and the CTA glow. It reads as the brightest object on the page. One per scene.
- **Ghost:** 3% white fill, `line-strong` border, `ink` text; hover lifts to 7% fill and a 30% violet border.
- **Small** (36px, 14px text, 16px icon): the GitHub button in the nav.
- **Press:** every button scales to 0.97 (small controls 0.96) over 160ms `ease-out`; color and shadow ease over 180 to 220ms.
- **Focus:** a 2px `violet-hi` outline, 3px offset, on every focusable element.

### Links
- `violet-hi` text with a 40%-alpha underline at 3px offset; hover makes the underline solid. Standalone code links pair the text with a 45-degree arrow icon.

### Chips and Tags
- **Chips** (privacy field): 10px 16px pills, 10% white fill, 18% white border, 600 weight 15px. They stagger in 60ms apart when the list enters view.
- **Tags** (logic chart annotations): 6px 10px pills on 92% raised night with a `line-strong` border, 600 weight 13px, text colored by the signal they describe (violet-hi for "locks once", ink-2 for "calm", green-text for "re-arm").

### Segmented Step Control
- A 4px-padded pill track (3% fill, `line` border) holding 34px pill buttons in `ink-3`. The current step (`aria-current="step"`) gets a 16% violet fill and `ink` text. It jumps the walk to each phase and is the primary control when motion is reduced.

### Instrument Wells
- **Signal trace and logic chart:** sunk night at 55% alpha, `line` border, 12px (trace) or 16px (chart) radius, overflow clipped. `ink` polyline at 2 to 2.2px with round joins; green and red dashed threshold lines; mono threshold labels in the text variants.
- **Code well:** `bg-sunk`, `line-strong` border, 12px radius, 13px mono in `ink`, horizontal scroll inside the well only, with a small 32px copy button (8px radius, 5% fill) that confirms through the pill copy toast.

### Radar (signature)
- A 400-unit SVG: violet radial glow, a faint outer ring, the red lock ring (r 128) and green near ring (r 78) as dashed strokes, a pulse ring, a white padlock whose shackle opens and closes, and the green phone dot drifting out and back on a 10-second loop. Under it a pill readout pairs the state word (colored by state) with a mono dBm value, and a legend explains the two rings.

### Drawn Mac (signature)
- A 16:10 black screen with a 7px night bezel and a gradient base, showing a violet wallpaper, a frosted menu bar with the AwayLock status item, the menu-bar panel (status badge, meter with red/mid/green zones and a knob), a frosted lock screen, and an unlock toast. It is an illustration of macOS, so it follows macOS proportions; its tiny internal type is illustration scale, not a type step. Every simulated instrument is captioned "Demostración con valores ilustrativos".

### Caution Callout
- The Gatekeeper aside: orange at 7% fill and 30% border, 20px radius, 28px padding, a light-orange h3, an ordered list, and a code well. Orange here means "expect a stop", matching its leaving/waiting meaning.

### Navigation
- Sticky top bar, 14px vertical padding, a night gradient (92% to 70%) with `saturate(140%) blur(14px)` and a `line` bottom border. Brand icon (28px, 7px radius) plus wordmark at `wdth` 110; section links in `ink-2` at 15px turning `ink` on hover; right side holds the mono language pill and the small ghost GitHub button. Links hide at 960px; the wordmark hides at 560px.

### FAQ
- Native `details`: `line-strong` rules above and below, 650 weight summaries with a drawn chevron that rotates from down to up over 220ms `ease-out`, answers capped at 64ch.

### Motion
Motion shows the product working; it never decorates.
- **Easing:** `ease-out` cubic-bezier(0.23, 1, 0.32, 1) for entrances and presses; `ease-in-out` cubic-bezier(0.77, 0, 0.175, 1) for wipes and draws.
- **Entrances:** blur-and-rise (opacity 0, `blur(6 to 12px)`, 10 to 14px down → rest). The hero headline builds line by line (150 / 750 / 1350ms delays, 900ms each), the first two lines then dim to `ink-dim`, and the lede and CTAs rise in at 1800 to 2000ms.
- **Reveals:** the logic chart draws left to right with a 2600ms `clip-path` wipe, then its lock marker and tags appear in sequence (1300 to 2500ms). Screenshots wipe down with a 1100ms `clip-path`. Reveals trigger once via IntersectionObserver at -12% bottom margin.
- **Ambient loops:** the radar pulse (3.2s), the closing rings (3.6s, staggered 1.2s), a login spinner (800ms) and a blinking caret. The radar's JS loop pauses when offscreen or when the tab is hidden.
- **Scroll-driven:** the walk scene is scrubbed by scroll position on a rAF-throttled passive listener; step buttons smooth-scroll to each phase.
- **Progressive enhancement:** reveal states only apply under an `html.js` class, so without JavaScript all content is visible.
- **Reduced motion:** entrance animations are removed and elements render at their final state (the first two headline lines already dimmed); pulse and ring loops stop and hide; spinner and caret stop; the walk track loses its 440vh height and the stage unpins, showing the first phase with the step buttons switching phases instantly; chart and screenshot wipes are removed; the radar renders one static frame; smooth scrolling is disabled.

### Native macOS app (separate surface)
The SwiftUI app in `Sources/AwayLock` shares the icon and the signal meanings but not the web tokens. It uses system colors (`.green` near, `.orange` leaving or paused, `.red` no signal, `.indigo` locked), system text styles with `.secondary`/`.tertiary` foregrounds, a grouped `Form` for the window, `MenuBarExtra` for the panel, and continuous rounded rectangles (10 to 12pt). Follow native macOS conventions there; do not port Archivo, Martian Mono, the night palette or web radii into it.

## Do's and Don'ts

### Do:
- **Do** keep the page on the violet night (`bg` #0a0816) with the 56px grid and a single violet glow; the landing is dark-only.
- **Do** color a thing green, red, orange or violet only when it expresses that signal state (The Four Signals Rule).
- **Do** set every sensor value and code string in Martian Mono with tabular figures, and everything else in Archivo (The Measurement Voice Rule).
- **Do** widen and thicken Archivo as statements grow (`wdth` 108/112/115, weight 750/800/850) and leave body at `wdth` 100.
- **Do** make every control a pill that scales to 0.97 on press over 160ms `ease-out`, with the 2px `violet-hi` focus ring.
- **Do** caption any simulated instrument as illustrative, and use the real app screenshots for the real UI.
- **Do** give every animation a static, fully readable reduced-motion state and gate reveal-hidden states behind the `js` class.
- **Do** swap download CTAs for the copy-link note on coarse-pointer, no-hover devices.

### Don't:
- **Don't** build a feature-card grid, a hero-screenshot-CTA stack, or icon-in-a-tile fact cards; explain by showing the signal and the Mac locking.
- **Don't** use gray borders or neutral black overlays; tint them violet (`rgba(190, 180, 255, …)`, `rgba(18, 15, 38, …)`).
- **Don't** use a signal color as brand accent, category color or gradient flourish on page surfaces; brand violet is the only atmospheric color (the drawn Mac's wallpaper is an illustration of macOS, not a page surface).
- **Don't** set headlines or prose in Martian Mono, or measurements in Archivo.
- **Don't** use hard or offset shadows; depth is tonal layers, hairlines and long soft negative-spread shadows.
- **Don't** offer a download on touch devices, and don't invent stars, users, testimonials or benchmark numbers the project doesn't have.
