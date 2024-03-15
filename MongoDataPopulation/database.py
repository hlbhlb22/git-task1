import time

from pymongo import MongoClient
import re
import config
import random
import json


class Database:
    def __init__(self, mongo_client: MongoClient):
        self.connection = mongo_client

    def get_connection(self):
        return self.connection

    def close_connection(self):
        self.connection.close()

    def get(self, collection):
        for i in range(config.NUMBER_OF_DOCUMENTS):
            self.connection[config.DATABASE][collection].find_one()
            i += 1

    def insert(self, collection, end_time):
        with open('data.json') as file:
            file_data = json.load(file)
            file_data["inserted"] = str(time.time())
            if config.TIME_TO_EXECUTE > 0:
                while time.time() < end_time:
                    if "_id" in file_data:
                        del file_data["_id"]
                    self.connection[config.DATABASE][collection].insert_one(file_data)
            if config.NUMBER_OF_DOCUMENTS > 0:
                for i in range(config.NUMBER_OF_DOCUMENTS):
                    if "_id" in file_data:
                        del file_data["_id"]
                    self.connection[config.DATABASE][collection].insert_one(file_data)

    def update(self, collection, end_time):
        if config.TIME_TO_EXECUTE > 0:
            while time.time() < end_time:
                self.connection[config.DATABASE][collection].update_one({}, {"$set": {"updated": str(time.time())}})
        if config.NUMBER_OF_DOCUMENTS > 0:
            for i in range(config.NUMBER_OF_DOCUMENTS):
                self.connection[config.DATABASE][collection].update_one({}, {"$set": {"updated": str(time.time())}})

    def delete(self, collection, end_time):
        if config.TIME_TO_EXECUTE > 0:
            while time.time() < end_time:
                self.connection[config.DATABASE][collection].delete_one({})
        if config.NUMBER_OF_DOCUMENTS > 0:
            for i in range(config.NUMBER_OF_DOCUMENTS):
                self.connection[config.DATABASE][collection].delete_one({})

    def choose_options(self, action):
        collection = random.choice(config.COLLECTIONS)
        end_time = time.time() + config.TIME_TO_EXECUTE
        print(action + " on " + collection)
        match action:
            case "get":
                self.get(collection)
            case "insert":
                self.insert(collection, end_time)
            case "update":
                self.update(collection, end_time)
            case "delete":
                self.delete(collection, end_time)
            case _:
                print("Invalid action")
                exit(1)
