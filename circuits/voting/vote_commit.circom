pragma circom 2.0.0;

include "../hashing/poseidon.circom";
include "../comparators.circom";

// Commit phase: prove commitment = H(choice, revealIdentity, salt, ballotId) and choice in [0, numChoices).
// Public input: commitment (contract stores it for reveal phase).
template VoteCommit(numChoices) {
    signal input choice;
    signal input revealIdentity;
    signal input salt;
    signal input ballotId;
    signal input commitment;

    component range = LessThan(32);
    range.in[0] <== choice;
    range.in[1] <== numChoices;
    range.out === 1;

    component h = Poseidon(4);
    h.inputs[0] <== choice;
    h.inputs[1] <== revealIdentity;
    h.inputs[2] <== salt;
    h.inputs[3] <== ballotId;
    h.out === commitment;
}
