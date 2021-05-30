;;;; processor ;;;;
     PROCESSOR 6502

;;;; assembly includes ;;;;
     INCLUDE "macro.h"
     INCLUDE "vcs.h"

;;;; ram ;;;;
    SEG.U VARIABLES
    ORG $80

;;;; variables ;;;;
Var  .byte     ; RAM variable

;;;; move to rom start ;;;;
     SEG ROM
     ORG $F000

;;;; reset vcs REGS, RAM, TIA ;;;;
Reset:
     CLEAN_START

;;;; init variables ;;;;
     LDX #0
     STA Var

;;;; Define rom end ;;;;
     ORG $FFFC
     .word Reset    ; FFFC,FFFE
     .word Reset    ; FFFE,FFFF rom launch endpoint

; at FFFF
