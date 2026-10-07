; PROBABLE resident jump interface, literal JP slots; no index API implied.
SECTION "Resident jump interface", ROM0[$01BC]
ResidualROM00_01BC::
ResidentJump01BC::
	jp $0D50
ResidentJump01BF::
	jp $0F15
ResidentJump01C2::
	jp $106D
ResidentJump01C5::
	jp RebuildLocalStorageDirectory
ResidentJump01C8::
	jp $113E
ResidentJump01CB::
	jp GetStorageDirectoryEntry
ResidentJump01CE::
	jp GetStorageRecordHeader
ResidentJump01D1::
	jp $1176
ResidentJump01D4::
	jp $269C
ResidentJump01D7::
	jp $271C
ResidentJump01DA::
	jp $2723
ResidentJump01DD::
	jp $272A
ResidentJump01E0::
	jp $2731
ResidentJump01E3::
	jp $2753
ResidentJump01E6::
	jp $2799
ResidentJump01E9::
	jp $27AA
ResidentJump01EC::
	jp $27C1
ResidentJump01EF::
	jp $28BE
ResidentJump01F2::
	jp $28E3
ResidentJump01F5::
	jp $2945
ResidentJump01F8::
	jp $294E
ResidentJump01FB::
	jp $2BFE
ResidentJump01FE::
	jp $2D46
ResidentJump0201::
	jp $2D53
ResidentJump0204::
	jp $2DC3
ResidentJump0207::
	jp $2DD0
ResidentJump020A::
	jp $2DE7
ResidentJump020D::
	jp $2E15
ResidentJump0210::
	jp $2EE9
ResidentJump0213::
	jp $2EFA
ResidentJump0216::
	jp $2F1C
ResidentJump0219::
	jp $2FE0
ResidentJump021C::
	jp $3031
ResidentJump021F::
	jp $30BC
ResidentJump0222::
	jp $3185
ResidentJump0225::
	jp SubtractDEFromHL
ResidentJump0228::
	jp CompareHLAndDE
ResidentJump022B::
	jp $2012
ResidentJump022E::
	jp $2023
ResidentJump0231::
	jp $2035
ResidentJump0234::
	jp $2046
ResidentJump0237::
	jp $2057
ResidentJump023A::
	jp $206A
ResidentJump023D::
	jp $206C
ResidentJump0240::
	jp $218F
ResidentJump0243::
	jp $2198
ResidentJump0246::
	jp $21D7
ResidentJump0249::
	jp CallBankA1EAndRestoreMapping
ResidentJump024C::
	jp $22A7
ResidentJump024F::
	jp $230C
ResidentJump0252::
	jp $235F
ResidentJump0255::
	jp $23CC
ResidentJump0258::
	jp $1186
ResidentJump025B::
	jp $118F
ResidentJump025E::
	jp $118F
ResidentJump0261::
	jp $11AA
ResidentJump0264::
	jp DispatchBankedCallback
ResidentJump0267::
	jp BankedCallbackReturnOnly
ResidentJump026A::
	jp $24B9
ResidentJump026D::
	jp DispatchLocalMinigame
ResidentJump0270::
	jp $25CB
ResidentJump0273::
	jp $25EF
ResidentJump0276::
	jp CopyBytesHLToDE
ResidentJump0279::
	jp $261C
ResidentJump027C::
	jp $2620
ResidentJump027F::
	jp $2685
ResidentJump0282::
	jp CallBankA16_4227
ResidentJump0285::
	jp CallBankA16_424D
ResidentJump0288::
	jp CallBankA16_42CB
ResidentJump028B::
	jp CallBankA16_42EF
ResidentJump028E::
	jp $16B1
ResidentJump0291::
	jp $16BF
ResidentJump0294::
	jp $16D6
ResidentJump0297::
	jp $16ED
ResidentJump029A::
	jp $172D
ResidentJump029D::
	jp $176F
ResidentJump02A0::
	jp $3EDC
ResidentJump02A3::
	jp $3F69
ResidentJump02A6::
	jp $3F3A
ResidentJump02A9::
	jp $3F4C
ResidentJump02AC::
	jp $3F55
ResidentJump02AF::
	jp $3F60
ResidentJump02B2::
	jp $318A
ResidentJump02B5::
	jp $3560
ASSERT @ == $02B8
