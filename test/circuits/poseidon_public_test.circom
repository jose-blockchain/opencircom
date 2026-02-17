pragma circom 2.0.0;

// Circuit with one public input (out) for real ZK prove/verify in tests.
include "../../circuits/hashing/poseidon.circom";

template PoseidonPublicTest() {
    signal input in[3];
    signal input out;  // public: claimed hash
    component p = Poseidon(3);
    p.inputs[0] <== in[0];
    p.inputs[1] <== in[1];
    p.inputs[2] <== in[2];
    p.out === out;
}

component main {public [out]} = PoseidonPublicTest();
