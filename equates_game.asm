;======================================
; Code equates
;======================================

PMAREA          = $3000
PL0             = PMAREA+1024
PL1             = PL0+256
PL2             = PL1+256
PL3             = PL2+256

ROMCH           = $E000                 ; rom chr set
CHARS           = $2C00                 ; my chr set
