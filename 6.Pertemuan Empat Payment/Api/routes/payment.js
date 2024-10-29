const express = require("express");
const { v4: uuidv4 } = require("uuid");
const axios = require("axios");
const crypto = require("crypto");

const router = express.Router();

const apiKey = "DEV-uQMdt6gpiT1TRbkOMcqdmYDcjbOVHB2xaqdfmEpq";
const privateKey = "Wf0B6-yUemf-3B8QV-09Qm7-rIrSD";
const merchant_code = "T22235";

async function createQrisTransaction(name, price, description) {
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
    customer_email: "emailpelanggan@domain.com",
    order_items: [
      {
        sku: "sku1",
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
          return status < 999; // ignore http error
        },
      }
    );
    console.log("QRIS Transaction Response:", response.data);
    return response.data.data.checkout_url;
  } catch (error) {
    console.error("Error creating QRIS transaction:", error);
    throw error;
  }
}

router.post("/create-qris", async (req, res) => {
  const { name, price, description } = req.body;

  if (!name || !price || !description) {
    return res
      .status(400)
      .json({ error: "Name, price, and description are required" });
  }

  try {
    const qrisUrl = await createQrisTransaction(name, price, description);
    res.json({ qris_url: qrisUrl });
  } catch (error) {
    res.status(500).json({ error: "Failed to create QRIS transaction" });
  }
});

module.exports = router;
