pragma circom 2.0.0;

include "../../circuits/hashing/sha256/sha256.circom";

template Sha256Test() {
    signal input in[512];
    signal output out[256];
    component sha = Sha256(512);
    for (var i = 0; i < 512; i++) {
        sha.in[i] <== in[i];
    }
    for (var i = 0; i < 256; i++) {
        out[i] <== sha.out[i];
    }
}

component main = Sha256Test();
