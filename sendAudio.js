const TelegramBot = require("node-telegram-bot-api");
const fs = require("fs");

// Replace 'YOUR_TELEGRAM_BOT_TOKEN' with your actual bot token
const bot = new TelegramBot("7003487106:AAGnw_CmEaVmaLvyyOUgl6KSJPu0vRppGP0", {
  polling: true,
});

// Function to send the downloaded audio file to the bot
function sendAudioToBot(filePath, chatId) {
  // Read the audio file from disk
  fs.readFile(filePath, (err, data) => {
    if (err) {
      console.error("Error reading file:", err);
      return;
    }

    // Send the audio file as a voice message
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

// Example usage
const filePath = "output.mp3"; // Replace with the actual file path
const chatId = "5747052391"; // Replace with the chat ID where you want to send the audio
sendAudioToBot(filePath, chatId);
