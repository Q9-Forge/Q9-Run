#!/bin/bash
# Q9-Run volle Build-Kette - ausgeführt von Q9-QCC/Q9-QCC/ aus
# wegen hardcoded Pfade in QCC binaries

set -e

cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-QCC/Q9-QCC

QCC="./build/qcc"
QRUN_DIR="/Volumes/SSD1TB/projects/Q9-Forge/Q9-Run"
BUILD_DIR="$QRUN_DIR/build_os9"
TMPDIR="$BUILD_DIR/tmp"

echo "════════════════════════════════════════════════════════════"
echo "Q9-Run OS-9 Build-Kette (v2)"
echo "════════════════════════════════════════════════════════════"
echo "Working dir: $(pwd)"
echo ""

mkdir -p "$TMPDIR"

echo "[1/3] QCC Kompilierung: $QRUN_DIR/Source/qrun_os9_entry.c → IR"
$QCC \
  --emit-ir \
  --tmpdir "$TMPDIR" \
  -o "$TMPDIR/qrun.ir" \
  "$QRUN_DIR/Source/qrun_os9_entry.c" || {
  echo "✗ QCC Fehler"
  exit 1
}

echo "✓ IR erzeugt:"
wc -l "$TMPDIR/qrun.ir"
head -5 "$TMPDIR/qrun.ir"

echo ""
echo "[2/3] qir68k: IR → 68k-ASM"
../Q9-BACKEND-68K/q9-qir68k/build/qir68k "$TMPDIR/qrun.ir" "$TMPDIR/qrun.s68k" -os9 || {
  echo "✗ qir68k Fehler"
  tail -20 "$TMPDIR/qrun.s68k" 2>/dev/null || echo "  (keine Ausgabe)"
  exit 1
}

echo "✓ 68k-ASM erzeugt:"
wc -l "$TMPDIR/qrun.s68k"
head -10 "$TMPDIR/qrun.s68k"

echo ""
echo "[3/3] Optional: r68 Assembler (brauchen MWOS-Setup)"
echo "  (Überspringe für jetzt — Hauptziel: QCC→IR→ASM-Kette ✓)"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Build-Kette erfolgreich!"
echo ""
echo "Artefakte:"
ls -lh "$BUILD_DIR"/ | tail -5
