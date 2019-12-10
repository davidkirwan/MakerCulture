# frozen_string_literal: true
require 'discordrb'
require 'time'
require 'fileutils'
require 'logger'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'makerculture'

puts ARGV.inspect
@discord_token = ARGV[0]
@gab_token = ARGV[1]
puts @discord_token
puts @gab_token
if @discord_token.nil? 
  puts "missing Discord API Token, call with: 'ruby makerculture.rb <DISCORD_API_TOKEN>'" 
  exit(0)
end
puts "Gab token not supplied (Optional)" if @gab_token.nil?

# This statement creates a bot with the specified token and application ID. After this line, you can add events to the
# created bot, and eventually run it.
#
# If you don't yet have a token to put in here, you will need to create a bot account here:
#   https://discordapp.com/developers/applications
# If you're wondering about what redirect URIs and RPC origins, you can ignore those for now. If that doesn't satisfy
# you, look here: https://github.com/meew0/discordrb/wiki/Redirect-URIs-and-RPC-origins
# After creating the bot, simply copy the token (*not* the OAuth2 secret) and put it into the
# respective place.
bot = Discordrb::Commands::CommandBot.new token: @discord_token, prefix: '!'
ADMINS = [268539077089951754]
@role_list = {}

# Configure the Mastodon client
GABGROUP = 23
unless @gab_token.nil?
  Makerculture::Mammoth.setup(@gab_token)
end


@logger = Logger.new(STDOUT)
#@logger = Logger.new('mc_event.log', 10, 1024000)
@logger.level = Logger::DEBUG


# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want
@logger.debug "This bot's invite URL is #{bot.invite_url}."
@logger.debug 'Click on it to invite it to your server.'


startup = Time.now
@logger.debug "Starting up at #{startup}"
# Determine how long ago the bot started running.
def relative_time(start_time)
  response = ""
  diff_seconds = Time.now - start_time
  case diff_seconds
    when 0 .. 59
      response = "#{diff_seconds} seconds ago"; @logger.debug response
    when 60 .. (3600-1)
      response = "#{diff_seconds/60} minutes ago"; @logger.debug response
    when 3600 .. (3600*24-1)
      response = "#{diff_seconds/3600} hours ago"; @logger.debug response
    when (3600*24) .. (3600*24*30) 
      response = "#{diff_seconds/(3600*24)} days ago"; @logger.debug response
    else
      response = start_time.strftime("%m/%d/%Y"); @logger.debug response
  end
  return response
end


# Here we can see the `help_available` property used, which can determine whether a command shows up in the default
# generated `help` command. It is true by default but it can be set to false to hide internal commands that only
# specific people can use.
bot.command(:exit, help_available: false) do |event|
  # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
  # able to shut your bot down whenever they wanted.
  @logger.debug "Command: exit"
  break unless ADMINS.include?(event.user.id)
  @logger.debug "Authorised user #{event.user.username}"
  bot.send_message(event.channel.id, 'Bot is shutting down')
  exit
end


# Here we can see the `help_available` property used, which can determine whether a command shows up in the default
# generated `help` command. It is true by default but it can be set to false to hide internal commands that only
# specific people can use.
bot.command(:uptime, description: "Prints the length of time that the bot has been running.", usage: "!uptime") do |event|
  # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
  # able to shut your bot down whenever they wanted.
  @logger.debug "Command: uptime"
  break unless ADMINS.include?(event.user.id)
  @logger.debug "Authorised user #{event.user.username}"
  event.respond("Bot started at #{startup}")
  event.respond("That was #{relative_time(startup)}")
end


# Ping/Pong
bot.command(:ping, description: "Ping the bot and have it respond with a Pong!", usage: "!ping") do |event|
  # The `respond` method returns a `Message` object, which is stored in a variable `m`. The `edit` method is then called
  # to edit the message with the time difference between when the event was received and after the message was sent.
  @logger.debug "event.user.id #{event.user.id}"
  m = event.respond('Pong!')
  m.edit "Pong! Time taken: #{Time.now - event.timestamp} seconds."
end


# Have the bot poke yourself, or others. eg: !poke / !poke <name>
bot.command(:poke, description: "The bot will poke the user specified as a parameter", usage: "!poke <user>") do |event, args|
  m = event.respond("Poke! #{args}")
end


# Print the invite URL for the bot
bot.command(:invite, description: "Print the bot invite URL", usage: "!invite", chain_usable: false) do |event|
  # This simply sends the bot's invite URL, without any specific permissions,
  # to the channel.
  event.bot.invite_url
end


# Print the Github/Codebase URL for the bot
bot.command(:github, description: "Print the URL to the bots codebase", usage: "!github", chain_usable: false) do |event|
  # This simply sends the bot's invite URL, without any specific permissions,
  # to the channel.
  event.respond("https://github.com/davidkirwan/MakerCulture")
end


# Print the list of roles which maybe applied to the caller. Each role can unlock a set of channels which the user is interested in.
bot.command(:list_roles, description: "List the available roles which can be applied to you", usage: "!list_roles") do |event|
  break unless ADMINS.include?(event.user.id)
  @logger.debug "Authorised user #{event.user.username}"
  unless event.channel.type == Discordrb::Channel::TYPES[:dm]
    roles = event.server.roles
    index = 1

    response = "```\n"
    roles.each do |i|
      role = i.name.gsub(/@/, "[at]")
      response +=  "#{index}: " + role + "\n"
      @role_list[role] = i 
      if index % 3 == 0 || index == roles.length
        sleep(1)
        response += "```"
        @logger.debug response
        event.respond(response)
        response = "```\n"
      end
      index += 1
    end
    break
    #response += "```"
    #@logger.debug response
    #event.respond(response) unless index % 3 == 0
  end
end


# Print the list of roles which maybe applied to the caller. Each role can unlock a set of channels which the user is interested in.
bot.command(:add_roles, description: "Add a role to the caller, or user specified by target", usage: "!add_roles <user> <role>") do |event|
  break unless ADMINS.include?(event.user.id)
  @logger.debug "Authorised user #{event.user.username}"
  unless event.channel.type == Discordrb::Channel::TYPES[:dm]
    response = ""
    content = event.message.content.split(" ")
    @logger.debug content
    @logger.debug event.message.content
    @logger.debug event.message.channel.name
    @logger.debug event.message.author.name
    response = "User: <@#{event.message.author.id}> wants to add role: #{content[2]} to: #{content[1]}"
    event.respond(response)

    role_exist = @role_list.keys.include?(content[2])
    @logger.debug @role_list.keys

    response = "Role #{content[2]} exists? #{role_exist}"
    event.respond(response)
  end
  break
end


# Print the version of the bot.
bot.command(:version, description: "Print the version of the Makerculture bot", usage: "!version") do |event|
  break unless ADMINS.include?(event.user.id)
  @logger.debug "Authorised user #{event.user.username}"

  event.respond("Makerculture Version: #{Makerculture::Version.to_s}")
end


bot.reaction_add do |event|
  @logger.debug "Discordrb::Events::ReactionAddEvent"
  #@logger.debug event.user.name
  #@logger.debug event.emoji.inspect
  #@logger.debug event.message
  #@logger.debug event.emoji.to_reaction

  if event.message.id == 571057326656585763 && event.emoji.name == "✅"
    @logger.debug "Adding role Maker to user: #{event.user.name}"
    role = event.server.roles.find {|r| r.name == "Maker"}
    event.user.add_role(role)
  end

  #event.respond "emoji add event #{event.emoji.mention}"
end

bot.reaction_remove do |event|
  @logger.debug "Discordrb::Events::ReactionRemoveEvent"
  #@logger.debug event.emoji.inspect
  #@logger.debug event.message
  #@logger.debug event.emoji.to_reaction

  # event.respond "emoji remove event #{event.emoji.mention}"
end


# Have the bot post the contents of your post to a gab group.
bot.command(:gab, description: "The bot will post the message to a gab group", usage: "!gab <msg>") do |event, args|
  break unless ADMINS.include?(event.user.id)
  @logger.debug "Authorised user #{event.user.username}"
  post = Makerculture::Mammoth.post(args, GABGROUP)
  m = event.respond("Post: #{post}")
end


# Logging
bot.message do |event|
  begin
    unless event.channel.type == Discordrb::Channel::TYPES[:dm]
      @logger.debug "event.server.id #{event.server.id}"
    end
    @logger.debug "event.channel.id #{event.channel.id}"
    @logger.debug "event.channel.type #{event.channel.type}"
    @logger.debug "event.user.id #{event.user.id}"
    @logger.debug "event.content #{event.content}"
  rescue Exception => e
    @logger.debug e.inspect
    @logger.debug event.inspect
  end

  if (event.content.include? "pizza" and event.content.include? "pineapple")
    event.respond "Pineapple is a perfectly reasonable topping for a pizza imo."
  end
end

@health = Thread.new do
  begin
    loop do
      sleep(15)
      if bot.connected?
	system("touch /tmp/healthy")
	@logger.debug "connected"
      else
	system("rm /tmp/healthy")
	raise Exception, "not connected"
      end
    end

  rescue Exception => e
    @logger.debug e.message
    @health.kill
    @health = nil
    exit
  end
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run


