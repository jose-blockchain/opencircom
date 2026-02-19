pragma circom 2.0.0;

include "../hashing/poseidon.circom";
include "../switcher.circom";
include "../bitify.circom";

/**
 * @title MerkleInclusionProof
 * @notice Proves that leaf is in a binary Merkle tree with the given root.
 * @dev pathIndices[i]=0 means current node is left child, 1 means right. Uses Poseidon(2) per level. Combine with Nullifier for double-spend prevention.
 * @param levels Tree depth (number of path elements).
 * @custom:input leaf Leaf value to prove.
 * @custom:input pathElements[levels] Sibling hashes along the path.
 * @custom:input pathIndices[levels] Direction bits (0=left, 1=right).
 * @custom:output root Computed root (must match public root).
 * @custom:complexity O(levels): (levels+1)×Poseidon(1 or 2), levels×Switcher. ~697 constraints for levels=2 (Poseidon cost dominates).
 * @custom:security pathIndices constrained binary. Combine with Nullifier for double-spend prevention; verify root on-chain.
 */
template MerkleInclusionProof(levels) {
    signal input leaf;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output root;

    component hashers[levels + 1];
    component switchers[levels];
    component muxes[levels];

    hashers[0] = Poseidon(1);
    hashers[0].inputs[0] <== leaf;

    signal computed[levels + 1];
    computed[0] <== hashers[0].out;

    for (var i = 0; i < levels; i++) {
        pathIndices[i] * (pathIndices[i] - 1) === 0;
        switchers[i] = Switcher();
        switchers[i].sel <== pathIndices[i];
        switchers[i].L <== computed[i];
        switchers[i].R <== pathElements[i];

        hashers[i + 1] = Poseidon(2);
        hashers[i + 1].inputs[0] <== switchers[i].outL;
        hashers[i + 1].inputs[1] <== switchers[i].outR;
        computed[i + 1] <== hashers[i + 1].out;
    }
    root <== computed[levels];
}

/**
 * @title SparseMerkleInclusion
 * @notice Proves that the leaf at key (pathIndices) equals the given value in a sparse Merkle tree.
 * @dev Same as MerkleInclusionProof; use a fixed empty-leaf convention (e.g. 0) for sparse trees.
 * @param levels Tree depth.
 * @custom:input leaf Value at the key.
 * @custom:input pathElements[levels] Path siblings.
 * @custom:input pathIndices[levels] Key bits.
 * @custom:output root Merkle root.
 */
template SparseMerkleInclusion(levels) {
    signal input leaf;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output root;
    component incl = MerkleInclusionProof(levels);
    incl.leaf <== leaf;
    for (var i = 0; i < levels; i++) {
        incl.pathElements[i] <== pathElements[i];
        incl.pathIndices[i] <== pathIndices[i];
    }
    root <== incl.root;
}

/**
 * @title SparseMerkleExclusion
 * @notice Proves that the leaf at key (pathIndices) is empty in a sparse Merkle tree.
 * @dev Uses MerkleInclusionProof with leaf = 0.
 * @param levels Tree depth.
 * @custom:input pathElements[levels] Path siblings.
 * @custom:input pathIndices[levels] Key bits.
 * @custom:output root Merkle root.
 */
template SparseMerkleExclusion(levels) {
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output root;
    component incl = MerkleInclusionProof(levels);
    incl.leaf <== 0;
    for (var i = 0; i < levels; i++) {
        incl.pathElements[i] <== pathElements[i];
        incl.pathIndices[i] <== pathIndices[i];
    }
    root <== incl.root;
}

/**
 * @title IncrementalMerkleInclusion
 * @notice Proves leaf at numeric index is in an append-only Merkle tree.
 * @dev pathIndices are derived from index (Num2Bits). Use for deposit-style trees where index is insertion order.
 * @param levels Tree depth.
 * @custom:input leaf Leaf value.
 * @custom:input index Numeric index of the leaf.
 * @custom:input pathElements[levels] Path siblings.
 * @custom:output root Merkle root.
 */
template IncrementalMerkleInclusion(levels) {
    signal input leaf;
    signal input index;
    signal input pathElements[levels];
    signal output root;
    component n2b = Num2Bits(levels);
    n2b.in <== index;
    component incl = MerkleInclusionProof(levels);
    incl.leaf <== leaf;
    for (var i = 0; i < levels; i++) {
        incl.pathElements[i] <== pathElements[i];
        incl.pathIndices[i] <== n2b.out[i];
    }
    root <== incl.root;
}

/**
 * @title MerkleUpdateProof
 * @notice Proves newRoot is oldRoot with one leaf updated at the same path.
 * @dev Constrains two inclusion proofs (oldLeaf→oldRoot, newLeaf→newRoot) with same pathElements and pathIndices.
 * @param levels Tree depth.
 * @custom:input oldRoot Previous root.
 * @custom:input newRoot Root after update.
 * @custom:input oldLeaf Leaf value before.
 * @custom:input newLeaf Leaf value after.
 * @custom:input pathElements[levels] Path siblings.
 * @custom:input pathIndices[levels] Key bits.
 */
template MerkleUpdateProof(levels) {
    signal input oldRoot;
    signal input newRoot;
    signal input oldLeaf;
    signal input newLeaf;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    component inclOld = MerkleInclusionProof(levels);
    inclOld.leaf <== oldLeaf;
    for (var i = 0; i < levels; i++) {
        inclOld.pathElements[i] <== pathElements[i];
        inclOld.pathIndices[i] <== pathIndices[i];
    }
    inclOld.root === oldRoot;
    component inclNew = MerkleInclusionProof(levels);
    inclNew.leaf <== newLeaf;
    for (var i = 0; i < levels; i++) {
        inclNew.pathElements[i] <== pathElements[i];
        inclNew.pathIndices[i] <== pathIndices[i];
    }
    inclNew.root === newRoot;
}

/**
 * @title Nullifier
 * @notice Nullifier hash for double-spend prevention: H(secret, externalNullifier).
 * @dev Uses Poseidon(2). Use a unique externalNullifier per action. Combine with MerkleInclusionProof for anonymous spend.
 * @param domainSize Unused; for API compatibility.
 * @custom:input secret Prover's secret.
 * @custom:input externalNullifier Action identifier (unique per action).
 * @custom:output nullifierHash Poseidon(secret, externalNullifier).
 * @custom:complexity 1× Poseidon(2): ~240 constraints (Poseidon cost).
 * @custom:security Use a unique externalNullifier per action to prevent cross-action replay. Keep secret unknown; nullifier reveals double-use only.
 */
template Nullifier(domainSize) {
    signal input secret;
    signal input externalNullifier;
    signal output nullifierHash;
    component h = Poseidon(2);
    h.inputs[0] <== secret;
    h.inputs[1] <== externalNullifier;
    nullifierHash <== h.out;
}
