# Punkt 3-4: Q9-Run r68/l68 Linking

**Status:** Punkt 1-2 ✅ (QCC→IR→ASM funktioniert)  
**Ausstehend:** Punkt 3-4 (ASM→OBJ→MOD braucht r68/l68)

---

## Das Problem

Microware r68 (68k-Assembler) und l68 (68k-Linker) sind nur als DOS/Linux-Binaries verfügbar:
- `/Volumes/SSD1TB/projects/MWOS/DOS/BIN/r68.exe` (Windows PE)
- Keine native macOS-Version

**Lösungsoptionen:**

### Option A: Docker/Linux-Container ✅ Empfohlen
```bash
# Dockerfile für MWOS-Umgebung schreiben
docker run --rm -v $(pwd):/work -w /work ubuntu:22.04 bash -c "
  apt-get update && apt-get install -y wine64
  cd /work
  wine /path/to/r68.exe -a=qrun.s68k -o=qrun.r
  wine /path/to/l68.exe qrun.r -o=qrun.mod
"
```

### Option B: Wine auf macOS
```bash
brew install wine
wine /Volumes/SSD1TB/projects/MWOS/DOS/BIN/r68.exe -a=qrun.s68k -o=qrun.r
```
(Nicht getestet; erfordert Wine-Setup)

### Option C: Im Q9-Emulator assemblen ✅ Native
1. ASM-Datei ins Q9-Image kopieren
2. Im Q9-Shell: `r68 -a=qrun.s68k -o=qrun.r`
3. Linken: `l68 qrun.r -o=qrun.mod`

**Dies ist die beste Lösung – keine externe Toolchain nötig!**

### Option D: Linux-VM oder SSH-Zugang
Wenn du Zugang zu einem Linux-System mit MWOS-Tools hast:
```bash
scp qrun.s68k user@linux:/tmp/
ssh user@linux "cd /tmp && r68 -a=qrun.s68k -o=qrun.r && l68 qrun.r -o=qrun.mod"
scp user@linux:/tmp/qrun.mod .
```

---

## Schritt für Schritt: Option C (Q9-Emulator)

### 1. ASM-Datei vorbereiten
```bash
cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run
bash build_os9_v2.sh
# Output: build_os9/tmp/qrun.s68k (23.599 Zeilen)
```

### 2. Q9-Emulator booten
```bash
cd /Volumes/SSD1TB/projects/Q9-Flux/Q9-Flux-68k
./build/native/q9.exe emu
```

### 3. Terminal 2: Datei transferieren
```bash
# Entweder via os9-Tool ins Image kopieren
os9 -f local_images/OS9SYS.hda copy /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/tmp/qrun.s68k /CMDS/qrun.s68k

# Oder via ToolShed
cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run
toolshed -f ../../Q9-Flux/local_images/OS9SYS.hda write build_os9/tmp/qrun.s68k /CMDS/
```

### 4. Terminal 3: Im Q9-Shell assemblen + linken
```bash
telnet localhost 2323

$ r68 -a=/CMDS/qrun.s68k -o=/CMDS/qrun.r
$ l68 /CMDS/qrun.r -o=/CMDS/qrun.mod

# Überprüfen:
$ dir /CMDS/qrun.*
qrun.s68k  qrun.r  qrun.mod
```

### 5. Ergebnis zurück auf Host
```bash
# Auf Host Terminal 2:
os9 -f local_images/OS9SYS.hda copy /CMDS/qrun.mod /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/
```

---

## Automatisiertes Makefile

Das Makefile `Makefile.os9` dokumentiert die volle Kette:
```bash
make -f Makefile.os9 asm      # Phase 2: Generate ASM
make -f Makefile.os9 obj      # Phase 3: Assemble (needs r68)
make -f Makefile.os9 mod      # Phase 4: Link (needs l68)
make -f Makefile.os9 all      # All phases
```

---

## Artefakte

Nach erfolgreichem Linking:
- `qrun.mod` — Ausführbares OS-9-Modul
- `qrun.map` — Symbol-Map für Debugging

Dann kann qrun.mod auf Q9 getestet werden:
```bash
$ /CMDS/qrun.mod [IR-files...]
```

---

## Status

| Phase | Tool | Input | Output | macOS | Linux |
|-------|------|-------|--------|-------|-------|
| 1 | qcc | qrun_os9_entry.c | qrun.ir | ✅ | ✅ |
| 2 | qir68k | qrun.ir | qrun.s68k | ✅ | ✅ |
| 3 | r68 | qrun.s68k | qrun.r | ⏳ (Docker) | ✅ |
| 4 | l68 | qrun.r | qrun.mod | ⏳ (Docker) | ✅ |

**Empfehlung:** Option C (Q9-Emulator assemblen) ist am einfachsten!

---
Generated: 2026-09-24
