import std/asyncdispatch
import std/options
import std/os
import std/strformat
import std/unicode
import dimscmd
import dimscord
import dimscord

const debug = not defined(release)
const tokenVarName = "ESREVER_TOKEN"

const defaultGuild =
  when debug:
    "504993749013889025"
  else:
    ""

# determine if token is embedded in executable (which it is when compiling in
# debug) or if token should be retrieved via environmental variable
const tokenOpt =
  when debug:
    some slurp("../token.txt").strip
  else:
    none string

let token =
  if tokenOpt.isSome:
    tokenOpt.get
  else:
    if existsEnv(tokenVarName):
      getEnv(tokenVarName)
    else:
      quit "No token specified."

let discord = newDiscordClient(token)
var cmd = discord.newHandler()

proc onReady(s: Shard, r: Ready) {.event(discord).} =
  await cmd.registerCommands()
  echo "bot is ready"

proc interactionCreate(s: Shard, i: Interaction) {.event(discord).} =
  discard await cmd.handleInteraction(s, i)

cmd.addSlash("reverse", guildId = defaultGuild) do (message: string):
  ## Reverse your message
  let response = InteractionResponse(
    kind: irtChannelMessageWithSource,
    data: some InteractionApplicationCommandCallbackData(
      content: message.reversed
    )
  )

  await discord.api.createInteractionResponse(i.id, i.token, response)

cmd.addSlash("pester", guildId = defaultGuild) do (victim: User, message: string):
  ## Reverse your message
  let response = InteractionResponse(
    kind: irtChannelMessageWithSource,
    data: some InteractionApplicationCommandCallbackData(
      content: &"<@{victim.id}>\n{message.reversed}"
    )
  )

  await discord.api.createInteractionResponse(i.id, i.token, response)

cmd.addSlash("whisper", guildId = defaultGuild) do (message: string):
  ## Whispers your message to you in reverse
  let response = InteractionResponse(
    kind: irtChannelMessageWithSource,
    data: some InteractionApplicationCommandCallbackData(
      content: message.reversed,
      flags: {mfEphemeral}
    )
  )

  await discord.api.createInteractionResponse(i.id, i.token, response)

cmd.addSlash("invite", guildId = defaultGuild) do ():
  ## Get invite link for bot
  let response = InteractionResponse(
    kind: irtChannelMessageWithSource,
    data: some InteractionApplicationCommandCallbackData(
      content: "https://discord.com/api/oauth2/authorize?client_id=1019601581722841250&permissions=2147483648&scope=bot",
      flags: {mfEphemeral}
    )
  )

  await discord.api.createInteractionResponse(i.id, i.token, response)

cmd.addSlash("source", guildId = defaultGuild) do ():
  ## Get source code of the bot
  let response = InteractionResponse(
    kind: irtChannelMessageWithSource,
    data: some InteractionApplicationCommandCallbackData(
      content: "https://github.com/RainbowAsteroids/esrever",
      flags: {mfEphemeral}
    )
  )

  await discord.api.createInteractionResponse(i.id, i.token, response)

waitFor discord.startSession(gateway_intents = {giGuilds})
