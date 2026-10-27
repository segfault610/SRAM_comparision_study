# Single 6T bit-cell: sky130 vs gpdk090 vs FreePDK45

Same cell, three technologies. All numbers are **nominal (tt, 27 °C)**, one cell, SPICE-level.
sky130 numbers come from the PUF project (`SRAM_PUF/results/cell/summary.md`, ngspice); gpdk090 and FreePDK45 numbers
from this repo (Spectre, Virtuoso 6.1.5 on the VM). Plots: `analysis/gpdk90_snm.png`, `analysis/fp45_snm.png`,
`analysis/compare_snm_gpdk90_fp45.png`.

| | sky130 (PUF project) | gpdk090 (this repo) | FreePDK45 (this repo) |
|---|---|---|---|
| supply | 1.8 V | 1.2 V | 1.0 V |
| L / sizing (PD / PG / PU) | 0.15 µm; 0.84 / 0.42 / 0.42 µm (β = 2) | 0.10 µm; 120 / 120 / 120 nm (β = 1, your cell) | 50 nm; 90 / 90 / 90 nm (β = 1, same style) |
| **hold SNM** | 707 mV (39 % of VDD) | **318.8 mV** (26.6 %) — your CSV: 318.81, regenerated: 318.75 | **358.8 mV** (35.9 %) |
| **read SNM** (WL = VDD, BL = BLB = VDD) | 416 mV (23 %) | **55.0 mV** (4.6 %) | **154.9 mV** (15.5 %) |
| **write** (butterfly, BL = 0, BLB = VDD, WL = VDD) | write margin 628 mV (different metric, see note) | one lobe vanishes → write OK; remaining lobe **536 mV** | write OK; remaining lobe **394 mV** |
| write time (WL 50 % → Q 50 %, ideal BL drive) | – | 31 ps pre / 40 ps post-layout | 42 ps (pre) |
| read disturb, peak Q_bar during read of a stored 1 | – | 347 mV pre / 348 mV post | 195 mV |
| hold leakage (supply current) | 24 pA | 28 nA pre / 48 nA post-layout | 2.4 nA |
| layout | 2.80 × 4.67 µm (array pitch 2.80 × 4.10 = 11.5 µm²) | ≈ 4.5 × 3.8 µm incl. rails and M2 (generator layout, not area-optimised) | 1.28 × 1.62 µm = 2.1 µm² (hand-placed rectangles) |
| DRC / LVS / extraction | Magic + KLayout DRC 0, LVS match, PEX done | **Assura DRC 0, LVS match, RCX done** (`av_extracted`, post-layout simulated) | layout drawn and exported to GDS; **DRC/LVS/PEX not run** (see issues log: third-party KLayout deck blocked, no extraction tool for this PDK on the VM) |

Notes for reading the table
* The **read SNM of 55 mV for gpdk090 is a property of the cell you drew** (all six devices equal: β = 1, pull-up
  ratio 1). It is positive but tiny; a pull-down of 240 nm (β = 2) is the usual fix (my earlier schematic experiments
  used that and gave ~240 mV read disturb → see `SRAM_PUF_Cadence`). FreePDK45 has the same β = 1 but its PTM devices
  give 155 mV (reason not investigated; PTM device ratios and supply differ).
* sky130 "write margin" in the PUF project is a bit-line sweep margin, not the butterfly lobe used here; the two are not
  directly comparable. Hold and read SNM use the same definition everywhere (largest square in the smaller lobe).
* Leakage: gpdk090 hold leakage rises 28 → 48 nA from schematic to extracted view. Cause not isolated; the extracted
  netlist replaces the CDF junction areas/perimeters by values measured from the layout, which is the first suspect.
* The 100× difference in read supply energy (26 fJ vs 0.26 fJ) comes from the crowbar current of the gpdk090 cell while
  Q_bar is lifted to 347 mV during the read (low read SNM); window 7.8–10.8 ns, ideal bit-line sources are not counted.
* gpdk090 and FreePDK45 results are for **one** corner/temperature with no Monte-Carlo; sky130 additionally has PVT and MC.
