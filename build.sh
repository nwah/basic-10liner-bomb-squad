#!/bin/sh

mkdir -p ./dist
mkdir -p ./build

rm -rf ./dist/*.*
rm -rf ./build/*.*

node ../rename.js src/bomb-squad-ntsc.bas > build/bomb-squad-ntsc.bas
node ../rename.js src/bomb-squad-pal-en.bas > build/bomb-squad-pal-en.bas
node ../rename.js src/bomb-squad-pal-de.bas > build/bomb-squad-pal-de.bas
node ../rename.js src/bomb-squad-pal-pl.bas > build/bomb-squad-pal-pl.bas

../../fastbasic-v4.7/fastbasic -ls:256 build/bomb-squad-ntsc.bas
../../fastbasic-v4.7/fastbasic -ls:256 build/bomb-squad-pal-en.bas
../../fastbasic-v4.7/fastbasic -ls:256 build/bomb-squad-pal-de.bas
../../fastbasic-v4.7/fastbasic -ls:256 build/bomb-squad-pal-pl.bas

mv build/*.xex dist/

mv build/bomb-squad-ntsc.list ./bomb.bas
