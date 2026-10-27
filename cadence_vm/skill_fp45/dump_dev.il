lib = "NCSU_Devices_FreePDK45"
foreach(c list("NMOS_VTG" "PMOS_VTG")
  printf("SP: == %s views: %L\n" c ddGetObj(lib c)~>views~>name)
  cdf = cdfGetBaseCellCDF(ddGetObj(lib c))
  printf("SP: simulators %L\n" cdf~>simInfo)
  foreach(p cdf~>parameters printf("SP:   param %s = %L (%s)\n" p~>name p~>defValue p~>type)))
cdf = cdfGetBaseCellCDF(ddGetObj(lib "NMOS_VTG"))
foreach(s list("spectre" "hspiceD" "auCdl" "auLvs")
  si = cdf~>simInfo
  printf("SP: sim %s: %L\n" s errset(si->s))
  printf("SP: netlistProcedure(%s)= %L\n" s errset(si->s->netlistProcedure)))
printf("SP: tech lib views %L\n" ddGetObj("NCSU_TechLib_FreePDK45")~>cells~>name)
exit()
