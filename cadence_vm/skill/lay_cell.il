;;; lay_sram6t.il - layout of the 6T bit-cell (gpdk090, 1 V core devices) built from the kit PCells.
;;; Geometry in microns. Transistor origins are the lower-left corner of the gate.
;;;   row y=0   : PG_L (x=0)  PD_L (x=1)  PD_R (x=2)  PG_R (x=3)
;;;   row y=1.3 : PU_L (x=1)  PU_R (x=2)
;;; Metal1: Q / QB / VDD / VSS / WL.  Metal2 (vertical): BL, BLB.

procedure(sp_rect(cv lay x1 y1 x2 y2 @optional (purpose "drawing"))
  dbCreateRect(cv list(lay purpose) list(x1:y1 x2:y2)))

;;; poly landing pad with one contact and a Metal1 pad: poly box, contact box, metal box
procedure(sp_contact_pad(cv px1 py1 px2 py2 cx cy mx1 my1 mx2 my2)
  sp_rect(cv "Poly" px1 py1 px2 py2)
  sp_rect(cv "Cont" cx-0.06 cy-0.06 cx+0.06 cy+0.06)
  sp_rect(cv "Metal1" mx1 my1 mx2 my2))

;;; substrate / well tap: oxide 0.24 square, contact, implant; ox is the lower-left corner
procedure(sp_tap(cv x y implant)
  sp_rect(cv "Oxide" x y x+0.26 y+0.24)
  sp_rect(cv "Cont" x+0.07 y+0.06 x+0.19 y+0.18)
  sp_rect(cv implant x-0.14 y-0.14 x+0.40 y+0.38))

procedure(sp_pin(cv lay x y name)
  dbCreateRect(cv list(lay "pin") list(x-0.06:y-0.06 x+0.06:y+0.06))
  dbCreateLabel(cv list(lay "label") x:y name "centerCenter" "R0" "roman" 0.1))

procedure(sp_make_layout_cell(layCell)
  let((cv nm pm)
    sp_ensure_lib(spLib spLibPath spTechLib)
    cv = dbOpenCellViewByType(spLib layCell "layout" "maskLayout" "w")
    nm = dbOpenCellViewByType(spTechLib spNmos "layout" "maskLayout" "r")
    pm = dbOpenCellViewByType(spTechLib spPmos "layout" "maskLayout" "r")
    foreach(d list(list("MPG_L" nm 0.0 0.0 1.2e-7) list("MPD_L" nm 1.0 0.0 1.2e-7)
                   list("MPD_R" nm 2.0 0.0 1.2e-7) list("MPG_R" nm 3.0 0.0 1.2e-7)
                   list("MPU_L" pm 1.0 1.3 1.2e-7) list("MPU_R" pm 2.0 1.3 1.2e-7))
      dbCreateParamInst(cv cadr(d) car(d) list(caddr(d) cadddr(d)) "R0" 1
        list(list("fw" "float" nth(4 d)) list("l" "float" 1e-7)
             list("fingers" "float" 1.0) list("leftTap" "boolean" "FALSE"))))
    ;; vertical poly joining NMOS and PMOS gates of each inverter
    sp_rect(cv "Poly" 1.0 0.30 1.1 1.12)
    sp_rect(cv "Poly" 2.0 0.30 2.1 1.12)
    ;; gate contacts: left inverter gate (=QB) via stub on the right, right gate (=Q) stub on the left
    sp_contact_pad(cv 1.0 0.76 1.48 1.0   1.36 0.88   1.24 0.70 1.48 1.06)
    sp_contact_pad(cv 1.66 0.40 2.1 0.64  1.78 0.52   1.66 0.36 1.90 0.68)
    ;; Q node: PG_L drain + PD_L left diffusion + PU_L drain, then to the right gate
    sp_rect(cv "Metal1" 0.26 -0.06 0.9 0.18)
    sp_rect(cv "Metal1" 0.72 -0.06 0.9 1.48)
    sp_rect(cv "Metal1" 0.72 0.44 1.78 0.56)
    ;; QB node: PD_R right diffusion + PG_R source + PU_R drain, then to the left gate
    sp_rect(cv "Metal1" 2.2 -0.06 2.84 0.18)
    sp_rect(cv "Metal1" 2.2 -0.06 2.38 1.48)
    sp_rect(cv "Metal1" 1.36 0.82 2.38 0.94)
    ;; VSS: PD_L right + PD_R left diffusions, down to the rail
    sp_rect(cv "Metal1" 1.2 -0.06 1.9 0.18)
    sp_rect(cv "Metal1" 1.40 -0.68 1.54 0.18)
    sp_rect(cv "Metal1" -0.6 -0.68 3.9 -0.44)
    ;; VDD: PU_L source + PU_R source, up to the rail
    sp_rect(cv "Metal1" 1.26 1.30 1.84 1.48)
    sp_rect(cv "Metal1" 1.40 1.30 1.60 2.18)
    sp_rect(cv "Metal1" -0.6 1.94 3.9 2.18)
    ;; fill the gap between the two pull-down Nimp regions (Nimp spacing 0.24)
    sp_rect(cv "Nimp" 1.3 -0.20 1.8 0.32)
    ;; taps and well
    sp_tap(cv 1.9 -0.68 "Pimp")
    sp_tap(cv 1.9 1.94 "Nimp")
    sp_rect(cv "Nwell" 0.4 0.98 2.9 2.44)
    ;; word line: poly drops from the access gates to a Metal1 line
    sp_rect(cv "Poly" 0.0 -1.09 0.1 0.30)
    sp_rect(cv "Poly" 3.0 -1.09 3.1 0.30)
    sp_contact_pad(cv 0.0 -1.09 0.48 -0.85  0.36 -0.97  0.24 -1.06 0.48 -0.88)
    sp_contact_pad(cv 2.62 -1.09 3.1 -0.85  2.74 -0.97  2.62 -1.06 2.86 -0.88)
    sp_rect(cv "Metal1" -0.6 -1.06 3.9 -0.88)
    ;; bit lines: Metal1 pad on the access-transistor outer diffusion, Via1, vertical Metal2
    sp_rect(cv "Metal1" -0.37 -0.08 -0.07 0.24)
    sp_rect(cv "Via1" -0.29 0.01 -0.15 0.15)
    sp_rect(cv "Metal2" -0.31 -1.2 -0.13 2.6)
    sp_rect(cv "Metal1" 3.18 -0.08 3.46 0.24)
    sp_rect(cv "Via1" 3.25 0.01 3.39 0.15)
    sp_rect(cv "Metal2" 3.23 -1.2 3.41 2.6)
    ;; pins
    sp_pin(cv "Metal1" -0.45 -0.97 "Wl")
    sp_pin(cv "Metal2" -0.22 -1.1 "BL")
    sp_pin(cv "Metal2" 3.32 -1.1 "BL_bar")
    sp_pin(cv "Metal1" -0.45 2.06 "VDD")
    sp_pin(cv "Metal1" -0.45 -0.56 "GND")
    dbSave(cv)
    sp_log("layout sram6t saved (%d instances, %d shapes)" length(cv~>instances) length(cv~>shapes))
    cv))
