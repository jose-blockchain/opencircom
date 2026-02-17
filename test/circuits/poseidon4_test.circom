pragma circom 2.0.0;

include "../../circuits/hashing/poseidon.circom";

template Poseidon4Test() {
    signal input in[4];
    signal output out;
    component p = Poseidon(4);
    p.inputs[0] <== in[0];
    p.inputs[1] <== in[1];
    p.inputs[2] <== in[2];
    p.inputs[3] <== in[3];
    out <== p.out;
}

component main = Poseidon4Test();
