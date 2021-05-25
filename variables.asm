;;;;;;;;;;;;;;; Basic configurations ;;;;;;;;;;;;;;;
    PROCESSOR 6502      ; processor MOS 6502/6507

    ; Macros for Atari 2600
    INCLUDE "vcs.h"
    INCLUDE "macro.h"

;;;;;;;;; Uninitialized segment for variables ;;;;;;;;;
    SEG.U VARS
    org $80

P0Height long          ; define 1 byte for p0 height 
P1Height byte          ; define 1 byte for p1 height

;;;;;;;;;;;; Begin code part ;;;;;;;;;;;
    SEG CODE            ; segment CODE
    ORG $F000           ; ROM area begin

;;;;;;;;;;;;; Reset and initialize system ;;;;;;;;;;;;;
Reset:
    CLEAN_START         ; clear RAM and registers, reset flags

;;;;;;;;;; Define start point ;;;;;;;;;;;;
Start:
    LDX #10             ; X = 10
    STX P0Height        ; P0Height = 10
    STX P1Height        ; P1Height = 10    JMP $FF00

Do:
    JMP Do

;;;;;;; Define end of cartridge ;;;;;;;
End:
    ORG $FFFC       ; goto cartridge end - 4 bytes
    .word Reset     ; add 2 bytes and Start address (FFFC-FFFD)
    .word Reset     ; another 2 bytes and Start address (FFFE-FFFF)
