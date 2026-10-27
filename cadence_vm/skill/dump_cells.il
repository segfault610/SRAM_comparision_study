;;; dump_cells.il - print every instance (name, master, key CDF params, terminal nets) of the user's schematics
procedure(dumpCell(lib cell)
  let((cv)
    cv = dbOpenCellViewByType(lib cell "schematic" nil "r")
    printf("SP: ===== %s/%s  (%d insts)\n" lib cell length(cv~>instances))
    foreach(i cv~>instances
      printf("SP: %-8s %s/%s @%L %s\n" i~>name i~>libName i~>cellName i~>xy i~>orient)
      foreach(p i~>prop printf("SP:     %s = %L\n" p~>name p~>value))
      foreach(it i~>instTerms printf("SP:     term %s -> %s\n" it~>name if(it~>net it~>net~>name "-"))))
    foreach(n cv~>nets printf("SP: net %s\n" n~>name))))
foreach(c list("simple_6t_sram_cell" "simple_6t_sram_cell_snm" "tb_simple_6t_sram_cell" "tb_snm_simple_6t_sram_cell")
  dumpCell("version_90nm_sram_puf" c))
exit()
