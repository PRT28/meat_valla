-- Create orders table matching the exact OrderModel structure
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userId UUID NOT NULL,
    
    -- Order items and delivery (stored as JSON to match model)
    items JSONB NOT NULL,
    deliveryAddress JSONB NOT NULL,
    
    -- Pricing
    subtotal DECIMAL(10, 2) NOT NULL,
    deliveryFee DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    
    -- Status and payment
    status TEXT NOT NULL DEFAULT 'placed',
    paymentMethod TEXT NOT NULL DEFAULT 'cashOnDelivery',
    
    -- Dates
    orderDate TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    estimatedDelivery TIMESTAMP WITH TIME ZONE,
    deliveredAt TIMESTAMP WITH TIME ZONE,
    
    -- Additional fields
    notes TEXT,
    trackingId TEXT,
    
    -- Payment integration fields (new)
    payment_status TEXT DEFAULT 'pending',
    payment_intent_id TEXT,
    payment_method_id TEXT,
    payment_details JSONB,
    
    -- Timestamps for system use
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints to match enum values
    CONSTRAINT orders_status_check CHECK (status IN ('placed', 'confirmed', 'preparing', 'outForDelivery', 'delivered', 'cancelled')),
    CONSTRAINT orders_payment_method_check CHECK (paymentMethod IN ('cashOnDelivery', 'card', 'upi', 'netBanking', 'wallet')),
    CONSTRAINT orders_payment_status_check CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled'))
);

-- Create payment_intents table for Stripe integration
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
    
    -- Stripe status constraints
    CONSTRAINT payment_intents_status_check CHECK (status IN (
        'requires_payment_method', 'requires_confirmation', 'requires_action', 
        'processing', 'requires_capture', 'canceled', 'succeeded'
    ))
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(userId);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_method ON orders(paymentMethod);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_intent_id ON orders(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(orderDate);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(createdAt);

CREATE INDEX IF NOT EXISTS idx_payment_intents_order_id ON payment_intents(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_status ON payment_intents(status);
CREATE INDEX IF NOT EXISTS idx_payment_intents_created_at ON payment_intents(created_at);

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
    pi.status as stripe_status,
    pi.amount as stripe_amount,
    pi.currency,
    pi.payment_method_type,
    pi.created_at as payment_created_at,
    pi.updated_at as payment_updated_at
FROM orders o
LEFT JOIN payment_intents pi ON o.payment_intent_id = pi.id;

-- Add helpful comments
COMMENT ON TABLE orders IS 'Orders table matching OrderModel structure exactly';
COMMENT ON COLUMN orders.id IS 'Unique order identifier (UUID)';
COMMENT ON COLUMN orders.userId IS 'Reference to user who placed the order';
COMMENT ON COLUMN orders.items IS 'JSON array of CartItem objects';
COMMENT ON COLUMN orders.deliveryAddress IS 'JSON object of AddressModel';
COMMENT ON COLUMN orders.status IS 'Order status: placed, confirmed, preparing, outForDelivery, delivered, cancelled';
COMMENT ON COLUMN orders.paymentMethod IS 'Payment method: cashOnDelivery, card, upi, netBanking, wallet';
COMMENT ON COLUMN orders.orderDate IS 'When the order was placed (maps to OrderModel.orderDate)';
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

-- Sample data structure for reference
/*
Example order JSON structure:

{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "userId": "123e4567-e89b-12d3-a456-426614174001", 
  "items": [
    {
      "id": "item1",
      "productId": "prod1",
      "name": "Chicken Breast",
      "image": "https://example.com/image.jpg",
      "price": 549.00,
      "quantity": 1,
      "weight": 1.0,
      "unit": "kg"
    }
  ],
  "deliveryAddress": {
    "id": "addr1",
    "name": "John Doe",
    "phoneNumber": "+91 9876543210",
    "addressLine1": "123 Main Street",
    "addressLine2": "Near Park",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001",
    "landmark": "Opposite Mall",
    "type": "home",
    "isDefault": true
  },
  "subtotal": 549.00,
  "deliveryFee": 50.00,
  "total": 599.00,
  "status": "placed",
  "paymentMethod": "cashOnDelivery",
  "orderDate": "2024-01-01T10:00:00Z",
  "estimatedDelivery": "2024-01-01T14:00:00Z",
  "notes": "Please deliver fresh",
  "payment_status": "pending"
}
*/

-- Grant permissions for authenticated users and service role
-- GRANT SELECT, INSERT ON orders TO authenticated;
-- GRANT ALL ON orders TO service_role;
-- GRANT ALL ON payment_intents TO service_role;
