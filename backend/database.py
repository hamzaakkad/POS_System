import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class DatabaseConnection:
    """Handles all database connections for the POS system"""

    def __init__(self):
        # Get database configuration from .env file
        self.config = {
            'host': os.getenv('DB_HOST', 'localhost'),
            'port': os.getenv('DB_PORT', '3306'),
            'database': os.getenv('DB_NAME', 'pos_system'),
            'user': os.getenv('DB_USER', 'root'),
            'password': os.getenv('DB_PASSWORD', 'macbookair7,1')
        }

    def get_connection(self):
        """
        Creates and returns a database connection

        Returns:
            connection: MySQL connection object or None if failed
        """
        try:
            connection = mysql.connector.connect(**self.config)
            print(f"Successfully connected to database: {self.config['database']}")
            return connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            return None

    def close_connection(self, connection, cursor=None):
        """
        Safely closes database connection and cursor

        Args:
            connection: MySQL connection object
            cursor: Database cursor object (optional)
        """
        try:
            if cursor:
                cursor.close()
            if connection and connection.is_connected():
                connection.close()
                print("Database connection closed")
        except Error as e:
            print(f"Error closing connection: {e}")

    def test_connection(self):
        """Test if database connection works"""
        connection = self.get_connection()
        if connection:
            cursor = connection.cursor()
            cursor.execute("SELECT DATABASE()")
            db_name = cursor.fetchone()[0]
            print(f"Connected to database: {db_name}")
            self.close_connection(connection, cursor)
            return True
        return False


# Create a global instance for easy access
db = DatabaseConnection()