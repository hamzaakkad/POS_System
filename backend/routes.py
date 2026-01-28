from flask import Blueprint, request, jsonify, send_from_directory
from database import db
import mysql.connector
import os
import uuid
from werkzeug.utils import secure_filename
import bcrypt

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


# @api.route('/products', methods=['GET'])
# def get_all_products():
#     """Get all products from database"""
#     connection = db.get_connection()
#     if not connection:
#         return jsonify({'error': 'Database connection failed'}), 500

#     cursor = connection.cursor(dictionary=True)
#     try:
#         cursor.execute("SELECT * FROM product WHERE is_archived = 0")#is archived = 0 the product is theere = 1 the product is archived
#         products = cursor.fetchall()
#         return jsonify({'products': products, 'count': len(products)})
#     except mysql.connector.Error as e:
#         return jsonify({'error': str(e)}), 500
#     finally:
#         db.close_connection(connection, cursor)
@api.route('/products', methods=['GET'])
def get_all_products():
    connection = db.get_connection()
    cursor = connection.cursor(dictionary=True)
    try:
        # This query joins the relation table to get the category_id
        # Note: If a product has multiple, it might return multiple rows, 
        # so for now we'll just get the 'first' one found. شىي  
        #and all of that didnt work 
        # its driving me crazyyy
        query = """
            SELECT p.*, 
            (SELECT category_id FROM product_category_rel WHERE product_id = p.id LIMIT 1) as category_id
            FROM product p 
            WHERE p.is_archived = 0
        """
        cursor.execute(query)
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
        where_clauses = ["p.is_archived = 0"]
        params = []
        
        # Handle JOIN for category filtering
        join_clause = ""
        if category_id:
            join_clause = "INNER JOIN product_category_rel rel ON p.id = rel.product_id"
            where_clauses.append("rel.category_id = %s")
            params.append(category_id)

        if search_query:
            where_clauses.append("p.name LIKE %s")
            params.append(f"%{search_query}%")

        # imma try this fix suggested by gemini: Ensure they are numbers and not empty strings for tyhe sql errors
        if min_price and min_price.strip():
            where_clauses.append("p.price >= %s")
            params.append(float(min_price))
            
        if max_price and max_price.strip():
            where_clauses.append("p.price <= %s") 
            params.append(float(max_price))

        if outOfStock:
            where_clauses.append("p.storage_quantity <= 0")
        elif inStock:
            where_clauses.append("p.storage_quantity > 0")

        # Capture the state of filters BEFORE adding cursor logic for the count
        count_where_str = " WHERE " + " AND ".join(where_clauses)
        count_params = list(params)

        # 3. Pagination & Sorting Logic
        if sort_AtoZ:
            order_by = "p.name ASC, p.id ASC"
            if cursor_param and '|' in cursor_param:
                try:
                    last_name, last_id = cursor_param.split('|')
                    where_clauses.append("(p.name > %s OR (p.name = %s AND p.id > %s))")
                    params.extend([last_name, last_name, last_id])
                except ValueError: pass
        elif sort_ZtoA:
            order_by = "p.name DESC, p.id ASC"
            if cursor_param and '|' in cursor_param:
                try:
                    last_name, last_id = cursor_param.split('|')
                    where_clauses.append("(p.name < %s OR (p.name = %s AND p.id > %s))")
                    params.extend([last_name, last_name, last_id])
                except ValueError: pass
        else:
            order_by = "p.id ASC"
            if cursor_param:
                where_clauses.append("p.id > %s")
                params.append(cursor_param)

        # 4. Fetch Products
        where_str = " WHERE " + " AND ".join(where_clauses)
        query = f"SELECT p.* FROM product p {join_clause} {where_str} ORDER BY {order_by} LIMIT %s"
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
        count_query = f"SELECT COUNT(*) as total FROM product p {join_clause} {count_where_str}"
        cursor.execute(count_query, count_params)
        total_matched = cursor.fetchone()['total']
        
        remaining_count = 0
        if next_cursor:
            # To keep it simple, imma use the same where_str that i just built
            remaining_query = f"SELECT COUNT(*) as remaining FROM product p {join_clause} {where_str}"
         
            cursor.execute(remaining_query, params)
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


# @api.route('/categories/manytomany/<int:category_id>', methods = ['GET'])
# def get_products_in_categories(category_id):
#     """Get all products in the category id based on the Many to Many relationship between the product table
#     and the category table setting in in the product_category_rel table just like orders and 
#     ordered_item relationship with product table"""
#     connection = db.get_connection()
#     if not connection:
#         return jsonify({'error': 'Database connection failed'}), 500
    
#     cursor = connection.cursor(dictionary=True)
#     try:
#         cursor.execute("SELECT * FROM product_category_rel WHERE category_id = %s ", (category_id,))
#         product_id = cursor.fetchall()
        
#         return jsonify({'product_id': product_id, 'count': len(product_id)})
    
#     except mysql.connector.Error as e:
#             return jsonify({'error': str(e)}), 500
#     finally:
#             db.close_connection(connection, cursor)
#THIS WORKSSSSS :) 
@api.route('/categories/<int:category_id>/products', methods=['GET'])
def get_products_by_category(category_id):
    """
    Get all full product details associated with a specific category ID
    using the product_category_rel many-to-many table.
    """
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)
    try:
        # SQL Logic:
        # 1. Select everything from 'product' (p)
        # 2. Join with 'product_category_rel' (rel) where IDs match
        # 3. Filter by the category_id provided in the URL
        query = """
            SELECT p.* FROM product p
            INNER JOIN product_category_rel rel ON p.id = rel.product_id
            WHERE rel.category_id = %s AND p.is_archived = 0
        """
        
        cursor.execute(query, (category_id,))
        products = cursor.fetchall()
        
        # Return the list of products and a their count
        return jsonify({
            'category_id': category_id,
            'count': len(products),
            'products': products
        }), 200

    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get a single product by ID with its associated categories"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        # Fetch the product
        cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
        product = cursor.fetchone()
        
        if product:
            # Fetch all categories linked to this product
            cursor.execute(
                "SELECT category_id FROM product_category_rel WHERE product_id = %s",
                (product_id,)
            )
            category_rows = cursor.fetchall()
            category_ids = [row['category_id'] for row in category_rows]
            
            # Add category_ids to the product response
            product['category_ids'] = category_ids
            return jsonify(product)
        return jsonify({'error': 'Product not found'}), 404
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

@api.route('/categories/edit/<int:category_id>', methods=['PUT'])
def edit_category(category_id):
    """edit an existing category"""

    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
         #Start transaction func does this: if category update fails, product info isn't left half-updated
        connection.start_transaction()
        
        update_category_query = """UPDATE categories SET name = %s WHERE id = %s"""

        cursor.execute("SELECT name FROM categories WHERE id = %s", (category_id,))
        existing = cursor.fetchone()

        if not existing: 
            return jsonify({'error': 'Category not found'}), 400
        category_values = (
            data.get('name', existing['name']),
            category_id
        )
        name = data.get('name')
        cursor.execute(update_category_query, category_values) # now this connects it al

        connection.commit()

        return jsonify({
            'message': 'Category updated successfully',
            'category_id': category_id,
            'new name': name
            
        }),200
    except mysql.connector.Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

# @api.route('/products', methods=['POST'])
# def create_product():
#     """Create a new product"""
#     data = request.get_json()

#     # Validate required fields
#     if not data or 'name' not in data or 'price' not in data:
#         return jsonify({'error': 'Name and price are required'}), 400

#     connection = db.get_connection()
#     if not connection:
#         return jsonify({'error': 'Database connection failed'}), 500

#     cursor = connection.cursor()
#     try:
#         # include image_url if provided (client uploads image first and supplies URL)
#         query = """
#         INSERT INTO product (name, price, storage_quantity, image_url) 
#         VALUES (%s, %s, %s, %s)
#         """
#         values = (
#             data['name'],
#             data['price'],
#             data.get('storage_quantity', 0),
#             data.get('image_url'),
#            # data.get('category_id')#this one caused me bugs [] () 
#         )

#         cursor.execute(query, values)
#         connection.commit()
#         product_id = cursor.lastrowid

#         return jsonify({
#             'message': 'Product created successfully',
#             'product_id': product_id
#         }), 201
#     except mysql.connector.Error as e:
#         return jsonify({'error': str(e)}), 500
#     finally:
#         db.close_connection(connection, cursor)
@api.route('/products', methods=['POST'])
def create_product():
    """Create a new product and link it to multiple categories"""
    data = request.get_json()

    # Validate 
    if not data or 'name' not in data or 'price' not in data:
        return jsonify({'error': 'Name and price are required'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    
    cursor = connection.cursor()
    try:
        # STEP 1: Insert into the product tableww
        product_query = """
        INSERT INTO product (name, price, storage_quantity, image_url) 
        VALUES (%s, %s, %s, %s)
        """
        product_values = (
            data['name'],
            data['price'],
            data.get('storage_quantity', 0),
            data.get('image_url')
        )
        cursor.execute(product_query, product_values)
        
        # Get the ID of the product that the user just created
        product_id = cursor.lastrowid#i made this insted of making multiple calls and putting it in the ui that would make the ui even slower and wont be effecient but i was brilliant and i thought anything that can be processed in the frontend  can also be processed in the backend and thats how i made this route work with multiple categories linked to one product
            
        #  Handle Category Relationships
        # Expecting 'category_ids' as a list from Flutter, e.g., [1, 2] imma implement the list mechanism rn in the frontend ( service / provider )
        category_ids = data.get('category_ids', [])
        
        # If the user sent a single 'category_id' instead of a list, wrap it in a list why ? because i built everything to accept list and i dont want the user to ruin it rn
        if 'category_id' in data and not category_ids:
            category_ids = [data['category_id']]

        if category_ids:
            rel_query = "INSERT INTO product_category_rel (product_id, category_id) VALUES (%s, %s)"
            # Prepare the data for multiple inserts
            rel_values = [(product_id, cat_id) for cat_id in category_ids]
            
            # executemany is efficient for inserting multiple rows at once
            cursor.executemany(rel_query, rel_values)

        # Commit everything at once
        connection.commit()

        return jsonify({
            'message': 'Product and category links created successfully',
            'product_id': product_id,
            'linked_categories': category_ids
        }), 201

    except mysql.connector.Error as e:
        connection.rollback()  # Undo changes if something goes wrong
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


# @api.route('/products/<int:product_id>', methods=['PUT']) # for later usage when i want to update product info i know the enginner would tell me to do thats why i added it for later usage
# # //she just told me 

# def update_product(product_id):
#     """Update product details"""
#     data = request.get_json()
#     if not data:
#         return jsonify({"error": "No data provided"}), 400

#     connection = db.get_connection()
#     if not connection:
#         return jsonify({"error": "Database connection failed"}), 500
    
#     cursor = connection.cursor()
#     try:
#         update_fields = []
#         values = []

     
#         if 'name' in data:
#             update_fields.append("name = %s")
#             values.append(data['name'])
#         if 'price' in data:
#             update_fields.append("price = %s")
#             values.append(data['price'])
#         if 'storage_quantity' in data:
#             update_fields.append("storage_quantity = %s")
#             values.append(data['storage_quantity'])

#         if not update_fields:
#             return jsonify({"error": "No fields to update"}), 400

       
#         values.append(product_id)
        
       
#         query = f"UPDATE product SET {', '.join(update_fields)} WHERE id = %s"
        
#         cursor.execute(query, values)
#         connection.commit()

        
#         if cursor.rowcount == 0:
#             return jsonify({"error": "Product not found"}), 404

#         return jsonify({"message": "Product updated successfully"})

#     except mysql.connector.Error as e:
#         return jsonify({"error": str(e)}), 500
#     finally:
        
#         db.close_connection(connection, cursor)
@api.route('/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Update product details and refresh category links"""
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        # Start transaction func does this: if category update fails, product info isn't left half-updated
        connection.start_transaction()

        # 1. Update the Product Table
        # We use COALESCE to keep existing values if the user doesn't provide a specific field
        update_product_query = """
            UPDATE product 
            SET name = %s, 
                price = %s, 
                storage_quantity = %s, 
                image_url = %s
            WHERE id = %s
        """
        # It is safer to fetch the existing product first or use a query that handles partial updates
        # For simplicity imma assume the frontend sends the full object or we use the data provided for fillig purposes
        cursor.execute("SELECT * FROM product WHERE id = %s", (product_id,))
        existing = cursor.fetchone()
        
        if not existing:
            return jsonify({'error': 'Product not found'}), 404

        product_values = (
            data.get('name', existing['name']),
            data.get('price', existing['price']),
            data.get('storage_quantity', existing['storage_quantity']),
            data.get('image_url', existing['image_url']),
            product_id
        )
        cursor.execute(update_product_query, product_values)

        # 2. Update Categories (The Many-to-Many part)
        # imma  only update categories if 'category_ids' is present in the request else no keep it as is
        if 'category_ids' in data:
            new_category_ids = data['category_ids'] # Expecting a list: [1, 2, 3] just like the create route

            # Step A: Delete all existing relationships for this product
            cursor.execute("DELETE FROM product_category_rel WHERE product_id = %s", (product_id,))

            # Step B: Insert the new relationships
            if new_category_ids:
                rel_query = "INSERT INTO product_category_rel (product_id, category_id) VALUES (%s, %s)"
                rel_values = [(product_id, cat_id) for cat_id in new_category_ids]
                cursor.executemany(rel_query, rel_values)

        connection.commit()
        return jsonify({
            'message': 'Product updated successfully',
            'product_id': product_id
        }), 200

    except mysql.connector.Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)



# @api.route('/users/login')
# def login():
#     """Login the user"""

# @api.route('/users/signup', methods=['POST'])
# def signup():
#     data = request.get_json()

#     #validation
#     if not data or 'email' not in data or 'password' not in data or 'name' not in data:
#         return jsonify({'error': 'All fields are required!'}), 400

#     connection = db.get_connection
#     if not connection:
#         return jsonify({'error': 'Database connection failed'}), 500
    
#     cursor = connection.cursor()

#     try:
#         # 1 add the parameters and values
#         signup_query = """INSERT INTO users (name, email, password) VALUES (%s, %s, %s)"""

#         signup_values = (
#             data['name'],
#             data['email'],
#             data['password']
#         )
#         cursor.execute(signup_query, signup_values)

#         connection.commit()
#         return jsonify({
#             'message': 'User signed up successfully',
#             'name': data['name'],
#             'email': data['email']
#         }), 201

#     except mysql.connector.Error as e:
#         connection.rollback()  # Undo changes if something goes wrong
#         return jsonify({'error': str(e)}), 500
#     finally:
#         db.close_connection(connection, cursor)


@api.route('/users/signup', methods=['POST'])
def signup():
    data = request.get_json()

    # Validation 
    required_fields = ['email', 'password', 'name']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'error': 'All fields are required!'}), 400
    
    # Additional validation i like those 
    if not isinstance(data['email'], str) or '@' not in data['email']:
        return jsonify({'error': 'Valid email is required'}), 400
    
    if not isinstance(data['password'], str) or len(data['password']) < 6:
        return jsonify({'error': 'Password must be at least 6 characters'}), 400
    
    if not isinstance(data['name'], str) or len(data['name'].strip()) == 0:
        return jsonify({'error': 'Valid name is required'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor()

    try:
        # Check if email already exists in db
        check_email_query = "SELECT id FROM users WHERE email = %s"
        cursor.execute(check_email_query, (data['email'].strip().lower(),))
        if cursor.fetchone():
            return jsonify({'error': 'Email already exists'}), 409  # 409 Conflict

        # hashing password using bcrypt
        hashed_password = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())
        
        signup_query = """INSERT INTO users (name, email, password) VALUES (%s, %s, %s)"""
        signup_values = (
            data['name'].strip(),
            data['email'].strip().lower(),  # some funcs to Normalize the email
            hashed_password.decode('utf-8')  
            #data['password']
        )
        cursor.execute(signup_query, signup_values)
        user_id = cursor.lastrowid  # Get the auto-generated ID from the db
        
        connection.commit()
        
        return jsonify({
            'message': 'User signed up successfully',
            'user': {
                'id': user_id,
                'name': data['name'],
                'email': data['email']
            }
        }), 201

    except mysql.connector.Error as e:
        connection.rollback()
        # Log the actual error for debugging
        print(f"Database error: {e}")
        return jsonify({'error': 'Registration failed'}), 500
    except Exception as e:
        connection.rollback()
        
        return jsonify({'error': f'An unexpected error occurred: {str(e)}'}), 500
    finally:
        db.close_connection(connection, cursor)

@api.route('/users/login', methods=['POST'])
def login():
    data = request.get_json()

    # Validation
    if not data or 'email' not in data or 'password' not in data:
        return jsonify({'error': 'Email and password are required'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)  # Get results as dict

    try:
        #Find the mr. user by email
        login_query = "SELECT id, name, email, password FROM users WHERE email = %s"
        cursor.execute(login_query, (data['email'].strip().lower(),))
        user = cursor.fetchone()
        
        #Checking if the  user exists
        if not user:
            # Don't reveal if email exists or not (security best practice)
            return jsonify({'error': 'Invalid credentials'}), 401
        
        #Verify password

        # Assuming password is stored as string in the DB imma encode it back to bytes and validate
        stored_hash = user['password'].encode('utf-8') if isinstance(user['password'], str) else user['password']
        entered_password = data['password'].encode('utf-8')
        
        if bcrypt.checkpw(entered_password, stored_hash):
            #Password matches - Login successful!
 
            
            return jsonify({
                'message': 'Login successful',
                'user': {
                    'id': user['id'],
                    'name': user['name'],
                    'email': user['email']
                }
               
            }), 200
        else:
            #Password doesn't match "_"
            return jsonify({'error': 'Invalid credentials'}), 401

    except mysql.connector.Error as e:
        return jsonify({'error': 'Login failed'}), 500
    except Exception as e:
        return jsonify({'error': f'An unexpected error occurred: {str(e)}'}), 500
    finally:
        db.close_connection(connection, cursor)


# @api.route('/users/getlogin/<int:user_id>', methods=['GET'])
# def get_login_info(user_id):

#     # data = request.get_json()
#     # if not data or 'user_id' not in data:
#     #     return jsonify({'error': 'You should provide the user ID'}), 400

#     connection = db.get_connection
#     if not connection :
#         return jsonify({'error': 'Database connectio failed'}), 500

    
#     cursor = connection.cursor (dictionary=True) # so i get the results as a dict

#     try:
#        # get_login_query = "SELECT id, name, email, FROM users WHERE id = %s"

#         # cursor.execute(get_login_query, data['user_id'])
#        # cursor.execute(get_login_info, user_id)
#         cursor.execute("SELECT id, name, email, role, FROM users WHERE id = %s", (user_id,))
#         user = cursor.fetchdone()

#         if not user:

#             return jsonify({'error': 'You are not signed up yet Sign up then retry'}), 401
        

#         return jsonify({
#             'message': 'User data are',
#             'user': {
#                 'id': user['id'],
#                 'name': user['name'],
#                 'email': user['email']
#             }
#         }), 200

#     except mysql.connector.Error as e:
#         return jsonify({'error': 'Login failed'}), 500
#     except Exception as e:
#         return jsonify({'error': f'An unexpected error occurred: {str(e)}'}), 500
#     finally:
#         db.close_connection(connection, cursor)

@api.route('/users/getuser/<int:user_id>', methods=['GET'])
def get_users(user_id):
    """Get a user data by ID"""
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        cursor.execute("SELECT id, name, email, role FROM users WHERE id = %s", (user_id,))
        product = cursor.fetchone()
        if product:
            return jsonify(product)
        return jsonify({'error': 'User not found, if you are not signed up try signing up first then retry'}), 404
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)
