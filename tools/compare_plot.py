#!/usr/bin/env python3
"""Overlay the hold/read/write butterflies of the two Cadence technologies (supply-normalised axes)."""
import sys; sys.path.insert(0, __file__.rsplit("/", 1)[0])
import numpy as np, matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
from snm_analysis import read_text
R = "cadence_vm/results/"
data = {"gpdk090 (1.2 V)": R + "simple_6t_sram_cell_snm_%s_tt27_vtc.txt", "FreePDK45 (1.0 V)": R + "fp45_simple_6t_sram_cell_snm_%s_tt27_vtc.txt"}
modes = [("hold", "hold_gen", "hold"), ("read", "read", "read"), ("write", "write", "write")]
col = {"gpdk090 (1.2 V)": ("#eb6834", "#eb6834"), "FreePDK45 (1.0 V)": ("#2a78d6", "#2a78d6")}
fig, axs = plt.subplots(1, 3, figsize=(12, 4.2))
for ax, (title, g, f) in zip(axs, modes):
    for tech, pat in data.items():
        v, q, qb = read_text(pat % (g if "gpdk" in tech else f)); vdd = v.max()
        ax.plot(v / vdd, qb / vdd, color=col[tech][0], lw=1.8, label=tech); ax.plot(q / vdd, v / vdd, color=col[tech][1], lw=1.8)
    ax.plot([0, 1], [0, 1], color="#bbb", ls="--", lw=0.7); ax.set_aspect("equal"); ax.set_xlim(0, 1); ax.set_ylim(0, 1)
    ax.set_title(f"{title} butterfly (axes normalised to VDD)"); ax.set_xlabel("Q / VDD"); ax.set_ylabel("Q_bar / VDD"); ax.grid(alpha=.3)
axs[0].legend(frameon=False, fontsize=8)
fig.tight_layout(); fig.savefig("analysis/compare_snm_gpdk90_fp45.png", dpi=170)
