; ///////////////////////
; //                   //
; //  File Attributes  //
; //                   //
; ///////////////////////

; Filename: startscreen.png
; Pixel Width: 160px
; Pixel Height: 144px

; /////////////////
; //             //
; //  Constants  //
; //             //
; /////////////////

startscreen_tile_map_size EQU $0400
startscreen_tile_map_width EQU $20
startscreen_tile_map_height EQU $20

startscreen_tile_data_size EQU $06B0
startscreen_tile_count EQU $6B

; ////////////////
; //            //
; //  Map Data  //
; //            //
; ////////////////

startscreen_map_data:
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D
DB $0E,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$15
DB $1B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27,$28
DB $29,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$2A,$2B,$00,$2C,$2D,$2E,$2F,$30,$2C,$31,$32,$33,$34
DB $35,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$36,$37,$38,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$39,$3A,$3B,$3C,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$3D,$3E,$3F,$40,$41,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$42,$43,$44,$45,$46,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$47,$47,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55
DB $56,$57,$58,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$59,$5A,$5B,$5C,$5D,$5D,$5E,$5F,$60,$61,$62,$63,$64,$65,$66
DB $67,$68,$69,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$6A,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; /////////////////
; //             //
; //  Tile Data  //
; //             //
; /////////////////

startscreen_tile_data:
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$1F,$FF,$7F,$FF,$7F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$F8,$FF,$FF,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$07,$FF,$83
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$07,$FF,$87
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$E0,$FF,$C0
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$1F,$FF,$7F,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$C0,$FF,$F0,$FF,$F8
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$07,$FF,$1F,$FF,$1F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$E0,$FF,$F8
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$03,$FF,$07
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FE,$FF,$FF,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$80,$FF,$C0
DB $FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$CF,$FF,$C7
DB $FF,$E3,$FF,$E1,$FF,$F1,$FF,$F0,$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$3F
DB $FF,$8F,$FF,$8F,$FF,$CF,$FF,$DF,$FF,$DF,$FF,$FE,$FF,$FE,$FF,$FC
DB $FF,$C1,$FF,$83,$FF,$87,$FF,$07,$FF,$07,$FF,$0F,$FF,$0F,$FF,$0F
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FC,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$9F,$FF,$9F,$FF,$9F
DB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$F1,$FF,$F0
DB $FF,$FC,$FF,$FE,$FF,$FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$0F,$FF,$1F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$7F,$FF,$7F,$FF,$7F
DB $FF,$E0,$FF,$F0,$FF,$F8,$FF,$F8,$FF,$F8,$FF,$FC,$FF,$FC,$FF,$FC
DB $FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F
DB $FF,$C7,$FF,$C7,$FF,$C7,$FF,$C7,$FF,$CF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$F8,$FF,$F8,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$E0,$FF,$C0,$FF,$00
DB $FF,$3F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$1F,$FF,$0F,$FF,$0F
DB $FF,$FC,$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F8,$FF,$F0
DB $FF,$0F,$FF,$0F,$FF,$0F,$FF,$0F,$FF,$0F,$FF,$0F,$FF,$07,$FF,$07
DB $FF,$F8,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0
DB $FF,$FF,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F
DB $FF,$9F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$0F,$FF,$0F
DB $FF,$F0,$FF,$F0,$FF,$F0,$FF,$F3,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DB $FF,$FF,$FF,$FE,$FF,$FE,$FF,$FC,$FF,$F8,$FF,$F0,$FF,$E0,$FF,$F0
DB $FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$7F,$FF,$3F,$FF,$3F
DB $FF,$C7,$FF,$83,$FF,$83,$FF,$83,$FF,$83,$FF,$83,$FF,$83,$FF,$83
DB $FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC,$FF,$FC,$FF,$F8,$FF,$F8
DB $FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$3F,$FF,$00,$FF,$00
DB $FF,$FC,$FF,$C0,$FF,$C0,$FF,$C0,$FF,$C0,$FF,$C0,$FF,$00,$FF,$00
DB $FF,$0F,$FF,$0F,$FF,$0F,$FF,$0F,$FF,$0F,$FF,$0F,$FF,$00,$FF,$00
DB $FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$F0,$FF,$00,$FF,$00
DB $FF,$07,$FF,$03,$FF,$03,$FF,$01,$FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$F8,$FF,$F9,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$FF,$1F,$FF,$00
DB $FF,$FF,$FF,$FE,$FF,$FC,$FF,$FC,$FF,$F8,$FF,$F0,$FF,$C0,$FF,$00
DB $FF,$FF,$FF,$F7,$FF,$F3,$FF,$F3,$FF,$F1,$FF,$F0,$FF,$00,$FF,$00
DB $FF,$F8,$FF,$FC,$FF,$FC,$FF,$FE,$FF,$FF,$FF,$F8,$FF,$60,$FF,$00
DB $FF,$3F,$FF,$1F,$FF,$1F,$FF,$0F,$FF,$07,$FF,$03,$FF,$00,$FF,$00
DB $FF,$C7,$FF,$CF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$FF,$00
DB $FF,$F8,$FF,$F0,$FF,$E0,$FF,$E0,$FF,$C0,$FF,$80,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$0F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$C0,$FF,$C0,$FF,$3C
DB $FF,$0F,$FF,$30,$FF,$30,$FC,$33,$FC,$33,$F0,$CF,$F0,$CF,$F0,$CF
DB $FF,$00,$0F,$FF,$0F,$FF,$33,$F3,$33,$F3,$30,$F0,$30,$F0,$0F,$FF
DB $FF,$3C,$CF,$CF,$CF,$CF,$C3,$C3,$C3,$C3,$FC,$FF,$FC,$FF,$C0,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$C0,$FF,$C0,$3F,$F0
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$03,$FF,$03,$FF,$03
DB $F0,$CF,$F0,$CF,$F0,$CF,$F0,$CF,$F0,$CF,$00,$FF,$00,$FF,$00,$FF
DB $0F,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$F0,$00,$F0,$C0,$C0
DB $C0,$FF,$0C,$FF,$0C,$FF,$C3,$FF,$C3,$FF,$3C,$3F,$3C,$3F,$03,$03
DB $3F,$F0,$0F,$FC,$0F,$FC,$FF,$FC,$FF,$FC,$3F,$F0,$3F,$F0,$FF,$C0
DB $FF,$03,$FF,$03,$FF,$03,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$FF,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF,$03,$FF,$03,$FF,$00
DB $C0,$C0,$C0,$C0,$C0,$C0,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$C0
DB $03,$03,$03,$03,$03,$03,$0F,$0C,$0F,$0C,$FF,$F0,$FF,$F0,$FF,$C0
DB $FF,$C0,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$C0,$FF,$FC,$FF,$FC,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$3F,$FF,$7F,$FF,$73,$FF,$73,$FF,$F3
DB $FF,$00,$FF,$00,$FF,$00,$FF,$80,$FF,$C0,$FF,$C0,$FF,$FF,$FF,$BF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$9F,$FF,$7F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$1F,$FF,$3F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$9F,$FF,$3F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$80,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$3E,$FF,$3E,$FF,$7E,$FF,$EE,$FF,$EE
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$3F,$FF,$3F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$CE,$FF,$CE
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$38,$FF,$70
DB $FF,$00,$FF,$00,$FF,$00,$FF,$1F,$FF,$3F,$FF,$39,$FF,$39,$FF,$7F
DB $FF,$00,$FF,$00,$FF,$00,$FF,$E0,$FF,$E0,$FF,$E0,$FF,$EF,$FF,$8E
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$01,$FF,$7B,$FF,$77
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$E1,$FF,$E3,$FF,$F7,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$C0,$FF,$C0,$FF,$E3,$FF,$EF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$E3,$FF,$F3
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$FC,$FF,$FC
DB $FF,$00,$FF,$00,$FF,$01,$FF,$01,$FF,$01,$FF,$03,$FF,$00,$FF,$00
DB $FF,$FF,$FF,$FE,$FF,$E0,$FF,$C0,$FF,$C0,$FF,$C0,$FF,$00,$FF,$00
DB $FF,$BF,$FF,$78,$FF,$70,$FF,$71,$FF,$F0,$FF,$E0,$FF,$00,$FF,$00
DB $FF,$77,$FF,$FF,$FF,$FF,$FF,$E0,$FF,$FE,$FF,$FC,$FF,$00,$FF,$00
DB $FF,$38,$FF,$7E,$FF,$3F,$FF,$8E,$FF,$FE,$FF,$FC,$FF,$00,$FF,$00
DB $FF,$01,$FF,$03,$FF,$03,$FF,$07,$FF,$0F,$FF,$1E,$FF,$00,$FF,$00
DB $FF,$CE,$FF,$8E,$FF,$FE,$FF,$FE,$FF,$1E,$FF,$1E,$FF,$00,$FF,$00
DB $FF,$39,$FF,$79,$FF,$73,$FF,$73,$FF,$F7,$FF,$E7,$FF,$00,$FF,$00
DB $FF,$CE,$FF,$CE,$FF,$8F,$FF,$8F,$FF,$8F,$FF,$0F,$FF,$0E,$FF,$7C
DB $FF,$E0,$FF,$E0,$FF,$C0,$FF,$80,$FF,$80,$FF,$01,$FF,$00,$FF,$00
DB $FF,$7F,$FF,$73,$FF,$F3,$FF,$E7,$FF,$FF,$FF,$FE,$FF,$00,$FF,$00
DB $FF,$8E,$FF,$DE,$FF,$DC,$FF,$9D,$FF,$BF,$FF,$1D,$FF,$00,$FF,$00
DB $FF,$73,$FF,$F3,$FF,$E3,$FF,$E7,$FF,$E7,$FF,$C3,$FF,$00,$FF,$00
DB $FF,$C7,$FF,$87,$FF,$87,$FF,$8F,$FF,$CF,$FF,$C7,$FF,$00,$FF,$00
DB $FF,$8E,$FF,$1C,$FF,$1C,$FF,$1C,$FF,$9F,$FF,$9F,$FF,$00,$FF,$00
DB $FF,$73,$FF,$77,$FF,$F7,$FF,$E7,$FF,$CF,$FF,$8E,$FF,$00,$FF,$00
DB $FF,$9C,$FF,$9C,$FF,$38,$FF,$38,$FF,$78,$FF,$70,$FF,$00,$FF,$00
DB $FF,$78,$FF,$F0,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
