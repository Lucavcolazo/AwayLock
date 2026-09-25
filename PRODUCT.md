# Product

<!-- impeccable:product-schema 1 -->

## Platform

web (landing page). The product itself is a native macOS menu bar app; this record covers the web surfaces that present it.

## Stack

Static HTML/CSS/JS, no framework and no build step. Published on GitHub Pages.

## Users

Tech audience on X: developers and people who follow open source projects, who own a Mac and an iPhone and leave the Mac unattended at offices, coworkings, university or cafés. They will judge the project partly by its code and approach, and most will first open the link on their phone.

## Product Purpose

AwayLock locks the Mac automatically when its owner walks away carrying their iPhone, by measuring the iPhone's Bluetooth signal. Unlocking stays with macOS (Apple Watch Auto Unlock, Touch ID or password). Success for the landing: visitors understand the idea in seconds, trust it, and download it or star the repo.

## Positioning

AwayLock only locks. It never stores or types the user's password and does not need Accessibility permission, unlike BLEUnlock, which unlocks by typing the password stored in the Keychain. It is written from scratch, open source (MIT), and makes no network connections.

## Operating Context

- Lives in the macOS menu bar; a separate window holds device selection and settings.
- Presence logic: median of recent signal readings, two thresholds (lock below, "you're back" above) with a gap between them, a delay before locking, a grace period after unlocking, and a fresh start after sleep, so it cannot get stuck locking repeatedly.
- The Mac recognizes the iPhone reliably only when both use the same Apple Account.
- Distributed as a zip on GitHub Releases, ad-hoc signed (not notarized). First launch requires System Settings → Privacy & Security → "Open Anyway". This will not change: the author won't pay for the Apple Developer Program.

## Capabilities and Constraints

- Requirements: Mac with Bluetooth (Apple silicon or Intel), macOS 13+ (tested only on macOS 26), iPhone on the same Apple Account. Apple Watch optional for unlocking.
- App UI is Spanish only for now.
- Measured on the author's Mac: ~0% CPU with the panel closed.
- Can't be downloaded or used from a phone; the landing must handle mobile visitors.
- Version 0.1.0, first public release.

## Brand Commitments

- Name: AwayLock. Icon: white padlock centered in radar rings on a violet gradient, with a green dot for the iPhone (`docs/icon.png`, `Resources/AppIcon.icns`).
- Voice: Rioplatense Spanish (voseo), plain and direct; English as a secondary language.
- The user asked for a landing inspired by a Wallbit promo video: dark background, heavy large type, small mono eyebrows, one idea per scene, animations that show the product working.

## Evidence on Hand

- Real screenshots rendered from the app: `docs/estados.png`, `docs/ventana.png`.
- Repository: https://github.com/Lucavcolazo/AwayLock. Latest release: https://github.com/Lucavcolazo/AwayLock/releases/latest.
- No users, testimonials, download counts, stars or press yet. Do not fabricate any.

## Product Principles

1. Honesty over hype: state limits (unsigned app, tested only on macOS 26, iPhone must be carried).
2. Never touch the password; locking is the only job.
3. Private by construction: no network, no data, everything on the Mac.
4. Show, don't tell: the product is best explained by watching the signal drop and the Mac lock.

## Accessibility & Inclusion

Respect `prefers-reduced-motion`; all information must be readable without animations.
