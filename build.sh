#!/usr/bin/env bash
# Builds CE-ScreenCopy.app on macOS 12.3+ (Apple Silicon or Intel). Paste-and-run:  ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

command -v xcrun >/dev/null || { echo "Install Xcode command line tools first:  xcode-select --install"; exit 1; }
command -v brew  >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
brew list libusb >/dev/null 2>&1 || brew install libusb
brew list leptonica >/dev/null 2>&1 || brew install leptonica
brew list dylibbundler >/dev/null 2>&1 || brew install dylibbundler

P="$(brew --prefix)"
APP="CE-ScreenCopy.app"
rm -rf "$APP" build && mkdir -p build "$APP/Contents/MacOS" "$APP/Contents/Frameworks"

CF="-O2 -I$P/include -I$P/include/leptonica -Isrc"
clang   $CF -c src/compression.c -o build/compression.o
clang++ $CF -std=c++17 -fobjc-arc -c src/main.mm        -o build/main.o
clang++ $CF -std=c++17 -fobjc-arc -c src/capture_mac.mm -o build/capture.o
clang++ $CF -std=c++17 -fobjc-arc -c src/input_mac.mm   -o build/input.o
clang++ $CF -std=c++17 -c src/sender.cpp   -o build/sender.o
clang++ $CF -std=c++17 -c src/receiver.cpp -o build/receiver.o
clang++ $CF -std=c++17 -c src/casio.cpp   -o build/casio.o
clang++ $CF -std=c++17 -c src/quality.cpp  -o build/quality.o

LEPT=lept; ls "$P"/lib/libleptonica.* >/dev/null 2>&1 && LEPT=leptonica   # name differs by leptonica version
clang++ build/*.o -o "$APP/Contents/MacOS/CE-ScreenCopy" -L"$P/lib" -lusb-1.0 -l$LEPT \
  -framework Cocoa -framework ScreenCaptureKit -framework CoreMedia -framework CoreVideo -framework ApplicationServices

cp Info.plist "$APP/Contents/Info.plist"
# make the app self-contained (copies libusb/leptonica + deps into the bundle)
dylibbundler -od -b -x "$APP/Contents/MacOS/CE-ScreenCopy" -d "$APP/Contents/Frameworks" -p @executable_path/../Frameworks >/dev/null
codesign --force --deep --sign - "$APP"

echo; echo "Built $APP  ->  drag it to /Applications, then right-click > Open the first time."
