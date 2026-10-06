addSeparator("separator")
addLabel("", "Ultimate Follow")
addSeparator("separator")

-- ============================================================================
-- ULTIMATE PING FOLLOW
-- Configuration and persistent state
-- ============================================================================

local panelName = "uFollowMacro"

if not storage[panelName] or not storage[panelName].list then
  storage[panelName] = {
    enabled = false,
    list = {},
    userSettings = {
      speed = 0,
      chestSpeed = 0,
      pzSpeed = 0,
      slowdownDistance = 0,
      slowdownDistancePz = 0,
      useMachete = true,
      useMacheteInPz = false,
      useHotcon = false,
      usehottxt = "",
    },
  }
end

local config = storage[panelName]


-- Use one normalized key format for all saved player states.
local function followNameKey(name)
  return type(name) == "string" and name:lower() or ""
end

-- Keep names and enabled state separate. This preserves the old list format
-- while allowing individual names to be temporarily disabled.
if type(config.activeNames) ~= "table" then
  config.activeNames = {}
  for _, name in ipairs(config.list or {}) do
    config.activeNames[followNameKey(name)] = true
  end
end

local function isFollowNameEnabled(name)
  return config.activeNames[followNameKey(name)] ~= false
end

-- The active list is rebuilt only after a list or checkbox change.
local activeFollowerListCache
local activeFollowerRevision = 0

local function invalidateActiveFollowerCache()
  activeFollowerListCache = nil
  activeFollowerRevision = activeFollowerRevision + 1
end

local function setFollowNameEnabled(name, enabled)
  local key = followNameKey(name)
  local newState = enabled == true
  if config.activeNames[key] ~= newState then
    config.activeNames[key] = newState
    invalidateActiveFollowerCache()
  end
end

local function getActiveFollowerList()
  if activeFollowerListCache then
    return activeFollowerListCache
  end

  local active = {}
  for _, name in ipairs(config.list or {}) do
    if isFollowNameEnabled(name) then
      table.insert(active, name)
    end
  end
  activeFollowerListCache = active
  return activeFollowerListCache
end

if type(config.userSettings) ~= "table" then
  config.userSettings = {
    speed = 0,
    chestSpeed = 0,
    pzSpeed = 0,
    slowdownDistance = 0,
    slowdownDistancePz = 0,
    useMachete = true,
    useMacheteInPz = false,
    useHotcon = false,
    usehottxt = "",
  }
end

-- Migrate text settings saved by older versions at the config root.
for _, key in ipairs({"usehottxt"}) do
  if (config.userSettings[key] == nil or config.userSettings[key] == "") and config[key] then
    config.userSettings[key] = config[key]
  end
end

local version = "1.1.0.0"

-- ============================================================================
-- STATUS OVERLAY
-- ============================================================================

local comboVersion = setupUI([[
Label
  id: lblComboVersion
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 280
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Combo initialised.')
]], modules.game_interface.getMapPanel())-- config

comboVersion:setText("Ultimate Follow version " .. version)

local topFollower = {}
topFollower[1] = setupUI([[
Label
  id: top1Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 320
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #1 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[2] = setupUI([[
Label
  id: top2Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 340
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #2 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[3] = setupUI([[
Label
  id: top3Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 360
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #3 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[4] = setupUI([[
Label
  id: top4Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 380
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #4 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[5] = setupUI([[
Label
  id: top5Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 400
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #5 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[6] = setupUI([[
Label
  id: top6Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 420
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #6 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[7] = setupUI([[
Label
  id: top7Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 440
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #7 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[8] = setupUI([[
Label
  id: top8Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 460
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #8 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[9] = setupUI([[
Label
  id: top9Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 480
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #9 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[10] = setupUI([[
Label
  id: top10Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 500
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #10 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[11] = setupUI([[
Label
  id: top11Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 520
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #11 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[12] = setupUI([[
Label
  id: top12Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 540
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #12 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[13] = setupUI([[
Label
  id: top13Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 560
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #13 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[14] = setupUI([[
Label
  id: top14Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 580
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #14 leader: ')
]], modules.game_interface.getMapPanel())

topFollower[15] = setupUI([[
Label
  id: top15Leader
  color: #62e889
  height: 26
  width: 26
  anchors.top: parent.top
  anchors.right: parent.right
  margin-left: 2
  margin-bottom: 12
  margin-top: 600
  font: verdana-11px-rounded
  background-color: #00000000
  opacity: 1.0
  text-horizontal-auto-resize: true
  text-auto-resize: true
  text-align: center
  !text: tr('Top #15 leader: ')
]], modules.game_interface.getMapPanel())

-- Match the Ultimate Combo overlay styling explicitly. Some client themes can
-- override colors declared only inside setupUI.
comboVersion:setColor("#62e889")
comboVersion:setBackgroundColor("#00000000")
comboVersion:setOpacity(1.0)

-- Keep empty ranking rows completely hidden until a listed player is visible.
for _, followerLabel in ipairs(topFollower) do
  followerLabel:setColor("#62e889")
  followerLabel:setBackgroundColor("#00000000")
  followerLabel:setOpacity(1.0)
  followerLabel:setVisible(false)
end

-- ============================================================================
-- FOLLOW WINDOW
-- ============================================================================

local ui = setupUI([[
FollowEntry < Panel
  focusable: true
  height: 17
  background-color: #00000000

  $focus:
    background-color: #ffffff18

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    size: 14 14
    margin-left: 1

    $checked:
      image-color: #54aed1

    $!checked:
      image-color: #808080

  Label
    id: playerName
    anchors.left: enabled.right
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 4
    color: #b0b0b0
    font: verdana-11px-rounded
    text-align: left

FollowWindow < MainWindow
  padding: 8
  image-source: /images/ui/menubox
  image-color: #718896
  image-border: 10
  opacity: 0.96
  size: 330 336
  focusable: true

  Panel
    anchors.right: next.left
    margin-right: 1
    anchors.top: parent.top
    anchors.left: parent.left
    height: 18
    image-source: /images/ui/button
    image-clip: 0 0 22 23
    image-border: 3
    phantom: true

    Label
      !text: tr('Ultimate Ping Follower')
      font: verdana-11px-antialised
      color: #c4f2ff
      anchors.centerIn: parent
      anchors.verticalCenter: parent.verticalCenter
      margin-left: 5

  Button
    id: closeButton
    size: 16 16
    height: 16
    anchors.right: parent.right
    anchors.top: parent.top
    icon: /images/game/console/closechannel
    icon-clip: 0 0 16 16

    $pressed:
      icon-clip: 0 16 16 16

  Label
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 28
    margin-left: 13
    text: FOLLOW ORDER
    color: #76c7e5
    font: cipsoftFont

  TableHeaderRow
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 45
    margin-left: 13
    margin-right: 13
    color: #c4f2ff
    height: 16

    Button
      id: top
      !text: tr('Top')
      width: 72
      color: #c4f2ff
      font: cipsoftFont
      $enabled:
        color: #c4f2ff

      $disabled:
        color: #c4f2ff

    Button
      id: up
      !text: tr('Up')
      width: 72
      color: #c4f2ff
      font: cipsoftFont
      enabled: true
      $enabled:
        color: #c4f2ff

      $disabled:
        color: #c4f2ff

    Button
      id: down
      !text: tr('Down')
      width: 72
      color: #c4f2ff
      font: cipsoftFont
      enabled: true
      $enabled:
        color: #c4f2ff

      $disabled:
        color: #c4f2ff

    Button
      id: remove
      !text: tr('Remove')
      width: 72
      color: #e8a0a0
      font: cipsoftFont
      enabled: true
      $enabled:
        color: #e8a0a0

      $disabled:
        color: #8a7777

  TextList
    id: list
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.left: parent.left
    margin-left: 13
    margin-right: 13
    anchors.right: parent.right
    padding: 1
    height: 112
    vertical-scrollbar: followScroll
    image-source: /images/ui/panel_map
    image-border: 5
    image-color: #7899a8
    auto-focus: first

  BotSmallScrollBar
    id: followScroll
    anchors.top: prev.top
    anchors.bottom: prev.bottom
    anchors.right: prev.right
    step: 14
    pixels-scroll: true

  Button
    id: addFollow
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 13
    margin-right: 13
    color: #aee6f5
    text: + Add Player
    size: 62 16
    font: cipsoftFont
    text-offset: 0 2

  Label
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 207
    margin-left: 13
    text: HOTKEYS
    color: #76c7e5
    font: cipsoftFont

  CheckBox
    id: useHotcon
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-left: 13
    margin-top: 226
    color: #c4f2ff
    tooltip: Enables a hotkey that toggles the follower configuration.
    text: Toggle Follow
    font: verdana-11px-rounded
    $checked:
      image-color: #54aed1

    $!checked:
      image-color: #808080

  TextEdit
    id: usehottxt
    anchors.top: parent.top
    anchors.right: parent.right
    margin-right: 13
    margin-top: 224
    image-color: #667983
    text-align: center
    size: 82 18
    font: cipsoftFont

  Label
    anchors.top: parent.top
    anchors.left: parent.left
    margin-top: 259
    margin-left: 13
    text: TOOLS
    color: #76c7e5
    font: cipsoftFont

  CheckBox
    id: useMachete
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    margin-top: 278
    margin-left: 13
    color: #c4f2ff
    text: Use Machete
    !tooltip: tr('Will use a machete to basically move faster')
    font: verdana-11px-rounded
    $checked:
      image-color: #54aed1

    $!checked:
      image-color: #808080

  CheckBox
    id: useMacheteInPz
    anchors.verticalCenter: prev.verticalCenter
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    margin-right: 13
    color: #c4f2ff
    text: In Pz
    !tooltip: tr('Will use a machete in pz')
    font: verdana-11px-rounded
    $checked:
      image-color: #54aed1

    $!checked:
      image-color: #808080

  Label
    id: finalCreator
    anchors.top: parent.top
    anchors.left: parent.left
    margin-left: 13
    margin-top: 317
    text: Base: Pojken
    color: #8499a3
    font: cipsoftFont
    width: 90
    visible: true

  Label
    id: creator
    anchors.top: parent.top
    anchors.right: parent.right
    margin-right: 13
    margin-top: 317
    text: Final: Endurias
    color: #8499a3
    font: cipsoftFont
    width: 90
    visible: true

Panel
  height: 20
  margin-top: 1

  Button
    id: follow
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: next.left
    margin-right: 2
    text-align: center
    height: 20
    font: cipsoftFont
    text: Follow
    color: #d2e2e8
    image-color: #7f9096

  Button
    id: startFollow
    anchors.top: parent.top
    anchors.right: next.left
    margin-right: 2
    text: Start
    size: 35 20
    color: #78f09c
    font: cipsoftFont
    text-offset: 0 2
    image-color: #789383

  Button
    id: stopFollow
    anchors.top: parent.top
    anchors.right: next.left
    margin-right: 2
    text: Stop
    size: 35 20
    color: #ff918a
    font: cipsoftFont
    text-offset: 0 2
    image-color: #947b7b

  TabButton
    id: setup
    anchors.top: parent.top
    anchors.right: parent.right
    height: 20
    width: 22
    image-source:/images/topbuttons/options
    image-color: #879398

]])

-- Use the existing in-game follow commands.
ui.startFollow.onClick = function()
  say("follow")
end

ui.stopFollow.onClick = function()
  say("stop")
end

local rootWidget = g_ui.getRootWidget()

local followWindow = UI.createWindow('FollowWindow', rootWidget)
followWindow:hide()

if rootWidget then

  local function Capitalize(str)
    return str:gsub("(%w)(%w*)", function(first, rest)
      return string.upper(first) .. rest
    end)
  end

  local function moveElementUp(list, element)
    local currentIndex
    for i, v in ipairs(list) do
      if v == element then
        currentIndex = i
        break
      end
    end
    if not currentIndex or currentIndex == 1 then return end
    list[currentIndex], list[currentIndex - 1] = list[currentIndex - 1], list[currentIndex]
  end

  local function moveElementDown(list, element)
    local currentIndex
    for i, v in ipairs(list) do
      if v == element then
        currentIndex = i
        break
      end
    end
    if not currentIndex or currentIndex == #list then return end
    list[currentIndex], list[currentIndex + 1] = list[currentIndex + 1], list[currentIndex]
  end

  ui.follow:setColor(not config.enabled and "#d2e2e8" or "#78f09c")
  ui.follow.onClick = function(widget)
    config.enabled = not config.enabled
    widget:setColor()
    ui.follow:setColor(not config.enabled and "#d2e2e8" or "#78f09c")
    widget:setOn(config.enabled)
  end

  local function togglePSetupWindow()
    followWindow:setVisible(not followWindow:isVisible())
    ui.setup:setOn(followWindow:isVisible())
    schedule(1, function()
      if followWindow:isVisible() then
        followWindow:raise()
        followWindow:focus()
      end
    end)
  end

  ui.setup.onClick = function(widget)
    widget:setOn(not widget:isOn())
    togglePSetupWindow()
  end

  followWindow.closeButton.onClick = function(widget)
    togglePSetupWindow()
  end

  g_keyboard.bindKeyDown("Escape", togglePSetupWindow, followWindow)

  local function updateVisuals()

    followWindow.useMachete:setChecked(config.userSettings.useMachete)
    followWindow.useMacheteInPz:setChecked(config.userSettings.useMacheteInPz)
    followWindow.useHotcon:setChecked(config.userSettings.useHotcon)

    followWindow.usehottxt:setText(config.userSettings.usehottxt or "")

  end

  updateVisuals()

  followWindow.useMachete.onClick = function(widget)
    config.userSettings.useMachete = not config.userSettings.useMachete
    updateVisuals()
  end
  followWindow.useMacheteInPz.onClick = function(widget)
    config.userSettings.useMacheteInPz = not config.userSettings.useMacheteInPz
    updateVisuals()
  end
  followWindow.useHotcon.onClick = function(widget)
    config.userSettings.useHotcon = not config.userSettings.useHotcon
    updateVisuals()
  end
  followWindow.usehottxt:setText(config.userSettings.usehottxt or "")
  followWindow.usehottxt.onTextChange = function(widget, text)
    config.userSettings.usehottxt = text
    updateVisuals()
  end

  -- --------------------------------------------------------------------------
  -- Follow-list controls
  -- --------------------------------------------------------------------------

  local function indexOf(list, value)
    for index, entry in ipairs(list) do
      if entry == value then
        return index
      end
    end
    return nil
  end

  local function updateButtonState()
    local input = followWindow.list:getFocusedChild()

    if not input then
      followWindow.header.top:setEnabled(false)
      followWindow.header.up:setEnabled(false)
      followWindow.header.down:setEnabled(false)
      followWindow.header.remove:setEnabled(false)
      return
    end

    local index = followWindow.list:getChildIndex(input)
    local childCount = followWindow.list:getChildCount()

    followWindow.header.top:setEnabled(true)
    followWindow.header.up:setEnabled(index > 1)
    followWindow.header.down:setEnabled(index < childCount)
    followWindow.header.remove:setEnabled(true)
  end

  followWindow.list.onChildFocusChange = function(widget, newChild, oldChild)
    updateButtonState()
  end

  local function getEntryName(entry)
    if not entry then return "" end
    if entry.playerNameValue then return entry.playerNameValue end
    if entry.playerName and entry.playerName.getText then
      return entry.playerName:getText()
    end
    return entry:getText() or ""
  end

  followWindow.header.top.onClick = function(widget)
    local input = followWindow.list:getFocusedChild()
    if not input then return end
    local inputText = getEntryName(input)
    local index = indexOf(config.list, inputText)
    if index then
      table.remove(config.list, index)
      table.insert(config.list, 1, inputText)
      invalidateActiveFollowerCache()
    end
    followWindow.list:moveChildToIndex(input, 1)
    updateButtonState()
  end

  followWindow.header.up.onClick = function(widget)
    local input = followWindow.list:getFocusedChild()
    if not input then return end
    moveElementUp(config.list, getEntryName(input))
    invalidateActiveFollowerCache()
    local index = followWindow.list:getChildIndex(input)
    if index < 2 then return end
    followWindow.list:moveChildToIndex(input, index - 1)
    updateButtonState()
  end

  followWindow.header.down.onClick = function(widget)
    local input = followWindow.list:getFocusedChild()
    if not input then return end
    moveElementDown(config.list, getEntryName(input))
    invalidateActiveFollowerCache()
    local index = followWindow.list:getChildIndex(input)
    if index >= followWindow.list:getChildCount() then return end
    followWindow.list:moveChildToIndex(input, index + 1)
    updateButtonState()
  end

  followWindow.header.remove.onClick = function(widget)
    local input = followWindow.list:getFocusedChild()
    if not input then return end
    local inputText = getEntryName(input)
    table.removevalue(config.list, inputText)
    config.activeNames[followNameKey(inputText)] = nil
    invalidateActiveFollowerCache()
    input:destroy()
    updateButtonState()
  end

  local function makeFollowEntry(name)
    local entry = UI.createWidget("FollowEntry", followWindow.list)
    entry.playerNameValue = name
    entry.playerName:setText(name)
    entry.enabled:setChecked(isFollowNameEnabled(name))
    entry.enabled.onClick = function(widget)
      local enabled = not isFollowNameEnabled(name)
      setFollowNameEnabled(name, enabled)
      widget:setChecked(enabled)
    end
  end

  local function addFollowPlayer(friendName)
    friendName = friendName:trim()
    if friendName:len() > 1 and not table.contains(config.list, friendName, true) then
      table.insert(config.list, friendName)
      setFollowNameEnabled(friendName, true)
      invalidateActiveFollowerCache()
      makeFollowEntry(friendName)
    end
  end

  local function makeList()
    for _, child in ipairs(followWindow.list:getChildren()) do
      child:destroy()
    end
    if config.list and #config.list > 0 then
      for _, name in ipairs(config.list) do
        makeFollowEntry(name)
      end
    end
  end
  makeList()

  followWindow.addFollow.onClick = function(widget)
    local options = {
      title = 'Enter Player Name',
      validation = '^[a-zA-Z -]+$'
    }
    modules.client_textedit.show('', options, function(text)
      addFollowPlayer(Capitalize(text:lower()))
    end)
  end

  updateButtonState()
end 

-- ============================================================================
-- ACTIVE FOLLOWER LOOKUPS AND LEADER SELECTION
-- ============================================================================

local function getLeader(onscreen)
  local activeFollowers = getActiveFollowerList()
  if #activeFollowers == 0 then return "" end

  onscreen = onscreen ~= false
  if onscreen then
    for _, buddy in ipairs(activeFollowers) do
      if getPlayerByName(buddy, false) then
        return buddy
      end
    end
  else
    return activeFollowers[1]
  end

  return ""
end

local followerLookupCache = nil
local followerIndexCache = nil
local followerLookupRevision = -1

local function normalizePlayerName(name)
  return type(name) == "string" and name:lower() or ""
end

local function buildNameLookup(list)
  local lookup = {}
  for index = 1, #(list or {}) do
    lookup[normalizePlayerName(list[index])] = true
  end
  return lookup
end

local function refreshFollowerCaches()
  if not storage or not storage["uFollowMacro"] or
     type(storage["uFollowMacro"].list) ~= "table" then
    followerLookupCache = {}
    followerIndexCache = {}
    followerLookupRevision = activeFollowerRevision
    return followerLookupCache, followerIndexCache
  end

  local list = getActiveFollowerList()
  if followerLookupRevision ~= activeFollowerRevision then
    followerLookupCache = buildNameLookup(list)
    followerIndexCache = {}
    for index = 1, #list do
      followerIndexCache[normalizePlayerName(list[index])] = index
    end
    followerLookupRevision = activeFollowerRevision
  end

  return followerLookupCache, followerIndexCache
end

local function getFollowerLookup()
  local lookup = refreshFollowerCaches()
  return lookup
end

local function getFollowerIndex(name)
  local _, index = refreshFollowerCaches()
  return index[normalizePlayerName(name)]
end

function isFollower(name)
  return getFollowerLookup()[normalizePlayerName(name)] == true
end

local function getPlayerAboveBot()
  local activeFollowers = getActiveFollowerList()
  local index = getFollowerIndex(player:getName())
  if index and index > 1 then
    return activeFollowers[index - 1]
  end
  return ""
end

local playerToFollow = getPlayerAboveBot()

macro(1000, function()
  local followers = getActiveFollowerList()
  local followerLookup = getFollowerLookup()
  local specs_on_screen = {}
  for _, mob in ipairs(getSpectators()) do
    local mobName = mob:getName()
    local normalizedName = normalizePlayerName(mobName)
    if followerLookup[normalizedName] then
      specs_on_screen[normalizedName] = true
    end
  end
  local i = 1
  for _, follower in ipairs(followers) do
    local normalizedFollower = normalizePlayerName(follower)
    if specs_on_screen[normalizedFollower] and topFollower[i] then
      topFollower[i]:setText("Top #" .. i .. " follow: " .. follower)
      topFollower[i]:setVisible(true)
      i = i + 1
    end
  end
  for j = i, #topFollower do
    topFollower[j]:setText("")
    topFollower[j]:setVisible(false)
  end
end)

local leaderPositions = {}
local leaderDoorPositions = {}
local leader = nil
local waitingForLeaderMove = true
local wasFollowEnabled = config and config.enabled or false
local followWalkState = {
  lastLeaderStepAt = 0,
  lastWalkAt = 0,
  lastPos = nil,
  lastLeaderFloorChangeAt = 0,
  lastLeaderTeleportAt = 0,
  lastLeaderTeleportPos = nil,
  lastRopeSpellAt = 0,
  queuedWalkId = 0,
  exactStopTarget = nil,
  pzTarget = nil,
  pzStepPending = false,
  lastPzStepAt = 0,
  pzStepFrom = nil
}
local listenedLeaderPosDir = nil
local listenedLeaderDir = nil
local leaderDirections = {}
local lastLeaderFloor
local standTime = now

-- ============================================================================
-- LEADER LIFE, ONLINE STATE, AND FALLBACK SELECTION
-- ============================================================================

local function isAliveCreature(target)
  return target and (target:getHealthPercent() or 0) > 0
end

local function setFollowTarget(name)
  if not name or name == "" then return end

  local targetChanged = normalizePlayerName(playerToFollow) ~= normalizePlayerName(name)
  playerToFollow = name
  if targetChanged then
    -- Keep the old follow behaviour: selecting an online replacement only
    -- arms the follower. Actual walking starts after that character moves.
    waitingForLeaderMove = true
    leader = nil
    leaderPositions = {}
    leaderDoorPositions = {}
    lastLeaderFloor = nil
    followWalkState.lastLeaderStepAt = 0
    followWalkState.lastWalkAt = 0
    followWalkState.lastPos = nil
  end
end

-- Re-arm the movement gate every time Follow is enabled. Without this reset,
-- the first leader movement unlocked following for the rest of the session.
macro(100, function()
  local followEnabled = config and config.enabled or false
  if followEnabled and not wasFollowEnabled then
    waitingForLeaderMove = true
    leader = nil
    leaderPositions = {}
    leaderDoorPositions = {}
    lastLeaderFloor = nil
    followWalkState.lastLeaderStepAt = 0
    followWalkState.lastWalkAt = 0
    followWalkState.lastPos = nil
  end
  wasFollowEnabled = followEnabled
end)

-- A missing creature can simply be on another floor or outside the screen.
-- Only health 0 is treated as a confirmed death.
local confirmedDeadFollowers = {}
local originalFollowTarget = getPlayerAboveBot()
local appliedFollowerRevision = activeFollowerRevision

local function markFollowerAlive(name)
  confirmedDeadFollowers[normalizePlayerName(name)] = nil
end

local function markFollowerDead(name)
  confirmedDeadFollowers[normalizePlayerName(name)] = true
end

local function isFollowerConfirmedDead(name)
  return confirmedDeadFollowers[normalizePlayerName(name)] == true
end

local function getEffectiveLifeState(name, creature)
  if creature then return isAliveCreature(creature) end
  return nil
end


local function getBestAlivePlayerAbove(skipName)
  local activeFollowers = getActiveFollowerList()
  local index = getFollowerIndex(player:getName())
  if not index then return "", nil end

  local skipped = normalizePlayerName(skipName)
  for i = index - 1, 1, -1 do
    local name = activeFollowers[i]
    if name and normalizePlayerName(name) ~= skipped and not isFollowerConfirmedDead(name) then
      local target = getCreatureByName(name)
      if getEffectiveLifeState(name, target) == true then
        return name, target
      end
    end
  end

  return "", nil
end

macro(500, function()
  if spikefound or not config or not config.enabled then return end
  if not isFollower(player:getName()) then
    leader = nil
    playerToFollow = ""
    waitingForLeaderMove = true
    followWalkState.queuedWalkId = followWalkState.queuedWalkId + 1
    followWalkState.exactStopTarget = nil
    followWalkState.pzTarget = nil
    followWalkState.pzStepPending = false
    return
  end

  local preferredLeader = getPlayerAboveBot()
  -- Checkbox/list changes must affect the live target immediately, not only
  -- after a bot reload. Recalculate the chain whenever its revision changes.
  if appliedFollowerRevision ~= activeFollowerRevision then
    appliedFollowerRevision = activeFollowerRevision
    originalFollowTarget = preferredLeader
    confirmedDeadFollowers = {}

    if preferredLeader == "" then
      playerToFollow = ""
      leader = nil
      leaderPositions = {}
      lastLeaderFloor = nil
      waitingForLeaderMove = true
      followWalkState.queuedWalkId = followWalkState.queuedWalkId + 1
      followWalkState.exactStopTarget = nil
      followWalkState.pzTarget = nil
      followWalkState.pzStepPending = false
      return
    end

    setFollowTarget(preferredLeader)
  end

  if preferredLeader == "" then
    playerToFollow = ""
    leader = nil
    waitingForLeaderMove = true
    return
  end

  -- Visible and alive is the common case. Prefer the visible leader.
  -- Fall back to remembered positions when the leader is missing.
  local visiblePreferredCreature = getCreatureByName(preferredLeader)
  if isAliveCreature(visiblePreferredCreature) then
    markFollowerAlive(preferredLeader)
    if normalizePlayerName(playerToFollow) ~= normalizePlayerName(preferredLeader) then
      setFollowTarget(preferredLeader)
    elseif not waitingForLeaderMove then
      leader = visiblePreferredCreature
    end
    return
  end

  if normalizePlayerName(preferredLeader) ~= normalizePlayerName(originalFollowTarget) then
    originalFollowTarget = preferredLeader
    confirmedDeadFollowers = {}
    setFollowTarget(preferredLeader)
  end

  local preferredCreature = getCreatureByName(preferredLeader)
  local preferredAlive = getEffectiveLifeState(preferredLeader, preferredCreature)
  if preferredAlive == true then
    markFollowerAlive(preferredLeader)
    if normalizePlayerName(playerToFollow) ~= normalizePlayerName(preferredLeader) then
      setFollowTarget(preferredLeader)
    elseif not preferredCreature then
      leader = nil
    end
    return
  end

  if preferredAlive == false and preferredCreature and not isAliveCreature(preferredCreature) then
    markFollowerDead(preferredLeader)
  end

  local currentTarget = getCreatureByName(playerToFollow)
  local currentAlive = getEffectiveLifeState(playerToFollow, currentTarget)
  if currentAlive == false then
    if currentTarget and not isAliveCreature(currentTarget) then
      markFollowerDead(playerToFollow)
    end
    leader = nil
    playerToFollow = ""
  elseif currentAlive == true then
    markFollowerAlive(playerToFollow)
    if not currentTarget then
      leader = nil
    end
    return
  end

  if not playerToFollow or playerToFollow == "" or isFollowerConfirmedDead(playerToFollow) then
    local nextName = getBestAlivePlayerAbove()
    if nextName ~= "" then
      markFollowerAlive(nextName)
      setFollowTarget(nextName)
    elseif preferredAlive == nil and not isFollowerConfirmedDead(preferredLeader) then
      -- Keep following the last known position while the leader is out of view.
      setFollowTarget(preferredLeader)
    end
  end
end)

-- ============================================================================
-- MOVEMENT SPEED AND WAYPOINT SUPPORT
-- ============================================================================

local function autoMacroSpeed()
  return 100
end

local function getNearTiles(pPosition, range)
    pPosition = pPosition or pos()
    range = range or 1
    if type(pPosition) ~= "table" then
        pPosition = pPosition:getPosition()
    end
    local tiles = {}
    if pPosition and pPosition.x and pPosition.y then
        for x = pPosition.x - range, pPosition.x + range do
            for y = pPosition.y - range, pPosition.y + range do
                local tile = g_map.getTile({x = x, y = y, z = pPosition.z})
                if tile then
                    tiles[#tiles + 1] = tile
                end
            end
        end
    end
    return tiles
end

local function isReachable(position, precis)
  precis = precis or 0
  local path = findPath(pos(), position, 10, {ignoreFields = true, ignoreNonPathable = true, ignoreCreatures = false, precision = precis})
  return path ~= nil
end

local function makeLookup(list)
    local lookup = {}
    for _, id in ipairs(list) do
        lookup[id] = true
    end
    return lookup
end

local FloorChangers = {
    RopeSpots = {
        Up = makeLookup({386}),
        Down = makeLookup({})
    },
    Use = {
        Up = makeLookup({
            7727, 8265, 1629, 1632, 8266, 7728, 1211, 1220, 1224, 1228, 1233, 1238,
            1242, 1246, 1251, 1256, 1260, 1540, 3546, 3548, 3550, 3552, 4915,
            5083, 5109, 5111, 5113, 5115, 5127, 5129, 5131, 5133, 5142, 5145,
            5283, 5285, 5289, 5293, 5516, 5737, 5749, 6194, 6199, 6203, 6207,
            6251, 6256, 6260, 6264, 6798, 6802, 6902, 6904, 6906, 6908, 7044,
            7046, 7048, 7050, 7055, 8543, 8548, 8552, 8556, 9167, 9172, 9269,
            9274, 9278, 9282, 10270, 10275, 10279, 10283, 10479, 10481, 10483,
            10485, 10786, 12101, 12199, 19851, 19853, 19991, 19993, 20284,
            20286, 17238, 13021, 10790, 12103, 12205, 19855, 19995, 20288,
            10792, 12105, 12203, 19857, 19997, 20290, 22825, 22827, 22829,
            22831, 1214, 1222, 1226, 1230, 1236, 1240, 1244, 1248, 1254,
            1258, 1262, 1542, 3537, 3539, 3541, 3543, 4918, 5085, 5100,
            5102, 5104, 5106, 5118, 5120, 5122, 5124, 5136, 5139, 5280,
            5287, 5291, 5295, 5518, 5734, 5746, 6197, 6201, 6205, 6209,
            6254, 6258, 6262, 6266, 6796, 6800, 6893, 6895, 6897, 6899,
            7035, 7037, 7039, 7041, 7057, 8546, 8550, 8554, 8558, 9170,
            9174, 9272, 9276, 9280, 9284, 10273, 10277, 10281, 10285,
            10470, 10472, 10474, 10476, 10777, 12094, 12190, 19842, 19844,
            19982, 19984, 20275, 20277, 17236, 18209, 13023, 10781, 12096,
            12196, 1660, 19846, 19986, 20279, 10783, 12098, 12194, 19848,
            19988, 20281, 22816, 22818, 22820, 22822, 1223, 1225, 1241,
            1243, 1255, 1257, 3542, 3551, 5105, 5114, 5123, 5132, 5288,
            5290, 5745, 5748, 6202, 6204, 6259, 6261, 6898, 6907, 7040,
            7049, 8551, 8553, 9175, 9177, 9277, 9279, 10278, 10280, 10475,
            10484, 10782, 12097, 19847, 19987, 20280, 10791, 12104, 12204,
            12195, 19856, 19996, 20289, 22821, 22830, 1227, 1229, 1245,
            1247, 1259, 1261, 3540, 3549, 5103, 5112, 5121, 5130, 5292,
            5294, 6206, 6208, 6263, 6265, 6896, 6905, 7038, 7047, 8555,
            8557, 9179, 9181, 9281, 9283, 10282, 10284, 10473, 10482,
            10780, 10789, 12095, 19845, 19985, 20278, 12102, 12193, 12202,
            19854, 19994, 20287, 1644, 1666, 8261, 1646, 8259, 8263,
            1948, 7771, 1723, 5542
        }),

        Down = makeLookup({
            435
        })
    }
}

-- =========================
-- OBJECT DEFINITIONS (SETS)
-- =========================

local objectsTable = {
  [435]=true, [1211]=true, [1214]=true, [1220]=true, [1222]=true, [1223]=true, [1224]=true, [1225]=true, [1226]=true, [1227]=true,
  [1228]=true, [1229]=true, [1230]=true, [1233]=true, [1236]=true, [1238]=true, [1240]=true, [1241]=true, [1242]=true, [1243]=true,
  [1244]=true, [1245]=true, [1246]=true, [1247]=true, [1248]=true, [1251]=true, [1254]=true, [1255]=true, [1256]=true, [1257]=true,
  [1258]=true, [1259]=true, [1260]=true, [1261]=true, [1262]=true, [1540]=true, [1542]=true, [1629]=true, [1630]=true, [1632]=true,
  [1633]=true, [1642]=true, [1644]=true, [1646]=true, [1660]=true, [1666]=true, [1669]=true, [1672]=true, [1683]=true, [1692]=true,
  [1696]=true, [1948]=true, [1968]=true, [2179]=true, [2772]=true, [2773]=true, [3537]=true, [3539]=true, [3540]=true, [3541]=true,
  [3542]=true, [3543]=true, [3546]=true, [3548]=true, [3549]=true, [3550]=true, [3551]=true, [3552]=true, [4911]=true, [4912]=true,
  [4915]=true, [4918]=true, [5006]=true, [5007]=true, [5083]=true, [5085]=true, [5100]=true, [5102]=true, [5103]=true, [5104]=true,
  [5105]=true, [5106]=true, [5107]=true, [5108]=true, [5109]=true, [5111]=true, [5112]=true, [5113]=true, [5114]=true, [5115]=true,
  [5116]=true, [5117]=true, [5118]=true, [5120]=true, [5121]=true, [5122]=true, [5123]=true, [5124]=true, [5125]=true, [5126]=true,
  [5127]=true, [5129]=true, [5130]=true, [5131]=true, [5132]=true, [5133]=true, [5136]=true, [5139]=true, [5142]=true, [5145]=true,
  [5280]=true, [5281]=true, [5283]=true, [5285]=true, [5287]=true, [5288]=true, [5289]=true, [5290]=true, [5291]=true, [5292]=true,
  [5293]=true, [5294]=true, [5295]=true, [5516]=true, [5518]=true, [5542]=true, [5732]=true, [5733]=true, [5734]=true, [5735]=true,
  [5736]=true, [5737]=true, [5745]=true, [5746]=true, [5748]=true, [5749]=true, [6194]=true, [6197]=true, [6199]=true, [6201]=true,
  [6202]=true, [6203]=true, [6204]=true, [6205]=true, [6206]=true, [6207]=true, [6208]=true, [6209]=true, [6248]=true, [6249]=true,
  [6250]=true, [6251]=true, [6252]=true, [6253]=true, [6254]=true, [6256]=true, [6257]=true, [6258]=true, [6259]=true, [6260]=true,
  [6261]=true, [6262]=true, [6263]=true, [6264]=true, [6265]=true, [6266]=true, [6796]=true, [6798]=true, [6800]=true, [6802]=true,
  [6893]=true, [6895]=true, [6896]=true, [6897]=true, [6898]=true, [6899]=true, [6902]=true, [6904]=true, [6905]=true, [6906]=true,
  [6907]=true, [6908]=true, [7035]=true, [7037]=true, [7038]=true, [7039]=true, [7040]=true, [7041]=true, [7044]=true, [7046]=true,
  [7047]=true, [7048]=true, [7049]=true, [7050]=true, [7055]=true, [7057]=true, [7131]=true, [7132]=true, [7712]=true, [7714]=true,
  [7715]=true, [7719]=true, [7727]=true, [7728]=true, [8255]=true, [8256]=true, [8257]=true, [8258]=true, [8259]=true, [8261]=true,
  [8263]=true, [8265]=true, [8266]=true, [8543]=true, [8546]=true, [8548]=true, [8550]=true, [8551]=true, [8552]=true, [8553]=true,
  [8554]=true, [8555]=true, [8556]=true, [8557]=true, [8558]=true, [9167]=true, [9170]=true, [9172]=true, [9174]=true, [9175]=true,
  [9176]=true, [9177]=true, [9178]=true, [9179]=true, [9180]=true, [9181]=true, [9182]=true, [9269]=true, [9272]=true, [9274]=true,
  [9276]=true, [9277]=true, [9278]=true, [9279]=true, [9280]=true, [9281]=true, [9282]=true, [9283]=true, [9284]=true, [10270]=true,
  [10273]=true, [10275]=true, [10277]=true, [10278]=true, [10279]=true, [10280]=true, [10281]=true, [10282]=true, [10283]=true, [10284]=true,
  [10285]=true, [10470]=true, [10472]=true, [10473]=true, [10474]=true, [10475]=true, [10476]=true, [10479]=true, [10481]=true, [10482]=true,
  [10483]=true, [10484]=true, [10485]=true, [10777]=true, [10780]=true, [10781]=true, [10782]=true, [10783]=true, [10786]=true, [10789]=true,
  [10790]=true, [10791]=true, [10792]=true, [11705]=true, [12094]=true, [12095]=true, [12096]=true, [12097]=true, [12098]=true, [12101]=true,
  [12102]=true, [12103]=true, [12104]=true, [12105]=true, [12190]=true, [12193]=true, [12194]=true, [12195]=true, [12196]=true, [12199]=true,
  [12202]=true, [12203]=true, [12204]=true, [12205]=true, [13021]=true, [13023]=true, [17236]=true, [17238]=true, [17701]=true, [17710]=true,
  [18209]=true, [19842]=true, [19844]=true, [19845]=true, [19846]=true, [19847]=true, [19848]=true, [19851]=true, [19853]=true, [19854]=true,
  [19855]=true, [19856]=true, [19857]=true, [19982]=true, [19984]=true, [19985]=true, [19986]=true, [19987]=true, [19988]=true, [19991]=true,
  [19993]=true, [19994]=true, [19995]=true, [19996]=true, [19997]=true, [20275]=true, [20277]=true, [20278]=true, [20279]=true, [20280]=true,
  [20281]=true, [20284]=true, [20286]=true, [20287]=true, [20288]=true, [20289]=true, [20290]=true, [20474]=true, [22816]=true, [22818]=true,
  [22820]=true, [22821]=true, [22822]=true, [22825]=true, [22827]=true, [22829]=true, [22830]=true, [22831]=true, [23873]=true, [23877]=true,
  [27260]=true, [30042]=true, [30049]=true, [30742]=true, [30772]=true, [30774]=true, [30776]=true, [30777]=true, [30824]=true, [31115]=true,
  [31116]=true, [31118]=true, [31120]=true, [31129]=true, [31130]=true, [31199]=true, [31200]=true, [31202]=true, [31228]=true, [31262]=true,
  [33262]=true,
}

-- Use the same transition IDs for detection and nearby passage recovery.
-- Keep explicitly classified downward transitions in their existing set.
for itemId in pairs(objectsTable) do
  if not FloorChangers.Use.Down[itemId] then
    FloorChangers.Use.Up[itemId] = true
  end
end

local objectsTable2 = {
  [5542]=true,
  [1948]=true,
  [435]=true,
  [7771]=true,
  [1723]=true,
  [386]=true,  -- levitate
  [418]=true
}

-- =========================
-- OBJECT DETECTION
-- =========================

local function isObject(targetPos)
  for _, tile in ipairs(getNearTiles(targetPos, 1)) do
    for _, item in ipairs(tile:getItems()) do
      local id = item:getId()
      if objectsTable2[id] or objectsTable[id] then
        return true
      end
    end
  end
  return false
end

-- =========================
-- TP LOSS HANDLING
-- =========================

local function handleTpLoss(targetPos, dist)
  if not targetPos or isInPz() then return end

  -- Never guess a teleport from nearby tiles. Only use the exact position
  -- confirmed when the configured leader actually stepped onto item 1949.
  local tpPos = followWalkState.lastLeaderTeleportPos
  if tpPos and tpPos.z == posz() and
     now - followWalkState.lastLeaderTeleportAt <= 2000 then
    leaderPositions[tpPos.z] = {x = tpPos.x, y = tpPos.y, z = tpPos.z}
  end
end

local lastPressed = nil

local function useClosestItem(targetPos, dist)
  dist = dist or 3
  targetPos = targetPos or leaderPositions[posz()]
  if not targetPos then return end
  if targetPos.z ~= posz() then return end

  local closestItem = nil
  local closestDistance = math.huge

  for _, tile in ipairs(getNearTiles(targetPos, dist)) do
    for _, item in ipairs(tile:getItems()) do
      if objectsTable[item:getId()] then
        local tilePos = tile:getPosition()
        local dx = math.abs(tilePos.x - targetPos.x)
        local dy = math.abs(tilePos.y - targetPos.y)
        local distance = dx + dy
        if isReachable(tilePos, 1) and distance < closestDistance then
          closestDistance = distance
          closestItem = item
        end
      end
    end
  end

  if closestItem then
    if (not lastPressed or (now - lastPressed) >= 500) then
      g_game.use(closestItem)
      lastPressed = now
    end
  end
end

-- Door 7727 changes to 7728 while it is open. Recognize both states so the
-- exact doorway crossed by the leader can be recorded locally.
local leaderDoorPassageIds = {
    [7727] = true, [7728] = true,
    [8265] = true, [8266] = true
}

local function getLeaderDoorPosition(position)
    if not position then return nil end
    local tile = g_map.getTile(position)
    if not tile then return nil end
    for _, item in ipairs(tile:getItems()) do
        if leaderDoorPassageIds[item:getId()] then
            return {x = position.x, y = position.y, z = position.z}
        end
    end
    return nil
end

onKeyDown(function(keys)
    if keys == config.userSettings.usehottxt and config.userSettings.useHotcon then
        config.enabled = not config.enabled
        if config.enabled then
            ui.follow:setColor("#78f09c")
        else
            ui.follow:setColor("#d2e2e8")
        end
    end
end)

local function handleUse(pos)
  local lastZ = posz()
  if posz() == lastZ then
    local newTile = g_map.getTile({x = pos.x, y = pos.y, z = pos.z})
    if newTile then
      g_game.use(newTile:getTopUseThing())
    end
  end
end

local function handleRope(pos)
  if not pos then return end

  local playerPos = player:getPosition()
  if not playerPos or playerPos.z ~= pos.z then return end

  -- Magic Rope requires the character to stand on the rope spot.
  if playerPos.x ~= pos.x or playerPos.y ~= pos.y then
    autoWalk(pos, 10, {
      ignoreNonPathable = true,
      ignoreCreatures = true,
      precision = 0
    })
    return
  end

  if now - followWalkState.lastRopeSpellAt >= 1000 then
    followWalkState.lastRopeSpellAt = now
    say("exani tera")
  end
end

local floorChangeSelector = {
  RopeSpots = {Up = handleRope, Down = handleRope},
  Use = {Up = handleUse, Down = handleUse}
}

local function isKnownFloorChangePosition(position)
  local tile = position and g_map.getTile(position)
  if not tile then return false end

  for changer, data in pairs(FloorChangers) do
    local thing = changer == "RopeSpots" and tile:getGround() or tile:getTopUseThing()
    local id = thing and thing:getId()
    if id then
      for _, dir in ipairs({"Down", "Up"}) do
        if data[dir] and data[dir][id] then
          return true
        end
      end
    end
  end
  return false
end

local function handleFloorChange()
  local range = 1
  local p = player:getPosition()
  local closestChanger = nil
  local closestPos = nil
  local closestDistance = 99999

  for _, dir in ipairs({"Down", "Up"}) do
    for changer, data in pairs(FloorChangers) do
      local lookup = data[dir]
      if lookup then
        for x = -range, range do
          for y = -range, range do
            local tilePos = {x = p.x + x, y = p.y + y, z = p.z}
            local tile = g_map.getTile(tilePos)

            if tile then
              -- Rope spots are ground tiles; other floor changers are use items.
              local thing = changer == "RopeSpots" and tile:getGround() or tile:getTopUseThing()
              local thingId = thing and thing:getId()
              local isTrackedDoor = thingId and leaderDoorPassageIds[thingId]
              local selectedDoorPos = leaderDoorPositions[p.z]
              local isSelectedDoor = selectedDoorPos and
                tilePos.x == selectedDoorPos.x and
                tilePos.y == selectedDoorPos.y and
                tilePos.z == selectedDoorPos.z

              -- Door IDs can occur several times next to each other. A door
              -- tracked from the leader may only be used at the exact tile the
              -- leader crossed; never fall back to a neighbouring same-ID door.
              if thing and lookup[thingId] and (not isTrackedDoor or isSelectedDoor) then
                local dist = math.abs(tilePos.x - p.x) + math.abs(tilePos.y - p.y)
                if dist < closestDistance then
                  closestChanger = floorChangeSelector[changer][dir]
                  closestPos = tilePos
                  closestDistance = dist
                end
              end
            end
          end
        end
      end
    end
  end

  if closestChanger then
    closestChanger(closestPos)
    return true
  end

  return false
end

local function levitate(dir)
  turn(dir)
  schedule(200, function()
    say('exani hur "down')
    say('exani hur "up')
  end)
end

local spikefound = false

macro(250, function()
    local p = pos()
    spikefound = false

    for x = -1, 1 do
        for y = -1, 1 do
            local tile = g_map.getTile({x = p.x + x, y = p.y + y, z = p.z})
            if tile then
                local thing = tile:getTopThing()
                if thing then
                    local id = thing:getId()
                    if id == 2148 or id == 37498 then
                        spikefound = true
                        if g_game.cancelWalk then
                            g_game.cancelWalk()
                        end
                        return
                    end
                end
            end
        end
    end
end)

local function matchPos(p1, p2)
  return (p1.x == p2.x and p1.y == p2.y)
end

-- Closed doors handled by the nearby interaction macro. Keep the same IDs
-- here so a blocked follower can first walk to a reachable tile beside one.
local followDoorIds = {
  [1723] = true, [2031] = true, [2472] = true, [2481] = true,
  [4073] = true, [4077] = true, [7727] = true, [8265] = true,
  [17353] = true, [19131] = true,
  [23740] = true, [23741] = true, [24040] = true
}

local function recoverBlockedDoor(leaderPos)
  local playerPos = player:getPosition()
  if not playerPos or not leaderPos or playerPos.z ~= leaderPos.z then return false end

  -- Never guess between neighbouring doors. This position is recorded from
  -- the configured leader's actual movement, locally.
  local selectedDoorPos = leaderDoorPositions[playerPos.z]
  if not selectedDoorPos then return false end

  local bestDoor, bestStandPos, bestScore

  local doorTile = g_map.getTile(selectedDoorPos)
  if not doorTile then return false end
  for _, item in ipairs(doorTile:getItems()) do
    if followDoorIds[item:getId()] then
      bestDoor = item
      break
    end
  end
  if not bestDoor then return false end

  for x = -1, 1 do
    for y = -1, 1 do
      if x ~= 0 or y ~= 0 then
        local standPos = {x = selectedDoorPos.x + x, y = selectedDoorPos.y + y, z = selectedDoorPos.z}
        local standTile = g_map.getTile(standPos)
        if standTile and standTile:isWalkable() then
          local path = findPath(playerPos, standPos, 40, {
            ignoreNonPathable = false,
            ignoreCreatures = true,
            precision = 0
          })
          if path and (not bestScore or #path < bestScore) then
            bestStandPos = standPos
            bestScore = #path
          end
        end
      end
    end
  end

  if not bestStandPos then return false end

  if getDistanceBetween(playerPos, bestDoor:getPosition()) <= 1 then
    g_game.use(bestDoor)
    return true
  end

  return autoWalk(bestStandPos, 40, {
    ignoreNonPathable = false,
    ignoreCreatures = true,
    precision = 0
  }) == true
end

local function handleUsing(leaderPos)
  if recoverBlockedDoor(leaderPos) then return true end
  return handleFloorChange()
end

-- Field items for the Tibia 8.00 client (items.xml / Tibia.dat 8.00).
-- The previous ids (2118-2122 -> 30423) came from a 10.x+ client. In 8.00
-- those ids are other items, and 30423 does not exist at all, which is what
-- swapped the fire sprites for tiles and bugged the game.
--
-- Fields are replaced with a plain splash (non-blocking, walkable, not a
-- field) so the walker no longer treats the tile as a field.
local ffChange = 2016

local ffLookup = {
    -- fire fields (map)
    [1487] = true,
    [1488] = true,
    [1489] = true,
    -- fire fields (rune, PvP)
    [1492] = true,
    [1493] = true,
    [1494] = true,
    -- fire fields (rune, non-PvP)
    [1500] = true,
    [1501] = true,
    [1502] = true,
    -- energy fields (map / rune PvP / rune non-PvP)
    [1491] = true,
    [1495] = true,
    [1504] = true
}

-- Never send an id the loaded client does not know about.
local ffChangeValid = not g_things or not g_things.isValidDatId
  or g_things.isValidDatId(ffChange, ThingCategoryItem)

local function replaceField(item)
  if ffChangeValid and ffLookup[item:getId()] then
    item:setId(ffChange)
  end
end

-- === EVENT: nya items ===
onAddThing(function(tile, thing)
if not config.enabled  then return end
    if thing:isItem() then
        replaceField(thing)
    end
end)

-- === SCAN: redan existerande items ===
local function initialScan()
    local playerPos = pos()

    for x = playerPos.x - 7, playerPos.x + 7 do
        for y = playerPos.y - 5, playerPos.y + 5 do
            local tile = g_map.getTile({x = x, y = y, z = playerPos.z})
            if tile then
                local items = tile:getItems()
                if items then
                    for i = 1, #items do
                        replaceField(items[i])
                    end
                end
            end
        end
    end
end

-- === RUN VID START ===
schedule(500, initialScan)

-- === RUN VID FLOOR CHANGE ===
onPlayerPositionChange(function(newPos, oldPos)
if not config.enabled  then return end
    if newPos.z ~= oldPos.z then
        schedule(500, initialScan)
    end
end)

onTurn(function(creature, direction)
  if not config.enabled  then return end
  local leader = getLeader()
  if leader == creature:getName() and getPlayerByName(leader) then
    turn(direction)
    delay(autoMacroSpeed())
  end
end)

local function getStandTime()
  return now - standTime
end

local ignoreIds = {2355, 8529}

function isIgnoredTile(pos, ignoreIds)
  local tile = g_map.getTile(pos)
  if not tile then return false end
  local topItem = tile:getTopUseThing()
  if not topItem then return false end
  local id = topItem:getId()
  if type(ignoreIds) == "table" then
    for _, ignoreId in pairs(ignoreIds) do
      if id == ignoreId then
        return true
      end
    end
  else
    if id == ignoreIds then
      return true
    end
  end
  return false
end

-- =========================
-- SAFETY HELPERS (VIKTIGT)
-- =========================
local function safeAutoWalk(pos, tries, opts)
  if not pos then return false end
  opts = opts or {ignoreNonPathable = true, precision = 1}
  return autoWalk(pos, tries or 40, opts)
end

-- Avoid replacing an active path with the exact same destination several
-- times per second. Repeated autoWalk calls are a common source of jitter.
local function followAutoWalk(targetPos, tries, opts, exactStop, useDirectStep)
  if not targetPos then return false end

  local lastPos = followWalkState.lastPos
  if lastPos and
     lastPos.x == targetPos.x and
     lastPos.y == targetPos.y and
     lastPos.z == targetPos.z and
     now - followWalkState.lastWalkAt < 300 then
    return true
  end

  -- Only diagonal leader movement sends one direct directional step. Straight
  -- movement keeps the original autoWalk behaviour. Both run immediately.
  -- Only use the direct step when the destination is currently walkable. A
  -- closed door needs the normal autoWalk/interact recovery path instead.
  local player = g_game.getLocalPlayer()
  local playerPos = player and player:getPosition()
  local targetTile = g_map.getTile(targetPos)
  local targetIsWalkable = targetTile and targetTile:isWalkable()
  if useDirectStep and exactStop and targetIsWalkable and playerPos and playerPos.z == targetPos.z then
    local dx = targetPos.x - playerPos.x
    local dy = targetPos.y - playerPos.y
    if math.abs(dx) <= 1 and math.abs(dy) <= 1 and (dx ~= 0 or dy ~= 0) then
      local stepDirections = {
        ["0,-1"] = 0,  -- north
        ["1,0"] = 1,   -- east
        ["0,1"] = 2,   -- south
        ["-1,0"] = 3,  -- west
        ["1,-1"] = 4,  -- north-east
        ["1,1"] = 5,   -- south-east
        ["-1,1"] = 6,  -- south-west
        ["-1,-1"] = 7  -- north-west
      }
      local direction = stepDirections[dx .. "," .. dy]
      if direction ~= nil and g_game.walk then
        followWalkState.lastWalkAt = now
        followWalkState.lastPos = {x = targetPos.x, y = targetPos.y, z = targetPos.z}
        followWalkState.exactStopTarget = nil
        g_game.walk(direction)
        return true
      end
    end
  end

  local started = safeAutoWalk(targetPos, tries, opts)
  if started then
    followWalkState.lastWalkAt = now
    followWalkState.lastPos = {x = targetPos.x, y = targetPos.y, z = targetPos.z}
    followWalkState.exactStopTarget = exactStop and {
      x = targetPos.x,
      y = targetPos.y,
      z = targetPos.z
    } or nil
  end
  return started
end

-- Stop the active path as soon as the follower reaches the leader's exact
-- departure tile. This prevents a buffered path from taking one extra step.
onCreaturePositionChange(function(creature, newPos)
  local player = g_game.getLocalPlayer()
  local target = followWalkState.exactStopTarget
  if not player or not creature or not newPos then return end
  if creature:getName():lower() ~= player:getName():lower() then return end

  -- Release the PZ one-step lock only after the server confirms movement from
  -- the position where the command was sent. This allows the next step to be
  -- sent immediately without ever queueing two steps from the same tile.
  if followWalkState.pzStepPending then
    local from = followWalkState.pzStepFrom
    if not from or newPos.x ~= from.x or newPos.y ~= from.y or newPos.z ~= from.z then
      followWalkState.pzStepPending = false
      followWalkState.pzStepFrom = nil
    end
  end

  if not target then return end

  if newPos.x == target.x and newPos.y == target.y and newPos.z == target.z then
    followWalkState.exactStopTarget = nil
    if not isInPz() and g_game.cancelWalk then
      g_game.cancelWalk()
    end
  end
end)

-- In PZ, send only one path direction at a time and wait for the character's
-- real position update before sending the next one. This avoids a buffered
-- autoWalk path while still following the leader's latest position.
macro(20, function()
  if not config or not config.enabled or not isInPz() then
    followWalkState.pzTarget = nil
    followWalkState.pzStepPending = false
    followWalkState.pzStepFrom = nil
    return
  end

  local target = followWalkState.pzTarget
  local player = g_game.getLocalPlayer()
  local playerPos = player and player:getPosition()
  if not target or not playerPos or playerPos.z ~= target.z then return end

  if playerPos.x == target.x and playerPos.y == target.y then
    followWalkState.pzTarget = nil
    followWalkState.pzStepPending = false
    followWalkState.pzStepFrom = nil
    return
  end

  if followWalkState.pzStepPending then
    local from = followWalkState.pzStepFrom
    local positionChanged = from and
      (playerPos.x ~= from.x or playerPos.y ~= from.y or playerPos.z ~= from.z)
    if positionChanged then
      followWalkState.pzStepPending = false
      followWalkState.pzStepFrom = nil
    else
      -- A normal server-confirmed step unlocks through the position callback.
      -- Retry sooner than the old fixed 400 ms only when the client is no
      -- longer walking; this avoids buffering a duplicate command in lag.
      local retryTimeout = 250
      local stillWalking = player.isWalking and player:isWalking()
      if stillWalking or now - followWalkState.lastPzStepAt <= retryTimeout then
        return
      end
      followWalkState.pzStepPending = false
      followWalkState.pzStepFrom = nil
    end
  end

  local path = findPath(playerPos, target, 40, {
    ignoreNonPathable = true,
    ignoreCreatures = true,
    precision = 0
  })
  local direction = path and path[1]
  if direction ~= nil and g_game.walk then
    followWalkState.pzStepPending = true
    followWalkState.lastPzStepAt = now
    followWalkState.pzStepFrom = {
      x = playerPos.x,
      y = playerPos.y,
      z = playerPos.z
    }
    g_game.walk(direction)
  end
end)

-- =========================
-- SAFE FIND PATH
-- =========================
local function safeFindPath(fromPos, toPos, dist, opts)
  if not fromPos or not toPos then return false end
  opts = opts or {ignoreNonPathable = true, precision = 1}
  return findPath(fromPos, toPos, dist or 20, opts)
end

local lastWalk = 0              -- tracks last walking time for online leader
local offlineLeaderDetected = 0 -- tracks when we detected leader is offline
local lastHandleUsing = 0       -- tracks last time handleUsing was called
local lastFloorChangeScan = 0   -- cap the heavier nearby floor-change scan

ultimatePingFollow = macro(200, function()
  local activeFollowers = getActiveFollowerList()
  if spikefound or not isFollower(player:getName()) or
     player:getName() == activeFollowers[1] or not config.enabled then return end
  if waitingForLeaderMove then return end

  local playerPos = player:getPosition()
  local prevFollow = getPlayerByName(playerToFollow, false)
  local leaderPos = leaderPositions[playerPos.z]

  if not prevFollow then
    handleTpLoss(leaderPos, 3)
    -- handleTpLoss may replace the saved last leader position with the exact
    -- portal tile. Refresh the local value so this same macro cycle uses it.
    leaderPos = leaderPositions[playerPos.z]
    --useClosestItem(leaderPos, 1)
  end 

  -- LEADER IS OFFLINE
  if not leader then
    if leaderPos then
      local distance = getDistanceBetween(playerPos, leaderPos)

      if distance > 0 then
        -- Start timer when first detected offline
        if offlineLeaderDetected == 0 then
          local hasRecentFloorChange =
            now - followWalkState.lastLeaderFloorChangeAt <= 1500
          local hasRecentTeleport =
            now - followWalkState.lastLeaderTeleportAt <= 1500
          offlineLeaderDetected = (hasRecentFloorChange or hasRecentTeleport)
            and (now - 500) or now
        end

        if now - offlineLeaderDetected >= 500 then
          if followAutoWalk(leaderPos, 127, {
            ignoreNonPathable = true,
            precision = 0
          }) then
            return
          end
        end
      else
        -- Reset if already at position
        offlineLeaderDetected = 0
      end
    end

    if now - lastFloorChangeScan >= 100 then
      lastFloorChangeScan = now
      if handleFloorChange() then return end
    end

    local dir = leaderDirections[playerPos.z]
    if dir then levitate(dir) end

  -- LEADER IS ONLINE
  else
    offlineLeaderDetected = 0

    listenedLeaderPosDir = nil
    listenedLeaderDir = nil

    local lpos = leader:getPosition()
    if not lpos then return end

    local distance = getDistanceBetween(playerPos, lpos)

    -- Position-change events handle normal step-by-step following. This is
    -- only a catch-up path after the leader's latest step has settled.
    if distance >= 2 and now - followWalkState.lastLeaderStepAt >= 350 then
      if getStandTime() > 1000 then
        if now - lastWalk > 500 then
          if followAutoWalk(lpos, 40, {
            ignoreNonPathable = true,
            precision = 1,
            ignoreCreatures = true
          }) then
            lastWalk = now
            return
          end
        end
      end
    end

    -- Delay before handleUsing()
    if distance > 1 and not safeFindPath(playerPos, lpos, 20, {
      ignoreNonPathable = true,
      precision = 1
    }) then
      if now - lastHandleUsing >= 500 then
        handleUsing(lpos)
        lastHandleUsing = now
      end
    end
  end
end)

-- =========================
-- MACHETE SUPPORT
-- =========================
macro(200, function()
  local activeFollowers = getActiveFollowerList()
  if spikefound or not isFollower(player:getName()) or
     player:getName() == activeFollowers[1] or not config.enabled then return end
  if waitingForLeaderMove then return end

  local leaderPos = leaderPositions[posz()]
  if not leaderPos then return end

  local inPz = isInPz()
  if config.userSettings.useMachete and
     (not inPz or config.userSettings.useMacheteInPz) then
    local cTile = g_map.getTile(leaderPos)
    local topThing = cTile and cTile:getTopUseThing()
    if topThing and getDistanceBetween(pos(), leaderPos) > 2 then
      g_game.useInventoryItemWith(3308, topThing)
    end
  end
end)


local lastInviteTime, inviteCooldown = 0, 2000
local vocation = player:getVocation()
local throneSearchGeneration = 0
local MAX_THRONE_ATTEMPTS = 120

local commands = {
  ["leave party"] = g_game.partyLeave,

  ["res on"] = function()
    if vocation == 1 and config.enabled then
      ressis.setOn()
    end
  end,

  ["res off"] = function()
    if vocation == 1 and config.enabled then
      ressis.setOff()
    end
  end,

  ["stop"] = function()
    if config.enabled then
      config.enabled = false
      ui.follow:setColor("#d2e2e8")
    end
  end,

  ["follow"] = function()
    if not config.enabled then
      config.enabled = true
      ui.follow:setColor("#78f09c")
    end
  end,

  ["reboot"] = function()
    saveConfig()
    reload()
    modules.game_bot.save()
    modules.game_bot.refresh()
  end,

  ["invite"] = function()
    local currentTime = now
    if currentTime - lastInviteTime >= inviteCooldown then
      say("invite")
      lastInviteTime = currentTime
    end
  end,

  ["exit"] = function()
    for _, tile in ipairs(g_map.getTiles(posz())) do
      for _, item in ipairs(tile:getItems()) do
        if item:getId() == 1949 then
          leaderPositions = {}
          autoWalk(tile:getPosition(), 127, {
            ignoreNonPathable = true,
            precision = 0
          })
          return
        end
      end
    end
  end,

  ["throne jump"] = function()
    throneSearchGeneration = throneSearchGeneration + 1
    local generation = throneSearchGeneration

    local function tryTakeThrone(attempt)
      if generation ~= throneSearchGeneration or attempt > MAX_THRONE_ATTEMPTS then
        return
      end

      for _, tile in ipairs(g_map.getTiles(posz())) do
        for _, item in ipairs(tile:getItems()) do
          local id = item:getId()
          if id == 2355 or id == 8529 then
            leaderPositions = {}
            local success = autoWalk(tile:getPosition(), 127, {
              ignoreNonPathable = true,
              precision = 0
            })
            if success then
              config.enabled = false
              ui.follow:setColor("#d2e2e8")
              return
            end
          end
        end
      end
      -- Om vi inte lyckades, schemalägg nästa försök om 500 ms
      schedule(500, function()
        tryTakeThrone(attempt + 1)
      end)
    end

    tryTakeThrone(1) -- starta första försöket
  end,

  ["turn north"] = function() turn(0) end,
  ["turn east"]  = function() turn(1) end,
  ["turn south"] = function() turn(2) end,
  ["turn west"]  = function() turn(3) end
}

onTalk(function(name, level, mode, text)
  if not isFollower(name) then return end
  local cmdAction = commands[text]
  if cmdAction then
    cmdAction()
  else
    local message = text:match("^say%s+(.*)$")
    if message then
      say(message)
    elseif text:match("^walk") then
      local directions = {
        ["walk north"] = {y = -1}, ["walk n"] = {y = -1},
        ["walk east"] = {x = 1},  ["walk e"] = {x = 1},
        ["walk south"] = {y = 1}, ["walk s"] = {y = 1},
        ["walk west"] = {x = -1}, ["walk w"] = {x = -1},
      }
      local walk = directions[text]
      if walk then
        local selfPosition = player:getPosition()
        selfPosition.y = selfPosition.y + (walk.y or 0)
        selfPosition.x = selfPosition.x + (walk.x or 0)
        leaderPositions = {}
        autoWalk(selfPosition, 40, {ignoreNonPathable = false})
      end
    end
  end
end)

local timeOut = 20000

-- Items att interagera med, med senaste interaktion
local interactTable = {
    [1723]  = {lastInteractByTile = {}},
    [2031]  = {lastInteractByTile = {}},
    [2472]  = {lastInteractByTile = {}},
    [2481]  = {lastInteractByTile = {}},
    [4073]  = {lastInteractByTile = {}},
    [4077]  = {lastInteractByTile = {}},
    [7727]  = {lastInteractByTile = {}},
    [8265]  = {lastInteractByTile = {}},
    [17353] = {lastInteractByTile = {}},
    [19131] = {lastInteractByTile = {}},
    [23740] = {lastInteractByTile = {}},
    [23741] = {lastInteractByTile = {}},
    [24040] = {lastInteractByTile = {}},
}

-- Lista över grannar (8 tiles)
local directions = {
    {1,0}, {-1,0}, {0,1}, {0,-1},
    {1,1}, {1,-1}, {-1,1}, {-1,-1}
}

-- Håll reda på när tiles sist kollades för att hoppa över onödiga checks
local tileLastChecked = {}

local function interact()
    local px, py, pz = posx(), posy(), posz()
    local selectedDoorPos = leaderDoorPositions[pz]
    
    for _, dir in ipairs(directions) do
        local tx, ty, tz = px + dir[1], py + dir[2], pz
        local tileKey = tx .. "," .. ty .. "," .. tz

        local isSelectedDoor = selectedDoorPos and
                               tx == selectedDoorPos.x and
                               ty == selectedDoorPos.y and
                               tz == selectedDoorPos.z
        
        -- Chests and other interaction items are checked normally. Only the
        -- tracked parallel-door IDs require the leader's exact coordinate.
        if not tileLastChecked[tileKey] or (now - tileLastChecked[tileKey] >= 200) then
            local tile = g_map.getTile({x=tx, y=ty, z=tz})
            if tile then
                local used = false
                for _, item in ipairs(tile:getItems()) do
                    local itemId = item:getId()
                    local obj = interactTable[itemId]
                    local isTrackedDoor = leaderDoorPassageIds[itemId] == true
                    local lastTileInteract = obj and (obj.lastInteractByTile[tileKey] or 0) or 0
                    if obj and (not isTrackedDoor or (config.enabled and isSelectedDoor)) and
                       (now - lastTileInteract >= timeOut) then
                        g_game.use(item)
                        obj.lastInteractByTile[tileKey] = now
                        used = true
                        break
                    end
                end
                -- Om ingen användes, uppdatera check-tid så vi inte kollar igen förrän timeout
                if not used then
                    tileLastChecked[tileKey] = now
                else
                    return -- Vi använde ett item, klart
                end
            end
        end
    end
end

macro(200, interact)

onTextMessage(function(mode, text)
    if mode ~= 18 then return end
    if text:find("daily quest tokens? and a lucky attribute point") or text:find("a daily quest token and a lucky attribute point") then
        say("LUCKY")
    elseif text:find("%d+ daily quest tokens") or text:find("a daily quest token") then
        say("TOKEN")
    elseif text:find("already received your daily rewards") then
        say("DAILY CHECK")
    elseif text:find("The treasure chest is empty.") then
        say("DONE")
    elseif text:find("Your character has already done this quest.") then
        say("QUEST DONE")
    elseif text:find("It's empty.") or text:find("The chest is empty.") or text:find("You have already opened this chest.")then
        say("ATTRI DONE")
    end
end)

local monsterHitList = {
    "ancient mage",
    "ancient priest",
    "bloodbeast",
    "corrupted demon",
    "crystal angel",
    "crystal golem",
    "crystal haunter",
    "crystal lizard",
    "crystalbeast",
    "cult leader",
    "death princess",
    "deathman leader",
    "demonic spectre",
    "desert king",
    "doom dragon",
    "doombringer",
    "doomcrawler",
    "doomlord",
    "dreamhaunter",
    "elder necromancer",
    "elf overlord",
    "elite pharaoh",
    "giga spider",
    "gigantic eyeball",
    "gloomstalker",
    "grand tauren",
    "great succubus",
    "jaul",
    "lethal golem",
    "lizard commander",
    "mad mage",
    "massive behemoth",
    "massive smasher",
    "master cherub",
    "mindreader",
    "morgaroth",
    "mutated pumpkin",
    "mystara",
    "nightmare guardian",
    "noble hero",
    "noxious mage",
    "obsidian hydra",
    "omega spider",
    "polar spirit",
    "sea devil",
    "seacrestus",
    "seraphos",
    "shadow lord",
    "shadow rider",
    "sharptooth",
    "toxic anemone",
    "toxic carniphila",
    "toxic mage",
    "verminor",
    "void lord",
}

local monsterHitLookup = buildNameLookup(monsterHitList)

local hasHitted = false

onTextMessage(function(mode, text)
    if mode == 20 and text:find("You've been teleported to the city.") then
        hasHitted = false
        return
    end
    if mode == 21 and not hasHitted then
        local monsterName = text:match("[Aa]n? ([%a%s]+) loses %d+ hitpoints due to your attack.")
        if monsterName and monsterHitLookup[monsterName:lower()] then
            say("Hit " .. monsterName)
            hasHitted = true
        end
    end
end)

local widget = setupUI([[
AmountLeftLabel < Label
  opacity: 0.87
  font: verdana-11px-rounded

Panel
  id: AmountLeftPanel
  height: 350
  width: 195
  anchors.left: parent.left
  anchors.top: parent.top
  margin-top: 70
  margin-left: 3
  layout:
    type: verticalBox
]], modules.game_interface.getMapPanel())

local label

local function updateLabel(touched, total)
    if not label then
        label = UI.createWidget("AmountLeftLabel", widget)
        label:setColor("#ca65e0")
    end
    label:setText(string.format("Thrones touched: %d/%d", touched, total))
end

local function extractThroneInfo(text)
    return text:match("You have touched (%d+)/(%d+) thrones%.")
end

onTextMessage(function(mode, text)
    if mode ~= 20 then return end
    local touched, total = extractThroneInfo(text)
    if touched then
        touched, total = tonumber(touched), tonumber(total)
        updateLabel(touched, total)
        say(string.format("Thrones touched: %d/%d", touched, total))
        return
    end
    if text:find("You've been teleported to the city.", 1, true) and label then
        label:destroy()
        label = nil
    end
end)

onCreaturePositionChange(function(creature, newPos, oldPos)
  local player = g_game.getLocalPlayer()
  if not player then return end

  -- 🔹 Basic checks
  if spikefound or not config or not config.enabled then return end
  if not playerToFollow then return end
  if creature:getName():lower() ~= playerToFollow:lower() then return end

  local leaderMoved = oldPos and newPos and
    (oldPos.x ~= newPos.x or oldPos.y ~= newPos.y or oldPos.z ~= newPos.z)
  local leaderMovedDiagonal = oldPos and newPos and oldPos.z == newPos.z and
    math.abs(newPos.x - oldPos.x) == 1 and
    math.abs(newPos.y - oldPos.y) == 1
  if waitingForLeaderMove then
    if not leaderMoved then return end
    waitingForLeaderMove = false
  end
  if leaderMoved then
    followWalkState.lastLeaderStepAt = now
    -- When the configured leader is visible, record
    -- the exact 7727/7728 doorway crossed in the creature movement event.
    local usedDoorPos = getLeaderDoorPosition(newPos) or getLeaderDoorPosition(oldPos)
    if usedDoorPos then
      leaderDoorPositions[usedDoorPos.z] = usedDoorPos
    end
  end

  -- 🔹 Leader position handling
  if newPos then
    leaderPositions = leaderPositions or {}
    leaderPositions[newPos.z] = newPos

    lastLeaderFloor = newPos.z
    leader = (newPos.z == posz()) and creature or nil
  else
    leader = nil
  end

  if not oldPos then return end

  -- 🔹 Store direction when changing floors
  if newPos and oldPos.z ~= newPos.z then
    followWalkState.lastLeaderFloorChangeAt = now
    leaderDirections = leaderDirections or {}
    -- Preserve the exact departure tile on the floor the follower is still
    -- standing on. This prevents an older position on that floor from being
    -- used when the leader teleports or changes floor quickly.
    leaderPositions[oldPos.z] = {
      x = oldPos.x,
      y = oldPos.y,
      z = oldPos.z
    }
    leaderDirections[oldPos.z] = creature:getDirection()
  end

  -- 🔹 Walk precision
  local walkPrecision = 1
  local oldTile = g_map.getTile(oldPos)
  if oldTile and not oldTile:hasCreature() then
    walkPrecision = 0
  end

  -- 🔹 Simple walk logic
  local targetPos
  local precision

  -- Outside PZ the normal follow target is oldPos, keeping the follower one
  -- step behind. A teleport is the exception: when the leader's newPos is the
  -- portal tile we must target that exact tile, especially on diagonal entry.
  local leaderEnteredTp = false
  if newPos then
    local newTile = g_map.getTile(newPos)
    if newTile then
      for _, item in ipairs(newTile:getItems()) do
        if item:getId() == 1949 then
          leaderEnteredTp = true
          break
        end
      end
    end
  end

  if leaderEnteredTp then
    -- A teleport must win over every normal queued follow step. Otherwise an
    -- older delayed oldPos can replace the portal path just after it starts.
    followWalkState.queuedWalkId = followWalkState.queuedWalkId + 1
    followWalkState.lastLeaderTeleportAt = now
    followWalkState.lastLeaderTeleportPos = {
      x = newPos.x,
      y = newPos.y,
      z = newPos.z
    }
    targetPos = newPos
    precision = 0
    leaderPositions[newPos.z] = {
      x = newPos.x,
      y = newPos.y,
      z = newPos.z
    }
  elseif isInPz() then
    targetPos = newPos
    precision = 1
  else
    -- Always take the leader's exact last tile. Precision 1 allows any
    -- adjacent tile and can leave the follower standing beside the leader.
    targetPos = oldPos
    precision = 0
  end

  if targetPos then
    if isInPz() and not leaderEnteredTp then
      followWalkState.exactStopTarget = nil
      followWalkState.pzTarget = {
        x = targetPos.x,
        y = targetPos.y,
        z = targetPos.z
      }
    else
      followAutoWalk(targetPos, 40, {
        ignoreNonPathable = true,
        precision = precision
      }, not leaderEnteredTp, leaderMovedDiagonal)
    end
  end
end)

onCreatureAppear(function(creature)
  if not creature then return end

  local cpos = creature:getPosition()
  if not cpos then return end

  -- Ignorera andra floors
  if cpos.z ~= posz() then return end

  local creatureName = creature:getName()
  local preferredLeader = getPlayerAboveBot()
  if isFollower(creatureName) and isAliveCreature(creature) then
    markFollowerAlive(creatureName)
  end

  -- Om original-ledaren kommer tillbaka, byt tillbaka direkt
  if preferredLeader ~= "" and creatureName:lower() == preferredLeader:lower() and isAliveCreature(creature) then
    setFollowTarget(preferredLeader)
    return
  end

  -- Om nuvarande ledare dyker upp
  if playerToFollow and creatureName:lower() == playerToFollow:lower() then
    leaderPositions[cpos.z] = {
      x = cpos.x,
      y = cpos.y,
      z = cpos.z
    }
    lastLeaderFloor = cpos.z
    if not waitingForLeaderMove then
      leader = creature
    end
    return
  end

  -- Om vi själva dyker upp (t.ex efter TP)
  if creature:getName() == player:getName() then
    if lastLeaderFloor and lastLeaderFloor == posz() then
      leader = getCreatureByName(playerToFollow)
    end
  end
end)

onCreatureDisappear(function(creature)
  if not creature then return end

  local cpos = creature:getPosition()
  if not cpos then return end

  -- Om ledaren försvinner
  if playerToFollow and creature:getName():lower() == playerToFollow:lower() then
    -- When the leader has just entered a teleport, keep its exact portal tile.
    -- The disappear event can report an older visible position and must not
    -- overwrite that destination (the older versions never did that).
    leaderPositions = leaderPositions or {}
    local recentTp = followWalkState.lastLeaderTeleportPos and
      followWalkState.lastLeaderTeleportPos.z == cpos.z and
      now - followWalkState.lastLeaderTeleportAt <= 1500
    if recentTp then
      local tp = followWalkState.lastLeaderTeleportPos
      leaderPositions[tp.z] = {x = tp.x, y = tp.y, z = tp.z}
    else
      leaderPositions[cpos.z] = {
        x = cpos.x,
        y = cpos.y,
        z = cpos.z
      }
    end
    if isKnownFloorChangePosition(cpos) then
      followWalkState.lastLeaderFloorChangeAt = now
    end
    leader = nil
    if not isAliveCreature(creature) then
      markFollowerDead(playerToFollow)
      playerToFollow = ""
    end
    return
  end

  -- Om vi själva byter floor utan ledaren
  if creature:getName() == player:getName() then
    if lastLeaderFloor and posz() ~= lastLeaderFloor then
      leader = nil
    end
  end
end)

leader = nil

--[[
local webhookLink = "https://discord.com/api/webhooks/1490415018372632658/Sc0CvmS_i4kqvLAjdmLHaE5fHesyqpguK0-JWx01gYHDkcSrawUzB83hxN7UV6Pi7Vta"
local botName = { username = "Spawn Alerts" }
local embed = { color = 16753920 }

local RESPAWN_HOURS = 56

-- Spawn-texter
local spawnMessages = {
    "An omega spider has spawned",
    "Rising from his tomb in the heart of the grasslands",
    "A noble hero has spawned",
	"The Noble Hero has appeared in the Grasslands",
    "A gigantic eyeball has spawned inside the",
	"Noxious Mage has spawned",
	"Corrupted Demon has spawned",
	"Ancient Mage has spawned",
	"Gather, warriors, as the Noble Hero will emerge in the Grasslands",
	"The dwarf geomancer spawn",
	"Lethal Golem has spawned",
	"A mutated pumpkin has spawned"
}

function onHTTPResult(data, err)
    if err then
        print("Discord Webhook Error: " .. err)
    end
end

local function formatTime(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

function sendDiscordWebhook(data)
    local dEmbed = embed
    if data.color then dEmbed.color = data.color end

    dEmbed.title = "**" .. data.title .. "**"
    dEmbed.fields = data.fields

    local dataSend = botName
    dataSend.embeds = { dEmbed }

    HTTP.postJSON(webhookLink, dataSend, onHTTPResult)
end

onTextMessage(function(mode, text)
    if mode ~= 18 then
        return
    end

    for _, spawnText in ipairs(spawnMessages) do
        if string.find(text, spawnText) then
            local now = os.time()

            local fields = {
                {
                    name = "Player:",
                    value = player:getName(),
                },
                {
                    name = "Spawned at:",
                    value = formatTime(now),
                },
                {
                    name = "Message:",
                    value = text,
                }
            }

            -- ENDAST eyeball får respawn timer
            if string.find(text, "A gigantic eyeball has spawned inside the") then
                local nextTime = now + (RESPAWN_HOURS * 60 * 60)

                table.insert(fields, {
                    name = "Next spawn (56h):",
                    value = formatTime(nextTime),
                })
            end

            local data = {
                title = "Boss Spawn Detected",
                fields = fields
            }

            return sendDiscordWebhook(data)
        end
    end
end)
--]]

addSeparator("separator")
