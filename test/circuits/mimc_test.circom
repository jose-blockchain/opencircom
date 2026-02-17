pragma circom 2.0.0;

include "../../circuits/hashing/mimc.circom";

template MiMCTest() {
    signal input x;
    signal input k;
    signal output out;
    component m = MiMC7(91);
    m.x_in <== x;
    m.k <== k;
    out <== m.out;
}

component main = MiMCTest();
