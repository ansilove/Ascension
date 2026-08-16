# Ascension III

![Ascension III](https://s3.amazonaws.com/f.cl.ly/items/2X1a3m1z3r2r2l2J2Z0n/asc3screen1.png)

Ascension III is an advanced ANSI/ASCII art viewer and text editor for
macOS. Originally created by [Stefan Vogt][original] (byteproject), this
fork modernizes the codebase for current macOS versions.

## Features

- View ANSI/ASCII artworks with accurate rendering
- Supports a wide range of file types: **ANS**, **BIN**, **ADF**, **IDF**,
  **XB**, **PCB**, **TND**, **ASC**, **NFO**, **DIZ** and plain text files
- Built-in text editor with legacy encoding support (Codepage 437 and others)
- Unicode support
- Properly renders Amiga artworks
- Export as PNG images
- Retina / HiDPI rendering
- Bundled **BlockZone** font (faithful recreation of the original DOS font)
  and many classic textmode typefaces
- Multi-color themes for ASCII
- SAUCE record reading
- Advanced settings: custom BIN columns, iCE colors, custom bits

## Installation

### Homebrew

```bash
brew install --cask vigo/ascension/ascension
```

### Requirements (building from source)

- macOS 13.0 (Ventura) or later
- Xcode 14+ for building from source

## Building

```bash
git clone https://github.com/vigo/Ascension.git
cd Ascension
open Ascension.xcodeproj
```

Build and run from Xcode (`Cmd+R`).

## What Changed in This Fork

- Removed embedded **AnsiLove.framework** and **AutoHyperlinks.framework**
  binaries; integrated AnsiLove source files directly into the project
- Refactored **SVBlockDrawDocument** for modern Objective-C compatibility
- Modernized **SVPreferences**, **SVThemeObject**, **SVToggleSlider**, and
  **SVEpicAboutBoxWC**
- Updated deployment target to macOS 13.0
- Cleaned up Xcode project configuration

## Version

Current release is `4.0.0 (200)`

## License

Ascension is released under the [BSD 3-Clause License](LICENSE).

Original author: Copyright (C) 2010-2015 Stefan Vogt.

---

[original]: https://github.com/byteproject/Ascension
