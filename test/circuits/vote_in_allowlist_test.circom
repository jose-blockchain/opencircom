pragma circom 2.0.0;

include "../../circuits/utils.circom";

template VoteInAllowlistTest() {
    signal input vote;
    signal input allowedChoices[3];
    signal output out;
    component v = VoteInAllowlist(3);
    v.vote <== vote;
    for (var i = 0; i < 3; i++) {
        v.allowedChoices[i] <== allowedChoices[i];
    }
    out <== v.out;
}

component main = VoteInAllowlistTest();
