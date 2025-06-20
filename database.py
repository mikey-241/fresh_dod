import oracledb
from sqlalchemy import create_engine

#thicc mode
oracledb.init_oracle_client(lib_dir=r"H:\dod_work\dod_page\instantclient_21_18")

# Database credentials
# update this later with environment variables or a config file.
username = "CMDB"
password = "Newyear2020"
host = "P7CML1D1.AZ.3PC.ATT.COM"
port = 1521
sid = "P7CML1D1"

# DSN for SID Oracle connection
dsn = oracledb.makedsn(host, port, sid=sid)

# SQLAlch connection string
oracle_connection_string = f"oracle+oracledb://{username}:{password}@{dsn}"

# SQLAlch engine
engine = create_engine(oracle_connection_string)

def get_db_engine():
    """Returns the SQLAlchemy engine for database connections."""
    return engine