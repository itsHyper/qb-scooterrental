local QBCore = exports['qb-core']:GetCoreObject()
local SpawnScooter = false


RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

-- Threads

CreateThread(function()
	RequestModel(Config.PedModel)
	  while not HasModelLoaded(Config.PedModel) do
	  Wait(1)
	end
	  scooterped = CreatePed(2, Config.PedModel, Config.PedLocation, false, false) -- change here the cords for the ped 
	  SetPedFleeAttributes(scooterped, 0, 0)
	  SetPedDiesWhenInjured(scooterped, false)
	  TaskStartScenarioInPlace(scooterped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
	  SetPedKeepTask(scooterped, true)
	  SetBlockingOfNonTemporaryEvents(scooterped, true)
	  SetEntityInvincible(scooterped, true)
	  FreezeEntityPosition(scooterped, true)
  end)

CreateThread(function()
	local scooterblip = AddBlipForCoord(Config.PedLocation)
	SetBlipAsShortRange(scooterblip, true)
	SetBlipSprite(scooterblip, 348)
	SetBlipColour(scooterblip, 60)
	SetBlipScale(scooterblip, 0.7)
	SetBlipDisplay(scooterblip, 6)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Scooter Rental')
	EndTextCommandSetBlipName(scooterblip)
end)


CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.PedModel, {
        options = {
            { 
                type = "client",
                event = "qb-scooterrentals:client:ScooterMenu",
                icon = "fas fa-bicycle",
                label = "Rent Scooter",
            },
        },
        distance = 3.0 
    })
end)

-- Events

RegisterNetEvent('qb-scooterrentals:client:ScooterMenu', function()
    local ScooterMenu = {
        {
            header = "Scooter Rentals",
            txt = "Rent a scooter for quick transportion!",
            isMenuHeader = true,
        },
        {
            header = "Scooter",
            txt =  "$ ".. Config.ScooterPrice .. "w/ Tax",
            params = {
                event = "qb-scooterrentals:client:Spawn",
                args = {
					model = Config.ScooterModel
                }
			}
        },
		{
            header = "Return Scooter",
            params = {
                event = "qb-scooterrentals:client:Return",
			}
		},
		{
            header = "< Close",
            params = {
                event = "qb-menu:client:close",
			}
		},
	}
    exports['qb-menu']:openMenu(ScooterMenu)
end)

RegisterNetEvent('qb-scooterrentals:client:Spawn', function(model)
    local model = Config.ScooterModel
    local player = PlayerPedId()
    QBCore.Functions.TriggerCallback('qb-scooterrentals:server:RentCheck', function(CanRent)
        if CanRent then 
		QBCore.Functions.Progressbar("grab_scooter", "Pulling out Scooter..", math.random(4000,6000), false, true, {
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = false,
		}, {}, {}, {}, function() -- Done
			ScooterRentalEmail()
			QBCore.Functions.SpawnVehicle(model, function(veh)                
				SetVehicleNumberPlateText(veh, "RENTAL"..tostring(math.random(1000, 9999)))
				exports[Config.FuelSystem]:SetFuel(veh, 100.0)
				TaskWarpPedIntoVehicle(player, veh, -1)
				TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(veh))
				SetVehicleEngineOn(veh, false, true)
				SetEntityAsMissionEntity(veh, true, true)
				SpawnScooter = true
			end, Config.SpawnLocation, true)
		end)
        else
            QBCore.Functions.Notify("You don't have enough money..", "error", 2500)
        end
    end, model)
end)


RegisterNetEvent('qb-scooterrentals:client:Return', function()
    if SpawnScooter then
        local Player = QBCore.Functions.GetPlayerData()
        QBCore.Functions.Notify('Returned Scooter!', 'success')
        local car = GetVehiclePedIsIn(PlayerPedId(),true)
        NetworkFadeOutEntity(car, true,false)
        Citizen.Wait(2000)
        QBCore.Functions.DeleteVehicle(car)
    else 
        QBCore.Functions.Notify("No Scooter near you.", "error")
    end
    SpawnScooter = false
end)


function ScooterRentalEmail()
    TriggerServerEvent('qb-phone:server:sendNewMail', {
    sender = 'Escapism Travel',
    subject = 'Scooter Rental',
    message = 'Thank you for renting a scooter from us! Bring the scooter back with in 24 hours!',
    })
end



