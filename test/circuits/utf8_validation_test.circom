pragma circom 2.0.0;

include "../../circuits/string_data.circom";

template Utf8ValidationTest() {
    signal input bytes[4];
    component v = Utf8Validation(4);
    for (var i = 0; i < 4; i++) {
        v.bytes[i] <== bytes[i];
    }
}

component main = Utf8ValidationTest();
