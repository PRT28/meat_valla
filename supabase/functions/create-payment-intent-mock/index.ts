import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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

    // Create mock payment intent (for development)
    const mockPaymentIntent = {
      id: `pi_mock_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      client_secret: `pi_mock_${Date.now()}_secret_${Math.random().toString(36).substr(2, 9)}`,
      status: 'requires_payment_method',
      amount: Math.round(amount),
      currency: currency,
      created: Math.floor(Date.now() / 1000),
    }

    // Store mock payment intent in Supabase for tracking
    const { error: dbError } = await supabaseClient
      .from('payment_intents')
      .insert({
        id: mockPaymentIntent.id,
        order_id: orderId,
        amount: amount,
        currency: currency,
        status: mockPaymentIntent.status,
        client_secret: mockPaymentIntent.client_secret,
        payment_method_type: paymentMethod,
        metadata: {
          mock: true,
          originalMetadata: metadata,
        },
        created_at: new Date().toISOString(),
      })

    if (dbError) {
      console.error('Error storing mock payment intent:', dbError)
      // Continue even if DB storage fails
    }

    return new Response(
      JSON.stringify({
        paymentIntent: mockPaymentIntent,
        mock: true,
        message: 'This is a mock payment intent for development'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error creating mock payment intent:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Failed to create mock payment intent',
        details: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

/* To deploy this function:
1. Deploy: supabase functions deploy create-payment-intent-mock
2. Update your app to use this function for development
3. Switch to real Stripe function for production
*/
