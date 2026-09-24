# Q9-Run volle Build-Kette für OS-9

Stand: 2026-09-24 ✅ Phase 1-2 funktionieren, Phase 3 pending

## Build-Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: QCC Frontend                                       │
├─────────────────────────────────────────────────────────────┤
│ Input:  qrun_os9_entry.c (mit QRUN_OS9-Guard)             │
│ Tool:   qcc --emit-ir                                       │
│ Output: qrun.ir (Stack-IR, 12.703 Zeilen)                  │
│ Status: ✅ FUNKTIONIERT                                     │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 2: qir68k Backend                                     │
├─────────────────────────────────────────────────────────────┤
│ Input:  qrun.ir (Stack-IR)                                  │
│ Tool:   qir68k input.ir output.s68k -os9                   │
│ Output: qrun.s68k (Microware r68-Format, 23.599 Zeilen)   │
│ Status: ✅ FUNKTIONIERT                                     │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 3: r68 Assembler                                      │
├─────────────────────────────────────────────────────────────┤
│ Input:  qrun.s68k (68k-ASM, Microware-Format)              │
│ Tool:   r68 -a=input.s68k -o=output.r                      │
│ Output: qrun.r (68k-Objektdatei)                           │
│ Status: ⏳ PENDING (r68 nur DOS/Linux, nicht macOS)        │
└─────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 4: l68 Linker                                         │
├─────────────────────────────────────────────────────────────┤
│ Input:  qrun.r + cstart.r (Startup)                        │
│ Tool:   l68 qrun.r -o qrun.mod                             │
│ Output: qrun.mod (OS-9 ausführbares Modul)                 │
│ Status: ⏳ PENDING (abhängig von r68)                       │
└─────────────────────────────────────────────────────────────┘
              ↓
        Q9-Run Emulator
       Telnet Port 2323
```

## Build ausführen

```bash
cd /Volumes/SSD1TB/projects/Q9-Forge/Q9-Run
bash build_os9_v2.sh
```

Output:
- `build_os9/tmp/qrun.ir` — Q9 Stack-IR (12703 Zeilen)
- `build_os9/tmp/qrun.s68k` — Microware r68-ASM (23599 Zeilen)

## Nächste Schritte (Phase 3-4)

### Option A: Wine auf macOS
```bash
# r68 ist DOS-Binary; könnte via Wine laufen
wine /Volumes/SSD1TB/projects/MWOS/DOS/BIN/r68.exe -a=qrun.s68k -o=qrun.r
```

### Option B: MWOS-Toolchain unter Linux

### Option C: Online-Build
- ASM in Q9-Emulator/OS-9 selbst assemblen + linken
- Telnet zu Q9 `→ r68 qrun.s68k`

## Status Zusammenfassung

| Phase | Tool | Input | Output | Status |
|-------|------|-------|--------|--------|
| 1 | qcc | qrun_os9_entry.c | qrun.ir | ✅ |
| 2 | qir68k | qrun.ir | qrun.s68k | ✅ |
| 3 | r68 | qrun.s68k | qrun.r | ⏳ (kein macOS-Binary) |
| 4 | l68 | qrun.r | qrun.mod | ⏳ (abhängig von Phase 3) |

**Erreicht:** Volle QCC→IR→ASM-Transformation funktioniert
**Ausstehend:** ASM→Objektcode→Linking (braucht DOS/Linux oder Wine)

---
Generated: 2026-09-24
