#!/usr/bin/env bash
# Write the Spectre wrappers (models/fp45_{nom,ff,ss}.scs) that read the FreePDK45 PTM BSIM4 models in SPICE mode.
# usage: FP45=/path/to/FreePDK45 scripts/make_fp45_models.sh      (FP45 = directory containing ncsu_basekit)
set -e; cd "$(dirname "$0")/.."; : "${FP45:?set FP45 to the FreePDK45 directory}"
M=$FP45/ncsu_basekit/models/hspice/tran_models; mkdir -p models
for c in nom ff ss; do cat > models/fp45_$c.scs <<EOT
// FreePDK45 (PTM 45 nm, BSIM4 level 54) $c corner, VTG devices, read in Spectre's SPICE-compatibility mode
simulator lang=spice
.include "$M/models_$c/NMOS_VTG.inc"
.include "$M/models_$c/PMOS_VTG.inc"
simulator lang=spectre
EOT
done; echo "wrote models/fp45_{nom,ff,ss}.scs"
