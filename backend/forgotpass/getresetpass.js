const pool = require('./db');

async function getResetPassword(req, res) {
  const { token } = req.params;

  try {
    // Check if the token exists and has not expired
    const result = await pool.query(
      'SELECT id FROM users WHERE reset_token = $1 AND reset_token_expiry > NOW()',
      [token]
    );

    if (result.rowCount === 0) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    // Token is valid — frontend can now show reset form
    res.status(200).json({ message: 'Valid token' });
  } catch (error) {
    console.error('Error validating token:', error);
    res.status(500).json({ message: 'Server error' });
  }
}

module.exports = getResetPassword;
