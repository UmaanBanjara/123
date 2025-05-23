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

    await transporter.sendMail(mailOptions);

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


app.post('/google_signin', async (req, res) => {
  try {
    const { first_name, last_name, email, google_id } = req.body;

    if (!google_id || !email) {
      return res.status(400).json({ error: 'Missing google_id or email' });
    }

    // Check if user exists by google_id
    const userbygoogleid = await pool.query('SELECT * FROM users WHERE google_id = $1', [google_id]);

    if (userbygoogleid.rows.length > 0) {
      // User exists, normal Google login
      return res.status(200).json({ message: 'Login successful', user: userbygoogleid.rows[0] });
    }

    // Check if user exists by email (email/password signup)
    const userByEmail = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if (userByEmail.rows.length > 0) {
      // User exists with this email but no Google ID linked — block Google login
      return res.status(400).json({
        error: 'User already exists with this email. Please login using email and password.',
      });
    }

    // Create new user
    const newUser = await pool.query(
      'INSERT INTO users (first_name, last_name, google_id, email, verified, create_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
      [first_name, last_name, google_id, email, true]
    );

    return res.status(201).json({ message: 'User created', user: newUser.rows[0] });
  } catch (err) {
    console.error('Google signin error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});


app.post('/signin_github' , async(req , res)=>{
  try{
    const{email , first_name , last_name , github_id } = req.body;

    
    if (!email || !github_id) {
      return res.status(400).json({ error: 'Missing email or github_id' });
    }

        // Check if user exists by email
    const existingUser = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if(existingUser.rows.length > 0){
      const user = existingUser.rows[0];

      // check if user exits with either google or email/pass

      if(user.google_id || user.password_hash){
        return res.status(400).json({
          error : 'Email already registered with Google or Email/Password. Use that to sign in.',
        });
      }
    }


    //if user exits with github login 


    const githubUser = await pool.query('SELECT * FROM users WHERE github_id = $1', [github_id]);
    if (githubUser.rows.length > 0) {
      return res.status(200).json({ message: 'Login successful', user: githubUser.rows[0] });
    }


    //create new user 


    const firstName = full_name.split(' ')[0];
    const lastName = full_name.split(' ').slice(1).join(' ') || '';



    const newUser = await pool.query(
      'INSERT INTO users (email, github_id, first_name, last_name, verified, create_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
      [email, github_id, firstName, lastName, true]
    );

      return res.status(201).json({ message: 'User created', user: newUser.rows[0] });

  } catch (err) {
    console.error('GitHub signin error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }







  
});



app.post('/login' , async(req , res) => {


try{
  const {email , password } = req.body ;

  //check if user exits by email 

  const userResult = await pool.query('SELECT * FROM users WHERE email = $1' , [email]);
  if(userResult.rows.length == 0){
    return res.status(400).json({error : 'Invalid email or password'});
  }
  const user = userResult.rows[0];

  if(!user.verified){
    return res.status(403).json({error : 'Please verify your email before loggin in'});
  }

  //compare password with password_hash

  const ispassvalid = await bcrypt.compare(password , user.password_hash);
  if(!ispassvalid){
    return res.status(400).json({ error: 'Invalid email or password' });  
  }

  //successfuuly login 

  return res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        // exclude password_hash and tokens here for security
      },
    });
}
catch (err) {
    console.error('Login error:', err.message);
    return res.status(500).json({ error: 'Server error' });
  }




});
 

app.listen(PORT, '0.0.0.0' , () => {  
  console.log(`Server is running on port ${PORT}`);
});
