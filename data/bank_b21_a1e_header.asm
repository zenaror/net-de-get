; PROBABLE native B $21 header, consumed by resident main states.
; Index1 record has four original big-endian relative stream displacements.
; SYNTHETIC forced resident load/setup; no natural launch or audio claim.
SECTION "B21 A1E pointer header", ROMX[$6000], BANK[$10]
ResidualROM10_6000::
BankB21A1EPointerHeader::
	dw $617B, BankB21LowerPointerPrefix, $600C, $603F, $6061, $614B
ASSERT @ == $600C
SECTION "B21 lower stream record1", ROMX[$662E], BANK[$10]
BankB21LowerStreamRecord1::
	db $04, $00, $00, $0A, $02, $E5, $05, $7A, $07, $01
ASSERT @ == $6638

; Only indices0/1 are represented; total table extent is unknown.
SECTION "B21 lower pointer prefix", ROMX[$660E], BANK[$10]
BankB21LowerPointerPrefix::
	dw $7000, BankB21LowerStreamRecord1
ASSERT @ == $6612

; PROBABLE slot0 prefix through first positive countdown, not full stream.
SECTION "B21 slot0 stream prefix", ROMX[$6638], BANK[$10]
ResidualROM10_6638::
BankB21Slot0StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $0E, $00 ; mapped B $6639
	db $FD, $00, $00 ; mapped B $663C
	db $9C, $45, $0B ; mapped B $663F
ASSERT @ == $6642

; PROBABLE slot1 prefix through first positive countdown, not full stream.
SECTION "B21 slot1 stream prefix", ROMX[$6913], BANK[$10]
BankB21Slot1StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $09, $00 ; mapped B $6914
	db $FD, $00, $00 ; mapped B $6917
	db $9A, $35, $0B ; mapped B $691A
ASSERT @ == $691D

; PROBABLE slot2 prefix through first positive countdown, not full stream.
SECTION "B21 slot2 stream prefix", ROMX[$6BA8], BANK[$10]
BankB21Slot2StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $04, $00 ; mapped B $6BA9
	db $FD, $00, $00 ; mapped B $6BAC
	db $9A, $39, $24 ; mapped B $6BAF
ASSERT @ == $6BB2

; PROBABLE slot3 prefix through first positive countdown, not full stream.
SECTION "B21 slot3 stream prefix", ROMX[$6D2F], BANK[$10]
BankB21Slot3StreamPrefix::
	db $00 ; consumed by installation
	db $C0, $00, $00 ; mapped B $6D30
	db $FD, $00, $00 ; mapped B $6D33
	db $9A, $24, $00 ; mapped B $6D36
	db $80, $18 ; mapped B $6D39
ASSERT @ == $6D3B

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B21 slot0 linear body", ROMX[$6642], BANK[$10]
ResidualROM10_6642::
BankB21Slot0LinearBody::
	db $80, $01 ; B $6642
	db $98, $54, $06 ; B $6644
	db $80, $00 ; B $6647
	db $96, $54, $03 ; B $6649
	db $80, $03 ; B $664C
	db $9C, $48, $07 ; B $664E
	db $80, $05 ; B $6651
	db $9C, $47, $0C ; B $6653
	db $80, $01 ; B $6656
	db $98, $54, $06 ; B $6658
	db $80, $00 ; B $665B
	db $96, $54, $03 ; B $665D
	db $80, $03 ; B $6660
	db $9C, $48, $07 ; B $6662
	db $80, $05 ; B $6665
	db $9C, $43, $3A ; B $6667
	db $80, $04 ; B $666A
	db $9C, $4A, $07 ; B $666C
	db $80, $05 ; B $666F
	db $9C, $45, $0C ; B $6671
	db $80, $01 ; B $6674
	db $98, $54, $05 ; B $6676
	db $80, $01 ; B $6679
	db $96, $54, $03 ; B $667B
	db $80, $03 ; B $667E
	db $9C, $48, $07 ; B $6680
	db $80, $05 ; B $6683
	db $9C, $47, $0C ; B $6685
	db $80, $00 ; B $6688
	db $98, $54, $06 ; B $668A
	db $80, $01 ; B $668D
	db $96, $54, $03 ; B $668F
	db $80, $03 ; B $6692
	db $9C, $48, $07 ; B $6694
	db $80, $05 ; B $6697
	db $9C, $4A, $37 ; B $6699
	db $80, $00 ; B $669C
	db $98, $4A, $13 ; B $669E
	db $80, $00 ; B $66A1
	db $9C, $45, $0B ; B $66A3
	db $80, $01 ; B $66A6
	db $98, $54, $06 ; B $66A8
	db $80, $00 ; B $66AB
	db $96, $54, $03 ; B $66AD
	db $80, $04 ; B $66B0
	db $9C, $48, $06 ; B $66B2
	db $80, $06 ; B $66B5
	db $9C, $47, $0B ; B $66B7
	db $80, $01 ; B $66BA
	db $98, $54, $06 ; B $66BC
	db $80, $00 ; B $66BF
	db $96, $54, $03 ; B $66C1
	db $80, $03 ; B $66C4
	db $9C, $48, $07 ; B $66C6
	db $80, $06 ; B $66C9
	db $9C, $4D, $0C ; B $66CB
	db $80, $00 ; B $66CE
	db $9C, $4C, $0C ; B $66D0
	db $80, $00 ; B $66D3
	db $9C, $4D, $0C ; B $66D5
	db $80, $01 ; B $66D8
	db $9C, $4F, $0C ; B $66DA
	db $80, $00 ; B $66DD
	db $98, $4F, $0C ; B $66DF
	db $80, $00 ; B $66E2
	db $9C, $48, $0B ; B $66E4
	db $80, $02 ; B $66E7
	db $9C, $47, $81, $13 ; B $66E9
	db $80, $00 ; B $66ED
	db $9C, $45, $0C ; B $66EF
	db $80, $01 ; B $66F2
	db $98, $54, $05 ; B $66F4
	db $80, $01 ; B $66F7
	db $96, $54, $03 ; B $66F9
	db $80, $03 ; B $66FC
	db $9C, $48, $07 ; B $66FE
	db $80, $05 ; B $6701
	db $9C, $47, $0C ; B $6703
	db $80, $01 ; B $6706
	db $98, $54, $05 ; B $6708
	db $80, $01 ; B $670B
	db $96, $54, $03 ; B $670D
	db $80, $03 ; B $6710
	db $9C, $48, $07 ; B $6712
	db $80, $05 ; B $6715
	db $9C, $43, $3A ; B $6717
	db $80, $04 ; B $671A
	db $9C, $4A, $07 ; B $671C
	db $80, $05 ; B $671F
	db $9C, $45, $0C ; B $6721
	db $80, $00 ; B $6724
	db $98, $54, $06 ; B $6726
	db $80, $00 ; B $6729
	db $96, $54, $04 ; B $672B
	db $80, $03 ; B $672E
	db $9C, $48, $07 ; B $6730
	db $80, $05 ; B $6733
	db $9C, $47, $0B ; B $6735
	db $80, $01 ; B $6738
	db $98, $54, $06 ; B $673A
	db $80, $00 ; B $673D
	db $96, $54, $03 ; B $673F
	db $80, $04 ; B $6742
	db $9C, $48, $06 ; B $6744
	db $80, $06 ; B $6747
	db $9C, $4A, $37 ; B $6749
	db $80, $00 ; B $674C
	db $98, $4A, $12 ; B $674E
	db $80, $01 ; B $6751
	db $9C, $45, $0B ; B $6753
	db $80, $01 ; B $6756
	db $98, $54, $06 ; B $6758
	db $80, $00 ; B $675B
	db $96, $54, $03 ; B $675D
	db $80, $03 ; B $6760
	db $9C, $48, $07 ; B $6762
	db $80, $06 ; B $6765
	db $9C, $47, $0B ; B $6767
	db $80, $01 ; B $676A
	db $98, $54, $06 ; B $676C
	db $80, $00 ; B $676F
	db $96, $54, $03 ; B $6771
	db $80, $03 ; B $6774
	db $9C, $48, $07 ; B $6776
	db $80, $06 ; B $6779
	db $9C, $4D, $0C ; B $677B
	db $80, $00 ; B $677E
	db $9C, $4C, $0C ; B $6780
	db $80, $00 ; B $6783
	db $9C, $4D, $0C ; B $6785
	db $80, $00 ; B $6788
	db $9C, $4F, $0C ; B $678A
	db $80, $01 ; B $678D
	db $98, $4F, $0C ; B $678F
	db $80, $00 ; B $6792
	db $9C, $51, $0B ; B $6794
	db $80, $01 ; B $6797
	db $9C, $4F, $4A ; B $6799
	db $80, $00 ; B $679C
	db $9C, $4A, $4A ; B $679E
	db $80, $00 ; B $67A1
	db $9C, $4C, $0C ; B $67A3
	db $80, $00 ; B $67A6
	db $9C, $4B, $0C ; B $67A8
	db $80, $01 ; B $67AB
	db $9C, $4C, $0C ; B $67AD
	db $80, $00 ; B $67B0
	db $9C, $4B, $09 ; B $67B2
	db $80, $03 ; B $67B5
	db $C0, $08, $00 ; B $67B7
	db $9A, $54, $06 ; B $67BA
	db $80, $00 ; B $67BD
	db $95, $54, $06 ; B $67BF
	db $80, $01 ; B $67C2
	db $C0, $0E, $00 ; B $67C4
	db $9C, $45, $0C ; B $67C7
	db $80, $00 ; B $67CA
	db $9C, $44, $0C ; B $67CC
	db $80, $00 ; B $67CF
	db $9C, $45, $0C ; B $67D1
	db $80, $01 ; B $67D4
	db $9C, $44, $05 ; B $67D6
	db $80, $01 ; B $67D9
	db $C0, $08, $00 ; B $67DB
	db $9A, $54, $04 ; B $67DE
	db $80, $02 ; B $67E1
	db $C0, $0E, $00 ; B $67E3
	db $9C, $4D, $0C ; B $67E6
	db $80, $00 ; B $67E9
	db $9C, $4C, $0C ; B $67EB
	db $80, $00 ; B $67EE
	db $9C, $4D, $0C ; B $67F0
	db $80, $01 ; B $67F3
	db $9C, $4C, $09 ; B $67F5
	db $80, $03 ; B $67F8
	db $C0, $08, $00 ; B $67FA
	db $9A, $54, $06 ; B $67FD
	db $80, $00 ; B $6800
	db $95, $54, $06 ; B $6802
	db $80, $00 ; B $6805
	db $C0, $0E, $00 ; B $6807
	db $9C, $48, $0C ; B $680A
	db $80, $01 ; B $680D
	db $9C, $47, $0C ; B $680F
	db $80, $00 ; B $6812
	db $9C, $48, $0C ; B $6814
	db $80, $00 ; B $6817
	db $9C, $47, $06 ; B $6819
	db $80, $00 ; B $681C
	db $C0, $08, $00 ; B $681E
	db $9A, $54, $05 ; B $6821
	db $80, $02 ; B $6824
	db $C0, $0E, $00 ; B $6826
	db $9B, $4C, $5C ; B $6829
	db $80, $00 ; B $682C
	db $98, $4C, $12 ; B $682E
	db $80, $00 ; B $6831
	db $9B, $4D, $5C ; B $6833
	db $80, $01 ; B $6836
	db $98, $4D, $12 ; B $6838
	db $80, $00 ; B $683B
	db $9B, $4F, $5C ; B $683D
	db $80, $00 ; B $6840
	db $97, $4F, $13 ; B $6842
	db $80, $00 ; B $6845
	db $9B, $4A, $5C ; B $6847
	db $80, $00 ; B $684A
	db $98, $4A, $12 ; B $684C
	db $80, $01 ; B $684F
	db $9C, $48, $0C ; B $6851
	db $80, $00 ; B $6854
	db $9C, $47, $0C ; B $6856
	db $80, $00 ; B $6859
	db $9C, $48, $0C ; B $685B
	db $80, $01 ; B $685E
	db $9C, $43, $09 ; B $6860
	db $80, $0F ; B $6863
	db $9C, $4F, $09 ; B $6865
	db $80, $04 ; B $6868
	db $9C, $48, $0C ; B $686A
	db $80, $00 ; B $686D
	db $9C, $47, $0C ; B $686F
	db $80, $00 ; B $6872
	db $9C, $48, $0C ; B $6874
	db $80, $00 ; B $6877
	db $9C, $43, $09 ; B $6879
	db $80, $1C ; B $687C
	db $9C, $48, $0C ; B $687E
	db $80, $01 ; B $6881
	db $9C, $47, $0C ; B $6883
	db $80, $00 ; B $6886
	db $9C, $48, $0C ; B $6888
	db $80, $00 ; B $688B
	db $9C, $4A, $19 ; B $688D
	db $80, $00 ; B $6890
	db $9C, $48, $0C ; B $6892
	db $80, $00 ; B $6895
	db $9C, $43, $37 ; B $6897
	db $80, $07 ; B $689A
	db $9C, $4A, $0C ; B $689C
	db $80, $00 ; B $689F
	db $9C, $48, $0C ; B $68A1
	db $80, $00 ; B $68A4
	db $9C, $47, $0C ; B $68A6
	db $80, $01 ; B $68A9
	db $9C, $48, $0C ; B $68AB
	db $80, $00 ; B $68AE
	db $9C, $43, $09 ; B $68B0
	db $80, $10 ; B $68B3
	db $9C, $4F, $09 ; B $68B5
	db $80, $03 ; B $68B8
	db $9C, $48, $0C ; B $68BA
	db $80, $00 ; B $68BD
	db $9C, $47, $0C ; B $68BF
	db $80, $01 ; B $68C2
	db $9C, $48, $0C ; B $68C4
	db $80, $00 ; B $68C7
	db $9C, $43, $09 ; B $68C9
	db $80, $1C ; B $68CC
	db $9C, $48, $0C ; B $68CE
	db $80, $00 ; B $68D1
	db $9C, $47, $0C ; B $68D3
	db $80, $00 ; B $68D6
	db $9C, $48, $0C ; B $68D8
	db $80, $01 ; B $68DB
	db $9C, $4A, $18 ; B $68DD
	db $80, $00 ; B $68E0
	db $9C, $48, $0C ; B $68E2
	db $80, $01 ; B $68E5
	db $9C, $4A, $05 ; B $68E7
	db $80, $01 ; B $68EA
	db $98, $4A, $05 ; B $68EC
	db $80, $01 ; B $68EF
	db $9C, $4C, $06 ; B $68F1
	db $80, $00 ; B $68F4
	db $98, $4A, $05 ; B $68F6
	db $80, $01 ; B $68F9
	db $9C, $4D, $06 ; B $68FB
	db $80, $00 ; B $68FE
	db $98, $4C, $06 ; B $6900
	db $80, $01 ; B $6903
	db $9C, $4F, $12 ; B $6905
	db $80, $00 ; B $6908
	db $98, $4F, $0F ; B $690A
	db $80, $03 ; B $690D
ASSERT @ == $690F

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B21 slot1 linear body", ROMX[$691D], BANK[$10]
ResidualROM10_691D::
BankB21Slot1LinearBody::
	db $80, $19 ; B $691D
	db $9A, $41, $0C ; B $691F
	db $80, $19 ; B $6922
	db $9A, $40, $0C ; B $6924
	db $80, $01 ; B $6927
	db $9A, $3E, $0C ; B $6929
	db $80, $00 ; B $692C
	db $9A, $3C, $0C ; B $692E
	db $80, $00 ; B $6931
	db $9A, $3B, $13 ; B $6933
	db $80, $06 ; B $6936
	db $9A, $49, $07 ; B $6938
	db $80, $05 ; B $693B
	db $9A, $35, $0C ; B $693D
	db $80, $19 ; B $6940
	db $9A, $41, $0C ; B $6942
	db $80, $19 ; B $6945
	db $9A, $43, $0C ; B $6947
	db $80, $00 ; B $694A
	db $9A, $41, $0C ; B $694C
	db $80, $01 ; B $694F
	db $9A, $40, $0C ; B $6951
	db $80, $00 ; B $6954
	db $9A, $3E, $18 ; B $6956
	db $80, $01 ; B $6959
	db $9A, $3C, $0C ; B $695B
	db $80, $00 ; B $695E
	db $9A, $35, $0B ; B $6960
	db $80, $1A ; B $6963
	db $9A, $41, $0B ; B $6965
	db $80, $1A ; B $6968
	db $9A, $3E, $24 ; B $696A
	db $80, $01 ; B $696D
	db $9A, $41, $18 ; B $696F
	db $80, $00 ; B $6972
	db $9A, $45, $0B ; B $6974
	db $80, $02 ; B $6977
	db $9A, $43, $15 ; B $6979
	db $80, $00 ; B $697C
	db $95, $4F, $09 ; B $697E
	db $80, $00 ; B $6981
	db $94, $4F, $03 ; B $6983
	db $80, $04 ; B $6986
	db $9A, $41, $15 ; B $6988
	db $80, $00 ; B $698B
	db $95, $4F, $09 ; B $698D
	db $80, $00 ; B $6990
	db $94, $4F, $03 ; B $6992
	db $80, $03 ; B $6995
	db $9A, $40, $16 ; B $6997
	db $80, $00 ; B $699A
	db $95, $4F, $09 ; B $699C
	db $80, $00 ; B $699F
	db $94, $4F, $03 ; B $69A1
	db $80, $03 ; B $69A4
	db $9A, $3E, $19 ; B $69A6
	db $80, $00 ; B $69A9
	db $9A, $3B, $0B ; B $69AB
	db $80, $01 ; B $69AE
	db $9A, $35, $0C ; B $69B0
	db $80, $19 ; B $69B3
	db $9A, $41, $0C ; B $69B5
	db $80, $19 ; B $69B8
	db $9A, $40, $0C ; B $69BA
	db $80, $00 ; B $69BD
	db $9A, $3E, $0C ; B $69BF
	db $80, $01 ; B $69C2
	db $9A, $3C, $0C ; B $69C4
	db $80, $00 ; B $69C7
	db $9A, $3B, $13 ; B $69C9
	db $80, $06 ; B $69CC
	db $9A, $49, $07 ; B $69CE
	db $80, $05 ; B $69D1
	db $9A, $35, $0C ; B $69D3
	db $80, $19 ; B $69D6
	db $9A, $41, $0B ; B $69D8
	db $80, $1A ; B $69DB
	db $9A, $43, $0C ; B $69DD
	db $80, $00 ; B $69E0
	db $9A, $41, $0C ; B $69E2
	db $80, $00 ; B $69E5
	db $9A, $40, $0C ; B $69E7
	db $80, $01 ; B $69EA
	db $9A, $3E, $18 ; B $69EC
	db $80, $00 ; B $69EF
	db $9A, $3C, $0C ; B $69F1
	db $80, $01 ; B $69F4
	db $9A, $35, $0B ; B $69F6
	db $80, $1A ; B $69F9
	db $9A, $41, $0B ; B $69FB
	db $80, $1A ; B $69FE
	db $9A, $3E, $24 ; B $6A00
	db $80, $00 ; B $6A03
	db $9A, $41, $25 ; B $6A05
	db $80, $00 ; B $6A08
	db $9A, $43, $16 ; B $6A0A
	db $80, $00 ; B $6A0D
	db $95, $54, $09 ; B $6A0F
	db $80, $00 ; B $6A12
	db $94, $54, $03 ; B $6A14
	db $80, $03 ; B $6A17
	db $9A, $41, $16 ; B $6A19
	db $80, $00 ; B $6A1C
	db $95, $54, $09 ; B $6A1E
	db $80, $00 ; B $6A21
	db $94, $54, $03 ; B $6A23
	db $80, $03 ; B $6A26
	db $9A, $40, $15 ; B $6A28
	db $80, $01 ; B $6A2B
	db $95, $54, $09 ; B $6A2D
	db $80, $00 ; B $6A30
	db $94, $54, $03 ; B $6A32
	db $80, $03 ; B $6A35
	db $9A, $3E, $16 ; B $6A37
	db $80, $03 ; B $6A3A
	db $9A, $3B, $0C ; B $6A3C
	db $80, $00 ; B $6A3F
	db $9A, $3C, $4A ; B $6A41
	db $80, $00 ; B $6A44
	db $9A, $3B, $25 ; B $6A46
	db $80, $00 ; B $6A49
	db $9A, $3E, $49 ; B $6A4B
	db $80, $01 ; B $6A4E
	db $9A, $41, $24 ; B $6A50
	db $80, $01 ; B $6A53
	db $9A, $40, $0C ; B $6A55
	db $80, $00 ; B $6A58
	db $9A, $3F, $0C ; B $6A5A
	db $80, $00 ; B $6A5D
	db $9A, $40, $0C ; B $6A5F
	db $80, $01 ; B $6A62
	db $9A, $3F, $09 ; B $6A64
	db $80, $03 ; B $6A67
	db $98, $54, $06 ; B $6A69
	db $80, $00 ; B $6A6C
	db $95, $54, $06 ; B $6A6E
	db $80, $00 ; B $6A71
	db $9A, $39, $0C ; B $6A73
	db $80, $00 ; B $6A76
	db $9A, $38, $0C ; B $6A78
	db $80, $01 ; B $6A7B
	db $9A, $39, $0C ; B $6A7D
	db $80, $00 ; B $6A80
	db $9A, $38, $06 ; B $6A82
	db $80, $00 ; B $6A85
	db $98, $54, $05 ; B $6A87
	db $80, $01 ; B $6A8A
	db $9A, $41, $0C ; B $6A8C
	db $80, $01 ; B $6A8F
	db $9A, $40, $0C ; B $6A91
	db $80, $00 ; B $6A94
	db $9A, $41, $0C ; B $6A96
	db $80, $00 ; B $6A99
	db $9A, $40, $09 ; B $6A9B
	db $80, $04 ; B $6A9E
	db $98, $54, $05 ; B $6AA0
	db $80, $01 ; B $6AA3
	db $95, $54, $06 ; B $6AA5
	db $80, $00 ; B $6AA8
	db $9A, $3C, $0C ; B $6AAA
	db $80, $00 ; B $6AAD
	db $9A, $3B, $0C ; B $6AAF
	db $80, $01 ; B $6AB2
	db $9A, $3C, $0C ; B $6AB4
	db $80, $00 ; B $6AB7
	db $9A, $3B, $06 ; B $6AB9
	db $80, $00 ; B $6ABC
	db $98, $54, $05 ; B $6ABE
	db $80, $01 ; B $6AC1
	db $9A, $43, $0C ; B $6AC3
	db $80, $00 ; B $6AC6
	db $9A, $42, $0C ; B $6AC8
	db $80, $01 ; B $6ACB
	db $9A, $43, $0C ; B $6ACD
	db $80, $00 ; B $6AD0
	db $9A, $45, $09 ; B $6AD2
	db $80, $03 ; B $6AD5
	db $98, $54, $06 ; B $6AD7
	db $80, $01 ; B $6ADA
	db $95, $54, $05 ; B $6ADC
	db $80, $01 ; B $6ADF
	db $9A, $40, $0C ; B $6AE1
	db $80, $00 ; B $6AE4
	db $9A, $3F, $0C ; B $6AE6
	db $80, $00 ; B $6AE9
	db $9A, $40, $0C ; B $6AEB
	db $80, $01 ; B $6AEE
	db $9A, $41, $05 ; B $6AF0
	db $80, $01 ; B $6AF3
	db $98, $54, $04 ; B $6AF5
	db $80, $02 ; B $6AF8
	db $9A, $43, $0C ; B $6AFA
	db $80, $00 ; B $6AFD
	db $9A, $42, $0C ; B $6AFF
	db $80, $01 ; B $6B02
	db $9A, $43, $0C ; B $6B04
	db $80, $00 ; B $6B07
	db $9A, $45, $09 ; B $6B09
	db $80, $03 ; B $6B0C
	db $98, $54, $06 ; B $6B0E
	db $80, $00 ; B $6B11
	db $95, $54, $06 ; B $6B13
	db $80, $00 ; B $6B16
	db $9A, $43, $0C ; B $6B18
	db $80, $01 ; B $6B1B
	db $9A, $42, $0C ; B $6B1D
	db $80, $00 ; B $6B20
	db $9A, $43, $0C ; B $6B22
	db $80, $00 ; B $6B25
	db $9A, $41, $06 ; B $6B27
	db $80, $01 ; B $6B2A
	db $98, $54, $04 ; B $6B2C
	db $80, $02 ; B $6B2F
	db $9A, $40, $37 ; B $6B31
	db $80, $06 ; B $6B34
	db $9A, $4E, $09 ; B $6B36
	db $80, $04 ; B $6B39
	db $9A, $40, $2E ; B $6B3B
	db $80, $0F ; B $6B3E
	db $9A, $3C, $0C ; B $6B40
	db $80, $00 ; B $6B43
	db $9A, $40, $25 ; B $6B45
	db $80, $00 ; B $6B48
	db $9A, $41, $25 ; B $6B4A
	db $80, $00 ; B $6B4D
	db $9A, $3E, $06 ; B $6B4F
	db $80, $00 ; B $6B52
	db $95, $3E, $06 ; B $6B54
	db $80, $01 ; B $6B57
	db $9A, $3C, $05 ; B $6B59
	db $80, $01 ; B $6B5C
	db $95, $3E, $05 ; B $6B5E
	db $80, $01 ; B $6B61
	db $9A, $3B, $06 ; B $6B63
	db $80, $00 ; B $6B66
	db $95, $3C, $05 ; B $6B68
	db $80, $01 ; B $6B6B
	db $9A, $37, $13 ; B $6B6D
	db $80, $06 ; B $6B70
	db $9A, $49, $0C ; B $6B72
	db $80, $00 ; B $6B75
	db $9A, $40, $37 ; B $6B77
	db $80, $07 ; B $6B7A
	db $9A, $4E, $09 ; B $6B7C
	db $80, $03 ; B $6B7F
	db $9A, $40, $2E ; B $6B81
	db $80, $0F ; B $6B84
	db $9A, $3C, $0C ; B $6B86
	db $80, $01 ; B $6B89
	db $9A, $40, $24 ; B $6B8B
	db $80, $01 ; B $6B8E
	db $9A, $41, $24 ; B $6B90
	db $80, $01 ; B $6B93
	db $9A, $43, $24 ; B $6B95
	db $80, $01 ; B $6B98
	db $9A, $41, $12 ; B $6B9A
	db $80, $00 ; B $6B9D
	db $95, $41, $0F ; B $6B9F
	db $80, $03 ; B $6BA2
ASSERT @ == $6BA4

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B21 slot2 linear body", ROMX[$6BB2], BANK[$10]
ResidualROM10_6BB2::
BankB21Slot2LinearBody::
	db $80, $00 ; B $6BB2
	db $9A, $37, $25 ; B $6BB4
	db $80, $00 ; B $6BB7
	db $9A, $34, $38 ; B $6BB9
	db $80, $06 ; B $6BBC
	db $9A, $35, $0C ; B $6BBE
	db $80, $00 ; B $6BC1
	db $9A, $39, $25 ; B $6BC3
	db $80, $00 ; B $6BC6
	db $9A, $37, $25 ; B $6BC8
	db $80, $00 ; B $6BCB
	db $9A, $32, $37 ; B $6BCD
	db $80, $07 ; B $6BD0
	db $9A, $35, $0C ; B $6BD2
	db $80, $00 ; B $6BD5
	db $9A, $39, $25 ; B $6BD7
	db $80, $00 ; B $6BDA
	db $9A, $37, $24 ; B $6BDC
	db $80, $01 ; B $6BDF
	db $9A, $35, $24 ; B $6BE1
	db $80, $01 ; B $6BE4
	db $9A, $32, $15 ; B $6BE6
	db $80, $03 ; B $6BE9
	db $9A, $35, $0C ; B $6BEB
	db $80, $01 ; B $6BEE
	db $9A, $37, $24 ; B $6BF0
	db $80, $01 ; B $6BF3
	db $9A, $35, $24 ; B $6BF5
	db $80, $00 ; B $6BF8
	db $9A, $34, $25 ; B $6BFA
	db $80, $00 ; B $6BFD
	db $9A, $32, $25 ; B $6BFF
	db $80, $00 ; B $6C02
	db $9A, $39, $25 ; B $6C04
	db $80, $00 ; B $6C07
	db $9A, $37, $25 ; B $6C09
	db $80, $00 ; B $6C0C
	db $9A, $34, $38 ; B $6C0E
	db $80, $06 ; B $6C11
	db $9A, $35, $0C ; B $6C13
	db $80, $00 ; B $6C16
	db $9A, $39, $25 ; B $6C18
	db $80, $00 ; B $6C1B
	db $9A, $37, $25 ; B $6C1D
	db $80, $00 ; B $6C20
	db $9A, $32, $37 ; B $6C22
	db $80, $06 ; B $6C25
	db $9A, $35, $0C ; B $6C27
	db $80, $01 ; B $6C2A
	db $9A, $39, $24 ; B $6C2C
	db $80, $01 ; B $6C2F
	db $9A, $37, $24 ; B $6C31
	db $80, $01 ; B $6C34
	db $9A, $35, $24 ; B $6C36
	db $80, $00 ; B $6C39
	db $9A, $32, $16 ; B $6C3B
	db $80, $03 ; B $6C3E
	db $9A, $34, $0C ; B $6C40
	db $80, $00 ; B $6C43
	db $9A, $37, $25 ; B $6C45
	db $80, $00 ; B $6C48
	db $9A, $35, $25 ; B $6C4A
	db $80, $00 ; B $6C4D
	db $9A, $34, $25 ; B $6C4F
	db $80, $00 ; B $6C52
	db $9A, $32, $25 ; B $6C54
	db $80, $00 ; B $6C57
	db $9A, $34, $5B ; B $6C59
	db $80, $01 ; B $6C5C
	db $98, $34, $13 ; B $6C5E
	db $80, $00 ; B $6C61
	db $9A, $32, $5B ; B $6C63
	db $80, $01 ; B $6C66
	db $98, $34, $12 ; B $6C68
	db $80, $01 ; B $6C6B
	db $9A, $34, $5B ; B $6C6D
	db $80, $01 ; B $6C70
	db $98, $32, $12 ; B $6C72
	db $80, $00 ; B $6C75
	db $9A, $32, $5C ; B $6C77
	db $80, $01 ; B $6C7A
	db $98, $34, $12 ; B $6C7C
	db $80, $00 ; B $6C7F
	db $9A, $3C, $5B ; B $6C81
	db $80, $01 ; B $6C84
	db $98, $32, $13 ; B $6C86
	db $80, $00 ; B $6C89
	db $9A, $3B, $49 ; B $6C8B
	db $80, $01 ; B $6C8E
	db $9A, $37, $24 ; B $6C90
	db $80, $01 ; B $6C93
	db $9A, $34, $1B ; B $6C95
	db $80, $00 ; B $6C98
	db $98, $54, $09 ; B $6C9A
	db $80, $01 ; B $6C9D
	db $9A, $32, $1B ; B $6C9F
	db $80, $00 ; B $6CA2
	db $98, $54, $09 ; B $6CA4
	db $80, $01 ; B $6CA7
	db $9A, $34, $1B ; B $6CA9
	db $80, $00 ; B $6CAC
	db $98, $54, $09 ; B $6CAE
	db $80, $00 ; B $6CB1
	db $9A, $32, $1C ; B $6CB3
	db $80, $00 ; B $6CB6
	db $98, $54, $09 ; B $6CB8
	db $80, $00 ; B $6CBB
	db $9A, $34, $1C ; B $6CBD
	db $80, $00 ; B $6CC0
	db $98, $54, $09 ; B $6CC2
	db $80, $00 ; B $6CC5
	db $9A, $35, $1C ; B $6CC7
	db $80, $00 ; B $6CCA
	db $98, $54, $09 ; B $6CCC
	db $80, $00 ; B $6CCF
	db $9A, $37, $1C ; B $6CD1
	db $80, $00 ; B $6CD4
	db $98, $54, $09 ; B $6CD6
	db $80, $00 ; B $6CD9
	db $9A, $32, $1C ; B $6CDB
	db $80, $00 ; B $6CDE
	db $98, $54, $09 ; B $6CE0
	db $80, $00 ; B $6CE3
	db $9A, $34, $1B ; B $6CE5
	db $80, $01 ; B $6CE8
	db $98, $54, $09 ; B $6CEA
	db $80, $00 ; B $6CED
	db $9A, $32, $1B ; B $6CEF
	db $80, $01 ; B $6CF2
	db $98, $54, $09 ; B $6CF4
	db $80, $00 ; B $6CF7
	db $9A, $34, $1B ; B $6CF9
	db $80, $01 ; B $6CFC
	db $98, $54, $09 ; B $6CFE
	db $80, $00 ; B $6D01
	db $9A, $32, $1B ; B $6D03
	db $80, $01 ; B $6D06
	db $98, $54, $08 ; B $6D08
	db $80, $01 ; B $6D0B
	db $9A, $34, $1B ; B $6D0D
	db $80, $00 ; B $6D10
	db $98, $54, $09 ; B $6D12
	db $80, $01 ; B $6D15
	db $9A, $35, $1B ; B $6D17
	db $80, $00 ; B $6D1A
	db $98, $54, $09 ; B $6D1C
	db $80, $01 ; B $6D1F
	db $9A, $37, $24 ; B $6D21
	db $80, $01 ; B $6D24
	db $9A, $3B, $24 ; B $6D26
	db $80, $00 ; B $6D29 (static zero-count tail; runtime probe stops here)
ASSERT @ == $6D2B

; PROBABLE straight-line continuation, stopping before first FE loop edge.
SECTION "B21 slot3 linear body", ROMX[$6D3B], BANK[$10]
ResidualROM10_6D3B::
BankB21Slot3LinearBody::
	db $97, $2E, $01 ; B $6D3B
	db $80, $0B ; B $6D3E
	db $98, $2E, $01 ; B $6D40
	db $80, $18 ; B $6D43
	db $98, $24, $01 ; B $6D45
	db $80, $0B ; B $6D48
	db $9A, $24, $01 ; B $6D4A
	db $80, $18 ; B $6D4D
	db $97, $2E, $01 ; B $6D4F
	db $80, $0B ; B $6D52
	db $98, $2E, $01 ; B $6D54
	db $80, $18 ; B $6D57
	db $96, $24, $01 ; B $6D59
	db $80, $0B ; B $6D5C
	db $9A, $24, $01 ; B $6D5E
	db $80, $18 ; B $6D61
	db $97, $2E, $01 ; B $6D63
	db $80, $0B ; B $6D66
	db $98, $2E, $01 ; B $6D68
	db $80, $18 ; B $6D6B
	db $98, $24, $01 ; B $6D6D
	db $80, $0B ; B $6D70
	db $9A, $24, $01 ; B $6D72
	db $80, $18 ; B $6D75
	db $97, $2E, $00 ; B $6D77
	db $80, $0C ; B $6D7A
	db $98, $2E, $01 ; B $6D7C
	db $80, $18 ; B $6D7F
	db $96, $24, $00 ; B $6D81
	db $80, $0C ; B $6D84
	db $9A, $24, $01 ; B $6D86
	db $80, $18 ; B $6D89
	db $97, $2E, $00 ; B $6D8B
	db $80, $0C ; B $6D8E
	db $98, $2E, $01 ; B $6D90
	db $80, $17 ; B $6D93
	db $98, $24, $01 ; B $6D95
	db $80, $0C ; B $6D98
	db $9A, $24, $01 ; B $6D9A
	db $80, $17 ; B $6D9D
	db $97, $2E, $01 ; B $6D9F
	db $80, $0C ; B $6DA2
	db $98, $2E, $00 ; B $6DA4
	db $80, $18 ; B $6DA7
	db $96, $24, $01 ; B $6DA9
	db $80, $0C ; B $6DAC
	db $9A, $24, $00 ; B $6DAE
	db $80, $18 ; B $6DB1
	db $97, $2E, $01 ; B $6DB3
	db $80, $0C ; B $6DB6
	db $98, $2E, $00 ; B $6DB8
	db $80, $18 ; B $6DBB
	db $98, $24, $01 ; B $6DBD
	db $80, $0B ; B $6DC0
	db $96, $2E, $01 ; B $6DC2
	db $80, $03 ; B $6DC5
	db $97, $2E, $00 ; B $6DC7
	db $80, $03 ; B $6DCA
	db $96, $2E, $00 ; B $6DCC
	db $80, $06 ; B $6DCF
	db $97, $2E, $01 ; B $6DD1
	db $80, $0B ; B $6DD4
	db $98, $2E, $01 ; B $6DD6
	db $80, $0B ; B $6DD9
	db $9A, $24, $01 ; B $6DDB
	db $80, $18 ; B $6DDE
	db $98, $2E, $01 ; B $6DE0
	db $80, $0B ; B $6DE3
	db $9A, $24, $01 ; B $6DE5
	db $80, $18 ; B $6DE8
	db $97, $2E, $01 ; B $6DEA
	db $80, $0B ; B $6DED
	db $98, $2E, $01 ; B $6DEF
	db $80, $18 ; B $6DF2
	db $98, $24, $01 ; B $6DF4
	db $80, $0B ; B $6DF7
	db $9A, $24, $01 ; B $6DF9
	db $80, $18 ; B $6DFC
	db $97, $2E, $01 ; B $6DFE
	db $80, $0B ; B $6E01
	db $98, $2E, $01 ; B $6E03
	db $80, $18 ; B $6E06
	db $96, $24, $00 ; B $6E08
	db $80, $0C ; B $6E0B
	db $9A, $24, $01 ; B $6E0D
	db $80, $18 ; B $6E10
	db $97, $2E, $00 ; B $6E12
	db $80, $0C ; B $6E15
	db $98, $2E, $01 ; B $6E17
	db $80, $18 ; B $6E1A
	db $98, $24, $00 ; B $6E1C
	db $80, $0C ; B $6E1F
	db $9A, $24, $01 ; B $6E21
	db $80, $17 ; B $6E24
	db $97, $2E, $01 ; B $6E26
	db $80, $0C ; B $6E29
	db $98, $2E, $01 ; B $6E2B
	db $80, $17 ; B $6E2E
	db $96, $24, $01 ; B $6E30
	db $80, $0C ; B $6E33
	db $9A, $24, $00 ; B $6E35
	db $80, $18 ; B $6E38
	db $97, $2E, $01 ; B $6E3A
	db $80, $0C ; B $6E3D
	db $98, $2E, $00 ; B $6E3F
	db $80, $18 ; B $6E42
	db $98, $24, $01 ; B $6E44
	db $80, $0C ; B $6E47
	db $9A, $24, $00 ; B $6E49
	db $80, $18 ; B $6E4C
	db $97, $2E, $01 ; B $6E4E
	db $80, $0B ; B $6E51
	db $98, $2E, $01 ; B $6E53
	db $80, $18 ; B $6E56
	db $96, $24, $01 ; B $6E58
	db $80, $0B ; B $6E5B
	db $9A, $24, $01 ; B $6E5D
	db $80, $18 ; B $6E60
	db $97, $2E, $01 ; B $6E62
	db $80, $0B ; B $6E65
	db $98, $2E, $01 ; B $6E67
	db $80, $18 ; B $6E6A
	db $98, $24, $01 ; B $6E6C
	db $80, $0B ; B $6E6F
	db $96, $2E, $01 ; B $6E71
	db $80, $02 ; B $6E74
	db $97, $2E, $01 ; B $6E76
	db $80, $02 ; B $6E79
	db $96, $2E, $01 ; B $6E7B
	db $80, $06 ; B $6E7E
	db $97, $2E, $00 ; B $6E80
	db $80, $0C ; B $6E83
	db $98, $2E, $01 ; B $6E85
	db $80, $0B ; B $6E88
	db $9A, $24, $01 ; B $6E8A
	db $80, $18 ; B $6E8D
	db $98, $2E, $01 ; B $6E8F
	db $80, $0B ; B $6E92
	db $9A, $24, $01 ; B $6E94
	db $80, $24 ; B $6E97
	db $97, $2E, $01 ; B $6E99
	db $80, $18 ; B $6E9C
	db $98, $2E, $00 ; B $6E9E
	db $80, $0C ; B $6EA1
	db $9A, $24, $01 ; B $6EA3
	db $80, $18 ; B $6EA6
	db $97, $2E, $00 ; B $6EA8
	db $80, $0C ; B $6EAB
	db $9A, $24, $01 ; B $6EAD
	db $80, $24 ; B $6EB0
	db $97, $2E, $01 ; B $6EB2
	db $80, $17 ; B $6EB5
	db $98, $2E, $01 ; B $6EB7
	db $80, $0C ; B $6EBA
	db $9A, $24, $00 ; B $6EBC
	db $80, $0C ; B $6EBF
	db $98, $2E, $01 ; B $6EC1
	db $80, $0B ; B $6EC4
	db $98, $24, $01 ; B $6EC6
	db $80, $0C ; B $6EC9
	db $9A, $24, $00 ; B $6ECB
	db $80, $25 ; B $6ECE
	db $97, $2E, $00 ; B $6ED0
	db $80, $18 ; B $6ED3
	db $98, $2E, $01 ; B $6ED5
	db $80, $0B ; B $6ED8
	db $9A, $24, $01 ; B $6EDA
	db $80, $18 ; B $6EDD
	db $97, $2E, $01 ; B $6EDF
	db $80, $0B ; B $6EE2
	db $9A, $24, $01 ; B $6EE4
	db $80, $24 ; B $6EE7
	db $97, $2E, $01 ; B $6EE9
	db $80, $18 ; B $6EEC
	db $98, $2E, $01 ; B $6EEE
	db $80, $0B ; B $6EF1
	db $9A, $24, $01 ; B $6EF3
	db $80, $0C ; B $6EF6
	db $98, $2E, $00 ; B $6EF8
	db $80, $0C ; B $6EFB
	db $98, $24, $01 ; B $6EFD
	db $80, $0B ; B $6F00
	db $9A, $24, $01 ; B $6F02
	db $80, $24 ; B $6F05
	db $97, $2E, $01 ; B $6F07
	db $80, $18 ; B $6F0A
	db $98, $2E, $00 ; B $6F0C
	db $80, $0C ; B $6F0F
	db $9A, $24, $01 ; B $6F11
	db $80, $18 ; B $6F14
	db $97, $2E, $00 ; B $6F16
	db $80, $0C ; B $6F19
	db $9A, $24, $01 ; B $6F1B
	db $80, $24 ; B $6F1E
	db $97, $2E, $01 ; B $6F20
	db $80, $17 ; B $6F23
	db $98, $2E, $01 ; B $6F25
	db $80, $0C ; B $6F28
	db $9A, $24, $01 ; B $6F2A
	db $80, $0B ; B $6F2D
	db $97, $2E, $01 ; B $6F2F
	db $80, $0B ; B $6F32
	db $98, $2E, $01 ; B $6F34
	db $80, $0C ; B $6F37
	db $97, $2E, $00 ; B $6F39
	db $80, $18 ; B $6F3C
	db $98, $2E, $01 ; B $6F3E
	db $80, $0C ; B $6F41
	db $9A, $24, $00 ; B $6F43
	db $80, $18 ; B $6F46
	db $96, $2E, $01 ; B $6F48
	db $80, $0C ; B $6F4B
	db $97, $2E, $00 ; B $6F4D
	db $80, $18 ; B $6F50
	db $98, $2E, $01 ; B $6F52
	db $80, $0B ; B $6F55
	db $9A, $24, $01 ; B $6F57
	db $80, $18 ; B $6F5A
	db $96, $2E, $01 ; B $6F5C
	db $80, $0B ; B $6F5F
	db $97, $2E, $01 ; B $6F61
	db $80, $18 ; B $6F64
	db $98, $2E, $01 ; B $6F66
	db $80, $0B ; B $6F69
	db $9A, $24, $01 ; B $6F6B
	db $80, $18 ; B $6F6E
	db $96, $2E, $01 ; B $6F70
	db $80, $0B ; B $6F73
	db $9A, $24, $01 ; B $6F75
	db $80, $08 ; B $6F78
	db $96, $2E, $01 ; B $6F7A
	db $80, $03 ; B $6F7D
	db $97, $2E, $00 ; B $6F7F
	db $80, $03 ; B $6F82
	db $96, $2E, $00 ; B $6F84
	db $80, $09 ; B $6F87
	db $98, $2E, $01 ; B $6F89
	db $80, $0B ; B $6F8C
	db $9A, $24, $01 ; B $6F8E
	db $80, $18 ; B $6F91
	db $98, $2E, $01 ; B $6F93
	db $80, $0B ; B $6F96
	db $97, $2E, $01 ; B $6F98
	db $80, $18 ; B $6F9B
	db $98, $2E, $00 ; B $6F9D
	db $80, $0C ; B $6FA0
	db $9A, $24, $01 ; B $6FA2
	db $80, $18 ; B $6FA5
	db $96, $2E, $00 ; B $6FA7
	db $80, $0C ; B $6FAA
	db $97, $2E, $01 ; B $6FAC
	db $80, $18 ; B $6FAF
	db $98, $2E, $00 ; B $6FB1
	db $80, $0C ; B $6FB4
	db $9A, $24, $01 ; B $6FB6
	db $80, $17 ; B $6FB9
	db $96, $2E, $01 ; B $6FBB
	db $80, $0C ; B $6FBE
	db $97, $2E, $01 ; B $6FC0
	db $80, $17 ; B $6FC3
	db $98, $2E, $01 ; B $6FC5
	db $80, $0C ; B $6FC8
	db $9A, $24, $00 ; B $6FCA
	db $80, $18 ; B $6FCD
	db $96, $2E, $01 ; B $6FCF
	db $80, $0C ; B $6FD2
	db $9A, $24, $00 ; B $6FD4
	db $80, $0C ; B $6FD7
	db $97, $2E, $01 ; B $6FD9
	db $80, $0B ; B $6FDC
	db $98, $24, $01 ; B $6FDE
	db $80, $0C ; B $6FE1
	db $96, $2E, $00 ; B $6FE3
	db $80, $03 ; B $6FE6
	db $97, $2E, $00 ; B $6FE8
	db $80, $03 ; B $6FEB
	db $96, $2E, $00 ; B $6FED
	db $80, $06 ; B $6FF0
	db $98, $2E, $01 ; B $6FF2
	db $80, $0B ; B $6FF5
	db $96, $2E, $01 ; B $6FF7
	db $80, $0B ; B $6FFA
ASSERT @ == $6FFC

; PROBABLE FE restart with original saved count0; FF fallback tested with count1.
SECTION "B21 slot0 first loop edge", ROMX[$690F], BANK[$10]
ResidualROM10_690F::
BankB21Slot0FirstLoopEdge::
	db $FE, $00
BankB21Slot0FirstLoopFallback::
	db $FF
ASSERT @ == $6912

; PROBABLE FE restart with original saved count0; FF fallback tested with count1.
SECTION "B21 slot1 first loop edge", ROMX[$6BA4], BANK[$10]
ResidualROM10_6BA4::
BankB21Slot1FirstLoopEdge::
	db $FE, $00
BankB21Slot1FirstLoopFallback::
	db $FF
ASSERT @ == $6BA7

; PROBABLE FE restart with original saved count0; FF fallback tested with count1.
SECTION "B21 slot2 first loop edge", ROMX[$6D2B], BANK[$10]
ResidualROM10_6D2B::
BankB21Slot2FirstLoopEdge::
	db $FE, $00
BankB21Slot2FirstLoopFallback::
	db $FF
ASSERT @ == $6D2E

; PROBABLE FE restart with original saved count0; FF fallback tested with count1.
SECTION "B21 slot3 first loop edge", ROMX[$6FFC], BANK[$10]
ResidualROM10_6FFC::
BankB21Slot3FirstLoopEdge::
	db $FE, $00
BankB21Slot3FirstLoopFallback::
	db $FF
ASSERT @ == $6FFF
