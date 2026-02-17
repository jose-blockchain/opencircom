pragma circom 2.0.0;

include "../../circuits/hashing/poseidon.circom";

template PoseidonTest() {
    signal input in[3];
    signal output out;
    component p = Poseidon(3);
    p.inputs[0] <== in[0];
    p.inputs[1] <== in[1];
    p.inputs[2] <== in[2];
    out <== p.out;
}

component main = PoseidonTest();
