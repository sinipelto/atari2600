;;;;;;;;;;;;;;; Basic configurations ;;;;;;;;;;;;;;;
    PROCESSOR 6502      ; processor MOS 6502/6507

    ; Macros for Atari 2600
    INCLUDE "vcs.h"
    INCLUDE "macro.h"

    SEG CODE            ; segment CODE
    ORG $F000           ; ROM area begin

;;;;;;;;;;;;; Reset and initialize system ;;;;;;;;;;;;;
Reset:
    CLEAN_START         ; clear RAM and registers, reset flags

;;;;;;;;;; Define start point ;;;;;;;;;;;;
Start:
    LDX #$80        ; blue color
    LDY #$1C        ; yellow
    STX COLUBK      ; set bg blue
    STY COLUPF      ; set playfield yellow

;;;;;; Start new frame ;;;;;;
StartFrame:
    LDA #2          ; start bit
    LDY #0          ; stop bit

    STA VBLANK      ; start vlbank
    STA VSYNC       ; start vsynk

;;;;;; VSYMC lines ;;;;;;;
    REPEAT 3
       STA WSYNC       ; 3x scanlines
    REPEND

    STY VSYNC          ; done vsync

;;;;;; VBLANK lines ;;;;;;
    REPEAT 37
        STA WSYNC       ; 37x scanlines
    REPEND

    STY VBLANK          ; done vblank

;;;;;; Playfield reflection ;;;;;;;;
    LDX #%00000001      ; bit6 1
    STX CTRLPF          ; playfield reflection enabled

;;;;;;;; Visible area - Playfield ;;;;;;;;;;
    LDA #0

    ; set empty border
    ; set all blank (no playfield)
    STA PF0
    STA PF1
    STA PF2
    REPEAT 7
        STA WSYNC
    REPEND

    ; set 7 lines for phsical pf border
    ; pf0 0011 => 1100 xxxx
    ; pf1 1111 1111
    ; pf2 1111 1111
    ;;; mirror ;;;
    ; pf2 1111 1111
    ; pf1 1111 1111
    ; pf0 1111 0000

    ; Top border lines
    LDX #%11100000
    LDY #%11111111
    STX PF0
    STY PF1
    STY PF2
    REPEAT 7
        STA WSYNC
    REPEND

    ; Left and right borders
    ; middle line
    LDX #%00100000
    LDY #%10000000
    STX PF0
    STA PF1
    STY PF2
    REPEAT 164
        STA WSYNC
    REPEND

    ; Bottom border lines
    LDX #%11100000
    LDY #%11111111
    STX PF0
    STY PF1
    STY PF2
    REPEAT 7
        STA WSYNC
    REPEND

    ; 0000 for bottom empty space
    STA PF0
    STA PF1
    STA PF2
    REPEAT 7
        STA WSYNC
    REPEND

;;;;;;;; Overscan area ;;;;;;;;;
    LDA #2
    LDY #0

    STA VBLANK

    REPEAT 30
        STA WSYNC
    REPEND
    
    STY VBLANK

    JMP StartFrame      ; loop next frame

;;;;;;; Define end of cartridge ;;;;;;;
End:
    ORG $FFFC       ; goto cartridge end - 4 bytes
    .word Reset     ; add 2 bytes and Start address (FFFC-FFFD)
    .word Reset     ; another 2 bytes and Start address (FFFE-FFFF)
