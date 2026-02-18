#!/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p build
echo "Compiling test circuits (opencircom)..."
circom test/circuits/poseidon_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/comparators_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/poseidon_public_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/merkle_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/gates_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/bitify_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/mimc_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/comparators_ext_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/switcher_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/mux_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/nullifier_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/poseidon4_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/voting_commit_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/voting_reveal_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/sha256_256_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/poseidon_merkle_helper.circom --r1cs --wasm -o build -l circuits
circom test/circuits/sparse_merkle_inclusion_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/sparse_merkle_exclusion_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/incremental_merkle_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/merkle_update_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/strict_num2bits_test.circom --r1cs --wasm -o build -l circuits
circom test/circuits/range_proof_test.circom --r1cs --wasm -o build -l circuits
echo "Done."
