lib.addCommand('playercars', {
    help = 'Opens the car management menu',
    params = {
        {
            name = 'cid',
            type = 'string',
            help = 'Citizen ID of the player (optional)',
            optional = true
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local playerCID = args.cid
    
    if not playerCID then
        -- Show input dialog to enter player CID
        TriggerClientEvent('showPlayerCarInput', source)
    else
        -- Fetch player cars directly if CID is provided as argument
        getPlayerCars(source, playerCID)
    end
end)

-- Function to get player cars
function getPlayerCars(source, playerCID)
    --print("Received player CID:", playerCID) --- Debugging

    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE citizenid = @cid', {
        ['@cid'] = playerCID
    }, function(result)
        print("Database query result:", json.encode(result))
        if result and #result > 0 then
            local cars = {}
            for _, row in ipairs(result) do
                table.insert(cars, {
                    vehicle = row.vehicle,
                    plate = row.plate,
                    garage = row.garage,
                    state = row.state
                })
            end
            -- Trigger client event to show the car list
            TriggerClientEvent('showPlayerCars', source, cars)
        else
            -- No cars found, notify the player
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Car Managment Tool',
                description = 'No cars found for this player.',
                type = 'error'
            })
        end
    end)
end

-- Register client event to trigger server-side fetching of player cars
RegisterServerEvent('getPlayerCars')
AddEventHandler('getPlayerCars', function(playerCID)
    local source = source
    getPlayerCars(source, playerCID)
end)

-- Delete car
RegisterServerEvent('deleteCar')
AddEventHandler('deleteCar', function(plate)
    local source = source
    MySQL.Async.execute('DELETE FROM player_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Car Managment Tool',
                description = 'Car deleted successfully.',
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Car Managment Tool',
                description = 'Car not found or delete failed.',
                type = 'error'
            })
        end
    end)
end)

-- Transfer car ownership
RegisterServerEvent('transferCar')
AddEventHandler('transferCar', function(plate, newOwnerCID)
    local source = source
    MySQL.Async.execute('UPDATE player_vehicles SET citizenid = @newOwnerCID WHERE plate = @plate', {
        ['@newOwnerCID'] = newOwnerCID,
        ['@plate'] = plate
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Car Managment Tool',
                description = 'Car ownership transferred successfully.',
                type = 'success'
            }) 
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Car Managment Tool',
                description = 'Car not found or transfer failed.',
                type = 'error'
            })
        end
    end)
end)

-- Change car garage
RegisterServerEvent('changeCarGarage')
AddEventHandler('changeCarGarage', function(plate, newGarage)
    local source = source
    MySQL.Async.execute('UPDATE player_vehicles SET garage = @newGarage WHERE plate = @plate', {
        ['@newGarage'] = newGarage,
        ['@plate'] = plate
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('ox_lib:notify', source, {
            title = 'Car Managment Tool',
            description = 'Car garage changed successfully.',
            type = 'success'
        })
        else
            TriggerClientEvent('ox_lib:notify', source, {
            title = 'Car Managment Tool',
            description = 'Car not found or garage change failed.',
            type = 'error'
        })
        end
    end)
end)
