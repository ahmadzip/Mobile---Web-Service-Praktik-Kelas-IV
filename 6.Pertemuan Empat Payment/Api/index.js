const express = require("express");
const bodyParser = require("body-parser");
const { sequelize } = require("./config/database");
const authRoutes = require("./routes/auth");
const paymentRoutes = require("./routes/payment");
const productRoutes = require("./routes/product");

const app = express();
const PORT = 3000;

app.use(bodyParser.json());

sequelize.sync();

app.use("/", authRoutes);
app.use("/", paymentRoutes);
app.use("/", productRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
