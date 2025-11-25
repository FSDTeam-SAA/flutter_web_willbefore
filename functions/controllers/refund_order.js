const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");

exports.refundOrder = onCall(async (request, context) => {
  console.log("Data: ", request.data);
  console.log("stripeSecretKey value:", stripeSecretKey.value());
  // 1. Must be logged in
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be logged in");
  }
  // 2. Must be admin
  if (!request.auth.token.admin) {
    console.log("Non-admin tried to refund", {uid: request.auth.uid});
    throw new HttpsError("permission-denied", "Only admins can issue refunds");
  }
  const {
    paymentIntentId,
    amount,
    reason = "requested_by_customer",
  } = request.data;

  if (!paymentIntentId) {
    throw new HttpsError("invalid-argument", "paymentIntentId is required");
  }
  // Initialize Stripe with secret (safe at runtime)
  const stripe = require("stripe")(stripeSecretKey.value());
  try {
    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      amount: amount ? Math.round(amount * 100) : undefined,
      reason,
    });
    console.log("Refund successful", {
      refundId: refund.id,
      amount: refund.amount,
      paymentIntentId,
    });
    return {
      success: true,
      refundId: refund.id,
      amountRefunded: refund.amount / 100,
      status: refund.status,
    };
  } catch (error) {
    console.log("Stripe refund failed", {
      code: error.code,
      message: error.message,
      paymentIntentId,
    });

    throw new HttpsError("internal", `Refund failed: ${error.message}`);
  }
});
