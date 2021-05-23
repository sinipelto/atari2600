    PROCESSOR 6502

    INCLUDE "vcs.h"
    INCLUDE "macro.h"

    SEG code
    ORG $F000 ; ROM begin

START:
    CLEAN_START     ; macro -> clear mem

;;;;;;; BG color luminosity to yellow ;;;;;;;
    lda #$1E            ; set A = NTSC yellow code
    sta COLUBK          ; set BG color to yellow
    jmp START           ; loop START

END:
    org $FFFC           ; Set pos to cartrigde END
    .word START         ; add Start -> Reset vector => FFFC
    .word START         ; add Start once more (interrupt) => FFFE
