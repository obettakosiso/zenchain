# Zen Initiative Smart Contract

A decentralized smart contract built on the Stacks blockchain that facilitates community-driven wellness programs through transparent fund management and participant coordination.

## Overview

The Zen Initiative empowers communities to pool resources and support wellness programs for participants in need. This smart contract provides a transparent, decentralized platform for managing contributions, participant registration, and fund distribution.

## Features

### Core Functionality
- **Transparent Fund Management**: All contributions and distributions are recorded on-chain
- **Participant Registration**: Secure enrollment system for wellness program participants
- **Flexible Distribution**: Coordinators can distribute funds based on participant needs
- **Emergency Controls**: Built-in emergency mode for crisis situations

### Security Features
- **Role-Based Access**: Only authorized coordinators can manage participants and funds
- **Validation Systems**: Comprehensive input validation and error handling
- **Balance Protection**: Prevents over-distribution and maintains fund integrity
- **Status Tracking**: Monitor participant progress and program effectiveness

## Contract Structure

### Data Variables
- `initiative-coordinator`: Principal address of the program coordinator
- `initiative-balance-total`: Total funds available for distribution
- `initiative-active-status`: Whether the initiative is currently accepting contributions
- `contribution-minimum-amount`: Minimum STX amount required for contributions
- `initiative-emergency-mode`: Emergency mode status for crisis management

### Key Functions

#### Public Functions
- `make-contribution()`: Allow community members to contribute STX to the initiative
- `register-new-participant(participant-wallet)`: Register new wellness program participants
- `distribute-wellness-funds(participant-wallet, amount)`: Distribute funds to participants
- `update-participant-status(participant-wallet, status)`: Update participant program status

#### Administrative Functions
- `set-minimum-contribution(amount)`: Adjust minimum contribution requirements
- `toggle-initiative-status()`: Enable/disable the initiative
- `enable-emergency-mode()` / `disable-emergency-mode()`: Emergency controls
- `transfer-coordinator-rights(new-coordinator)`: Transfer administrative control

#### Read-Only Functions
- `get-initiative-coordinator()`: Returns current coordinator address
- `get-initiative-balance()`: Returns total available funds
- `get-participant-information(wallet)`: Returns participant details
- `get-contributor-information(wallet)`: Returns contributor history
- `check-initiative-operational-status()`: Returns operational status

## Usage

### For Contributors
1. Ensure you have at least the minimum contribution amount (default: 1 STX)
2. Call `make-contribution()` to add funds to the initiative
3. Your contribution history is automatically tracked

### For Coordinators
1. Register participants using `register-new-participant()`
2. Distribute funds to participants with `distribute-wellness-funds()`
3. Monitor and update participant status as needed
4. Use administrative functions to manage the initiative

### For Participants
- Once registered, you can receive wellness fund distributions
- Your participation history and current status are tracked on-chain
- Funds are distributed directly to your wallet address

## Error Codes

- `ERR-UNAUTHORIZED-COORDINATOR-ACCESS (u100)`: Unauthorized access to coordinator functions
- `ERR-PARTICIPANT-DUPLICATE (u101)`: Attempted to register existing participant
- `ERR-PARTICIPANT-NONEXISTENT (u102)`: Operation on non-registered participant
- `ERR-INITIATIVE-BALANCE-INSUFFICIENT (u103)`: Insufficient funds for distribution
- `ERR-CONTRIBUTION-MINIMUM-NOT-MET (u104)`: Contribution below minimum threshold
- `ERR-INITIATIVE-NOT-ACTIVE (u105)`: Initiative not currently active
- `ERR-CONTRIBUTION-AMOUNT-INVALID (u106)`: Invalid contribution amount
- `ERR-PARTICIPANT-STATUS-INVALID (u107)`: Invalid participant status
- `ERR-COORDINATOR-ADDRESS-INVALID (u108)`: Invalid coordinator address

## Participant Status Types

- `"active"`: Currently participating in wellness programs
- `"pending"`: Awaiting program enrollment or approval
- `"suspended"`: Temporarily paused from program participation
- `"completed"`: Successfully completed wellness program

## Security Considerations

- Only the designated coordinator can manage participants and distribute funds
- All transactions are transparent and verifiable on the blockchain
- Emergency mode allows for rapid response to crisis situations
- Input validation prevents common attack vectors
- Balance checks prevent over-distribution of funds

## Development

### Prerequisites
- Stacks blockchain development environment
- Clarity smart contract knowledge
- STX tokens for testing

### Testing
Ensure thorough testing of all functions, especially:
- Contribution and distribution flows
- Access control mechanisms
- Emergency mode functionality
- Edge cases and error conditions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes with proper testing
4. Submit a pull request with detailed description


## Support

For questions, issues, or contributions, please open an issue on the project repository or contact the development team.
