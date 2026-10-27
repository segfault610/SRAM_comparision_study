#!/usr/bin/env python3
"""Butterfly curves and static noise margins from DC half-cell VTCs.

Input  : VTC files, either Ocean ocnPrint text ("vin  Q  Q_bar") or the hand-made CSV pairs
         (va_*_vtc.csv = Q(A), vb_*_vtc.csv = Q_bar(B)).
Method : the closed cell has B = Q and A = Q_bar, so in the (Q, Q_bar) plane
         curve 1 = (B, Q_bar(B))  and curve 2 = (Q(A), A).  The largest square that fits in a lobe has its
         diagonal along the 45-degree direction: rotate by 45 degrees, take the largest separation of the two
         curves in each lobe and divide by sqrt(2).  SNM = smaller lobe (hold, read);
         write: the cell is written when one lobe has vanished, WSNM = the remaining lobe.
Usage  : snm_analysis.py out_prefix label:mode:file[:file2] ...    (mode = hold|read|write)
"""
import csv, json, math, re, sys
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def read_text(path):
    xs, a, b = [], [], []
    for ln in open(path):
        p = ln.split()
        if len(p) == 3 and re.match(r"^[-+0-9.]", p[0]):
            try: xs.append(float(p[0])); a.append(float(p[1])); b.append(float(p[2]))
            except ValueError: pass
    return np.array(xs), np.array(a), np.array(b)

def read_csv(path):
    r = list(csv.reader(open(path)))[1:]
    return np.array([float(x[0]) for x in r]), np.array([float(x[1]) for x in r])

def load(spec):
    if len(spec) == 2:  # csv pair: Q(A), Q_bar(B)
        x, q = read_csv(spec[0]); x2, qb = read_csv(spec[1]); return x, q, qb
    return read_text(spec[0])

def lobes(vin, q, qb):
    # curve 1: x = B (=Q), y = Q_bar(B);  curve 2: x = Q(A), y = A (=Q_bar)
    c1 = (vin, qb); c2 = (q, vin)
    def rot(c):
        x, y = c; u = (x - y) / math.sqrt(2); v = (x + y) / math.sqrt(2)
        o = np.argsort(u); return u[o], v[o]
    u1, v1 = rot(c1); u2, v2 = rot(c2)
    lo, hi = max(u1.min(), u2.min()), min(u1.max(), u2.max())
    u = np.linspace(lo, hi, 4001)
    d = np.interp(u, u1, v1) - np.interp(u, u2, v2)       # >0: curve 1 above curve 2 (toward Q_bar high)
    return max(d.max(), 0) / math.sqrt(2), max((-d).max(), 0) / math.sqrt(2)

def main():
    prefix = sys.argv[1]; specs = [s.split(":") for s in sys.argv[2:]]
    res = {}
    fig, axs = plt.subplots(1, len(specs), figsize=(4.2 * len(specs), 4.2), squeeze=False)
    for ax, (label, mode, *files) in zip(axs[0], specs):
        vin, q, qb = load(files)
        vdd = vin.max()
        la, lb = lobes(vin, q, qb)
        snm = min(la, lb) if mode != "write" else max(la, lb) if min(la, lb) < 0.01 else 0.0
        res[label] = dict(mode=mode, lobe_Qbar_high=float(la), lobe_Q_high=float(lb), snm_V=float(snm),
                          write_ok=bool(min(la, lb) < 0.01) if mode == "write" else None)
        ax.plot(vin, qb, color="#2a78d6", lw=1.8, label=r"$\overline{Q}$ = f(Q)  (right inverter)")
        ax.plot(q, vin, color="#eb6834", lw=1.8, label=r"Q = f($\overline{Q}$)  (left inverter)")
        ax.plot([0, vdd], [0, vdd], color="#bbb", lw=0.7, ls="--")
        ax.set_aspect("equal"); ax.set_xlim(0, vdd); ax.set_ylim(0, vdd)
        ax.set_xlabel("Q (V)"); ax.set_ylabel(r"$\overline{Q}$ (V)")
        ax.set_title(f"{label}: {mode} butterfly\nSNM = {snm*1e3:.1f} mV  (lobes {la*1e3:.0f} / {lb*1e3:.0f} mV)", fontsize=9)
        ax.grid(alpha=0.3); ax.legend(fontsize=6.5, loc="upper right" if mode != "write" else "lower left", frameon=False)
    fig.tight_layout(); fig.savefig(prefix + ".png", dpi=170)
    json.dump(res, open(prefix + ".json", "w"), indent=1)
    for k, v in res.items():
        print(f"{k:28s} {v['mode']:6s} SNM={v['snm_V']*1e3:7.2f} mV  lobes={v['lobe_Qbar_high']*1e3:7.2f}/{v['lobe_Q_high']*1e3:7.2f} mV", "" if v['write_ok'] is None else f"write_ok={v['write_ok']}")

if __name__ == "__main__":
    main()
