# opencircom

![opencircom logo](logo.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Circom](https://img.shields.io/badge/Circom-ZK%20Circuits-8B5CF6)](https://docs.circom.io/)
[![Tests](https://img.shields.io/badge/tests-64%2B%20passing-success)](./test)
[![Node](https://img.shields.io/badge/node-%3E%3D18.x-brightgreen)](https://nodejs.org/)
[![No circomlib](https://img.shields.io/badge/deps-no%20circomlib-informational)](./circuits)

Reusable Circom ZK circuit templates: hashing, comparators, Merkle trees, nullifiers, and utilities. No dependency on circomlib.

## Use in your project

Add the `circuits` folder to your include path and include templates:

```circom
include "opencircom/circuits/hashing/poseidon.circom";
include "opencircom/circuits/comparators.circom";
include "opencircom/circuits/merkle/merkle_inclusion.circom";

template MyCircuit(levels) {
    signal input secret;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output root;

    component hasher = Poseidon(1);
    hasher.inputs[0] <== secret;

    component tree = MerkleInclusionProof(levels);
    tree.leaf <== hasher.out;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
    root <== tree.root;
}
```

If you clone or link this repo as `opencircom` in your project root, compile with:

```bash
circom your.circom --r1cs --wasm -o build -l opencircom/circuits
```

## Include in Hardhat or Foundry

### Install

From npm:

```bash
npm install opencircom
```

Or add to your `package.json`: `"opencircom": "^0.1.0"`.

### Hardhat

1. Add `opencircom` as a dependency (see Install).
2. In your Circom build step (e.g. Hardhat plugin or script), pass the package circuits as the include path:

   ```bash
   circom circuits/YourCircuit.circom --r1cs --wasm -o build -l node_modules/opencircom/circuits
   ```

3. Use snarkjs (or your flow) to generate the verifier contract; deploy or import it in your Hardhat tests.

### Foundry

1. Add `opencircom` via npm (`npm install opencircom`) or as a Git submodule:
   ```bash
   git submodule add https://github.com/jose-blockchain/opencircom.git lib/opencircom
   ```
2. In a script, run `circom` with the opencircom circuits on the include path:
   - npm: `-l node_modules/opencircom/circuits`
   - submodule: `-l lib/opencircom/circuits`
3. Use snarkjs (or circom) to generate the Solidity verifier; put the generated `.sol` in `src/`.
4. Run `forge build` and `forge test`; your Solidity code calls the verifier contract as usual.

## Circuits

| Category   | Template                 | Description |
|-----------|--------------------------|-------------|
| Hashing   | `Poseidon(nInputs)`      | Hades Poseidon (configurable width). |
| Hashing   | `MiMC7(nrounds)`, `MultiMiMC7(nInputs, nRounds)` | MiMC-7. |
| Comparators | `LessThan(n)`, `GreaterThan(n)`, `IsEqual()`, `IsZero()` | Range and equality. |
| Bitify    | `Num2Bits(n)`, `Bits2Num(n)` | Bit decomposition (see also `compconstant.circom`, `aliascheck.circom`). |
| Gates     | `AND`, `OR`, `NOT`, `XOR`, `MultiAND(n)` | Boolean gates. |
| Utils     | `Mux1`, `Mux2`, `Switcher` | Multiplexer and conditional swap. |
| Merkle    | `MerkleInclusionProof(levels)` | Binary Merkle inclusion. |
| Identity  | `Nullifier(domainSize)`  | Nullifier hash for double-spend prevention. |
| Voting    | `VoteCommit(numChoices)`, `VoteReveal()` | Commit-reveal (commit phase + reveal with ZK), anonymous 1-of-N vote, tally verification, double-vote prevention (nullifier-based). |

## Potential circuits to add (roadmap)

Planned or community-requested templates (not yet implemented):

- **Hashing**: Pedersen, SHA-256 (in-circuit), Keccak-256.
- **Signatures**: EdDSA verify (Baby JubJub), ECDSA verify (secp256k1).
- **Merkle**: Sparse Merkle tree (inclusion + exclusion), incremental Merkle tree, Merkle update proof.
- **Comparators & range**: Range proof (value in [a, b]), strict Num2Bits with range enforcement.
- **Arithmetic**: Safe division with remainder, modular exponentiation, sum/inner product, aliasing-safe field checks.
- **Encryption**: ElGamal encrypt/decrypt, ECDH shared secret, symmetric (Poseidon-based).
- **Identity & credentials**: Semaphore-style identity commitment, selective attribute disclosure, age/threshold proof (attribute > N without revealing).
- **Set membership**: Merkle-based allowlist, non-membership proof (sparse Merkle), accumulator-based membership.
- **Payments & finance**: Balance proof (balance ≥ amount without revealing), confidential transfer, mixer (deposit/withdraw).
- **String & data**: Regex matching (in-circuit), JSON field extraction, UTF-8 validation, substring search.
- **Utilities**: MuxN, array contains / index of, padding (PKCS, zero-pad).

Contributions welcome; open an issue to propose or prioritize.

## Security

- **Range checks**: Use `LessThan(n)` with `n` large enough for your values; combine with `Num2Bits` when you need strict field bounds.
- **Merkle**: Enforce `pathIndices[i]` binary (circuit does this).
- **Nullifier**: Use a unique `externalNullifier` per action to avoid cross-action replay.
- **Hashing**: Poseidon uses standard Hades parameters (same as circomlib spec); constants are in `circuits/hashing/poseidon_constants.circom`.

See [SECURITY.md](SECURITY.md) for more.

## Tests

Tests use **real** ZK where applicable: circuits are compiled with Circom, then a small Powers of Tau and zkey are generated, and a Groth16 proof is created and verified with snarkjs (no mocks).

**Coverage** (64+ tests): Poseidon (constraints, determinism, large inputs, full prove/verify), Comparators (LessThan, IsEqual, LessEqThan, GreaterThan, GreaterEqThan, IsZero, boundaries), Gates (XOR, AND, OR, NOT, multiple combos), Bitify (Num2Bits/Bits2Num round-trip for 0, 1, 42, 127, 128, 255), Merkle (inclusion proof, path indices, determinism), MiMC (constraints, determinism), Mux1/Mux2, Switcher, Nullifier (determinism, distinct inputs), Voting (VoteCommit, VoteReveal, commit-reveal flow, double-vote prevention), and one full Groth16 prove/verify.

```bash
npm install
npm test
```

The first run runs `setup:zk` (ptau + zkey generation) and can take about a minute.

## License

MIT
