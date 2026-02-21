pragma circom 2.0.0;

include "comparators.circom";
include "gates.circom";
include "muxn.circom";
include "arithmetic.circom";

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

/**
 * @title IndexOf
 * @notice Proves knowledge of an index i in [0, N-1] such that arr[i] == value; outputs that index.
 * @dev Uses SelectByIndex to constrain arr[index]==value. nBits must satisfy 2^nBits >= N.
 * @param N Array length (>= 1).
 * @param nBits Bit width for index (2^nBits >= N).
 * @custom:input arr[N] Array of field elements.
 * @custom:input value Value that must equal arr[index].
 * @custom:input index Private index in [0, N-1].
 * @custom:output out The index (prover can make it public or keep private in higher-level circuit).
 * @custom:complexity Same as SelectByIndex(N, nBits) plus one IsEqual. O(N).
 * @custom:security Index is range-checked by SelectByIndex. Use when proving "value appears at position i" without revealing i elsewhere.
 */
template IndexOf(N, nBits) {
    assert(N >= 1 && nBits >= 1);
    signal input arr[N];
    signal input value;
    signal input index;
    signal output out;

    component sel = SelectByIndex(N, nBits);
    for (var i = 0; i < N; i++) {
        sel.inputs[i] <== arr[i];
    }
    sel.index <== index;

    component eq = IsEqual();
    eq.in[0] <== sel.out;
    eq.in[1] <== value;
    eq.out === 1;

    out <== index;
}

/**
 * @title Min2
 * @notice Outputs the minimum of two values (both assumed in [0, 2^n - 1]).
 * @dev Uses LessThan(n) and SelectByIndex(2,1). out = a when a < b, else b.
 * @param n Bit width for comparison.
 * @custom:input a First value.
 * @custom:input b Second value.
 * @custom:output out min(a, b).
 */
template Min2(n) {
    assert(n >= 1 && n <= 252);
    signal input a;
    signal input b;
    signal output out;
    component lt = LessThan(n);
    lt.in[0] <== a;
    lt.in[1] <== b;
    component sel = SelectByIndex(2, 1);
    sel.inputs[0] <== a;
    sel.inputs[1] <== b;
    sel.index <== 1 - lt.out;
    out <== sel.out;
}

/**
 * @title Max2
 * @notice Outputs the maximum of two values (both assumed in [0, 2^n - 1]).
 * @dev Uses LessThan(n) and SelectByIndex(2,1). out = b when a < b, else a.
 * @param n Bit width for comparison.
 * @custom:input a First value.
 * @custom:input b Second value.
 * @custom:output out max(a, b).
 */
template Max2(n) {
    assert(n >= 1 && n <= 252);
    signal input a;
    signal input b;
    signal output out;
    component lt = LessThan(n);
    lt.in[0] <== a;
    lt.in[1] <== b;
    component sel = SelectByIndex(2, 1);
    sel.inputs[0] <== a;
    sel.inputs[1] <== b;
    sel.index <== lt.out;
    out <== sel.out;
}

/**
 * @title AllEqual
 * @notice Returns 1 if all array elements are equal, else 0.
 * @dev For n>=2: arr[i]==arr[0] for all i, combined with MultiAND. For n==1, outputs 1.
 * @param n Array length (>= 1).
 * @custom:input arr[n] Array of field elements.
 * @custom:output out 1 if all equal, 0 otherwise.
 */
template AllEqual(n) {
    assert(n >= 1);
    signal input arr[n];
    signal output out;
    if (n == 1) {
        out <== 1;
    } else {
        component eq[n - 1];
        for (var i = 0; i < n - 1; i++) {
            eq[i] = IsEqual();
            eq[i].in[0] <== arr[0];
            eq[i].in[1] <== arr[i + 1];
        }
        component and = MultiAND(n - 1);
        for (var i = 0; i < n - 1; i++) {
            and.in[i] <== eq[i].out;
        }
        out <== and.out;
    }
}

/**
 * @title CountMatches
 * @notice Counts how many indices i have arr[i] == value (output in [0, N]).
 * @dev Sum of IsEqual(arr[i], value). Useful for tally or allowlist count.
 * @param N Array length (>= 1).
 * @custom:input arr[N] Array of field elements.
 * @custom:input value Value to count.
 * @custom:output out Number of i with arr[i] == value.
 */
template CountMatches(N) {
    assert(N >= 1);
    signal input arr[N];
    signal input value;
    signal output out;
    component eq[N];
    for (var i = 0; i < N; i++) {
        eq[i] = IsEqual();
        eq[i].in[0] <== arr[i];
        eq[i].in[1] <== value;
    }
    component sum = Sum(N);
    for (var i = 0; i < N; i++) {
        sum.in[i] <== eq[i].out;
    }
    out <== sum.out;
}

/**
 * @title MinN
 * @notice Outputs the minimum of N values (each in [0, 2^n - 1]).
 * @dev Chains Min2(n) over the array. O(N) constraints.
 * @param n Bit width for each value.
 * @param N Array length (>= 1).
 * @custom:input arr[N] Values to take min of.
 * @custom:output out min(arr[0], ..., arr[N-1]).
 */
template MinN(n, N) {
    assert(n >= 1 && n <= 252 && N >= 1);
    signal input arr[N];
    signal output out;
    if (N == 1) {
        out <== arr[0];
    } else {
        signal runningMin[N];
        runningMin[0] <== arr[0];
        component min2[N - 1];
        for (var i = 0; i < N - 1; i++) {
            min2[i] = Min2(n);
            min2[i].a <== runningMin[i];
            min2[i].b <== arr[i + 1];
            runningMin[i + 1] <== min2[i].out;
        }
        out <== runningMin[N - 1];
    }
}

/**
 * @title MaxN
 * @notice Outputs the maximum of N values (each in [0, 2^n - 1]).
 * @dev Chains Max2(n) over the array. O(N) constraints.
 * @param n Bit width for each value.
 * @param N Array length (>= 1).
 * @custom:input arr[N] Values to take max of.
 * @custom:output out max(arr[0], ..., arr[N-1]).
 */
template MaxN(n, N) {
    assert(n >= 1 && n <= 252 && N >= 1);
    signal input arr[N];
    signal output out;
    if (N == 1) {
        out <== arr[0];
    } else {
        signal runningMax[N];
        runningMax[0] <== arr[0];
        component max2[N - 1];
        for (var i = 0; i < N - 1; i++) {
            max2[i] = Max2(n);
            max2[i].a <== runningMax[i];
            max2[i].b <== arr[i + 1];
            runningMax[i + 1] <== max2[i].out;
        }
        out <== runningMax[N - 1];
    }
}

/**
 * @title Tally
 * @notice Counts votes per choice: count[c] = number of votes equal to c (votes constrained to [0, numChoices-1]).
 * @dev Each vote is range-checked (StrictNum2Bits + LessEqThan); then CountMatches per choice. Use for anonymous tally.
 * @param numChoices Number of choices (>= 1). nBits = ceil(log2(numChoices)).
 * @param numVotes Number of votes (>= 1).
 * @custom:input votes[numVotes] Each vote in [0, numChoices-1].
 * @custom:output count[numChoices] count[c] = number of votes with value c.
 */
template Tally(numChoices, numVotes) {
    assert(numChoices >= 1 && numVotes >= 1);
    var nBits = 1;
    var t = 1;
    while (t < numChoices) {
        t = t * 2;
        nBits = nBits + 1;
    }
    signal input votes[numVotes];
    signal output count[numChoices];
    component strict[numVotes];
    component leq[numVotes];
    for (var i = 0; i < numVotes; i++) {
        strict[i] = StrictNum2Bits(nBits);
        strict[i].in <== votes[i];
        leq[i] = LessEqThan(nBits);
        leq[i].in[0] <== votes[i];
        leq[i].in[1] <== numChoices - 1;
        leq[i].out === 1;
    }
    component cnt[numChoices];
    for (var c = 0; c < numChoices; c++) {
        cnt[c] = CountMatches(numVotes);
        for (var i = 0; i < numVotes; i++) {
            cnt[c].arr[i] <== votes[i];
        }
        cnt[c].value <== c;
        count[c] <== cnt[c].out;
    }
}
