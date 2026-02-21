pragma circom 2.0.0;

include "comparators.circom";

/**
 * @title Sum
 * @notice Sum of n field elements.
 * @dev Constraint count O(n). Use for bounded-size arrays.
 * @param n Length of the input array (>= 1).
 * @custom:input in[n] Field elements to sum.
 * @custom:output out Sum of all elements.
 * @custom:complexity O(n) constraints (n-1 additions).
 * @custom:security None; pure arithmetic.
 */
template Sum(n) {
    assert(n >= 1);
    signal input in[n];
    signal output out;
    if (n == 1) {
        out <== in[0];
    } else {
        signal run[n];
        run[0] <== in[0];
        for (var i = 1; i < n; i++) {
            run[i] <== run[i - 1] + in[i];
        }
        out <== run[n - 1];
    }
}

/**
 * @title InnerProduct
 * @notice Inner product (dot product) of two arrays of length n.
 * @dev out = sum(a[i] * b[i]) for i in 0..n-1. Constraint count O(n).
 * @param n Length of both arrays (>= 1).
 * @custom:input a[n] First array.
 * @custom:input b[n] Second array.
 * @custom:output out Dot product sum(a[i]*b[i]).
 * @custom:complexity O(n) constraints (n multiplications + Sum(n)).
 * @custom:security None; ensure inputs are range-checked elsewhere if needed.
 */
template InnerProduct(n) {
    assert(n >= 1);
    signal input a[n];
    signal input b[n];
    signal output out;
    signal terms[n];
    for (var i = 0; i < n; i++) {
        terms[i] <== a[i] * b[i];
    }
    component sum = Sum(n);
    for (var i = 0; i < n; i++) {
        sum.in[i] <== terms[i];
    }
    out <== sum.out;
}

/**
 * @title DivRem
 * @notice Safe division with remainder: constrains a = b*q + r with 0 <= r < b.
 * @dev Prover supplies quotient q and remainder r; circuit checks equality and range. b must be nonzero; a, b, q, r are n-bit. Use for integer division in ZK.
 * @param n Bit width for all operands (<= 251).
 * @custom:input a Dividend.
 * @custom:input b Divisor (nonzero).
 * @custom:input q Quotient (prover-supplied).
 * @custom:input r Remainder (prover-supplied).
 * @custom:output quotient Same as q (for wiring).
 * @custom:output remainder Same as r (for wiring).
 * @custom:complexity O(n): 5 StrictNum2Bits(n), 1 LessThan(n+1), 1 IsZero; ~135 constraints for n=16.
 * @custom:security All of a, b, q, r are range-checked to n-bit. Circuit checks a=b*q+r and 0<=r<b.
 */
template DivRem(n) {
    assert(n <= 251);
    signal input a;
    signal input b;
    signal input q;
    signal input r;
    signal output quotient;
    signal output remainder;
    quotient <== q;
    remainder <== r;
    component bNonZero = IsZero();
    bNonZero.in <== b;
    bNonZero.out === 0;
    a === b * q + r;
    component strictA = StrictNum2Bits(n);
    strictA.in <== a;
    component strictB = StrictNum2Bits(n);
    strictB.in <== b;
    component strictQ = StrictNum2Bits(n);
    strictQ.in <== q;
    component strictR = StrictNum2Bits(n);
    strictR.in <== r;
    component lt = LessThan(n + 1);
    lt.in[0] <== r;
    lt.in[1] <== b;
    lt.out === 1;
}

/**
 * @title ExpByBits
 * @notice Field exponentiation: out = base^exp with exponent given as n bits.
 * @dev Square-and-multiply; exp[0] is MSB (weight 2^(n-1)), exp[n-1] is LSB. Each exp[i] constrained to 0 or 1.
 * @param n Number of exponent bits (exp in [0, 2^n - 1]).
 * @custom:input base Base (field element).
 * @custom:input exp[n] Exponent as bits (MSB-first).
 * @custom:output out base^exp in the field.
 * @custom:complexity O(n): n binary checks + 4n constraints (square-and-multiply). ~14 constraints for n=4.
 * @custom:security Field exponentiation only; for crypto (e.g. mod-exp) ensure exponent is properly bounded and base is in intended domain.
 */
template ExpByBits(n) {
    assert(n >= 1);
    signal input base;
    signal input exp[n];
    signal output out;
    for (var i = 0; i < n; i++) {
        exp[i] * (exp[i] - 1) === 0;
    }
    signal r[n + 1];
    signal t[n];
    signal s[n];
    signal u[n];
    r[0] <== 1;
    for (var i = 0; i < n; i++) {
        t[i] <== r[i] * r[i];
        s[i] <== exp[i] * (base - 1);
        u[i] <== t[i] * s[i];
        r[i + 1] <== t[i] + u[i];
    }
    out <== r[n];
}
