pragma circom 2.0.0;

include "comparators.circom";
include "gates.circom";

/**
 * @title PadBits
 * @notice Zero-pads a bit array to a target length.
 * @dev out[i] = in[i] for i < n, out[i] = 0 for i >= n. Input bits are constrained to 0 or 1.
 * @param n Current length of input.
 * @param target Output length (>= n).
 * @custom:input in[n] Bits to pad.
 * @custom:output out[target] Padded bits (zeros after position n-1).
 * @custom:complexity n binary constraints + (target-n) zero assignments. O(target).
 * @custom:security Input bits must be constrained 0/1; pad region is fixed zeros.
 */
template PadBits(n, target) {
    assert(n >= 1 && target >= n);
    signal input in[n];
    signal output out[target];
    for (var i = 0; i < n; i++) {
        in[i] * (in[i] - 1) === 0;
        out[i] <== in[i];
    }
    for (var i = n; i < target; i++) {
        out[i] <== 0;
    }
}

/**
 * @title OneOfN
 * @notice Returns 1 if value equals arr[i] for some i, otherwise 0 (array contains check).
 * @dev Uses IsEqual per element and 1 - MultiAND(1-eq[i]). Constraint count O(n).
 * @param n Array length (>= 1).
 * @custom:input arr[n] Array of field elements.
 * @custom:input value Value to look for.
 * @custom:output out 1 if value in arr, 0 otherwise.
 * @custom:complexity O(n): n×IsEqual, n×NOT, MultiAND(n). Use for small allowlists.
 * @custom:security Does not reveal index; suitable for membership proof. For large sets consider Merkle allowlist.
 */
template OneOfN(n) {
    assert(n >= 1);
    signal input arr[n];
    signal input value;
    signal output out;
    component eq[n];
    for (var i = 0; i < n; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== arr[i];
        eq[i].in[1] <== value;
    }
    component notEq[n];
    for (var i = 0; i < n; i++) {
        notEq[i] = NOT();
        notEq[i].in <== eq[i].out;
    }
    component allNone = MultiAND(n);
    for (var i = 0; i < n; i++) {
        allNone.in[i] <== notEq[i].out;
    }
    out <== 1 - allNone.out;
}
