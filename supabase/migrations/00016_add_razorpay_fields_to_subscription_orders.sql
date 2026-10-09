-- Add Razorpay-specific columns to subscription_orders (Stripe columns kept for backward compat)
ALTER TABLE subscription_orders
  ADD COLUMN IF NOT EXISTS razorpay_order_id   text,
  ADD COLUMN IF NOT EXISTS razorpay_payment_id  text,
  ADD COLUMN IF NOT EXISTS razorpay_signature   text;

CREATE INDEX IF NOT EXISTS idx_subscription_orders_razorpay_order_id
  ON subscription_orders(razorpay_order_id)
  WHERE razorpay_order_id IS NOT NULL;