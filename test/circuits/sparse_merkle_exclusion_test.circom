pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template SparseMerkleExclusionTest() {
    signal input pathElements[2];
    signal input pathIndices[2];
    signal output root;
    component sm = SparseMerkleExclusion(2);
    for (var i = 0; i < 2; i++) {
        sm.pathElements[i] <== pathElements[i];
        sm.pathIndices[i] <== pathIndices[i];
    }
    root <== sm.root;
}

component main = SparseMerkleExclusionTest();
