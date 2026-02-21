pragma circom 2.0.0;

include "../../circuits/utils.circom";

template PadBits10StarTest() {
    signal input in[4];
    signal output out[8];
    component p = PadBits10Star(4, 8);
    for (var i = 0; i < 4; i++) {
        p.in[i] <== in[i];
    }
    for (var i = 0; i < 8; i++) {
        out[i] <== p.out[i];
    }
}

component main = PadBits10StarTest();
