const https = require("https");
const fs = require("fs");

async function downloadBotFile(file_id, token, downloadedfilepath) {
  try {
    const file_path = await getFileUrl(file_id, token);
    const downloaded_file_path = await downloadFile(
      file_path,
      token,
      downloadedfilepath
    );
    return downloaded_file_path;
  } catch (error) {
    console.error("Error downloading audio file:", error);
    return null;
  }
}

async function getFileUrl(file_id, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: "api.telegram.org",
      port: 443,
      path: `/bot${token}/getFile?file_id=${file_id}`,
      method: "GET",
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => {
        const file_path = JSON.parse(data).result.file_path;
        resolve(file_path);
      });
    });

    req.on("error", (error) => {
      reject(error);
    });

    req.end();
  });
}

async function downloadFile(file_path, token, downloaded_file_path) {
  return new Promise((resolve, reject) => {
    const url = `https://api.telegram.org/file/bot${token}/${file_path}`;
    const file = fs.createWriteStream(downloaded_file_path);

    https
      .get(url, (res) => {
        res.pipe(file);
        file.on("finish", () => {
          file.close(() => resolve(downloaded_file_path));
        });
      })
      .on("error", (error) => {
        fs.unlink(downloaded_file_path, () => reject(error));
      });
  });
}

module.exports = { downloadBotFile };
