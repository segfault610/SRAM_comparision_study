#!/bin/bash
# Run on the VM:  ./run_ocean.sh <ocean-file> "<var=value ...>"    (from ~/SRAM_comparision_study/cadence_vm)
# e.g.  ./run_ocean.sh ocean/snm_dc.ocn 'ocnCell="simple_6t_sram_cell_snm_read" ocnTag="tt27"'
cd "$(dirname "$0")/../vm_work" || exit 1
f=$1; shift
echo "$* load(\"../cadence_vm/$f\")" > ../cadence_vm/.drv.ocn
export DISPLAY=${DISPLAY:-:0}
mkdir -p ../cadence_vm/logs
ocean -nograph -replay ../cadence_vm/.drv.ocn -log ../cadence_vm/logs/$(basename $f .ocn).log > /dev/null 2>&1
grep -E "rror" ../cadence_vm/logs/$(basename $f .ocn).log | grep -v "extractVerify" | head
