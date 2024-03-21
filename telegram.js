const TelegramBot = require("node-telegram-bot-api");
const { generateText } = require("./api");
const { uploadAudioFile } = require("./audioApi");
const { downloadBotFile } = require("./downloadBotFile.js");
const { convertTextToSpeech } = require("./textToAudio");
const textToImage = require("./textToImage");
const getImageTags = require("./imageToText");
const http = require("http");
const fs = require("fs");

const options = {
  hostname: "localhost",
  port: 3000,
  path: "/get_tokens",
  method: "GET",
};

const req = http.request(options, (res) => {
  let data = "";

  res.on("data", (chunk) => {
    data += chunk;
  });

  res.on("end", () => {
    const tokens = JSON.parse(data);
    const bots = [];

    tokens.forEach((token) => {
      const bot = new TelegramBot(token, { polling: true });
      bots.push(bot);
    });

    bots.forEach((bot) => {
      bot.on("message", (msg) => {
        handleMessage(msg, bot);
      });

      bot.on("photo", (msg) => {
        handlePhoto(msg, bot);
      });

      bot.on("voice", (msg) => {
        handleVoice(msg, bot);
      });
    });

    console.log("Bot is running...");
  });
});

req.on("error", (error) => {
  console.error(error);
});

req.end();

function handleMessage(msg, bot) {
  const chatId = msg.chat.id;
  if (msg.text) {
    generateText(msg.text, (error, response) => {
      if (error) {
        console.error("Failed to generate text:", error);
        bot.sendMessage(chatId, "Failed to generate text: " + error);
        return;
      } else {
        console.log("Generated text:", response);
        bot.sendMessage(chatId, "I received your message: " + response);
      }
    });
  }
}

async function handlePhoto(msg, bot) {
  const token = bot.token;
  const chatId = msg.chat.id;
  const photoFileId = msg.photo[0].file_id;
  const downloaded_file_path = `image_file_${Date.now()}.png`;
  await downloadBotFile(photoFileId, token, downloaded_file_path)
    .then((downloadedFilePath) => {
      if (downloadedFilePath) {
        getImageTags(downloadedFilePath)
          .then((tags) => {
            textToImage(tags).then((imagePath) => {
              fs.readFile(imagePath, (err, data) => {
                if (err) {
                  console.error("Error reading file:", err);
                  return;
                }
                bot
                  .sendPhoto(chatId, data)
                  .then(() => {
                    console.log("Image sent successfully to bot.");
                  })
                  .catch((error) => {
                    console.error("Failed to send image:", error);
                  });
              });
            });
          })
          .catch((error) => {
            console.error("Error:", error);
          });
      } else {
        console.log("Failed to download file.");
      }
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

async function handleVoice(msg, bot) {
  const token = bot.token;
  const chatId = msg.chat.id;
  const voiceId = msg.voice.file_id;
  const downloaded_file_path = `audio_file_${Date.now()}.ogg`;
  if (msg.voice) {
    await downloadBotFile(voiceId, token, downloaded_file_path)
      .then((downloadedFilePath) => {
        if (downloadedFilePath) {
          uploadAudioFile(downloadedFilePath)
            .then((responseData) => {
              generateText(responseData, (error, text) => {
                if (error) {
                  console.error("Failed to generate text:", error);
                  bot.sendMessage(chatId, "Failed to generate text: " + error);
                  return;
                } else {
                  convertTextToSpeech(text, (error, filePath) => {
                    if (error) {
                      console.error("Failed to convert text to speech:", error);
                    } else {
                      fs.readFile(filePath, (err, data) => {
                        if (err) {
                          console.error("Error reading file:", err);
                          return;
                        }
                        bot
                          .sendVoice(chatId, data)
                          .then(() => {
                            console.log("Audio file sent successfully to bot.");
                          })
                          .catch((error) => {
                            console.error("Failed to send audio file:", error);
                          });
                      });
                    }
                  });
                }
              });
            })
            .catch((error) => {
              console.error("Error:", error);
            });
        } else {
          console.log("Failed to download audio file.");
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
