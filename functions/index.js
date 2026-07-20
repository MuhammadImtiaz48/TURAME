const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const Stripe = require('stripe');

admin.initializeApp();

const stripeSecret = defineSecret('STRIPE_SECRET');

/**
 * Creates a Stripe PaymentIntent for the signed-in patient.
 * Secrets: firebase functions:secrets:set STRIPE_SECRET
 */
exports.createPaymentIntent = onCall(
  { secrets: [stripeSecret], region: 'us-central1' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in required.');
    }

    const amount = Number(request.data?.amount);
    const currency = String(request.data?.currency || 'rwf').toLowerCase();
    const metadata = request.data?.metadata || {};

    if (!Number.isFinite(amount) || amount < 1) {
      throw new HttpsError('invalid-argument', 'Invalid amount.');
    }

    const stripe = new Stripe(stripeSecret.value(), {
      apiVersion: '2024-12-18.acacia',
    });

    try {
      const intent = await stripe.paymentIntents.create({
        amount: Math.round(amount),
        currency,
        automatic_payment_methods: { enabled: true },
        metadata: {
          firebaseUid: request.auth.uid,
          ...Object.fromEntries(
            Object.entries(metadata).map(([k, v]) => [k, String(v)]),
          ),
        },
      });

      return {
        clientSecret: intent.client_secret,
        paymentIntentId: intent.id,
      };
    } catch (err) {
      console.error('Stripe error', err);
      throw new HttpsError(
        'internal',
        err.message || 'Unable to create payment intent',
      );
    }
  },
);
