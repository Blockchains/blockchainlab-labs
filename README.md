# Blockchain Lab — 30 hands-on smart-contract labs

![Blockchain Lab Labs](social-preview.png)

[![ci](https://github.com/Blockchains/blockchainlab-labs/actions/workflows/ci.yml/badge.svg)](https://github.com/Blockchains/blockchainlab-labs/actions/workflows/ci.yml)

**30 runnable Solidity labs with Foundry tests — from storage basics to reentrancy, flash loans, proxies, ERC-7201, fuzzing, invariants and mainnet forks** — plus a bonus Hardhat lab. Every lab compiles and passes in CI.

> Built by **Blockchain Lab — [blockchainlab.com](https://blockchainlab.com/?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs)**

## Run

```bash
git clone --recursive https://github.com/Blockchains/blockchainlab-labs && cd blockchainlab-labs
curl -L https://foundry.paradigm.xyz | bash && foundryup     # if you don't have Foundry
forge test                          # all 30 labs (82 tests)
forge test --match-path test/L09*   # one lab
forge test --match-path test/L29* -vv   # mainnet fork lab (uses https://ethereum-rpc.publicnode.com or MAINNET_RPC_URL)
cd hardhat && npm ci && npx hardhat test   # bonus Hardhat lab
```

## Labs

| # | Lab | You learn | Exercise | Blockchain Lab |
|---|---|---|---|---|
| 01 | [SimpleStorage](src/L01_SimpleStorage.sol) · [test](test/L01_SimpleStorage.t.sol) | State variables, storage slot 0, first fuzz test | Add a `uint256[] history` and push every value; assert its length. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/storage/) |
| 02 | [Counter](src/L02_Counter.sol) · [test](test/L02_Counter.t.sol) | Events, custom errors, vm.expectEmit / expectRevert | Add `reset()` restricted to the deployer. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/abi/) |
| 03 | [Ownable](src/L03_Ownable.sol) · [test](test/L03_Ownable.t.sol) | Access control, two-step ownership | Add a `renounceOwnership` with a 2-day delay. | [read](https://blockchainlab.com/development-lab/smart-contract-security-assurance?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 04 | [ERC20Scratch](src/L04_ERC20Scratch.sol) · [test](test/L04_ERC20Scratch.t.sol) | ERC-20 from first principles, infinite allowance | Add `increaseAllowance` and a test for the approve front-running problem. | [read](https://blockchainlab.com/learn/concepts/tokenisation?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/reference/?q=20) |
| 05 | [OZToken](src/L05_OZToken.sol) · [test](test/L05_OZToken.t.sol) | OpenZeppelin ERC20Capped + AccessControl roles | Add a PAUSER_ROLE using ERC20Pausable. | [read](https://blockchainlab.com/learn/concepts/tokenisation?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 06 | [NFT](src/L06_NFT.sol) · [test](test/L06_NFT.t.sol) | ERC-721 paid mint, supply cap, tokenURI | Add a Merkle-gated presale (combine with lab 11). | [read](https://blockchainlab.com/learn/concepts/tokenisation?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/reference/?q=721) |
| 07 | [MultiToken](src/L07_MultiToken.sol) · [test](test/L07_MultiToken.t.sol) | ERC-1155 fungible + non-fungible items, batch transfer | Add a crafting function that burns 100 GOLD to mint a SWORD. | [read](https://blockchainlab.com/learn/concepts/tokenisation?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 08 | [EtherVault](src/L08_EtherVault.sol) · [test](test/L08_EtherVault.t.sol) | receive(), checks-effects-interactions, pull payments | Add a per-user daily withdrawal limit. | [read](https://blockchainlab.com/learn/concepts/custody?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 09 | [Reentrancy](src/L09_Reentrancy.sol) · [test](test/L09_Reentrancy.t.sol) | Reentrancy exploit end-to-end and two fixes | Write a cross-function reentrancy variant and fix it. | [read](https://blockchainlab.com/learn/failure-atlas?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 10 | [Arithmetic](src/L10_Arithmetic.sol) · [test](test/L10_Arithmetic.t.sol) | Checked vs unchecked maths, rounding direction | Find an input where rounding the wrong way lets a user extract value. | [read](https://blockchainlab.com/development-lab/smart-contract-security-assurance?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/units/) |
| 11 | [MerkleAirdrop](src/L11_MerkleAirdrop.sol) · [test](test/L11_MerkleAirdrop.t.sol) | OpenZeppelin StandardMerkleTree allowlist claim | Build your own tree in the Tools hash page and claim with it. | [read](https://blockchainlab.com/learn/concepts/merkle-tree?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/hash/) |
| 12 | [Permit](src/L12_Permit.sol) · [test](test/L12_Permit.t.sol) | EIP-2612 / EIP-712 typed signatures, replay & expiry | Implement a `depositWithPermit` vault. | [read](https://blockchainlab.com/learn/concepts/private-key?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/reference/?q=2612) |
| 13 | [Signatures](src/L13_Signatures.sol) · [test](test/L13_Signatures.t.sol) | EIP-191 signed vouchers, ecrecover via ECDSA, nonces | Add an expiry and show signature malleability is handled by ECDSA. | [read](https://blockchainlab.com/learn/concepts/public-key?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 14 | [MultiSig](src/L14_MultiSig.sol) · [test](test/L14_MultiSig.t.sol) | M-of-N wallet: submit / confirm / execute | Add revoke-confirmation and owner rotation via self-call. | [read](https://blockchainlab.com/intelligence/custody/mpc-vs-multisig-vs-hsm?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 15 | [Timelock](src/L15_Timelock.sol) · [test](test/L15_Timelock.t.sol) | Queued governance actions with delay and grace | Add `cancel()` and emit events for off-chain monitoring. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 16 | [CommitReveal](src/L16_CommitReveal.sol) · [test](test/L16_CommitReveal.t.sol) | Hiding choices to resist front-running | Add a deposit that is slashed if a committer never reveals. | [read](https://blockchainlab.com/learn/concepts/hash?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/hash/) |
| 17 | [DutchAuction](src/L17_DutchAuction.sol) · [test](test/L17_DutchAuction.t.sol) | Linear price decay, refunds | Make the decay exponential and compare gas. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 18 | [EnglishAuction](src/L18_EnglishAuction.sol) · [test](test/L18_EnglishAuction.t.sol) | Bidding with pull refunds (DoS-safe) | Add anti-sniping: extend the end time on late bids. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 19 | [Crowdfund](src/L19_Crowdfund.sol) · [test](test/L19_Crowdfund.t.sol) | SafeERC20, goals, deadlines, refunds | Support fee-on-transfer tokens correctly. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 20 | [StakingRewards](src/L20_StakingRewards.sol) · [test](test/L20_StakingRewards.t.sol) | Reward-per-token accumulator (Synthetix pattern) | Add a reward period end and `notifyRewardAmount`. | [read](https://blockchainlab.com/intelligence/staking/native-vs-liquid-vs-restaking?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 21 | [ConstantProductAMM](src/L21_ConstantProductAMM.sol) · [test](test/L21_ConstantProductAMM.t.sol) | x·y=k swaps, 0.3% fee, LP shares, slippage | Add a TWAP price oracle accumulator. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 22 | [FlashLoan](src/L22_FlashLoan.sol) · [test](test/L22_FlashLoan.t.sol) | ERC-3156 flash lender and borrower | Use a flash loan to arbitrage two lab-21 pools. | [read](https://blockchainlab.com/learn/failure-atlas?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/reference/?q=3156) |
| 23 | [UpgradeableProxy](src/L23_UpgradeableProxy.sol) · [test](test/L23_UpgradeableProxy.t.sol) | UUPS + ERC-1967 proxy, initialisers, upgrade auth | Add a storage-collision bug in V2 and catch it with a test. | [read](https://blockchainlab.com/development-lab/smart-contract-security-assurance?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/storage/) |
| 24 | [NamespacedStorage](src/L24_NamespacedStorage.sol) · [test](test/L24_NamespacedStorage.t.sol) | ERC-7201 namespaced storage layout | Add a second namespace and prove they never collide. | [read](https://blockchainlab.com/development-lab/smart-contract-security-assurance?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/storage/) |
| 25 | [StorageLayout](src/L25_StorageLayout.sol) · [test](test/L25_StorageLayout.t.sol) | Packing, mappings, arrays, short strings via vm.load | Store a 40-byte string and decode the long-string layout. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/storage/) |
| 26 | [GasOptimisation](src/L26_GasOptimisation.sol) · [test](test/L26_GasOptimisation.t.sol) | Packing, caching, calldata, unchecked loops | Run `forge snapshot` and cut another 10%. | [read](https://blockchainlab.com/learn/concepts/virtual-machine?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/gas/) |
| 27 | [FuzzMath](src/L27_FuzzMath.sol) · [test](test/L27_FuzzMath.t.sol) | Property-based fuzzing finds a precision bug | Write a fuzz test that fails on `afterFeeBuggy`. | [read](https://blockchainlab.com/development-lab/smart-contract-security-assurance?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 28 | [InvariantVault](src/L28_InvariantVault.sol) · [test](test/L28_InvariantVault.t.sol) | Stateful invariant testing with a handler + ghost vars | Introduce a bug in withdraw and watch the invariant catch it. | [read](https://blockchainlab.com/development-lab/smart-contract-security-assurance?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |
| 29 | [MainnetFork](test/L29_MainnetFork.t.sol) · [test](test/L29_MainnetFork.t.sol) | Fork tests against real USDC / WETH via public RPC | Fork Base and test real Base USDC. | [read](https://blockchainlab.com/learn/protocol-atlas?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/address/?q=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) |
| 30 | [Create2Factory](src/L30_Create2Factory.sol) · [test](test/L30_Create2Factory.t.sol) | CREATE2 deterministic deployment and address prediction | Predict the address off-chain with ethers `getCreate2Address`. | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [tool](https://blockchains.github.io/blockchainlab-tools/hash/) |
| H1 | [Counter (Hardhat)](hardhat/contracts/Counter.sol) · [test](hardhat/test/Counter.test.js) | Same contract as lab 02, tested with Hardhat + ethers + chai | Port lab 04 to Hardhat | [read](https://blockchainlab.com/learn/concepts/smart-contract?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) |

Each lab = one contract in `src/` and one test in `test/`. Read the test first — it is the spec. Then do the exercise and make your new test pass.

## Stack

Foundry (forge-std v1.17), Solidity 0.8.28 (Cancun), OpenZeppelin Contracts v5.4.0, Hardhat 2 for the bonus lab. Anchor (Solana) labs are not included yet.

## Where next

- [Blockchain developer roadmap](https://github.com/Blockchains/blockchain-dev-roadmap) · [Interview questions](https://github.com/Blockchains/blockchain-interview-questions)
- [Blockchain Lab Tools](https://blockchains.github.io/blockchainlab-tools/) — decode the txs your labs produce once deployed; compute storage slots; build Merkle trees
- [Whitepaper library](https://blockchainlab.com/whitepaper?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [Glossary](https://blockchainlab.com/learn/glossary?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs) · [Failure atlas](https://blockchainlab.com/learn/failure-atlas?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs)

Educational code — not audited, do not deploy to mainnet with real funds. MIT.

---
Built by Blockchain Lab — [blockchainlab.com](https://blockchainlab.com/?utm_source=github&utm_medium=readme&utm_campaign=blockchainlab-labs)
