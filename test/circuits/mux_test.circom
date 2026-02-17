pragma circom 2.0.0;

include "../../circuits/mux1.circom";
include "../../circuits/mux2.circom";

template MuxTest() {
    signal input c1[2];
    signal input s1;
    signal input c2[4];
    signal input s2[2];
    signal output mux1Out;
    signal output mux2Out;
    component m1 = Mux1();
    component m2 = Mux2();
    m1.c[0] <== c1[0];
    m1.c[1] <== c1[1];
    m1.s <== s1;
    m2.c[0] <== c2[0];
    m2.c[1] <== c2[1];
    m2.c[2] <== c2[2];
    m2.c[3] <== c2[3];
    m2.s[0] <== s2[0];
    m2.s[1] <== s2[1];
    mux1Out <== m1.out;
    mux2Out <== m2.out;
}

component main = MuxTest();
