; PROBABLE original input variant/action pointers; target bodies remain unresolved.
SECTION "A12 input table 475E-4763", ROMX[$475E], BANK[$09]
A12InputVariantTargets::
	dw DispatchA12InputVariant0
	dw DispatchA12InputVariant1
	dw DispatchA12InputVariant2
ASSERT @ == $4764

SECTION "A12 input table 477A-4785", ROMX[$477A], BANK[$09]
A12InputActions0::
	dw $4786
	dw $47D2
	dw $47F0
	dw $47A4
	dw $481E
	dw $483C
ASSERT @ == $4786

SECTION "A12 input table 4870-487B", ROMX[$4870], BANK[$09]
A12InputActions1::
	dw $487C
	dw $48B8
	dw $48D6
	dw $489A
	dw $4904
	dw $4922
ASSERT @ == $487C

SECTION "A12 input table 4956-4961", ROMX[$4956], BANK[$09]
A12InputActions2::
	dw $4962
	dw $49AE
	dw $49CC
	dw $4980
	dw $49FA
	dw $4A18
ASSERT @ == $4962
