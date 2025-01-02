"use strict";
module.exports = (sequelize, DataTypes) => {
  const Payment = sequelize.define("Payment", {
    merchant_ref: {
      type: DataTypes.STRING,
      allowNull: false,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    price: {
      type: DataTypes.FLOAT,
      allowNull: false,
    },
    status: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "Users",
        key: "id",
      },
    },
    qris_url: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    sku: {
      type: DataTypes.STRING,
      allowNull: false,
      references: {
        model: "Products",
        key: "sku",
      },
    },
  });

  Payment.associate = (models) => {
    Payment.belongsTo(models.User, {
      foreignKey: "user_id",
      as: "user",
    });
    Payment.belongsTo(models.Product, {
      foreignKey: "sku",
      as: "product",
    });
  };

  return Payment;
};
