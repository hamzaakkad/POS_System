import requests
import json
# litterly forgot howw to use it ;) if ibwant i can read it. but developers are pretty lazy ;)
BASE_URL = "http://localhost:5000/api"

def test_endpoint(method, endpoint, data=None):
    """Test an API endpoint"""
    url = f"{BASE_URL}{endpoint}"
    try:
        if method == 'GET':
            response = requests.get(url)
        elif method == 'POST':
            response = requests.post(url, json=data)
        elif method == 'PUT':
            response = requests.put(url, json=data)

        print(f"\n{'='*60}")
        print(f"Testing {method} {endpoint}")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response

    except Exception as e:
        print(f"Error: {e}")
        return None

def run_tests():
    """Run all tests"""
    print("🧪 Starting Backend API Tests")

    # 1. Test API status
    test_endpoint('GET', '/')

    # 2. Test health check
    test_endpoint('GET', '/health')

    # 3. Test get all products
    test_endpoint('GET', '/products')

    # 4. Test create product
    new_product = {
        "name": "Wireless Mouse",
        "price": 35.99,
        "storage_quantity": 50
    }
    response = test_endpoint('POST', '/products', new_product)

    # 5. Test create order (using first two products)
    if response and 'product_id' in response.json():
        new_order = {
            "items": [
                {"product_id": 1, "quantity": 1},
                {"product_id": 2, "quantity": 2}
            ]
        }
        test_endpoint('POST', '/orders', new_order)

    print(f"\n{'='*60}")
    print("✅ All tests completed!")

if __name__ == '__main__':
    # Make sure Flask server is running first!
    print("  Make sure Flask server is running on port 5000")
    input("Press Enter to start tests...")
    run_tests()