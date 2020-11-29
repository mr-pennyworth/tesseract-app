#!/usr/bin/env bash

mkdir Tesseract.app/Contents/Frameworks
mkdir Tesseract.app/Contents/MacOS
mkdir Tesseract.app/Contents/Resources

cp assets/tesseract.icns Tesseract.app/Contents/Resources/


echo
echo "Installing and copying tesseract binary"
HOMEBREW_NO_AUTO_UPDATE=1 brew install tesseract
cp "$(brew list tesseract | grep 'tesseract$')" Tesseract.app/Contents/MacOS
chmod +w Tesseract.app/Contents/MacOS/tesseract


echo
echo "Copying tessdata"
brew list tesseract \
  | grep tessdata \
  | xargs -I{} cp -r {} Tesseract.app/Contents/Resources/


echo
echo "Compiling dylibbundler"
cd macdylibbundler

echo
echo "Fixing tesseract library paths"
make
./dylibbundler \
 --overwrite-dir \
 --bundle-deps \
 --dest-dir ../Tesseract.app/Contents/Frameworks \
 --fix-file ../Tesseract.app/Contents/MacOS/tesseract \
 --install-path '@executable_path/../Frameworks'

cd ..

function tesseract_version() {
  ./Tesseract.app/Contents/MacOS/tesseract --version \
    | head -n1 \
    | cut -d' ' -f2
}

echo
echo "Setting app version to $(tesseract_version)"
plutil \
  -replace CFBundleVersion \
  -string "$(tesseract_version)" \
  Tesseract.app/Contents/Info.plist

plutil \
  -replace CFBundleShortVersionString \
  -string "$(tesseract_version)" \
  Tesseract.app/Contents/Info.plist


echo
echo "Zipping the app bundle"
zip -r Tesseract.app.zip Tesseract.app


# This'll be used by github workflow
echo -n "$(tesseract_version)" > tesseract_version
