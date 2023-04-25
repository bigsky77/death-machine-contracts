# Death-Machine

Welcome to **Death-Machine**, a fully on-chain game that is simple to learn yet hard to master! We designed Death-Machine to replicate the most interesting mechanics in crypto, such as the hunt for MEV and block validation, at a level of abstraction that is easy to understand and accessible to everyone.

**Death-Machine** is heavily based on the awesome game [Mumu](https://mu-mu.netlify.app/).  We use a ton of their code and patterns - and owe them a huge debt of gratitude for expanding what is possible on-chain!

## Gameplay

The goal of the game is to collect stars on a 15x15 grid. Players control three spaceships and strive to design the optimal sequences before submitting their moves on-chain. Death-Machine consists of 49 turns, and each turn corresponds to a player move.

### Rounds

Rounds last 20 minutes. At the end of the 20 minutes, the player who has submitted the best sequence of moves wins.

### Rewards

Winners validate the block and are rewarded with the captured stars. The stars can be any arbitrary smart-contract such as ERC-20 or ERC-721.

### Block Difficulty

The block difficulty is dynamically adjusted based on the previous block scores.

### Enemy Skulls

Enemy skulls are distributed randomly on the grid. Every turn, these skulls move randomly within a set radius. We use the Xoroshiro128+ algorithm and a secret seed to generate the enemy moves.

## Scalability and Access

Death-Machine leverages zero-knowledge technology to manage scalability and access. We use the Sismo Protocol to manage player access in a privacy-preserving way, while our smart contracts are written in Cairo and deployed on Starknet.

### Beta Testing

For our beta testing, only players who generate a zk-proof attesting that they follow @__zkhack__ on Twitter can play!

## Challenges

By far the biggest source of complexity was fully integrating the software development flow across the frontend, backend, and smart-contracts. Small changes in one often had outsized impacts on the other two, especially with smart-contract inputs and outputs.

Death-Machine v1 will heavily focus on building a more tightly integrated and responsive development and testing environment.
