from flask import Flask, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
from routes import api

# Load environment variables
load_dotenv()

def create_app():
    """Application factory function"""
    # Create Flask app
    app = Flask(__name__)

    # Configure CORS Allows my Flutter app to access the API
    CORS(app, resources={
        r"/*": {
            "origins": ["http://localhost:3000", "http://localhost:8081"],
            "methods": ["GET", "POST", "PUT", "DELETE"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })

    # Register API blueprint
    app.register_blueprint(api, url_prefix='/api')

    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Endpoint not found'}), 404

    @app.errorhandler(500)
    def server_error(error):
        return jsonify({'error': 'Internal server error'}), 500

    return app


if __name__ == '__main__':
    app = create_app()

    # Get configuration from environment
    host = os.getenv('FLASK_HOST', '0.0.0.0')
    port = int(os.getenv('FLASK_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'

    print(f" Starting POS System Backend...")
    print(f" API URL: http://{host}:{port}/api")
    print(f" API Documentation:")
    print(f"   GET  /api/               - API status")
    print(f"   GET  /api/health         - Health check")
    print(f"   GET  /api/products       - Get all products")
    print(f"   POST /api/products       - Create product")
    print(f"   GET  /api/products/<id>  - Get product by ID")
    print(f"   PUT  /api/products/<id>  - Update product")
    print(f"   POST /api/orders         - Create order")
    print(f"   GET  /api/orders/<id>    - Get order details")

    app.run(host=host, port=port, debug=debug)