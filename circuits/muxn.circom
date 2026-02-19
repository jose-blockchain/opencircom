pragma circom 2.0.0;

include "comparators.circom";
include "arithmetic.circom";

/**
 * @title SelectByIndex
 * @notice Selects one of N inputs by index; out = inputs[index].
 * @dev Index is constrained to [0, N-1] via StrictNum2Bits and LessThan. nBits must satisfy 2^nBits >= N (e.g. N=5 => nBits=3).
 * @param N Number of inputs.
 * @param nBits Bit width for index (2^nBits >= N).
 * @custom:input inputs[N] Array of values.
 * @custom:input index Selector in [0, N-1].
 * @custom:output out inputs[index].
 * @custom:complexity O(N): StrictNum2Bits(nBits), LessThan(nBits+1), N×IsEqual, Sum(N). ~46 constraints for N=4,nBits=2.
 * @custom:security Index is range-checked; ensures correct selection. No overflow if inputs are field elements.
 */
template SelectByIndex(N, nBits) {
    assert(N >= 1 && nBits >= 1);
    signal input inputs[N];
    signal input index;
    signal output out;

    component strict = StrictNum2Bits(nBits);
    strict.in <== index;

    component lt = LessThan(nBits + 1);
    lt.in[0] <== index;
    lt.in[1] <== N;
    lt.out === 1;

    component eq[N];
    for (var i = 0; i < N; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== index;
        eq[i].in[1] <== i;
    }

    signal run[N];
    run[0] <== eq[0].out;
    for (var i = 1; i < N; i++) {
        run[i] <== run[i - 1] + eq[i].out;
    }
    run[N - 1] === 1;

    signal terms[N];
    for (var i = 0; i < N; i++) {
        terms[i] <== inputs[i] * eq[i].out;
    }
    component sum = Sum(N);
    for (var i = 0; i < N; i++) {
        sum.in[i] <== terms[i];
    }
    out <== sum.out;
}
