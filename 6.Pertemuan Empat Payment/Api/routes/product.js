const express = require("express");
const { v4: uuidv4 } = require("uuid");
const { Payment, User, Product } = require("../models");
const router = express.Router();
const { Op } = require("sequelize");

// Get all products
router.get("/products", async (req, res) => {
  try {
    const products = await Product.findAll();
    res.json(products);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch products" });
  }
});

// Get product by SKU
router.get("/products/:sku", async (req, res) => {
  const { sku } = req.params;
  try {
    const product = await Product.findOne({ where: { sku } });
    if (product) {
      res.json(product);
    } else {
      res.status(404).json({ error: "Product not found" });
    }
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch product" });
  }
});

router.get("/user-products/:email", async (req, res) => {
  const { email } = req.params;
  try {
    const user = await User.findOne({
      where: {
        [Op.or]: [{ email: email }, { username: email }],
      },
    });
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const products = await Product.findAll();
    const ownedProducts = await Payment.findAll({
      where: { user_id: user.id, status: "paid" },
      attributes: ["sku"],
    });

    const ownedSkus = ownedProducts.map((payment) => payment.sku);

    const productsWithOwnership = products.map((product) => ({
      ...product.toJSON(),
      owned: ownedSkus.includes(product.sku),
    }));

    res.json(productsWithOwnership);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch user products" });
  }
});

router.post("/products", async (req, res) => {
  const { name, description, imageUrl, price } = req.body;
  const sku = uuidv4();
  try {
    const newProduct = await Product.create({
      sku,
      name,
      description,
      imageUrl,
      price,
    });
    res.status(201).json(newProduct);
  } catch (error) {
    res.status(500).json({ error: "Failed to create product" });
  }
});

router.put("/products/:sku", async (req, res) => {
  const { sku } = req.params;
  const { name, description, imageUrl, price } = req.body;
  try {
    const product = await Product.findOne({ where: { sku } });
    if (product) {
      product.name = name;
      product.description = description;
      product.imageUrl = imageUrl;
      product.price = price;
      await product.save();
      res.json(product);
    } else {
      res.status(404).json({ error: "Product not found" });
    }
  } catch (error) {
    res.status(500).json({ error: "Failed to update product" });
  }
});

router.delete("/delete/:email", async (req, res) => {
  const { email } = req.params;
  try {
    const user = await User.findOne({
      where: {
        [Sequelize.Op.or]: [{ email: email }, { username: email }],
      },
    });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    await user.destroy();
    return res.json({ message: "User deleted" });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Failed to delete user" });
  }
});

module.exports = router;
