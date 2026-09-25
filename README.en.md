<div align="center">

<img src="docs/icon.png" alt="AwayLock icon" width="128">

# AwayLock

**Your Mac locks itself when you walk away with your iPhone.**<br>
Come back and your Apple Watch unlocks it, hands-free.

[![Latest release](https://img.shields.io/github/v/release/Lucavcolazo/AwayLock)](https://github.com/Lucavcolazo/AwayLock/releases/latest)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
[![MIT License](https://img.shields.io/badge/license-MIT-6E56CF)](LICENSE)

[**Download**](https://github.com/Lucavcolazo/AwayLock/releases/latest) · [Español](README.md)

<img src="docs/estados.png" alt="AwayLock's three states: near, walking away and locked" width="100%">

<sub>The app is in Spanish for now.</sub>

</div>

## How it works

1. **Keep your iPhone on you.** AwayLock listens to its Bluetooth signal from the menu bar.
2. **Get up and leave.** When the signal drops, it waits a few seconds just in case, then locks your Mac.
3. **Come back.** It wakes the screen and your Apple Watch unlocks it as usual.

AwayLock only **locks**. It never stores your password or asks for Accessibility access: unlocking is still up to macOS, with your Apple Watch, Touch ID or password.

## Download and install

1. Download the `.zip` from the [latest release](https://github.com/Lucavcolazo/AwayLock/releases/latest) and unzip it.
2. Move **AwayLock.app** to **Applications**.
3. Open it and allow **Bluetooth** access when asked.

> [!IMPORTANT]
> **macOS will block it the first time.** AwayLock isn't signed with a paid Apple Developer account, so macOS says it can't verify it. To open it:
>
> 1. Try to open AwayLock and dismiss the warning (don't move it to the Trash).
> 2. Go to **System Settings → Privacy & Security**.
> 3. Scroll down to the message about AwayLock and click **Open Anyway**.
>
> You only need to do this once. If you prefer the Terminal, this does the same:
>
> ```bash
> xattr -dr com.apple.quarantine /Applications/AwayLock.app
> ```
>
> The code is open source: if you'd rather not trust the downloaded file, you can [build it yourself](#build-from-source).

### Requirements

- A Mac with Bluetooth, Apple silicon or Intel.
- macOS 13 or later. So far it's been tested on macOS 26; if you use it on another version, [let us know how it went](https://github.com/Lucavcolazo/AwayLock/issues/new/choose).
- An iPhone signed in to the **same Apple Account** as your Mac. That's how your Mac always recognizes it, even though the iPhone rotates its Bluetooth address for privacy.
- Optional: an Apple Watch with **System Settings → Touch ID & Password → Apple Watch** turned on, so it unlocks your Mac when you return. It works without a watch too; you just unlock with Touch ID or your password.

## Getting started

1. The AwayLock window opens on its own the first time. If it doesn't, open the app from Applications or click **Dispositivo y ajustes…** (Device and settings) in the menu bar.
2. Bring your iPhone close to the Mac and select it under **Dispositivo** (Device).
3. Watch the meter while sitting as usual, then walk to where you want it to lock. Use that to set the two marks under **Distancia** (Distance).

Turn on **Abrir al iniciar sesión** (Open at login) to have AwayLock start every time you log in.

## Privacy

AwayLock doesn't connect to the internet, collects no data and never stores your password. All it does is measure your iPhone's Bluetooth signal, entirely on your Mac.

## FAQ

<details>
<summary><b>Can it get stuck locking over and over?</b></summary>
<br>

No. After locking, AwayLock won't lock again until it sees you close by, and it gives you a few seconds of grace after you unlock. If it ever locks while you're sitting at your Mac, the panel tells you and suggests what to adjust.
</details>

<details>
<summary><b>Does it drain the battery?</b></summary>
<br>

No. It uses Bluetooth Low Energy, the same kind of connection your iPhone already keeps with your watch or AirPods. With the panel closed, the app uses virtually no CPU. For the absolute minimum, turn on **Solo escuchar (sin conectarse)** (Listen only).
</details>

<details>
<summary><b>What if I leave my iPhone on the desk?</b></summary>
<br>

Then your Mac won't lock, because as far as AwayLock knows you're still there. It works when you carry your iPhone with you.
</details>

<details>
<summary><b>What happens when I close the lid or the Mac sleeps?</b></summary>
<br>

On wake it starts fresh and waits to see you close by before watching again, so it won't lock you out right after you open your laptop.
</details>

<details>
<summary><b>My iPhone doesn't show up in the list</b></summary>
<br>

The list only shows devices whose name includes "iPhone". If you renamed yours, check **Mostrar todos los dispositivos** (Show all devices). Also make sure your iPhone uses the same Apple Account as your Mac.
</details>

<details>
<summary><b>How is it different from BLEUnlock?</b></summary>
<br>

[BLEUnlock](https://github.com/ts1/BLEUnlock) is a great project that also unlocks your Mac by typing your password, which it stores in the Keychain and types using Accessibility access. AwayLock was written from scratch with a different approach: it only locks and leaves unlocking to your Apple Watch, so it never touches your password.
</details>

## Report a problem

This is a new project, so your experience really helps. If something doesn't work, [open an issue](https://github.com/Lucavcolazo/AwayLock/issues/new/choose). The form asks for your Mac model, macOS version and the signal you see while sitting, which is what's needed to figure out what's going on.

## Build from source

You need Xcode or its command line tools.

```bash
git clone https://github.com/Lucavcolazo/AwayLock.git
cd AwayLock
./install.sh
```

`install.sh` builds the app, copies it to Applications and opens it. Run it again to update after a change.

<details>
<summary>For developers</summary>
<br>

- `swift test` runs the tests for the logic that decides when to lock.
- `swift run AwayLock --snapshots docs` regenerates the README images with sample data.
- `./scripts/make-icon.sh` regenerates the icon from `scripts/icon.swift`.
- `./scripts/release.sh` builds `dist/AwayLock-<version>.zip`. Pushing a `vX.Y.Z` tag makes GitHub Actions build and publish the release automatically.
- `Sources/AwayLockCore` holds the pure logic; `Sources/AwayLock`, the Bluetooth, screen and UI code.

</details>

## License

[MIT](LICENSE)
