pragma circom 2.0.0;

include "../../circuits/comparators.circom";

template StrictNum2BitsTest() {
    signal input in;
    signal output out[8];
    component s = StrictNum2Bits(8);
    s.in <== in;
    for (var i = 0; i < 8; i++) {
        out[i] <== s.out[i];
    }
}

component main = StrictNum2BitsTest();
