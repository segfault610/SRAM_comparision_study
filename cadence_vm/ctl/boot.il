;;; boot.il - lets an outside script drive a GUI Virtuoso: every 5 s it runs ctl/cmd.il (if present) and touches ctl/done.
procedure(clPoll()
  let((cmd run)
    cmd = "/home/buet/SRAM_comparision_study/cadence_vm/ctl/cmd.il"
    run = "/home/buet/SRAM_comparision_study/cadence_vm/ctl/run.il"
    when(isFile(cmd)
      sh(sprintf(nil "mv %s %s" cmd run))
      printf("\nCLAUDE_BEGIN\n")
      unless(errset(load(run) t) printf("CLAUDE_ERROR %L\n" errset.errset))
      printf("\nCLAUDE_END\n")
      sh("touch /home/buet/SRAM_comparision_study/cadence_vm/ctl/done"))
    hiRegTimer("clPoll()" 5)))
hiRegTimer("clPoll()" 5)
