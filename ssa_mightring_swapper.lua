-- =========================================================
-- SSA / MIGHT RING SWAPPER (Tibia 8.00 client, OTC/vBot)
--
-- Two independent swappers on the HP tab:
--  * Amulet: SSA at low HP/mana, back to your normal amulet when recovered
--  * Ring:   Might Ring at low HP/mana, back to your normal ring when recovered
--
-- Per swapper:
--  * "Low"      = emergency item (default SSA 3081 / Might Ring 3048)
--  * "Normal"   = item to put back on once recovered (optional)
--  * "Supply BP"= backpack type your SSAs / rings are stored in (optional).
--                 When no copy is left in any open container, the next
--                 nested backpack of that type is opened in the same window.
--  * "Main BP"  = where the item taken off goes (empty = worn backpack)
--
-- Why it's faster / more reliable on 8.00:
--  * Reacts on health/mana change events, plus a 50ms backup tick.
--  * 8.00 servers can't swap onto an occupied slot, so the worn item is
--    moved to Main BP and the new one into the slot in the SAME tick - the
--    server handles the packets in order, so the slot is already empty when
--    the equip arrives. No delays or waits between the two moves.
--  * Only plain g_game.move() to the inventory slot is used (8.00 has no
--    equipItemId); a move that didn't land is resent after 250ms.
--  * Spare copies left in Main BP are reused before fresh ones are taken.
-- =========================================================

local SLOT_NECK = SlotNeck or 2
local SLOT_FINGER = SlotFinger or 9

local RETRY_MS = 250         -- resend a move if the slot hasn't updated after this long
local RESTORE_HOLD_MS = 1000 -- metric must stay above "restore" this long before swapping back
local OPEN_COOLDOWN_MS = 600 -- between backpack opens

local warnCooldowns = {}
local function warnThrottled(key, message)
  if not warnCooldowns[key] or now - warnCooldowns[key] > 30000 then
    warnCooldowns[key] = now
    warn(message)
  end
end

local function inventoryPosition(slot)
  return {x = 65535, y = slot, z = 0}
end

local function isFull(container)
  if containerIsFull then return containerIsFull(container) end
  return container:getItemsCount() >= container:getCapacity()
end

-- Prefers the worn backpack's own window (no parent) when several open
-- containers share the same backpack id.
local function getMainBackpack(mainBackpackId)
  local wantedId = tonumber(mainBackpackId) or 0
  local useWorn = wantedId <= 0
  if useWorn then
    local back = getBack()
    if not back then return nil end
    wantedId = back:getId()
  end

  local fallback = nil
  for _, container in pairs(g_game.getContainers()) do
    local containerItem = container:getContainerItem()
    if containerItem and containerItem:getId() == wantedId then
      if not useWorn or not container.hasParent or not container:hasParent() then
        return container
      end
      fallback = fallback or container
    end
  end
  return fallback
end

-- Returns item, container. Looks in `preferred` first so spare copies left
-- in Main BP are reused instead of pulling a fresh one every time.
local function findItemInContainers(itemId, preferred)
  if preferred then
    for _, item in ipairs(preferred:getItems()) do
      if item:getId() == itemId then return item, preferred end
    end
  end
  for _, container in pairs(g_game.getContainers()) do
    if container ~= preferred then
      for _, item in ipairs(container:getItems()) do
        if item:getId() == itemId then return item, container end
      end
    end
  end
  return nil, nil
end

-- Where to put the item being taken off: Main BP, else any other open
-- container with room. Never the container the new item comes from, since
-- dropping into it would shift that item's position before it is moved.
local function getDropContainer(mainBackpack, exclude)
  if mainBackpack and mainBackpack ~= exclude and not isFull(mainBackpack) then
    return mainBackpack
  end
  for _, container in pairs(g_game.getContainers()) do
    if container ~= exclude and not isFull(container) then
      return container
    end
  end
  return nil
end

local CONFIG_OTML = [[
Panel
  height: 232

  Label
    id: itemsTitle
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    margin-top: 4
    text-align: center
    text: "ITEMS"
    font: verdana-11px-rounded

  Label
    id: specialLabel
    anchors.left: parent.left
    anchors.top: itemsTitle.bottom
    margin-left: 22
    margin-top: 6
    text: "Low"
    font: verdana-11px-rounded

  BotItem
    id: specialItem
    anchors.left: parent.left
    anchors.top: specialLabel.bottom
    margin-left: 22
    margin-top: 3

  Label
    id: mainLabel
    anchors.right: parent.right
    anchors.top: itemsTitle.bottom
    margin-right: 26
    margin-top: 6
    text: "Normal"
    font: verdana-11px-rounded

  BotItem
    id: mainItem
    anchors.right: parent.right
    anchors.top: mainLabel.bottom
    margin-right: 34
    margin-top: 3

  Label
    id: supplyBpLabel
    anchors.left: parent.left
    anchors.top: specialItem.bottom
    margin-left: 10
    margin-top: 8
    text: "Supply BP"
    font: verdana-11px-rounded

  BotItem
    id: supplyBackpack
    anchors.left: parent.left
    anchors.top: supplyBpLabel.bottom
    margin-left: 22
    margin-top: 3

  Label
    id: mainBpLabel
    anchors.right: parent.right
    anchors.top: mainItem.bottom
    margin-right: 22
    margin-top: 8
    text: "Main BP"
    font: verdana-11px-rounded

  BotItem
    id: mainBackpack
    anchors.right: parent.right
    anchors.top: mainBpLabel.bottom
    margin-right: 34
    margin-top: 3

  Label
    id: mainBpInfo
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: mainBackpack.bottom
    margin-top: 4
    text-align: center
    text: "Main BP empty = worn backpack"
    font: verdana-9px

  BotSwitch
    id: metricToggle
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: mainBpInfo.bottom
    margin-top: 6
    margin-left: 10
    margin-right: 10
    text-align: center
    font: verdana-11px-rounded

  Label
    id: labelEquip
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: metricToggle.bottom
    margin-top: 8
    text-align: center
    font: verdana-11px-rounded

  HorizontalScrollBar
    id: scrollEquip
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: labelEquip.bottom
    margin-left: 10
    margin-right: 10
    margin-top: 4
    minimum: 1
    maximum: 100
    step: 1

  Label
    id: labelRestore
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: scrollEquip.bottom
    margin-top: 8
    text-align: center
    font: verdana-11px-rounded

  HorizontalScrollBar
    id: scrollRestore
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: labelRestore.bottom
    margin-left: 10
    margin-right: 10
    margin-top: 4
    minimum: 1
    maximum: 100
    step: 1
]]

local HEADER_OTML = [[
Panel
  height: 19

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    font: verdana-11px-rounded

  Button
    id: edit
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: "Config"
    font: verdana-9px-italic
]]

-- Old saves used ssaItemId / mainAmuletId / ssaBackpackId.
if type(storage["Amulet Settings"]) == "table" then
  local old = storage["Amulet Settings"]
  if old.specialItemId == nil and old.ssaItemId ~= nil then old.specialItemId = old.ssaItemId end
  if old.mainItemId == nil and old.mainAmuletId ~= nil then old.mainItemId = old.mainAmuletId end
  if old.specialBackpackId == nil and old.ssaBackpackId ~= nil then old.specialBackpackId = old.ssaBackpackId end
end

local function createSwapper(spec)
  if type(storage[spec.storageKey]) ~= "table" then
    storage[spec.storageKey] = {}
  end
  local cfg = storage[spec.storageKey]
  cfg.enabled = cfg.enabled == true
  cfg.specialItemId = tonumber(cfg.specialItemId) or spec.defaultSpecialId
  cfg.mainItemId = tonumber(cfg.mainItemId) or 0
  cfg.specialBackpackId = tonumber(cfg.specialBackpackId) or 0
  cfg.mainBackpackId = tonumber(cfg.mainBackpackId) or 0
  cfg.hpEquip = tonumber(cfg.hpEquip) or 50
  cfg.hpUnequip = tonumber(cfg.hpUnequip) or 80
  if cfg.hpUnequip < cfg.hpEquip then cfg.hpUnequip = cfg.hpEquip end
  cfg.metric = (cfg.metric == "mana") and "mana" or "hp"

  -- ---------------------------------------------------------------
  -- UI
  -- ---------------------------------------------------------------
  local ui = setupUI(HEADER_OTML)
  ui.title:setText(spec.name)

  local configUI = setupUI(CONFIG_OTML)
  configUI:hide()

  local function metricName()
    return cfg.metric == "mana" and "Mana" or "HP"
  end

  local function refreshLabels()
    configUI.metricToggle:setText("Trigger: " .. metricName() .. "%")
    configUI.labelEquip:setText("Equip " .. spec.specialName .. " at " .. metricName() .. "% <= " .. cfg.hpEquip)
    configUI.labelRestore:setText("Restore Normal at " .. metricName() .. "% >= " .. cfg.hpUnequip)
  end

  configUI.specialItem:setItemId(cfg.specialItemId)
  configUI.mainItem:setItemId(cfg.mainItemId)
  configUI.supplyBackpack:setItemId(cfg.specialBackpackId)
  configUI.mainBackpack:setItemId(cfg.mainBackpackId)
  configUI.scrollEquip:setValue(cfg.hpEquip)
  configUI.scrollRestore:setValue(cfg.hpUnequip)
  refreshLabels()

  local icon = nil

  configUI.specialItem.onItemChange = function(widget)
    cfg.specialItemId = widget:getItemId()
    if icon then icon.item:setItemId(cfg.specialItemId) end
  end
  configUI.mainItem.onItemChange = function(widget)
    cfg.mainItemId = widget:getItemId()
  end
  configUI.supplyBackpack.onItemChange = function(widget)
    cfg.specialBackpackId = widget:getItemId()
  end
  configUI.mainBackpack.onItemChange = function(widget)
    cfg.mainBackpackId = widget:getItemId()
  end

  configUI.metricToggle.onClick = function()
    cfg.metric = (cfg.metric == "mana") and "hp" or "mana"
    refreshLabels()
  end

  -- restore threshold is always kept >= equip threshold
  configUI.scrollEquip.onValueChange = function(scroll, value)
    cfg.hpEquip = value
    if cfg.hpUnequip < value then
      cfg.hpUnequip = value
      configUI.scrollRestore:setValue(value)
    end
    refreshLabels()
  end
  configUI.scrollRestore.onValueChange = function(scroll, value)
    cfg.hpUnequip = value
    if cfg.hpEquip > value then
      cfg.hpEquip = value
      configUI.scrollEquip:setValue(value)
    end
    refreshLabels()
  end

  local showEdit = false
  ui.edit.onClick = function()
    showEdit = not showEdit
    if showEdit then configUI:show() else configUI:hide() end
  end

  -- ---------------------------------------------------------------
  -- ENABLE SWITCH + ICON
  -- ---------------------------------------------------------------
  local switch = macro(1000000, function() end)

  local function setEnabled(state)
    cfg.enabled = state and true or false
    ui.title:setOn(cfg.enabled)
    if cfg.enabled then switch:setOn() else switch:setOff() end
  end

  ui.title.onClick = function()
    setEnabled(not cfg.enabled)
  end

  icon = addIcon(spec.iconId, {
    item = {id = cfg.specialItemId},
    text = spec.iconText,
    switchable = true,
    movable = true
  }, switch)

  -- addIcon() may restore its own saved on/off state; ours wins.
  setEnabled(cfg.enabled)

  -- ---------------------------------------------------------------
  -- SWAP LOGIC
  -- ---------------------------------------------------------------
  local pendingId, pendingAt = nil, 0  -- last item we tried to put on, and when
  local recoverSince = nil
  local openAt = 0

  -- Opens the supply backpack, or the next nested one of the same type.
  -- A nested one replaces the current (empty) window instead of adding one.
  local function openNextSupply()
    local bpId = tonumber(cfg.specialBackpackId) or 0
    if bpId <= 0 or now < openAt then return end

    local openItems = {}
    local supplyWindows = {}
    for _, container in pairs(g_game.getContainers()) do
      local containerItem = container:getContainerItem()
      if containerItem then
        table.insert(openItems, containerItem)
        if containerItem:getId() == bpId then
          table.insert(supplyWindows, container)
        end
      end
    end

    -- OTClient hands out a new userdata per lookup, so compare with ==
    -- (pointer equality) rather than using items as table keys.
    local function isOpen(item)
      for _, opened in ipairs(openItems) do
        if opened == item then return true end
      end
      return false
    end

    for _, container in ipairs(supplyWindows) do
      for _, item in ipairs(container:getItems()) do
        if item:isContainer() and item:getId() == bpId and not isOpen(item) then
          openAt = now + OPEN_COOLDOWN_MS
          g_game.open(item, container)
          return
        end
      end
    end
    if #supplyWindows > 0 then return end

    for _, container in pairs(g_game.getContainers()) do
      for _, item in ipairs(container:getItems()) do
        if item:isContainer() and item:getId() == bpId then
          openAt = now + OPEN_COOLDOWN_MS
          g_game.open(item, nil)
          return
        end
      end
    end
  end

  -- Puts `itemId` into the slot. Returns false if no copy is reachable.
  local function equip(itemId, current)
    if pendingId == itemId and now - pendingAt < RETRY_MS then return true end

    local mainBackpack = getMainBackpack(cfg.mainBackpackId)
    local item, fromContainer = findItemInContainers(itemId, mainBackpack)
    if not item then return false end

    pendingId, pendingAt = itemId, now

    if current then
      local drop = getDropContainer(mainBackpack, fromContainer)
      if drop then
        -- Both packets go out together; the server frees the slot first.
        g_game.move(current, drop:getSlotPosition(drop:getItemsCount()), current:getCount())
      elseif mainBackpack and mainBackpack == fromContainer and not isFull(mainBackpack) then
        -- Only room is the container the new item is in: dropping there
        -- would shift its position, so take this one off now and equip on
        -- the next tick once the slot is empty.
        g_game.move(current, mainBackpack:getSlotPosition(mainBackpack:getItemsCount()), current:getCount())
        return true
      else
        warnThrottled(spec.name .. ":full", "[" .. spec.name .. "] No room to take off the worn item - trying a direct swap.")
      end
    end

    g_game.move(item, inventoryPosition(spec.slot), 1)
    return true
  end

  local function tick()
    if not cfg.enabled then return end

    local specialId = tonumber(cfg.specialItemId) or 0
    if specialId <= 0 then return end

    local metric = cfg.metric == "mana" and manapercent() or hppercent()
    local current = spec.getCurrent()
    local currentId = current and current:getId() or 0

    if metric <= cfg.hpEquip then
      recoverSince = nil
      if currentId == specialId then return end
      if not equip(specialId, current) then
        openNextSupply()
        warnThrottled(spec.name .. ":missing", "[" .. spec.name .. "] No " .. spec.specialName .. " in an open backpack!")
      end
      return
    end

    local mainId = tonumber(cfg.mainItemId) or 0
    if mainId <= 0 or currentId == mainId then
      recoverSince = nil
      return
    end

    if metric < cfg.hpUnequip then
      recoverSince = nil
      return
    end
    recoverSince = recoverSince or now
    if now - recoverSince < RESTORE_HOLD_MS then return end

    if not equip(mainId, current) then
      warnThrottled(spec.name .. ":missingMain", "[" .. spec.name .. "] Normal item not found in an open backpack!")
    end
  end

  macro(50, function()
    -- keep the panel switch, the icon and storage in sync
    local on = switch:isOn()
    if on ~= cfg.enabled then
      cfg.enabled = on
      ui.title:setOn(on)
    end
    tick()
  end)

  -- React the moment HP/mana changes instead of waiting for the next tick.
  if type(onPlayerHealthChange) == "function" then
    onPlayerHealthChange(function() tick() end)
  elseif type(onCreatureHealthPercentChange) == "function" then
    onCreatureHealthPercentChange(function(creature)
      if creature == player then tick() end
    end)
  end
  if type(onManaChange) == "function" then
    onManaChange(function() tick() end)
  end

  -- Keep Main BP open and a stocked supply backpack ready before it's needed.
  local backOpenAt = 0
  macro(500, function()
    if not cfg.enabled then return end

    if not getMainBackpack(cfg.mainBackpackId) and now >= backOpenAt then
      local configuredId = tonumber(cfg.mainBackpackId) or 0
      local back = getBack()
      if back and (configuredId <= 0 or back:getId() == configuredId) then
        backOpenAt = now + OPEN_COOLDOWN_MS
        g_game.open(back, nil)
      elseif configuredId > 0 then
        -- configured Main BP sitting closed inside an open container
        local item = findItemInContainers(configuredId)
        if item then
          backOpenAt = now + OPEN_COOLDOWN_MS
          g_game.open(item, nil)
        end
      end
    end

    local specialId = tonumber(cfg.specialItemId) or 0
    if specialId > 0 and not findItemInContainers(specialId) then
      openNextSupply()
    end
  end)
end

-- =========================================================
-- INSTANCES
-- =========================================================

setDefaultTab("HP")
UI.Separator()
UI.Label("SSA / Might Ring Swapper")

createSwapper({
  storageKey = "Amulet Settings",
  slot = SLOT_NECK,
  getCurrent = getNeck,
  name = "SSA Swapper",
  specialName = "SSA",
  defaultSpecialId = 3081,
  iconId = "amuletSwapperIcon",
  iconText = "SSA",
})

createSwapper({
  storageKey = "Ring Settings",
  slot = SLOT_FINGER,
  getCurrent = getFinger,
  name = "Might Swapper",
  specialName = "Might Ring",
  defaultSpecialId = 3048,
  iconId = "ringSwapperIcon",
  iconText = "Might",
})

UI.Separator()
