# Stripe Payment Integration Setup Guide

This guide will help you set up Stripe payments with UPI and card support for your Meat Valla app.

## 🚀 Quick Setup Overview

1. **Create Stripe Account** → Get API keys
2. **Configure Supabase** → Deploy Edge Functions & Run Migrations  
3. **Update App Configuration** → Add Stripe keys
4. **Test Payments** → Verify integration

---

## 📋 Prerequisites

- Stripe account (create at [stripe.com](https://stripe.com))
- Supabase project with CLI access
- Flutter development environment

---

## 🔧 Step 1: Stripe Account Setup

### 1.1 Create Stripe Account
1. Go to [stripe.com](https://stripe.com) and create an account
2. Complete business verification for India
3. Enable UPI and card payments in your dashboard

### 1.2 Get API Keys
1. Go to **Developers → API Keys** in Stripe Dashboard
2. Copy your **Publishable Key** (starts with `pk_test_` or `pk_live_`)
3. Copy your **Secret Key** (starts with `sk_test_` or `sk_live_`)

### 1.3 Configure Payment Methods for India
1. Go to **Settings → Payment Methods**
2. Enable:
   - ✅ **Cards** (Visa, Mastercard, RuPay)
   - ✅ **UPI** (Google Pay, PhonePe, Paytm, etc.)
   - ✅ **Net Banking** (All major Indian banks)
   - ✅ **Wallets** (Paytm, PhonePe, etc.)

---

## 🗄️ Step 2: Database Setup

### 2.1 Run Database Migration
Execute the SQL migration in your Supabase SQL Editor:

```sql
-- Run the contents of supabase/migrations/add_payment_support.sql
-- This adds payment tracking tables and columns
```

### 2.2 Verify Tables Created
Check that these tables exist:
- ✅ `payment_intents` - Tracks Stripe payment intents
- ✅ `orders` table updated with payment columns

---

## ☁️ Step 3: Supabase Edge Functions Setup

### 3.1 Install Supabase CLI
```bash
npm install -g supabase
```

### 3.2 Login and Link Project
```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

### 3.3 Set Environment Variables
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
```

### 3.4 Deploy Edge Functions
```bash
# Deploy payment intent creation function
supabase functions deploy create-payment-intent

# Deploy payment verification function  
supabase functions deploy verify-payment
```

### 3.5 Verify Functions Deployed
Check in Supabase Dashboard → Edge Functions:
- ✅ `create-payment-intent`
- ✅ `verify-payment`

---

## 📱 Step 4: App Configuration

### 4.1 Update Stripe Publishable Key
Edit `lib/services/payment_service.dart`:

```dart
static const String _stripePublishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY_HERE';
```

### 4.2 Test Configuration
The app should now support:
- ✅ Cash on Delivery (existing)
- ✅ Credit/Debit Cards
- ✅ UPI Payments
- ✅ Net Banking
- ✅ Wallet Payments

---

## 🧪 Step 5: Testing

### 5.1 Test Card Numbers (Stripe Test Mode)
```
Successful Payment: 4242 4242 4242 4242
Declined Payment:   4000 0000 0000 0002
Requires 3D Secure: 4000 0027 6000 3184
```

### 5.2 Test UPI (Test Mode)
- Use any valid UPI ID format: `test@paytm`
- Payments will simulate success in test mode

### 5.3 Test Flow
1. **Add items to cart**
2. **Select delivery address**  
3. **Choose payment method**
4. **Complete payment**
5. **Verify order created**

---

## 🔒 Step 6: Security & Production

### 6.1 Environment Variables
Never commit API keys to code. Use environment variables:

```dart
// For production, load from environment
static const String _stripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: 'pk_test_default_key',
);
```

### 6.2 Webhook Setup (Optional)
For production, set up Stripe webhooks:
1. Go to **Developers → Webhooks** in Stripe
2. Add endpoint: `https://your-project.supabase.co/functions/v1/stripe-webhook`
3. Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`

---

## 📊 Step 7: Monitoring & Analytics

### 7.1 Stripe Dashboard
Monitor payments in Stripe Dashboard:
- **Payments** → View all transactions
- **Analytics** → Payment success rates
- **Disputes** → Handle chargebacks

### 7.2 Supabase Analytics
Track orders in Supabase:
```sql
-- Payment success rate
SELECT 
  payment_status,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM orders 
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY payment_status;
```

---

## 🚨 Troubleshooting

### Common Issues:

#### 1. "No implementation found for method"
**Solution**: Ensure Flutter Stripe plugin is properly installed
```bash
flutter clean
flutter pub get
```

#### 2. "Payment intent creation failed"
**Solution**: Check Supabase Edge Function logs and Stripe secret key

#### 3. "UPI not available"
**Solution**: Ensure UPI is enabled in Stripe Dashboard for India

#### 4. "Payment sheet not showing"
**Solution**: Verify Stripe publishable key is correct

---

## 📞 Support

### Stripe Support
- [Stripe Documentation](https://stripe.com/docs)
- [Stripe Support](https://support.stripe.com)

### Supabase Support  
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)

---

## 🎯 Production Checklist

Before going live:

- [ ] **Switch to live Stripe keys**
- [ ] **Test with real payment methods**
- [ ] **Set up webhook endpoints**
- [ ] **Configure proper error handling**
- [ ] **Set up monitoring and alerts**
- [ ] **Review security settings**
- [ ] **Test refund functionality**
- [ ] **Verify tax calculations**
- [ ] **Test edge cases (network failures, etc.)**

---

## 💡 Features Included

✅ **Multiple Payment Methods**: Cards, UPI, Net Banking, Wallets
✅ **Indian Payment Support**: Optimized for Indian market
✅ **Secure Processing**: PCI compliant via Stripe
✅ **Real-time Status**: Live payment status updates
✅ **Error Handling**: Graceful failure management
✅ **Order Tracking**: Complete payment audit trail
✅ **Mobile Optimized**: Native mobile payment experience

Your Meat Valla app now supports comprehensive payment options for Indian customers! 🎉
