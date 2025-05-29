const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('./db');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const authenticationtoken = require('./authenticatetoken');
const cloudinary = require('./cloudinary/cloudinary');
const multer = require('multer');
const streamifier = require('streamifier');


const storage = multer.memoryStorage(); //tells multer to store data in buffer(buffer vaneko temp storage jun RAM ma huncha)
const upload = multer({storage}); // yo line le multer lai buffer ma store gar vhancha




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
    res.status(500).json({ error: 'Server error', details: err.message });
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

app.post('/google_signin',  async (req, res) => {
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

    const user = newUser.rows[0];

    //generate jwt token for the user 

    const payload = {
      userId : user.id,
      email : user.email,
      firstName : user.first_name,
      lastName : user.last_name,
    };  

    const token = jwt.sign(payload , process.env.JWT_secret , {expiresIn : '1h'});

    return res.status(201).json({ message: 'User created', token , user});
  } catch (err) {
    console.error('Google signin error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/login', async (req, res) => {
  const JWT_secret = process.env.JWT_secret;

  try {
    const { email, password } = req.body;

    // Check if user exists by email
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const user = userResult.rows[0];

    if (!user.verified) {
      return res.status(403).json({ error: 'Please verify your email before logging in' });
    }

    // Compare password with password_hash
    const ispassvalid = await bcrypt.compare(password, user.password_hash);
    if (!ispassvalid) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    // Create a JWT payload, payload is data to check integrity
    const payload = {
      userId: user.id,
      email: user.email,
      firstName: user.first_name,
      lastname: user.last_name,
    };

    const token = jwt.sign(payload, JWT_secret, { expiresIn: '1h' });

    // Successfully login 
    return res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        // exclude password_hash and tokens here for security
      },
    });
  } catch (err) {
    console.error('Login error:', err.message);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/profilecreation', authenticationtoken , async(req , res) =>{

try{
   const { username, profile_picture_url, banner_url } = req.body;

   const userId = req.user.userId;

   //check if usernaem already exits


   const usernamecheck = await pool.query('SELECT * FROM users WHERE username = $1 AND id != $2' , [username , userId]);

   if(usernamecheck.rows.length>0){
    return res.status(400).json({error : 'Username already taken , Please choose another one'});
   }

   //update the user with the new profile info

   const updateprofile = await pool.query('UPDATE users SET username = $1, profile_picture_url = $2, banner_url = $3 WHERE id = $4 RETURNING *',[username , profile_picture_url , banner_url , userId]);

   return res.status(200).json({
    message : 'Profile Updated successfully',
    user : updateprofile.rows[0],
   });
}

catch (err){
  console.error('Profile creation error : ',err.message);
  res.status(500).json({error : 'Server Error'});
}

});




app.post('/uploadfiles', upload.fields([{name : 'profile_picture' , maxCount : 1} , {name : 'banner' , maxCount : 1 }]) , async(req , res) => {

//  maxcount : 1 , vaneko except 1 file from each propery 

//req.files vaneko ui le pathako files server ma
  const profilePictureFile = req.files?.['profile_picture']?.[0];
  const bannerFile = req.files?.['banner']?.[0];


  // FIXED: added missing arrow =>
  const uploadtocloudinary = (fileBuffer , folder) => {
    return new Promise((resolve , reject) => {
      //create an upload stream to cloudinary 

        const stream = cloudinary.uploader.upload_stream(

          {},
          (error , result) => {

            if(error) return reject(error);
            resolve(result.url);
          }


        );

      streamifier.createReadStream(fileBuffer).pipe(stream);


    });


  };

  try{

    let profileUrl , bannerUrl;

    if(profilePictureFile){
      profileUrl = await uploadtocloudinary(profilePictureFile.buffer , 'profile_pictures'); 
    }

    if(bannerFile){
      bannerUrl = await uploadtocloudinary(bannerFile.buffer , 'banners');
    }

    res.status(200).json({
      message : 'Files uploaded successfully',
      profile_picture_url : profileUrl || null ,
      banner_url : bannerUrl || null,
    });

  }
  catch(err){
    // FIXED: Changed error to err
    console.error(err);
    res.status(500).json({error : 'Upload Failed' , details : err.message});
  }


});
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});




//what the fuck is thsi shit nigg