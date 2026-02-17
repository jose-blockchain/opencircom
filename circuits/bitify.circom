pragma circom 2.0.0;

// Bit decomposition and recomposition. Enforces binary and reconstruction.
// Num2Bits: in === sum(out[i]*2^i). Use n small enough for your field.

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1 = 0;
    var e2 = 1;
    for (var i = 0; i < n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] - 1) === 0;
        lc1 += out[i] * e2;
        e2 = e2 + e2;
    }
    lc1 === in;
}

template Bits2Num(n) {
    signal input in[n];
    signal output out;
    var lc1 = 0;
    var e2 = 1;
    for (var i = 0; i < n; i++) {
        lc1 += in[i] * e2;
        e2 = e2 + e2;
    }
    lc1 ==> out;
}

template Num2BitsNeg(n) {
    signal input in;
    signal output out[n];
    var lc1 = 0;
    component isZero = IsZero();
    var neg = n == 0 ? 0 : (1 << n) - in;
    for (var i = 0; i < n; i++) {
        out[i] <-- (neg >> i) & 1;
        out[i] * (out[i] - 1) === 0;
        lc1 += out[i] * (1 << i);
    }
    in ==> isZero.in;
    lc1 + isZero.out * (1 << n) === (1 << n) - in;
}

template IsZero() {
    signal input in;
    signal output out;
    signal inv;
    inv <-- in != 0 ? 1 / in : 0;
    out <== -in * inv + 1;
    in * out === 0;
}
