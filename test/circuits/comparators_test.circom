pragma circom 2.0.0;

include "../../circuits/comparators.circom";

template ComparatorsTest() {
    signal input a;
    signal input b;
    signal output lt;
    signal output eq;
    component lessThan = LessThan(64);
    component isEqual = IsEqual();
    lessThan.in[0] <== a;
    lessThan.in[1] <== b;
    isEqual.in[0] <== a;
    isEqual.in[1] <== b;
    lt <== lessThan.out;
    eq <== isEqual.out;
}

component main = ComparatorsTest();
