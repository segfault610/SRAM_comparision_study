#!/bin/bash
# push the cadence_vm tree (scripts only) to the VM copy:  ./push.sh
V=${V:-/tmp/claude-1000/-home-jonny-Desktop-Code-VLSI-System-Design-SRAM-PUF/06c7ff35-1b78-495b-9549-3754d03cc6d8/scratchpad/vm/vm.sh}
cd "$(dirname "$0")" && tar czf - --exclude=results --exclude=logs --exclude='*.txt' . | $V run 'mkdir -p ~/SRAM_comparision_study/cadence_vm && cd ~/SRAM_comparision_study/cadence_vm && tar xzmf -'
