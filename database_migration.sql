-- Migration script to add latitude and longitude columns to addresses table
-- Run this in your Supabase SQL Editor

-- Add latitude and longitude columns to addresses table
ALTER TABLE addresses 
ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8);

-- Add index for location-based queries (optional but recommended for performance)
CREATE INDEX IF NOT EXISTS idx_addresses_location ON addresses (latitude, longitude);

-- Add a comment to document the columns
COMMENT ON COLUMN addresses.latitude IS 'Latitude coordinate of the address location';
COMMENT ON COLUMN addresses.longitude IS 'Longitude coordinate of the address location';
