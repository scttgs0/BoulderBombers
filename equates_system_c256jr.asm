
;---------------------------------------
; System Equates for Foenix C256jr
;---------------------------------------

COLS_VISIBLE            = $000F         ; 2-byte Columns visible per screen line. A virtual line can be longer than displayed, up to COLS_PER_LINE long. Default = 80
COLS_PER_LINE           = $0011         ; 2-byte Columns in memory per screen line. A virtual line can be this long. Default=128
LINES_VISIBLE           = $0013         ; 2-byte The number of rows visible on the screen. Default=25
LINES_MAX               = $0015         ; 2-byte The number of rows in memory for the screen. Default=64

;---------------------------------------

MASTER_CTRL_L           = $D000
mcTextOn            = $01               ; Enable Text Mode
mcOverlayOn         = $02               ; Overlay Text on top of Graphics (Text Background Color is transparent)
mcGraphicsOn        = $04               ; Enable Graphic Mode
mcBitmapOn          = $08               ; Enable the Bitmap Module
mcTileMapOn         = $10               ; Enable the Tile Module
mcSpriteOn          = $20               ; Enable the Sprite Module
mcGammaOn           = $40               ; Enable Gamma Correction
mcDisableVideo      = $80               ; Disable the scanning of the video (hence giving 100% bandwith to the CPU)

MASTER_CTRL_H           = $D001
mcVideoMode240      = $00               ; 0 - 640x480 (Clock @ 60Mhz)                  - Text Mode only
                                        ; 0 - 320x240 w/pixel-doubling (Clock @ 60Mhz) - Graphics/Text Mode
mcVideoMode200      = $01               ; 1 - 640x400 (Clock @ 70Mhz)                  - Text Mode only
                                        ; 1 - 320x200 w/pixel-doubling (Clock @ 70Mhz) - Graphics/Text Mode             
mcTextXDouble       = $02               ; X Pixel Doubling - Text Mode only
mcTextYDouble       = $04               ; Y Pixel Doubling - Text Mode only

;---------------------------------------

LAYER_ORDER_CTRL_0      = $D002
locLayer0_BM0       = $00
locLayer0_BM1       = $01
locLayer0_BM2       = $02
locLayer1_BM0       = $00
locLayer1_BM1       = $01
locLayer1_BM2       = $02
LAYER_ORDER_CTRL_1      = $D003
locLayer2_BM0       = $00
locLayer2_BM1       = $01
locLayer2_BM2       = $02

;---------------------------------------

BORDER_CTRL             = $D004         ; Bit[0] - Enable (1 by default)
bcEnable            = $01               ; Bit[4..6]: X Scroll Offset (Will scroll Left)

BORDER_COLOR_B          = $D005
BORDER_COLOR_G          = $D006
BORDER_COLOR_R          = $D007
BORDER_X_SIZE           = $D008         ; Values: 0 - 32 (Default: 32)
BORDER_Y_SIZE           = $D009         ; Values: 0 - 32 (Default: 32)

; Line Interrupt (SOL)
VKY_LINE_IRQ_CTRL_REG   = $D018         ; Bit[0] - Enable Line 0 - Write Only
VKY_LINE_CMP_VALUE_LO   = $D019         ; Write Only [7:0]
VKY_LINE_CMP_VALUE_HI   = $D01A         ; Write Only [3:0]

VKY_PIXEL_X_POS_LO      = $D018         ; pixel displacement on raster line
VKY_PIXEL_X_POS_HI      = $D019
VKY_LINE_Y_POS_LO       = $D01A         ; raster line
VKY_LINE_Y_POS_HI       = $D01B

;---------------------------------------

BITMAP0_CTRL            = $D100
bmcEnable           = $01
bmcLUT0             = $02
bmcLUT1             = $04
bmcLUT2             = $08
bmcLUT3             = $10
BITMAP0_START_ADDR      = $D101

BITMAP1_CTRL            = $D108
BITMAP1_START_ADDR      = $D109

BITMAP2_CTRL            = $D110
BITMAP2_START_ADDR      = $D111

;---------------------------------------

TILE0_CTRL              = $D200
tcEnable            = $01
TILE0_START_ADDR        = $D201
TILE0_X_SIZE            = $D204
TILE0_Y_SIZE            = $D206
TILE0_WINDOW_X_POS      = $D208
TILE0_WINDOW_Y_POS      = $D20A

TILE1_CTRL              = $D20C
TILE1_START_ADDR        = $D20D
TILE1_X_SIZE            = $D210
TILE1_Y_SIZE            = $D212
TILE1_WINDOW_X_POS      = $D214
TILE1_WINDOW_Y_POS      = $D216

TILE2_CTRL              = $D218
TILE2_START_ADDR        = $D219
TILE2_X_SIZE            = $D21C
TILE2_Y_SIZE            = $D21E
TILE2_WINDOW_X_POS      = $D220
TILE2_WINDOW_Y_POS      = $D222

TILE3_CTRL              = $D224
TILE3_START_ADDR        = $D225
TILE3_X_SIZE            = $D228
TILE3_Y_SIZE            = $D22A
TILE3_WINDOW_X_POS      = $D22C
TILE3_WINDOW_Y_POS      = $D22E

TILESET0_ADDR           = $D280
TILESET0_ADDR_CFG       = $D283
tclVertical         = $00
tclSquare           = $08

;---------------------------------------

VDMA_CTRL               = $D400
vdcEnable       = $01
vdc1D_2D        = $02                   ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
vdcTRF_Fill     = $04                   ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
vdcInt_Enable   = $08                   ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
vdcSysRAM_Src   = $10                   ; Set to 1 to Indicate that the Source is the System Ram Memory
vdcSysRAM_Dst   = $20                   ; Set to 1 to Indicate that the Destination is the System Ram Memory
vdcStart_TRF    = $80                   ; Set to 1 To Begin Process, Need to Cleared before, you can start another
VDMA_STATUS             = $D401      ; Read only
vdsSize_Err     = $01                   ; If Set to 1, Overall Size is Invalid
vdsDst_Add_Err  = $02                   ; If Set to 1, Destination Address Invalid
vdsSrc_Add_Err  = $04                   ; If Set to 1, Source Address Invalid
vdsVDMA_IPS     = $80                   ; If Set to 1, VDMA Transfer in Progress (this Inhibit CPU Access to Mem)
VDMA_DST_ADDR           = $D405      ; Destination Pointer within Vicky's video memory Range
VDMA_SIZE               = $D408      ; Maximum Value: $40:0000 (4Megs)

SDMA0_CTRL              = $D420
sdcEnable       = $01
sdc1D_2D        = $02                   ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
sdcTRF_Fill     = $04                   ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
sdcInt_Enable   = $08                   ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
sdcSysRAM_Src   = $10                   ; Set to 1 to Indicate that the Source is the System Ram Memory
sdcSysRAM_Dst   = $20                   ; Set to 1 to Indicate that the Destination is the System Ram Memory
sdcStart_TRF    = $80                   ; Set to 1 To Begin Process, Need to Cleared before, you can start another
SDMA_SRC_ADDR           = $D422      ; Pointer to the Source of the Data to be stransfered
SDMA_SIZE               = $D428      ; Maximum Value: $40:0000 (4Megs)

;---------------------------------------

SID1_FREQ1              = $D400         ; [word]
SID1_PULSE1             = $D402         ; [word]
SID1_CTRL1              = $D404
SID1_ATDCY1             = $D405
SID1_SUREL1             = $D406

SID1_FREQ2              = $D407         ; [word]
SID1_PULSE2             = $D409         ; [word]
SID1_CTRL2              = $D40B
SID1_ATDCY2             = $D40C
SID1_SUREL2             = $D40D

SID1_FREQ3              = $D40E         ; [word]
SID1_PULSE3             = $D410         ; [word]
SID1_CTRL3              = $D412
SID1_ATDCY3             = $D413
SID1_SUREL3             = $D414

SID1_CUTOFF             = $D415         ; [word]
SID1_RESON              = $D417
SID1_SIGVOL             = $D418
SID1_RANDOM             = $D41B
SID1_ENV3               = $D41C

SID2_FREQ1              = $D500         ; [word]
SID2_PULSE1             = $D502         ; [word]
SID2_CTRL1              = $D504
SID2_ATDCY1             = $D505
SID2_SUREL1             = $D506

SID2_FREQ2              = $D507         ; [word]
SID2_PULSE2             = $D509         ; [word]
SID2_CTRL2              = $D50B
SID2_ATDCY2             = $D50C
SID2_SUREL2             = $D50D

SID2_FREQ3              = $D50E         ; [word]
SID2_PULSE3             = $D510         ; [word]
SID2_CTRL3              = $D512
SID2_ATDCY3             = $D513
SID2_SUREL3             = $D514

SID2_CUTOFF             = $D515         ; [word]
SID2_RESON              = $D517
SID2_SIGVOL             = $D518
SID2_RANDOM             = $D51B
SID2_ENV3               = $D51C

;---------------------------------------

KBD_INPT_BUF            = $D640
irqKBD          = $01                   ; keyboard Interrupt

;---------------------------------------

INT_PENDING_REG0        = $D660
INT_PENDING_REG1        = $D661
INT_MASK_REG0           = $D66C
FNX0_INT00_SOF      = $01
FNX0_INT01_SOL      = $02
INT_MASK_REG1           = $D66D
FNX1_INT00_KBD      = $01
FNX1_INT01_COL0     = $02               ; collision detection
FNX1_INT02_COL1     = $04
FNX1_INT03_COL2     = $08

;---------------------------------------

RTC_SEC                 = $D690
RTC_MIN                 = $D692
RTC_HRS                 = $D694
RTC_DAY                 = $D696

;---------------------------------------

MOUSE_PTR_CTRL          = $D700

C256F_MODEL_MAJOR       = $D70B
C256F_MODEL_MINOR       = $D70C

;---------------------------------------

FG_CHAR_LUT_PTR         = $D800         ; 16 entries = ARGB     $008060FF (medium slate blue)
                                        ;                       $00108020 (la salle green)
BG_CHAR_LUT_PTR		    = $D840         ; 16 entries = ARGB

;---------------------------------------

SP00_CTRL               = $D900
scEnable            = $01

scLUT0              = $00
scLUT1              = $02
scLUT2              = $04
scLUT3              = $06
scLUT4              = $08
scLUT5              = $0A
scLUT6              = $0C
scLUT7              = $0E

scDEPTH0            = $00
scDEPTH1            = $10
scDEPTH2            = $20
scDEPTH3            = $30
scDEPTH4            = $40
scDEPTH5            = $50
scDEPTH6            = $60

SP00_ADDR               = $D901      ; [long]
SP00_X_POS              = $D904      ; [word]
SP00_Y_POS              = $D906      ; [word]

SP01_CTRL               = $D908
SP01_ADDR               = $D909
SP01_X_POS              = $D90C
SP01_Y_POS              = $D90E

SP02_CTRL               = $D910
SP02_ADDR               = $D911
SP02_X_POS              = $D914
SP02_Y_POS              = $D916

SP03_CTRL               = $D918
SP03_ADDR               = $D919
SP03_X_POS              = $D91C
SP03_Y_POS              = $D91E


;---------------------------------------
;---------------------------------------
;   Memory Bank 01
;---------------------------------------

FONT_MEMORY_BANK0       = $C000         ; [C000:C7FF]

;--------------------------------------

GRPH_LUT0_PTR	        = $D000         ; [D000:D3FF]
GRPH_LUT1_PTR	        = $D400         ; [D400:D7FF]
GRPH_LUT2_PTR	        = $D800         ; [D800:DBFF]
GRPH_LUT3_PTR	        = $DC00         ; [DC00:DFFF]


;---------------------------------------
;---------------------------------------
;   Memory Bank 02
;---------------------------------------

CS_TEXT_MEM_PTR         = $C000         ; [C000:DFFF]   ascii code for text character


;---------------------------------------
;---------------------------------------
;   Memory Bank 02
;---------------------------------------
CS_COLOR_MEM_PTR        = $C000         ; [C000:DFFF]   HiNibble = Foreground; LoNibble = Background
                                        ;               0-15 = index into the CHAR_LUT tables


;--------------------------------------

JOYSTICK0               = $DC00         ; (R) Joystick 0

                                        ;           1110            bit-0   UP
                                        ;      1010   |   0110      bit-1   DOWN
                                        ;          \  |  /          bit-2   LEFT
                                        ;   1011----1111----0111    bit-3   RIGHT
                                        ;          /  |  \
                                        ;      1001   |   0101
                                        ;           1101

JOYSTICK1               = $DC01

LUTBkColor      = 0
LUTPfColor0     = 1
LUTPfColor1     = 2
LUTPfColor2     = 3
LUTPfColor3     = 4
LUTPfColor4     = 5
LUTPfColor5     = 6
LUTPfColor6     = 7
LUTPfColor7     = 8
LUTSprColor0    = 9
LUTSprColor1    = 10
LUTSprColor2    = 11
LUTSprColor3    = 12
LUTSprColor4    = 13
LUTSprColor5    = 14
LUTSprColor6    = 15
LUTSprColor7    = 16

;--------------------------------------

; READ
GABE_RNG_DAT_LO         = $D6A4      ; Low Part of 16Bit RNG Generator
GABE_RNG_DAT_HI         = $D6A5      ; Hi Part of 16Bit RNG Generator

; WRITE
GABE_RNG_SEED_LO        = $D6A4      ; Low Part of 16Bit RNG Generator
GABE_RNG_SEED_HI        = $D6A5      ; Hi Part of 16Bit RNG Generator

; WRITE
GABE_RNG_CTRL           = $D6A6
grcEnable       = $01                   ; Enable the LFSR BLOCK_LEN
grcDV           = $02                   ; After Setting the Seed Value, Toggle that Bit for it be registered

;---------------------------------------

vecCOP                  = $FFF4
vecABORT                = $FFF8
vecNMI                  = $FFFA
vecRESET                = $FFFC
vecIRQ_BRK              = $FFFE
