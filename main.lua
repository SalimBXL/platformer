function love.load()

    -- Animations
    anim8 = require 'libraries/anim8/anim8'
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

    -- Platform definition
    platform = world:newRectangleCollider(250,400,300,100, {collision_class = "Platform"})
    platform:setType('static')

    -- Player definition
    require('player')

    -- Danger zoneS definition
    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType('static')
end

function love.update(dt)
    world:update(dt)
    playerUpdate(dt)
end


function love.draw()
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
        if player.grounded then
            player:applyLinearImpulse(0, -4000)
            player.animation = animations.jump
        end
    end
end


function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end