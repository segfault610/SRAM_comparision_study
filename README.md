# SRAM comparison study — single 6T bit-cell in gpdk090 and FreePDK45 (Cadence), vs sky130

Your original content is untouched: `cds.lib`, `cds.lib.copy`, `gpdk90/version_90nm_sram_puf/*`, the CSVs and JPGs.
Everything new lives in `cadence_vm/`, `tools/`, `analysis/`, `docs/`.

| folder | content |
|---|---|
| `cadence_vm/skill/`, `skill_fp45/` | SKILL generators: SNM test cells, layouts, FreePDK45 cell + testbench (+ small dump/debug helpers) |
| `cadence_vm/ocean/` | Ocean/Spectre scripts: `snm_dc.ocn` (butterfly sweeps), `tb_tran.ocn` (your transient testbench, pre/post layout) |
| `cadence_vm/scripts/` | `assura_run.sh drc|lvs|rcx <cell>` (batch Assura, no GUI), `make_fp45_models.sh`, `env.sh` |
| `cadence_vm/run_gpdk090.sh` | whole gpdk090 flow in one command (≈ 80 s) |
| `cadence_vm/lib_additions/` | the generated cells (OA) — **staging copies, not merged into your library**: `gpdk90/` (3 SNM schematics, layout + av_extracted views of `simple_6t_sram_cell`), `freepdk45/fp45_sram6t` (complete library) |
| `cadence_vm/results/`, `reports/`, `screenshots/` | VTC/waveform text files, Assura run files + LVS report, GDS files, GUI screenshots |
| `tools/` | `snm_analysis.py` (butterfly + SNM), `tb_analysis.py` (timing/energy), `compare_plot.py`, `fp45_drc.sh` (not yet run, see below) |
| `analysis/` | butterfly plots, JSON/TXT metrics |
| `docs/` | `comparison.md` (**the three-technology table**), `issues_log.md`, `sky130_status.md` |

## Reproduce gpdk090 on the university server (Virtuoso 6.1.8)
1. `git clone` this repo; make a **separate work directory** (do not touch your own cds.lib): copy `cadence_vm/config/cds.lib.template`, fill in paths
   (gpdk090 kit, `version_90nm_sram_puf`, plus `avTech` from the Assura install for DRC/LVS).
2. `export PDK=<gpdk090 kit dir>`; merge `lib_additions/gpdk90/*` into the library, *or* simply let the flow regenerate
   everything: `cd cadence_vm && ./run_gpdk090.sh <workdir>` (needs Virtuoso, Spectre, Assura on the PATH; `DISPLAY` set for the kit's CDF callbacks).
3. Analysis (any python3 with numpy/matplotlib): `python3 tools/snm_analysis.py analysis/my "hold:hold:cadence_vm/results/<file>_vtc.txt" …`, `python3 tools/tb_analysis.py <wave.txt>` (set `VDD=` for the supply).
4. Differences to expect on 6.1.8 vs the 6.1.5 used here: none known; if `schCreateWireLabel` or the Ocean `envOption('switchViewList …)` complain, the same calls exist in 6.1.8. Assura 4.1 vs your server's version: only the `techRuleSets` lookup (`?technology "gpdk090"`) matters.

## FreePDK45
Schematic + simulation done (kit symbols, PTM models through Spectre). Layout drawn as rectangles and exported (`reports/freepdk45/simple_6t_sram_cell.gds`);
**DRC/LVS not run yet**: it needs the KLayout FreePDK45 deck (`github.com/laurentc2/FreePDK45_for_KLayout`), third-party Ruby DSL code
that my environment declined to run. Either run `tools/fp45_drc.sh freepdk45_src/simple_6t_sram_cell.gds simple_6t_sram_cell out/` yourself
after reading the deck, or tell me to run it. There is no parasitic extraction tool for FreePDK45 on the VM.
Rebuild: `FP45=<dir with ncsu_basekit> cadence_vm/scripts/make_fp45_models.sh`, then `skill_fp45/fp45_cells.il`, `skill_fp45/run_lay.il`, `run_ocean_fp45.sh`.
