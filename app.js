const TelegramBot = require("node-telegram-bot-api");
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

    bots.forEach((bot, index) => {
      bot.onText(/\/start/, (msg) => {
        const chatId = msg.chat.id;
        bot.sendMessage(chatId, `Hello! I am bot ${index}.`);
      });

      bot.onText(/\/hello/, (msg) => {
        const chatId = msg.chat.id;
        bot.sendMessage(chatId, "Hello there!");
      });

      bot.on("message", (msg) => {
        const chatId = msg.chat.id;
        bot.sendMessage(chatId, "I received your message: " + msg.text);
      });
    });
    console.log("Bot is running...");
  });
});

req.on("error", (error) => {
  console.error(error);
});

req.end();
