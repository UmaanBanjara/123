const bcrypt = require('bcrypt');
const pool = require('./db');

async function postResetPassword(req, res) {
  const { token, newPassword } = req.body;

  try {
    // 1. Validate token
    const userResult = await pool.query(
      'SELECT id FROM users WHERE reset_token = $1 AND reset_token_expiry > NOW()',
      [token]
    );

    if (userResult.rowCount === 0) {
      return res.status(400).json({ message: 'Invalid or expired reset token' });
    }

    const userId = userResult.rows[0].id;

    // 2. Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // 3. Update password and clear reset token
    await pool.query(
      `UPDATE users 
       SET password_hash = $1, reset_token = NULL, reset_token_expiry = NULL 
       WHERE id = $2`,
      [hashedPassword, userId]
    );

    res.json({ message: 'Password has been reset successfully' });
  } catch (error) {
    console.error('Error resetting password:', error);
    res.status(500).json({ message: 'Server error, please try again' });
  }
}

module.exports = postResetPassword;
