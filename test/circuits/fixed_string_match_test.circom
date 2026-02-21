pragma circom 2.0.0;

include "../../circuits/string_data.circom";

template FixedStringMatchTest() {
    signal input bytes[4];
    signal input expected[4];
    signal output out;
    component m = FixedStringMatch(4);
    for (var i = 0; i < 4; i++) {
        m.bytes[i] <== bytes[i];
        m.expected[i] <== expected[i];
    }
    out <== m.out;
}

component main = FixedStringMatchTest();
