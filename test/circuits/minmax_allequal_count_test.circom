pragma circom 2.0.0;

include "../../circuits/utils.circom";

template MinMaxAllEqualCountTest() {
    signal input a;
    signal input b;
    signal input arr3[3];
    signal input arr4[4];
    signal input value;
    signal output minOut;
    signal output maxOut;
    signal output allEq3;
    signal output allEq4;
    signal output count4;

    component min2 = Min2(16);
    component max2 = Max2(16);
    component allEq3C = AllEqual(3);
    component allEq4C = AllEqual(4);
    component count4C = CountMatches(4);

    min2.a <== a;
    min2.b <== b;
    max2.a <== a;
    max2.b <== b;
    minOut <== min2.out;
    maxOut <== max2.out;

    for (var i = 0; i < 3; i++) {
        allEq3C.arr[i] <== arr3[i];
    }
    allEq3 <== allEq3C.out;

    for (var i = 0; i < 4; i++) {
        allEq4C.arr[i] <== arr4[i];
        count4C.arr[i] <== arr4[i];
    }
    allEq4 <== allEq4C.out;
    count4C.value <== value;
    count4 <== count4C.out;
}

component main = MinMaxAllEqualCountTest();
