;;; snm_cells.il - SNM test cells in the style of the hand-drawn simple_6t_sram_cell_snm (hold):
;;; the cross-coupled loop is opened, each half cell is driven by its own DC source (A drives the left
;;; inverter, B the right one) and the two voltage-transfer curves Q(A) and Q_bar(B) are plotted as a butterfly.
;;;   mode "hold"  : WL = 0,   BL = BL_bar = Vdd
;;;   mode "read"  : WL = Vdd, BL = BL_bar = Vdd           (access devices fight the pull-downs)
;;;   mode "write" : WL = Vdd, BL = 0, BL_bar = Vdd        (writing a 0 into Q)
;;; Both access transistors connect the bit line to the half-cell OUTPUT (Q / Q_bar), unlike the hold
;;; schematic where they hang on the (irrelevant for WL = 0) input nodes.
;;; The DC sources A and B take the design variable "vin" so one sweep gives both curves.

procedure(sp_make_snm(cell mode)
  let((lib cv nm pm wl bl blb)
    lib = sp_ensure_lib(spLib spLibPath spTechLib)
    cv = dbOpenCellViewByType(spLib cell "schematic" "schematic" "w")
    nm = dbOpenCellViewByType(spTechLib spNmos "symbol")
    pm = dbOpenCellViewByType(spTechLib spPmos "symbol")
    wl  = if(mode == "hold" then 0.0 else spVdd)
    bl  = if(mode == "write" then 0.0 else spVdd)
    blb = spVdd
    ;; name master W origin   D G S B
    foreach(d list(
        list("PM0" pm spWpu list(0 4)  list("Q"     "A" "vdd!" "vdd!"))
        list("NM0" nm spWpd list(0 0)  list("Q"     "A" "gnd!" "gnd!"))
        list("PM1" pm spWpu list(6 4)  list("Q_bar" "B" "vdd!" "vdd!"))
        list("NM1" nm spWpd list(6 0)  list("Q_bar" "B" "gnd!" "gnd!"))
        list("NM2" nm spWpg list(-4 0) list("BL"     "WL" "Q"     "gnd!"))
        list("NM3" nm spWpg list(10 0) list("BL_bar" "WL" "Q_bar" "gnd!")))
      let((inst c)
        inst = schCreateInst(cv cadr(d) car(d) nth(3 d) "R0")
        sp_mos_params(inst caddr(d) spL)
        c = nth(4 d)
        sp_label_term(cv inst "D" nth(0 c))
        sp_label_term(cv inst "G" nth(1 c))
        sp_label_term(cv inst "S" nth(2 c))
        sp_label_term(cv inst "B" nth(3 c))))
    ;; sources (vdc "vdc" is the property Ocean sweeps / sets)
    sp_vdc(cv "V0" list(-4 -5) "A"      "gnd!" 0.0)
    sp_vdc(cv "V6" list(0 -5)  "B"      "gnd!" 0.0)
    sp_vdc(cv "V5" list(4 -5)  "vdd!"   "gnd!" spVdd)
    sp_vdc(cv "V3" list(8 -5) "WL"     "gnd!" wl)
    sp_vdc(cv "V2" list(12 -5) "BL"     "gnd!" bl)
    sp_vdc(cv "V4" list(16 -5) "BL_bar" "gnd!" blb)
    cv~>instances~>name   ; touch
    sp_set_prop(cv "V0" "vdc" "vin")
    sp_set_prop(cv "V6" "vdc" "vin")
    schCheck(cv)
    dbSave(cv)
    sp_log("schematic %s (%s) saved: %d instances" cell mode length(cv~>instances))
    dbClose(cv)
    t))

procedure(sp_set_prop(cv instName prop value)
  let((i) i = car(setof(x cv~>instances x~>name == instName))
    dbReplaceProp(i prop 'string value)))
