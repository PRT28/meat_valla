-- Safe migration to add missing columns without losing data
-- Run this if you have existing orders data you want to preserve

-- Add missing columns that OrderModel expects
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS deliveredAt TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS trackingId TEXT;

-- Ensure all expected columns exist with correct data types
-- Check and add any other missing columns

-- Add payment columns if they don't exist (from previous migrations)
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS payment_intent_id TEXT,
ADD COLUMN IF NOT EXISTS payment_method_id TEXT,
ADD COLUMN IF NOT EXISTS payment_details JSONB;

-- Add system timestamp columns if they don't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update existing records to have proper timestamps if they're null
UPDATE orders 
SET createdAt = orderDate 
WHERE createdAt IS NULL;

UPDATE orders 
SET updatedAt = orderDate 
WHERE updatedAt IS NULL;

-- Update constraints to match OrderModel enums
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN ('placed', 'confirmed', 'preparing', 'outForDelivery', 'delivered', 'cancelled'));

ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_payment_method_check;
ALTER TABLE orders ADD CONSTRAINT orders_payment_method_check 
CHECK (paymentMethod IN ('cashOnDelivery', 'card', 'upi', 'netBanking', 'wallet'));

ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_payment_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_payment_status_check 
CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded', 'cancelled'));

-- Add indexes for new columns
CREATE INDEX IF NOT EXISTS idx_orders_delivered_at ON orders(deliveredAt);
CREATE INDEX IF NOT EXISTS idx_orders_tracking_id ON orders(trackingId);

-- Create or update the timestamp update function
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

-- Add comments for new columns
COMMENT ON COLUMN orders.deliveredAt IS 'Timestamp when order was actually delivered';
COMMENT ON COLUMN orders.trackingId IS 'Order tracking identifier';

-- Verify all expected columns exist
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND column_name IN (
    'id', 'userId', 'items', 'deliveryAddress', 'subtotal', 'deliveryFee', 'total',
    'status', 'paymentMethod', 'orderDate', 'estimatedDelivery', 'deliveredAt',
    'notes', 'trackingId', 'payment_status', 'payment_intent_id', 'payment_method_id',
    'payment_details', 'createdAt', 'updatedAt'
)
ORDER BY 
    CASE column_name
        WHEN 'id' THEN 1
        WHEN 'userId' THEN 2
        WHEN 'items' THEN 3
        WHEN 'deliveryAddress' THEN 4
        WHEN 'subtotal' THEN 5
        WHEN 'deliveryFee' THEN 6
        WHEN 'total' THEN 7
        WHEN 'status' THEN 8
        WHEN 'paymentMethod' THEN 9
        WHEN 'orderDate' THEN 10
        WHEN 'estimatedDelivery' THEN 11
        WHEN 'deliveredAt' THEN 12
        WHEN 'notes' THEN 13
        WHEN 'trackingId' THEN 14
        WHEN 'payment_status' THEN 15
        WHEN 'payment_intent_id' THEN 16
        WHEN 'payment_method_id' THEN 17
        WHEN 'payment_details' THEN 18
        WHEN 'createdAt' THEN 19
        WHEN 'updatedAt' THEN 20
        ELSE 99
    END;
