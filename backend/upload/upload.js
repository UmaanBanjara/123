    const path = require('path');
    const multer = require('multer');

    // Storage configuration with error handling
    const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        try {
        if (file.fieldname === 'profile_picture') {
            cb(null, path.join(__dirname, 'uploaded_pfp_by_user'));
        } else if (file.fieldname === 'banner') {
            cb(null, path.join(__dirname, 'uploaded_banner_by_user'));
        } else if (file.fieldname === 'mediafiles') {
            if (file.mimetype.startsWith('image/')) {
            cb(null, path.join(__dirname, 'uploaded_images_by_user'));
            } else if (file.mimetype.startsWith('video/')) {
            cb(null, path.join(__dirname, 'uploaded_vids_by_user'));
            } else {
            cb(null, path.join(__dirname, 'uploads/others'));
            }
        } else {
            cb(null, path.join(__dirname, 'uploads/others'));
        }
        } catch (err) {
        cb(err);  // Pass any unexpected error to multer
        }
    },

    filename: function (req, file, cb) {
        try {
        const ext = path.extname(file.originalname);
        const uniquesuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, file.fieldname + '-' + uniquesuffix + ext);
        } catch (err) {
        cb(err);
        }
    }
    });


module.exports = { storage };