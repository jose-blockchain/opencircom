pragma circom 2.0.0;

include "../../circuits/utils.circom";

template MinNMaxNTest() {
    signal input arr4[4];
    signal input arr5[5];
    signal output min4;
    signal output max4;
    signal output min5;
    signal output max5;

    component min4C = MinN(16, 4);
    component max4C = MaxN(16, 4);
    component min5C = MinN(16, 5);
    component max5C = MaxN(16, 5);

    for (var i = 0; i < 4; i++) {
        min4C.arr[i] <== arr4[i];
        max4C.arr[i] <== arr4[i];
    }
    min4 <== min4C.out;
    max4 <== max4C.out;

    for (var i = 0; i < 5; i++) {
        min5C.arr[i] <== arr5[i];
        max5C.arr[i] <== arr5[i];
    }
    min5 <== min5C.out;
    max5 <== max5C.out;
}

component main = MinNMaxNTest();
