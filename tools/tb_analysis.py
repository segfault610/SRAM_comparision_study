#!/usr/bin/env python3
"""Timing/energy extraction from the transient waves of tb_simple_6t_sram_cell (pre/post layout).
Columns: t, WL, BL_bar, BL, Q, Q_bar, I(Vdd).   Usage: tb_analysis.py wave.txt [wave2.txt ...]"""
import re, sys, numpy as np
def load(p):
    rows=[[float(x) for x in l.split()] for l in open(p) if re.match(r"^\s*[-+0-9.]", l) and len(l.split())==7]
    return np.array(rows).T
def cross(t,y,lvl,rising,t0=0,t1=1e9):
    m=(t>=t0)&(t<=t1); tt=t[m]; yy=y[m]-lvl
    s=np.where((yy[:-1]<0)&(yy[1:]>=0) if rising else (yy[:-1]>0)&(yy[1:]<=0))[0]
    return tt[s[0]]+(tt[s[0]+1]-tt[s[0]])*(-yy[s[0]])/(yy[s[0]+1]-yy[s[0]]) if len(s) else None
for p in sys.argv[1:]:
    t,wl,blb,bl,q,qb,i=load(p)
    print("==",p)
    r={}
    twl=cross(t,wl,0.6,True,0.8e-9,3e-9)
    r["write1_delay_ps"]=1e12*(cross(t,q,0.6,True,twl,4e-9)-twl)
    twl2=cross(t,wl,0.6,True,7.5e-9,9e-9)
    m=(t>twl2)&(t<10.2e-9)
    r["read_disturb_QB_peak_mV"]=1e3*qb[m].max(); r["read_Q_min_V"]=q[m].min()
    r["Q_after_write_V"]=q[np.argmin(abs(t-4e-9))]; r["Q_after_read_V"]=q[np.argmin(abs(t-11.5e-9))]
    def energy(a,b):
        m=(t>=a)&(t<=b); return -np.trapezoid(1.2*i[m],t[m])      # supply current is negative when sourced
    r["write_energy_fJ"]=1e15*energy(0.8e-9,3.8e-9)
    r["read_energy_fJ"]=1e15*energy(7.8e-9,10.8e-9)
    r["leak_hold_nA"]=1e9*abs(i[np.argmin(abs(t-6e-9))])
    for k,v in r.items(): print(f"  {k:28s} {v:10.4g}")
