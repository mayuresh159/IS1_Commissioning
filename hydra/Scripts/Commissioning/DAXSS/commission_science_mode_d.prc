;IS1 Commission Science Mode D
;Purpose: Send IS-1 to SCI-D and checkout DAXSS
;Outline
;    Check IS1 Batt Volt for Science
;    Check eclipse state
;    Check DAXSS CDH, EPS, SPS, X123 (aliveness)
;
; 16-02-2022: Robert Sewell		Created for IS-1 commissioning

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntDaxss dn16l
declare cmdTryDaxss dn16l
declare cmdSucceedDaxss dn16l
declare DaxssNominalRate dn32l
declare X123State dn16l
declare SPSPicoState dn16l
declare waitInterval dn32l



print cmdTry
print cmdSucceed