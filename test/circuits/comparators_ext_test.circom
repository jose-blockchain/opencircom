pragma circom 2.0.0;

include "../../circuits/comparators.circom";

template ComparatorsExtTest() {
    signal input a;
    signal input b;
    signal input single;  // for IsZero
    signal output lt;
    signal output lte;
    signal output gt;
    signal output gte;
    signal output eq;
    signal output isZero;
    component lessThan = LessThan(64);
    component lessEqThan = LessEqThan(64);
    component greaterThan = GreaterThan(64);
    component greaterEqThan = GreaterEqThan(64);
    component isEqual = IsEqual();
    component isZeroC = IsZero();
    lessThan.in[0] <== a;
    lessThan.in[1] <== b;
    lessEqThan.in[0] <== a;
    lessEqThan.in[1] <== b;
    greaterThan.in[0] <== a;
    greaterThan.in[1] <== b;
    greaterEqThan.in[0] <== a;
    greaterEqThan.in[1] <== b;
    isEqual.in[0] <== a;
    isEqual.in[1] <== b;
    isZeroC.in <== single;
    lt <== lessThan.out;
    lte <== lessEqThan.out;
    gt <== greaterThan.out;
    gte <== greaterEqThan.out;
    eq <== isEqual.out;
    isZero <== isZeroC.out;
}

component main = ComparatorsExtTest();
