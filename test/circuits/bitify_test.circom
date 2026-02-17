pragma circom 2.0.0;

include "../../circuits/bitify.circom";

template BitifyTest() {
    signal input in;
    signal output bits[8];
    signal output reconstructed;
    component n2b = Num2Bits(8);
    component b2n = Bits2Num(8);
    n2b.in <== in;
    for (var i = 0; i < 8; i++) {
        bits[i] <== n2b.out[i];
        b2n.in[i] <== n2b.out[i];
    }
    reconstructed <== b2n.out;
}

component main = BitifyTest();
