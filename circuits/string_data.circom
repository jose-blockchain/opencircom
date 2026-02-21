pragma circom 2.0.0;

include "comparators.circom";
include "gates.circom";

/**
 * @title ByteInRange
 * @notice Outputs 1 if byte is in [lo, hi] (inclusive), else 0. Both lo and hi are constants; byte is input.
 * @dev Uses LessEqThan(8). Use for UTF-8 or simple pattern checks.
 * @param lo Lower bound (constant, 0-255).
 * @param hi Upper bound (constant, 0-255), lo <= hi.
 * @custom:input byte Single byte (0-255; constrain with StrictNum2Bits(8) elsewhere if untrusted).
 * @custom:output out 1 if lo <= byte <= hi, 0 otherwise.
 */
template ByteInRange(lo, hi) {
    signal input byte;
    signal output out;
    component leqLo = LessEqThan(8);
    component leqHi = LessEqThan(8);
    leqLo.in[0] <== lo;
    leqLo.in[1] <== byte;
    leqHi.in[0] <== byte;
    leqHi.in[1] <== hi;
    component andGate = AND();
    andGate.a <== leqLo.out;
    andGate.b <== leqHi.out;
    out <== andGate.out;
}

/**
 * @title FixedStringMatch
 * @notice Outputs 1 if bytes[i] == expected[i] for all i (fixed string equality).
 * @dev Simple regex-like "exact match". Uses n×IsEqual + MultiAND(n).
 * @param n Length of byte arrays.
 * @custom:input bytes[n] Prover's bytes.
 * @custom:input expected[n] Expected bytes (can be public or private).
 * @custom:output out 1 if bytes equals expected, 0 otherwise.
 */
template FixedStringMatch(n) {
    signal input bytes[n];
    signal input expected[n];
    signal output out;
    component eq[n];
    component multiAnd = MultiAND(n);
    for (var i = 0; i < n; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== bytes[i];
        eq[i].in[1] <== expected[i];
        multiAnd.in[i] <== eq[i].out;
    }
    out <== multiAnd.out;
}

/**
 * @title BytesAllInRange
 * @notice Outputs 1 if every bytes[i] is in [lo, hi]. Simple pattern: e.g. alphanumeric range.
 * @param n Number of bytes.
 * @param lo Lower bound constant (0-255).
 * @param hi Upper bound constant (0-255).
 * @custom:input bytes[n] Bytes to check.
 * @custom:output out 1 if all bytes in [lo, hi], 0 otherwise.
 */
template BytesAllInRange(n, lo, hi) {
    signal input bytes[n];
    signal output out;
    component inRange[n];
    component multiAnd = MultiAND(n);
    for (var i = 0; i < n; i++) {
        inRange[i] = ByteInRange(lo, hi);
        inRange[i].byte <== bytes[i];
        multiAnd.in[i] <== inRange[i].out;
    }
    out <== multiAnd.out;
}

/**
 * @title Utf8ByteTransition
 * @notice One step of UTF-8 validation: (state_in, byte) -> state_out. state 0 = at boundary, 1..3 = expecting that many continuation bytes. Simplified (no overlong check).
 * @dev Internal; use Utf8Validation(n).
 */
template Utf8ByteTransition() {
    signal input state_in;
    signal input byte;
    signal output state_out;

    signal t;
    signal u;
    t <== state_in * (state_in - 1);
    u <== t * (state_in - 2);
    u * (state_in - 3) === 0;

    component eq0 = IsEqual();
    component eq1 = IsEqual();
    component eq2 = IsEqual();
    component eq3 = IsEqual();
    eq0.in[0] <== state_in;
    eq0.in[1] <== 0;
    eq1.in[0] <== state_in;
    eq1.in[1] <== 1;
    eq2.in[0] <== state_in;
    eq2.in[1] <== 2;
    eq3.in[0] <== state_in;
    eq3.in[1] <== 3;

    component lead1 = ByteInRange(0, 127);
    component lead2 = ByteInRange(194, 223);
    component lead3 = ByteInRange(224, 239);
    component lead4 = ByteInRange(240, 244);
    component cont = ByteInRange(128, 191);

    lead1.byte <== byte;
    lead2.byte <== byte;
    lead3.byte <== byte;
    lead4.byte <== byte;
    cont.byte <== byte;

    signal s0;
    signal s1;
    signal s2;
    signal s3;
    s0 <== lead2.out + 2 * lead3.out + 3 * lead4.out;
    s1 <== 0;
    s2 <== 1;
    s3 <== 2;

    signal out0;
    signal out1;
    signal out2;
    signal out3;
    out0 <== eq0.out * s0;
    out1 <== eq1.out * s1;
    out2 <== eq2.out * s2;
    out3 <== eq3.out * s3;
    state_out <== out0 + out1 + out2 + out3;

    eq0.out + eq1.out + eq2.out + eq3.out === 1;
    eq0.out * (lead1.out + lead2.out + lead3.out + lead4.out - 1) === 0;
    eq1.out * (1 - cont.out) === 0;
    eq2.out * (1 - cont.out) === 0;
    eq3.out * (1 - cont.out) === 0;
}

/**
 * @title Utf8Validation
 * @notice Constrains bytes[0..n-1] to be valid UTF-8. Simplified: no overlong encoding check; rejects invalid lead/continuation sequences.
 * @dev Each byte is range-checked 0-255; state machine enforces lead bytes (ASCII, 2/3/4-byte) and continuation bytes (0x80-0xBF). Final state must be 0.
 * @param n Number of bytes.
 * @custom:input bytes[n] Byte array (each constrained to 0-255).
 * @custom:complexity n×StrictNum2Bits(8) + n×Utf8ByteTransition + state chain. O(n).
 * @custom:security Use for proving a string is valid UTF-8 without revealing it. Simplified validator; overlong encodings are accepted.
 */
template Utf8Validation(n) {
    signal input bytes[n];

    component strict[n];
    for (var i = 0; i < n; i++) {
        strict[i] = StrictNum2Bits(8);
        strict[i].in <== bytes[i];
    }

    signal state[n + 1];
    state[0] <== 0;
    component trans[n];
    for (var i = 0; i < n; i++) {
        trans[i] = Utf8ByteTransition();
        trans[i].state_in <== state[i];
        trans[i].byte <== bytes[i];
        state[i + 1] <== trans[i].state_out;
    }
    state[n] === 0;
}
