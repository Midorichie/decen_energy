import hashlib
import time
from typing import List, Dict

class Block:
    def __init__(self, index: int, transactions: List[Dict], timestamp: float, previous_hash: str):
        self.index = index
        self.transactions = transactions
        self.timestamp = timestamp
        self.previous_hash = previous_hash
        self.nonce = 0
        self.hash = self.calculate_hash()

    def calculate_hash(self) -> str:
        block_string = f"{self.index}{self.transactions}{self.timestamp}{self.previous_hash}{self.nonce}"
        return hashlib.sha256(block_string.encode()).hexdigest()

class Blockchain:
    def __init__(self):
        self.chain = [self.create_genesis_block()]
        self.difficulty = 4
        self.pending_transactions = []
        self.mining_reward = 1

    def create_genesis_block(self) -> Block:
        return Block(0, [], time.time(), "0")

    def get_latest_block(self) -> Block:
        return self.chain[-1]

    def mine_pending_transactions(self, miner_address: str):
        block = Block(len(self.chain), self.pending_transactions, time.time(), self.get_latest_block().hash)
        block.mine_block(self.difficulty)

        print("Block mined successfully!")
        self.chain.append(block)

        self.pending_transactions = [
            {"from": "SYSTEM", "to": miner_address, "amount": self.mining_reward}
        ]

    def create_transaction(self, sender: str, recipient: str, amount: float):
        self.pending_transactions.append({
            "from": sender,
            "to": recipient,
            "amount": amount
        })

    def get_balance(self, address: str) -> float:
        balance = 0
        for block in self.chain:
            for transaction in block.transactions:
                if transaction["from"] == address:
                    balance -= transaction["amount"]
                if transaction["to"] == address:
                    balance += transaction["amount"]
        return balance

class EnergyTrading:
    def __init__(self):
        self.blockchain = Blockchain()
        self.users = {}

    def register_user(self, address: str, energy_production: float):
        self.users[address] = {"energy_production": energy_production, "energy_consumed": 0}

    def trade_energy(self, seller: str, buyer: str, amount: float, price: float):
        if seller not in self.users or buyer not in self.users:
            print("Invalid seller or buyer address")
            return

        if self.users[seller]["energy_production"] - self.users[seller]["energy_consumed"] < amount:
            print("Seller doesn't have enough energy to trade")
            return

        self.blockchain.create_transaction(buyer, seller, amount * price)
        self.users[seller]["energy_consumed"] += amount
        self.users[buyer]["energy_production"] += amount

        print(f"Energy trade successful: {amount} units from {seller} to {buyer} for {amount * price} tokens")

    def mine_block(self, miner_address: str):
        self.blockchain.mine_pending_transactions(miner_address)

# Simple CLI for interaction
def main():
    energy_trading = EnergyTrading()

    while True:
        print("\n1. Register User")
        print("2. Trade Energy")
        print("3. Mine Block")
        print("4. Check Balance")
        print("5. Exit")

        choice = input("Enter your choice: ")

        if choice == "1":
            address = input("Enter user address: ")
            production = float(input("Enter energy production capacity: "))
            energy_trading.register_user(address, production)
            print(f"User {address} registered successfully")

        elif choice == "2":
            seller = input("Enter seller address: ")
            buyer = input("Enter buyer address: ")
            amount = float(input("Enter energy amount to trade: "))
            price = float(input("Enter price per unit: "))
            energy_trading.trade_energy(seller, buyer, amount, price)

        elif choice == "3":
            miner = input("Enter miner address: ")
            energy_trading.mine_block(miner)

        elif choice == "4":
            address = input("Enter address to check balance: ")
            balance = energy_trading.blockchain.get_balance(address)
            print(f"Balance of {address}: {balance} tokens")

        elif choice == "5":
            break

        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()