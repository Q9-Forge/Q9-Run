#!/bin/bash
# Q9-Run volle Build-Kette für OS-9 Ziel
# QCC → IR → qir68k → r68-ASM → l68-Link

set -e

QCC_DIR="/Volumes/SSD1TB/projects/Q9-Forge/Q9-QCC"
QCC_HOME="$QCC_DIR/Q9-QCC"
QCC="$QCC_HOME/build/qcc"
QIR68K="$QCC_DIR/Q9-BACKEND-68K/q9-qir68k/build/qir68k"
export QCC_FRONTEND_DIR="$QCC_DIR/Q9-FRONTEND-C"
export QCC_BACKEND_DIR="$QCC_DIR/Q9-BACKEND-68K"
R68="/Volumes/SSD1TB/projects/MWOS/tools/macos/bin/r68"
L68="/Volumes/SSD1TB/projects/MWOS/tools/macos/bin/l68"

SOURCE_DIR="Source"
BUILD_DIR="build_os9"
TMPDIR="$BUILD_DIR/tmp"

# Nur interessante Dateien
SOURCES=(
  "qrun_instruction.c"
  "qrun_vm.c"
  "qrun_main.c"
)

# Single-TU Ansatz: alle in qrun_all.c zusammengefasst
# oder einzelne Dateien durch Kette
ENTRY_SOURCE="$SOURCE_DIR/qrun_all.c"

echo "════════════════════════════════════════════════════════════"
echo "Q9-Run OS-9 Build-Kette"
echo "════════════════════════════════════════════════════════════"

# Überprüfe Tools
for tool in "$QCC" "$QIR68K" "$R68" "$L68"; do
  if [ ! -x "$tool" ]; then
    echo "✗ Tool nicht gefunden: $tool"
    exit 1
  fi
done

echo "✓ Alle Tools vorhanden"
echo ""

# Build-Verzeichnis
mkdir -p "$TMPDIR"

echo "[1/4] QCC Kompilierung → IR..."
$QCC \
  -DQRUN_OS9 \
  -I"$SOURCE_DIR" \
  --emit-ir \
  --tmpdir "$TMPDIR" \
  -o "$TMPDIR/qrun.ir" \
  "$ENTRY_SOURCE" 2>&1 | head -20

if [ ! -f "$TMPDIR/qrun.ir" ]; then
  echo "✗ QCC konnte nicht kompilieren"
  exit 1
fi
echo "✓ IR-Datei: $TMPDIR/qrun.ir"
wc -l "$TMPDIR/qrun.ir"

echo ""
echo "[2/4] qir68k Backend → 68k-ASM..."
$QIR68K < "$TMPDIR/qrun.ir" > "$TMPDIR/qrun.s" 2>&1 || {
  echo "✗ qir68k konnte nicht assemblen"
  head -20 "$TMPDIR/qrun.s"
  exit 1
}
echo "✓ 68k-ASM: $TMPDIR/qrun.s"
wc -l "$TMPDIR/qrun.s"

echo ""
echo "[3/4] r68 Assembler → Objektdatei..."
$R68 -a=$TMPDIR/qrun.s -o=$BUILD_DIR/qrun.r 2>&1 || {
  echo "✗ r68 konnte nicht assemblen"
  exit 1
}
echo "✓ Objektdatei: $BUILD_DIR/qrun.r"
ls -lh "$BUILD_DIR/qrun.r"

echo ""
echo "[4/4] l68 Linker..."
# Einfaches Linking (brauchen wir noch passende Startup-Code/Libs)
$L68 \
  -a=$BUILD_DIR/qrun.r \
  -o=$BUILD_DIR/qrun.mod \
  -m=$BUILD_DIR/qrun.map \
  2>&1 || {
  echo "✗ l68 konnte nicht linken"
  echo "  (Das ist OK wenn wir noch Startup-Code/Libs brauchen)"
  # Nicht abbrechen, wir wollen die Ausgabe sehen
}

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✓ Build-Kette abgeschlossen!"
echo ""
echo "Artefakte:"
ls -lh "$BUILD_DIR"/ | grep -E "\.ir|\.s|\.r|\.mod|\.map"
