"use strict";
const bcrypt = require("bcrypt");

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const hashedPassword = await bcrypt.hash("123", 10);

    await queryInterface.bulkInsert("Users", [
      {
        username: "123",
        email: "123@123.com",
        password: hashedPassword,
        otp: null,
        isVerified: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete("Users", { username: "defaultuser" }, {});
  },
};
