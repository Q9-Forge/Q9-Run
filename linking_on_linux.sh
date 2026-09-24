#!/bin/bash
# Q9-Run r68/l68 Linking auf Linux durchführen
# Nutzer: Diese Datei auf einem Linux-System mit MWOS-Tools ausführen

set -e

echo "════════════════════════════════════════════════════════════"
echo "Q9-Run Punkt 3-4: r68/l68 Linking (Linux-Version)"
echo "════════════════════════════════════════════════════════════"
echo ""

# Configuration
ASM_FILE="${1:-qrun.s68k}"
BUILD_DIR="${2:-build_os9}"
STARTUP_CODE="${3:-/path/to/q9_cstart.r}"
QCLIB="${4:-/path/to/qclib.l}"

echo "Input:"
echo "  ASM: $ASM_FILE"
echo "  Build Dir: $BUILD_DIR"
echo "  Startup: $STARTUP_CODE"
echo "  Library: $QCLIB"
echo ""

# Prüfe Inputs
if [ ! -f "$ASM_FILE" ]; then
  echo "✗ ASM-Datei nicht gefunden: $ASM_FILE"
  exit 1
fi

mkdir -p "$BUILD_DIR"

echo "[1/2] r68 Assembler..."
echo "  Command: r68 -a=$ASM_FILE -o=$BUILD_DIR/qrun.r"
echo ""

r68 -a="$ASM_FILE" -o="$BUILD_DIR/qrun.r" || {
  echo "✗ r68 fehlgeschlagen"
  echo "  Fehler: $(tail -5 "$BUILD_DIR/qrun.r" 2>/dev/null || echo 'unknown')"
  exit 1
}

if [ -f "$BUILD_DIR/qrun.r" ]; then
  echo "✓ Object-Datei erzeugt:"
  ls -lh "$BUILD_DIR/qrun.r"
else
  echo "✗ qrun.r wurde nicht erzeugt"
  exit 1
fi

echo ""
echo "[2/2] l68 Linker..."
echo "  Command: l68 $STARTUP_CODE $BUILD_DIR/qrun.r -l=$QCLIB -o=$BUILD_DIR/qrun.mod"
echo ""

l68 "$STARTUP_CODE" "$BUILD_DIR/qrun.r" \
  -l="$QCLIB" \
  -o="$BUILD_DIR/qrun.mod" \
  -m="$BUILD_DIR/qrun.map" || {
  echo "✗ l68 fehlgeschlagen"
  echo "  Fehler: $(tail -5 "$BUILD_DIR/qrun.mod" 2>/dev/null || echo 'unknown')"
  exit 1
}

if [ -f "$BUILD_DIR/qrun.mod" ]; then
  echo "✓ Modul erzeugt:"
  ls -lh "$BUILD_DIR/qrun.mod"
  echo "  Map: $BUILD_DIR/qrun.map"
else
  echo "✗ qrun.mod wurde nicht erzeugt"
  exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Linking erfolgreich!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Ergebnis: $BUILD_DIR/qrun.mod"
echo ""
echo "Nächste Schritte:"
echo "1. qrun.mod zurück zum Host kopieren"
echo "2. Ins Q9-Image laden"
echo "3. Testen: /CMDS/qrun.mod [IR-file]"
echo ""
