from flask import Blueprint, request, jsonify, send_from_directory
from database import db
import mysql.connector
import os
import uuid
from werkzeug.utils import secure_filename

api = Blueprint('api', __name__)

@api.route('/')
def home():
    """Home endpoint - API status"""
    return jsonify({
        'message': 'POS System API',
        'status': 'running',
        'endpoints': {
            'products': '/products',
            'orders': '/orders',
            'health': '/health'
            #remember to add the new api routes
            # i should really update these :))
        }
    })




@api.route('/health', methods=['GET'])
def health_check():
    """Check if API and database are healthy"""
    if db.test_connection():
        return jsonify({'status': 'healthy', 'database': 'connected'})
    return jsonify({'status': 'unhealthy', 'database': 'disconnected'}), 500


@api.route('/products', methods=['GET'])
def get_all_products():
    """Get all products from database"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM product WHERE is_archived = 0")#is archived = 0 the product is theere = 1 the product is archived
        products = cursor.fetchall()
        return jsonify({'products': products, 'count': len(products)})
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


    
#Still testing the route it works now wih postman and imma test it with the frontend 
@api.route('/products/paged', methods=['GET'])
def get_paged_products():
    # 1. Get Parameters
    limit = int(request.args.get('limit', 60))
    cursor_param = request.args.get('cursor')
    
    search_query = request.args.get('search')
    category_id = request.args.get('category')
    min_price = request.args.get('min_price')
    max_price = request.args.get('max_price')
    sort_AtoZ = request.args.get("sort_atoz") 
    sort_ZtoA = request.args.get("sort_ztoa")
    outOfStock = request.args.get("outofstock")
    inStock = request.args.get("instock")

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)
    try:
        # 2. Base Filters (Applied to both Data and Total Count)
        where_clauses = ["is_archived = 0"]
        params = []

        if search_query:
            where_clauses.append("name LIKE %s")
            params.append(f"%{search_query}%")
        
        if category_id:
            where_clauses.append("category_id = %s")
            params.append(category_id)

        # imma try this fix suggested by gemini: Ensure they are numbers and not empty strings for tyhe sql errors
        if min_price and min_price.strip():
            where_clauses.append("price >= %s")
            params.append(float(min_price))
            
        if max_price and max_price.strip():
            where_clauses.append("price <= %s") 
            params.append(float(max_price))

        if outOfStock:
            where_clauses.append("storage_quantity <= 0")
        elif inStock:
            where_clauses.append("storage_quantity > 0")

        # Capture the state of filters BEFORE adding cursor logic for the count
        count_where_str = " WHERE " + " AND ".join(where_clauses)
        count_params = list(params)

        # 3. Pagination & Sorting Logic
        if sort_AtoZ:
            order_by = "name ASC, id ASC"
            if cursor_param and '|' in cursor_param:
                try:
                    last_name, last_id = cursor_param.split('|')
                    where_clauses.append("(name > %s OR (name = %s AND id > %s))")
                    params.extend([last_name, last_name, last_id])
                except ValueError: pass
        elif sort_ZtoA:
            order_by = "name DESC, id ASC"
            if cursor_param and '|' in cursor_param:
                try:
                    last_name, last_id = cursor_param.split('|')
                    where_clauses.append("(name < %s OR (name = %s AND id > %s))")
                    params.extend([last_name, last_name, last_id])
                except ValueError: pass
        else:
            order_by = "id ASC"
            if cursor_param:
                where_clauses.append("id > %s")
                params.append(cursor_param)

        # 4. Fetch Products
        where_str = " WHERE " + " AND ".join(where_clauses)
        query = f"SELECT * FROM product {where_str} ORDER BY {order_by} LIMIT %s"
        cursor.execute(query, params + [limit])
        products = cursor.fetchall()
        
        # 5. Generate Next Cursor
        next_cursor = None
        if len(products) == limit:
            last_item = products[-1]
            if sort_AtoZ or sort_ZtoA:
                next_cursor = f"{last_item['name']}|{last_item['id']}"
            else:
                next_cursor = last_item['id']

        # 6. Calculate Remaining Count correctly
        # We count total matching items and subtract what we've already seen
        cursor.execute(f"SELECT COUNT(*) as total FROM product {count_where_str}", count_params)
        total_matched = cursor.fetchone()['total']
        
        remaining_count = 0
        if next_cursor:
            # To keep it simple, imma use the same where_str that i just built
            count_query = f"SELECT COUNT(*) as remaining FROM product {where_str}"
         
            cursor.execute(f"SELECT COUNT(*) as remaining FROM product {where_str.replace('>', '>=')}", params)
            remaining_count = cursor.fetchone()['remaining'] - len(products)

        return jsonify({
            'products': products,
            'count': len(products),
            'remaining_count': max(0, remaining_count),
            'next_cursor': next_cursor,
            'total_matches': total_matched
        })

    except Exception as e:
        print(f"Error: {str(e)}") # for debugging
        return jsonify({'error': str(e)}), 500
    finally: 
        db.close_connection(connection, cursor)






@api.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get a single product by ID"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
        product = cursor.fetchone()
        if product:
            return jsonify(product)
        return jsonify({'error': 'Product not found'}), 404
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/products', methods=['POST'])
def create_product():
    """Create a new product"""
    data = request.get_json()

    # Validate required fields
    if not data or 'name' not in data or 'price' not in data:
        return jsonify({'error': 'Name and price are required'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor()
    try:
        # include image_url if provided (client uploads image first and supplies URL)
        query = """
        INSERT INTO product (name, price, storage_quantity, image_url, category_id) 
        VALUES (%s, %s, %s, %s, %s)
        """
        values = (
            data['name'],
            data['price'],
            data.get('storage_quantity', 0),
            data.get('image_url'),
            data.get('category_id')#this one caused me bugs [] () 
        )

        cursor.execute(query, values)
        connection.commit()
        product_id = cursor.lastrowid

        return jsonify({
            'message': 'Product created successfully',
            'product_id': product_id
        }), 201
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

#categories get, post, delete

@api.route('/categories', methods=['GET'])
def get_all_categories():
    """Get all categories from database"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM categories")
        categories = cursor.fetchall()
        return jsonify({'categories': categories, 'count': len(categories)})
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/categories', methods=['POST'])
def create_category():
    """Create a new category"""
    data = request.get_json()

    # Validate required fields
    # if not data or 'name' not in data or 'id' not in data:
    #     return jsonify({'error': 'Name and id are required'}), 400
    if not data or 'name' not in data:
        return jsonify({'error': 'a Name for the category should be provided'}), 400

    # if 'name' in data:
    #     return jsonify({'error': 'Sorry but the name is already used'}), 400
    #this didnt work there is something wrong its checking if the name exist even in the request and therefore deletes it which is totally wrong
    # i need to find a correct way to check if the name exists in the database show a 
    # 'Polite' error message totally 'Polite' message 

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor()
    try:
        query = """
        INSERT INTO categories (name) 
        VALUES (%s)
        """
        values = (
            data['name'],#idont need to add id because i made it AUTO_INCREMENT
        )

        cursor.execute(query, values)
        connection.commit()
        category_id = cursor.lastrowid

        # return jsonify({
        #     'message': 'category created successfully',
        #     'name': category_name
        # }), 201
        cursor.execute("SELECT name FROM categories WHERE id = %s", (category_id,))
        result = cursor.fetchone()
        category_name = result[0] if result else None

        return jsonify({
            'message': 'category created successfully',
            'name': category_name
        }), 201
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/categories/delete/<int:category_id>', methods=['DELETE'])
def delete_category(category_id):
    """Delete a category"""
    # data = request.get_json()

    # if not data or 'id' not in data:
    #     return jsonify({'error': 'ID must be provided for the removal process'}), 400
    
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor()
    try:
        #cursor.execute("DELETE FROM product WHERE id = %s", (product_id,))
        #forget all this crap imma implement soft delete method where is deleted = 1 means deleted and is deleted = 0 means not deleted

        cursor.execute("DELETE FROM categories WHERE id = %s", (category_id,))
        connection.commit()
       

        if cursor.rowcount == 0:
            return jsonify({'error': 'category not found'}), 404

        return jsonify({'message': 'category deleted successfully'}), 200
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

    
@api.route('/uploads', methods=['POST']) #with lots of helps from the internet and the community
def upload_image():
    """Upload a product image, resize to a small image, and return its URL."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    # Prepare the upload folder (backend/uploads/products) brotha 
    upload_dir = os.path.join(os.path.dirname(__file__), 'uploads', 'products')
    os.makedirs(upload_dir, exist_ok=True)

    orig_name = secure_filename(file.filename)
    _, ext = os.path.splitext(orig_name)
    ext = ext.lower() if ext else '.jpg'
    filename = f"{uuid.uuid4().hex}{ext}"
    save_path = os.path.join(upload_dir, filename)

    # Try to verify/open the uploadeed file with Pillow to ensure it's an imagee
    try:
        from PIL import Image
        file.stream.seek(0)
        img = Image.open(file.stream)
        img = img.convert('RGB')
        img.thumbnail((600, 600))
        img.save(save_path, optimize=True, quality=85)
    except Exception:
        # If Pillow cannot open it, reject the upload as unsupported imma implement error handling later on
        try:
            # attempt to fallback to raw save if stream still valid
            file.stream.seek(0)
            file.save(save_path)
        except Exception: # here we go thats a good error handling imma make the ui listen to it later on 
            return jsonify({'error': 'Unsupported file type'}), 400

    # Return an absolute URL so the flutter app or client idk what to name it can use it directly
    host = request.host_url.rstrip('/')
    # The API blueprint is mounted at /api so include that prefix for the public URL
    url = f"{host}/api/uploads/products/{filename}"
    return jsonify({'url': url}), 201


@api.route('/uploads/products/<path:filename>', methods=['GET']) # now this is the opposit of ipload image this func will get the image from tyhe backend and call it to the ui 
# imma test it first with postman or the normal browser would be enough
def serve_upload(filename):
    """Serve uploaded product images (development). In production serve with Nginx/CDN."""
    upload_dir = os.path.join(os.path.dirname(__file__), 'uploads', 'products')
    return send_from_directory(upload_dir, filename)

# home made :)
#imma make it archive insted of delete
@api.route('/products/archive/<int:product_id>', methods=['PUT'])
def archive_product(product_id):
    """ARCHIVE a product by ID"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor()
    try:
        #cursor.execute("DELETE FROM product WHERE id = %s", (product_id,))
        #forget all this crap imma implement soft delete method where is deleted = 1 means deleted and is deleted = 0 means not deleted

        cursor.execute("UPDATE product SET is_archived = 1 WHERE id = %s", (product_id,))
        connection.commit()
       

        if cursor.rowcount == 0:
            return jsonify({'error': 'Product not found'}), 404

        return jsonify({'message': 'Product archived successfully'}), 200
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)



@api.route('/orders/delete/<int:order_id>', methods=['DELETE'])
def archive_order(order_id):
    """Delete an order by ID"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor()
    try:
        #cursor.execute("DELETE FROM product WHERE id = %s", (product_id,))
        #forget all this crap imma implement soft delete method where is deleted = 1 means deleted and is deleted = 0 means not deleted

        cursor.execute("DELETE FROM orders WHERE id = %s", (order_id,))
        connection.commit()
       

        if cursor.rowcount == 0:
            return jsonify({'error': 'order not found'}), 404

        return jsonify({'message': 'order deleted successfully'}), 200
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)



# @api.route('/orders', methods=['POST'])
# def create_order():
#     """Create a new order with items"""
#     data = request.get_json()

#     if not data or 'items' not in data or not data['items']:
#         return jsonify({'error': 'Order must contain items'}), 400

#     connection = db.get_connection()
#     if not connection:
#         return jsonify({'error': 'Database connection failed'}), 500

#     cursor = connection.cursor(dictionary=True)

#     try:
#         # Start transaction
#         connection.start_transaction()

#         # Step 1: Calculate total price and check stock
#         total_price = 0
#         order_items = []

#         for item in data['items']:
#             product_id = item.get('product_id')
#             quantity = item.get('quantity', 1)

#             # Get product details
#             cursor.execute(
#                 "SELECT id, name, price, storage_quantity FROM product WHERE id = %s",
#                 (product_id,)
#             )
#             product = cursor.fetchone()

#             if not product:
#                 return jsonify({'error': f'Product {product_id} not found'}), 404

#             if product['storage_quantity'] < quantity:
#                 return jsonify({
#                     'error': f'Insufficient stock for {product["name"]}. '
#                              f'Available: {product["storage_quantity"]}, Requested: {quantity}'
#                 }), 400

#             # Calculate item total
#             item_total = product['price'] * quantity
#             total_price += item_total

#             order_items.append({
#                 'product_id': product_id,
#                 'quantity': quantity,
#                 'unit_price': product['price'],
#                 'product': product
#             })

#         # Step 2: Create order record
#         cursor.execute(
#             "INSERT INTO orders (total_price, status) VALUES (%s, %s)",
#             (total_price, 'pending')
#         )
#         order_id = cursor.lastrowid

#         # Step 3: Create order items and update stock
#         for item in order_items:
#             # Insert ordered item
#             cursor.execute(
#                 """INSERT INTO ordered_item 
#                    (product_id, order_id, ordered_quantity, unit_price) 
#                    VALUES (%s, %s, %s, %s)""",
#                 (item['product_id'], order_id, item['quantity'], item['unit_price'])
#             )

#             # Update product stock
#             cursor.execute(
#                 "UPDATE product SET storage_quantity = storage_quantity - %s WHERE id = %s",
#                 (item['quantity'], item['product_id'])
#             )

#         # Step 4: Update order status to completed
#         cursor.execute(
#             "UPDATE orders SET status = 'completed' WHERE id = %s",
#             (order_id,)
#         )

#         # Commit transaction
#         connection.commit()

#         return jsonify({
#             'message': 'Order created successfully',
#             'order_id': order_id,
#             'total_price': total_price,
#             'items_count': len(order_items)
#         }), 201

#     except mysql.connector.Error as e:
#         # Rollback in case of error
#         connection.rollback()
#         return jsonify({'error': str(e)}), 500
#     finally:
#         db.close_connection(connection, cursor)

# a new order api route new 


#fetch orders api route
# @api.route('/fetchorders', methods=['GET'])
# def get_order():
#     """fetxh all the orders"""
#     connection = db.get_connection()
#     if not connection:
#         return jsonify({'error': 'Database connection failed'}), 500

#     cursor = connection.cursor(dictionary=True)
#     try:
#         # Get order info
#         cursor.execute("SELECT * FROM orders")
#         order = cursor.fetchone()

#         if not order:
#             return jsonify({'error': 'Order not found'}), 404

        # Get order items
        # cursor.execute("""
        #     SELECT oi.*, p.name as product_name 
        #     FROM ordered_item oi
        #     JOIN product p ON oi.product_id = p.id
        #     WHERE oi.order_id = %s
        # """, (order_id,))
    #     items = cursor.fetchall()

    #     order['items'] = items
    #     return jsonify(order)

    # except mysql.connector.Error as e:
    #     return jsonify({'error': str(e)}), 500
    # finally:
    #     db.close_connection(connection, cursor)




@api.route('/orders', methods=['POST'])#MARK: NEW ORDER API ROUTE
def create_order():
    """Process a checkout: Snapshot prices, create order, and update stock"""
    data = request.get_json()

    # Expected JSON: {"items": [{"product_id": 1, "quantity": 2}, {"product_id": 2, "quantity": 1}]}
    if not data or 'items' not in data or not data['items']:
        return jsonify({'error': 'Order must contain items'}), 400 

    connection = db.get_connection()
    if not connection: 
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)

    try: 
        # Start transaction: if one item fails, the whole order is canceled
        connection.start_transaction()

        # Step 1: Create the 'Parent' Order entry
        cursor.execute("INSERT INTO orders (total_price) VALUES (%s)", (0,))
        order_id = cursor.lastrowid        
        
        total_order_price = 0 

        # Step 2: Loop through items and create "Snapshots"
        for item in data['items']:
            pid = item.get('product_id')
            qty = item.get('quantity', 1)

            # Get the current "Live" price from inventory
            cursor.execute("SELECT name, price, storage_quantity FROM product WHERE id = %s", (pid,))
            product = cursor.fetchone()

            if not product:
                connection.rollback()
                return jsonify({'error': f'Product {pid} not found'}), 404
            
            if product['storage_quantity'] < qty:
                connection.rollback()
                return jsonify({'error': f'Insufficient stock for {product["name"]}'}), 400
            
            # SNAPSHOT CALCULATION
            current_unit_price = product['price'] 
            item_total = current_unit_price * qty
            total_order_price += item_total # Accumulates total for all items

            # Insert into ordered_item using your EXACT column: 'quantity'
            cursor.execute("""
                INSERT INTO ordered_item (order_id, product_id, quantity, unit_price) 
                VALUES (%s, %s, %s, %s)
            """, (order_id, pid, qty, current_unit_price))

            # Deduct from inventory (IT WORKD RN) i have top edit the ui now so it updates the ui whenever i click the checkout button and removes one the quantity from the item in the ui
            # cursor.execute(
            #      "UPDATE product SET storage_quantity = storage_quantity - %s WHERE id = %s", 
            #      (qty, pid)
            #  )
            cursor.execute(
                "UPDATE product SET storage_quantity = storage_quantity - %s WHERE id = %s", 
                (qty, pid)
            )

        # Update the final total in the parent order table
        cursor.execute("UPDATE orders SET total_price = %s WHERE id = %s", (total_order_price, order_id))

        # Finalize the transaction
        connection.commit()
        
        return jsonify({
            'message': 'Checkout complete',
            'order_id': order_id,
            'total': float(total_order_price)
        }), 201
    
    except mysql.connector.Error as e:
        connection.rollback() # Safely undo everything on error
        return jsonify({'error': str(e)}), 500
    finally: 
        db.close_connection(connection, cursor)

        """CREATE TABLE ordered_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0), -- Corrected column name here!
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES `orders`(id) ON DELETE CASCADE, -- Escaped if 'orders' is a keyword
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE RESTRICT
);


UPDATE table_name
SET quantity = quantity - 1
WHERE product_id = the id i get from the user;

        """


@api.route('/orders/<int:order_id>', methods=['GET']) # never used it yet idk why i thouyght i might need it but later i might implement orsers search then this would be usefull somehow

def get_order(order_id):
    """Get order details with items"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        # Get order info
        cursor.execute("SELECT * FROM orders WHERE id = %s", (order_id,))
        order = cursor.fetchone()

        if not order:
            return jsonify({'error': 'Order not found'}), 404

        # Get order items
        cursor.execute("""
            SELECT oi.*, p.name as product_name 
            FROM ordered_item oi
            JOIN product p ON oi.product_id = p.id
            WHERE oi.order_id = %s
        """, (order_id,))
        items = cursor.fetchall()

        order['items'] = items
        return jsonify(order)

    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/orders', methods=['GET'])
def get_all_orders():
    """Return all orders with their items"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM orders ORDER BY id DESC")
        orders = cursor.fetchall()

        # attach items for each order
        for order in orders:
            cursor.execute(
                """
                SELECT oi.*, p.name as product_name
                FROM ordered_item oi
                JOIN product p ON oi.product_id = p.id
                WHERE oi.order_id = %s
                """,
                (order['id'],)
            )
            items = cursor.fetchall()
            order['items'] = items

        return jsonify({'orders': orders, 'count': len(orders)})
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/products/<int:product_id>', methods=['PUT']) # for later usage when i want to update product info i know the enginner would tell me to do thats why i added it for later usage

def update_product(product_id):
    """Update product information"""
    data = request.get_json()

    if not data:
        return jsonify({'error': 'No data provided'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor()
    try:
        # Build update query dynamically based on provided fields
        update_fields = []
        values = []

        if 'name' in data:
            update_fields.append("name = %s")
            values.append(data['name'])

        if 'price' in data:
            update_fields.append("price = %s")
            values.append(data['price'])

        if 'storage_quantity' in data:
            update_fields.append("storage_quantity = %s")
            values.append(data['storage_quantity'])

        if not update_fields:
            return jsonify({'error': 'No fields to update'}), 400

        values.append(product_id)
        query = f"UPDATE product SET {', '.join(update_fields)} WHERE id = %s"

        cursor.execute(query, values)
        connection.commit()

        if cursor.rowcount == 0:
            return jsonify({'error': 'Product not found'}), 404

        return jsonify({'message': 'Product updated successfully'})

    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)
