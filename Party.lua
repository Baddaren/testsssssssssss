
UI.Separator()
UI.Label("Party Panel")

local partyPanelUI = setupUI([[
Panel
  height: 42

  BotSwitch
    id: JoinButtonState
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: next.left
    height: 17
    margin-right: 1
    text: Auto Join

  BotButton
    id: SayInviteButton
    anchors.top: parent.top
    anchors.right: next.left
    margin-right: 1
    size: 40 17
    text: Invite

  BotButton
    id: LeavePartyButton
    anchors.top: parent.top
    anchors.right: parent.right
    size: 40 17
    margin-left: 1
    color: red
    text: Leave

  BotSwitch
    id: PartyLeaderButtonState
    anchors.top: prev.bottom
    anchors.left: parent.left
    margin-top: 3
    size: 96 17
    text: Party Leader

  BotSwitch
    id: AutoInviteMc
    anchors.top: prev.top
    anchors.left: prev.right
    margin-top: 0
    size: 80 17
    text: Invite MC

]], parent)

local panelName = "PartyPanel"
if not storage[panelName] then
  storage[panelName] = {
    partyJoinerEnabled = false,
    partyLeaderEnabled = false,
    autoInviteMcEnabled = false,
  }
end
if not storage[panelName].partyJoinerEnabled then
  storage[panelName].partyJoinerEnabled = false
end
if not storage[panelName].partyLeaderEnabled then
  storage[panelName].partyLeaderEnabled = false
end
if not storage[panelName].autoInviteMcEnabled then
  storage[panelName].autoInviteMcEnabled = false
end

local config = storage[panelName]
local joinButtonState = partyPanelUI.JoinButtonState
local partyLeaderButtonState = partyPanelUI.PartyLeaderButtonState
local autoInviteMc = partyPanelUI.AutoInviteMc

-- Talk modes (client-side MessageMode enum) we listen to for "invite"
local TALK_MODES = {
  [1] = true, -- say
  [2] = true, -- whisper
  [3] = true, -- yell
  [4] = true, -- private message from
}

local SHIELD_WHITEBLUE = 2 -- party shield: I already invited that player

local INVITE_COOLDOWN = 3000 -- ms before the same player can trigger a new invite

-- These globals come from other scripts on some setups; don't crash if they are missing
local function isEnemy(name)
  if type(IsEnemy) == "function" then
    return IsEnemy(name)
  end
  return false
end

local function getServerMembers()
  if type(ServerMembers) == "table" then
    return ServerMembers
  end
  return {}
end

local function trim(str)
  return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- getPlayerByName can be case sensitive / missing on older clients, so fall back to scanning the screen
local function findPlayer(name)
  if not name or name == "" then return nil end

  if getPlayerByName then
    local found = getPlayerByName(name)
    if found then return found end
  end

  local lowerName = name:lower()
  for _, spec in ipairs(getSpectators()) do
    if spec:isPlayer() and spec:getName():lower() == lowerName then
      return spec
    end
  end
  return nil
end

-- You can only send invites when you're not in a party, or when you lead it
local function canInvite()
  return player:isPartyLeader() or not player:isPartyMember()
end

local lastInvite = {}
local function tryInvite(name)
  if not canInvite() then return end
  if name:lower() == player:getName():lower() then return end
  if isEnemy(name) then return end

  local target = findPlayer(name)
  if not target then return end

  -- Already in a party, or already has a pending invite from us
  if target:isPartyMember() or target:getShield() == SHIELD_WHITEBLUE then return end

  local key = name:lower()
  if lastInvite[key] and now - lastInvite[key] < INVITE_COOLDOWN then return end
  lastInvite[key] = now

  g_game.partyInvite(target:getId())
end

joinButtonState:setOn(config.partyJoinerEnabled)
joinButtonState.onClick = function(widget)
  if partyLeaderButtonState:isOn() then
    partyLeaderButtonState:setOn(false)
    config.partyLeaderEnabled = false
  end
  config.partyJoinerEnabled = not config.partyJoinerEnabled
  widget:setOn(config.partyJoinerEnabled)
end

partyLeaderButtonState:setOn(config.partyLeaderEnabled)
partyLeaderButtonState.onClick = function(widget)
  if joinButtonState:isOn() then
    joinButtonState:setOn(false)
    config.partyJoinerEnabled = false
  end
  config.partyLeaderEnabled = not config.partyLeaderEnabled
  widget:setOn(config.partyLeaderEnabled)
end

autoInviteMc:setOn(config.autoInviteMcEnabled)
autoInviteMc.onClick = function(widget)
  config.autoInviteMcEnabled = not config.autoInviteMcEnabled
  widget:setOn(config.autoInviteMcEnabled)
end

partyPanelUI.SayInviteButton.onClick = function(widget)
  if joinButtonState:isOn() then
    say("invite")
  end
end

partyPanelUI.LeavePartyButton.onClick = function(widget)
  g_game.partyLeave()
end

-- Auto join: 8.0 servers send "Name has invited you to his/her party." with a
-- different message mode than newer clients, so match on the text only
onTextMessage(function(mode, text)
  if not joinButtonState:isOn() then return end

  local inviterName = text:match("^(.-) has invited you")
  if not inviterName then return end

  local inviter = findPlayer(trim(inviterName))
  if inviter then
    g_game.partyJoin(inviter:getId())
  end
end)

local askTime = 0
onTalk(function(name, level, mode, text, channelId, pos)
  if not TALK_MODES[mode] or name == player:getName() then return end

  local message = trim(text):lower()

  if partyLeaderButtonState:isOn() then
    if message == "invite" then
      tryInvite(name)
    end
  elseif joinButtonState:isOn() then
    local members = getServerMembers()
    if table.find(members, name) and now - askTime > 5000 and message:find("invite") then
      say("invite")
      askTime = now
    end
  end
end)

onPlayerPositionChange(function(newPos, oldPos)
  if not config.autoInviteMcEnabled or not isInPz() then return end

  for _, name in ipairs(getServerMembers()) do
    tryInvite(name)
  end
end)
