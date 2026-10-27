#!/usr/bin/env bash
# Whole gpdk090 flow for the single 6T cell, from a clean checkout. Run from cadence_vm/ on a machine with Virtuoso,
# Spectre and Assura. Needs: a work directory with a cds.lib that defines gpdk090, analogLib, basic and
# version_90nm_sram_puf (see config/cds.lib.template), PDK = gpdk090 kit directory.
#   ./run_gpdk090.sh <workdir>            e.g. ./run_gpdk090.sh ../vm_work
# Steps: 1 SNM test cells (schematics)   2 SNM DC sweeps   3 layout   4 Assura DRC/LVS/RCX   5 pre/post transient
set -e
HERE=$(cd "$(dirname "$0")" && pwd); W=$(cd "${1:?workdir}" && pwd); cd "$W"
export PDK=${PDK:-$HOME/cadence/gpdk090_v4.6}; export DISPLAY=${DISPLAY:-:0}
ln -sfn "$HERE/skill" skill
. "$HERE/scripts/env.sh"
echo "[1] SNM schematics";   virtuoso -nograph -replay skill/run_snm_cells.il -log snm.log >/dev/null 2>&1
echo "[2] SNM sweeps";       for c in hold_gen read write; do "$HERE/run_ocean.sh" ocean/snm_dc.ocn "ocnCell=\"simple_6t_sram_cell_snm_$c\" ocnTag=\"tt27\""; done
echo "[3] layout";           virtuoso -nograph -replay skill/run_lay_cell.il -log lay.log >/dev/null 2>&1
echo "[4] Assura";           for k in drc lvs rcx; do "$HERE/scripts/assura_run.sh" $k simple_6t_sram_cell | tail -2; done
echo "    DRC errors: $(grep -c '^Rule No' runs/simple_6t_sram_cell_drc/*.err || true)"; grep -h "Schematic and Layout" runs/simple_6t_sram_cell_lvs/*.csm || echo "    LVS: see runs/simple_6t_sram_cell_lvs"
echo "[5] transient";        "$HERE/run_ocean.sh" ocean/tb_tran.ocn 'ocnView="schematic" ocnTag="pre"'; "$HERE/run_ocean.sh" ocean/tb_tran.ocn 'ocnView="av_extracted" ocnTag="post"'
echo "done; results in $HERE/results (analyse with ../tools/*.py on any machine with python3 + numpy + matplotlib)"
