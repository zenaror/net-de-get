; PROBABLE measured prefix; arbitrary parameters can read beyond this range.
SECTION "Color transition count prefix 08F2-08FA", ROM0[$08F2]
ColorTransitionCountPrefix::
 db $20, $10, $08, $04, $02, $01
ColorTransitionRightCounts::
 db $20, $40, $80
ASSERT @ == $08FB
