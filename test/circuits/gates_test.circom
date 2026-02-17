pragma circom 2.0.0;

include "../../circuits/gates.circom";

template GatesTest() {
    signal input a;
    signal input b;
    signal output xorOut;
    signal output andOut;
    signal output orOut;
    signal output notA;
    component xorGate = XOR();
    component andGate = AND();
    component orGate = OR();
    component notGate = NOT();
    xorGate.a <== a;
    xorGate.b <== b;
    andGate.a <== a;
    andGate.b <== b;
    orGate.a <== a;
    orGate.b <== b;
    notGate.in <== a;
    xorOut <== xorGate.out;
    andOut <== andGate.out;
    orOut <== orGate.out;
    notA <== notGate.out;
}

component main = GatesTest();
