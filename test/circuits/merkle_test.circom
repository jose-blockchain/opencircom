pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template MerkleTest() {
    signal input leaf;
    signal input pathElements[2];
    signal input pathIndices[2];
    signal output root;
    component tree = MerkleInclusionProof(2);
    tree.leaf <== leaf;
    for (var i = 0; i < 2; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
    root <== tree.root;
}

component main = MerkleTest();
