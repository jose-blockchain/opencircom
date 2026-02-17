pragma circom 2.0.0;

include "../../circuits/merkle/merkle_inclusion.circom";

template NullifierTest() {
    signal input secret;
    signal input externalNullifier;
    signal output nullifierHash;
    component n = Nullifier(1);
    n.secret <== secret;
    n.externalNullifier <== externalNullifier;
    nullifierHash <== n.nullifierHash;
}

component main = NullifierTest();
