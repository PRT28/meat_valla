-- Fix orders table to match OrderModel exactly
-- Add missing columns that the OrderModel expects

-- First, let's see what columns exist (for reference)
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'orders';

-- Add missing columns if they don't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS deliveredAt TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS trackingId TEXT;

-- Ensure all expected columns exist with correct names and types
-- The OrderModel expects these exact column names:

-- Core order fields (should already exist)
-- id, userId, items, deliveryAddress, subtotal, deliveryFee, total, status, paymentMethod

-- Date fields
-- orderDate (should already exist)
-- estimatedDelivery (should already exist) 
-- deliveredAt (adding above)

-- Optional fields
-- notes (should already exist)
-- trackingId (adding above)

-- Payment fields (should already exist from previous migration)
-- payment_status, payment_intent_id, payment_method_id, payment_details

-- System fields (should already exist)
-- createdAt, updatedAt

-- Update constraints to include new status if needed
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN ('placed', 'confirmed', 'preparing', 'outForDelivery', 'delivered', 'cancelled'));

-- Add index for deliveredAt for performance
CREATE INDEX IF NOT EXISTS idx_orders_delivered_at ON orders(deliveredAt);
CREATE INDEX IF NOT EXISTS idx_orders_tracking_id ON orders(trackingId);

-- Add comments for new columns
COMMENT ON COLUMN orders.deliveredAt IS 'Timestamp when order was actually delivered';
COMMENT ON COLUMN orders.trackingId IS 'Tracking ID for order delivery';

-- Verify the table structure matches OrderModel expectations
-- You can run this query to check:
/*
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
ORDER BY ordinal_position;
*/

-- Expected columns for OrderModel:
/*
1. id - UUID PRIMARY KEY
2. userId - UUID NOT NULL  
3. items - JSONB NOT NULL
4. deliveryAddress - JSONB NOT NULL
5. subtotal - DECIMAL(10,2) NOT NULL
6. deliveryFee - DECIMAL(10,2) NOT NULL DEFAULT 0
7. total - DECIMAL(10,2) NOT NULL
8. status - TEXT NOT NULL DEFAULT 'placed'
9. paymentMethod - TEXT NOT NULL DEFAULT 'cashOnDelivery'
10. orderDate - TIMESTAMP WITH TIME ZONE DEFAULT NOW()
11. estimatedDelivery - TIMESTAMP WITH TIME ZONE
12. deliveredAt - TIMESTAMP WITH TIME ZONE (ADDED)
13. notes - TEXT
14. trackingId - TEXT (ADDED)
15. payment_status - TEXT DEFAULT 'pending'
16. payment_intent_id - TEXT
17. payment_method_id - TEXT  
18. payment_details - JSONB
19. createdAt - TIMESTAMP WITH TIME ZONE DEFAULT NOW()
20. updatedAt - TIMESTAMP WITH TIME ZONE DEFAULT NOW()
*/

-- Sample insert to test the structure
/*
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
    deliveredAt,
    notes,
    trackingId,
    payment_status
) VALUES (
    gen_random_uuid(),
    '[{"id": "test", "name": "Test Product", "price": 100, "quantity": 1}]',
    '{"name": "Test User", "city": "Mumbai", "addressLine1": "Test Address"}',
    100.00,
    50.00,
    150.00,
    'placed',
    'cashOnDelivery',
    NOW(),
    NOW() + INTERVAL '2 hours',
    NULL,
    'Test order',
    'TRK123456',
    'pending'
);
*/
