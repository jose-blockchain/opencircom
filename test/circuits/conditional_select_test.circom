pragma circom 2.0.0;

include "../../circuits/utils.circom";

template ConditionalSelectTest() {
    signal input condition;
    signal input a;
    signal input b;
    signal output out;
    component c = ConditionalSelect();
    c.condition <== condition;
    c.a <== a;
    c.b <== b;
    out <== c.out;
}

component main = ConditionalSelectTest();
