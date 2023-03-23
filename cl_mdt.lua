local isVisible = false
local prop = nil
local JournalOuvert = false

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
    SetTextCentre(centre)
    SetTextFontForCurrentCommand(15) 
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    DisplayText(str, x, y)
end


    Citizen.CreateThread(function()   
        if Config.UseOffice == true then 
        while true do 
            Citizen.Wait(1)
            local coords = GetEntityCoords(PlayerPedId())
            for k,v in pairs(Config.Office) do
                if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.coords[1], v.coords[2], v.coords[3], false) < 1.0  then
                DrawTxt(Config.Open['text'], 0.50, 0.95, 0.7, 0.5, true, 223, 44, 53, 255, true)
                if IsControlJustPressed(0, Config.Open['key']) then
                    ExecuteCommand(""..Config.Command.."")                
                end    
            end
        end
    end
        end
    end)



TriggerServerEvent("bucky_mdt:getOffensesAndOfficer")


function SortirJournal()
    local ped = PlayerPedId()
	AnimationJ(ped, "mech_inspection@mini_map@satchel", "enter")
end

function RangerJournal()
    local ped = PlayerPedId()
	AnimationJ(ped, "mech_inspection@two_fold_map@satchel", "exit_satchel")
end

function AnimationJ(ped, dict, name)
    if not DoesAnimDictExist(dict) then
      return
    end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
    Citizen.Wait(0)
    end
    TaskPlayAnim(ped, dict, name, -1.0, -0.5, 2000, 1, 0, true, 0, false, 0, false)
    RemoveAnimDict(dict)
end

RegisterNetEvent("bucky_mdt:toggleVisibilty")
AddEventHandler("bucky_mdt:toggleVisibilty", function(reports, warrants, officer, job, grade, note)
    local playerPed = PlayerPedId()
    if not isVisible then
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
        JournalOuvert = true
        SortirJournal()
        Wait(2000)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player) 
        local props = CreateObject(GetHashKey("p_cs_newspaper_02x_noanim"), coords.x, coords.y, coords.z, 1, 0, 1)
        prop = props
        SetEntityAsMissionEntity(prop,true,true)
        RequestAnimDict("mech_carry_box")
        while not HasAnimDictLoaded("mech_carry_box") do
        Citizen.Wait(100)
        end
        Citizen.InvokeNative(0xEA47FE3719165B94, player,"mech_carry_box", "idle", 1.0, 8.0, -1, 31, 0, 0, 0, 0)
        Citizen.InvokeNative(0x6B9BBD38AB0796DF, prop,player,GetEntityBoneIndexByName(player,"SKEL_L_Finger12"), 0.20, 0.00, -0.05, 180.0, 190.0, 0.0, true, true, false, true, 1, true)	
    else
        local playerPed = PlayerPedId()
        FreezeEntityPosition(PlayerPedId(), false)
        JournalOuvert = false

        RangerJournal()
        Wait(2000)
        
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(prop,false,true)
        ClearPedTasks(player)
        DeleteObject(prop)	

    end
    if #warrants == 0 then warrants = false end
    if #reports == 0 then reports = false end
    if #note == 0 then note = false end
    SendNUIMessage({
        type = "recentReportsAndWarrantsLoaded",
        reports = reports,
        warrants = warrants,
        officer = officer,
        department = job,
        rank = grade,
        note = note,
    })

    ToggleGUI()
end)

RegisterNUICallback("close", function(data, cb)

    FreezeEntityPosition(PlayerPedId(), false)
    JournalOuvert = false

    RangerJournal()
    Wait(2000)
    
    ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
    DetachEntity(prop,false,true)
    ClearPedTasks(player)
    DeleteObject(prop)	

    ToggleGUI(false)
    cb('ok')
end)

RegisterNUICallback("performOffenderSearch", function(data, cb)
    TriggerServerEvent("bucky_mdt:performOffenderSearch", data.query)
    TriggerServerEvent("bucky_mdt:getOffensesAndOfficer")

    cb('ok')
end)

RegisterNUICallback("viewOffender", function(data, cb)
    TriggerServerEvent("bucky_mdt:getOffenderDetails", data.offender)

    cb('ok')
end)

RegisterNUICallback("saveOffenderChanges", function(data, cb)
    TriggerServerEvent("bucky_mdt:saveOffenderChanges", data.id, data.changes, data.identifier)

    cb('ok')
end)

RegisterNUICallback("submitNewReport", function(data, cb)
    TriggerServerEvent("bucky_mdt:submitNewReport", data)

    cb('ok')
end)

RegisterNUICallback("submitNote", function(data, cb)
    TriggerServerEvent("bucky_mdt:submitNote", data)

    cb('ok')
end)

RegisterNUICallback("performReportSearch", function(data, cb)
    TriggerServerEvent("bucky_mdt:performReportSearch", data.query)

    cb('ok')
end)

RegisterNUICallback("getOffender", function(data, cb)
    TriggerServerEvent("bucky_mdt:getOffenderDetailsById", data.char_id)

    cb('ok')
end)

RegisterNUICallback("deleteReport", function(data, cb)
    TriggerServerEvent("bucky_mdt:deleteReport", data.id)

    cb('ok')
end)

RegisterNUICallback("deleteNote", function(data, cb)
    TriggerServerEvent("bucky_mdt:deleteNote", data.id)

    cb('ok')
end)

RegisterNUICallback("saveReportChanges", function(data, cb)
    TriggerServerEvent("bucky_mdt:saveReportChanges", data)

    cb('ok')
end)

RegisterNUICallback("getWarrants", function(data, cb)
    TriggerServerEvent("bucky_mdt:getWarrants")

end)

RegisterNUICallback("submitNewWarrant", function(data, cb)
    TriggerServerEvent("bucky_mdt:submitNewWarrant", data)

    cb('ok')
end)

RegisterNUICallback("deleteWarrant", function(data, cb)
    TriggerServerEvent("bucky_mdt:deleteWarrant", data.id)

    cb('ok')
end)

RegisterNUICallback("deleteWarrant", function(data, cb)
    TriggerServerEvent("bucky_mdt:deleteWarrant", data.id)

    cb('ok')
end)

RegisterNUICallback("getReport", function(data, cb)
    TriggerServerEvent("bucky_mdt:getReportDetailsById", data.id)

    cb('ok')
end)

RegisterNUICallback("getNotes", function(data, cb)
    TriggerServerEvent("bucky_mdt:getNoteDetailsById", data.id)

    cb('ok')
end)

RegisterNetEvent("bucky_mdt:returnOffenderSearchResults")
AddEventHandler("bucky_mdt:returnOffenderSearchResults", function(results)

    SendNUIMessage({
        type = "returnedPersonMatches",
        matches = results
    })
end)

RegisterNetEvent("bucky_mdt:closeModal")
AddEventHandler("bucky_mdt:closeModal", function()

    SendNUIMessage({
        type = "closeModal"
    })
end)

RegisterNetEvent("bucky_mdt:returnOffenderDetails")
AddEventHandler("bucky_mdt:returnOffenderDetails", function(data)

    SendNUIMessage({
        type = "returnedOffenderDetails",
        details = data
    })
end)

RegisterNetEvent("bucky_mdt:returnOffensesAndOfficer")
AddEventHandler("bucky_mdt:returnOffensesAndOfficer", function(data, name)

    SendNUIMessage({
        type = "offensesAndOfficerLoaded",
        offenses = data,
        name = name
    })
end)

RegisterNetEvent("bucky_mdt:returnReportSearchResults")
AddEventHandler("bucky_mdt:returnReportSearchResults", function(results)

    SendNUIMessage({
        type = "returnedReportMatches",
        matches = results
    })
end)

RegisterNetEvent("bucky_mdt:returnWarrants")
AddEventHandler("bucky_mdt:returnWarrants", function(data)

    SendNUIMessage({
        type = "returnedWarrants",
        warrants = data
    })
end)

RegisterNetEvent("bucky_mdt:completedWarrantAction")
AddEventHandler("bucky_mdt:completedWarrantAction", function(data)

    SendNUIMessage({
        type = "completedWarrantAction"
    })
end)

RegisterNetEvent("bucky_mdt:returnReportDetails")
AddEventHandler("bucky_mdt:returnReportDetails", function(data)

    SendNUIMessage({
        type = "returnedReportDetails",
        details = data
    })
end)

RegisterNetEvent("bucky_mdt:returnNoteDetails")
AddEventHandler("bucky_mdt:returnNoteDetails", function(data)

    SendNUIMessage({
        type = "returnedNoteDetails",
        details = data
    })
end)

RegisterNetEvent("bucky_mdt:sendNUIMessage")
AddEventHandler("bucky_mdt:sendNUIMessage", function(messageTable)

    SendNUIMessage(messageTable)
end)

RegisterNetEvent("bucky_mdt:sendNotification")
AddEventHandler("bucky_mdt:sendNotification", function(message)

    SendNUIMessage({
        type = "sendNotification",
        message = message
    })
end)

function ToggleGUI(explicit_status)
  if explicit_status ~= nil then
    isVisible = explicit_status
  else
    isVisible = not isVisible
  end
  SetNuiFocus(isVisible, isVisible)
  SendNUIMessage({
    type = "enable",
    isVisible = isVisible
  })
end
