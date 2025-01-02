const express = require("express");
const { v4: uuidv4 } = require("uuid");
const axios = require("axios");
const crypto = require("crypto");
const { Payment, User, Product } = require("../models");
const { Op } = require("sequelize");
const router = express.Router();
const apiKey = "DEV-uQMdt6gpiT1TRbkOMcqdmYDcjbOVHB2xaqdfmEpq";
const privateKey = "Wf0B6-yUemf-3B8QV-09Qm7-rIrSD";
const merchant_code = "T22235";

async function createQrisTransaction(name, price, sku, email, userId) {
  const merchant_ref = uuidv4();
  const amount = price;
  const expiry = parseInt(Math.floor(new Date() / 1000) + 24 * 60 * 60);

  const signature = crypto
    .createHmac("sha256", privateKey)
    .update(merchant_code + merchant_ref + amount)
    .digest("hex");

  const payload = {
    method: "QRIS",
    merchant_ref: merchant_ref,
    amount: amount,
    customer_name: name,
    customer_email: email,
    order_items: [
      {
        sku: sku,
        name: name,
        price: price,
        quantity: 1,
      },
    ],
    return_url: "https://192.168.0.105.com/redirect",
    expired_time: expiry,
    signature: signature,
  };

  try {
    const response = await axios.post(
      "https://tripay.co.id/api-sandbox/transaction/create",
      payload,
      {
        headers: { Authorization: "Bearer " + apiKey },
        validateStatus: function (status) {
          return status < 999;
        },
      }
    );

    if (!response.data.data || !response.data.data.qr_url) {
      throw new Error("Failed to get checkout URL");
    }
    const product = await Product.findOne({ where: { sku } });
    if (!product.sku) {
      throw new Error("Product not found");
    }

    await Payment.create({
      merchant_ref: merchant_ref,
      name: name,
      price: price,
      qris_url: response.data.data.qr_url,
      sku: sku,
      user_id: userId,
      status: "pending",
    });

    return {
      qris_url: response.data.data.qr_url,
    };
  } catch (error) {
    console.error("Error creating QRIS transaction:", error);
    throw error;
  }
}

router.post("/create-qris", async (req, res) => {
  const { emailOrUsername, productId } = req.body;

  if (!emailOrUsername || !productId) {
    return res.status(400).json({
      error: "Email or username and productId are required",
    });
  }

  try {
    const user = await User.findOne({
      where: {
        [Op.or]: [{ email: emailOrUsername }, { username: emailOrUsername }],
      },
    });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const product = await Product.findByPk(productId);
    if (!product) {
      return res.status(404).json({ error: "Product not found" });
    }

    const qrisUrl = await createQrisTransaction(
      product.name,
      product.price,
      product.sku,
      user.email,
      user.id
    );
    res.json({ qris_url: qrisUrl });
  } catch (error) {
    console.error("Error in /create-qris route:", error);
    res.status(500).json({ error: error.message });
  }
});

router.post("/tripay/callback", async (req, res) => {
  const json = req.body;
  const signature = crypto
    .createHmac("sha256", privateKey)
    .update(JSON.stringify(json))
    .digest("hex");

  console.log("Signature:", signature);
  console.log("JSON Response:", json);

  const { merchant_ref, status } = json;

  if (status === "PAID") {
    try {
      const payment = await Payment.findOne({ where: { merchant_ref } });
      if (payment) {
        payment.status = "paid";
        await payment.save();
        console.log(
          `Payment status updated to 'paid' for merchant_ref: ${merchant_ref}`
        );
      } else {
        console.log(`Payment not found for merchant_ref: ${merchant_ref}`);
      }
    } catch (error) {
      console.error("Error updating payment status:", error);
      return res.status(500).send("Internal Server Error");
    }
  }

  res.status(200).send("Callback received");
});

module.exports = router;
