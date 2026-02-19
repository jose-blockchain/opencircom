pragma circom 2.0.0;

include "../../circuits/utils.circom";

template UtilsTest() {
    signal input padIn[3];
    signal input arr[3];
    signal input value;
    signal output padOut0;
    signal output padOut4;
    signal output oneOfN;
    component pad = PadBits(3, 5);
    component oneOf = OneOfN(3);
    for (var i = 0; i < 3; i++) {
        pad.in[i] <== padIn[i];
        oneOf.arr[i] <== arr[i];
    }
    oneOf.value <== value;
    padOut0 <== pad.out[0];
    padOut4 <== pad.out[4];
    oneOfN <== oneOf.out;
}

component main = UtilsTest();
