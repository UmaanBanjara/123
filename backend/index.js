  const express = require('express');
  const bcrypt = require('bcrypt');
  const pool = require('./db');
  const nodemailer = require('nodemailer');
  const crypto = require('crypto');
  const jwt = require('jsonwebtoken');
  require('dotenv').config();
  const authenticationtoken = require('./middleware/authenticateToken');
  const cloudinary = require('./cloudinary/cloudinary');
  const multer = require('multer');
  const streamifier = require('streamifier');
  /*const forgotPassword = require('./forgotpass/forgotpass');
  const getResetPass = require('./forgotpass/getresetpass');
  const postResetPass = require('./forgotpass/postresetpass');*/





  const app = express();

  /*app.post('/forgot-password', forgotPassword);
  app.get('/reset-password', getResetPass);
  app.post('/reset-password', postResetPass);*/



  const storage = multer.memoryStorage(); // Store files in RAM buffer
  const upload = multer({ storage });

  const PORT = 3000;

  app.use(express.json());

  // Setup nodemailer transporter with Gmail
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'umaanflutter@gmail.com',
      pass: 'afzprdifayhxxrqq', // Your app password here
    },
  });

  // Signup route with email verification
  app.post('/signup', async (req, res) => {
    try {
      const { first_name, last_name, email, password } = req.body;

      // Check if user already exists
      const usercheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      if (usercheck.rows.length > 0) {
        return res.status(400).json({ error: 'User already exists with that email' });
      }

      // Hash password
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Generate email verification token
      const verificationToken = crypto.randomBytes(32).toString('hex');

      // Insert new user into DB
      const newuser = await pool.query(
        'INSERT INTO users (first_name, last_name, email, password_hash, verification_token, verified) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
        [first_name, last_name, email, hashedPassword, verificationToken, false]
      );

      // Create verification link (adjust IP/hostname accordingly)
      const verificationLink = `http://192.168.1.5:${PORT}/verify-email?token=${verificationToken}`;

      // Prepare email
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

      // Send verification email
      await transporter.sendMail(mailOptions);

      return res.status(201).json({
        message: 'User created successfully. Please verify your email.',
        user: newuser.rows[0],
      });
    } catch (err) {
      console.error(err.message);
      res.status(500).json({ error: 'Server error', details: err.message });
    }
  });

  // Email verification route
  app.get('/verify-email', async (req, res) => {
    try {
      const { token } = req.query;

      // Find user by token
      const userResult = await pool.query('SELECT * FROM users WHERE verification_token = $1', [token]);
      if (userResult.rows.length === 0) {
        return res.status(400).send('Invalid verification token');
      }

      // Update verified status and remove token
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

  // Google Signin route
  app.post('/google_signin', async (req, res) => {
    try {
      const { first_name, last_name, email, google_id } = req.body;

      if (!google_id || !email) {
        return res.status(400).json({ error: 'Missing google_id or email' });
      }

      // Check if user exists by google_id
      const userbygoogleid = await pool.query('SELECT * FROM users WHERE google_id = $1', [google_id]);

      if (userbygoogleid.rows.length > 0) {
        // User exists, login success
        return res.status(200).json({ message: 'Login successful', user: userbygoogleid.rows[0] });
      }

      // Check if user exists by email (email/password signup)
      const userByEmail = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

      if (userByEmail.rows.length > 0) {
        return res.status(400).json({
          error: 'User already exists with this email. Please login using email and password.',
        });
      }

      // Create new Google user
      const newUser = await pool.query(
        'INSERT INTO users (first_name, last_name, google_id, email, verified, create_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
        [first_name, last_name, google_id, email, true]
      );

      const user = newUser.rows[0];

      // Generate JWT token
      const payload = {
        userId: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
      };

      const token = jwt.sign(payload, process.env.JWT_secret, { expiresIn: '1h' });

      return res.status(201).json({ message: 'User created', token, user, create_at: user.create_at , profile_completed : user.profile_completed});
    } catch (err) {
      console.error('Google signin error:', err.message);
      res.status(500).json({ error: 'Server error' });
    }
  });

  // Login route
  app.post('/login', async (req, res) => {
    try {
      const { email, password } = req.body;

      // Find user by email
      const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
      if (userResult.rows.length === 0) {
        return res.status(400).json({ error: 'Invalid email or password' });
      }

      const user = userResult.rows[0];

      if (!user.verified) {
        return res.status(403).json({ error: 'Please verify your email before logging in' });
      }

      // Compare password hash
      const ispassvalid = await bcrypt.compare(password, user.password_hash);
      if (!ispassvalid) {
        return res.status(400).json({ error: 'Invalid email or password' });
      }

      // Create JWT payload
      const payload = {
        userId: user.id,
        email: user.email,
        firstName: user.first_name,
        lastname: user.last_name,
      };

      const token = jwt.sign(payload, process.env.JWT_secret, { expiresIn: '1h' });

      return res.status(200).json({
        message: 'Login successful',
        token,
        user: {
          id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          create_at: user.create_at,
          profile_completed : user.profile_completed
        },
      });
    } catch (err) {
      console.error('Login error:', err.message);
      return res.status(500).json({ error: 'Server error' });
    }
  });

    // Profile creation/update route (authenticated)
    app.post('/profilecreation', authenticationtoken, async (req, res) => {
      try {
        const { username, profile_picture_url, banner_url , bio} = req.body;
        const userId = req.user.userId;

        // Check if username is taken by other user
        const usernamecheck = await pool.query('SELECT * FROM users WHERE username = $1 AND id != $2', [username, userId]);

        if (usernamecheck.rows.length > 0) {
          return res.status(400).json({ error: 'Username already taken, please choose another one' });
        }

        // Update profile details
        const updateprofile = await pool.query(
          `UPDATE users SET username = $1, profile_picture_url = $2, banner_url = $3, profile_completed = $4, bio = $5 WHERE id = $6 RETURNING *`,
          [username, profile_picture_url, banner_url, true,bio , userId]
        );


        return res.status(200).json({
          message: 'Profile updated successfully',
          user: {
            username: updateprofile.rows[0].username,
            profile_picture_url: updateprofile.rows[0].profile_picture_url,
            banner_url: updateprofile.rows[0].banner_url,
            bio : updateprofile.rows[0].bio
          },
        });
      } catch (err) {
        console.error('Profile creation error:', err.message);
        res.status(500).json({ error: 'Server error' });
      }
    });

  // File upload route for profile picture and banner
  app.post('/uploadfiles', upload.fields([{ name: 'profile_picture', maxCount: 1 }, { name: 'banner', maxCount: 1 }]), async (req, res) => {
    const profilePictureFile = req.files?.['profile_picture']?.[0];
    const bannerFile = req.files?.['banner']?.[0];

    const uploadtocloudinary = (fileBuffer, folder) => {
      return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: folder },
          (error, result) => {
            if (error) return reject(error);
            resolve(result.url);
          }
        );

        streamifier.createReadStream(fileBuffer).pipe(stream);
      });
    };

    try {
      let profileUrl = null,
        bannerUrl = null;

      if (profilePictureFile) {
        profileUrl = await uploadtocloudinary(profilePictureFile.buffer, 'profile_pictures');
      }

      if (bannerFile) {
        bannerUrl = await uploadtocloudinary(bannerFile.buffer, 'banners');
      }

      res.status(200).json({
        message: 'Files uploaded successfully',
        profile_picture_url: profileUrl,
        banner_url: bannerUrl,
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Upload failed', details: err.message });
    }
  });

  // Get user details route (authenticated)
  app.get('/getuserdetail', authenticationtoken, async (req, res) => {
    try {
      const userId = req.user.userId;

      const result = await pool.query(
        'SELECT username, profile_picture_url, banner_url, email, first_name, last_name, create_at ,bio FROM users WHERE id = $1',
        [userId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      return res.status(200).json({ user: result.rows[0] });
    } catch (err) {
      console.error('Get profile error:', err.message);
      return res.status(500).json({ error: 'Server error' });
    }
  });



  // Start server on all network interfaces
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
  });
