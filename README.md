## README

This README outlines the steps required to set up and run the application, as well as how to create and deploy Telegram and Discord bots.

## Setup

# Ruby version

Ensure you have Ruby version 3.1.2 installed.

# Dependencies

Run `bundle install` to install all necessary dependencies.

# Database creation

Create the database by running:
`rails db:create`
`rails db:migrate`

- ...

# Creating a Telegram Bot

To create a Telegram bot, follow these steps:

- Go to telegram app
- Search @BotFather on Telegram.
- Type /start to get started.
- Type /newbot to get a bot.
- Enter your Bot name and unique Username, which should end with the bot.
- Then, you would get your Bot token.

# Creating a Discord Bot

To create a Discord bot, follow these steps:

- Make sure you're logged on to the Discord website.
- Navigate to the application page.
- Click on the “New Application” button.
- Give the application a name and click “Create”.
- Navigate to the “Bot” tab to configure it.
- Make sure that Public Bot is ticked if you want others to invite your bot.
- Reset token.
- Get the bot token.
- Navigate to the OAuth2.
- Check the bot option from OAuth2 URL Generator.
- Set the Bot permissions.
- Copy the url and paste it on new tab.
- Authorize the bot and add it to the server.

# Saving Bot Tokens

- Once you obtain the bot tokens from Telegram or Discord, save them in your database. (We can achieve this by Hitting the Api)

##OR 

- Open your terminal and run command `rails c`.
- Generate a Telegram token with the command `Telegram.create(token: "your telegram bot token")`.
- Generate a Discord token using the command `Discord.create(token: "your discord bot token")`.

# Running Telegram Bot

To run the Telegram bot:

- Start the rails server using `rails s`.
- Run the telegram bot with `node telegram.js`.
- Your Telegram bot is now active and ready for use.

# Running Discord Bot

To run the Discord bot:

- Start the rails server using `rails s`.
- Execute the Discord bot script with `bundle exec ruby discord.rb`.
- Your Discord bot is now running and accessible.

Feel free to test your bots and integrate them into your servers or applications accordingly. If you encounter any issues, refer to the respective documentation or seek assistance from the community.
