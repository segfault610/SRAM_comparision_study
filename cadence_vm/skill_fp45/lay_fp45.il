;;; lay_fp45.il - 6T bit-cell layout for FreePDK45, drawn with plain rectangles (the kit's PyCell transistors
;;; need the CiraNova PyCell plug-in, which is not installed on this machine). Dimensions in microns.
;;; Layers (stream numbers in config/fp45.layermap): active 1, pwell 2, nwell 3, nimplant 4, pimplant 5, vtg 6,
;;; poly 9, contact 10, metal1 11, via1 12, metal2 13.
;;; Geometry:  one NMOS active strip  BL | PG_L | Q | PD_L | VSS | PD_R | QB | PG_R | BLB   (gates at x = 0, .19, .64, .83)
;;;            one PMOS active strip   Q | PU_L | VDD | PU_R | QB                              (gates at x = .19, .64)
;;; Gate length 50 nm, all widths 90 nm (kit minimum), like the single-size gpdk090 cell.

procedure(fp_r(cv lay x1 y1 x2 y2)
  dbCreateRect(cv list(lay "drawing") list(x1:y1 x2:y2)))

;;; contact with M1 pad: centre cx cy, optional pad extents
procedure(fp_cont(cv cx cy)
  fp_r(cv "contact" cx-0.0325 cy-0.0325 cx+0.0325 cy+0.0325))

;;; transistor: gate x gx, active strip drawn separately; poly column only
procedure(fp_pin(cv lay x y name)
  dbCreateRect(cv list(lay "pin") list(x-0.0325:y-0.0325 x+0.0325:y+0.0325))
  dbCreateLabel(cv list(lay "label") x:y name "centerCenter" "R0" "roman" 0.05))

procedure(fp_make_layout(layCell)
  let((cv gx yp)
    sp_ensure_lib(spLib spLibPath spTechLib)
    cv = dbOpenCellViewByType(spLib layCell "layout" "maskLayout" "w")
    yp = 0.60                                    ; PMOS active bottom
    ;; ---- wells, implants, threshold-voltage layer
    fp_r(cv "pwell" -0.20 -0.50 1.08 0.50)
    fp_r(cv "nwell"  0.03  0.50 0.85 1.12)
    fp_r(cv "nimplant" -0.175 -0.055 1.055 0.145)       ; NMOS strip
    fp_r(cv "pimplant"  0.015  0.530 0.865 0.760)       ; PMOS strip
    fp_r(cv "pimplant"  0.350 -0.310 0.550 -0.115)      ; p-tap (substrate)
    fp_r(cv "nimplant"  0.350  0.890 0.550  1.090)      ; n-tap (well)
    fp_r(cv "vtg" -0.105 -0.055 0.985 0.145)
    fp_r(cv "vtg"  0.085  0.545 0.795 0.745)
    ;; ---- active
    fp_r(cv "active" -0.105 0.0 0.985 0.09)             ; NMOS strip
    fp_r(cv "active"  0.085 yp 0.795 yp+0.09)           ; PMOS strip
    fp_r(cv "active"  0.400 -0.255 0.490 -0.165)        ; p-tap
    fp_r(cv "active"  0.400  0.945 0.490  1.035)        ; n-tap
    ;; ---- poly: the two inverter gates run from the NMOS to the PMOS row
    foreach(gx list(0.19 0.64) fp_r(cv "poly" gx -0.055 gx+0.05 yp+0.145))
    ;; access gates (word line) run down to the WL line
    foreach(gx list(0.0 0.83) fp_r(cv "poly" gx -0.45 gx+0.05 0.145))
    foreach(gx list(0.0 0.83) fp_r(cv "poly" gx-0.0275 -0.45 gx+0.0775 -0.345))
    ;; cross-coupling landing pads: left gate (Q_bar) to the right, right gate (Q) to the left
    fp_r(cv "poly" 0.19 0.2175 0.34 0.3225)
    fp_r(cv "poly" 0.54 0.3975 0.69 0.5025)
    ;; ---- contacts (centres)
    foreach(c list(list(-0.0675 0.045) list(0.12 0.045) list(0.44 0.045) list(0.76 0.045) list(0.9475 0.045)   ; NMOS strip
                   list(0.1225 0.645) list(0.44 0.645) list(0.7575 0.645)                                      ; PMOS strip
                   list(0.2875 0.27) list(0.5925 0.45)                                                         ; gate pads
                   list(0.025 -0.3975) list(0.855 -0.3975)                                                     ; WL poly contacts
                   list(0.445 -0.21) list(0.445 0.99))                                                         ; taps
      fp_cont(cv car(c) cadr(c)))
    ;; ---- metal1
    fp_r(cv "metal1" 0.0825 -0.0225 0.1575 0.7125)                      ; Q bus
    fp_r(cv "metal1" 0.7225 -0.0225 0.7975 0.7125)                      ; Q_bar bus
    fp_r(cv "metal1" 0.255 0.2025 0.32 0.3375)                          ; left gate pad
    fp_r(cv "metal1" 0.32 0.2375 0.7975 0.3025)                         ; ... to Q_bar bus
    fp_r(cv "metal1" 0.56 0.3825 0.625 0.5175)                          ; right gate pad
    fp_r(cv "metal1" 0.0825 0.4175 0.625 0.4825)                        ; ... to Q bus
    fp_r(cv "metal1" 0.4075 -0.2575 0.4725 0.1125)                      ; VSS: shared source down to the rail
    fp_r(cv "metal1" 0.4075 0.5775 0.4725 0.9925)                       ; VDD: shared source up to the rail
    fp_r(cv "metal1" -0.20 -0.2575 1.08 -0.1625)                        ; VSS rail
    fp_r(cv "metal1" -0.20 0.9425 1.08 1.0375)                          ; VDD rail
    fp_r(cv "metal1" -0.035 -0.43 0.92 -0.365)                          ; word line
    fp_r(cv "metal1" -0.1 -0.0225 -0.035 0.1125)                        ; BL pad
    fp_r(cv "metal1" 0.915 -0.0225 0.98 0.1125)                         ; BL_bar pad
    ;; ---- bit lines: via1 + vertical metal2
    fp_r(cv "via1" -0.1 0.0125 -0.035 0.0775)
    fp_r(cv "via1" 0.915 0.0125 0.98 0.0775)
    fp_r(cv "metal2" -0.1025 -0.50 -0.0325 1.12)
    fp_r(cv "metal2" 0.9125 -0.50 0.9825 1.12)
    ;; ---- pins
    fp_pin(cv "metal1" -0.10 -0.3975 "Wl")
    fp_pin(cv "metal2" -0.0675 -0.45 "BL")
    fp_pin(cv "metal2" 0.9475 -0.45 "BL_bar")
    fp_pin(cv "metal1" -0.10 0.99 "VDD")
    fp_pin(cv "metal1" -0.10 -0.21 "GND")
    dbSave(cv)
    sp_log("layout %s saved (%d shapes)" layCell length(cv~>shapes))
    cv))
