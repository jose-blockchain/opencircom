// Hash 256 bits (e.g. 32 bytes) with SHA-256.
pragma circom 2.0.0;

include "../../circuits/hashing/sha256/sha256.circom";

template Sha256_256_Test() {
    signal input in[256];
    signal output out[256];
    component sha = Sha256(256);
    for (var i = 0; i < 256; i++) {
        sha.in[i] <== in[i];
    }
    for (var i = 0; i < 256; i++) {
        out[i] <== sha.out[i];
    }
}

component main = Sha256_256_Test();
