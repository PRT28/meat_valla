-- Add payment support to orders table
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS payment_intent_id TEXT,
ADD COLUMN IF NOT EXISTS payment_method_id TEXT,
ADD COLUMN IF NOT EXISTS payment_details JSONB;

-- Create payment_intents table for tracking Stripe payment intents
CREATE TABLE IF NOT EXISTS payment_intents (
    id TEXT PRIMARY KEY, -- Stripe payment intent ID
    order_id UUID REFERENCES orders(id),
    amount INTEGER NOT NULL, -- Amount in smallest currency unit (paise)
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_payment_intents_order_id ON payment_intents(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_intents_status ON payment_intents(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_intent_id ON orders(payment_intent_id);

-- Add comments for documentation
COMMENT ON COLUMN orders.payment_status IS 'Payment status: pending, paid, failed, refunded';
COMMENT ON COLUMN orders.payment_intent_id IS 'Stripe payment intent ID';
COMMENT ON COLUMN orders.payment_method_id IS 'Stripe payment method ID';
COMMENT ON COLUMN orders.payment_details IS 'Additional payment details and metadata';

COMMENT ON TABLE payment_intents IS 'Tracks Stripe payment intents for orders';
COMMENT ON COLUMN payment_intents.id IS 'Stripe payment intent ID (pi_xxx)';
COMMENT ON COLUMN payment_intents.amount IS 'Amount in smallest currency unit (paise for INR)';
COMMENT ON COLUMN payment_intents.status IS 'Stripe payment intent status';
COMMENT ON COLUMN payment_intents.client_secret IS 'Client secret for frontend payment confirmation';
COMMENT ON COLUMN payment_intents.payment_method_type IS 'Type of payment method (card, upi, etc.)';
COMMENT ON COLUMN payment_intents.charges IS 'Stripe charges data';
COMMENT ON COLUMN payment_intents.metadata IS 'Additional metadata from Stripe';

-- Update existing orders to have default payment status
UPDATE orders 
SET payment_status = 'paid' 
WHERE payment_status IS NULL AND paymentMethod = 'cashOnDelivery';

UPDATE orders 
SET payment_status = 'pending' 
WHERE payment_status IS NULL AND paymentMethod != 'cashOnDelivery';

-- Create a function to update payment intent timestamps
CREATE OR REPLACE FUNCTION update_payment_intent_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic timestamp updates
DROP TRIGGER IF EXISTS trigger_update_payment_intent_updated_at ON payment_intents;
CREATE TRIGGER trigger_update_payment_intent_updated_at
    BEFORE UPDATE ON payment_intents
    FOR EACH ROW
    EXECUTE FUNCTION update_payment_intent_updated_at();

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

COMMENT ON VIEW order_payment_summary IS 'Combined view of order and payment information';

-- Grant necessary permissions (adjust based on your RLS policies)
-- These are examples - adjust based on your security requirements

-- Allow authenticated users to read their own payment data
-- CREATE POLICY "Users can view their own payment intents" ON payment_intents
--     FOR SELECT USING (
--         order_id IN (
--             SELECT id FROM orders WHERE userId = auth.uid()
--         )
--     );

-- Allow service role to manage payment intents (for Edge Functions)
-- GRANT ALL ON payment_intents TO service_role;
-- GRANT ALL ON order_payment_summary TO service_role;
