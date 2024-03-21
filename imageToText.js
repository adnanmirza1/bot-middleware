// const axios = require("axios/dist/node/axios.cjs");
const FormData = require("form-data");
const fs = require("fs");

async function getImageTags(imagePath) {
  const url = "http://alb-beta.dev.moemate.io/ram";
  const modelId = "ram";

  try {
    const formData = new FormData();
    formData.append("img", fs.createReadStream(imagePath));

    const response = await axios.post(url, formData, {
      headers: {
        model_id: modelId,
        ...formData.getHeaders(),
      },
    });

    return response.data.tags;
  } catch (error) {
    throw new Error(error.response ? error.response.data : error.message);
  }
}

module.exports = getImageTags;
