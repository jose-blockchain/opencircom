pragma circom 2.0.0;

include "../../circuits/utils.circom";

template PadPKCS7Test() {
    signal input block[8];
    signal input numUsed;
    component p = PadPKCS7(8);
    for (var i = 0; i < 8; i++) {
        p.block[i] <== block[i];
    }
    p.numUsed <== numUsed;
}

component main = PadPKCS7Test();
