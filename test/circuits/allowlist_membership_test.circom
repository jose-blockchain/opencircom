pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template AllowlistMembershipTest() {
    signal input identity;
    signal input pathElements[2];
    signal input pathIndices[2];
    signal output root;
    component a = AllowlistMembership(2);
    a.identity <== identity;
    for (var i = 0; i < 2; i++) {
        a.pathElements[i] <== pathElements[i];
        a.pathIndices[i] <== pathIndices[i];
    }
    root <== a.root;
}

component main = AllowlistMembershipTest();
