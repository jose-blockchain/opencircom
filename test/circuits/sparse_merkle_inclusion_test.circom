pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template SparseMerkleInclusionTest() {
    signal input leaf;
    signal input pathElements[2];
    signal input pathIndices[2];
    signal output root;
    component sm = SparseMerkleInclusion(2);
    sm.leaf <== leaf;
    for (var i = 0; i < 2; i++) {
        sm.pathElements[i] <== pathElements[i];
        sm.pathIndices[i] <== pathIndices[i];
    }
    root <== sm.root;
}

component main = SparseMerkleInclusionTest();
