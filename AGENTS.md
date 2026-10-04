# AGENTS.md: blockchainlab-labs

Instructions for AI coding agents (Grok, Cursor, Claude Code, Codex, Copilot and others) working **in** this repo or **using it as a building block**. Humans: see [README.md](README.md).

## What this is

54 runnable smart-contract labs: 45 Solidity labs with Foundry tests (storage to reentrancy, AMMs, flash loans, proxies, ERC-7201, fuzzing, invariants, mainnet forks), 4 Noir ZK labs, 4 Cairo/Starknet labs and a Hardhat lab. Each lab is a small, tested, importable contract.

- Kind: contracts, docs · stability: `stable` · licence: MIT
- Machine-readable manifest: [`blocks.json`](blocks.json) (schema: [BLOCKS-SCHEMA](https://github.com/Blockchains/.github/blob/main/docs/BLOCKS-SCHEMA.md))
- How it fits with the other Blockchains repos: [Build with Blocks](https://github.com/Blockchains/.github/blob/main/docs/BUILD-WITH-BLOCKS.md)

## Setup

```bash
git clone --recursive https://github.com/Blockchains/blockchainlab-labs && cd blockchainlab-labs
foundryup
```

## Build and test

```bash
forge fmt --check && forge build --sizes && forge test -vv
forge test --match-path test/L09*   # one lab
cd noir && nargo test
cd cairo && scarb test
cd hardhat && npm ci && npx hardhat test
```

Tests hit **live** public networks/APIs (the org rule is no mocks). A failure can be an upstream outage: re-run before changing code.

## Environment

| Variable | Required | Purpose |
|---|---|---|
| `MAINNET_RPC_URL` | no | mainnet fork lab (defaults to https://ethereum-rpc.publicnode.com) |

## Structure

| Path | What |
|---|---|
| `src/L<NN>_*.sol` | Solidity labs |
| `test/L<NN>_*.t.sol` | Foundry tests per lab |
| `noir/n<N>_*/` | Noir circuits |
| `cairo/c<N>_*/` | Cairo/Starknet labs |
| `hardhat/` | bonus Hardhat lab |
| `lib/` | forge-std, openzeppelin-contracts submodules |

## Conventions

- One concept per lab, with its test next to it under the same number.
- `forge fmt` formatting is enforced in CI.
- Each README row has a lab, what you learn, an exercise and a Blockchain Lab link.

## Extension points

- New lab: `src/L<next>_<Name>.sol` + `test/L<next>_<Name>.t.sol` + a README row; keep it self-contained.

## Do

- Keep labs small and dependency-light (OpenZeppelin only).

## Don't

- Present lab contracts as production-ready.
- Break the numbering of existing labs (other repos link to them).
- Commit secrets, keys or `.env` files. Run `gitleaks` before pushing; CI and the org policy reject leaks.

## Using it from another project

- **src/L<NN>_<Name>.sol** (solidity): `forge install Blockchains/blockchainlab-labs`
- **noir/** (file): `cd noir && nargo test`
- **cairo/** (file): `cd cairo && scarb test`

See the README section [Use as a building block](README.md#use-as-a-building-block) for a copy-paste example.

## Related blocks

- [Blockchains/blockchain-dev-roadmap](https://github.com/Blockchains/blockchain-dev-roadmap): roadmap stages link to these labs
- [Blockchains/blockchain-interview-questions](https://github.com/Blockchains/blockchain-interview-questions): answers link to labs
- [Blockchains/blockchainlab-tools](https://github.com/Blockchains/blockchainlab-tools): labs reference the hash/storage tools
- [Blockchains/blockchainlab-starters](https://github.com/Blockchains/blockchainlab-starters): production-style starters for the same stacks
- [Blockchains/forge-usd-priced-membership-nft](https://github.com/Blockchains/forge-usd-priced-membership-nft): combine lab patterns with composed contracts
