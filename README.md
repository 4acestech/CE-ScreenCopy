# CE-ScreenCopy for macOS
Made by @4acestech

Mac port of Calc2KeyCE.Fast (https://github.com/dnmalenke/Calc2KeyCE, MIT). Same calculator-side
program and USB protocol, so **your existing CALC2KEY.8xp + usbdrvce on the calc work unchanged**.

- Screen mirroring: ScreenCaptureKit -> 320x240 -> same palette/ZX0 packing as the Windows build
- Calc keys -> keyboard / mouse via CGEvent (bind, save/load bindings, mouse speed)
- Simple AppKit window: connection status, permissions, fps, binding table
- **Casio fx-CG mode** (new): mirrors the Mac screen to a Casio fx-CG calculator over USB and forwards its keys

## Install as a DMG
    bash make_dmg.sh
Builds the app (if needed) and creates `CE-ScreenCopy.dmg` with the usual drag-to-Applications layout.

## Build (on the Mac)
    cd Calc2KeyCE-mac && ./build.sh
Installs libusb/leptonica/dylibbundler via Homebrew, builds `CE-ScreenCopy.app`, bundles the libs, ad-hoc signs it.

## Use
1. Calc: run `CALC2KEY` (needs usbdrvce + CE C libs on the calc, same as the Windows version). Back up RAM first. [ON] exits.
2. Plug in the calc, open the app (first time: right-click > Open).
3. Click **Grant Permissions…**:
   - Screen Recording (mirroring)
   - Accessibility (key/mouse binds)
   Then quit and reopen the app once after granting.
4. Status should read "Connected to calculator."

No Zadig / driver install is needed on macOS; libusb talks to it directly.

## Tests
`test/test_core.cpp` covers report decoding, bindings and frame packing (built on Linux).
The ScreenCaptureKit / CGEvent / AppKit parts only compile on macOS.

## Casio fx-CG mode (fx-CG10/20/50)
Pick **Casio fx-CG** with the switch at the top right of the window.

This talks to the **CG Virtual Monitor** add-in (`CGVirtMo.g3a`, by Lephenixnoir, built on gint) using
its USB "fxlink" protocol, so you still need that add-in on the calculator. It is not included here.
Get it from https://git.planet-casio.com/Lephenixnoir/cg-virtual-monitor and copy it to the calc like any add-in.

1. Copy `CGVirtMo.g3a` to the calculator (USB mass-storage mode), eject it.
2. On the calc, open **Virt Monitor**. It waits for a computer.
3. Plug the USB cable into the Mac, open CE-ScreenCopy, choose **Casio fx-CG**.
4. Status should read "Connected to Casio calculator." and the Mac screen appears on the calc (396x224).

Calc keys are sent back to the Mac as keyboard/mouse input. Defaults match the add-in's own mapping
(0=Z, EXE=Return, A-F/G-L/M-O/P-T/U-Y letters, arrows, F1-F6, ...). Use **Bind Key...** to change them,
**Defaults** to restore. Casio bindings are stored separately from the TI ones.

Notes
- Wire format (396x224, RGB565 big-endian, `cgvm`/`fb` messages, `pressed-keys` replies) was read from the
  published host client; no code from that project is included.
- Frame rate is limited by the calc's USB link and by what the add-in draws.
- Quit the add-in on the calc (EXIT/MENU) before unplugging.

## Calculator View + quality settings
Click **Calculator View…** to open a window showing exactly what the calculator is displaying
(after palette reduction / pixelation). Under it you can trade quality for speed live:

- **Resolution** Full, 1/2, 1/3, 1/4, 1/6 (pixelates the image; compresses better on TI)
- **Colours** 240 down to 8 (TI only: smaller palette = smaller frames = higher FPS)
- **Grayscale**
- **Max FPS** cap (1-30)
- **Compression** how long the TI packer may spend per frame (Fast / Balanced / Best)
- **Skip unchanged frames** don't re-send a frame the calc already shows
- Presets: Best quality, Balanced, Max speed

On Casio the USB frame size is fixed (396x224 RGB565), so resolution/colour only change the look;
the FPS cap and skip-unchanged are what help there. Settings are remembered.

**Hide/Show** buttons: Calculator View, Options, Key Bindings (main window) and Settings (view window).
