# Staking Contract (Solidity)

## Overview

This is a simple staking contract implemented in Solidity for the Ethereum blockchain. It allows users to deposit a specific ERC-20 token and earn rewards based on their choice of staking duration and associated Annual Percentage Yield (APY). The contract also includes features for emergency withdrawals, adjusting APY, and more.

## Features

- Users can deposit their ERC-20 tokens and choose between three different staking options with varying APYs and durations.
- Rewards are calculated based on the selected staking duration and APY.
- Early withdrawals result in an exit penalty, while normal withdrawals include a configurable fee.
- The owner can start or stop reward distribution, update APY values, exit penalty, and withdrawal fees.
- An emergency withdrawal function allows the owner to take out any remaining rewards in the contract.

## Getting Started

To use this contract, you will need access to the Ethereum blockchain and a compatible wallet (e.g., MetaMask). Follow these steps to interact with the contract:

1. Deploy the Staking Contract on the Ethereum blockchain using a development environment such as Remix or Truffle.

2. Initialize the contract by providing the contract address of the ERC-20 token you want to stake and a fee address for withdrawal fees.

3. Set the APY values for the three staking options and configure other parameters as needed.

4. Start reward distribution when you are ready for users to start earning rewards.

5. Users can then deposit their tokens by calling the `deposit` function, specifying the amount and staking option.

6. Users can monitor their deposits and rewards using the various `getStakedItem...` functions.

7. To withdraw, users can call the `withdraw` function, specifying the index of the deposit they wish to withdraw.

8. The owner can use the `withdrawEmergencyReward` function to withdraw any remaining rewards in the contract.

## Contract Maintenance

- The owner can adjust the APY values, exit penalty, withdrawal fee, and the fee address by calling the respective functions.

## Security

- The contract utilizes OpenZeppelin libraries for safety and security best practices.

## License

This contract is provided under the UNLICENSED SPDX license, meaning it is free to use without any licensing restrictions.

## Disclaimer

This contract is provided for educational purposes and as a starting point for your own projects. Please exercise caution and conduct thorough testing before deploying it on the Ethereum mainnet. The contract may be updated or improved over time, so ensure you use the latest version for your needs.

Feel free to reach out me for any questions or clarifications.

Happy staking!
