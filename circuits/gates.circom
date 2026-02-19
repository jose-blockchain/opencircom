pragma circom 2.0.0;

/**
 * @title XOR
 * @notice Boolean XOR: out = 1 iff exactly one of a, b is 1.
 * @dev Inputs must be 0 or 1; use with bitify for range checks. One constraint.
 * @custom:input a First bit.
 * @custom:input b Second bit.
 * @custom:output out a XOR b.
 * @custom:complexity 1 constraint. Inputs must be 0 or 1 (enforce with bitify or range checks).
 * @custom:security No security caveats; use with binary-constrained inputs.
 */
template XOR() {
    signal input a;
    signal input b;
    signal output out;
    out <== a + b - 2 * a * b;
}

/**
 * @title AND
 * @notice Boolean AND: out = a * b.
 * @dev Inputs 0 or 1. One constraint.
 * @custom:input a First bit.
 * @custom:input b Second bit.
 * @custom:output out a AND b.
 */
template AND() {
    signal input a;
    signal input b;
    signal output out;
    out <== a * b;
}

/**
 * @title OR
 * @notice Boolean OR: out = 1 iff at least one of a, b is 1.
 * @dev out = a + b - a*b. One constraint.
 * @custom:input a First bit.
 * @custom:input b Second bit.
 * @custom:output out a OR b.
 */
template OR() {
    signal input a;
    signal input b;
    signal output out;
    out <== a + b - a * b;
}

/**
 * @title NOT
 * @notice Boolean NOT: out = 1 - in.
 * @dev in must be 0 or 1. One constraint.
 * @custom:input in Input bit.
 * @custom:output out 1 if in == 0, 0 if in == 1.
 */
template NOT() {
    signal input in;
    signal output out;
    out <== 1 + in - 2 * in;
}

/**
 * @title NAND
 * @notice Boolean NAND: out = 1 - a*b.
 * @custom:input a First bit.
 * @custom:input b Second bit.
 * @custom:output out NOT(a AND b).
 */
template NAND() {
    signal input a;
    signal input b;
    signal output out;
    out <== 1 - a * b;
}

/**
 * @title NOR
 * @notice Boolean NOR: out = 1 iff both a and b are 0.
 * @custom:input a First bit.
 * @custom:input b Second bit.
 * @custom:output out NOT(a OR b).
 */
template NOR() {
    signal input a;
    signal input b;
    signal output out;
    out <== a * b + 1 - a - b;
}

/**
 * @title MultiAND
 * @notice N-way AND: out = 1 iff all in[i] are 1.
 * @dev Recursive structure; constraint count O(n). Inputs must be 0 or 1.
 * @param n Number of inputs.
 * @custom:input in[n] Input bits.
 * @custom:output out 1 iff all in[i] == 1.
 * @custom:complexity O(n) constraints (recursive AND tree). Inputs must be binary.
 * @custom:security None; combine with IsEqual/OneOfN for set checks.
 */
template MultiAND(n) {
    signal input in[n];
    signal output out;
    component and1;
    component and2;
    component ands[2];
    if (n == 1) {
        out <== in[0];
    } else if (n == 2) {
        and1 = AND();
        and1.a <== in[0];
        and1.b <== in[1];
        out <== and1.out;
    } else {
        and2 = AND();
        var n1 = n \ 2;
        var n2 = n - n \ 2;
        ands[0] = MultiAND(n1);
        ands[1] = MultiAND(n2);
        for (var i = 0; i < n1; i++) ands[0].in[i] <== in[i];
        for (var i = 0; i < n2; i++) ands[1].in[i] <== in[n1 + i];
        and2.a <== ands[0].out;
        and2.b <== ands[1].out;
        out <== and2.out;
    }
}
