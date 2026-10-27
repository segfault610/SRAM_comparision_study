;;; config.il - FreePDK45 (45 nm PTM/BSIM4, NCSU kit v1.4) settings for the single-cell study.
;;; Same topology as the gpdk090 cell: all six devices the same size (the kit minimum W = 90 n, L = 50 n).
spLib      = "fp45_sram6t"
spLibPath  = "./fp45_sram6t"
spTechLib  = "NCSU_Devices_FreePDK45"        ; device symbols / CDF
spTechFile = "NCSU_TechLib_FreePDK45"        ; technology library (layers, rules)
spNmos     = "NMOS_VTG"
spPmos     = "PMOS_VTG"
spVdd      = 1.0
spL        = "50n"
spWpd      = "90n"
spWpg      = "90n"
spWpu      = "90n"
