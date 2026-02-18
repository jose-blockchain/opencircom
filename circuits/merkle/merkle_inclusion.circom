pragma circom 2.0.0;

include "../hashing/poseidon.circom";
include "../switcher.circom";
include "../bitify.circom";

// Binary Merkle inclusion proof. Proves leaf is in tree with root, using pathElements and pathIndices.
// pathIndex[i]=0 => current is left child; pathIndex[i]=1 => current is right child.
// Uses Poseidon(2) per level. Combine with nullifier for double-spend prevention.
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

// Sparse Merkle inclusion: prove that the leaf at key (pathIndices) has the given value.
// Same as MerkleInclusionProof; use with a fixed empty-leaf convention for sparse trees.
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

// Sparse Merkle exclusion: prove that the leaf at key (pathIndices) is empty (no value).
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

// Incremental (append-only) Merkle inclusion: prove leaf at index is in the tree.
// pathIndices are derived from index (index as bits). Use for deposit-style trees.
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

// Merkle update proof: prove newRoot is oldRoot with one leaf updated at key (pathIndices).
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

// Nullifier = H(secret, externalNullifier). Use with MerkleInclusionProof for anonymous spend.
template Nullifier(domainSize) {
    signal input secret;
    signal input externalNullifier;
    signal output nullifierHash;
    component h = Poseidon(2);
    h.inputs[0] <== secret;
    h.inputs[1] <== externalNullifier;
    nullifierHash <== h.out;
}
