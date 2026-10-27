#!/usr/bin/env bash
# Batch Assura run:  scripts/assura_run.sh drc|lvs|rcx <cell> [layout-view]
# Writes runs/<cell>_<kind>/<cell>_<kind>.rsf from the kit rule files and runs Assura without the GUI.
set -euo pipefail
. "$(dirname "$0")/env.sh"
kind=$1; cell=$2; view=${3:-layout}
run=${cell}_${kind}; dir=runs/$run; mkdir -p "$dir"
common="?inputLayout (\"df2\" \"$SP_LIB\") ?cellName \"$cell\" ?viewName \"$view\" ?technology \"gpdk090\" ?techLib \"$ASSURA_TECH\"
 ?runName \"$run\" ?workingDirectory \"$PWD/$dir\" ?avrpt t ?dbuPerUU 2000.0 ?flagNon45 t ?flagOffGrid (0.005 1.0)
 ?joinPins top ?overwrite t ?userUnits \"micron\""
case $kind in
 drc) cat > $dir/$run.rsf <<EOT
avParameters( $common )
EOT
 ;;

 lvs) cat > $dir/$run.vlr <<EOT
avSimName = "auLvs"
avDisableWildcardPG = nil
avLibName  = "$SP_LIB"
avCellName = "$cell"
avViewName = "schematic"
avViewList = "auLvs schematic symbol"
avStopList = "auLvs"
avVldbFile = "$PWD/$dir/$run.sdb"
EOT
 cat > $dir/$run.rsf <<EOT
avParameters( $common ?textLevel (0:0) ?textPriOnly t )
avCompareRules(
 schematic( netlist( dfII "$PWD/$dir/$run.vlr" ) )
 bindingFile("$ASSURA_RULES/bind.rul") )
avLVS()
EOT
 ;;
 rcx) # parasitic extraction re-uses the database of the LVS run (same run name / directory)
 run=${cell}_lvs; dir=runs/$run
 cat > $dir/rcx.$run.rsf <<EOT
avParameters( ?workingDirectory "$PWD/$dir" ?runName "$run" ?inputLayout ("df2" "$SP_LIB") ?cellName "$cell" ?viewName "$view"
 ?technology "gpdk090" ?techLib "$ASSURA_TECH" )
rcxParameters( ?outputFormat "dfII" ?extractedView "av_extracted" ?checkCellView nil ?resistor "presistor" ?resPropName "r"
 ?capacitor "pcapacitor" ?capPropName "c" ?extract "both" ?netNameSpace "layout" ?maxFractureLength "infinite"
 ?fractureLengthUnits "microns" ?temperature 25.0 ?capExtractMode "decoupled" ?capGround "gnd" ?capCouplingFactor 1.0
 ?type "full" ?rcxfsType "none" ?minR 0.001 ?maxMergedViaSize "auto" ?arrayViasSpacing "auto" ?capModels "no"
 ?parasiticCapModels "no" ?resModels "no" ?parasiticResModels "comment" ?runName "$run" )
setShellEnvVar("CDS_AUTO_CKOUT=all")
avRCX()
EOT
 cd "$dir"; assura "rcx.$run.rsf" -cdslib $CDSLIB 2>&1 | grep -E "Summary|Error|ERROR|Finished|ended"; exit 0
 ;;
esac
cd "$dir"
assura "$run.rsf" -cdslib $CDSLIB -libdefs $CDSLIB 2>&1 | tail -25
