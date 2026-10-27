;;; Replaces the gpdk090-specific helpers of util.il (load after util.il).
;;; Junction areas of the kit: as = ad = W * 105 n, ps = pd = 2 W + 120 n (the defaults of the 90 n device).
procedure(sp_mos_params(inst w l)
  let((wv)
    inst~>w = w
    inst~>l = l
    wv = sp_eng(w)
    inst~>as = sprintf(nil "%g" wv*105e-9)
    inst~>ad = sprintf(nil "%g" wv*105e-9)
    inst~>ps = sprintf(nil "%g" 2*wv+120e-9)
    inst~>pd = sprintf(nil "%g" 2*wv+120e-9)
    inst))

procedure(sp_ensure_lib(libName libPath techLib)
  let((lib)
    unless(ddGetObj(libName)
      lib = ddCreateLib(libName libPath)
      techBindTechFile(lib spTechFile "techfile")
      ddUpdateLibList()
      sp_log("created library %s at %s (tech %s)" libName libPath spTechFile))
    ddGetObj(libName)))
