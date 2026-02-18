// T1 = h + Sigma1(e) + Ch(e,f,g) + K + W (FIPS 180-4).
pragma circom 2.0.0;

include "../../binsum.circom";
include "sigma.circom";
include "ch.circom";

template T1() {
    signal input h[32];
    signal input e[32];
    signal input f[32];
    signal input g[32];
    signal input k[32];
    signal input w[32];
    signal output out[32];
    component ch = Ch_t(32);
    component bigsigma1 = BigSigma(6, 11, 25);
    for (var ki = 0; ki < 32; ki++) {
        bigsigma1.in[ki] <== e[ki];
        ch.a[ki] <== e[ki];
        ch.b[ki] <== f[ki];
        ch.c[ki] <== g[ki];
    }
    component sum = BinSum(32, 5);
    for (var ki = 0; ki < 32; ki++) {
        sum.in[0][ki] <== h[ki];
        sum.in[1][ki] <== bigsigma1.out[ki];
        sum.in[2][ki] <== ch.out[ki];
        sum.in[3][ki] <== k[ki];
        sum.in[4][ki] <== w[ki];
    }
    for (var ki = 0; ki < 32; ki++) {
        out[ki] <== sum.out[ki];
    }
}
