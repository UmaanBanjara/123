const crypto = require('crypto');
const pool = require('./db');  // your PostgreSQL pool instance
const nodemailer = require('nodemailer');

async function forgotPassword(req, res) {
  const { email } = req.body;

  try {
    // Check if user exists
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rowCount === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate token & expiry (1 hour)
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiry = new Date(Date.now() + 3600000).toISOString();

    // Save token & expiry in DB
    await pool.query(
      'UPDATE users SET reset_token = $1, reset_token_expiry = $2 WHERE email = $3',
      [resetToken, expiry, email]
    );

    // Configure Nodemailer (replace with your SMTP config)
    const transporter = nodemailer.createTransport({
    
      service : 'gmail',  
      
       
      auth: {
        user: "umaanflutter@gmail.com",
        pass: "afzprdifayhxxrqq",
      },
    });


    // Compose reset email
    const resetUrl = `https://192.168.1.5:3000/reset-password/${resetToken}`;
    const mailOptions = {
      from: 'umaanflutter@gmail.com',
      to: email,
      subject: "Password Reset Request",
      text: `You requested a password reset. Click here to reset your password: ${resetUrl}`,
      html: `<p>You requested a password reset.</p><p>Click <a href="${resetUrl}">here</a> to reset your password.</p>`
    };

    await transporter.sendMail(mailOptions);

    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error, try again later' });
  }
}

module.exports = forgotPassword;
