pragma circom 2.0.0;

include "../../circuits/voting/vote_commit.circom";

template Main() {
    signal input choice;
    signal input allowedChoices[3];
    signal input revealIdentity;
    signal input salt;
    signal input ballotId;
    signal input commitment;
    component c = VoteCommitAllowlist(3);
    c.choice <== choice;
    c.allowedChoices[0] <== allowedChoices[0];
    c.allowedChoices[1] <== allowedChoices[1];
    c.allowedChoices[2] <== allowedChoices[2];
    c.revealIdentity <== revealIdentity;
    c.salt <== salt;
    c.ballotId <== ballotId;
    c.commitment <== commitment;
}
component main { public [commitment] } = Main();
