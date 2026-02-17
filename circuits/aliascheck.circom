pragma circom 2.0.0;

include "compconstant.circom";

// Ensures in[0..253] represents a field element < p (no overflow).
// Use with Num2Bits(254) output for strict range.
template AliasCheck() {
    signal input in[254];
    component compConstant = CompConstant(-1);
    for (var i = 0; i < 254; i++) in[i] ==> compConstant.in[i];
    compConstant.out === 0;
}
