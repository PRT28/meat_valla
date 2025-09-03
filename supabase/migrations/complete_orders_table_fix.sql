-- Complete fix for orders table to match OrderModel exactly
-- This ensures all columns expected by the Dart model exist

-- Drop the table if it exists and recreate with correct structure
-- (Use this approach if you don't have important data)
DROP TABLE IF EXISTS payment_intents CASCADE;
DROP TABLE IF EXISTS orders CASCADE;

-- Create orders table with exact structure expected by OrderModel
CREATE TABLE orders (
    -- Primary fields
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userId UUID NOT NULL,
    
    -- Order content (JSON fields)
    items JSONB NOT NULL,
    deliveryAddress JSONB NOT NULL,
    
    -- Pricing fields
    subtotal DECIMAL(10, 2) NOT NULL,
    deliveryFee DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    
    -- Status and payment
    status TEXT NOT NULL DEFAULT 'placed',
    paymentMethod TEXT NOT NULL DEFAULT 'cashOnDelivery',
    
    -- Date fields (exact names from OrderModel)
    orderDate TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    estimatedDelivery TIMESTAMP WITH TIME ZONE,
    deliveredAt TIMESTAMP WITH TIME ZONE,
    
    -- Optional fields
    notes TEXT,
    trackingId TEXT,
    
    -- Payment integration fields
    payment_status TEXT DEFAULT 'pending',
    payment_intent_id TEXT,
    payment_method_id TEXT,
    payment_details JSONB,
    
    -- System timestamps
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT orders_status_check CHECK (status IN ('placed', 'confirmed', 'preparing', 'outForDelivery', 'delivered', 'cancelled')),
    CONSTRAINT orders_payment_method_check CHECK (paymentMethod IN ('cashOnDelivery', 'card', 'upi', 'netBanking', 'wallet')),
    CONSTRAINT orders_payment_status_check CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled'))
);

-- Create payment_intents table for Stripe integration
CREATE TABLE payment_intents (
    id TEXT PRIMARY KEY, -- Stripe payment intent ID
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- Amount in smallest currency unit (paise)
    currency TEXT NOT NULL DEFAULT 'inr',
    status TEXT NOT NULL,
    client_secret TEXT,
    payment_method_type TEXT,
    payment_method_id TEXT,
    charges JSONB,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Stripe status constraints
    CONSTRAINT payment_intents_status_check CHECK (status IN (
        'requires_payment_method', 'requires_confirmation', 'requires_action', 
        'processing', 'requires_capture', 'canceled', 'succeeded'
    ))
);

-- Create indexes for performance
CREATE INDEX idx_orders_user_id ON orders(userId);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_method ON orders(paymentMethod);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_payment_intent_id ON orders(payment_intent_id);
CREATE INDEX idx_orders_order_date ON orders(orderDate);
CREATE INDEX idx_orders_estimated_delivery ON orders(estimatedDelivery);
CREATE INDEX idx_orders_delivered_at ON orders(deliveredAt);
CREATE INDEX idx_orders_tracking_id ON orders(trackingId);
CREATE INDEX idx_orders_created_at ON orders(createdAt);

CREATE INDEX idx_payment_intents_order_id ON payment_intents(order_id);
CREATE INDEX idx_payment_intents_status ON payment_intents(status);
CREATE INDEX idx_payment_intents_created_at ON payment_intents(created_at);

-- Create function to update updatedAt timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updatedAt = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create function to update payment intent timestamp
CREATE OR REPLACE FUNCTION update_payment_intent_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER trigger_update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_payment_intent_updated_at
    BEFORE UPDATE ON payment_intents
    FOR EACH ROW
    EXECUTE FUNCTION update_payment_intent_updated_at();

-- Create view for order summary with payment information
CREATE OR REPLACE VIEW order_payment_summary AS
SELECT 
    o.id as order_id,
    o.userId,
    o.total as order_total,
    o.status as order_status,
    o.paymentMethod as payment_method,
    o.payment_status,
    o.payment_intent_id,
    o.orderDate,
    o.estimatedDelivery,
    o.deliveredAt,
    o.trackingId,
    pi.status as stripe_status,
    pi.amount as stripe_amount,
    pi.currency,
    pi.payment_method_type,
    pi.created_at as payment_created_at,
    pi.updated_at as payment_updated_at
FROM orders o
LEFT JOIN payment_intents pi ON o.payment_intent_id = pi.id;

-- Add helpful comments
COMMENT ON TABLE orders IS 'Orders table with exact structure matching OrderModel';
COMMENT ON COLUMN orders.id IS 'Unique order identifier (UUID)';
COMMENT ON COLUMN orders.userId IS 'Reference to user who placed the order';
COMMENT ON COLUMN orders.items IS 'JSON array of CartItem objects';
COMMENT ON COLUMN orders.deliveryAddress IS 'JSON object of AddressModel';
COMMENT ON COLUMN orders.status IS 'Order status: placed, confirmed, preparing, outForDelivery, delivered, cancelled';
COMMENT ON COLUMN orders.paymentMethod IS 'Payment method: cashOnDelivery, card, upi, netBanking, wallet';
COMMENT ON COLUMN orders.orderDate IS 'When the order was placed (maps to OrderModel.orderDate)';
COMMENT ON COLUMN orders.estimatedDelivery IS 'Estimated delivery time';
COMMENT ON COLUMN orders.deliveredAt IS 'Actual delivery timestamp';
COMMENT ON COLUMN orders.trackingId IS 'Order tracking identifier';
COMMENT ON COLUMN orders.payment_status IS 'Payment processing status for online payments';
COMMENT ON COLUMN orders.payment_intent_id IS 'Stripe payment intent ID for tracking';

COMMENT ON TABLE payment_intents IS 'Stripe payment intents for order payment tracking';
COMMENT ON VIEW order_payment_summary IS 'Combined order and payment status information';

-- Enable Row Level Security
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_intents ENABLE ROW LEVEL SECURITY;

-- Example RLS policies (uncomment and customize as needed)
/*
-- Users can only see their own orders
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (userId = auth.uid());

-- Users can create orders for themselves
CREATE POLICY "Users can create own orders" ON orders
    FOR INSERT WITH CHECK (userId = auth.uid());

-- Users can update their own orders (limited scenarios)
CREATE POLICY "Users can update own orders" ON orders
    FOR UPDATE USING (userId = auth.uid());

-- Service role has full access (for backend operations)
CREATE POLICY "Service role full access orders" ON orders
    FOR ALL USING (auth.role() = 'service_role');

-- Payment intents access
CREATE POLICY "Users can view payment intents for own orders" ON payment_intents
    FOR SELECT USING (
        order_id IN (SELECT id FROM orders WHERE userId = auth.uid())
    );

CREATE POLICY "Service role payment intents access" ON payment_intents
    FOR ALL USING (auth.role() = 'service_role');
*/

-- Insert a test order to verify structure
INSERT INTO orders (
    userId,
    items,
    deliveryAddress,
    subtotal,
    deliveryFee,
    total,
    status,
    paymentMethod,
    orderDate,
    estimatedDelivery,
    notes,
    trackingId,
    payment_status
) VALUES (
    gen_random_uuid(),
    '[{"id": "test1", "productId": "prod1", "name": "Test Product", "price": 100, "quantity": 1, "weight": 1.0, "unit": "kg"}]',
    '{"id": "addr1", "name": "Test User", "phoneNumber": "+91 9876543210", "addressLine1": "Test Address", "city": "Mumbai", "state": "Maharashtra", "pincode": "400001", "type": "home"}',
    100.00,
    50.00,
    150.00,
    'placed',
    'cashOnDelivery',
    NOW(),
    NOW() + INTERVAL '2 hours',
    'Test order for verification',
    'TRK' || EXTRACT(EPOCH FROM NOW())::TEXT,
    'pending'
);

-- Verify the insert worked
SELECT 
    id, 
    userId, 
    total, 
    status, 
    paymentMethod, 
    orderDate, 
    estimatedDelivery, 
    deliveredAt, 
    trackingId,
    payment_status
FROM orders 
WHERE notes = 'Test order for verification';

-- Show table structure for verification
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
ORDER BY ordinal_position;
