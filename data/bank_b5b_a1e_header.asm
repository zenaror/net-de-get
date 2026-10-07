; PROBABLE native B $5B header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B5B A1E pointer header", ROMX[$6000], BANK[$2D]
ResidualROM2D_6000::
BankB5BA1EPointerHeader::
	dw $617B, BankB5BLowerPointerPrefix, $600C, $603F, $6061, $614B
ASSERT @ == $600C
SECTION "B5B lower stream record1", ROMX[$65D4], BANK[$2D]
BankB5BLowerStreamRecord1::
	db $04, $00, $00, $0A, $03, $AB, $06, $F0, $08, $E9
ASSERT @ == $65DE

; Only indices0/1 are represented; total table extent is unknown.
SECTION "B5B lower pointer prefix", ROMX[$65B4], BANK[$2D]
BankB5BLowerPointerPrefix::
	dw $7259, BankB5BLowerStreamRecord1
ASSERT @ == $65B8

; PROBABLE slot0 prefix through first positive countdown, not full stream.
SECTION "B5B slot0 stream prefix", ROMX[$65DE], BANK[$2D]
ResidualROM2D_65DE::
BankB5BSlot0StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $07, $00 ; mapped B $65DF
	db $B1, $40, $00 ; mapped B $65E2
	db $FD, $00, $00 ; mapped B $65E5
	db $9B, $39, $1B ; mapped B $65E8
ASSERT @ == $65EB

; PROBABLE slot1 prefix through first positive countdown, not full stream.
SECTION "B5B slot1 stream prefix", ROMX[$697F], BANK[$2D]
BankB5BSlot1StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $01, $00 ; mapped B $6980
	db $B1, $40, $00 ; mapped B $6983
	db $FD, $00, $00 ; mapped B $6986
	db $9A, $4B, $0E ; mapped B $6989
ASSERT @ == $698C

; PROBABLE slot2 prefix through first positive countdown, not full stream.
SECTION "B5B slot2 stream prefix", ROMX[$6CC4], BANK[$2D]
BankB5BSlot2StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $02, $00 ; mapped B $6CC5
	db $B1, $40, $00 ; mapped B $6CC8
	db $FD, $00, $00 ; mapped B $6CCB
	db $9F, $45, $1D ; mapped B $6CCE
ASSERT @ == $6CD1

; PROBABLE slot3 prefix through first positive countdown, not full stream.
SECTION "B5B slot3 stream prefix", ROMX[$6EBD], BANK[$2D]
BankB5BSlot3StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $01, $00 ; mapped B $6EBE
	db $B1, $40, $00 ; mapped B $6EC1
	db $FD, $00, $00 ; mapped B $6EC4
	db $9E, $29, $02 ; mapped B $6EC7
ASSERT @ == $6ECA

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B5B slot0 linear body", ROMX[$65EB], BANK[$2D]
ResidualROM2D_65EB::
BankB5BSlot0LinearBody::
	db $80, $03 ; B $65EB
	db $99, $40, $05 ; B $65ED
	db $80, $19 ; B $65F0
	db $99, $3F, $0E ; B $65F2
	db $80, $01 ; B $65F5
	db $99, $40, $0E ; B $65F7
	db $80, $01 ; B $65FA
	db $99, $42, $1D ; B $65FC
	db $80, $01 ; B $65FF
	db $9B, $45, $06 ; B $6601
	db $80, $18 ; B $6604
	db $9A, $3B, $1D ; B $6606
	db $80, $01 ; B $6609
	db $99, $40, $04 ; B $660B
	db $80, $1A ; B $660E
	db $99, $3F, $0E ; B $6610
	db $80, $01 ; B $6613
	db $99, $40, $0C ; B $6615
	db $80, $01 ; B $6618
	db $99, $3E, $01 ; B $661A
	db $80, $01 ; B $661D
	db $99, $40, $01 ; B $661F
	db $80, $00 ; B $6622
	db $99, $42, $15 ; B $6624
	db $80, $08 ; B $6627
	db $99, $40, $16 ; B $6629
	db $80, $08 ; B $662C
	db $9B, $39, $1B ; B $662E
	db $80, $03 ; B $6631
	db $99, $40, $05 ; B $6633
	db $80, $19 ; B $6636
	db $99, $3F, $0E ; B $6638
	db $80, $01 ; B $663B
	db $99, $40, $0E ; B $663D
	db $80, $01 ; B $6640
	db $99, $42, $1D ; B $6642
	db $80, $01 ; B $6645
	db $9B, $45, $06 ; B $6647
	db $80, $18 ; B $664A
	db $9A, $3B, $1D ; B $664C
	db $80, $01 ; B $664F
	db $99, $40, $04 ; B $6651
	db $80, $1A ; B $6654
	db $99, $3F, $0E ; B $6656
	db $80, $01 ; B $6659
	db $99, $40, $0C ; B $665B
	db $80, $01 ; B $665E
	db $99, $3E, $01 ; B $6660
	db $80, $01 ; B $6663
	db $99, $40, $01 ; B $6665
	db $80, $00 ; B $6668
	db $99, $42, $15 ; B $666A
	db $80, $08 ; B $666D
	db $99, $40, $16 ; B $666F
	db $80, $08 ; B $6672
	db $9C, $39, $58 ; B $6674
	db $80, $02 ; B $6677
	db $9B, $3B, $06 ; B $6679
	db $80, $01 ; B $667C
	db $95, $3B, $16 ; B $667E
	db $80, $01 ; B $6681
	db $9C, $39, $06 ; B $6683
	db $80, $01 ; B $6686
	db $96, $39, $16 ; B $6688
	db $80, $01 ; B $668B
	db $9C, $38, $06 ; B $668D
	db $80, $01 ; B $6690
	db $96, $38, $16 ; B $6692
	db $80, $01 ; B $6695
	db $9C, $39, $3B ; B $6697
	db $80, $01 ; B $669A
	db $9B, $3B, $0E ; B $669C
	db $80, $01 ; B $669F
	db $95, $3B, $0E ; B $66A1
	db $80, $01 ; B $66A4
	db $9C, $39, $0E ; B $66A6
	db $80, $01 ; B $66A9
	db $96, $39, $0E ; B $66AB
	db $80, $01 ; B $66AE
	db $9C, $39, $59 ; B $66B0
	db $80, $01 ; B $66B3
	db $9A, $3D, $4A ; B $66B5
	db $80, $01 ; B $66B8
	db $9A, $3B, $0E ; B $66BA
	db $80, $01 ; B $66BD
	db $99, $40, $0E ; B $66BF
	db $80, $01 ; B $66C2
	db $9A, $3B, $0E ; B $66C4
	db $80, $01 ; B $66C7
	db $9B, $3A, $0E ; B $66C9
	db $80, $01 ; B $66CC
	db $99, $40, $07 ; B $66CE
	db $80, $17 ; B $66D1
	db $9A, $3B, $0E ; B $66D3
	db $80, $01 ; B $66D6
	db $99, $40, $0E ; B $66D8
	db $80, $01 ; B $66DB
	db $9A, $3B, $0E ; B $66DD
	db $80, $01 ; B $66E0
	db $9B, $3A, $0E ; B $66E2
	db $80, $01 ; B $66E5
	db $99, $40, $07 ; B $66E7
	db $80, $17 ; B $66EA
	db $9A, $3B, $0E ; B $66EC
	db $80, $01 ; B $66EF
	db $99, $40, $0E ; B $66F1
	db $80, $01 ; B $66F4
	db $9A, $3B, $0E ; B $66F6
	db $80, $01 ; B $66F9
	db $9B, $3A, $0E ; B $66FB
	db $80, $01 ; B $66FE
	db $99, $40, $07 ; B $6700
	db $80, $17 ; B $6703
	db $9A, $3B, $0E ; B $6705
	db $80, $01 ; B $6708
	db $99, $40, $0E ; B $670A
	db $80, $01 ; B $670D
	db $9A, $3B, $0E ; B $670F
	db $80, $01 ; B $6712
	db $9B, $3A, $0E ; B $6714
	db $80, $01 ; B $6717
	db $99, $40, $07 ; B $6719
	db $80, $08 ; B $671C
	db $94, $42, $0E ; B $671E
	db $80, $01 ; B $6721
	db $94, $40, $07 ; B $6723
	db $80, $00 ; B $6726
	db $94, $3F, $07 ; B $6728
	db $80, $01 ; B $672B
	db $96, $42, $0E ; B $672D
	db $80, $01 ; B $6730
	db $96, $40, $07 ; B $6732
	db $80, $00 ; B $6735
	db $96, $3F, $07 ; B $6737
	db $80, $01 ; B $673A
	db $99, $42, $0E ; B $673C
	db $80, $01 ; B $673F
	db $99, $40, $07 ; B $6741
	db $80, $00 ; B $6744
	db $99, $3F, $07 ; B $6746
	db $80, $01 ; B $6749
	db $9B, $39, $1B ; B $674B
	db $80, $03 ; B $674E
	db $99, $40, $05 ; B $6750
	db $80, $19 ; B $6753
	db $99, $3F, $0E ; B $6755
	db $80, $01 ; B $6758
	db $99, $40, $0E ; B $675A
	db $80, $01 ; B $675D
	db $99, $42, $1D ; B $675F
	db $80, $01 ; B $6762
	db $9B, $45, $06 ; B $6764
	db $80, $18 ; B $6767
	db $9A, $3B, $1D ; B $6769
	db $80, $01 ; B $676C
	db $99, $40, $04 ; B $676E
	db $80, $1A ; B $6771
	db $99, $3F, $0E ; B $6773
	db $80, $01 ; B $6776
	db $99, $40, $0C ; B $6778
	db $80, $01 ; B $677B
	db $99, $3E, $01 ; B $677D
	db $80, $01 ; B $6780
	db $99, $40, $01 ; B $6782
	db $80, $00 ; B $6785
	db $99, $42, $15 ; B $6787
	db $80, $08 ; B $678A
	db $99, $40, $16 ; B $678C
	db $80, $08 ; B $678F
	db $9B, $39, $1B ; B $6791
	db $80, $03 ; B $6794
	db $99, $40, $05 ; B $6796
	db $80, $19 ; B $6799
	db $99, $3F, $0E ; B $679B
	db $80, $01 ; B $679E
	db $99, $40, $0E ; B $67A0
	db $80, $01 ; B $67A3
	db $99, $42, $1D ; B $67A5
	db $80, $01 ; B $67A8
	db $9B, $45, $06 ; B $67AA
	db $80, $18 ; B $67AD
	db $9A, $3B, $1D ; B $67AF
	db $80, $01 ; B $67B2
	db $99, $40, $04 ; B $67B4
	db $80, $1A ; B $67B7
	db $99, $3F, $0E ; B $67B9
	db $80, $01 ; B $67BC
	db $99, $40, $0C ; B $67BE
	db $80, $01 ; B $67C1
	db $99, $3E, $01 ; B $67C3
	db $80, $01 ; B $67C6
	db $99, $40, $01 ; B $67C8
	db $80, $00 ; B $67CB
	db $99, $42, $15 ; B $67CD
	db $80, $08 ; B $67D0
	db $99, $40, $16 ; B $67D2
	db $80, $08 ; B $67D5
	db $9B, $39, $1B ; B $67D7
	db $80, $03 ; B $67DA
	db $99, $40, $05 ; B $67DC
	db $80, $19 ; B $67DF
	db $99, $3F, $0E ; B $67E1
	db $80, $01 ; B $67E4
	db $99, $40, $0E ; B $67E6
	db $80, $01 ; B $67E9
	db $99, $42, $1D ; B $67EB
	db $80, $01 ; B $67EE
	db $9B, $45, $06 ; B $67F0
	db $80, $18 ; B $67F3
	db $9A, $3B, $1D ; B $67F5
	db $80, $01 ; B $67F8
	db $99, $40, $04 ; B $67FA
	db $80, $1A ; B $67FD
	db $99, $3F, $0E ; B $67FF
	db $80, $01 ; B $6802
	db $99, $40, $0C ; B $6804
	db $80, $01 ; B $6807
	db $99, $3E, $01 ; B $6809
	db $80, $01 ; B $680C
	db $99, $40, $01 ; B $680E
	db $80, $00 ; B $6811
	db $99, $42, $15 ; B $6813
	db $80, $08 ; B $6816
	db $99, $40, $16 ; B $6818
	db $80, $08 ; B $681B
	db $9B, $39, $1B ; B $681D
	db $80, $03 ; B $6820
	db $99, $40, $05 ; B $6822
	db $80, $19 ; B $6825
	db $99, $3F, $0E ; B $6827
	db $80, $01 ; B $682A
	db $99, $40, $0E ; B $682C
	db $80, $01 ; B $682F
	db $99, $42, $1D ; B $6831
	db $80, $01 ; B $6834
	db $9B, $45, $06 ; B $6836
	db $80, $18 ; B $6839
	db $9A, $3B, $1D ; B $683B
	db $80, $01 ; B $683E
	db $99, $40, $04 ; B $6840
	db $80, $1A ; B $6843
	db $99, $3F, $0E ; B $6845
	db $80, $01 ; B $6848
	db $99, $40, $0C ; B $684A
	db $80, $01 ; B $684D
	db $99, $3E, $01 ; B $684F
	db $80, $01 ; B $6852
	db $99, $40, $01 ; B $6854
	db $80, $00 ; B $6857
	db $99, $42, $15 ; B $6859
	db $80, $08 ; B $685C
	db $99, $40, $16 ; B $685E
	db $80, $08 ; B $6861
	db $9B, $39, $1B ; B $6863
	db $80, $03 ; B $6866
	db $99, $40, $05 ; B $6868
	db $80, $19 ; B $686B
	db $99, $3F, $0E ; B $686D
	db $80, $01 ; B $6870
	db $99, $40, $0E ; B $6872
	db $80, $01 ; B $6875
	db $99, $42, $1D ; B $6877
	db $80, $01 ; B $687A
	db $9B, $45, $06 ; B $687C
	db $80, $18 ; B $687F
	db $9A, $3B, $1D ; B $6881
	db $80, $01 ; B $6884
	db $99, $40, $04 ; B $6886
	db $80, $1A ; B $6889
	db $99, $3F, $0E ; B $688B
	db $80, $01 ; B $688E
	db $99, $40, $0C ; B $6890
	db $80, $01 ; B $6893
	db $99, $3E, $01 ; B $6895
	db $80, $01 ; B $6898
	db $99, $40, $01 ; B $689A
	db $80, $00 ; B $689D
	db $99, $42, $15 ; B $689F
	db $80, $08 ; B $68A2
	db $99, $40, $16 ; B $68A4
	db $80, $08 ; B $68A7
	db $9B, $39, $1B ; B $68A9
	db $80, $03 ; B $68AC
	db $99, $40, $05 ; B $68AE
	db $80, $19 ; B $68B1
	db $99, $3F, $0E ; B $68B3
	db $80, $01 ; B $68B6
	db $99, $40, $0E ; B $68B8
	db $80, $01 ; B $68BB
	db $99, $42, $1D ; B $68BD
	db $80, $01 ; B $68C0
	db $9B, $45, $06 ; B $68C2
	db $80, $18 ; B $68C5
	db $9A, $3B, $1D ; B $68C7
	db $80, $01 ; B $68CA
	db $99, $40, $04 ; B $68CC
	db $80, $1A ; B $68CF
	db $99, $3F, $0E ; B $68D1
	db $80, $01 ; B $68D4
	db $99, $40, $0C ; B $68D6
	db $80, $01 ; B $68D9
	db $99, $3E, $01 ; B $68DB
	db $80, $01 ; B $68DE
	db $99, $40, $01 ; B $68E0
	db $80, $00 ; B $68E3
	db $99, $42, $15 ; B $68E5
	db $80, $08 ; B $68E8
	db $99, $40, $16 ; B $68EA
	db $80, $08 ; B $68ED
	db $9B, $39, $1B ; B $68EF
	db $80, $03 ; B $68F2
	db $99, $40, $05 ; B $68F4
	db $80, $19 ; B $68F7
	db $99, $3F, $0E ; B $68F9
	db $80, $01 ; B $68FC
	db $99, $40, $0E ; B $68FE
	db $80, $01 ; B $6901
	db $99, $42, $1D ; B $6903
	db $80, $01 ; B $6906
	db $9B, $45, $06 ; B $6908
	db $80, $18 ; B $690B
	db $9A, $3B, $1D ; B $690D
	db $80, $01 ; B $6910
	db $99, $40, $04 ; B $6912
	db $80, $1A ; B $6915
	db $99, $3F, $0E ; B $6917
	db $80, $01 ; B $691A
	db $99, $40, $0C ; B $691C
	db $80, $01 ; B $691F
	db $99, $3E, $01 ; B $6921
	db $80, $01 ; B $6924
	db $99, $40, $01 ; B $6926
	db $80, $00 ; B $6929
	db $99, $42, $15 ; B $692B
	db $80, $08 ; B $692E
	db $99, $40, $16 ; B $6930
	db $80, $08 ; B $6933
	db $9B, $39, $1B ; B $6935
	db $80, $03 ; B $6938
	db $99, $40, $05 ; B $693A
	db $80, $19 ; B $693D
	db $99, $3F, $0E ; B $693F
	db $80, $01 ; B $6942
	db $99, $40, $0E ; B $6944
	db $80, $01 ; B $6947
	db $99, $42, $1D ; B $6949
	db $80, $01 ; B $694C
	db $9B, $45, $06 ; B $694E
	db $80, $18 ; B $6951
	db $9A, $3B, $1D ; B $6953
	db $80, $01 ; B $6956
	db $99, $40, $04 ; B $6958
	db $80, $1A ; B $695B
	db $99, $3F, $0E ; B $695D
	db $80, $01 ; B $6960
	db $99, $40, $0C ; B $6962
	db $80, $01 ; B $6965
	db $99, $3E, $01 ; B $6967
	db $80, $01 ; B $696A
	db $99, $40, $01 ; B $696C
	db $80, $00 ; B $696F
	db $99, $42, $15 ; B $6971
	db $80, $08 ; B $6974
	db $99, $40, $16 ; B $6976
	db $80, $08 ; B $6979
ASSERT @ == $697B

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B5B slot1 linear body", ROMX[$698C], BANK[$2D]
ResidualROM2D_698C::
BankB5BSlot1LinearBody::
	db $80, $01 ; B $698C
	db $9A, $4C, $0E ; B $698E
	db $80, $01 ; B $6991
	db $9A, $51, $07 ; B $6993
	db $80, $00 ; B $6996
	db $92, $51, $16 ; B $6998
	db $80, $01 ; B $699B
	db $9A, $4B, $0E ; B $699D
	db $80, $01 ; B $69A0
	db $9A, $4C, $0E ; B $69A2
	db $80, $01 ; B $69A5
	db $9A, $4B, $0E ; B $69A7
	db $80, $01 ; B $69AA
	db $9A, $4C, $0E ; B $69AC
	db $80, $01 ; B $69AF
	db $9A, $4B, $0E ; B $69B1
	db $80, $01 ; B $69B4
	db $9A, $4C, $0E ; B $69B6
	db $80, $01 ; B $69B9
	db $9A, $4B, $0E ; B $69BB
	db $80, $01 ; B $69BE
	db $9A, $4C, $0E ; B $69C0
	db $80, $01 ; B $69C3
	db $9A, $51, $07 ; B $69C5
	db $80, $00 ; B $69C8
	db $92, $51, $16 ; B $69CA
	db $80, $01 ; B $69CD
	db $9A, $4B, $0E ; B $69CF
	db $80, $01 ; B $69D2
	db $9A, $4C, $0E ; B $69D4
	db $80, $01 ; B $69D7
	db $9A, $53, $0E ; B $69D9
	db $80, $01 ; B $69DC
	db $9A, $52, $0E ; B $69DE
	db $80, $01 ; B $69E1
	db $9A, $53, $0E ; B $69E3
	db $80, $01 ; B $69E6
	db $92, $53, $0E ; B $69E8
	db $80, $01 ; B $69EB
	db $9A, $47, $16 ; B $69ED
	db $80, $08 ; B $69F0
	db $9A, $49, $16 ; B $69F2
	db $80, $08 ; B $69F5
	db $9A, $45, $16 ; B $69F7
	db $80, $08 ; B $69FA
	db $9A, $47, $0E ; B $69FC
	db $80, $01 ; B $69FF
	db $9A, $49, $0E ; B $6A01
	db $80, $01 ; B $6A04
	db $9A, $4C, $0E ; B $6A06
	db $80, $01 ; B $6A09
	db $9A, $4B, $0E ; B $6A0B
	db $80, $01 ; B $6A0E
	db $9A, $4C, $0F ; B $6A10
	db $80, $0F ; B $6A13
	db $9A, $4E, $0F ; B $6A15
	db $80, $0F ; B $6A18
	db $9A, $53, $0D ; B $6A1A
	db $80, $02 ; B $6A1D
	db $9A, $51, $05 ; B $6A1F
	db $80, $02 ; B $6A22
	db $9A, $50, $06 ; B $6A24
	db $80, $02 ; B $6A27
	db $9A, $51, $0D ; B $6A29
	db $80, $02 ; B $6A2C
	db $9A, $50, $0D ; B $6A2E
	db $80, $02 ; B $6A31
	db $9A, $51, $0D ; B $6A33
	db $80, $02 ; B $6A36
	db $9A, $4E, $0D ; B $6A38
	db $80, $02 ; B $6A3B
	db $9A, $4C, $3B ; B $6A3D
	db $80, $01 ; B $6A40
	db $9A, $4B, $0E ; B $6A42
	db $80, $01 ; B $6A45
	db $9A, $4C, $0E ; B $6A47
	db $80, $01 ; B $6A4A
	db $9A, $4E, $0E ; B $6A4C
	db $80, $01 ; B $6A4F
	db $9A, $4B, $0E ; B $6A51
	db $80, $01 ; B $6A54
	db $9A, $4C, $0E ; B $6A56
	db $80, $01 ; B $6A59
	db $9A, $4E, $0E ; B $6A5B
	db $80, $01 ; B $6A5E
	db $9A, $4C, $81, $0F ; B $6A60
	db $80, $07 ; B $6A64
	db $9A, $4E, $3B ; B $6A66
	db $80, $01 ; B $6A69
	db $9A, $4A, $0E ; B $6A6B
	db $80, $01 ; B $6A6E
	db $9A, $4C, $0E ; B $6A70
	db $80, $01 ; B $6A73
	db $9A, $4E, $0E ; B $6A75
	db $80, $01 ; B $6A78
	db $9A, $4B, $0E ; B $6A7A
	db $80, $01 ; B $6A7D
	db $9A, $4C, $0E ; B $6A7F
	db $80, $01 ; B $6A82
	db $9A, $4E, $0E ; B $6A84
	db $80, $01 ; B $6A87
	db $9A, $4C, $81, $0F ; B $6A89
	db $80, $25 ; B $6A8D
	db $9A, $4C, $16 ; B $6A8F
	db $80, $08 ; B $6A92
	db $9A, $4C, $05 ; B $6A94
	db $80, $0A ; B $6A97
	db $9A, $4C, $04 ; B $6A99
	db $80, $0B ; B $6A9C
	db $9A, $4C, $04 ; B $6A9E
	db $80, $0B ; B $6AA1
	db $9A, $4C, $04 ; B $6AA3
	db $80, $0B ; B $6AA6
	db $9A, $4C, $16 ; B $6AA8
	db $80, $08 ; B $6AAB
	db $9A, $4C, $04 ; B $6AAD
	db $80, $0B ; B $6AB0
	db $9A, $4C, $04 ; B $6AB2
	db $80, $0B ; B $6AB5
	db $9A, $4C, $04 ; B $6AB7
	db $80, $0B ; B $6ABA
	db $9A, $4C, $05 ; B $6ABC
	db $80, $0A ; B $6ABF
	db $9A, $4C, $16 ; B $6AC1
	db $80, $08 ; B $6AC4
	db $9A, $4C, $04 ; B $6AC6
	db $80, $0B ; B $6AC9
	db $9A, $4C, $04 ; B $6ACB
	db $80, $0B ; B $6ACE
	db $9A, $4C, $04 ; B $6AD0
	db $80, $0B ; B $6AD3
	db $9A, $4C, $05 ; B $6AD5
	db $80, $0A ; B $6AD8
	db $9A, $4C, $0E ; B $6ADA
	db $80, $01 ; B $6ADD
	db $9A, $4E, $0E ; B $6ADF
	db $80, $01 ; B $6AE2
	db $9A, $51, $07 ; B $6AE4
	db $80, $00 ; B $6AE7
	db $93, $51, $08 ; B $6AE9
	db $80, $0F ; B $6AEC
	db $9A, $4C, $0E ; B $6AEE
	db $80, $01 ; B $6AF1
	db $9A, $4E, $0E ; B $6AF3
	db $80, $01 ; B $6AF6
	db $9A, $4C, $0E ; B $6AF8
	db $80, $01 ; B $6AFB
	db $9A, $4E, $0E ; B $6AFD
	db $80, $01 ; B $6B00
	db $9A, $51, $07 ; B $6B02
	db $80, $00 ; B $6B05
	db $93, $51, $08 ; B $6B07
	db $80, $0F ; B $6B0A
	db $9A, $4C, $0E ; B $6B0C
	db $80, $01 ; B $6B0F
	db $9A, $4E, $0E ; B $6B11
	db $80, $01 ; B $6B14
	db $9A, $53, $07 ; B $6B16
	db $80, $00 ; B $6B19
	db $93, $53, $08 ; B $6B1B
	db $80, $0F ; B $6B1E
	db $9A, $4C, $0E ; B $6B20
	db $80, $01 ; B $6B23
	db $9A, $4E, $0E ; B $6B25
	db $80, $01 ; B $6B28
	db $9A, $4C, $0E ; B $6B2A
	db $80, $01 ; B $6B2D
	db $9A, $4E, $0E ; B $6B2F
	db $80, $01 ; B $6B32
	db $9A, $53, $0E ; B $6B34
	db $80, $01 ; B $6B37
	db $9A, $51, $0E ; B $6B39
	db $80, $01 ; B $6B3C
	db $9A, $4C, $0E ; B $6B3E
	db $80, $01 ; B $6B41
	db $9A, $4E, $0E ; B $6B43
	db $80, $01 ; B $6B46
	db $9A, $51, $07 ; B $6B48
	db $80, $00 ; B $6B4B
	db $93, $51, $08 ; B $6B4D
	db $80, $0F ; B $6B50
	db $9A, $4C, $0E ; B $6B52
	db $80, $01 ; B $6B55
	db $9A, $4E, $0E ; B $6B57
	db $80, $01 ; B $6B5A
	db $9A, $4C, $0E ; B $6B5C
	db $80, $01 ; B $6B5F
	db $9A, $4E, $0E ; B $6B61
	db $80, $01 ; B $6B64
	db $9A, $51, $07 ; B $6B66
	db $80, $00 ; B $6B69
	db $93, $51, $08 ; B $6B6B
	db $80, $0F ; B $6B6E
	db $9A, $4C, $0E ; B $6B70
	db $80, $01 ; B $6B73
	db $9A, $4E, $0E ; B $6B75
	db $80, $01 ; B $6B78
	db $9A, $53, $07 ; B $6B7A
	db $80, $00 ; B $6B7D
	db $93, $53, $08 ; B $6B7F
	db $80, $0F ; B $6B82
	db $9A, $4C, $0E ; B $6B84
	db $80, $01 ; B $6B87
	db $9A, $4E, $0E ; B $6B89
	db $80, $01 ; B $6B8C
	db $9A, $4C, $0E ; B $6B8E
	db $80, $01 ; B $6B91
	db $9A, $4E, $0E ; B $6B93
	db $80, $01 ; B $6B96
	db $9A, $53, $0E ; B $6B98
	db $80, $01 ; B $6B9B
	db $93, $53, $0E ; B $6B9D
	db $80, $01 ; B $6BA0
	db $9A, $53, $3B ; B $6BA2
	db $80, $01 ; B $6BA5
	db $9A, $51, $1D ; B $6BA7
	db $80, $01 ; B $6BAA
	db $9A, $4C, $3B ; B $6BAC
	db $80, $01 ; B $6BAF
	db $9A, $51, $3B ; B $6BB1
	db $80, $01 ; B $6BB4
	db $9A, $50, $1D ; B $6BB6
	db $80, $01 ; B $6BB9
	db $9A, $4A, $3B ; B $6BBB
	db $80, $01 ; B $6BBE
	db $9A, $4C, $59 ; B $6BC0
	db $80, $01 ; B $6BC3
	db $9A, $49, $3B ; B $6BC5
	db $80, $01 ; B $6BC8
	db $9A, $4A, $3B ; B $6BCA
	db $80, $01 ; B $6BCD
	db $9A, $51, $3B ; B $6BCF
	db $80, $01 ; B $6BD2
	db $9A, $50, $1D ; B $6BD4
	db $80, $01 ; B $6BD7
	db $9A, $4C, $77 ; B $6BD9
	db $80, $01 ; B $6BDC
	db $9A, $4E, $59 ; B $6BDE
	db $80, $01 ; B $6BE1
	db $9A, $51, $3B ; B $6BE3
	db $80, $01 ; B $6BE6
	db $9A, $50, $3B ; B $6BE8
	db $80, $01 ; B $6BEB
	db $9A, $51, $59 ; B $6BED
	db $80, $01 ; B $6BF0
	db $9A, $4C, $81, $2C ; B $6BF2
	db $80, $08 ; B $6BF6
	db $9A, $4B, $0E ; B $6BF8
	db $80, $01 ; B $6BFB
	db $9A, $4C, $0E ; B $6BFD
	db $80, $01 ; B $6C00
	db $9A, $51, $07 ; B $6C02
	db $80, $00 ; B $6C05
	db $92, $51, $16 ; B $6C07
	db $80, $01 ; B $6C0A
	db $9A, $4B, $0E ; B $6C0C
	db $80, $01 ; B $6C0F
	db $9A, $4C, $0E ; B $6C11
	db $80, $01 ; B $6C14
	db $9A, $4B, $0E ; B $6C16
	db $80, $01 ; B $6C19
	db $9A, $4C, $0E ; B $6C1B
	db $80, $01 ; B $6C1E
	db $9A, $4B, $0E ; B $6C20
	db $80, $01 ; B $6C23
	db $9A, $4C, $0E ; B $6C25
	db $80, $01 ; B $6C28
	db $9A, $4B, $0E ; B $6C2A
	db $80, $01 ; B $6C2D
	db $9A, $4C, $0E ; B $6C2F
	db $80, $01 ; B $6C32
	db $9A, $51, $07 ; B $6C34
	db $80, $00 ; B $6C37
	db $92, $51, $16 ; B $6C39
	db $80, $01 ; B $6C3C
	db $9A, $4B, $0E ; B $6C3E
	db $80, $01 ; B $6C41
	db $9A, $4C, $0E ; B $6C43
	db $80, $01 ; B $6C46
	db $9A, $53, $0E ; B $6C48
	db $80, $01 ; B $6C4B
	db $9A, $52, $0E ; B $6C4D
	db $80, $01 ; B $6C50
	db $9A, $53, $0E ; B $6C52
	db $80, $01 ; B $6C55
	db $9A, $51, $0E ; B $6C57
	db $80, $01 ; B $6C5A
	db $9A, $4B, $0E ; B $6C5C
	db $80, $01 ; B $6C5F
	db $9A, $4C, $0E ; B $6C61
	db $80, $01 ; B $6C64
	db $9A, $51, $07 ; B $6C66
	db $80, $00 ; B $6C69
	db $92, $51, $16 ; B $6C6B
	db $80, $01 ; B $6C6E
	db $9A, $4B, $0E ; B $6C70
	db $80, $01 ; B $6C73
	db $9A, $4C, $0E ; B $6C75
	db $80, $01 ; B $6C78
	db $9A, $4B, $0E ; B $6C7A
	db $80, $01 ; B $6C7D
	db $9A, $4C, $0E ; B $6C7F
	db $80, $01 ; B $6C82
	db $9A, $4B, $0E ; B $6C84
	db $80, $01 ; B $6C87
	db $9A, $4C, $0E ; B $6C89
	db $80, $01 ; B $6C8C
	db $9A, $4B, $0E ; B $6C8E
	db $80, $01 ; B $6C91
	db $9A, $4C, $0E ; B $6C93
	db $80, $01 ; B $6C96
	db $9A, $51, $07 ; B $6C98
	db $80, $00 ; B $6C9B
	db $92, $51, $16 ; B $6C9D
	db $80, $01 ; B $6CA0
	db $9A, $4B, $0E ; B $6CA2
	db $80, $01 ; B $6CA5
	db $9A, $4C, $0E ; B $6CA7
	db $80, $01 ; B $6CAA
	db $9A, $53, $0E ; B $6CAC
	db $80, $01 ; B $6CAF
	db $9A, $52, $0E ; B $6CB1
	db $80, $01 ; B $6CB4
	db $9A, $53, $0E ; B $6CB6
	db $80, $01 ; B $6CB9
	db $92, $53, $0E ; B $6CBB
	db $80, $01 ; B $6CBE
ASSERT @ == $6CC0

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B5B slot2 linear body", ROMX[$6CD1], BANK[$2D]
ResidualROM2D_6CD1::
BankB5BSlot2LinearBody::
	db $80, $01 ; B $6CD1
	db $9F, $47, $1D ; B $6CD3
	db $80, $01 ; B $6CD6
	db $9F, $45, $1D ; B $6CD8
	db $80, $01 ; B $6CDB
	db $9F, $40, $2C ; B $6CDD
	db $80, $01 ; B $6CE0
	db $9A, $40, $0E ; B $6CE2
	db $80, $01 ; B $6CE5
	db $9F, $45, $1D ; B $6CE7
	db $80, $01 ; B $6CEA
	db $9F, $47, $1D ; B $6CEC
	db $80, $01 ; B $6CEF
	db $9F, $45, $1D ; B $6CF1
	db $80, $01 ; B $6CF4
	db $9F, $40, $2C ; B $6CF6
	db $80, $01 ; B $6CF9
	db $9A, $40, $0E ; B $6CFB
	db $80, $01 ; B $6CFE
	db $9A, $51, $58 ; B $6D00
	db $80, $02 ; B $6D03
	db $9A, $53, $3B ; B $6D05
	db $80, $01 ; B $6D08
	db $9A, $51, $57 ; B $6D0A
	db $80, $03 ; B $6D0D
	db $9A, $50, $38 ; B $6D0F
	db $80, $04 ; B $6D12
	db $9A, $51, $58 ; B $6D14
	db $80, $02 ; B $6D17
	db $9A, $53, $59 ; B $6D19
	db $80, $01 ; B $6D1C
	db $9A, $51, $39 ; B $6D1E
	db $80, $03 ; B $6D21
	db $9A, $50, $39 ; B $6D23
	db $80, $03 ; B $6D26
	db $9A, $51, $58 ; B $6D28
	db $80, $02 ; B $6D2B
	db $9A, $53, $39 ; B $6D2D
	db $80, $03 ; B $6D30
	db $9A, $51, $3A ; B $6D32
	db $80, $02 ; B $6D35
	db $9A, $50, $1C ; B $6D37
	db $80, $02 ; B $6D3A
	db $9A, $51, $3A ; B $6D3C
	db $80, $02 ; B $6D3F
	db $9A, $50, $1C ; B $6D41
	db $80, $02 ; B $6D44
	db $9A, $51, $3A ; B $6D46
	db $80, $02 ; B $6D49
	db $9A, $50, $1C ; B $6D4B
	db $80, $02 ; B $6D4E
	db $9A, $51, $3A ; B $6D50
	db $80, $02 ; B $6D53
	db $9A, $50, $1C ; B $6D55
	db $80, $02 ; B $6D58
	db $9A, $51, $3A ; B $6D5A
	db $80, $02 ; B $6D5D
	db $9A, $53, $1C ; B $6D5F
	db $80, $02 ; B $6D62
	db $9F, $45, $1D ; B $6D64
	db $80, $01 ; B $6D67
	db $9F, $47, $1D ; B $6D69
	db $80, $01 ; B $6D6C
	db $9F, $45, $1D ; B $6D6E
	db $80, $01 ; B $6D71
	db $9F, $40, $2C ; B $6D73
	db $80, $01 ; B $6D76
	db $9A, $40, $0E ; B $6D78
	db $80, $01 ; B $6D7B
	db $9F, $45, $1D ; B $6D7D
	db $80, $01 ; B $6D80
	db $9F, $47, $1D ; B $6D82
	db $80, $01 ; B $6D85
	db $9F, $45, $1D ; B $6D87
	db $80, $01 ; B $6D8A
	db $9F, $40, $2C ; B $6D8C
	db $80, $01 ; B $6D8F
	db $9A, $40, $0E ; B $6D91
	db $80, $01 ; B $6D94
	db $9F, $45, $1D ; B $6D96
	db $80, $01 ; B $6D99
	db $9F, $47, $1D ; B $6D9B
	db $80, $01 ; B $6D9E
	db $9F, $45, $1D ; B $6DA0
	db $80, $01 ; B $6DA3
	db $9F, $40, $2C ; B $6DA5
	db $80, $01 ; B $6DA8
	db $9A, $40, $0E ; B $6DAA
	db $80, $01 ; B $6DAD
	db $9F, $45, $1D ; B $6DAF
	db $80, $01 ; B $6DB2
	db $9F, $47, $1D ; B $6DB4
	db $80, $01 ; B $6DB7
	db $9F, $45, $1D ; B $6DB9
	db $80, $01 ; B $6DBC
	db $9F, $40, $2C ; B $6DBE
	db $80, $01 ; B $6DC1
	db $9A, $40, $0E ; B $6DC3
	db $80, $01 ; B $6DC6
	db $9F, $45, $1D ; B $6DC8
	db $80, $01 ; B $6DCB
	db $9F, $47, $1D ; B $6DCD
	db $80, $01 ; B $6DD0
	db $9F, $45, $1D ; B $6DD2
	db $80, $01 ; B $6DD5
	db $9F, $40, $2C ; B $6DD7
	db $80, $01 ; B $6DDA
	db $9A, $40, $0E ; B $6DDC
	db $80, $01 ; B $6DDF
	db $9F, $45, $1D ; B $6DE1
	db $80, $01 ; B $6DE4
	db $9F, $47, $1D ; B $6DE6
	db $80, $01 ; B $6DE9
	db $9F, $45, $1D ; B $6DEB
	db $80, $01 ; B $6DEE
	db $9F, $40, $2C ; B $6DF0
	db $80, $01 ; B $6DF3
	db $9A, $40, $0E ; B $6DF5
	db $80, $01 ; B $6DF8
	db $9F, $45, $1D ; B $6DFA
	db $80, $01 ; B $6DFD
	db $9F, $47, $1D ; B $6DFF
	db $80, $01 ; B $6E02
	db $9F, $45, $1D ; B $6E04
	db $80, $01 ; B $6E07
	db $9F, $40, $2C ; B $6E09
	db $80, $01 ; B $6E0C
	db $9A, $40, $0E ; B $6E0E
	db $80, $01 ; B $6E11
	db $9F, $45, $1D ; B $6E13
	db $80, $01 ; B $6E16
	db $9F, $47, $1D ; B $6E18
	db $80, $01 ; B $6E1B
	db $9F, $45, $1D ; B $6E1D
	db $80, $01 ; B $6E20
	db $9F, $40, $2C ; B $6E22
	db $80, $01 ; B $6E25
	db $9A, $40, $0E ; B $6E27
	db $80, $01 ; B $6E2A
	db $9F, $45, $1D ; B $6E2C
	db $80, $01 ; B $6E2F
	db $9F, $47, $1D ; B $6E31
	db $80, $01 ; B $6E34
	db $9F, $45, $1D ; B $6E36
	db $80, $01 ; B $6E39
	db $9F, $40, $2C ; B $6E3B
	db $80, $01 ; B $6E3E
	db $9A, $40, $0E ; B $6E40
	db $80, $01 ; B $6E43
	db $9F, $45, $1D ; B $6E45
	db $80, $01 ; B $6E48
	db $9F, $47, $1D ; B $6E4A
	db $80, $01 ; B $6E4D
	db $9F, $45, $1D ; B $6E4F
	db $80, $01 ; B $6E52
	db $9F, $40, $2C ; B $6E54
	db $80, $01 ; B $6E57
	db $9A, $40, $0E ; B $6E59
	db $80, $01 ; B $6E5C
	db $9F, $45, $1D ; B $6E5E
	db $80, $01 ; B $6E61
	db $9F, $47, $1D ; B $6E63
	db $80, $01 ; B $6E66
	db $9F, $45, $1D ; B $6E68
	db $80, $01 ; B $6E6B
	db $9F, $40, $2C ; B $6E6D
	db $80, $01 ; B $6E70
	db $9A, $40, $0E ; B $6E72
	db $80, $01 ; B $6E75
	db $9F, $45, $1D ; B $6E77
	db $80, $01 ; B $6E7A
	db $9F, $47, $1D ; B $6E7C
	db $80, $01 ; B $6E7F
	db $9F, $45, $1D ; B $6E81
	db $80, $01 ; B $6E84
	db $9F, $40, $2C ; B $6E86
	db $80, $01 ; B $6E89
	db $9A, $40, $0E ; B $6E8B
	db $80, $01 ; B $6E8E
	db $9A, $51, $81, $15 ; B $6E90
	db $80, $01 ; B $6E94
	db $9A, $50, $1D ; B $6E96
	db $80, $01 ; B $6E99
	db $9A, $51, $77 ; B $6E9B
	db $80, $01 ; B $6E9E
	db $9A, $50, $1D ; B $6EA0
	db $80, $01 ; B $6EA3
	db $9A, $51, $77 ; B $6EA5
	db $80, $01 ; B $6EA8
	db $9A, $50, $1D ; B $6EAA
	db $80, $01 ; B $6EAD
	db $9A, $51, $59 ; B $6EAF
	db $80, $01 ; B $6EB2
	db $9A, $50, $1D ; B $6EB4
	db $80, $01 ; B $6EB7
ASSERT @ == $6EB9

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B5B slot3 linear body", ROMX[$6ECA], BANK[$2D]
ResidualROM2D_6ECA::
BankB5BSlot3LinearBody::
	db $80, $1C ; B $6ECA
	db $9B, $2F, $00 ; B $6ECC
	db $80, $1E ; B $6ECF
	db $9C, $29, $02 ; B $6ED1
	db $80, $0D ; B $6ED4
	db $98, $2F, $00 ; B $6ED6
	db $80, $0F ; B $6ED9
	db $9C, $29, $02 ; B $6EDB
	db $80, $1C ; B $6EDE
	db $99, $2F, $00 ; B $6EE0
	db $80, $0F ; B $6EE3
	db $9D, $29, $02 ; B $6EE5
	db $80, $0D ; B $6EE8
	db $9E, $29, $02 ; B $6EEA
	db $80, $1C ; B $6EED
	db $99, $2F, $00 ; B $6EEF
	db $80, $1E ; B $6EF2
	db $9A, $29, $02 ; B $6EF4
	db $80, $0D ; B $6EF7
	db $99, $2F, $00 ; B $6EF9
	db $80, $0F ; B $6EFC
	db $9C, $29, $02 ; B $6EFE
	db $80, $1C ; B $6F01
	db $99, $2F, $00 ; B $6F03
	db $80, $0F ; B $6F06
	db $9D, $29, $02 ; B $6F08
	db $80, $0D ; B $6F0B
	db $9E, $29, $02 ; B $6F0D
	db $80, $1C ; B $6F10
	db $9B, $2F, $00 ; B $6F12
	db $80, $1E ; B $6F15
	db $9C, $29, $02 ; B $6F17
	db $80, $0D ; B $6F1A
	db $98, $2F, $00 ; B $6F1C
	db $80, $0F ; B $6F1F
	db $9C, $29, $02 ; B $6F21
	db $80, $1C ; B $6F24
	db $99, $2F, $00 ; B $6F26
	db $80, $0F ; B $6F29
	db $9D, $29, $02 ; B $6F2B
	db $80, $0D ; B $6F2E
	db $9E, $29, $02 ; B $6F30
	db $80, $1C ; B $6F33
	db $99, $2F, $00 ; B $6F35
	db $80, $1E ; B $6F38
	db $9A, $29, $02 ; B $6F3A
	db $80, $0D ; B $6F3D
	db $99, $2F, $00 ; B $6F3F
	db $80, $0F ; B $6F42
	db $9C, $29, $02 ; B $6F44
	db $80, $1C ; B $6F47
	db $99, $2F, $00 ; B $6F49
	db $80, $0F ; B $6F4C
	db $9D, $29, $02 ; B $6F4E
	db $80, $0D ; B $6F51
	db $9E, $29, $02 ; B $6F53
	db $80, $1C ; B $6F56
	db $9B, $2F, $00 ; B $6F58
	db $80, $1E ; B $6F5B
	db $9C, $29, $02 ; B $6F5D
	db $80, $0D ; B $6F60
	db $98, $2F, $00 ; B $6F62
	db $80, $0F ; B $6F65
	db $9C, $29, $02 ; B $6F67
	db $80, $1C ; B $6F6A
	db $99, $2F, $00 ; B $6F6C
	db $80, $0F ; B $6F6F
	db $9D, $29, $02 ; B $6F71
	db $80, $0D ; B $6F74
	db $9E, $29, $02 ; B $6F76
	db $80, $1C ; B $6F79
	db $99, $2F, $00 ; B $6F7B
	db $80, $1E ; B $6F7E
	db $9A, $29, $02 ; B $6F80
	db $80, $0D ; B $6F83
	db $99, $2F, $00 ; B $6F85
	db $80, $0F ; B $6F88
	db $9C, $29, $02 ; B $6F8A
	db $80, $1C ; B $6F8D
	db $99, $2F, $00 ; B $6F8F
	db $80, $0F ; B $6F92
	db $9D, $29, $02 ; B $6F94
	db $80, $0D ; B $6F97
	db $9E, $29, $02 ; B $6F99
	db $80, $1C ; B $6F9C
	db $9B, $2F, $00 ; B $6F9E
	db $80, $1E ; B $6FA1
	db $9C, $29, $02 ; B $6FA3
	db $80, $0D ; B $6FA6
	db $98, $2F, $00 ; B $6FA8
	db $80, $0F ; B $6FAB
	db $9C, $29, $02 ; B $6FAD
	db $80, $1C ; B $6FB0
	db $99, $2F, $00 ; B $6FB2
	db $80, $0F ; B $6FB5
	db $9D, $29, $02 ; B $6FB7
	db $80, $0D ; B $6FBA
	db $9E, $29, $02 ; B $6FBC
	db $80, $1C ; B $6FBF
	db $99, $2F, $00 ; B $6FC1
	db $80, $1E ; B $6FC4
	db $9A, $29, $02 ; B $6FC6
	db $80, $0D ; B $6FC9
	db $99, $2F, $00 ; B $6FCB
	db $80, $0F ; B $6FCE
	db $9C, $29, $02 ; B $6FD0
	db $80, $1C ; B $6FD3
	db $99, $2F, $00 ; B $6FD5
	db $80, $0F ; B $6FD8
	db $9D, $29, $02 ; B $6FDA
	db $80, $0D ; B $6FDD
	db $9E, $29, $02 ; B $6FDF
	db $80, $1C ; B $6FE2
	db $9B, $2F, $00 ; B $6FE4
	db $80, $1E ; B $6FE7
	db $9C, $29, $02 ; B $6FE9
	db $80, $0D ; B $6FEC
	db $98, $2F, $00 ; B $6FEE
	db $80, $0F ; B $6FF1
	db $9C, $29, $02 ; B $6FF3
	db $80, $1C ; B $6FF6
	db $99, $2F, $00 ; B $6FF8
	db $80, $0F ; B $6FFB
	db $9D, $29, $02 ; B $6FFD
	db $80, $0D ; B $7000
	db $9E, $29, $02 ; B $7002
	db $80, $1C ; B $7005
	db $99, $2F, $00 ; B $7007
	db $80, $1E ; B $700A
	db $9A, $29, $02 ; B $700C
	db $80, $0D ; B $700F
	db $99, $2F, $00 ; B $7011
	db $80, $0F ; B $7014
	db $9C, $29, $02 ; B $7016
	db $80, $1C ; B $7019
	db $99, $2F, $00 ; B $701B
	db $80, $0F ; B $701E
	db $9D, $29, $02 ; B $7020
	db $80, $0D ; B $7023
	db $9E, $29, $02 ; B $7025
	db $80, $1C ; B $7028
	db $9B, $2F, $00 ; B $702A
	db $80, $1E ; B $702D
	db $9C, $29, $02 ; B $702F
	db $80, $0D ; B $7032
	db $98, $2F, $00 ; B $7034
	db $80, $0F ; B $7037
	db $9C, $29, $02 ; B $7039
	db $80, $1C ; B $703C
	db $99, $2F, $00 ; B $703E
	db $80, $0F ; B $7041
	db $9D, $29, $02 ; B $7043
	db $80, $0D ; B $7046
	db $9E, $29, $02 ; B $7048
	db $80, $1C ; B $704B
	db $99, $2F, $00 ; B $704D
	db $80, $1E ; B $7050
	db $9A, $29, $02 ; B $7052
	db $80, $0D ; B $7055
	db $99, $2F, $00 ; B $7057
	db $80, $0F ; B $705A
	db $9C, $29, $02 ; B $705C
	db $80, $1C ; B $705F
	db $99, $2F, $00 ; B $7061
	db $80, $0F ; B $7064
	db $9D, $29, $02 ; B $7066
	db $80, $0D ; B $7069
	db $9E, $29, $02 ; B $706B
	db $80, $1C ; B $706E
	db $9B, $2F, $00 ; B $7070
	db $80, $1E ; B $7073
	db $9C, $29, $02 ; B $7075
	db $80, $0D ; B $7078
	db $98, $2F, $00 ; B $707A
	db $80, $0F ; B $707D
	db $9C, $29, $02 ; B $707F
	db $80, $1C ; B $7082
	db $99, $2F, $00 ; B $7084
	db $80, $0F ; B $7087
	db $9D, $29, $02 ; B $7089
	db $80, $0D ; B $708C
	db $9E, $29, $02 ; B $708E
	db $80, $1C ; B $7091
	db $99, $2F, $00 ; B $7093
	db $80, $1E ; B $7096
	db $9A, $29, $02 ; B $7098
	db $80, $0D ; B $709B
	db $99, $2F, $00 ; B $709D
	db $80, $0F ; B $70A0
	db $9C, $29, $02 ; B $70A2
	db $80, $1C ; B $70A5
	db $99, $2F, $00 ; B $70A7
	db $80, $0F ; B $70AA
	db $9D, $29, $02 ; B $70AC
	db $80, $0D ; B $70AF
	db $9E, $29, $02 ; B $70B1
	db $80, $1C ; B $70B4
	db $9B, $2F, $00 ; B $70B6
	db $80, $1E ; B $70B9
	db $9C, $29, $02 ; B $70BB
	db $80, $0D ; B $70BE
	db $98, $2F, $00 ; B $70C0
	db $80, $0F ; B $70C3
	db $9C, $29, $02 ; B $70C5
	db $80, $1C ; B $70C8
	db $99, $2F, $00 ; B $70CA
	db $80, $0F ; B $70CD
	db $9D, $29, $02 ; B $70CF
	db $80, $0D ; B $70D2
	db $9E, $29, $02 ; B $70D4
	db $80, $1C ; B $70D7
	db $99, $2F, $00 ; B $70D9
	db $80, $1E ; B $70DC
	db $9A, $29, $02 ; B $70DE
	db $80, $0D ; B $70E1
	db $99, $2F, $00 ; B $70E3
	db $80, $0F ; B $70E6
	db $9C, $29, $02 ; B $70E8
	db $80, $1C ; B $70EB
	db $99, $2F, $00 ; B $70ED
	db $80, $0F ; B $70F0
	db $9D, $29, $02 ; B $70F2
	db $80, $0D ; B $70F5
	db $9E, $29, $02 ; B $70F7
	db $80, $1C ; B $70FA
	db $9B, $2F, $00 ; B $70FC
	db $80, $1E ; B $70FF
	db $9C, $29, $02 ; B $7101
	db $80, $0D ; B $7104
	db $98, $2F, $00 ; B $7106
	db $80, $0F ; B $7109
	db $9C, $29, $02 ; B $710B
	db $80, $1C ; B $710E
	db $99, $2F, $00 ; B $7110
	db $80, $0F ; B $7113
	db $9D, $29, $02 ; B $7115
	db $80, $0D ; B $7118
	db $9E, $29, $02 ; B $711A
	db $80, $1C ; B $711D
	db $99, $2F, $00 ; B $711F
	db $80, $1E ; B $7122
	db $9A, $29, $02 ; B $7124
	db $80, $0D ; B $7127
	db $99, $2F, $00 ; B $7129
	db $80, $0F ; B $712C
	db $9C, $29, $02 ; B $712E
	db $80, $1C ; B $7131
	db $99, $2F, $00 ; B $7133
	db $80, $0F ; B $7136
	db $9D, $29, $02 ; B $7138
	db $80, $0D ; B $713B
	db $9E, $29, $02 ; B $713D
	db $80, $1C ; B $7140
	db $9B, $2F, $00 ; B $7142
	db $80, $1E ; B $7145
	db $9C, $29, $02 ; B $7147
	db $80, $0D ; B $714A
	db $98, $2F, $00 ; B $714C
	db $80, $0F ; B $714F
	db $9C, $29, $02 ; B $7151
	db $80, $1C ; B $7154
	db $99, $2F, $00 ; B $7156
	db $80, $0F ; B $7159
	db $9D, $29, $02 ; B $715B
	db $80, $0D ; B $715E
	db $9E, $29, $02 ; B $7160
	db $80, $1C ; B $7163
	db $99, $2F, $00 ; B $7165
	db $80, $1E ; B $7168
	db $9A, $29, $02 ; B $716A
	db $80, $0D ; B $716D
	db $99, $2F, $00 ; B $716F
	db $80, $0F ; B $7172
	db $9C, $29, $02 ; B $7174
	db $80, $1C ; B $7177
	db $99, $2F, $00 ; B $7179
	db $80, $0F ; B $717C
	db $9D, $29, $02 ; B $717E
	db $80, $0D ; B $7181
	db $9E, $29, $02 ; B $7183
	db $80, $1C ; B $7186
	db $9B, $2F, $00 ; B $7188
	db $80, $1E ; B $718B
	db $9C, $29, $02 ; B $718D
	db $80, $0D ; B $7190
	db $98, $2F, $00 ; B $7192
	db $80, $0F ; B $7195
	db $9C, $29, $02 ; B $7197
	db $80, $1C ; B $719A
	db $99, $2F, $00 ; B $719C
	db $80, $0F ; B $719F
	db $9D, $29, $02 ; B $71A1
	db $80, $0D ; B $71A4
	db $9E, $29, $02 ; B $71A6
	db $80, $1C ; B $71A9
	db $99, $2F, $00 ; B $71AB
	db $80, $1E ; B $71AE
	db $9A, $29, $02 ; B $71B0
	db $80, $0D ; B $71B3
	db $99, $2F, $00 ; B $71B5
	db $80, $0F ; B $71B8
	db $9C, $29, $02 ; B $71BA
	db $80, $1C ; B $71BD
	db $99, $2F, $00 ; B $71BF
	db $80, $0F ; B $71C2
	db $9D, $29, $02 ; B $71C4
	db $80, $0D ; B $71C7
	db $9E, $29, $02 ; B $71C9
	db $80, $1C ; B $71CC
	db $9B, $2F, $00 ; B $71CE
	db $80, $1E ; B $71D1
	db $9C, $29, $02 ; B $71D3
	db $80, $0D ; B $71D6
	db $98, $2F, $00 ; B $71D8
	db $80, $0F ; B $71DB
	db $9C, $29, $02 ; B $71DD
	db $80, $1C ; B $71E0
	db $99, $2F, $00 ; B $71E2
	db $80, $0F ; B $71E5
	db $9D, $29, $02 ; B $71E7
	db $80, $0D ; B $71EA
	db $9E, $29, $02 ; B $71EC
	db $80, $1C ; B $71EF
	db $99, $2F, $00 ; B $71F1
	db $80, $1E ; B $71F4
	db $9A, $29, $02 ; B $71F6
	db $80, $0D ; B $71F9
	db $99, $2F, $00 ; B $71FB
	db $80, $0F ; B $71FE
	db $9C, $29, $02 ; B $7200
	db $80, $1C ; B $7203
	db $99, $2F, $00 ; B $7205
	db $80, $0F ; B $7208
	db $9D, $29, $02 ; B $720A
	db $80, $0D ; B $720D
	db $9E, $29, $02 ; B $720F
	db $80, $1C ; B $7212
	db $9B, $2F, $00 ; B $7214
	db $80, $1E ; B $7217
	db $9C, $29, $02 ; B $7219
	db $80, $0D ; B $721C
	db $98, $2F, $00 ; B $721E
	db $80, $0F ; B $7221
	db $9C, $29, $02 ; B $7223
	db $80, $1C ; B $7226
	db $99, $2F, $00 ; B $7228
	db $80, $0F ; B $722B
	db $9D, $29, $02 ; B $722D
	db $80, $0D ; B $7230
	db $9E, $29, $02 ; B $7232
	db $80, $1C ; B $7235
	db $99, $2F, $00 ; B $7237
	db $80, $1E ; B $723A
	db $9A, $29, $02 ; B $723C
	db $80, $0D ; B $723F
	db $99, $2F, $00 ; B $7241
	db $80, $0F ; B $7244
	db $9C, $29, $02 ; B $7246
	db $80, $1C ; B $7249
	db $99, $2F, $00 ; B $724B
	db $80, $0F ; B $724E
	db $9D, $29, $02 ; B $7250
	db $80, $0D ; B $7253
ASSERT @ == $7255
