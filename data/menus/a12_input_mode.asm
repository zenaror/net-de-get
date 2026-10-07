; PROBABLE original input variant/action pointers; action bodies have separate sources; natural execution remains unproven.
SECTION "A12 input table 475E-4763", ROMX[$475E], BANK[$09]
A12InputVariantTargets::
	dw DispatchA12InputVariant0
	dw DispatchA12InputVariant1
	dw DispatchA12InputVariant2
ASSERT @ == $4764

SECTION "A12 input table 477A-4785", ROMX[$477A], BANK[$09]
A12InputActions0::
	dw A12InputAction0_0
	dw A12InputAction0_1
	dw A12InputAction0_2
	dw A12InputAction0_3
	dw A12InputAction0_4
	dw A12InputAction0_5
ASSERT @ == $4786

SECTION "A12 input table 4870-487B", ROMX[$4870], BANK[$09]
A12InputActions1::
	dw A12InputAction1_0
	dw A12InputAction1_1
	dw A12InputAction1_2
	dw A12InputAction1_3
	dw A12InputAction1_4
	dw A12InputAction1_5
ASSERT @ == $487C

SECTION "A12 input table 4956-4961", ROMX[$4956], BANK[$09]
A12InputActions2::
	dw A12InputAction2_0
	dw A12InputAction2_1
	dw A12InputAction2_2
	dw A12InputAction2_3
	dw A12InputAction2_4
	dw A12InputAction2_5
ASSERT @ == $4962
