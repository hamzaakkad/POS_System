from flask import Blueprint, request, jsonify, send_from_directory
from database import db
import mysql.connector
import os
import uuid
from werkzeug.utils import secure_filename
import bcrypt
from decimal import Decimal


# --- permission helpers ----------------------------------------------------

def _user_has_page_permission(user_id: int, page_key: str, cursor) -> bool:
    # look up mapping
    cursor.execute("""
        SELECT permission_id FROM page_permission WHERE page_key = %s
    """, (page_key,))
    row = cursor.fetchone()
    if not row:
        return True
    perm_id = row.get('permission_id')
    if not perm_id:
        return True
    # check if user's role has this permission
    cursor.execute("""
        SELECT 1
        FROM users u
        JOIN role_permission rp ON u.role_id = rp.role_id
        WHERE u.id = %s AND rp.permission_id = %s
    """, (user_id, perm_id))
    return cursor.fetchone() is not None


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

            #FR
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


@api.route('/admin/users', methods=['GET'])
def admin_list_users():
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        query = """
            SELECT u.id, u.name, u.email, u.role_id, r.role as role
            FROM users u
            LEFT JOIN role r ON u.role_id = r.id
        """
        cursor.execute(query)
        users = cursor.fetchall()
        return jsonify({'users': users}), 200
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/admin/roles', methods=['GET', 'POST'])# imma add DELETE later after i test this and it works
def admin_roles():
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            # Fetch roles with their permissions
            query = """
                SELECT r.id AS role_id, r.role AS role_name, p.id AS permission_id, p.permission AS permission_name
                FROM role r
                LEFT JOIN role_permission rp ON r.id = rp.role_id
                LEFT JOIN permission p ON rp.permission_id = p.id
                ORDER BY r.id
            """
            cursor.execute(query)
            rows = cursor.fetchall()

            roles = {}
            for row in rows:
                rid = row['role_id']
                if rid not in roles:
                    roles[rid] = {'id': rid, 'role': row['role_name'], 'permissions': []}
                if row['permission_id'] and row['permission_name']:
                    roles[rid]['permissions'].append({'id': row['permission_id'], 'permission': row['permission_name']})

            return jsonify({'roles': list(roles.values())}), 200

        # POST -> create role
        data = request.get_json() or {}
        admin_id = data.get('admin_id')
        # simple admin check
        if not admin_id:
            return jsonify({'error': 'admin_id required'}), 400

        # verify admin
        cursor.execute("SELECT r.role FROM users u JOIN role r ON u.role_id = r.id WHERE u.id = %s", (admin_id,))
        admin_role = cursor.fetchone()
        if not admin_role or admin_role.get('role') != 'admin':
            return jsonify({'error': 'Forbidden'}), 403

        role_name = data.get('role')
        permission_ids = data.get('permission_ids', [])
        if not role_name:
            return jsonify({'error': 'role name is required'}), 400

        cursor.execute("INSERT INTO role (role) VALUES (%s)", (role_name,))
        new_role_id = cursor.lastrowid
        if permission_ids:
            rp_query = "INSERT INTO role_permission (role_id, permission_id) VALUES (%s, %s)"
            rp_data = [(new_role_id, pid) for pid in permission_ids]
            cursor.executemany(rp_query, rp_data)

        connection.commit()
        return jsonify({'message': 'Role created', 'role_id': new_role_id}), 201

    except mysql.connector.Error as e:
        if connection:
            connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/admin/roles/<int:role_id>', methods=['PUT'])
def admin_update_role(role_id):
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        data = request.get_json() or {}
        admin_id = data.get('admin_id')
        if not admin_id:
            return jsonify({'error': 'admin_id required'}), 400

        cursor.execute("SELECT r.role FROM users u JOIN role r ON u.role_id = r.id WHERE u.id = %s", (admin_id,))
        admin_role = cursor.fetchone()
        if not admin_role or admin_role.get('role') != 'admin':
            return jsonify({'error': 'Forbidden'}), 403

        role_name = data.get('role')
        permission_ids = data.get('permission_ids')

        if role_name:
            cursor.execute("UPDATE role SET role = %s WHERE id = %s", (role_name, role_id))

        if permission_ids is not None:
            # replace mappings
            cursor.execute("DELETE FROM role_permission WHERE role_id = %s", (role_id,))
            if permission_ids:
                rp_query = "INSERT INTO role_permission (role_id, permission_id) VALUES (%s, %s)"
                rp_data = [(role_id, pid) for pid in permission_ids]
                cursor.executemany(rp_query, rp_data)

        connection.commit()
        return jsonify({'message': 'Role updated'}), 200

    except mysql.connector.Error as e:
        if connection:
            connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/admin/users/role/<int:user_id>', methods=['PUT'])
def admin_update_user_role(user_id):
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        data = request.get_json() or {}
        admin_id = data.get('admin_id')
        new_role_id = data.get('role_id')
        if not admin_id or new_role_id is None:
            return jsonify({'error': 'admin_id and role_id are required'}), 400

        cursor.execute("SELECT r.role FROM users u JOIN role r ON u.role_id = r.id WHERE u.id = %s", (admin_id,))
        admin_role = cursor.fetchone()
        if not admin_role or admin_role.get('role') != 'admin':
            return jsonify({'error': 'Forbidden'}), 403

        cursor.execute("UPDATE users SET role_id = %s WHERE id = %s", (new_role_id, user_id))
        connection.commit()
        return jsonify({'message': 'User role updated'}), 200

    except mysql.connector.Error as e:
        if connection:
            connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/admin/permissions', methods=['GET', 'POST'])
def admin_permissions():
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        if request.method == 'GET':
            cursor.execute("SELECT id, permission FROM permission")
            perms = cursor.fetchall()
            return jsonify({'permissions': perms}), 200

        data = request.get_json() or {}
        admin_id = data.get('admin_id')
        perm_name = data.get('permission')
        if not admin_id or not perm_name:
            return jsonify({'error': 'admin_id and permission are required'}), 400

        cursor.execute("SELECT r.role FROM users u JOIN role r ON u.role_id = r.id WHERE u.id = %s", (admin_id,))
        admin_role = cursor.fetchone()
        if not admin_role or admin_role.get('role') != 'admin':
            return jsonify({'error': 'Forbidden'}), 403

        cursor.execute("INSERT INTO permission (permission) VALUES (%s)", (perm_name,))
        new_id = cursor.lastrowid
        connection.commit()
        return jsonify({'message': 'Permission created', 'permission_id': new_id}), 201

    except mysql.connector.Error as e:
        if connection:
            connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


    
#Still testing the route it works now wih postman and imma test it with the frontend 
#It works 
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
        # We count total matching items and subtract what we've already seen after coming back here i ask my self did i built that i measn it look diff than the one in my mind 
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
        # I sould really get better at join commands
        query = """
            SELECT p.* FROM product p
            INNER JOIN product_category_rel rel ON p.id = rel.product_id
            WHERE rel.category_id = %s AND p.is_archived = 0
        """
        
        cursor.execute(query, (category_id,))
        products = cursor.fetchall()
        
        # Return the list of products and their count
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
        #😂😂
            
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

    
@api.route('/uploads', methods=['POST']) #with lots of help from the internet and the community
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

            status = "Pending"
            method = "Unknown"
            cursor.execute("""
                INSERT INTO order_payment_status (order_id, status, method) VALUES (%s, %s, %s)""", (order_id, status, method)) #GREAT

            # Deduct from inventory (IT WORKED RN) i have top edit the ui now so it updates the ui whenever i click the checkout button and removes one the quantity from the item in the ui
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

# @api.route('/orders/getorderpaymentstatus/<int:order_id>', methods=['GET'])
# def get_order

@api.route('/orders/<int:order_id>', methods=['GET']) # never used it yet idk why i thought i might need it but later i might implement orders search then this would be usefull somehow

def get_order(order_id):
    """Get order details with items"""
    user_id = request.args.get('user_id', type=int)
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        if user_id and not _user_has_page_permission(user_id, 'orders', cursor):
            return jsonify({'error': 'Forbidden'}), 403
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
    # Get pagination parameters from query string (/orders?limit=10&offset=0)
    limit = request.args.get('limit', default=10, type=int)
    offset = request.args.get('offset', default=0, type=int)

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    # Using buffered=True to handle unread results
    cursor = connection.cursor(dictionary=True, buffered=True)
    
    try:
        # Update query to use LIMIT and OFFSET
        query = "SELECT * FROM orders ORDER BY id DESC LIMIT %s OFFSET %s"
        cursor.execute(query, (limit, offset))
        orders = cursor.fetchall()

        # Attach items and status for each order
        for order in orders:
            cursor.execute(
                "SELECT oi.*, p.name as product_name FROM ordered_item oi "
                "JOIN product p ON oi.product_id = p.id WHERE oi.order_id = %s",
                (order['id'],)
            )
            order['items'] = cursor.fetchall()
            
            cursor.execute(
                "SELECT status, method FROM order_payment_status WHERE order_id = %s",
                (order['id'],)
            )
            status_method_data = cursor.fetchone()
            if status_method_data:
                order['order_status'] = status_method_data['status']
                order['payment_method'] = status_method_data['method']
            else:
                order['order_status'] = 'Unknown'
                order['payment_method'] = 'Unknown'

        # Optional: Get total count for frontend pagination UI
        cursor.execute("SELECT COUNT(*) as total FROM orders")
        total_count = cursor.fetchone()['total']

        return jsonify({
            'orders': orders,
            'limit': limit,
            'offset': offset,
            'count': len(orders),
            'total_count': total_count
        })
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)



@api.route('/orders/cashpayment/<int:order_id>/<int:paid_price>', methods=['PUT'])
def order_payment(order_id, paid_price):
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)
    try:
        # 1. Fetch order details
        cursor.execute("SELECT total_price FROM orders WHERE id = %s", (order_id,))
        order = cursor.fetchone()            
        if not order:
            return jsonify({'error': 'Order not found'}), 404
        
        # FIX: Convert all values to Decimal to avoid "unsupported operand" errors
        order_price = Decimal(str(order['total_price']))
        current_payment = Decimal(str(paid_price))

        # 2. Get the sum of all previous payments for this order
        cursor.execute("SELECT SUM(paid_price) as total_paid FROM payments WHERE order_id = %s", (order_id,))
        payment_history = cursor.fetchone()
        previous_paid = Decimal(str(payment_history['total_paid'] or 0))
        
        # 3. Calculate new totals
        total_paid_so_far = previous_paid + current_payment
        money_left = max(Decimal(0), order_price - total_paid_so_far)
        
        # 4. Determine status
        status = 'Paid' if total_paid_so_far >= order_price else 'Partially Paid'
        method = 'Cash'

        # 5. Update the main status table
        update_status_query = "UPDATE order_payment_status SET status = %s, method = %s WHERE order_id = %s"
        cursor.execute(update_status_query, (status, method, order_id))

        # 6. Log this specific payment into the history ledger
        # We store current payment details and the current balance left after this transaction
        insert_payment_query = """
            INSERT INTO payments (order_id, order_price, method, status, paid_price, money_left) 
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        insert_order_payments_query = """
            INSERT INTO order_payments (order_id, price) 
            VALUES (%s, %s)
        """
        cursor.execute(insert_payment_query, (
            order_id, 
            order_price, 
            method, 
            status, 
            current_payment, 
            money_left
        ))
        cursor.execute(insert_order_payments_query, (order_id, paid_price))
        
        connection.commit()
        
        return jsonify({
            'message': f'Payment successful. Order is now {status}.',
            'order_id': order_id,
            'total_price': float(order_price),
            'paid_in_this_txn': float(current_payment),
            'total_paid_to_date': float(total_paid_so_far),
            'remaining_balance': float(money_left),
            'status': status
        }), 200
        
    except mysql.connector.Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


@api.route('/orders/payments', methods=['GET'])
def get_all_payment_records():
    """Return all order payments records. requires ?user_id=nnn for permission check"""

    user_id = request.args.get('user_id', type=int)
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    cursor = connection.cursor(dictionary=True)
    try: 
        if user_id:
            # enforce page permission
            if not _user_has_page_permission(user_id, 'payments', cursor):
                return jsonify({'error': 'Forbidden'}), 403
        cursor.execute("SELECT * FROM payments ORDER BY id DESC")
        payment_records = cursor.fetchall()
        connection.commit()
        return jsonify({
            'Payment records': payment_records
        }), 200
        
    except mysql.connector.Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)
#home made
@api.route('/orders/orderpayments/<int:order_id>', methods=['GET'])
def get_all_order_payments(order_id):
    # Return all order payments records
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)
    try:
        query = "SELECT * FROM order_payments WHERE order_id = %s ORDER BY id DESC"
        cursor.execute(query, (order_id,))
        payment_records = cursor.fetchall()
        
        return jsonify({'payment_records': payment_records}), 200
        
    except mysql.connector.Error as e:
        return jsonify({'error': 'Database error occurred'}), 500
        
    finally:
        if 'cursor' in locals(): cursor.close()
        db.close_connection(connection)



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


@api.route('/users/signup', methods=['POST'])
def signup():
    data = request.get_json()

    # 1. Update validation for multiple numbers
    required_fields = ['email', 'password', 'name', 'phone_numbers']
    if not data or not all(field in data for field in required_fields):
        return jsonify({'error': 'All fields are required!'}), 400
    
    if not isinstance(data['phone_numbers'], list):
        return jsonify({'error': 'phone_numbers must be a list'}), 400

    # keep the existing email and password validation

    connection = db.get_connection()
    cursor = connection.cursor()

    try:
        # Insert User
        user_query = "INSERT INTO users (name, email, password) VALUES (%s, %s, %s)"
        user_values = (
            data['name'].strip(), 
            data['email'].strip().lower(), 
            bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        )
        cursor.execute(user_query, user_values)
        new_user_id = cursor.lastrowid 

        # Inserting Multiple Phone Numbers using executemany
        # imma create a list of tuples just like what i did with the orders and the categopries : [(user_id, phone1), (user_id, phone2), ...]

        """
        the input should be like this 
        {
    "message": "User signed up successfully",
    "user": {
        "email": "test@gmailtest.com",
        "id": 16,
        "name": "testnumbername",
        "phone_numbers": [
            "314234",
            "234534"
        ]
    }
}
        """

        phone_query = "INSERT INTO user_phone_numbers (user_id, phone_number) VALUES (%s, %s)"
        phone_data = [(new_user_id, phone.strip()) for phone in data['phone_numbers']]
        
        cursor.executemany(phone_query, phone_data)

        connection.commit()
        return jsonify({
            'message': 'User signed up successfully',
            'user': {
                'id': new_user_id,
                'name': data['name'],
                'email': data['email'],
                'phone_numbers': data['phone_numbers']
            }
        }), 201

    except Exception as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

@api.route('/users/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data or 'email' not in data or 'password' not in data:
        return jsonify({'error': 'Email and password are required'}), 400

    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)

    try:
        # JOIN with role table to get the role name
        login_query = """
            SELECT u.id, u.name, u.email, u.password, r.role 
            FROM users u
            LEFT JOIN role r ON u.role_id = r.id
            WHERE u.email = %s
        """
        cursor.execute(login_query, (data['email'].strip().lower(),))
        user = cursor.fetchone()

        if not user:
            return jsonify({'error': 'Invalid credentials'}), 401

        # Verify password
        stored_hash = user['password'].encode('utf-8') if isinstance(user['password'], str) else user['password']
        entered_password = data['password'].encode('utf-8')

        if bcrypt.checkpw(entered_password, stored_hash):
            # Fetch phone numbers
            phone_query = "SELECT phone_number FROM user_phone_numbers WHERE user_id = %s"
            cursor.execute(phone_query, (user['id'],))
            phone_records = cursor.fetchall()
            phone_numbers = [record['phone_number'] for record in phone_records]

            # Preparing response and keeping the separate 'role' field
            return jsonify({
                'message': 'Login successful',
                'user': {
                    'id': user['id'],
                    'name': user['name'],
                    'email': user['email'],
                    'phone_numbers': phone_numbers
                },
                'role': user['role']   # here we go
            }), 200
        else:
            return jsonify({'error': 'Invalid credentials'}), 401

    except mysql.connector.Error as e:
        return jsonify({'error': 'Login failed'}), 500
    except Exception as e:
        return jsonify({'error': f'An unexpected error occurred: {str(e)}'}), 500
    finally:
        db.close_connection(connection, cursor)

@api.route('/users/getuser/<int:user_id>', methods=['GET'])
def get_users(user_id):
    """Get user data, role, and phone numbers in two optimized queries."""
    connection = db.get_connection()
    if not connection:
        return jsonify({"error": "Database connection failed"}), 500
    
    cursor = connection.cursor(dictionary=True)
    try:
        # JOIN users and role tables:
        # imma select user details and the actual 'role' string from the role table
        user_query = """
            SELECT u.id, u.name, u.email, r.role 
            FROM users u
            LEFT JOIN role r ON u.role_id = r.id
            WHERE u.id = %s
        """
        cursor.execute(user_query, (user_id,))
        user_data = cursor.fetchone()

        if not user_data:
            return jsonify({"error": "User not found. Please sign up first."}), 404

        # Fetch phone numbers
        phone_query = "SELECT phone_number FROM user_phone_numbers WHERE user_id = %s"
        cursor.execute(phone_query, (user_id,))
        phone_records = cursor.fetchall()
        
        # Organize the final response
        # Extract the role name to keep the JSON clean insted of making 2 dicts like before
        role_name = user_data.pop('role') 
        user_data['phone_numbers'] = [row['phone_number'] for row in phone_records]

        return jsonify({
            'user': user_data, 
            'role': role_name
        })

    except mysql.connector.Error as e:
        return jsonify({"error": "Database error", "details": str(e)}), 500
    finally:
        cursor.close()
        db.close_connection(connection)

@api.route('/users/edituser/<int:user_id>', methods=['PUT'])
def edit_user_data(user_id):
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    # Get connection - added parentheses ()
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        connection.start_transaction()

        # Build query dynamically to only update provided fields
        query_parts = []
        values = []

        if 'name' in data:
            query_parts.append('name = %s')
            values.append(data['name'])
        
        if 'email' in data:
            query_parts.append('email = %s')
            values.append(data['email'])

        if 'phone_numbers' in data:
            # Delete existing phone numbers
            cursor.execute('DELETE FROM user_phone_numbers WHERE user_id = %s', (user_id,))
            
            # Insert new phone numbers if provided
            if data['phone_numbers'] and isinstance(data['phone_numbers'], list):
                phone_query = "INSERT INTO user_phone_numbers (user_id, phone_number) VALUES (%s, %s)"
                phone_data = [(user_id, phone.strip()) for phone in data['phone_numbers']]
                cursor.executemany(phone_query, phone_data)
        
        # Check if we have any updates to make
        has_updates = len(query_parts) > 0 or 'phone_numbers' in data
        
        if not has_updates:
            return jsonify({'message': 'No valid fields provided for update'}), 400

        # Only execute the users table update if there are fields to update
        if query_parts:
            # Construct the final query
            update_user_data_query = f"UPDATE users SET {', '.join(query_parts)} WHERE id = %s"
            values.append(user_id) # Add the user_id to the end of the values list

            cursor.execute(update_user_data_query, tuple(values))

        # Check if a user was actually updated
        if cursor.rowcount == 0:
            connection.rollback()
            return jsonify({'error': 'User not found or no new data provided'}), 404

        connection.commit()
        return jsonify({'message': 'User data updated successfully'}), 200

    except mysql.connector.Error as e:
        connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

@api.route('/users/changepassword/<int:user_id>', methods=['PUT'])
def change_password(user_id):
    connection = None
    cursor = None
    try:
        connection = db.get_connection()
        data = request.get_json()
        cursor = connection.cursor(dictionary=True)

        # fetch user data
        cursor.execute('SELECT password FROM users WHERE id = %s', (user_id,))
        user_record = cursor.fetchone()

        if not user_record:
            return {"error": "User not found"}, 404

        #Verify old password
        stored_hash = user_record['password'].encode('utf-8') 
        old_entered = data['old_password'].encode('utf-8')

        if bcrypt.checkpw(old_entered, stored_hash):
            #Hash NEW password
            new_password_raw = data['new_password'].encode('utf-8')
            new_hashed_password = bcrypt.hashpw(new_password_raw, bcrypt.gensalt())

            #now immaupdate DB
            update_query = 'UPDATE users SET password = %s WHERE id = %s'
            cursor.execute(update_query, (new_hashed_password, user_id))
            
            connection.commit() # Save changes
            return {"message": "Password updated successfully"}, 200
        else:
            return {"error": "Incorrect old password"}, 401

    except mysql.connector.Error as e:
        if connection:
            connection.rollback() # Undo changes on error
        return {"error": str(e)}, 500
    
    finally:
        if cursor:
            cursor.close()
        if connection:
            db.close_connection(connection)


@api.route('/users/permission/<int:user_id>', methods=['GET'])
def get_permission(user_id):
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500
    
    cursor = connection.cursor(dictionary=True)
    try: 
        # i should really improve my jointing skills
        query = """
            SELECT p.permission 
            FROM permission p
            JOIN role_permission rp ON p.id = rp.permission_id
            JOIN users u ON u.role_id = rp.role_id
            WHERE u.id = %s
        """
        cursor.execute(query, (user_id,))
        permissions = cursor.fetchall() 
        
        # permission_list = [p['permission'] for p in permissions]
        # just a minor extra layer of security
        #so my backend returns a empty list if the user has no premission
        permission_list = [p['permission'] for p in permissions] if permissions else []
        return jsonify({'permissions': permission_list}), 200

    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)


# -------------------------
# Page visibility management
# -------------------------
# i need to get better at join commands when i have some free time
def _ensure_page_permission_table(cursor):
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS page_permission (
            id INT AUTO_INCREMENT PRIMARY KEY,
            page_key VARCHAR(100) UNIQUE,
            permission_id INT,
            FOREIGN KEY (permission_id) REFERENCES permission(id) ON DELETE SET NULL
        ) ENGINE=InnoDB;
    """)


@api.route('/admin/page-permissions', methods=['GET', 'PUT'])
def admin_page_permissions():
    connection = db.get_connection()
    if not connection:
        return jsonify({'error': 'Database connection failed'}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        _ensure_page_permission_table(cursor)

        if request.method == 'GET':
            query = """
                SELECT pp.page_key, pp.permission_id, p.permission
                FROM page_permission pp
                LEFT JOIN permission p ON pp.permission_id = p.id
            """
            cursor.execute(query)
            rows = cursor.fetchall()
            return jsonify({'page_permissions': rows}), 200

        data = request.get_json() or {}
        admin_id = data.get('admin_id')
        page_key = data.get('page_key')
        perm_id = data.get('permission_id')

        if not admin_id or page_key is None:
            return jsonify({'error': 'admin_id and page_key required'}), 400

        cursor.execute("SELECT r.role FROM users u JOIN role r ON u.role_id = r.id WHERE u.id = %s", (admin_id,))
        admin_role = cursor.fetchone()
        if not admin_role or admin_role.get('role') != 'admin':
            return jsonify({'error': 'Forbidden'}), 403

        cursor.execute("SELECT id FROM page_permission WHERE page_key = %s", (page_key,))
        existing = cursor.fetchone()
        if existing:
            cursor.execute(
                "UPDATE page_permission SET permission_id = %s WHERE page_key = %s",
                (perm_id, page_key),
            )
        else:
            cursor.execute(
                "INSERT INTO page_permission (page_key, permission_id) VALUES (%s, %s)",
                (page_key, perm_id),
            )
        connection.commit()
        return jsonify({'message': 'Page permission updated'}), 200

    except mysql.connector.Error as e:
        if connection:
            connection.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)
        

@api.route('/users/delete/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    """Delete a user"""
    #only admins are allowed
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

        cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
        connection.commit()
       

        if cursor.rowcount == 0:
            return jsonify({'error': 'user not found'}), 404

        return jsonify({'message': 'user deleted successfully'}), 200
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)

@api.route('/roles/delete/<int:role_id>', methods=['DELETE'])
def delete_role(role_id):
    """Delete a usroleer"""
    #only admins are allowed
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

        cursor.execute("DELETE FROM role WHERE id = %s", (role_id,))
        connection.commit()
       

        if cursor.rowcount == 0:
            return jsonify({'error': 'role not found'}), 404

        return jsonify({'message': 'role deleted successfully'}), 200
    except mysql.connector.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db.close_connection(connection, cursor)
