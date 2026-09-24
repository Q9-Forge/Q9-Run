# Option B: Docker/Linux Setup für r68/l68

Da macOS keinen nativen r68/l68 hat, gibt es mehrere Optionen:

---

## Option B1: WSL2 (Windows Subsystem for Linux)

Falls du Windows mit WSL2 hast:

```bash
# WSL2 in Linux-Shell
wsl

# Installiere MWOS-Tools (falls verfügbar)
sudo apt-get install -y wine64

# Kopiere die Dateien
cp /mnt/c/path/to/qrun.s68k .
cp /Volumes/SSD1TB/projects/MWOS/DOS/BIN/r68.exe .

# Führe das Linux-Skript aus
bash linking_on_linux.sh qrun.s68k
```

---

## Option B2: Docker auf Mac (starte Docker Desktop)

```bash
# Docker starten
open /Applications/Docker.app
sleep 10  # Warte auf Startup

# Container bauen
docker build -f /tmp/Dockerfile.q9run -t q9-run-linker .

# Linking durchführen
docker run --rm -v $(pwd):/work q9-run-linker bash -c "
  r68 -a=/work/build_os9/tmp/qrun.s68k -o=/work/build_os9/qrun.r
  l68 /work/build_os9/qrun.r -o=/work/build_os9/qrun.mod
"
```

---

## Option B3: Linux-VM oder SSH-Server

Falls du Zugang zu einem Linux-System hast:

```bash
# Vom Host Mac:
scp build_os9/tmp/qrun.s68k user@linux:/tmp/

# Auf Linux-Server:
ssh user@linux << 'EOF'
cd /tmp
r68 -a=qrun.s68k -o=qrun.r
l68 qrun.r -o=qrun.mod
EOF

# Ergebnis zurück:
scp user@linux:/tmp/qrun.mod build_os9/
```

---

## Option B4: Installation mit Homebrew (macOS)

Wine-Installation versuchen:

```bash
# Install Wine
brew install wine

# Dann:
wine /Volumes/SSD1TB/projects/MWOS/DOS/BIN/r68.exe \
  -a=build_os9/tmp/qrun.s68k \
  -o=build_os9/qrun.r

wine /Volumes/SSD1TB/projects/MWOS/DOS/BIN/l68.exe \
  build_os9/qrun.r \
  -o=build_os9/qrun.mod
```

(Warnung: Wine auf macOS kann langsam sein)

---

## Was brauchst du?

**Minimal:**
- Linux-System mit r68/l68 Tools (oder Wine)
- ASM-Datei: `build_os9/tmp/qrun.s68k`
- Startup-Code + Libraries (MWOS-Package)

**Skripte zur Nutzung:**
- `linking_on_linux.sh` — Automatisiertes r68/l68-Skript
- `Makefile.os9` — Makefile-Version
- `PUNKT3-4-MANUAL.md` — Manuelle Steps

---

## Quick-Test

```bash
# Falls Linux/Wine verfügbar:
cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run
bash linking_on_linux.sh build_os9/tmp/qrun.s68k build_os9

# Falls erfolgreich:
ls -lh build_os9/qrun.mod
```

---

**Empfehlung:** Option B2 (Docker) oder B3 (Linux-SSH) sind am zuverlässigsten.

Generated: 2026-09-24
