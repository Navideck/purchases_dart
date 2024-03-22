("use strict");
const functions = require("firebase-functions");
const express = require("express");
const admin = require("firebase-admin");
const { Liquid } = require("liquidjs");

// Configure the app
const appConfig = {
  region: "europe-west1",
  stripe_key: "STRIPE_SECRET_KEY",
  stripe_webhook_secret: "STRIPE_WEBHOOK_SECRET",
  revenuecat_api_key: "REVENUECAT_API_KEY",
};

const stripe = require("stripe")(appConfig.stripe_key);

admin.initializeApp();
const app = express();
const engine = new Liquid();

const revenueCatAxios = require("axios").create({
  baseURL: "https://api.revenuecat.com/v1",
  headers: {
    "X-Platform": "stripe",
    Authorization: `Bearer ${appConfig.revenuecat_api_key}`,
  },
});

// Set the engine to render liquid templates
app.engine("liquid", engine.express());
app.set("views", "./views");
app.set("view engine", "liquid");

// Handle Stripe webhook
app.post("/webhook", async (request, response) => {
  try {
    const sig = request.headers["stripe-signature"];
    const event = stripe.webhooks.constructEvent(
      request.rawBody,
      sig,
      appConfig.stripe_webhook_secret
    );
    const purchaseObject = event.data.object;
    const userId = purchaseObject.client_reference_id;
    const customer = purchaseObject.customer;
    let token = purchaseObject.subscription;
    if (!token) {
      token = purchaseObject.id;
    }
    if (!userId) {
      return response
        .status(400)
        .end(JSON.stringify({ error: "client_reference_id not found " }));
    }

    // Make a post request to RevenueCat for updating the purchase
    await revenueCatAxios.post("/receipts", {
      app_user_id: userId,
      fetch_token: token,
      attributes: {
        stripe_customer_id: {
          value: customer,
        },
      },
    });

    return response.json({ received: true });
  } catch (err) {
    return response.status(400).end(JSON.stringify({ error: err }));
  }
});

// Handle Stripe result
app.get("/stripe_result*", async (req, res) => {
  try {
    const path = req.path.replace("/stripe_result", "");
    const isSuccess = path.startsWith("/success");
    const appScheme = req.query.app_scheme;
    let sessionId = req.query.session_id;
    if (!sessionId) {
      sessionId = "NA";
    }
    let appSchemeUrl = "";
    if (appScheme) {
      const url = new URL(`stripe${path}`, `${appScheme}://`);
      url.searchParams.append("session_id", sessionId);
      appSchemeUrl = url.toString();
    }
    res.status(200).render("stripe_result", {
      result: isSuccess ? "Success" : "Failure",
      appSchemeUrl: appSchemeUrl,
    });
  } catch (err) {
    console.log(err);
    return res.status(400).send();
  }
});

exports.app = functions.region(appConfig.region).https.onRequest(app);

// To use as a standalone express server
// app.listen(3000, () => {
//   console.log("Server is running on port 3000");
// });
