pragma circom 2.0.0;

include "../../circuits/voting/vote_reveal.circom";

template Main() {
    signal input choice;
    signal input identity;
    signal input salt;
    signal input ballotId;
    signal input commitment;
    signal output nullifierHash;
    component c = VoteReveal();
    c.choice <== choice;
    c.identity <== identity;
    c.salt <== salt;
    c.ballotId <== ballotId;
    c.commitment <== commitment;
    nullifierHash <== c.nullifierHash;
}
component main {public [choice, ballotId, commitment]} = Main();
