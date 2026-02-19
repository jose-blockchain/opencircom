pragma circom 2.0.0;

include "../../circuits/arithmetic.circom";

template DivRemTest() {
    signal input a;
    signal input b;
    signal input q;
    signal input r;
    signal output quotient;
    signal output remainder;
    component divrem = DivRem(16);
    divrem.a <== a;
    divrem.b <== b;
    divrem.q <== q;
    divrem.r <== r;
    quotient <== divrem.quotient;
    remainder <== divrem.remainder;
}

component main = DivRemTest();
