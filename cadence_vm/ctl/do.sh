#!/bin/bash
# on the VM:  ctl/do.sh "<skill code>" [screenshot.png]   - runs SKILL in the GUI Virtuoso, then screenshots the screen
C=~/SRAM_comparision_study/cadence_vm/ctl
rm -f $C/done; printf '%s\n' "$1" > $C/cmd.il.tmp; mv $C/cmd.il.tmp $C/cmd.il
for i in $(seq 1 40); do [ -f $C/done ] && break; sleep 1; done
if [ -n "$2" ]; then sleep 3; DISPLAY=:0 python $C/shot.py "$2"; fi
