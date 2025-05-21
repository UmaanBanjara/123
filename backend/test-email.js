const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'umaanflutter@gmail.com',
    pass: 'afzprdifayhxxrqq  ',
  },
});

const mailOptions = {
  from: 'umaanflutter@gmail.com',
  to: 'umaanbanjara@gmail.com',
  subject: 'Test Email',
  text: 'This is a test email from Node.js',
};

transporter.sendMail(mailOptions, (error, info) => {
  if (error) {
    return console.log('Error:', error);
  }
  console.log('Email sent:', info.response);
});
