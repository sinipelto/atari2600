;;;; processor ;;;;
     PROCESSOR 6502 ; MOS 6502 CPU

;;;; assembly includes ;;;;
     INCLUDE "macro.h"
     INCLUDE "vcs.h"

;;;; ram ;;;;
    SEG.U VARIABLES ; uninit segment
    ORG $80    ; RAM pos 0

;;;; variables ;;;;
JetXPos   .byte     ; P0 X position
JetYPos   .byte     ; P0 Y position

BomberXPos     .byte     ; P1 X pos
BomberYPos     .byte     ; P1 Y pos

;;;; move to rom start ;;;;
     SEG ROM
     ORG $F000

;;;; reset vcs REGS, RAM, TIA ;;;;
;;;; game reset endpoint ;;;;
Reset:
     CLEAN_START

;;;; init variables ;;;;
Start:
     LDA #$82
     STA COLUBK     ; set BG Blue

     LDA #$7D
     STA COLUPF     ; set playfield Green

     LDA #1
     STA CTRLPF     ; playfield reflection

     ; set playfield graphics
     LDA #$F0       ; 1111 0000
     STA PF0        ; playfield part 0
     
     LDA #$FC       ; 1111 1100
     STA PF1        ; playfield part 1
     
     LDA #0         ; 0000 0000
     STA PF2        ; playfield part 2

     LDA #10
     STA JetYPos    ; JetYPos = 10

     LDA #60
     STA JetXPos    ; JetXPos = 60

     LDX #2         ; enable bit
     LDY #0         ; disable bit

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
Visible:
     LDX #192
.ScanLoop
     STA WSYNC
     DEX
     BNE .ScanLoop

;;;; Overscan ;;;;
     LDX #2
     LDY #0
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
