const fs = require('fs');
const path = require('path');
const os = require('os');

const homeDir = os.homedir();

const dirs = {
  profile_pictures: path.join(homeDir, 'uploaded_pfp_by_user'),
  banners: path.join(homeDir, 'uploaded_banner_by_user'),
  images: path.join(homeDir, 'uploaded_images_by_user'),
  videos: path.join(homeDir, 'uploaded_vids_by_user'),
  others: path.join(homeDir, 'uploaded_othes'),
};

async function deleteUserFiles(userId) {
  try {
    for (const dirPath of Object.values(dirs)) {
      const files = await fs.promises.readdir(dirPath);

      const userFiles = files.filter(filename => filename.includes(`-${userId}-`));

      for (const file of userFiles) {
        const filePath = path.join(dirPath, file);
        await fs.promises.unlink(filePath);
        console.log(`[Deleted] ${filePath}`);
      }
    }

    console.log(`[Success] All files for user ${userId} deleted.`);
  } catch (err) {
    console.error(`[Error] Deleting user files:`, err);
    throw err;
  }
}

module.exports = deleteUserFiles;
