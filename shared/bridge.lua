FuelBridge = {}

local Framework = pr_lib.framework
local Inventory = pr_lib.inventory

function FuelBridge.GetPlayerData(source)
    if IsDuplicityVersion() then
        return Framework.GetPlayerData(source)
    end
    return Framework.GetPlayerData()
end

function FuelBridge.GetPlate(vehicle)
    return vehicle and GetVehicleNumberPlateText(vehicle) or nil
end

function FuelBridge.GetPlayer(source)
    local data = Framework.GetPlayerData(source)
    if not data then return nil end

    data.citizenid = data.citizenid or data.identifier or data.charId or Framework.GetIdentifier(source)
    data.money = data.money or {
        cash = Framework.GetPlayerAccountBalance(source, 'cash') or 0,
        bank = Framework.GetPlayerAccountBalance(source, 'bank') or 0,
    }

    return {
        PlayerData = data,
        Functions = {
            AddMoney = function(account, amount, reason)
                return Framework.AddPlayerAccountBalance(source, account, amount, reason) ~= false
            end,
            RemoveMoney = function(account, amount, reason)
                return Framework.RemovePlayerAccountBalance(source, account, amount, reason) ~= false
            end,
            AddItem = function(item, amount, _, metadata)
                return Inventory.AddItem(source, item, amount, metadata)
            end,
            SetInventory = function()
                return false
            end,
        },
    }
end

function FuelBridge.TriggerCallback(name, callback, ...)
    local result = pr_lib.callback.await(name, false, ...)
    if callback then callback(result) end
    return result
end

function FuelBridge.CreateCallback(name, callback)
    pr_lib.callback.register(name, function(source, ...)
        local result
        callback(source, function(value) result = value end, ...)
        return result
    end)
end

function FuelBridge.CreateUseableItem(item, callback)
    return Framework.RegisterUsableItem(item, callback)
end

function FuelBridge.HasItem(item, amount)
    return (Inventory.GetItemCount(item) or 0) >= (amount or 1)
end

function FuelBridge.DisplayMetadata(entries)
    if Inventory.displayMetadata then return Inventory.displayMetadata(entries) end
end

function FuelBridge.SearchItem(item)
    if Inventory.GetItemCount then return Inventory.GetItemCount(item) or 0 end
    if Inventory.Search then return Inventory.Search('count', item) or 0 end
    return 0
end

function FuelBridge.ShowInput(data)
    local fields = {}
    for _, input in ipairs(data.inputs or {}) do
        local inputType = input.type == 'number' and 'number' or 'input'
        fields[#fields + 1] = {
            type = inputType,
            label = input.text or input.name,
            required = input.isRequired == true,
            default = input.default,
        }
    end

    local values = pr_lib.inputDialog(data.header or 'Combustível', fields)
    if not values then return nil end

    local result = {}
    for index, input in ipairs(data.inputs or {}) do
        result[input.name] = values[index]
    end
    return result
end

local menuSequence = 0
function FuelBridge.OpenMenu(entries)
    menuSequence = menuSequence + 1
    local id = ('cdn_fuel_menu_%s'):format(menuSequence)
    local title = 'Combustível'
    local options = {}

    for _, entry in ipairs(entries or {}) do
        if entry.isMenuHeader and entry.header and entry.header ~= '' then
            title = entry.header
        else
            local current = entry
            options[#options + 1] = {
                title = current.header ~= '' and current.header or current.txt or 'Continuar',
                description = current.txt,
                icon = current.icon,
                disabled = current.isMenuHeader == true,
                onSelect = function()
                    local params = current.params or {}
                    if params.event then TriggerEvent(params.event, params.args) end
                end,
            }
        end
    end

    pr_lib.registerContext({ id = id, title = title, options = options })
    pr_lib.showContext(id)
end

function FuelBridge.PhoneNotification(title, message)
    local result = pr_lib.alertDialog({
        header = title,
        content = message,
        centered = true,
        cancel = true,
        labels = { confirm = 'Confirmar', cancel = 'Cancelar' },
    })
    return result == 'confirm'
end

function FuelBridge.GiveVehicleKeys(vehicle)
    local plate = FuelBridge.GetPlate(vehicle)
    local keys = pr_lib.vehicle_key
    if keys.GiveTempKeys then return keys.GiveTempKeys(plate) end
    if keys.GiveKeys then return keys.GiveKeys(vehicle, plate) end
    return false
end
function FuelBridge.Progressbar(_, label, duration, useWhileDead, canCancel, disable, anim, prop, propTwo, onFinish, onCancel)
    local completed = pr_lib.progressBar({
        label = label,
        duration = duration,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        disable = {
            move = disable and disable.disableMovement or false,
            car = disable and disable.disableCarMovement or false,
            mouse = disable and disable.disableMouse or false,
            combat = disable and disable.disableCombat or false,
        },
        anim = anim and {
            dict = anim.animDict,
            clip = anim.anim,
            flag = anim.flags,
        } or nil,
        prop = prop,
        propTwo = propTwo,
    })

    if completed then
        if onFinish then onFinish() end
    elseif onCancel then
        onCancel()
    end
    return completed
end

if IsDuplicityVersion() then
    FuelDatabase = {
        query = function(query, params) return pr_lib.database.query(query, params) end,
        insert = function(query, params) return pr_lib.database.insert(query, params) end,
        update = function(query, params) return pr_lib.database.update(query, params) end,
        scalar = function(query, params) return pr_lib.database.scalar(query, params) end,
        single = function(query, params) return pr_lib.database.single(query, params) end,
    }
    FuelDatabase.Async = {
        fetchAll = function(query, params, callback)
            local result = FuelDatabase.query(query, params)
            if callback then callback(result) end
            return result
        end,
        execute = function(query, params, callback)
            local result = FuelDatabase.update(query, params)
            if callback then callback(result) end
            return result
        end,
    }
    FuelDatabase.Sync = { fetchAll = FuelDatabase.query }
end