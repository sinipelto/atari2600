;;;;;;;;;; Initialization ;;;;;;;;;;;;;
    PROCESSOR 6502      ; MOS 6502/6507

    INCLUDE "vcs.h"
    INCLUDE "macro.h"

    SEG CODE
    ORG $F000

Start:
    CLEAN_START     ; macro to clean regs & memory

    LDA #2      ; A = 2 => Start bit
    LDY #0      ; Y = 0 => Stop bit

;;;;;;;;;;;; Start new frame, turn oon VBLANK and VSYNC ;;;;;;;;;;;;;;;;;;;
NextFrame:
    STA VBLANK      ; start VBLANK

;;;;;;;;;; Generate WSYNC lines (3 scanlines) ;;;;;;;;;;;;;
    STA VSYNC

    STA WSYNC       ; 1st line
    STA WSYNC       ; 2nd line
    STA WSYNC       ; 3rd line

    STY VSYNC       ; stop VSYNC

;;;;;;;;;; Generate VBLANK lines (37 scanlines) ;;;;;;;;;;
    LDX #37         ; X = 37

LoopVBlank:
    STA WSYNC       ; hit wsync & wait for TIA to return
    DEX
    BNE LoopVBlank  ; while X != 0

    STY VBLANK      ; stop VBLANK

;;;;;;;;;;; Draw visible scanlines (192) ;;;;;;;;;;;;;
    LDX #192

LoopVisible:
    STX COLUBK      ; set bg color
    STA WSYNC       ; wait for next line
    DEX
    BNE LoopVisible



;;;; Define end of cartridge ;;;;;;;
End:
    ORG $FFFC       ; goto cartridge end - 4 bytes
    ; Setup interrupt vectors
    .word Start     ; add 2 bytes and Start address (FFFC-FFFD)
    .word Start     ; another 2 bytes and Start address (FFFE-FFFF)
