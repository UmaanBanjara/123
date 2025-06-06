const os = require('os');
const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('./db');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const authenticationtoken = require('./middleware/authenticateToken');
const multer = require('multer');
const path = require('path');
const router = require('./tenor/tenor');

const { storage } = require('./upload/upload');
const upload = multer({ storage });

const homeDir = os.homedir();
const app = express();

app.use('/uploads/pfp', express.static(path.join(homeDir, 'uploaded_pfp_by_user')));
app.use('/uploads/banner', express.static(path.join(homeDir, 'uploaded_banner_by_user')));
app.use('/uploads/images', express.static(path.join(homeDir, 'uploaded_images_by_user')));
app.use('/uploads/videos', express.static(path.join(homeDir, 'uploaded_vids_by_user')));

const PORT = 3000;

app.use(express.json());
app.use('/search', router);

// Nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.USER_EMAIL,
    pass: process.env.USER_PASSWORD,
  },
});

// Signup with email verification
app.post('/signup', async (req, res) => {
  try {
    const { first_name, last_name, email, password } = req.body;

    console.log('[Signup] Received signup request for email:', email);

    const usercheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (usercheck.rows.length > 0) {
      console.log('[Signup] User already exists:', email);
      return res.status(400).json({ error: 'User already exists with that email' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const verificationToken = crypto.randomBytes(32).toString('hex');

    const newuser = await pool.query(
      'INSERT INTO users (first_name, last_name, email, password_hash, verification_token, verified) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [first_name, last_name, email, hashedPassword, verificationToken, false]
    );

    // Use your actual domain or IP, consider making this configurable
    const verificationLink = `http://192.168.1.5:${PORT}/verify-email?token=${verificationToken}`;

    const mailOptions = {
      from: process.env.USER_EMAIL,
      to: email,
      subject: 'Please verify your email',
      html: `
        <p>Hi ${first_name},</p>
        <p>Thanks for registering! Please click the link below to verify your email:</p>
        <a href="${verificationLink}">${verificationLink}</a>
      `,
    };

    await transporter.sendMail(mailOptions);

    console.log('[Signup] User created and verification email sent:', email);

    return res.status(201).json({
      message: 'User created successfully. Please verify your email.',
      user: newuser.rows[0],
    });
  } catch (err) {
    console.error('[Signup] Error:', err.message);
    res.status(500).json({ error: 'Server error', details: err.message });
  }
});

// Email verification
app.get('/verify-email', async (req, res) => {
  try {
    const { token } = req.query;

    console.log('[Verify Email] Token received:', token);

    const userResult = await pool.query('SELECT * FROM users WHERE verification_token = $1', [token]);
    if (userResult.rows.length === 0) {
      console.log('[Verify Email] Invalid token:', token);
      return res.status(400).send('Invalid verification token');
    }

    await pool.query(
      'UPDATE users SET verified = $1, verification_token = $2 WHERE verification_token = $3',
      [true, null, token]
    );

    console.log('[Verify Email] Email verified for token:', token);

    res.send('Email verified successfully. You can now log in.');
  } catch (err) {
    console.error('[Verify Email] Error:', err.message);
    res.status(500).send('Server error');
  }
});

// Google Signin
app.post('/google_signin', async (req, res) => {
  try {
    const { first_name, last_name, email, google_id } = req.body;

    console.log('[Google Signin] Attempt:', email, google_id);

    if (!google_id || !email) {
      return res.status(400).json({ error: 'Missing google_id or email' });
    }

    const userbygoogleid = await pool.query('SELECT * FROM users WHERE google_id = $1', [google_id]);

    if (userbygoogleid.rows.length > 0) {
      console.log('[Google Signin] User found by google_id:', google_id);
      return res.status(200).json({ message: 'Login successful', user: userbygoogleid.rows[0] });
    }

    const userByEmail = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if (userByEmail.rows.length > 0) {
      console.log('[Google Signin] Email exists but google_id not linked:', email);
      return res.status(400).json({
        error: 'User already exists with this email. Please login using email and password.',
      });
    }

    const newUser = await pool.query(
      'INSERT INTO users (first_name, last_name, google_id, email, verified, create_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
      [first_name, last_name, google_id, email, true]
    );

    const user = newUser.rows[0];

    const payload = {
      userId: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    console.log('[Google Signin] New user created:', email);

    return res.status(201).json({ message: 'User created', token, user });
  } catch (err) {
    console.error('[Google Signin] Error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// Login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log('[Login] Attempt for email:', email);

    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      console.log('[Login] No user found:', email);
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const user = userResult.rows[0];

    if (!user.verified) {
      console.log('[Login] User email not verified:', email);
      return res.status(403).json({ error: 'Please verify your email before logging in' });
    }

    const ispassvalid = await bcrypt.compare(password, user.password_hash);
    if (!ispassvalid) {
      console.log('[Login] Invalid password attempt for:', email);
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const payload = {
      userId: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });

    console.log('[Login] Successful login:', email);

    return res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        create_at: user.create_at,
        profile_completed: user.profile_completed,
      },
    });
  } catch (err) {
    console.error('[Login] Error:', err.message);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Profile creation/update
app.post('/profilecreation', authenticationtoken, async (req, res) => {
  try {
    const { username, profile_picture_url, banner_url, bio } = req.body;
    const userId = req.user.userId;

    console.log('[Profile Creation] User ID:', userId, 'Username:', username);

    const usernamecheck = await pool.query('SELECT * FROM users WHERE username = $1 AND id != $2', [username, userId]);

    if (usernamecheck.rows.length > 0) {
      console.log('[Profile Creation] Username already taken:', username);
      return res.status(400).json({ error: 'Username already taken, please choose another one' });
    }

    const updateprofile = await pool.query(
      `UPDATE users SET username = $1, profile_completed = $2, bio = $3 WHERE id = $4 RETURNING *`,
      [username ,  true, bio, userId]
    );

    console.log('[Profile Creation] Profile updated for user:', userId);

    return res.status(200).json({
      message: 'Profile updated successfully',
      user: {
        username: updateprofile.rows[0].username,
        profile_picture_url: updateprofile.rows[0].profile_picture_url,
        banner_url: updateprofile.rows[0].banner_url,
        bio: updateprofile.rows[0].bio,
      },
    });
  } catch (err) {
    console.error('[Profile Creation] Error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// Upload profile & banner
app.post(
  '/upload/profile-banner',
  authenticationtoken,
  upload.fields([
    { name: 'profile_picture', maxCount: 1 },
    { name: 'banner', maxCount: 1 },
  ]),
  async (req, res) => {
    try {
      console.log('[Upload Profile-Banner] Incoming request');
      const files = req.files;
      const userId = req.user.userId;

      console.log('[Upload Profile-Banner] User ID:', userId);
      console.log('[Upload Profile-Banner] Files received:', files);
      if (!files || (Object.keys(files).length === 0)) {
        console.log('[Upload Profile-Banner] No images provided, skipping upload');
        return res.status(200).json({
          message: 'No files uploaded, skipping image update',
        });
      }


      const profilePictureFile = files.profile_picture ? files.profile_picture[0] : null;
      const bannerFile = files.banner ? files.banner[0] : null;

      const profilePicturePath = profilePictureFile ? `/uploads/pfp/${profilePictureFile.filename}` : null;
      const bannerPath = bannerFile ? `/uploads/banner/${bannerFile.filename}` : null;

      console.log('[Upload Profile-Banner] Profile Picture Path:', profilePicturePath);
      console.log('[Upload Profile-Banner] Banner Path:', bannerPath);

      // Update DB
      const result = await pool.query(
        `UPDATE users SET
          profile_picture_url = COALESCE($1, profile_picture_url),
          banner_url = COALESCE($2, banner_url)
        WHERE id = $3 RETURNING profile_picture_url, banner_url`,
        [profilePicturePath, bannerPath, userId]
      );

      console.log('[Upload Profile-Banner] DB update result:', result.rows[0]);

      return res.status(200).json({
        message: 'Upload successful',
        profile_picture_url: result.rows[0].profile_picture_url,
        banner_url: result.rows[0].banner_url,
      });
    } catch (err) {
      console.error('[Upload Profile-Banner] Error:', err);
      res.status(500).json({ error: 'Upload failed' });
    }
  }
);

// Create Tweet
app.post('/tweets/create', authenticationtoken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { content, location } = req.body;

    console.log('[Create Tweet] User ID:', userId, 'Content:', content);

    const result = await pool.query(
      'INSERT INTO tweets (user_id, content, created_at, location) VALUES ($1, $2, NOW(), $3) RETURNING id',
      [userId, content, location]
    );

    res.status(201).json({ message: 'Tweet created', tweetId: result.rows[0].id });
  } catch (err) {
    console.error('[Create Tweet] Error:', err);
    res.status(500).json({ error: 'Could not create tweet' });
  }
});

// Upload tweet media
app.post(
  '/upload/mediafiles',
  authenticationtoken,
  upload.array('mediafiles', 10),
  async (req, res) => {
    try {
      const files = req.files;
      const userId = req.user.userId;
      const { tweetId } = req.body;

      console.log('[Upload Tweet Media] User ID:', userId, 'Tweet ID:', tweetId);
      console.log('[Upload Tweet Media] Files:', files);

      if (!tweetId) {
        console.log('[Upload Tweet Media] tweetId missing');
        return res.status(400).json({ error: 'tweetId is required' });
      }

      if (!files || files.length === 0) {
        console.log('[Upload Tweet Media] No media files uploaded');
        return res.status(400).json({ error: 'No media files uploaded' });
      }

      const filePaths = files.map(file => file.path);

      // Assuming media_url is a text array or JSON column
      await pool.query(
        'UPDATE tweets SET media_url = $1 WHERE id = $2',
        [filePaths, tweetId]
      );

      res.status(200).json({
        message: 'Media files uploaded successfully',
        file_paths: filePaths,
      });
    } catch (err) {
      console.error('[Upload Tweet Media] Error:', err);
      res.status(500).json({ error: 'Upload failed' });
    }
  }
);

app.get('/getuserdetails', authenticationtoken, async (req, res) => {
  try {
    const userId = req.user.userId;

    console.log('[Get User Details] User ID:', userId);

    const userResult = await pool.query(
      'SELECT username, bio, profile_picture_url, banner_url FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      console.log('[Get User Details] User not found:', userId);
      return res.status(404).json({ error: 'User not found' });
    }

      // Fetch all tweets columns for the user
    const tweetsResult = await pool.query(
      `SELECT id, user_id, content, media_url, created_at, location 
       FROM tweets 
       WHERE user_id = $1 
       ORDER BY created_at DESC
       LIMIT 1
       `,
       
      [userId]
    );

    const userDetails = userResult.rows[0];

    console.log('[Get User Details] Retrieved:', userDetails);

    return res.status(200).json({ userDetails : userResult.rows[0] , tweetsResult : tweetsResult.rows[0] });
  } catch (err) {
    console.error('[Get User Details] Error:', err.message);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});
