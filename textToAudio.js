const https = require("https");
const fs = require("fs");

function convertTextToSpeech(text, callback) {
  const url = "https://azure.dev.moemate.io";
  const authToken =
    "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlMzLUstVWhieEtHYnExbF8tbEloMiJ9.eyJhcHBfbWV0YWRhdGEiOnsic3RyaXBlX2N1c3RvbWVyX2lkIjoiY3VzX1BsdEFmTEdmZHFDU1BiIiwic3ViX3N0YXR1cyI6InBybyIsInVzZXJuYW1lIjoiVGVzdCBEZXYifSwibmlja25hbWUiOiJ0ZXN0ZGV2MCIsIm5hbWUiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvOTViMTljNWI1ODBhOTVjNjk5YTQ2ODg3OWE4MmUwYTQ_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZ0ZS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyNC0wMy0yMFQxODoxNjo0MS42ODZaIiwiZW1haWwiOiJ0ZXN0ZGV2MEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImlzcyI6Imh0dHBzOi8vbW9lbWF0ZS1kZXYudXMuYXV0aDAuY29tLyIsImF1ZCI6IlIzOTBCNFNMdnA2OTRTWmN4T2NEYk1Pd3NFdDd0ZWJBIiwiaWF0IjoxNzEwOTk3Nzc2LCJleHAiOjE3MTEwMzM3NzYsInN1YiI6ImF1dGgwfDY1Zjg3N2I5NWMyY2QxNGNmYmQzMDU1NyIsInNpZCI6Ii1SSW5aUnBUdlpuTWhaTk0zQlpaRG8zRjNCTGY2UTh6In0.SIjqQLKPmQt-BIzm3u2D-UWO9WVALOaV2Sl8mbmUHDxmnLRiN0e2FM62RJJb3CIgdjxDKXnSYOmchAvyujETbsd9-mNVdAjj3kZTnRfunPjdwN1zzdBBpG17mAfqHKEDeHSDxM5VIo2SP5dhP7qzbRDpyf-1vUs3lPNX8Qv7OXeeTrNsBJ9dmwRvqdLY9cNzZYfy0Y6y7iIs6re3_6axBWTSRv-VqvlbisQCHG2lXRNTiO0ozm8ehsYJX1mwyrksn2_5WbP92AB_PeAtpA2JePpNFBKmpyPXxEKN4mvspGQGtXQNzzpFXwcn3VAi1g_Tj0ndVvAGJJQ2QNi-jUrizg";
  const outputFormat = "audio-48khz-192kbitrate-mono-mp3";

  const postData = `
    <speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="en-US">
      <voice name="en-US-JennyNeural">
        <mstts:viseme type="FacialExpression"/>
        <mstts:express-as style="assistant">
          <prosody rate="15%" pitch="15%">
            <lang xml:lang="en-US">${text}</lang>
          </prosody>
        </mstts:express-as>
      </voice>
    </speak>
  `;

  const options = {
    hostname: "azure.dev.moemate.io",
    path: "/",
    method: "POST",
    headers: {
      "Content-Type": "application/ssml+xml",
      WebaAuth: `Bearer ${authToken}`,
      "X-Microsoft-OutputFormat": outputFormat,
    },
  };

  const req = https.request(options, (res) => {
    const audioFilePath = `output_file_${Date.now()}.mp3`;
    const fileStream = fs.createWriteStream(audioFilePath);

    res.on("data", (chunk) => {
      fileStream.write(chunk);
    });

    res.on("end", () => {
      fileStream.end();
      console.log(`Audio file saved at: ${audioFilePath}`);
      callback(null, audioFilePath);
    });
  });

  req.on("error", (error) => {
    console.error("Error:", error);
    callback(error);
  });

  req.write(postData);
  req.end();
}

module.exports = { convertTextToSpeech };
