;;; config.il - settings for the single-cell comparison study (gpdk090 part).
;;; The sizes are those of the hand-drawn cell simple_6t_sram_cell: every device W = 120 n, L = 100 n.
spLib      = or(getShellEnvVar("SP_LIB") "version_90nm_sram_puf")
spLibPath  = or(getShellEnvVar("SP_LIBPATH") "./version_90nm_sram_puf")
spTechLib  = "gpdk090"
spNmos     = "nmos1v"
spPmos     = "pmos1v"
spVdd      = 1.2
spL        = "100n"
spWpd      = "120n"
spWpg      = "120n"
spWpu      = "120n"
