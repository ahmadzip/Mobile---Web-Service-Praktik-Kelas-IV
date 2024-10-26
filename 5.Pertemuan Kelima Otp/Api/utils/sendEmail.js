const nodemailer = require("nodemailer");

const sendMail = async (to, subject, html) => {
  console.log("to", to);
  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
      user: "",
      pass: "",
    },
  });

  const info = await transporter.sendMail({
    from: "",
    to,
    subject,
    html,
  });

  if (info.accepted[0] === to) {
    return { status: true, msg: "Email sent successfully." };
  } else {
    return { status: false, msg: "Email not sent." };
  }
};

module.exports = sendMail;
