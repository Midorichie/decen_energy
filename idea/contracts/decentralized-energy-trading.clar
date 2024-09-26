import hashlib
import time
import random
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

    def mine_block(self, difficulty: int):
        target = "0" * difficulty
        while self.hash[:difficulty] != target:
            self.nonce += 1
            self.hash = self.calculate_hash()

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

class SmartContract:
    def __init__(self, seller: str, buyer: str, energy_amount: float, price: float):
        self.seller = seller
        self.buyer = buyer
        self.energy_amount = energy_amount
        self.price = price
        self.is_fulfilled = False

    def execute(self, energy_trading):
        if energy_trading.users[self.seller]["energy_available"] >= self.energy_amount:
            energy_trading.trade_energy(self.seller, self.buyer, self.energy_amount, self.price)
            self.is_fulfilled = True
            return True
        return False

class EnergyTrading:
    def __init__(self):
        self.blockchain = Blockchain()
        self.users = {}
        self.smart_contracts = []
        self.current_time = 0
        self.energy_price = 1.0  # Base price per unit of energy

    def register_user(self, address: str, production_capacity: float, consumption_rate: float):
        self.users[address] = {
            "production_capacity": production_capacity,
            "consumption_rate": consumption_rate,
            "energy_available": 0,
            "energy_consumed": 0
        }

    def update_energy_levels(self):
        for address, user in self.users.items():
            produced = user["production_capacity"] * random.uniform(0.8, 1.2)  # Simulate varying production
            consumed = user["consumption_rate"]
            user["energy_available"] += produced - consumed
            user["energy_consumed"] += consumed
            if user["energy_available"] < 0:
                user["energy_available"] = 0

    def calculate_energy_price(self):
        total_available = sum(user["energy_available"] for user in self.users.values())
        total_demand = sum(user["consumption_rate"] for user in self.users.values())
        self.energy_price = max(0.5, min(1.5, (total_demand / total_available) * self.energy_price))

    def create_smart_contract(self, seller: str, buyer: str, energy_amount: float):
        contract = SmartContract(seller, buyer, energy_amount, self.energy_price)
        self.smart_contracts.append(contract)

    def execute_smart_contracts(self):
        for contract in self.smart_contracts:
            if not contract.is_fulfilled:
                contract.execute(self)
        self.smart_contracts = [contract for contract in self.smart_contracts if not contract.is_fulfilled]

    def trade_energy(self, seller: str, buyer: str, amount: float, price: float):
        if seller not in self.users or buyer not in self.users:
            print("Invalid seller or buyer address")
            return

        if self.users[seller]["energy_available"] < amount:
            print("Seller doesn't have enough energy to trade")
            return

        self.blockchain.create_transaction(buyer, seller, amount * price)
        self.users[seller]["energy_available"] -= amount
        self.users[buyer]["energy_available"] += amount

        print(f"Energy trade successful: {amount} units from {seller} to {buyer} for {amount * price} tokens")

    def mine_block(self, miner_address: str):
        self.blockchain.mine_pending_transactions(miner_address)

    def simulate_time_step(self):
        self.current_time += 1
        self.update_energy_levels()
        self.calculate_energy_price()
        self.execute_smart_contracts()
        print(f"Time step {self.current_time} completed. Current energy price: {self.energy_price:.2f}")

# Enhanced CLI for interaction
def main():
    energy_trading = EnergyTrading()

    while True:
        print("\n1. Register User")
        print("2. Create Smart Contract")
        print("3. Mine Block")
        print("4. Check Balance")
        print("5. Simulate Time Step")
        print("6. View User Stats")
        print("7. Exit")

        choice = input("Enter your choice: ")

        if choice == "1":
            address = input("Enter user address: ")
            production = float(input("Enter energy production capacity: "))
            consumption = float(input("Enter energy consumption rate: "))
            energy_trading.register_user(address, production, consumption)
            print(f"User {address} registered successfully")

        elif choice == "2":
            seller = input("Enter seller address: ")
            buyer = input("Enter buyer address: ")
            amount = float(input("Enter energy amount for the contract: "))
            energy_trading.create_smart_contract(seller, buyer, amount)
            print("Smart contract created successfully")

        elif choice == "3":
            miner = input("Enter miner address: ")
            energy_trading.mine_block(miner)

        elif choice == "4":
            address = input("Enter address to check balance: ")
            balance = energy_trading.blockchain.get_balance(address)
            print(f"Balance of {address}: {balance} tokens")

        elif choice == "5":
            energy_trading.simulate_time_step()

        elif choice == "6":
            address = input("Enter user address to view stats: ")
            if address in energy_trading.users:
                user = energy_trading.users[address]
                print(f"User stats for {address}:")
                print(f"Production Capacity: {user['production_capacity']}")
                print(f"Consumption Rate: {user['consumption_rate']}")
                print(f"Energy Available: {user['energy_available']:.2f}")
                print(f"Energy Consumed: {user['energy_consumed']:.2f}")
            else:
                print("User not found")

        elif choice == "7":
            break

        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()