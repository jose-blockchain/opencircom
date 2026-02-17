#!/bin/bash
# Prepares circuits and zkey for real ZK tests (prove + verify). Run before npm test.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BUILD="$ROOT/build"
PTAU="$ROOT/build/pot12_final.ptau"
CIRCUIT="poseidon_public_test"

mkdir -p "$BUILD"

if [ ! -f "$PTAU" ]; then
  echo "Generating Powers of Tau (12)..."
  npx snarkjs powersoftau new bn128 12 "$BUILD/pot12_0000.ptau"
  npx snarkjs powersoftau contribute "$BUILD/pot12_0000.ptau" "$BUILD/pot12_0001.ptau" --name="First" -e="$(head -c 64 /dev/urandom | xxd -ps -c 64)"
  npx snarkjs powersoftau beacon "$BUILD/pot12_0001.ptau" "$BUILD/pot12_beacon.ptau" "$(head -c 32 /dev/urandom | xxd -ps -c 32)" 10
  npx snarkjs powersoftau prepare phase2 "$BUILD/pot12_beacon.ptau" "$PTAU" -v
  echo "ptau ready."
fi

if [ ! -f "$BUILD/${CIRCUIT}.r1cs" ]; then
  echo "Compiling ${CIRCUIT}..."
  circom test/circuits/${CIRCUIT}.circom --r1cs --wasm -o "$BUILD" -l circuits
  echo "Circuit compiled."
fi

if [ ! -f "$BUILD/${CIRCUIT}_final.zkey" ]; then
  echo "Generating zkey for ${CIRCUIT}..."
  npx snarkjs groth16 setup "$BUILD/${CIRCUIT}.r1cs" "$PTAU" "$BUILD/${CIRCUIT}_0000.zkey"
  npx snarkjs zkey contribute "$BUILD/${CIRCUIT}_0000.zkey" "$BUILD/${CIRCUIT}_final.zkey" --name="Test" -e="$(openssl rand -hex 32)"
  npx snarkjs zkey export verificationkey "$BUILD/${CIRCUIT}_final.zkey" "$BUILD/${CIRCUIT}_vkey.json"
  echo "zkey ready."
fi
echo "ZK test setup done."
