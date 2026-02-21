pragma circom 2.0.0;

include "../../circuits/utils.circom";

// 3 choices, 5 votes -> count[0], count[1], count[2]
template TallyTest() {
    signal input votes[5];
    signal output count[3];
    component t = Tally(3, 5);
    for (var i = 0; i < 5; i++) {
        t.votes[i] <== votes[i];
    }
    for (var c = 0; c < 3; c++) {
        count[c] <== t.count[c];
    }
}

component main = TallyTest();
