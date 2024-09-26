# Decentralized Renewable Energy Exchange Platform

This project implements an enhanced decentralized platform for trading renewable energy using blockchain technology. It creates a dynamic energy market where users can trade surplus renewable energy (such as solar or wind) in real-time, with automated smart contracts and a price discovery mechanism.

## Features

- Advanced blockchain implementation with Proof of Work consensus
- User registration with energy production capacity and consumption rate
- Peer-to-peer energy trading using smart contracts
- Dynamic price discovery based on supply and demand
- Time-based simulation of energy production and consumption
- Token-based transaction system
- Enhanced command-line interface for interaction

## Requirements

- Python 3.7+

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/Midorichie/decentralized-energy-trading.git
   ```

2. Navigate to the project directory:
   ```
   cd decentralized-energy-trading
   ```

3. (Optional) Create and activate a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```

4. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

## Usage

Run the main script to start the command-line interface:

```
python main.py
```

Follow the on-screen prompts to interact with the platform:

1. Register User: Add a new user with their energy production capacity and consumption rate.
2. Create Smart Contract: Set up an automated energy trade between two users.
3. Mine Block: Simulate the mining process to add a new block to the blockchain.
4. Check Balance: View the token balance of a user.
5. Simulate Time Step: Advance the simulation by one time unit, updating energy levels and prices.
6. View User Stats: Display detailed statistics for a specific user.
7. Exit: Close the application.

## Project Structure

- `main.py`: The main script containing the blockchain, energy trading, smart contracts, and CLI logic.
- `README.md`: This file, providing project information and instructions.

## Key Components

- `Block` and `Blockchain` classes: Core blockchain implementation with Proof of Work consensus.
- `SmartContract` class: Implements automated energy trading contracts.
- `EnergyTrading` class: Manages the energy trading logic, user data, and interaction with the blockchain.

## Future Improvements

- Implement a graphical user interface for easier interaction
- Add more sophisticated trading strategies and contract types
- Introduce a reputation system for users
- Implement grid stability mechanisms and demand response features
- Develop a mobile app for real-time energy trading

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.