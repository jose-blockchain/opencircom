pragma circom 2.0.0;

include "../../circuits/string_data.circom";

template BytesAllInRangeTest() {
    signal input bytes[4];
    signal output out;
    component r = BytesAllInRange(4, 48, 57);
    for (var i = 0; i < 4; i++) {
        r.bytes[i] <== bytes[i];
    }
    out <== r.out;
}

component main = BytesAllInRangeTest();
