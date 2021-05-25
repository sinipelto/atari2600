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

;;;;;;; Define end of cartridge ;;;;;;;
End:
    ORG $FFFC       ; goto cartridge end - 4 bytes
    .word Reset     ; add 2 bytes and Start address (FFFC-FFFD)
    .word Reset     ; another 2 bytes and Start address (FFFE-FFFF)
