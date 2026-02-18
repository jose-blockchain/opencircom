// Helper to compute Poseidon(1)(x) and Poseidon(2)(a,b) for building Merkle trees in tests.
pragma circom 2.0.0;

include "../../circuits/hashing/poseidon.circom";

template PoseidonMerkleHelper() {
    signal input in1;
    signal input in2_0;
    signal input in2_1;
    signal output out1;
    signal output out2;
    component p1 = Poseidon(1);
    component p2 = Poseidon(2);
    p1.inputs[0] <== in1;
    p2.inputs[0] <== in2_0;
    p2.inputs[1] <== in2_1;
    out1 <== p1.out;
    out2 <== p2.out;
}

component main = PoseidonMerkleHelper();
