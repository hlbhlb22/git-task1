import random
import threading
import time
from database import Database
import config
from sshtunnel import SSHTunnelForwarder
from pymongo import MongoClient
from pymongo import errors

if __name__ == '__main__':
    try:
        server = SSHTunnelForwarder(
            (config.REMOTE_SERVER_IP, config.REMOTE_SERVER_SSH_PORT),  # Remote server IP and SSH port
            ssh_username=config.SSH_USERNAME,
            ssh_password=config.SSH_PASSWORD,
            remote_bind_address=(config.REMOTE_MONGO_HOST, config.REMOTE_MONGO_PORT),  # MongoDB host and port on the remote server
        )
        server.start()

        mongo_client = MongoClient(
            config.LOCAL_MONGO_HOST,
            server.local_bind_port,
            #replicaset=config.REPLICASET_NAME,
        )  # for remote server

        # mongo_client = MongoClient(config.CONNECTION_STRING) # for local server

        database = Database(mongo_client)
        connection = database.get_connection()
        threads = []
        start_time = time.time()
        for i in range(config.NUMBER_OF_THREADS):
            action = random.choice(config.ACTIONS)
            t = threading.Thread(target=lambda: database.choose_options(action))  # target is randomly picked
            threads.append(t)
            t.start()
            time.sleep(config.DELAY_BETWEEN_LOOPS)
        for t in threads:
            t.join()
        database.close_connection()

        print("Time taken: " + str(time.time() - start_time))
        print("in minutes: " + str((time.time() - start_time) / 60))
        server.stop()
    except Exception as e:
        print(e)
        server.stop()
        exit(1)