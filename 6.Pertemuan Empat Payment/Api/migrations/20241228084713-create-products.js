"use strict";
const { v4: uuidv4 } = require("uuid");

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable("Products", {
      sku: {
        type: Sequelize.STRING,
        allowNull: false,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      description: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      imageUrl: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      price: {
        type: Sequelize.FLOAT,
        allowNull: false,
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal("CURRENT_TIMESTAMP"),
      },
    });

    const products = [
      {
        sku: uuidv4(),
        name: "PENYAKIT JANTUNG",
        description:
          "Penyakit jantung adalah penyakit yang menyerang jantung dan pembuluh darah.",
        imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
        price: 100000,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        sku: uuidv4(),
        name: "PENGAKIT MAG",
        description: "Mag terjadi ketika asam lambung naik ke kerongkongan.",
        imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
        price: 80000,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        sku: uuidv4(),
        name: "PENYAKIT ANAK",
        description:
          "Demam, pilek, batuk, dan diare adalah penyakit anak-anak.",
        imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
        price: 120000,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        sku: uuidv4(),
        name: "PENYAKIT KULIT",
        description: "Penyakit yang menyerang kulit seperti eksim dan jerawat.",
        imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
        price: 150000,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        sku: uuidv4(),
        name: "PENYAKIT GIGI",
        description:
          "Gigi berlubang, gusi bengkak, dan sakit gigi adalah penyakit gigi.",
        imageUrl: "https://i.ibb.co.com/dMTZbM8/images.png",
        price: 90000,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ];

    await queryInterface.bulkInsert("Products", products);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable("Products");
  },
};
