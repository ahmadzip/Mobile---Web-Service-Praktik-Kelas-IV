"use strict";

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const tableInfo = await queryInterface.describeTable("Payments");

    if (!tableInfo.sku) {
      await queryInterface.addColumn("Payments", "sku", {
        type: Sequelize.STRING,
        allowNull: false,
        defaultValue: "default_sku",
      });
    }

    if (tableInfo.name) {
      await queryInterface.removeColumn("Payments", "name");
    }
    if (tableInfo.price) {
      await queryInterface.removeColumn("Payments", "price");
    }
    if (tableInfo.description) {
      await queryInterface.removeColumn("Payments", "description");
    }
    if (tableInfo.qris_url) {
      await queryInterface.removeColumn("Payments", "qris_url");
    }
  },

  down: async (queryInterface, Sequelize) => {
    const tableInfo = await queryInterface.describeTable("Payments");

    if (!tableInfo.name) {
      await queryInterface.addColumn("Payments", "name", {
        type: Sequelize.STRING,
        allowNull: false,
      });
    }
    if (!tableInfo.price) {
      await queryInterface.addColumn("Payments", "price", {
        type: Sequelize.FLOAT,
        allowNull: false,
      });
    }
    if (!tableInfo.description) {
      await queryInterface.addColumn("Payments", "description", {
        type: Sequelize.STRING,
        allowNull: false,
      });
    }
    if (!tableInfo.qris_url) {
      await queryInterface.addColumn("Payments", "qris_url", {
        type: Sequelize.STRING,
        allowNull: false,
      });
    }
    if (tableInfo.sku) {
      await queryInterface.removeColumn("Payments", "sku");
    }
  },
};
