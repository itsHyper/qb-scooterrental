local QBCore = exports['qb-core']:GetCoreObject()


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
	RequestModel('a_m_m_prolhost_01')
	  while not HasModelLoaded('a_m_m_prolhost_01') do
	  Wait(1)
	end
	  scooterped = CreatePed(2, 'a_m_m_prolhost_01', Config.PedLocation, false, false) -- change here the cords for the ped 
	  SetPedFleeAttributes(scooterped, 0, 0)
	  SetPedDiesWhenInjured(scooterped, false)
	  TaskStartScenarioInPlace(scooterped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
	  SetPedKeepTask(scooterped, true)
	  SetBlockingOfNonTemporaryEvents(scooterped, true)
	  SetEntityInvincible(scooterped, true)
	  FreezeEntityPosition(scooterped, true)
  end)


CreateThread(function()
    exports['qb-target']:AddTargetModel('a_m_m_prolhost_01', {
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





