#!/bin/bash
# Q9-Run Punkt 3-4: r68/l68 Linking im Q9-Emulator
# 3 Terminal-Fenster nötig (manuell öffnen)

set -e

QCC_DIR="/Volumes/SSD1TB/projects/Q9-Forge/Q9-QCC/Q9-QCC"
QRUN_DIR="/Volumes/SSD1TB/projects/Q9-Forge/Q9-Run"
Q9_IMAGE="/Volumes/SSD1TB/projects/Q9-Forge/Q9-Flux/Q9-Flux-68k/local_images/OS9SYS.hda"

echo "════════════════════════════════════════════════════════════"
echo "PUNKT 3-4: Q9-Run r68/l68 Linking (Q9-Emulator)"
echo "════════════════════════════════════════════════════════════"
echo ""

# Step 1: Generate ASM if missing
if [ ! -f "$QRUN_DIR/build_os9/tmp/qrun.s68k" ]; then
  echo "[1/4] ASM generieren..."
  cd "$QRUN_DIR"
  bash build_os9_v2.sh > /dev/null 2>&1
fi

ASM_SIZE=$(wc -l < "$QRUN_DIR/build_os9/tmp/qrun.s68k")
echo "✓ ASM vorhanden: $ASM_SIZE Zeilen"
echo ""

# Step 2: Copy ASM into Q9 image
echo "════════════════════════════════════════════════════════════"
echo "[2/4] ASM ins Q9-Image kopieren..."
echo "════════════════════════════════════════════════════════════"
echo ""

if [ ! -f "$Q9_IMAGE" ]; then
  echo "✗ Q9 Image nicht gefunden: $Q9_IMAGE"
  exit 1
fi

# Backup Image
BACKUP_IMAGE="${Q9_IMAGE}.backup.$(date +%s)"
if [ ! -f "$BACKUP_IMAGE" ]; then
  echo "Backup erstellen: $BACKUP_IMAGE"
  cp "$Q9_IMAGE" "$BACKUP_IMAGE"
fi

echo "Kopiere ASM ins Image..."
os9 -f "$Q9_IMAGE" copy "$QRUN_DIR/build_os9/tmp/qrun.s68k" "/CMDS/qrun.s68k" 2>&1 || {
  echo "✗ os9 copy fehlgeschlagen"
  echo "  Alternative: Mit ToolShed manuell ins Image kopieren"
  exit 1
}

echo "✓ ASM ins Image kopiert"
echo ""

# Step 3: Instructions for manual linking in Q9
echo "════════════════════════════════════════════════════════════"
echo "[3/4] MANUELLE SCHRITTE IN Q9-EMULATOR"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Terminal 1: Emulator starten"
echo "  $ cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Flux/Q9-Flux-68k"
echo "  $ ./build/native/q9.exe emu"
echo ""
echo "Terminal 2: Telnet zur Shell"
echo "  $ telnet localhost 2323"
echo ""
echo "Terminal 3: Assemblen + Linken IN Q9-SHELL:"
echo "  $ r68 -a=/CMDS/qrun.s68k -o=/CMDS/qrun.r"
echo "  $ l68 /CMDS/qrun.r -o=/CMDS/qrun.mod"
echo ""
echo "Verifizieren:"
echo "  $ ls -la /CMDS/qrun.*"
echo "  qrun.s68k  qrun.r  qrun.mod"
echo ""

# Step 4: Script to extract result
echo "════════════════════════════════════════════════════════════"
echo "[4/4] Nach dem Linking: Resultat zurückholen"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Sobald qrun.mod erzeugt ist, führe aus:"
echo ""
echo "  $ os9 -f $Q9_IMAGE copy /CMDS/qrun.mod $QRUN_DIR/build_os9/qrun.mod"
echo ""
echo "Fertig! qrun.mod ist das ausführbare OS-9-Modul."
echo ""
echo "Test auf Q9:"
echo "  $ /CMDS/qrun.mod [IR-file]"
echo ""
