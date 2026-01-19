class Product:
    """Represents a product in the inventory"""

    def __init__(self, id=None, name=None, price=0.0, storage_quantity=0, created_at=None, image_url=None):
        self.id = id
        self.name = name
        self.price = price
        self.storage_quantity = storage_quantity
        self.created_at = created_at
        self.image_url = image_url

    @classmethod
    def from_dict(cls, data):
        """Create Product object from dictionary"""
        return cls(
            id=data.get('id'),
            name=data.get('name'),
            price=data.get('price', 0.0),
            storage_quantity=data.get('storage_quantity', 0),
            created_at=data.get('created_at'),
            image_url=data.get('image_url')
        )

    def to_dict(self):
        """Convert Product object to dictionary (for JSON)"""
        return {
            'id': self.id,
            'name': self.name,
            'price': float(self.price) if self.price else 0.0,
            'storage_quantity': self.storage_quantity,
            'created_at': str(self.created_at) if self.created_at else None,
            'image_url': self.image_url
        }


class Order:
    """Represents a customer order"""

    def __init__(self, id=None, total_price=0.0, status='pending', created_at=None):
        self.id = id
        self.total_price = total_price
        self.status = status
        self.created_at = created_at
        self.items = []  # List of OrderedItem objects

    def to_dict(self):
        """Convert Order object to dictionary"""
        return {
            'id': self.id,
            'total_price': float(self.total_price) if self.total_price else 0.0,
            'status': self.status,
            'created_at': str(self.created_at) if self.created_at else None,
            'items': [item.to_dict() for item in self.items]
        }


class OrderedItem:
    """Represents an item within an order"""

    def __init__(self, id=None, product_id=None, order_id=None,
                 ordered_quantity=0, unit_price=0.0):
        self.id = id
        self.product_id = product_id
        self.order_id = order_id
        self.ordered_quantity = ordered_quantity
        self.unit_price = unit_price

    def to_dict(self):
        """Convert OrderedItem object to dictionary"""
        return {
            'id': self.id,
            'product_id': self.product_id,
            'order_id': self.order_id,
            'ordered_quantity': self.ordered_quantity,
            'unit_price': float(self.unit_price) if self.unit_price else 0.0
        }