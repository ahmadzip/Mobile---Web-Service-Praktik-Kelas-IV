const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { Sequelize } = require("sequelize");
const { User } = require("../models");
const generateOtp = require("../utils/otp");
const sendMail = require("../utils/sendEmail");

const router = express.Router();
const SECRET_KEY = "123";

router.post("/register", async (req, res) => {
  const { username, email, password, otpMethod } = req.body;
  try {
    const existingUser = await User.findOne({
      where: {
        [Sequelize.Op.or]: [{ username }, { email }],
      },
    });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists!" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = generateOtp();
    await User.create({ username, email, password: hashedPassword, otp });
    if (otpMethod === "Gmail") {
      const subject = "OTP for email verification";
      const html = `<p>Your OTP code is: <strong>${otp}</strong></p>`;
      const emailResult = await sendMail(email, subject, html);
      if (!emailResult.status) {
        return res.status(500).json({ message: "Failed to send OTP email." });
      }
    }

    return res
      .status(201)
      .json({ message: "User created successfully!", otpMethod });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal server error!" });
  }
});

router.post("/verify-otp", async (req, res) => {
  const { email, otp } = req.body;
  console.log(email, otp);
  try {
    const user = await User.findOne({ where: { username: email, otp } });
    if (!user) {
      return res.status(400).json({ message: "Invalid OTP!" });
    }

    user.isVerified = true;
    user.otp = null;
    await user.save();

    return res.status(200).json({ message: "User verified successfully!" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal server error!" });
  }
});

router.post("/login", async (req, res) => {
  const { usernameOrEmail, password } = req.body;

  try {
    const user = await User.findOne({
      where: {
        [Sequelize.Op.or]: [
          { username: usernameOrEmail },
          { email: usernameOrEmail },
        ],
      },
    });

    if (!user) {
      return res.status(401).json({ message: "Invalid credentials!" });
    }

    if (!user.isVerified) {
      return res
        .status(403)
        .json({ message: "User not verified!", username: user.username });
    }

    if (await bcrypt.compare(password, user.password)) {
      const token = jwt.sign({ username: user.username }, SECRET_KEY, {
        expiresIn: "1h",
      });
      return res.status(200).json({ message: "Login successful!", token });
    } else {
      return res.status(401).json({ message: "Invalid credentials!" });
    }
  } catch (error) {
    return res.status(500).json({ message: "Internal server error!" });
  }
});

router.post("/forgot-password", async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(400).json({ message: "User not found!" });
    }

    const otp = generateOtp();
    user.otp = otp;
    await user.save();

    const subject = "OTP for password reset";
    const html = `<p>Your OTP code is: <strong>${otp}</strong></p>`;
    const emailResult = await sendMail(email, subject, html);
    if (!emailResult.status) {
      return res.status(500).json({ message: "Failed to send OTP email." });
    }

    return res.status(200).json({ message: "OTP sent successfully!" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal server error!" });
  }
});

router.post("/reset-password", async (req, res) => {
  const { email, password, otp } = req.body;
  console.log(email, password, otp);
  try {
    const user = await User.findOne({
      where: {
        [Sequelize.Op.or]: [{ username: email }, { email: email }],
        otp,
      },
    });
    if (!user) {
      return res.status(400).json({ message: "Invalid OTP!" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;
    user.otp = null;
    await user.save();

    return res.status(200).json({ message: "Password reset successfully!" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Internal server error!" });
  }
});

module.exports = router;
