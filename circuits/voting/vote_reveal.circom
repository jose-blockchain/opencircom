pragma circom 2.0.0;

include "../hashing/poseidon.circom";
include "../merkle/merkle_inclusion.circom";

// Reveal phase: prove (choice, identity, salt, ballotId) match commitment and compute nullifier for double-vote prevention.
// Nullifier = H(H(identity, salt), ballotId). Contract checks commitment was in set and nullifier not yet spent.
template VoteReveal() {
    signal input choice;
    signal input identity;
    signal input salt;
    signal input ballotId;
    signal input commitment;  // must equal H(choice, identity, salt, ballotId); contract verifies it was committed

    signal output nullifierHash;

    component commitmentHash = Poseidon(4);
    commitmentHash.inputs[0] <== choice;
    commitmentHash.inputs[1] <== identity;
    commitmentHash.inputs[2] <== salt;
    commitmentHash.inputs[3] <== ballotId;
    commitmentHash.out === commitment;

    component inner = Poseidon(2);
    inner.inputs[0] <== identity;
    inner.inputs[1] <== salt;

    component n = Nullifier(1);
    n.secret <== inner.out;
    n.externalNullifier <== ballotId;
    nullifierHash <== n.nullifierHash;
}
