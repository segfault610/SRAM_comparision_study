# sky130 SRAM-PUF flow (this PC): what is done / not done

Read from the repository `SRAM_PUF` (HEAD `bb762b2`, working tree clean) — **nothing was re-run**.

**Done, committed and pushed (GitHub `segfault610/SRAM_PUF`)**
* front end: xschem schematics (hand-wired ones untouched), testbenches, ngspice characterisation (PVT, Monte-Carlo, SNM, write margin, read current)
* PUF analysis: power-up and read-current PUF, 24-chip campaigns (pre-layout and post-layout), BER vs T/VDD, MMD stabilisation
* layout: bit-cell v2, 16×16 array, 25 blocks, both macros (`sram_puf_16x16`, `sram_16x16`): **Magic DRC 0, KLayout DRC 0, LVS match for all**
* parasitic extraction and post-layout simulation of both macros (SRAM: 0 errors; PUF keys generated)
* documentation, layout guide (MD + PDF), issues log (48 entries), `make pd-all`, backups

**Not done / open (all listed by the project itself)**
* bit-line capacitance of the column-pair block is the main post-layout penalty → proposed re-floorplan (precharge + SAs under the array), then re-run post-layout PUF statistics
* post-layout *read-current* PUF statistics with extracted periphery (power-up PUF was done)
* digital PUF controller / chip level in LibreLane (installed, smoke-tested only); no pad ring
* poly word-lines not strapped (≈ 0.2 ns extra at far end); cell area not optimised (logic rules, 11.5 µm² pitch)
* analog noise only modelled (kT/C), single 16×16 macro
* documentation inconsistency: `docs/characterization.md` "Known limitations" still says *"No layout / parasitic extraction"* — outdated since the layout work; should be edited when you next touch the repo (not changed here)
