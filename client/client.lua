-- Show input dialog to enter player CID
RegisterNetEvent('showPlayerCarInput', function()
    local input = lib.inputDialog('Please Enter the target Citizen ID', {'Enter Citizen ID. Ex: KBI94689'})
    
    if not input then 
        return 
    end

    local playerCID = input[1]
    TriggerServerEvent('getPlayerCars', playerCID)
end)

-- Register a NetEvent to receive the car list from the server
RegisterNetEvent('showPlayerCars', function(cars)
    local playerID = GetPlayerServerId(PlayerId())
   -- print("Received car data from server:", json.encode(cars))
    
    local options = {
        {
            title = 'Information',
            description = '(0)= Out of Garage, (1)= In Garage, (2)= Impounded',
            icon = 'fa-solid fa-circle-info',
            disabled = true,
            iconColor = 'green'
        }
    }

    for _, car in ipairs(cars) do
        local vehicle = car.vehicle or "Unknown"
        local plate = car.plate or "Unknown"
        local garage = car.garage or "Unknown"
        local state = car.state or "Unknown"
        local vehicleImageURL = 'https://docs.fivem.net/vehicles/' .. vehicle .. '.webp'

        table.insert(options, {
            icon = 'car',
            title = vehicle,
            description = 'Plate: ' .. plate .. '\nGarage: ' .. garage .. '\nState: ' .. state,
            menu = 'car_menu_' .. plate,
            image = vehicleImageURL
        })

        lib.registerContext({
            id = 'car_menu_' .. plate,
            title = vehicle .. ' (' .. plate .. ')',
            options = {
                {
                    title = 'Delete Car',
                    description = 'Delete this car permanently',
                    icon = 'trash',
                    onSelect = function()
                        TriggerServerEvent('deleteCar', plate)
                    end
                },
                {
                    title = 'Transfer Ownership',
                    description = 'Transfer ownership to another player',
                    icon = 'exchange-alt',
                    onSelect = function()
                        local input = lib.inputDialog('Enter new owner Citizen ID', {'Citizen ID. Ex: KBI94689'})
                        if input and input[1] then
                            local newOwnerCID = input[1]
                            TriggerServerEvent('transferCar', plate, newOwnerCID)
                        end
                    end
                },
                {
                    title = 'Change Garage',
                    description = 'Move the car to a different garage',
                    icon = 'warehouse',
                    menu = 'garage_menu_' .. plate
                },
                {
                    title = 'Back',
                    icon = 'fa-solid fa-arrow-left',
                    onSelect = function()
                        lib.showContext('player_cars_menu')
                    end}
            }
        })

        local garageOptions = {}
        for _, g in ipairs(Config.garages) do
            table.insert(garageOptions, {
                title = g,
                onSelect = function()
                    TriggerServerEvent('changeCarGarage', plate, g)
                end
            })
        end

        -- Add a "Back" option to the garage menu
        table.insert(garageOptions, {
            title = 'Back',
            icon = 'fa-solid fa-arrow-left',
            onSelect = function()
                lib.showContext('car_menu_' .. plate)
            end
        })

        lib.registerContext({
            id = 'garage_menu_' .. plate,
            title = 'Select Garage',
            options = garageOptions
        })
    end

    lib.registerContext({
        id = 'player_cars_menu',
        title = 'Player Cars' .. ' (' .. playerID .. ')',
        options = options
    })

    lib.showContext('player_cars_menu')
end)
