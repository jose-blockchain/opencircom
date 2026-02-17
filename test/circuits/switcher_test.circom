pragma circom 2.0.0;

include "../../circuits/switcher.circom";

template SwitcherTest() {
    signal input sel;
    signal input L;
    signal input R;
    signal output outL;
    signal output outR;
    component sw = Switcher();
    sw.sel <== sel;
    sw.L <== L;
    sw.R <== R;
    outL <== sw.outL;
    outR <== sw.outR;
}

component main = SwitcherTest();
