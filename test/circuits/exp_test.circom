pragma circom 2.0.0;

include "../../circuits/arithmetic.circom";

template ExpTest() {
    signal input base;
    signal input exp[4];
    signal output out;
    component e = ExpByBits(4);
    e.base <== base;
    for (var i = 0; i < 4; i++) {
        e.exp[i] <== exp[i];
    }
    out <== e.out;
}

component main = ExpTest();
