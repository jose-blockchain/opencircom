pragma circom 2.0.0;

include "../../circuits/voting/vote_commit.circom";

template Main() {
    signal input choice;
    signal input revealIdentity;
    signal input salt;
    signal input ballotId;
    signal input commitment;
    component c = VoteCommit(5);
    c.choice <== choice;
    c.revealIdentity <== revealIdentity;
    c.salt <== salt;
    c.ballotId <== ballotId;
    c.commitment <== commitment;
}
component main {public [commitment]} = Main();
