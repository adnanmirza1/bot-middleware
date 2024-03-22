const https = require("https");

function generateText(inputs, callback) {
  const data = JSON.stringify({
    inputs: inputs,
    parameters: {
      best_of: 1,
      decoder_input_details: true,
      details: false,
      stream: true,
      do_sample: true,
      max_new_tokens: 500,
      repetition_penalty: 1.15,
      return_full_text: false,
      seed: null,
      stop: ["USER:", "User:", "Human:"],
      temperature: 0.9,
      top_k: 10,
      top_p: 0.6,
      truncate: null,
      typical_p: 0.99,
      watermark: false,
    },
  });

  const options = {
    hostname: "ai.dev.moemate.io",
    port: 443,
    path: "/api/chat",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      webahost: "llm2.dev.moemate.io",
      WebaAuth: `Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsic3RyaXBlX2N1c3RvbWVyX2lkIjoiY3VzX1BsdEFmTEdmZHFDU1BiIiwic3ViX3N0YXR1cyI6InBybyIsInVzZXJuYW1lIjoiVGVzdCBEZXYifSwibmlja25hbWUiOiJ0ZXN0ZGV2MCIsIm5hbWUiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvOTViMTljNWI1ODBhOTVjNjk5YTQ2ODg3OWE4MmUwYTQ_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ0ZS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyNC0wMy0yMFQxODoxNjo0MS42ODZaIiwiZW1haWwiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzEwOTk3Nzc2LCJleHAiOjE3MTEwMzM3NzYsInN1YiI6ImF1dGgwfDY1Zjg3N2I5NWMyY2QxNGNmYmQzMDU1NyIsInNpZCI6Ii1SSW5aUnBUdlpuTWhaTk0zQlpaRG8zRjNCTGY2UTh6In0.SIjqQLKPmQt-BIzm3u2D-UWO9WVALOaV2Sl8mbmUHDxmnLRiN0e2FM62RJJb3CIgdjxDKXnSYOmchAvyujETbsd9-mNVdAjj3kZTnRfunPjdwN1zzdBBpG17mAfqHKEDeHSDxM5VIo2SP5dhP7qzbRDpyf-1vUs3lPNX8Qv7OXeeTrNsBJ9dmwRvqdLY9cNzZYfy0Y6y7iIs6re3_6axBWTSRv-VqvlbisQCHG2lXRNTiO0ozm8ehsYJX1mwyrksn2_5WbP92AB_PeAtpA2JePpNFBKmpyPXxEKN4mvspGQGtXQNzzpFXwcn3VAi1g_Tj0ndVvAGJJQ2QNi-jUrizg`,
      "Content-Length": data.length,
    },
  };

  const req = https.request(options, (res) => {
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
