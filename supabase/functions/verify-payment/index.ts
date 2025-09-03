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

    const { paymentIntentId } = await req.json()

    if (!paymentIntentId) {
      return new Response(
        JSON.stringify({ error: 'Missing paymentIntentId' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId)

    // Update payment intent status in Supabase
    const { error: updateError } = await supabaseClient
      .from('payment_intents')
      .update({
        status: paymentIntent.status,
        updated_at: new Date().toISOString(),
        payment_method_id: paymentIntent.payment_method,
        charges: paymentIntent.charges?.data || [],
      })
      .eq('id', paymentIntentId)

    if (updateError) {
      console.error('Error updating payment intent:', updateError)
    }

    // If payment succeeded, update the order status
    if (paymentIntent.status === 'succeeded') {
      const orderId = paymentIntent.metadata?.orderId
      if (orderId) {
        const { error: orderUpdateError } = await supabaseClient
          .from('orders')
          .update({
            payment_status: 'paid',
            payment_intent_id: paymentIntentId,
            payment_method_id: paymentIntent.payment_method,
            updated_at: new Date().toISOString(),
          })
          .eq('id', orderId)

        if (orderUpdateError) {
          console.error('Error updating order payment status:', orderUpdateError)
        }
      }
    }

    return new Response(
      JSON.stringify({
        status: paymentIntent.status,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        metadata: paymentIntent.metadata,
        payment_method: paymentIntent.payment_method,
        created: paymentIntent.created,
        charges: paymentIntent.charges?.data || [],
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error verifying payment:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Failed to verify payment',
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
1. Deploy: supabase functions deploy verify-payment
*/
