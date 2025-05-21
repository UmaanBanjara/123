const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('./db');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

const app = express();
const PORT = 3000;

app.use(express.json());

// ✅ Corrected: `;` → `,` in transporter config
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'umaanflutter@gmail.com',
    pass: 'afzprdifayhxxrqq', // Use your app password here
  },
});

app.post('/signup', async (req, res) => {
  try {
    const { first_name, last_name, email, password } = req.body;

    // Check if user already exists
    const usercheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (usercheck.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists with that email' });
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Generate verification token
    const verificationToken = crypto.randomBytes(32).toString('hex');

    // Insert new user
    const newuser = await pool.query(
      'INSERT INTO users (first_name, last_name, email, password_hash, verification_token, verified) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [first_name, last_name, email, hashedPassword, verificationToken, false]
    );

    // ✅ Corrected: Backticks for template literal
    const verificationLink = `http://192.168.1.5:${PORT}/verify-email?token=${verificationToken}`;

    const mailOptions = {
      from: 'umaanflutter@gmail.com',
      to: email,  
      subject: 'Please verify your email',
      html: `
        <p>Hi ${first_name},</p>
        <p>Thanks for registering! Please click the link below to verify your email:</p>
        <a href="${verificationLink}">${verificationLink}</a>
      `,
    };
    try{

     const emailresutl =  await transporter.sendMail(mailOptions);
        
      console.log("Email sent :",emailresutl.response);


        }

        catch(emailError){
          console.error("error is : ",emailError.message);
        }

    return res.status(201).json({
      message: 'User created successfully. Please verify your email.',
      user: newuser.rows[0],
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' , details : err.message });
  }
});

app.get('/verify-email', async (req, res) => {
  try {
    const { token } = req.query;

    // Find user with this token
    const userResult = await pool.query('SELECT * FROM users WHERE verification_token = $1', [token]);
    if (userResult.rows.length === 0) {
      return res.status(400).send('Invalid verification token');
    }

    // Mark user as verified
    await pool.query(
      'UPDATE users SET verified = $1, verification_token = $2 WHERE verification_token = $3',
      [true, null, token]
    );

    res.send('Email verified successfully. You can now log in.');
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

app.listen(PORT, '0.0.0.0' , () => {
  console.log(`Server is running on port ${PORT}`);
});
