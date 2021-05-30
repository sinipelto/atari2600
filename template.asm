;;; processor ;;;
     PROCESSOR 6502

;;; assembly includes ;;;
     INCLUDE "macro.h"
     INCLUDE "vcs.h"

;;; ram ;;;
    SEG.U VARIABLES
    ORG $80

Var  .byte     ; RAM variable

;;; move to rom start ;;;
     SEG ROM
     ORG $F000

;;; reset vcs REGS, RAM, TIA ;;;
Reset:
     CLEAN_START

;;;; init variables ;;;;
     LDX #0
     STA Var

;;;; Define rom end ;;;;
     ORG $FFFC
     .word Reset
     .word Reset    ; rom launch endpoint
