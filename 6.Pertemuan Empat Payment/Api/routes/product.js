const express = require("express");
const { v4: uuidv4 } = require("uuid");

const router = express.Router();

const products = [
  {
    sku: uuidv4(),
    name: "PENYAKIT JANTUNG",
    description:
      "Penyakit jantung adalah penyakit yang menyerang jantung dan pembuluh darah. ",
    imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
    price: 100000,
  },
  {
    sku: uuidv4(),
    name: "PENGAKIT MAG",
    description: "Mag terjadi ketika asam lambung naik ke kerongkongan.",
    imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
    price: 80000,
  },
  {
    sku: uuidv4(),
    name: "PENYAKIT ANAK",
    description: "Demam, pilek, batuk, dan diare adalah penyakit anak-anak.",
    imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
    price: 120000,
  },
  {
    sku: uuidv4(),
    name: "PENYAKIT KULIT",
    description: "Penyakit yang menyerang kulit seperti eksim dan jerawat.",
    imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
    price: 150000,
  },
  {
    sku: uuidv4(),
    name: "PENYAKIT GIGI",
    description:
      "Gigi berlubang, gusi bengkak, dan sakit gigi adalah penyakit gigi.",
    imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
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
