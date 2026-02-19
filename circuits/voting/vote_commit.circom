pragma circom 2.0.0;

include "../hashing/poseidon.circom";
include "../comparators.circom";

/**
 * @title VoteCommit
 * @notice Commit phase: proves commitment = H(choice, revealIdentity, salt, ballotId) and choice in [0, numChoices).
 * @dev Public input: commitment (contract stores it for reveal phase). Use with VoteReveal for anonymous 1-of-N voting.
 * @param numChoices Number of choices (choice must be < numChoices).
 * @custom:input choice Voter's choice (private).
 * @custom:input revealIdentity Identity used in reveal.
 * @custom:input salt Random salt.
 * @custom:input ballotId Ballot identifier.
 * @custom:input commitment Public commitment (must match H(choice, revealIdentity, salt, ballotId)).
 * @custom:complexity LessThan(32) + Poseidon(4): ~330 constraints. Keep numChoices within 32-bit range.
 * @custom:security Commitment must be published and stored for reveal. choice in [0, numChoices) enforced; ensure ballotId is unique per ballot.
 */
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
