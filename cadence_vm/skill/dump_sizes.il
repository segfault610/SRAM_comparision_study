cv = dbOpenCellViewByType("version_90nm_sram_puf" "simple_6t_sram_cell_snm" "schematic" nil "r")
foreach(i cv~>instances
  when(rexMatchp("^[NP]M" i~>name)
    printf("SP: %s w=%L l=%L fw=%L fingers=%L m=%L as=%L ad=%L\n" i~>name i~>w i~>l i~>fw i~>fingers i~>m i~>as i~>ad)))
exit()
