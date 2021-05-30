    processor 6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include required files with register mapping and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an uninitialized segment at $80 for var declaration.
;; We have memory from $80 to $FF to work with, minus a few at
;; the end if we use the stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80

P0Height      .byte    ; player sprite height

P0XPos        .byte    ; sprite X coordinate
P0XBegin      .byte    ; start moving X pos from here
P0XEnd        .byte    ; stop moving X pos here and start again

P0YPos        .byte    ; sprite Y coordinate
P0YBegin      .byte    ; start moving X pos from here
P0YEnd        .byte    ; stop moving X pos here and start again

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start our ROM code segment starting at $F000.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000

Reset:
    CLEAN_START    ; macro to clean memory and TIA

    ldx #$00       ; black background color
    stx COLUBK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; ldx #40         ; X = 40
    ; stx P0XBegin    ; set P0Beg = X

    ; ldx #80         ; X = 80
    ; stx P0XEnd      ; set P0End = X

    lda #70
    sta P0XPos     ; initialize player X coordinate

    lda #86        ; screen half - player size
    sta P0YPos     ; set plr y pos

    lda #17
    sta P0Height    ; set player height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by configuring VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #2
    sta VBLANK     ; turn VBLANK on
    sta VSYNC      ; turn VSYNC on

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display 3 vertical lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 3
        sta WSYNC  ; first three VSYNC scanlines
    REPEND
    lda #0
    sta VSYNC      ; turn VSYNC off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set player horizontal position while in VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda P0XPos     ; load register A with desired X position
    and #$7F       ; same as AND 01111111, forces bit 7 to zero
                   ; keeping the result positive

    sec            ; set carry flag before subtraction

    sta WSYNC      ; wait for next scanline
    sta HMCLR      ; clear old horizontal position values

DivideLoop:
    sbc #15        ; Subtract 15 from A
    bcs DivideLoop ; loop while carry flag is still set

    eor #7         ; adjust the remainder in A between -8 and 7

    REPEAT 4
    asl            ; shift left by 4, as HMP0 uses only 4 bits
    REPEND

    sta HMP0       ; set smooth position value
    sta RESP0      ; fix rough position
    sta WSYNC      ; wait for next scanline
    sta HMOVE      ; apply the fine position offset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the 35 (37 - 2) recommended lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 35
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK     ; turn VBLANK off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192       ; A = 192

Scanline:
    txa            ; transfer X to A
    sec            ; make sure carry flag is set
    sbc P0YPos ; subtract sprite Y coordinate
    cmp P0Height  ; are we inside the sprite height bounds?
    bcc LoadBitmap ; if result < SpriteHeight, call subroutine
    lda #0         ; else, set index to 0

LoadBitmap:
    tay
    lda P0Bitmap,Y ; load player bitmap slice of data

    sta WSYNC      ; wait for next scanline

    sta GRP0       ; set graphics for player 0 slice

    lda P0Color,Y  ; load player color from lookup table

    sta COLUP0     ; set color for player 0 slice

    dex
    bne Scanline   ; repeat next scanline until finished

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 30 more VBLANK overscan lines to complete our frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Overscan:
    lda #2
    sta VBLANK     ; turn VBLANK on again for overscan
    REPEAT 30
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Joystick input test for P0 up/down/left/right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000
    bit SWCHA
    bne CheckP0Down
    inc P0YPos

CheckP0Down:
    lda #%00100000
    bit SWCHA
    bne CheckP0Left
    dec P0YPos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec P0XPos

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    inc P0XPos

NoInput:
    ; fallback when no input was performed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

    ; Goto near end of the rom
    org $FF00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lookup table for the player graphics bitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Bitmap:
    .byte #%00000000
    .byte #%00010100
    .byte #%00010100
    .byte #%00010100
    .byte #%00010100
    .byte #%00010100
    .byte #%00011100
    .byte #%01011101
    .byte #%01011101
    .byte #%01011101
    .byte #%01011101
    .byte #%01111111
    .byte #%00111110
    .byte #%00010000
    .byte #%00011100
    .byte #%00011100
    .byte #%00011100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lookup table for the player colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    .byte #$00
    .byte #$F6
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$F2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$C2
    .byte #$3E
    .byte #$3E
    .byte #$3E
    .byte #$24

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Complete ROM size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Reset
    .word Reset
