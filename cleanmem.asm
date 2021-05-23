    processor 6502 ; define used processor chip

    seg code ; segment "code"
    org $F000   ; start address

Start:
    sei     ; disable interrupts flag = 0
    cld     ; clear decimal flag 
    ldx #$FF    ; loads into X value FF
    txs     ; transfer X to SP

;;;;;;;;;;;;;;;;;;; Clear mem from $00 to $ff ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0      ; A = 0
    ldx #$FF    ; X = FF

MemLoop:
    sta $0,x       ; Store A into $0 + X
    dex             ; X--
    bne MemLoop     ; while Z != 0

;;;;;;;;;;;;;;;;; Fill rom size 4kB ;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC       ; Set pos to cartrigde END
    .word Start     ; Start -> Reset vector => FFFC
    .word Start     ; Start once more (interrupt) => FFFE
