const http = require("http");

function generateText(inputs, callback) {
  const data = JSON.stringify({
    inputs: inputs,
    parameters: {
      best_of: 1,
      decoder_input_details: true,
      details: false,
      stream: false,
      do_sample: true,
      max_new_tokens: 500,
      repetition_penalty: 1.15,
      return_full_text: false,
      seed: null,
      stop: [],
      temperature: 0.9,
      top_k: 10,
      top_p: 0.6,
      truncate: null,
      typical_p: 0.99,
      watermark: false,
    },
  });

  const options = {
    hostname: "alb-beta.dev.moemate.io",
    port: 80, // Assuming HTTP
    path: "/generate",
    method: "POST",
    headers: {
      Host: "llm7",
      "Content-Type": "application/json",
      "Content-Length": data.length,
      model_id: "llm7",
    },
  };

  const req = http.request(options, (res) => {
    let responseData = "";

    res.on("data", (chunk) => {
      responseData += chunk;
    });

    res.on("end", () => {
      try {
        const responseObject = JSON.parse(responseData);
        const generatedText = responseObject["generated_text"];
        console.log("response: " + generatedText);
        callback(null, generatedText);
      } catch (error) {
        console.error("error parsing response: " + error);
        callback(error, null);
      }
    });
  });

  req.on("error", (error) => {
    console.error("error: " + error);
    callback(error, null);
  });
  req.write(data);
  req.end();
}

module.exports = { generateText };
