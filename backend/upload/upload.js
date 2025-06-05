const multer = require('multer');
const path = require('path');
const os = require('os');

const homeDir = os.homedir();
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    try {
      if (file.fieldname === 'profile_picture') {
        cb(null, path.join(homeDir, 'uploaded_pfp_by_user'));
      } else if (file.fieldname === 'banner') {
        cb(null, path.join(homeDir, 'uploaded_banner_by_user'));
      } else if (file.fieldname === 'mediafiles') {
        if (file.mimetype.startsWith('image/')) {
          cb(null, path.join(homeDir, 'uploaded_images_by_user'));
        } else if (file.mimetype.startsWith('video/')) {
          cb(null, path.join(homeDir, 'uploaded_vids_by_user'));
        } else {
          cb(null, path.join(homeDir, 'uploaded_othes'));
        }
      } else {
        cb(null, path.join(homeDir, 'uploaded_othes'));
      }
    } catch (err) {
      cb(err);
    }
  },
  filename: function (req, file, cb) {
    try {
      const ext = path.extname(file.originalname);
      const userId = req.user && req.user.userId ? req.user.userId : 'unknown'; 
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
      cb(null, `${file.fieldname}-${userId}-${uniqueSuffix}${ext}`);
    } catch (err) {
      cb(err);
    }
  }
});

module.exports = { storage };
