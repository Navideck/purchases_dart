# Firebase Function Stripe

Handle Stripe webhooks and update RevenueCat.

## Getting Started

To get started, follow these steps:

1. Configure the following environment variables in `functions/index.js`:
    - `stripe_key`: Your Stripe API key
    - `stripe_webhook_secret`: Your Stripe webhook signing secret
    - `revenuecat_api_key`: Your RevenueCat API key

2. Make sure you have Node.js and Firebase CLI installed on your machine.

3. Install the Node.js dependencies by running `npm install` in the `/functions` directory.

4. Add a new Firebase project by running `firebase use --add`.

5. Deploy the cloud function by running `firebase deploy`.

## Setting Up Stripe

After deploying the Firebase function, follow these steps to set up Stripe:

1. Get the cloud function URL and add it to the Stripe webhook section with the `/webhook` path. For example: `https://CLOUD_FUNCTION_URL/app/webhook`. Set the event to `checkout.session.completed`.

2. After setting up the webhook, get the webhook's signing secret and add it to the `stripe_webhook_secret` variable in the `functions/index.js` file. Then, redeploy the function.

## Note

The `index.js` file can also be used as a standalone Express.js application with some modifications.
