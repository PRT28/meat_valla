import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.21.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Stripe with secret key
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || '', {
      apiVersion: '2023-10-16',
    })

    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const { amount, currency, orderId, paymentMethod, metadata } = await req.json()

    // Validate required fields
    if (!amount || !currency || !orderId) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: amount, currency, orderId' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create payment intent with Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Amount in smallest currency unit (paise for INR)
      currency: currency,
      // Use either automatic_payment_methods OR payment_method_types, not both
      payment_method_types: getPaymentMethodTypes(paymentMethod),
      metadata: {
        orderId: orderId,
        paymentMethod: paymentMethod || 'unknown',
        ...metadata,
      },
    })

    // Store payment intent in Supabase for tracking
    const { error: dbError } = await supabaseClient
      .from('payment_intents')
      .insert({
        id: paymentIntent.id,
        order_id: orderId,
        amount: amount,
        currency: currency,
        status: paymentIntent.status,
        client_secret: paymentIntent.client_secret,
        payment_method_type: paymentMethod,
        created_at: new Date().toISOString(),
      })

    if (dbError) {
      console.error('Error storing payment intent:', dbError)
      // Continue even if DB storage fails
    }

    return new Response(
      JSON.stringify({
        paymentIntent: {
          id: paymentIntent.id,
          client_secret: paymentIntent.client_secret,
          status: paymentIntent.status,
          amount: paymentIntent.amount,
          currency: paymentIntent.currency,
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error creating payment intent:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Failed to create payment intent',
        details: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Helper function to get payment method types based on selected method
function getPaymentMethodTypes(paymentMethod: string): string[] {
  switch (paymentMethod) {
    case 'card':
      return ['card']
    case 'upi':
      return ['upi']
    case 'netBanking':
      return ['netbanking']
    case 'wallet':
      return ['wallet']
    case 'cashOnDelivery':
      // For COD, we don't need payment methods, but return card as fallback
      return ['card']
    default:
      // Return commonly supported methods for India
      return ['card', 'upi']
  }
}

/* To deploy this function:
1. Install Supabase CLI: npm install -g supabase
2. Login: supabase login
3. Link project: supabase link --project-ref your-project-ref
4. Set environment variables:
   supabase secrets set STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
5. Deploy: supabase functions deploy create-payment-intent
*/
