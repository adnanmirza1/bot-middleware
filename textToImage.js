// const axios = require("axios/dist/node/axios.cjs");
const fs = require("fs");

async function textToImage(prompt) {
  const payload = {
    model_id: "sd_xl_turbo_1.0_fp16.safetensors [e869ac7d69]",
    prompt: prompt,
    width: "512",
    height: "512",
    samples: "1",
    num_inference_steps: "1",
    safety_checker: "no",
    enhance_prompt: "no",
    seed: null,
    guidance_scale: "1",
    multi_lingual: "no",
    panorama: "no",
    self_attention: "no",
    upscale: "no",
    embeddings_model: null,
    lora_model: "",
    tomesd: "yes",
    clip_skip: 2,
    use_karras_sigmas: "yes",
    vae: null,
    lora_strength: 1,
    scheduler: "DPM++ 2M Karras",
    sampler: "Euler a",
    webhook: null,
    track_id: null,
  };

  try {
    const response = await axios.post(
      "http://alb-beta.dev.moemate.io/text2image",
      payload,
      {
        headers: {
          "Content-Type": "application/json",
        },
      }
    );
    const imageData = response.data.images[0];
    const imageBuffer = Buffer.from(imageData, "base64");
    const fileName = `output_image_${Date.now()}.png`;
    const imagePath = `./${fileName}`;
    fs.writeFileSync(imagePath, imageBuffer, { encoding: "base64" });
    console.log("Image saved successfully!");
    return imagePath;
  } catch (error) {
    console.error("Error:", error);
    return null;
  }
}

module.exports = textToImage;
