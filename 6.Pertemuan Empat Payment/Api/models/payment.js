module.exports = (sequelize, DataTypes) => {
  const Payments = sequelize.define("Payments", {
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
    description: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    qris_url: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  });

  return Payments;
};
