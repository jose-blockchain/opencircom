pragma circom 2.0.0;

include "bitify.circom";

// LessThan(n): out = 1 if in[0] < in[1], else 0. Both inputs < 2^n.
template LessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;
    component n2b = Num2Bits(n + 1);
    n2b.in <== in[0] + (1 << n) - in[1];
    out <== 1 - n2b.out[n];
}

template LessEqThan(n) {
    signal input in[2];
    signal output out;
    component lt = LessThan(n);
    lt.in[0] <== in[0];
    lt.in[1] <== in[1] + 1;
    lt.out ==> out;
}

template GreaterThan(n) {
    signal input in[2];
    signal output out;
    component lt = LessThan(n);
    lt.in[0] <== in[1];
    lt.in[1] <== in[0];
    lt.out ==> out;
}

template GreaterEqThan(n) {
    signal input in[2];
    signal output out;
    component lt = LessThan(n);
    lt.in[0] <== in[1];
    lt.in[1] <== in[0] + 1;
    lt.out ==> out;
}

template IsEqual() {
    signal input in[2];
    signal output out;
    component isz = IsZero();
    in[1] - in[0] ==> isz.in;
    isz.out ==> out;
}

template ForceEqualIfEnabled() {
    signal input enabled;
    signal input in[2];
    component isz = IsZero();
    in[1] - in[0] ==> isz.in;
    (1 - isz.out) * enabled === 0;
}
