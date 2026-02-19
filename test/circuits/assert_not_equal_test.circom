pragma circom 2.0.0;

include "../../circuits/comparators.circom";

template AssertNotEqualTest() {
    signal input a;
    signal input b;
    signal output ok;
    component ne = AssertNotEqual();
    ne.in[0] <== a;
    ne.in[1] <== b;
    ok <== 1;
}

component main = AssertNotEqualTest();
