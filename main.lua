function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'

    -- Animations
    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15', 1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7', 2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15', 3), 0.05)

    -- World definition
    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    -- World 's collisons
    world:addCollisionClass('Platform')
    world:addCollisionClass('Player' --[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    -- Player definition
    require('player')

    -- Danger zones definition
    --dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    --dangerZone:setType('static')

    -- Map Level
    platforms = {}
    loadMap()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
end


function love.draw()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    world:draw()
    drawPlayer()
end

function getPlayerColliders()
    local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 50, 2, {'Platform'})
    if #colliders > 0 then 
        player.grounded = true
    else
        player.grounded = false
    end
    return colliders
end

-- Manage Jump for player
function love.keypressed(key)
    if key == 'up' then
        playerJump()
    end
end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType('static')
        table.insert(platforms, platform)
    end
end

function loadMap()
    gameMap = sti("maps/level1.lua")
    local objects = gameMap.layers["Platforms"].objects
    for i, obj in pairs(objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end




--[[
function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end
]]