pragma circom 2.0.0;

include "../../circuits/comparators.circom";

template RangeProofTest() {
    signal input x;
    signal input a;
    signal input b;
    signal output out;
    component r = RangeProof(16);
    r.x <== x;
    r.a <== a;
    r.b <== b;
    out <== r.out;
}

component main = RangeProofTest();
