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

// Strict Num2Bits: same as Num2Bits(n) but enforces in in [0, 2^n - 1] (no field overflow).
// Use when the value must be a true n-bit non-negative integer.
template StrictNum2Bits(n) {
    assert(n <= 251);
    signal input in;
    signal output out[n];
    component n2b = Num2Bits(n);
    n2b.in <== in;
    for (var i = 0; i < n; i++) {
        out[i] <== n2b.out[i];
    }
    component lt = LessThan(n + 1);
    lt.in[0] <== in;
    lt.in[1] <== (1 << n);
    lt.out === 1;
}

// Range proof: proves a <= x <= b (all in field, n-bit range). a, b can be public or private.
// Requires 2^n > b - a; use n large enough for your range.
template RangeProof(n) {
    assert(n <= 251);
    signal input x;
    signal input a;
    signal input b;
    signal output out;  // 1 (always) for convenience
    component strictLo = StrictNum2Bits(n);
    component strictHi = StrictNum2Bits(n);
    component leq = LessEqThan(n);
    strictLo.in <== x - a;
    strictHi.in <== b - x;
    leq.in[0] <== x - a;
    leq.in[1] <== b - a;
    leq.out === 1;
    out <== 1;
}
