pragma circom 2.0.0;

include "../../circuits/utils.circom";

template IndexOfTest() {
    signal input arr[4];
    signal input value;
    signal input index;
    signal output out;
    component idx = IndexOf(4, 2);
    for (var i = 0; i < 4; i++) {
        idx.arr[i] <== arr[i];
    }
    idx.value <== value;
    idx.index <== index;
    out <== idx.out;
}

component main = IndexOfTest();
