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
;;; game reset endpoint ;;;
Reset:
     CLEAN_START

;;;; init variables ;;;;
Start:
     LDA #$82
     STA COLUBK     ; set BG blue

     LDX #2
     LDY #0

Frame:
;;;; VSYNC ;;;;
     STX VBLANK
     STX VSYNC

     REPEAT 3
          STA WSYNC
     REPEND

     STY VSYNC

;;;; VBLANK ;;;;
     REPEAT 37
          STA WSYNC
     REPEND

     STY VBLANK

;;;; Visible picture ;;;;
     REPEAT 192
          STA WSYNC
     REPEND

;;;; Overscan ;;;;
     STX VBLANK

     REPEAT 30
          STA WSYNC
     REPEND

     STY VBLANK

;;;; Loop next frame ;;;;
     JMP Frame

;;;; Define rom end ;;;;
     ORG $FFFC
     .word Reset    ; FFFC,FFFE
     .word Reset    ; FFFE,FFFF rom launch endpoint
     ; at FFFF
