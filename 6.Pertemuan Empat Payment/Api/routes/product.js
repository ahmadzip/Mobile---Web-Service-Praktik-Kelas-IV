const express = require("express");
const { v4: uuidv4 } = require("uuid");

const router = express.Router();

const products = [
  {
    sku: uuidv4(),
    name: "Acocado Salad",
    description: "Fresh avocado salad with cherry tomatoes",
    imageUrl: "images/food1.png",
    price: 100000,
  },
  {
    sku: uuidv4(),
    name: "Egg Boil Bread",
    description: "Boiled egg with bread and vegetables",
    imageUrl: "images/food2.png",
    price: 80000,
  },
  {
    sku: uuidv4(),
    name: "Fried Shrimp",
    description: "Fried shrimp with vegetables",
    imageUrl: "images/food3.png",
    price: 120000,
  },
  {
    sku: uuidv4(),
    name: "Salmon Steam",
    description: "Steamed salmon with vegetables",
    imageUrl: "images/food4.png",
    price: 150000,
  },
  {
    sku: uuidv4(),
    name: "Vegetable Salad",
    description: "Fresh vegetable salad with cherry tomatoes",
    imageUrl: "images/food5.png",
    price: 90000,
  },
];

// Get all products
router.get("/products", (req, res) => {
  res.json(products);
});

// Get a product by SKU
router.get("/products/:sku", (req, res) => {
  const { sku } = req.params;
  const product = products.find((p) => p.sku === sku);
  if (product) {
    res.json(product);
  } else {
    res.status(404).json({ error: "Product not found" });
  }
});

// Create a new product
router.post("/products", (req, res) => {
  const { name, description, imageUrl, price } = req.body;
  const sku = uuidv4();
  const newProduct = { sku, name, description, imageUrl, price };
  products.push(newProduct);
  res.status(201).json(newProduct);
});

// Update a product by SKU
router.put("/products/:sku", (req, res) => {
  const { sku } = req.params;
  const { name, description, imageUrl, price } = req.body;
  const product = products.find((p) => p.sku === sku);
  if (product) {
    product.name = name;
    product.description = description;
    product.imageUrl = imageUrl;
    product.price = price;
    res.json(product);
  } else {
    res.status(404).json({ error: "Product not found" });
  }
});

// Delete a product by SKU
router.delete("/products/:sku", (req, res) => {
  const { sku } = req.params;
  const productIndex = products.findIndex((p) => p.sku === sku);
  if (productIndex !== -1) {
    products.splice(productIndex, 1);
    res.json({ message: "Product deleted" });
  } else {
    res.status(404).json({ error: "Product not found" });
  }
});

module.exports = router;
