-- Create orders table with payment support
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userId UUID NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    total DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    deliveryFee DECIMAL(10, 2) NOT NULL DEFAULT 0,
    tax DECIMAL(10, 2) DEFAULT 0,
    discount DECIMAL(10, 2) DEFAULT 0,
    
    -- Payment related fields
    paymentMethod TEXT NOT NULL DEFAULT 'cashOnDelivery',
    payment_status TEXT DEFAULT 'pending',
    payment_intent_id TEXT,
    payment_method_id TEXT,
    payment_details JSONB,
    
    -- Delivery address (embedded JSON)
    deliveryAddress JSONB NOT NULL,
    
    -- Order items (embedded JSON array)
    items JSONB NOT NULL,
    
    -- Additional fields
    notes TEXT,
    estimatedDeliveryTime TIMESTAMP WITH TIME ZONE,
    actualDeliveryTime TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT orders_status_check CHECK (status IN ('pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled')),
    CONSTRAINT orders_payment_method_check CHECK (paymentMethod IN ('cashOnDelivery', 'card', 'upi', 'netBanking', 'wallet')),
    CONSTRAINT orders_payment_status_check CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled'))
);

-- Create payment_intents table for tracking Stripe payment intents
CREATE TABLE IF NOT EXISTS payment_intents (
    id TEXT PRIMARY KEY, -- Stripe payment intent ID (pi_xxx)
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- Amount in smallest currency unit (paise for INR)
    currency TEXT NOT NULL DEFAULT 'inr',
    status TEXT NOT NULL,
    client_secret TEXT,
    payment_method_type TEXT,
    payment_method_id TEXT,
    charges JSONB,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT payment_intents_status_check CHECK (status IN ('requires_payment_method', 'requires_confirmation', 'requires_action', 'processing', 'requires_capture', 'canceled', 'succeeded'))
);

-- Create order_items table for normalized item storage (optional, for better querying)
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL,
    product_name TEXT NOT NULL,
    product_image TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    weight DECIMAL(8, 3), -- in kg
    unit TEXT DEFAULT 'kg',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT order_items_quantity_positive CHECK (quantity > 0),
    CONSTRAINT order_items_unit_price_positive CHECK (unit_price >= 0),
    CONSTRAINT order_items_total_price_positive CHECK (total_price >= 0)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(userId);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_intent_id ON orders(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(createdAt);
CREATE INDEX IF NOT EXISTS idx_orders_payment_method ON orders(paymentMethod);

CREATE INDEX IF NOT EXISTS idx_payment_intents_order_id ON payment_intents(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_status ON payment_intents(status);
CREATE INDEX IF NOT EXISTS idx_payment_intents_created_at ON payment_intents(created_at);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Create a function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updatedAt = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a function to update payment intent updated_at timestamp
CREATE OR REPLACE FUNCTION update_payment_intent_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
DROP TRIGGER IF EXISTS trigger_update_orders_updated_at ON orders;
CREATE TRIGGER trigger_update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_update_payment_intent_updated_at ON payment_intents;
CREATE TRIGGER trigger_update_payment_intent_updated_at
    BEFORE UPDATE ON payment_intents
    FOR EACH ROW
    EXECUTE FUNCTION update_payment_intent_updated_at();

-- Create a view for order summary with payment information
CREATE OR REPLACE VIEW order_summary AS
SELECT 
    o.id,
    o.userId,
    o.status,
    o.total,
    o.subtotal,
    o.deliveryFee,
    o.paymentMethod,
    o.payment_status,
    o.payment_intent_id,
    o.deliveryAddress,
    o.notes,
    o.createdAt,
    o.updatedAt,
    pi.status as stripe_status,
    pi.amount as stripe_amount,
    pi.currency,
    pi.payment_method_type,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN payment_intents pi ON o.payment_intent_id = pi.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, pi.id;

-- Create a view for order payment summary
CREATE OR REPLACE VIEW order_payment_summary AS
SELECT 
    o.id as order_id,
    o.total as order_total,
    o.payment_status,
    o.paymentMethod as payment_method,
    o.payment_intent_id,
    pi.status as stripe_status,
    pi.amount as stripe_amount,
    pi.currency,
    pi.payment_method_type,
    pi.created_at as payment_created_at,
    pi.updated_at as payment_updated_at
FROM orders o
LEFT JOIN payment_intents pi ON o.payment_intent_id = pi.id;

-- Add comments for documentation
COMMENT ON TABLE orders IS 'Main orders table storing all order information';
COMMENT ON COLUMN orders.id IS 'Unique order identifier';
COMMENT ON COLUMN orders.userId IS 'Reference to the user who placed the order';
COMMENT ON COLUMN orders.status IS 'Order status: pending, confirmed, preparing, out_for_delivery, delivered, cancelled';
COMMENT ON COLUMN orders.paymentMethod IS 'Payment method: cashOnDelivery, card, upi, netBanking, wallet';
COMMENT ON COLUMN orders.payment_status IS 'Payment status: pending, paid, failed, refunded, cancelled';
COMMENT ON COLUMN orders.payment_intent_id IS 'Stripe payment intent ID for online payments';
COMMENT ON COLUMN orders.payment_method_id IS 'Stripe payment method ID';
COMMENT ON COLUMN orders.payment_details IS 'Additional payment details and metadata';
COMMENT ON COLUMN orders.deliveryAddress IS 'JSON object containing delivery address details';
COMMENT ON COLUMN orders.items IS 'JSON array containing order items (for backward compatibility)';

COMMENT ON TABLE payment_intents IS 'Tracks Stripe payment intents for orders';
COMMENT ON COLUMN payment_intents.id IS 'Stripe payment intent ID (pi_xxx)';
COMMENT ON COLUMN payment_intents.amount IS 'Amount in smallest currency unit (paise for INR)';
COMMENT ON COLUMN payment_intents.status IS 'Stripe payment intent status';
COMMENT ON COLUMN payment_intents.client_secret IS 'Client secret for frontend payment confirmation';

COMMENT ON TABLE order_items IS 'Normalized order items for better querying and reporting';
COMMENT ON VIEW order_summary IS 'Complete order information with payment and item details';
COMMENT ON VIEW order_payment_summary IS 'Order and payment status summary';

-- Insert sample data for testing (optional)
-- Uncomment the following lines if you want sample data

/*
-- Sample order with cash on delivery
INSERT INTO orders (
    userId, 
    status, 
    total, 
    subtotal, 
    deliveryFee, 
    paymentMethod, 
    payment_status,
    deliveryAddress, 
    items,
    notes
) VALUES (
    gen_random_uuid(), -- Replace with actual user ID
    'pending',
    599.00,
    549.00,
    50.00,
    'cashOnDelivery',
    'pending',
    '{"name": "John Doe", "phone": "+91 9876543210", "addressLine1": "123 Main Street", "city": "Mumbai", "state": "Maharashtra", "pincode": "400001"}',
    '[{"id": "prod1", "name": "Chicken Breast", "quantity": 1, "price": 549.00, "weight": 1.0}]',
    'Please deliver fresh'
);

-- Sample order with online payment
INSERT INTO orders (
    userId, 
    status, 
    total, 
    subtotal, 
    deliveryFee, 
    paymentMethod, 
    payment_status,
    deliveryAddress, 
    items
) VALUES (
    gen_random_uuid(), -- Replace with actual user ID
    'confirmed',
    899.00,
    849.00,
    50.00,
    'upi',
    'paid',
    '{"name": "Jane Smith", "phone": "+91 9876543211", "addressLine1": "456 Park Avenue", "city": "Delhi", "state": "Delhi", "pincode": "110001"}',
    '[{"id": "prod2", "name": "Mutton Curry Cut", "quantity": 1, "price": 849.00, "weight": 1.0}]'
);
*/

-- Grant necessary permissions (adjust based on your RLS policies)
-- These are examples - adjust based on your security requirements

-- Enable RLS on tables
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_intents ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Example RLS policies (uncomment and modify as needed)
/*
-- Users can only see their own orders
CREATE POLICY "Users can view their own orders" ON orders
    FOR SELECT USING (userId = auth.uid());

-- Users can insert their own orders
CREATE POLICY "Users can create their own orders" ON orders
    FOR INSERT WITH CHECK (userId = auth.uid());

-- Users can update their own orders (limited fields)
CREATE POLICY "Users can update their own orders" ON orders
    FOR UPDATE USING (userId = auth.uid());

-- Service role can manage all orders (for admin functions)
CREATE POLICY "Service role can manage orders" ON orders
    FOR ALL USING (auth.role() = 'service_role');

-- Similar policies for payment_intents and order_items
CREATE POLICY "Users can view payment intents for their orders" ON payment_intents
    FOR SELECT USING (
        order_id IN (SELECT id FROM orders WHERE userId = auth.uid())
    );

CREATE POLICY "Service role can manage payment intents" ON payment_intents
    FOR ALL USING (auth.role() = 'service_role');
*/
