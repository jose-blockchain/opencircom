pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template MerkleUpdateTest() {
    signal input oldRoot;
    signal input newRoot;
    signal input oldLeaf;
    signal input newLeaf;
    signal input pathElements[2];
    signal input pathIndices[2];
    component upd = MerkleUpdateProof(2);
    upd.oldRoot <== oldRoot;
    upd.newRoot <== newRoot;
    upd.oldLeaf <== oldLeaf;
    upd.newLeaf <== newLeaf;
    for (var i = 0; i < 2; i++) {
        upd.pathElements[i] <== pathElements[i];
        upd.pathIndices[i] <== pathIndices[i];
    }
}

component main = MerkleUpdateTest();
