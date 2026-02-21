pragma circom 2.0.0;

/**
 * @title Switcher
 * @notice Conditional swap: if sel==0 then (outL, outR)=(L, R); if sel==1 then (outL, outR)=(R, L).
 * @dev Used in Merkle path hashing to place sibling on correct side. Two constraints.
 * @custom:input sel Selector (0 or 1).
 * @custom:input L Left value.
 * @custom:input R Right value.
 * @custom:output outL L or R according to sel.
 * @custom:output outR R or L according to sel.
 * @custom:complexity 3 constraints (1 binary + 2 swap).
 * @custom:security sel is constrained to {0, 1} within the template.
 */
template Switcher() {
    signal input sel;
    signal input L;
    signal input R;
    signal output outL;
    signal output outR;
    sel * (sel - 1) === 0;
    signal aux;
    aux <== (R - L) * sel;
    outL <== aux + L;
    outR <== -aux + R;
}
