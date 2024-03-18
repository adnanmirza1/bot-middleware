const TelegramBot = require("node-telegram-bot-api");
const { generateText } = require("./api");
const http = require("http");

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

function handlePhoto(msg, bot) {
  const chatId = msg.chat.id;
  const photoFileId = msg.photo[0].file_id;
  bot
    .getFile(photoFileId)
    .then((photoInfo) => {
      const photoUrl = `https://api.telegram.org/file/bot${`6819618027:AAHV1_iRyeuNG9nDOT87mD7ZP_9PxfULTio`}/${
        photoInfo.file_path
      }`;

      // Pass the photo URL to generate text
      generateText(photoUrl, (error, response) => {
        if (error) {
          console.error("Failed to generate text:", error);
          bot.sendMessage(chatId, "Failed to generate text: " + error);
        } else {
          bot
            .sendPhoto(chatId, photoFileId, { caption: response })
            .then(() => console.log("Photo sent successfully"))
            .catch((error) => console.error("Failed to send photo:", error));
        }
      });
    })
    .catch((error) => {
      console.error("Failed to get photo info:", error);
      bot.sendMessage(chatId, "Failed to get photo info: " + error);
    });
}

function handleVoice(msg, bot) {
  const chatId = msg.chat.id;
  const voiceId = msg.voice.file_id;
  console.log(msg.voice);
  if (msg.voice) {
    generateText(msg.voice.file_id, (error, response) => {
      if (error) {
        console.error("Failed to generate text:", error);
        bot.sendMessage(chatId, "Failed to generate text: " + error);
        return;
      } else {
        console.log("Generated text:", response);
        bot
          .sendVoice(chatId, response, { caption: "I received your message: " })
          .then(() => console.log("Voice message sent successfully"))
          .catch((error) =>
            console.error("Failed to send voice message:", error)
          );
      }
    });
  }
  // bot
  //   .sendVoice(chatId, voiceId, { caption: "I received your voice message!" })
  //   .then(() => console.log("Voice message sent successfully"))
  //   .catch((error) => console.error("Failed to send voice message:", error));
}
