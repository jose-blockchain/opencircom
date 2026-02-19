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
 * @custom:complexity 2 constraints. sel should be 0 or 1 (enforced in Merkle usage via pathIndices).
 * @custom:security Used internally in Merkle path; pathIndices constrain sel to binary.
 */
template Switcher() {
    signal input sel;
    signal input L;
    signal input R;
    signal output outL;
    signal output outR;
    signal aux;
    aux <== (R - L) * sel;
    outL <== aux + L;
    outR <== -aux + R;
}
