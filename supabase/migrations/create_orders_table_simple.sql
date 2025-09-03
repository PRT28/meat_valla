-- Create orders table matching the current OrderModel structure
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userId UUID NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    total DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    deliveryFee DECIMAL(10, 2) NOT NULL DEFAULT 0,
    
    -- Payment fields
    paymentMethod TEXT NOT NULL DEFAULT 'cashOnDelivery',
    payment_status TEXT DEFAULT 'pending',
    payment_intent_id TEXT,
    payment_method_id TEXT,
    payment_details JSONB,
    
    -- Delivery address (JSON object)
    deliveryAddress JSONB NOT NULL,
    
    -- Order items (JSON array)
    items JSONB NOT NULL,
    
    -- Optional fields
    notes TEXT,
    estimatedDeliveryTime TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT orders_status_check CHECK (status IN ('pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled')),
    CONSTRAINT orders_payment_method_check CHECK (paymentMethod IN ('cashOnDelivery', 'card', 'upi', 'netBanking', 'wallet')),
    CONSTRAINT orders_payment_status_check CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled'))
);

-- Create payment_intents table for Stripe integration
CREATE TABLE IF NOT EXISTS payment_intents (
    id TEXT PRIMARY KEY, -- Stripe payment intent ID
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL, -- Amount in paise
    currency TEXT NOT NULL DEFAULT 'inr',
    status TEXT NOT NULL,
    client_secret TEXT,
    payment_method_type TEXT,
    payment_method_id TEXT,
    charges JSONB,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(userId);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_intent_id ON orders(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(createdAt);

CREATE INDEX IF NOT EXISTS idx_payment_intents_order_id ON payment_intents(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_status ON payment_intents(status);

-- Create function to update updatedAt timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updatedAt = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic timestamp updates
DROP TRIGGER IF EXISTS trigger_update_orders_updated_at ON orders;
CREATE TRIGGER trigger_update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to update payment intent timestamp
CREATE OR REPLACE FUNCTION update_payment_intent_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for payment intents
DROP TRIGGER IF EXISTS trigger_update_payment_intent_updated_at ON payment_intents;
CREATE TRIGGER trigger_update_payment_intent_updated_at
    BEFORE UPDATE ON payment_intents
    FOR EACH ROW
    EXECUTE FUNCTION update_payment_intent_updated_at();

-- Add comments
COMMENT ON TABLE orders IS 'Orders table storing all order information';
COMMENT ON COLUMN orders.paymentMethod IS 'Payment method: cashOnDelivery, card, upi, netBanking, wallet';
COMMENT ON COLUMN orders.payment_status IS 'Payment status: pending, paid, failed, refunded, cancelled';
COMMENT ON COLUMN orders.payment_intent_id IS 'Stripe payment intent ID for online payments';
COMMENT ON COLUMN orders.deliveryAddress IS 'JSON object with delivery address details';
COMMENT ON COLUMN orders.items IS 'JSON array with order items';

COMMENT ON TABLE payment_intents IS 'Stripe payment intents tracking';

-- Enable Row Level Security
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_intents ENABLE ROW LEVEL SECURITY;

-- Example RLS policies (uncomment and modify as needed)
/*
-- Users can only access their own orders
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (userId = auth.uid());

CREATE POLICY "Users can create own orders" ON orders
    FOR INSERT WITH CHECK (userId = auth.uid());

-- Service role can access all orders
CREATE POLICY "Service role full access" ON orders
    FOR ALL USING (auth.role() = 'service_role');

-- Payment intents policies
CREATE POLICY "Users can view payment intents for own orders" ON payment_intents
    FOR SELECT USING (
        order_id IN (SELECT id FROM orders WHERE userId = auth.uid())
    );

CREATE POLICY "Service role payment intents access" ON payment_intents
    FOR ALL USING (auth.role() = 'service_role');
*/

-- Sample data structure for reference
/*
Example order record:
{
  "id": "uuid",
  "userId": "uuid", 
  "status": "pending",
  "total": 599.00,
  "subtotal": 549.00,
  "deliveryFee": 50.00,
  "paymentMethod": "cashOnDelivery",
  "payment_status": "pending",
  "deliveryAddress": {
    "id": "uuid",
    "name": "John Doe",
    "phoneNumber": "+91 9876543210",
    "addressLine1": "123 Main Street",
    "addressLine2": "Near Park",
    "city": "Mumbai",
    "state": "Maharashtra", 
    "pincode": "400001",
    "landmark": "Opposite Mall",
    "type": "home"
  },
  "items": [
    {
      "id": "uuid",
      "productId": "uuid",
      "name": "Chicken Breast",
      "image": "url",
      "price": 549.00,
      "quantity": 1,
      "weight": 1.0,
      "unit": "kg"
    }
  ],
  "notes": "Please deliver fresh",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
*/
