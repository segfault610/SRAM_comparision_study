#!/bin/bash
# FreePDK45 variant of run_ocean.sh: runs from vm_work_fp45 with the PTM model wrapper
cd "$(dirname "$0")/../vm_work_fp45" || exit 1
f=$1; shift
echo "ocnLib=\"fp45_sram6t\" ocnPre=\"fp45_\" ocnVdd=1.0 ocnModelFile=\"$HOME/SRAM_comparision_study/cadence_vm/models/fp45_nom.scs\" $* load(\"../cadence_vm/$f\")" > ../cadence_vm/.drv45.ocn
export DISPLAY=${DISPLAY:-:0}
mkdir -p ../cadence_vm/logs
ocean -nograph -replay ../cadence_vm/.drv45.ocn -log ../cadence_vm/logs/fp45_$(basename $f .ocn).log > /dev/null 2>&1
grep -E "rror" ../cadence_vm/logs/fp45_$(basename $f .ocn).log | grep -v "extractVerify" | head
