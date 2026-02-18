// Message schedule: w[t] = ssigma1(w[t-2]) + w[t-7] + ssigma0(w[t-15]) + w[t-16] (FIPS 180-4).
pragma circom 2.0.0;

include "../../binsum.circom";
include "sigma.circom";

template SigmaPlus() {
    signal input in2[32];
    signal input in7[32];
    signal input in15[32];
    signal input in16[32];
    signal output out[32];
    component sigma1 = SmallSigma(17, 19, 10);
    component sigma0 = SmallSigma(7, 18, 3);
    for (var k = 0; k < 32; k++) {
        sigma1.in[k] <== in2[k];
        sigma0.in[k] <== in15[k];
    }
    component sum = BinSum(32, 4);
    for (var k = 0; k < 32; k++) {
        sum.in[0][k] <== sigma1.out[k];
        sum.in[1][k] <== in7[k];
        sum.in[2][k] <== sigma0.out[k];
        sum.in[3][k] <== in16[k];
    }
    for (var k = 0; k < 32; k++) {
        out[k] <== sum.out[k];
    }
}
