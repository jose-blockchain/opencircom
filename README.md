# opencircom

![opencircom logo](logo.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Circom](https://img.shields.io/badge/Circom-ZK%20Circuits-8B5CF6)](https://docs.circom.io/)
[![Tests](https://img.shields.io/badge/tests-79%2B%20passing-success)](./test)
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

Or add to your `package.json`: `"opencircom": "^0.2.0"`.

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

### Boilerplates

Starter repos that wire opencircom with a build pipeline and verifier contracts:

- **opencircom-hardhat-boilerplate** — Circom + snarkjs + Hardhat; compile circuits, generate verifier, test from JS.
- **opencircom-foundry-boilerplate** — Circom + snarkjs + Foundry; verifier in `src/`, `forge test` for Solidity tests.

Use them to jump-start a project without configuring the toolchain from scratch.

## Circuits

| Category   | Template                 | Description |
|-----------|--------------------------|-------------|
| Hashing   | `Poseidon(nInputs)`      | Hades Poseidon (configurable width). |
| Hashing   | `MiMC7(nrounds)`, `MultiMiMC7(nInputs, nRounds)` | MiMC-7. |
| Hashing   | `Sha256(nBits)`  | SHA-256 (FIPS 180-4). Input length in bits; padding is applied. |
| Comparators | `LessThan(n)`, `GreaterThan(n)`, `IsEqual()`, `IsZero()` | Range and equality. |
| Comparators | `StrictNum2Bits(n)` | Num2Bits with in ∈ [0, 2^n−1] enforced. |
| Comparators | `RangeProof(n)` | Prove a ≤ x ≤ b (inputs x, a, b; n-bit range). |
| Bitify    | `Num2Bits(n)`, `Bits2Num(n)` | Bit decomposition (see also `compconstant.circom`, `aliascheck.circom`). |
| Gates     | `AND`, `OR`, `NOT`, `XOR`, `MultiAND(n)` | Boolean gates. |
| Utils     | `Mux1`, `Mux2`, `Switcher` | Multiplexer and conditional swap. |
| Merkle    | `MerkleInclusionProof(levels)` | Binary Merkle inclusion. |
| Merkle    | `SparseMerkleInclusion(levels)`, `SparseMerkleExclusion(levels)` | Sparse Merkle: prove leaf at key equals value, or is empty. |
| Merkle    | `IncrementalMerkleInclusion(levels)` | Append-only tree: prove leaf at numeric index. |
| Merkle    | `MerkleUpdateProof(levels)` | Prove old root → new root by changing one leaf on the same path. |
| Identity  | `Nullifier(domainSize)`  | Nullifier hash for double-spend prevention. |
| Voting    | `VoteCommit(numChoices)`, `VoteReveal()` | Commit-reveal (commit phase + reveal with ZK), anonymous 1-of-N vote, tally verification, double-vote prevention (nullifier-based). |

## Potential circuits to add (roadmap)

Planned or community-requested templates (not yet implemented):

- **Hashing**: Pedersen (Baby Jubjub), Keccak-256.
- **Signatures**: EdDSA verify (Baby JubJub), ECDSA verify (secp256k1).
- **Merkle**: (Sparse inclusion/exclusion, incremental, update proof are implemented.)
- **Comparators & range**: (Range proof and StrictNum2Bits are implemented.)
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

**Coverage** (79+ tests): Poseidon, SHA-256, Comparators (incl. StrictNum2Bits, RangeProof), Gates, Bitify, Merkle (inclusion, sparse, incremental, update), MiMC, Mux1/Mux2, Switcher, Nullifier, Voting, and one full Groth16 prove/verify.

```bash
npm install
npm test
```

The first run runs `setup:zk` (ptau + zkey generation) and can take about a minute.

## License

MIT
