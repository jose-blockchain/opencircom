pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template IncrementalMerkleTest() {
    signal input leaf;
    signal input index;
    signal input pathElements[2];
    signal output root;
    component inc = IncrementalMerkleInclusion(2);
    inc.leaf <== leaf;
    inc.index <== index;
    for (var i = 0; i < 2; i++) {
        inc.pathElements[i] <== pathElements[i];
    }
    root <== inc.root;
}

component main = IncrementalMerkleTest();
