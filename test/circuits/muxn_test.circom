pragma circom 2.0.0;

include "../../circuits/muxn.circom";

template MuxNTest() {
    signal input inputs4[4];
    signal input index4;
    signal input inputs5[5];
    signal input index5;
    signal output out4;
    signal output out5;
    component sel4 = SelectByIndex(4, 2);
    component sel5 = SelectByIndex(5, 3);
    for (var i = 0; i < 4; i++) sel4.inputs[i] <== inputs4[i];
    sel4.index <== index4;
    for (var i = 0; i < 5; i++) sel5.inputs[i] <== inputs5[i];
    sel5.index <== index5;
    out4 <== sel4.out;
    out5 <== sel5.out;
}

component main = MuxNTest();
