import random
import time

from pymongo import MongoClient
import config


class Database:
    def __init__(self, mongo_client: MongoClient):
        self.connection = mongo_client

    def get_connection(self):
        return self.connection

    def close_connection(self):
        self.connection.close()

    def get_database_size(self):
        data_size = self.connection[config.DATABASE].command("dbStats")["dataSize"]
        data_size_in_GB = round(data_size/(1024 * 1024 * 1024), 5)
        return data_size, data_size_in_GB

    def check_if_database_size_exceeds_threshold(self):
        data_size, data_size_in_GB = self.get_database_size()
        print("Database size: " + str(data_size) + " bytes (" + str(data_size_in_GB) + " GB)")
        if data_size > config.THRESHOLD_DB_SIZE * 1024 * 1024 * 1024:
           print("Database is full")
           return True
        return False

    def free_space(self):
        print("Clean up started.")
        end_time = time.time() + config.EXECUTION_TIME
        while time.time() < end_time:
            collection = random.choice(config.COLLECTIONS)
            self.connection[config.DATABASE][collection].delete_one({})