import time
import config
from database import Database
from sshtunnel import SSHTunnelForwarder
from pymongo import MongoClient

if __name__ == '__main__':
    server = SSHTunnelForwarder(
        (config.REMOTE_SERVER_IP, config.REMOTE_SERVER_SSH_PORT),  # Remote server IP and SSH port
        ssh_username=config.SSH_USERNAME,
        ssh_password=config.SSH_PASSWORD,
        remote_bind_address=(config.REMOTE_MONGO_HOST, config.REMOTE_MONGO_PORT),
        # MongoDB host and port on the remote server
    )
    server_secondary = SSHTunnelForwarder(
        ("10.202.15.136", config.REMOTE_SERVER_SSH_PORT),  # Remote server IP and SSH port
        ssh_username=config.SSH_USERNAME,
        ssh_password=config.SSH_PASSWORD,
        remote_bind_address=("10.202.15.136", config.REMOTE_MONGO_PORT),
        # MongoDB host and port on the remote server
    )
    server.start()
    server_secondary.start()

    mongo_client = MongoClient(
        config.LOCAL_MONGO_HOST,
        server.local_bind_port,
        replicaset=config.REPLICASET_NAME,
    )  # for remote server
    mongo_client_secondary = MongoClient(
        config.LOCAL_MONGO_HOST,
        server_secondary.local_bind_port,
        replicaset=config.REPLICASET_NAME,
    )  # for remote server
    database = Database(mongo_client)
    database_secondary = Database(mongo_client_secondary)
    start_time = time.time()

    time_for_primary = 0
    time_for_secondary = 0

    while True:
        if(database.check_if_database_size_exceeds_threshold()):
            # database.free_space()
            # print((time.time() - start_time) / 60, " minutes")
            if (time_for_primary == 0):
                time_for_primary = time.time() - start_time
        if (database_secondary.check_if_database_size_exceeds_threshold()):
            # database_secondary.free_space()
            # print((time.time() - start_time) / 60, " minutes")
            time_for_secondary = time.time() - start_time
            print("Primary: ", time_for_primary, " seconds")
            print("Secondary: ", time_for_secondary, " seconds")
            print("Difference: ", time_for_secondary - time_for_primary, " seconds")
            database.close_connection()
            database_secondary.close_connection()
            break
        time.sleep(1)
