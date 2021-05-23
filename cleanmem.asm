    processor 6502      ; define used processor chip

    seg code            ; segment "code"
    org $F000           ; start address

Start:
    sei                 ; disable interrupts flag = 0
    cld                 ; clear decimal flag 
    ldx #$FF            ; loads into X value FF
    txs                 ; transfer X to SP

;;;;;;;;;;;;;;;;;;; Clear mem from $FF to $00 ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0              ; A = 0
    ldx #$FF            ; X = FF
    ldy #0              ; Y = 0 (fixes crash occurring by sta $FF)

    ; Initially set mem 0xFF to 0
    sta $FF             ; Store A(=0) into mem pos $FF

MemLoop:
    dex                 ; X--
    sta $0,x            ; Store A into $0 + X
    bne MemLoop         ; while X != 0

;;;;;;;;;;;;;;;;; Fill rom size 4kB ;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC           ; Set pos to cartrigde END
    .word Start         ; Start -> Reset vector => FFFC
    .word Start         ; Start once more (interrupt) => FFFE
