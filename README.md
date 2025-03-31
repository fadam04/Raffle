# Raffle Smart Contract

This is a Foundry-based decentralized lottery (raffle) project built as an Ethereum smart contract. The goal is to create a transparent, secure, and automated raffle system.

## Description
The Raffle smart contract allows users to purchase tickets with a small amount of ETH, with a randomly selected winner receiving the prize pool. Randomness can be ensured using Chainlink VRF (Verifiable Random Function).

## Key Features
- **Ticket Purchase**: Anyone can participate by sending a minimum amount of ETH.
- **Random Winner Selection**: Decentralized and tamper-proof winner determination.
- **Automated Payout**: The prize is automatically transferred to the winner.

## Installation and Usage
1. **Prerequisites**:
   - Install [Foundry](https://github.com/foundry-rs/foundry): `curl -L https://foundry.paradigm.xyz | bash`
   - Install dependencies: `forge install`

2. **Clone the Repository**:
   ```bash
   git clone https://github.com/fadam04/Raffle.git
   cd Raffle
