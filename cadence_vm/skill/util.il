;;; util.il - helpers shared by all SRAM-PUF SKILL scripts.
;;; Written for Virtuoso IC 6.1.5 (VM) and checked for 6.1.7 / 6.1.8 compatibility:
;;; only long-standing db* / sch* / dd* / tech* calls are used (no 6.1.7+ only API).

procedure(sp_log(fmt @rest args)
  apply('printf strcat("SP: " fmt "\n") args)
  nil)

procedure(sp_fail(fmt @rest args)
  apply('printf strcat("SP_ERROR: " fmt "\n") args)
  nil)

;;; ---------------------------------------------------------------- libraries
procedure(sp_ensure_lib(libName libPath techLib)
  let((lib)
    unless(ddGetObj(libName)
      lib = ddCreateLib(libName libPath)
      techBindTechFile(lib techLib "techfile")
      ddUpdateLibList()
      sp_log("created library %s at %s (tech %s)" libName libPath techLib))
    ddGetObj(libName)))

;;; ---------------------------------------------------------------- schematic helpers
;;; Terminal centre of an instance terminal.
procedure(sp_term_pt(inst termName)
  let((it bb xy)
    ;; pin geometry is in master coordinates: translate by the instance origin (orientation R0 only)
    it = car(setof(x inst~>instTerms x~>name == termName))
    unless(it
      sp_fail("Terminal %s not found on instance %s (cell %s)" termName inst~>name inst~>cellName))
    bb = car(it~>term~>pins~>fig~>bBox)
    xy = inst~>xy
    list(xCoord(xy)+0.5*(xCoord(car(bb))+xCoord(cadr(bb)))
         yCoord(xy)+0.5*(yCoord(car(bb))+yCoord(cadr(bb))))))

;;; Place a short wire stub on a terminal, pointing away without overlapping, and name the net.
procedure(sp_label_term(cv inst termName netName @optional (len 0.6))
  let((p p2 w just masterName isMos it dir)
    p = sp_term_pt(inst termName)
    it = car(setof(x inst~>instTerms x~>name == termName))
    dir = if(it && it~>term then it~>term~>direction else "inputOutput")
    masterName = inst~>cellName
    isMos = member(masterName list("nmos1v" "pmos1v" "nmos1v_hvt" "pmos1v_hvt" "nmos2v" "pmos2v" "nmoscap1v" "pmoscap1v" "NMOS_VTG" "NMOS_VTL" "NMOS_VTH" "PMOS_VTG" "PMOS_VTL" "PMOS_VTH"))
    if(isMos then
      cond(
        (termName == "G"
          p2 = list(xCoord(p)-len yCoord(p))
          just = "centerRight")
        (termName == "B"
          p2 = list(xCoord(p)+len yCoord(p))
          just = "centerLeft")
        ((termName == "D" && member(masterName list("nmos1v" "nmos1v_hvt" "nmos2v" "NMOS_VTG" "NMOS_VTL" "NMOS_VTH")))
          p2 = list(xCoord(p) yCoord(p)+len)
          just = "lowerCenter")
        ((termName == "S" && member(masterName list("nmos1v" "nmos1v_hvt" "nmos2v" "NMOS_VTG" "NMOS_VTL" "NMOS_VTH")))
          p2 = list(xCoord(p) yCoord(p)-len)
          just = "upperCenter")
        ((termName == "S" && member(masterName list("pmos1v" "pmos1v_hvt" "pmos2v" "PMOS_VTG" "PMOS_VTL" "PMOS_VTH")))
          p2 = list(xCoord(p) yCoord(p)+len)
          just = "lowerCenter")
        ((termName == "D" && member(masterName list("pmos1v" "pmos1v_hvt" "pmos2v" "PMOS_VTG" "PMOS_VTL" "PMOS_VTH")))
          p2 = list(xCoord(p) yCoord(p)-len)
          just = "upperCenter")
        (t
          p2 = list(xCoord(p)+len yCoord(p))
          just = "centerLeft"))
    else
      ;; For sub-blocks / gates: use pin direction
      cond(
        (dir == "input"
          p2 = list(xCoord(p)-len yCoord(p))
          just = "centerRight")
        (dir == "output"
          p2 = list(xCoord(p)+len yCoord(p))
          just = "centerLeft")
        (t
          ;; For inputOutput pins (e.g. supplies, bit-lines), determine if top or bottom
          let((ibox ymid)
            ibox = inst~>bBox
            ymid = 0.5*(yCoord(car(ibox)) + yCoord(cadr(ibox)))
            if(yCoord(p) >= ymid
              then p2 = list(xCoord(p) yCoord(p)+len) just = "lowerCenter"
              else p2 = list(xCoord(p) yCoord(p)-len) just = "upperCenter")))))
    w = car(schCreateWire(cv "route" "full" list(p p2) 0.0625 0.0625 0.0))
    schCreateWireLabel(cv w p2 netName just "R0" "stick" 0.2 nil)
    w))

;;; Place a pin with an attached wire stub and net label
procedure(sp_create_pin(cv name dir pt @optional (len 0.5))
  let((master mCell p2 w just)
    mCell = case(dir
      ("input" "ipin")
      ("output" "opin")
      (t "iopin"))
    master = dbOpenCellViewByType("basic" mCell "symbol")
    schCreatePin(cv master name dir nil pt "R0")
    p2 = list(xCoord(pt)+len yCoord(pt))
    just = "centerLeft"
    w = car(schCreateWire(cv "route" "full" list(pt p2) 0.0625 0.0625 0.0))
    schCreateWireLabel(cv w p2 name just "R0" "stick" 0.2 nil)
    w))

;;; Create an instance of a cell from a library and return it
procedure(sp_inst(cv lib cell name origin @optional (orient "R0"))
  let((m inst)
    m = dbOpenCellViewByType(lib cell "symbol")
    unless(m
      sp_fail("Failed to open symbol for %s/%s" lib cell))
    inst = schCreateInst(cv m name origin orient)
    inst))

;;; Connect multiple terminals on an instance: conns is a list of (termName netName)
procedure(sp_connect_inst(cv inst conns)
  foreach(c conns
    sp_label_term(cv inst car(c) cadr(c)))
  inst)

;;; Save schematic, run schCheck, and generate symbol
procedure(sp_finish_schematic(cv lib cell @optional (genSymbol t))
  schCheck(cv)
  dbSave(cv)
  sp_log("schematic %s saved (%d instances)" cell length(cv~>instances))
  dbClose(cv)
  when(genSymbol
    let((sym)
      schPinListToSymbol(lib cell "symbol" schSchemToPinList(lib cell "schematic"))
      sp_log("symbol %s created" cell)))
  t)

;;; Set CDF parameters of a gpdk090 MOS instance. W, L are strings such as "240n".
;;; The CDF "done" procedure of the kit needs a display and does not update the junction
;;; areas in batch mode, so they are set explicitly with the kit's own formula
;;; (as = ad = 0.58u * W, ps = pd = 1.16u).
procedure(sp_mos_params(inst w l)
  let((wv)
    inst~>w = w
    inst~>l = l
    wv = sp_eng(w)
    inst~>as = sprintf(nil "%g" wv*0.58e-6)
    inst~>ad = sprintf(nil "%g" wv*0.58e-6)
    inst~>ps = "1.16u"
    inst~>pd = "1.16u"
    inst))

;;; "240n" -> 2.4e-7
procedure(sp_eng(s)
  let((num suffix mult)
    if(numberp(s) then s
      else
        num = atof(s)
        suffix = substring(s strlen(s) 1)
        mult = case(suffix
                 ("f" 1e-15) ("p" 1e-12) ("n" 1e-9) ("u" 1e-6) ("m" 1e-3) ("k" 1e3)
                 (t 1.0))
        num*mult)))

procedure(sp_open_new(lib cell view type)
  dbOpenCellViewByType(lib cell view type "w"))

procedure(sp_save(cv)
  dbSave(cv)
  dbClose(cv))

;;; ---------------------------------------------------------------- testbench helpers
;;; Place an analogLib source/passive: name, cell ("vdc" "vpwl" "cap" "gnd" ...), origin, plus-net, minus-net.
procedure(sp_place_src(cv cell name origin plusNet minusNet)
  let((m inst)
    m = dbOpenCellViewByType("analogLib" cell "symbol")
    inst = schCreateInst(cv m name origin "R0")
    sp_label_term(cv inst "PLUS" plusNet)
    sp_label_term(cv inst "MINUS" minusNet)
    inst))

procedure(sp_vdc(cv name origin plusNet minusNet volts)
  let((i) i = sp_place_src(cv "vdc" name origin plusNet minusNet)
    i~>vdc = sprintf(nil "%g" volts) i))

;;; PWL source from a list of (time value) pairs; time strings like "1.2n", values in volts.
procedure(sp_vpwl(cv name origin plusNet minusNet pts)
  let((i k)
    i = sp_place_src(cv "vpwl" name origin plusNet minusNet)
    k = 1
    foreach(p pts
      dbReplaceProp(i sprintf(nil "t%d" k) 'string car(p))
      dbReplaceProp(i sprintf(nil "v%d" k) 'string cadr(p))
      k++)
    i~>tvpairs = sprintf(nil "%d" length(pts))
    i))

procedure(sp_cap(cv name origin plusNet minusNet c)
  let((i) i = sp_place_src(cv "cap" name origin plusNet minusNet)
    i~>c = c i))

;;; Place a gpdk090 MOS with named nets for D G S B.
procedure(sp_mos(cv type name origin w l d g s b)
  let((m i)
    m = dbOpenCellViewByType(spTechLib type "symbol")
    i = schCreateInst(cv m name origin "R0")
    sp_mos_params(i w l)
    sp_label_term(cv i "D" d) sp_label_term(cv i "G" g)
    sp_label_term(cv i "S" s) sp_label_term(cv i "B" b)
    i))
