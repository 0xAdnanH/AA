# AA

The AA project presents another template of smart contract designed to represent blockchain accounts for various entities, including individuals, DAOs, and companies. It facilitates identity representation and supports essential interactions. The other template is my other project: [Account-Contract](https://github.com/0xAdnanH/Account-Contract/tree/master).

The AA contract implements the following functionalities:

- **ERC173 Ownership Management:** Following the ERC173 standard, the contract includes ownership management mechanisms, enabling control over ownership transfer and access.

- **ERC1271 Message Verification:** The contract implements ERC1271, allowing signed messages to be verified based on the owner's signature.

- **ERC725X Generic Executor:** The contract features the ERC725's generic execute function allowing interaction with different addresses on the blockchain and the ability to create new contracts using [CREATE2](https://eips.ethereum.org/EIPS/eip-1014) operation.

- **ERC725Y Generic Key-Value Store:** The contract features the ERC725's generic setData and getData functions allowing the ability to store and retreive data within the smart contract, making it readable for other smart contracts.

## Goals of the Project

The project aims to:

- **Showcase Smart Contract Account Utilization:** Highlight the versatility of smart contract accounts by implementing diverse functions and standards within the contract.

## Technicalities of the Project

- **Usage of OpenZeppelin:** The project leverages the OpenZeppelin library to import pre-audited and well-tested code. This practice enhances security and efficiency by avoiding the introduction of unnecessary vulnerabilities and saving development time.

- **Tested with ethers.js:** Comprehensive unit tests are written using `ethers.js` to ensure the proper functionality of the implemented features.

- **Documentation Using Natspec:** The project's functions and overall functionality are thoroughly documented using Natspec, offering insights into each function's purpose and usage.

- **Use of internal function:** The project uses internal functions to divide the logic into smaller pieces making the code more readeable and understandable.

**Note:** The AA project serves as an educational exploration of smart contract accounts, emphasizing their functionality and standards implementation.


## Installation

### Cloning the Repository

You can clone the repository and install its dependencies to start using the provided smart contracts.

```bash
$ git clone https://github.com/0xAdnanH/AA.git
$ cd ./AA
$ npm install
```

### Instructions

#### Compile

To Compile the contract run:

```bash
$ npx hardhat compile
```

#### Tests

To run the unit tests:

```bash
$ npx hardhat test
```
