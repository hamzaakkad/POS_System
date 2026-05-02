# POS System

A comprehensive Point of Sale (POS) system designed for retail businesses, featuring inventory management, order processing, payment handling, and user role-based access control. This full-stack application provides a seamless experience for managing products, categories, orders, and payments through a modern Flutter frontend and a robust Python Flask backend with a MySQL database.

## Features

### Core Functionality
- **Product Management**: Add, edit, archive, and categorize products with pricing, inventory tracking, and image support
- **Order Processing**: Create and manage customer orders with real-time cart functionality
- **Payment Handling**: Support for multiple payment methods with status tracking and change calculation
- **Category Organization**: Hierarchical product categorization for easy navigation
- **User Authentication**: Secure login system with role-based permissions
- **Dashboard Analytics**: Real-time insights into sales, inventory, and order status

### Advanced Features
- **Role-Based Access Control**: Granular permissions for different user roles (admin, cashier, manager)
- **Inventory Tracking**: Real-time stock monitoring with low-stock alerts
- **Order History**: Complete audit trail of all transactions
- **Search & Filtering**: Advanced product search with category and price filters
- **Responsive Design**: Cross-platform compatibility (iOS, Android, Web, Desktop)
- **API-Driven Architecture**: RESTful API for easy integration and scalability

## Tech Stack

### Backend
- **Framework**: Python Flask with application factory pattern
- **Database**: MySQL with connection pooling and error handling
- **Authentication**: JWT-based authentication with bcrypt password hashing
- **CORS Support**: Configured for cross-origin requests from Flutter frontend
- **File Uploads**: Secure image upload handling for product photos
- **Environment Configuration**: dotenv for secure credential management

### Database
- **Schema**: Normalized relational database with foreign key constraints
- **Tables**: Products, Orders, Ordered Items, Payments, Categories, Users, Roles, Permissions
- **Indexing**: Optimized queries with proper indexing for performance
- **Relationships**: Many-to-many product-category relationships, order-item associations

### Frontend
- **Framework**: Flutter with Material Design
- **State Management**: Provider pattern for reactive UI updates
- **Architecture**: MVVM with separate service, provider, and UI layers
- **Networking**: HTTP client for API communication with error handling
- **UI Components**: Custom reusable widgets for consistent design
- **Theming**: Dynamic light/dark theme support
- **Navigation**: Intuitive routing with permission-based page access

## Backend Architecture

The backend is built with Flask and follows RESTful API principles:

- **Routes**: Modular blueprint structure with endpoints for products, orders, payments, users, and admin functions
- **Models**: Python classes for data serialization and validation
- **Database Layer**: Connection management with automatic cleanup and error handling
- **Security**: CORS configuration, input validation, and secure file uploads
- **Health Checks**: API status monitoring and database connectivity verification

## Database Design

The MySQL database features a well-normalized schema:

- **Products**: Core inventory with pricing, stock levels, and archival status
- **Orders & Order Items**: Transaction records with line-item details
- **Payments**: Payment processing with method tracking and status updates
- **Categories**: Product organization with many-to-many relationships
- **Users & Roles**: Authentication system with granular permissions
- **Audit Trail**: Complete transaction history for compliance

## Frontend Architecture

The Flutter app provides a native mobile and web experience:

- **Pages**: Dedicated screens for dashboard, products, orders, payments, and admin functions
- **Providers**: State management for cart, products, orders, and user sessions
- **Services**: API communication layer with error handling and retry logic
- **Widgets**: Reusable components for dialogs, filters, and UI elements
- **Responsive Layout**: Adaptive design for different screen sizes and orientations

## Installation & Setup

### Prerequisites
- Python 3.8+
- MySQL 8.0+
- Flutter 3.0+
- Dart SDK

### Backend Setup
```bash
cd backend
pip install -r requirements.txt
# Configure environment variables in .env
# Set up MySQL database using pos_system.sql
python app.py
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

### Database Setup
```sql
-- Import the provided SQL schema
mysql -u username -p pos_system < pos_system.sql
```

## Usage

1. **Authentication**: Login with appropriate user credentials (the current admin account: hamzakkad@pos.com // pass: hamzakkad)
2. **Dashboard**: View real-time sales and inventory data
3. **Products**: Manage inventory through add/edit/archive functions
4. **POS Operations**: Add items to cart, process payments, print receipts
5. **Orders**: Track order status and payment history
6. **Admin Panel**: User management and system configuration

## API Endpoints

- `GET /api/products` - Retrieve product catalog
- `POST /api/orders` - Create new orders
- `GET /api/orders/{id}` - Get order details
- `POST /api/payments` - Process payments
- `GET /api/categories` - List product categories
- `GET /api/admin/users` - User management (admin only)
-  For more explore the routes.py file in the backend folder

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on GitHub or contact the developer,
or email me at hamza.akkad.2007@gmail.com .
