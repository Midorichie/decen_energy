# Decentralized Renewable Energy Exchange Platform

This project implements a basic decentralized platform for trading renewable energy using blockchain technology. It aims to create a decentralized energy market where users can trade surplus renewable energy (such as solar or wind) in real-time, reducing reliance on traditional energy grids.

## Features

- Basic blockchain implementation
- User registration with energy production capacity
- Peer-to-peer energy trading
- Simple mining mechanism
- Token-based transaction system
- Command-line interface for interaction

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

1. Register User: Add a new user with their energy production capacity.
2. Trade Energy: Initiate an energy trade between two users.
3. Mine Block: Simulate the mining process to add a new block to the blockchain.
4. Check Balance: View the token balance of a user.
5. Exit: Close the application.

## Project Structure

- `main.py`: The main script containing the blockchain, energy trading, and CLI logic.
- `README.md`: This file, providing project information and instructions.

## Future Improvements

- Implement more sophisticated energy trading mechanisms
- Enhance blockchain security and consensus algorithms
- Develop a user-friendly graphical interface
- Introduce smart contracts for automated trading and settlement
- Implement real-time energy production and consumption tracking

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.