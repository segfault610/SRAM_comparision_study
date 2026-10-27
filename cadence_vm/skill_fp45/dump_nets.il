cv = dbOpenCellViewByType("fp45_sram6t" "simple_6t_sram_cell" "schematic" nil "r")
foreach(n cv~>nets
  printf("SP: net %s : " n~>name)
  foreach(it n~>instTerms printf("%s.%s " it~>inst~>name it~>name))
  foreach(tm n~>term printf("[pin %s] " tm~>name))
  printf("\n"))
foreach(i cv~>instances printf("SP: %s %L %L\n" i~>name i~>xy i~>bBox))
exit()
