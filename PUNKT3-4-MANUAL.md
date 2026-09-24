# Punkt 3-4: Manuelle Anleitung (Q9-Emulator)

**ASM-Datei:** `/Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/tmp/qrun.s68k` (407 KB, 23.599 Zeilen)

---

## 3 Terminal-Fenster öffnen

### Terminal 1: Q9-Emulator starten

```bash
cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Flux/Q9-Flux-68k
./build/native/q9.exe emu
```

Warten auf:
```
An OS-9 kernel module was found at $FE0158AC
A valid OS-9 bootfile was found.
pd: can't open current directory. $
```

---

### Terminal 2: Datei ins Emulator-RAM-Disk kopieren

Während der Emulator läuft: Öffne eine neue Shell und erstelle einen temp-File-Server oder copy-Prozess. 

**Option A: Über /tmp direkt (einfachste Methode)**

```bash
# Im Emulator selbst (Terminal 3 Telnet):
$ mount /tmp
$ cp /tmp/qrun.s68k /CMDS/qrun.s68k
```

Oder vom Host (Terminal 2):
```bash
# Host: Datei wo Emulator sie findet
cp /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/tmp/qrun.s68k /tmp/qrun.s68k
```

Dann im Emulator-Shell:
```bash
$ mount /tmp
$ ls /tmp/qrun.s68k
$ cp /tmp/qrun.s68k /CMDS/
```

**Option B: Über Telnet direkt eingeben (aufwändig)**
- Base64-encode der Datei
- Im Q9-Shell per `uuencode` dekodieren

---

### Terminal 3: Telnet zu Q9-Shell

```bash
telnet localhost 2323
```

Dann:
```bash
$ r68 -a=/CMDS/qrun.s68k -o=/CMDS/qrun.r
$ l68 /CMDS/qrun.r -o=/CMDS/qrun.mod
$ ls -la /CMDS/qrun.*
```

---

## Detaillierte Schritte

### Step 1: Emulator-Shell Vorbereitung

```bash
$ dir /CMDS
# Falls CMDS nicht existiert:
$ makdir /CMDS
```

### Step 2: ASM-Datei transferieren

**Am sichersten: über /tmp**

Terminal 2 (Host):
```bash
cp /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/tmp/qrun.s68k /tmp/
chmod 777 /tmp/qrun.s68k
```

Terminal 3 (Q9-Telnet):
```bash
$ mount /tmp
$ cp /tmp/qrun.s68k /CMDS/qrun.s68k
$ ls -la /CMDS/qrun.s68k
```

### Step 3: Assemblen

```bash
$ r68 -a=/CMDS/qrun.s68k -o=/CMDS/qrun.r
```

Output sollte sein:
```
r68 V3.1
Assembling qrun.s68k...
[lines assembled]
Linking...
[linking messages]
```

Falls Fehler: Die ASM-Datei ist Microware-r68-Format (mit `nam`, `psect`, `ends`). Das sollte direkt funktionieren.

### Step 4: Linken

```bash
$ l68 /CMDS/qrun.r -o=/CMDS/qrun.mod
```

Output sollte sein:
```
Linker...
[linking symbols]
[output size]
```

Falls Fehler wegen fehlender Libraries:
```bash
$ l68 /CMDS/qrun.r -o=/CMDS/qrun.mod -l=/Lib/os9.l -l=/Lib/sys.l
```

### Step 5: Überprüfen

```bash
$ ls -la /CMDS/qrun.*
qrun.s68k      407370  (input)
qrun.r         [size]  (assembled)
qrun.mod       [size]  (linked!)
```

---

## Ergebnis zurück auf Host

Terminal 2 (Host), nach erfolgreichem Linking:

```bash
# Telnet-Shell kopiert Datei zurück:
# (oder manuell aus Q9-Image extrahieren)

# Falls Shared /tmp genutzt:
$ cp /CMDS/qrun.mod /tmp/

# Dann Host:
cp /tmp/qrun.mod /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/

# Oder direkt vom Image extrahieren:
os9 copy /CMDS/qrun.mod /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run/build_os9/
```

---

## Testen

Nach erfolgreichem Linking in Q9-Shell:

```bash
$ /CMDS/qrun.mod /path/to/test.ir
```

---

## Debugging

**Fehler: "Assembler Error at line XXX"**
- ASM-Format-Fehler
- Überprüfe qrun.s68k auf Syntaxfehler (oder regeneriere)

**Fehler: "Undefined symbol XXX"**
- Link-Fehler (fehlende Libraries)
- Nutze `-l=/Lib/...` Flags

**Hang beim Linking**
- Große Datei (qrun ist ~24K Zeilen)
- Warte länger oder versuche auf Linux-System

---

## Kommandos Quick-Ref

```bash
# Nur ASM vom Host generieren:
cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run
bash build_os9_v2.sh

# ASM-Größe:
wc -l build_os9/tmp/qrun.s68k

# Im Q9-Shell:
r68 -a=/CMDS/qrun.s68k -o=/CMDS/qrun.r
l68 /CMDS/qrun.r -o=/CMDS/qrun.mod
ls -la /CMDS/qrun.*
/CMDS/qrun.mod [IR-file]
```

---

**Hinweis:** Falls Steps zu komplex: Alternativ auf Linux-System mit echtem MWOS-Toolchain durchführen.

Generated: 2026-09-24
