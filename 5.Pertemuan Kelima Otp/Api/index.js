const express = require("express");
const bodyParser = require("body-parser");
const { sequelize } = require("./config/database");
const authRoutes = require("./routes/auth");

const app = express();
const PORT = 3000;

app.use(bodyParser.json());

sequelize.sync();

app.use("/", authRoutes);

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
