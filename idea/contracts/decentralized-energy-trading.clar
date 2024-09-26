import hashlib
import time
import random
from typing import List, Dict
from enum import Enum

class Weather(Enum):
    SUNNY = 1
    CLOUDY = 2
    RAINY = 3
    WINDY = 4

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
    def __init__(self, seller: str, buyer: str, energy_amount: float, price: float, duration: int):
        self.seller = seller
        self.buyer = buyer
        self.energy_amount = energy_amount
        self.price = price
        self.duration = duration
        self.start_time = None
        self.is_active = False
        self.is_fulfilled = False

    def activate(self, current_time: int):
        self.start_time = current_time
        self.is_active = True

    def execute(self, energy_trading, current_time: int):
        if self.is_active and current_time < self.start_time + self.duration:
            if energy_trading.users[self.seller]["energy_available"] >= self.energy_amount:
                energy_trading.trade_energy(self.seller, self.buyer, self.energy_amount, self.price)
                return True
        elif current_time >= self.start_time + self.duration:
            self.is_fulfilled = True
        return False

class EnergyStorage:
    def __init__(self, capacity: float):
        self.capacity = capacity
        self.current_level = 0

    def store(self, amount: float) -> float:
        stored = min(amount, self.capacity - self.current_level)
        self.current_level += stored
        return stored

    def retrieve(self, amount: float) -> float:
        retrieved = min(amount, self.current_level)
        self.current_level -= retrieved
        return retrieved

class EnergyTrading:
    def __init__(self):
        self.blockchain = Blockchain()
        self.users = {}
        self.smart_contracts = []
        self.current_time = 0
        self.energy_price = 1.0
        self.grid_stability = 1.0
        self.weather = Weather.SUNNY
        self.energy_storage = EnergyStorage(1000)  # 1000 units of energy storage

    def register_user(self, address: str, production_capacity: float, consumption_rate: float):
        self.users[address] = {
            "production_capacity": production_capacity,
            "consumption_rate": consumption_rate,
            "energy_available": 0,
            "energy_consumed": 0,
            "reputation": 1.0,
            "demand_response": False
        }

    def update_weather(self):
        self.weather = random.choice(list(Weather))

    def weather_impact(self) -> float:
        if self.weather == Weather.SUNNY:
            return 1.2
        elif self.weather == Weather.CLOUDY:
            return 0.8
        elif self.weather == Weather.RAINY:
            return 0.6
        elif self.weather == Weather.WINDY:
            return 1.5
        return 1.0

    def update_energy_levels(self):
        weather_factor = self.weather_impact()
        for address, user in self.users.items():
            produced = user["production_capacity"] * weather_factor * random.uniform(0.8, 1.2)
            consumed = user["consumption_rate"] * (0.8 if user["demand_response"] else 1.0)
            user["energy_available"] += produced - consumed
            user["energy_consumed"] += consumed
            if user["energy_available"] < 0:
                user["energy_available"] = 0

            # Store excess energy
            if user["energy_available"] > user["consumption_rate"]:
                excess = user["energy_available"] - user["consumption_rate"]
                stored = self.energy_storage.store(excess)
                user["energy_available"] -= stored

    def calculate_energy_price(self):
        total_available = sum(user["energy_available"] for user in self.users.values()) + self.energy_storage.current_level
        total_demand = sum(user["consumption_rate"] for user in self.users.values())
        base_price = max(0.5, min(1.5, (total_demand / total_available) * self.energy_price))
        self.energy_price = base_price * (2 - self.grid_stability)

    def create_smart_contract(self, seller: str, buyer: str, energy_amount: float, duration: int):
        contract = SmartContract(seller, buyer, energy_amount, self.energy_price, duration)
        self.smart_contracts.append(contract)
        contract.activate(self.current_time)

    def execute_smart_contracts(self):
        for contract in self.smart_contracts:
            if not contract.is_fulfilled:
                contract.execute(self, self.current_time)
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

        # Update reputation
        self.users[seller]["reputation"] = min(1.0, self.users[seller]["reputation"] + 0.01)
        self.users[buyer]["reputation"] = min(1.0, self.users[buyer]["reputation"] + 0.01)

        print(f"Energy trade successful: {amount} units from {seller} to {buyer} for {amount * price} tokens")

    def update_grid_stability(self):
        total_capacity = sum(user["production_capacity"] for user in self.users.values())
        total_consumption = sum(user["consumption_rate"] for user in self.users.values())
        self.grid_stability = max(0.5, min(1.0, total_capacity / total_consumption))

        if self.grid_stability < 0.8:
            self.trigger_demand_response()

    def trigger_demand_response(self):
        for user in self.users.values():
            if random.random() < 0.5:  # 50% chance to participate in demand response
                user["demand_response"] = True
            else:
                user["demand_response"] = False

    def mine_block(self, miner_address: str):
        self.blockchain.mine_pending_transactions(miner_address)

    def simulate_time_step(self):
        self.current_time += 1
        self.update_weather()
        self.update_energy_levels()
        self.update_grid_stability()
        self.calculate_energy_price()
        self.execute_smart_contracts()
        print(f"Time step {self.current_time} completed. Weather: {self.weather.name}, Grid Stability: {self.grid_stability:.2f}, Energy Price: {self.energy_price:.2f}")

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
        print("7. View Grid Stats")
        print("8. Exit")

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
            duration = int(input("Enter contract duration in time steps: "))
            energy_trading.create_smart_contract(seller, buyer, amount, duration)
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
                print(f"Reputation: {user['reputation']:.2f}")
                print(f"Demand Response Active: {'Yes' if user['demand_response'] else 'No'}")
            else:
                print("User not found")

        elif choice == "7":
            print("Grid Stats:")
            print(f"Current Time: {energy_trading.current_time}")
            print(f"Weather: {energy_trading.weather.name}")
            print(f"Grid Stability: {energy_trading.grid_stability:.2f}")
            print(f"Energy Price: {energy_trading.energy_price:.2f}")
            print(f"Energy Storage Level: {energy_trading.energy_storage.current_level:.2f}/{energy_trading.energy_storage.capacity}")

        elif choice == "8":
            break

        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()