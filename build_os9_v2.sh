#!/bin/bash
# Q9-Run volle Build-Kette - ausgeführt von Q9-QCC/Q9-QCC/ aus
# wegen hardcoded Pfade in QCC binaries
#
# Mehrdatei-Build (statt eines einzigen riesigen qrun_all.c-Moduls):
# qrun_ir.c/qrun_vm.c/qrun_main.c werden EINZELN zu eigenen kleinen
# ROF-Modulen assembliert (-part -unit=qrun), der gemeinsame 68k-Core/
# I/O-Anker (tc_mul_i32 etc.) traegt nur qrun_ir_os9.c (-runtime). Ein
# einziges Modul aus allem zusammen ueberschreitet die bsr-Wortform-
# Reichweite (+-32K), die qr68k lokal beim Assemblieren aufloest -- erst
# als getrennte Module werden die Aufrufe zu externen Referenzen, die
# ql68 -a bei Bedarf ueber eine Sprungtabelle bindet (siehe
# Q9-BACKEND-68K/q9-ql68k/README.md, Abschnitt "Die Sprungtabelle (-a)").

set -e

cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-QCC/Q9-QCC

QCC="./build/qcc"
QRUN_DIR="/Volumes/SSD1TB/projects/Q9-Forge/Q9-Run"
BUILD_DIR="$QRUN_DIR/build_os9"
TMPDIR="$BUILD_DIR/tmp"

QR68="../Q9-BACKEND-68K/q9-qr68k/build/qr68k"
QL68="../Q9-BACKEND-68K/q9-ql68k/build/ql68k"
QIR68K="../Q9-BACKEND-68K/q9-qir68k/build/qir68k"
QCLIB="../Q9-BACKEND-68K/q9-qclib/build/qclib.l"
CSTART_SRC="../runtime/os9/q9_cstart.a"
QDEFS_SRC="../runtime/os9/q9defs.d"

echo "════════════════════════════════════════════════════════════"
echo "Q9-Run OS-9 Build-Kette (v3, Mehrdatei)"
echo "════════════════════════════════════════════════════════════"
echo "Working dir: $(pwd)"
echo ""

mkdir -p "$TMPDIR"

# Modulname -> ob es den gemeinsamen Runtime-Anker traegt (-runtime)
MODULES="qrun_ir qrun_os9support qrun_vmhelpers qrun_vm qrun_main"
RUNTIME_MODULE="qrun_ir"

for mod in $MODULES; do
  echo "[$mod 1/3] QCC Kompilierung: Source/${mod}_os9.c → IR"
  $QCC \
    --emit-ir \
    --tmpdir "$TMPDIR" \
    -o "$TMPDIR/$mod.ir" \
    "$QRUN_DIR/Source/${mod}_os9.c" || {
    echo "✗ QCC Fehler ($mod)"
    exit 1
  }

  echo "[$mod 2/3] qir68k: IR → 68k-ASM (-part -unit=qrun$( [ "$mod" = "$RUNTIME_MODULE" ] && echo " -runtime" ))"
  RTFLAG=""
  [ "$mod" = "$RUNTIME_MODULE" ] && RTFLAG="-runtime"
  $QIR68K "$TMPDIR/$mod.ir" "$TMPDIR/$mod.s68k" -os9 -part $RTFLAG -unit=qrun || {
    echo "✗ qir68k Fehler ($mod)"
    tail -20 "$TMPDIR/$mod.s68k" 2>/dev/null || echo "  (keine Ausgabe)"
    exit 1
  }

  echo "[$mod 3/3] qr68k: 68k-ASM → ROF-Objekt"
  $QR68 "$TMPDIR/$mod.s68k" -o="$TMPDIR/$mod.r" || {
    echo "✗ qr68k Fehler ($mod)"
    exit 1
  }
  echo "✓ $mod.r erzeugt"
  echo ""
done

echo "[cstart] qr68k: Laufzeiteinstieg q9_cstart.a → ROF-Objekt"
cp "$CSTART_SRC" "$QDEFS_SRC" "$TMPDIR/"
(cd "$TMPDIR" && "$OLDPWD/$QR68" q9_cstart.a -o=q9_cstart.r) || {
  echo "✗ qr68k Fehler (q9_cstart.a)"
  exit 1
}
echo "✓ q9_cstart.r erzeugt"

echo ""
echo "[Link] ql68 -a: Binden zu OS-9-Modul (gegen qclib.l)"
$QL68 -a "$TMPDIR/q9_cstart.r" "$TMPDIR/qrun_main.r" "$TMPDIR/qrun_vm.r" \
  "$TMPDIR/qrun_vmhelpers.r" "$TMPDIR/qrun_os9support.r" "$TMPDIR/qrun_ir.r" \
  -l="$QCLIB" -O="$TMPDIR/qrun.mod" || {
  echo "✗ ql68 Fehler"
  exit 1
}
echo "✓ qrun.mod erzeugt"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ Build-Kette erfolgreich!"
echo ""
echo "Artefakte:"
ls -lh "$TMPDIR"/*.mod "$TMPDIR"/*.r 2>/dev/null
