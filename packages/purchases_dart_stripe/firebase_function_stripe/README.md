# Firebase Function Stripe

To handle Stripe webhook and update RevenueCat

## Get Started

Configure `stripe_key` `stripe_webhook_secret` and `revenuecat_api_key` in `functions/index.js`

Make sure [node](https://nodejs.org/en) and [firebase](https://firebase.google.com/docs/cli) is installed

install node dependencies with `npm install` in `/functions` path

Add new firebase project: `firebase use --add`

Deploy to cloud function: `firebase deploy`

## Setup on Stripe

After deployed to firebase, Get cloud function url and add that in Stripe's Webhook section with `/webhook` path
eg: `https://CLOUD_FUNCTION_URL/app/webhook` with event: `checkout.session.completed`

Note: after setting up webhook, get webhook's `signing secret` and add in function's `stripe_webhook_secret` and deploy again

## Note

index.js can also be used as a standalone expressJs application with little modification
