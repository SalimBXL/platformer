DATA_FILE = "data.lua"
DEFAULT_MUSIC_VOLUME = 0.5


function love.load()
    love.window.setMode(1000, 768)

    -- Libraries
    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'
    wf = require 'libraries/windfield/windfield'

    cam = cameraFile()

    -- Sounds
    sounds = {}
    sounds.jump = love.audio.newSource("audio/jump.wav", "static")
    sounds.music = love.audio.newSource("audio/music.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.5)
    sounds.music:play()

    -- Sprites
    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('sprites/enemySheet.png')
    sprites.background = love.graphics.newImage('sprites/background.png')
    
    -- Animations
    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())
    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15', 1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7', 2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15', 3), 0.05)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2', 1), 0.03)

    -- World definition
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    -- World 's collisons
    world:addCollisionClass('Platform')
    world:addCollisionClass('Player' --[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    -- Requires
    require('player')
    require('enemy')
    require('libraries/show')

    -- Danger zones definition
    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    -- Map Level
    platforms = {}
    flagX = 0
    flagY = 0

    -- Saving and loading Datas
    saveData = {}
    saveData.currentLevel = "level1"
    if love.filesystem.getInfo(DATA_FILE) then
        local data = love.filesystem.load(DATA_FILE)
        data()
    end

    loadMap(saveData.currentLevel)
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight()/2)

    local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
    if #colliders > 0 then
        if saveData.currentLevel == "level1" then
            loadMap("level2")
        elseif saveData.currentLevel == "level2" then
            loadMap("level1")
        end
    end
end


function love.draw()
    love.graphics.draw(sprites.background, 0, 0)
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        --world:draw()
        drawPlayer()
        drawEnemies()
    cam:detach()
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

function destroyAll()
    -- Platforms
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end
    -- Ennemies
    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i - 1
    end
end

function loadMap(mapName)
    saveData.currentLevel = mapName
    love.filesystem.write(DATA_FILE, table.show(saveData, "saveData"))

    destroyAll()

    gameMap = sti("maps/" .. mapName .. ".lua")

    -- Starting Point For Player
    local startObjects = gameMap.layers["Start"].objects
    for i, obj in pairs(startObjects) do
        --print("x:"..obj.x.." y:"..obj.y)
        playerStartX = obj.x
        playerStartY = obj.y
    end
    player:setPosition(playerStartX, playerStartY)

    -- Platforms
    local platformObjects = gameMap.layers["Platforms"].objects
    for i, obj in pairs(platformObjects) do
        --print("x:"..obj.x.." y:"..obj.y)
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end

    --Enemies
    local enemyObjects = gameMap.layers["Enemies"].objects
    for i, obj in pairs(enemyObjects) do
        --print("x:"..obj.x.." y:"..obj.y)
        spawnEnemy(obj.x, obj.y, obj.width, obj.height)
    end

    --Flags
    local flagObjects = gameMap.layers["Flag"].objects
    for i, obj in pairs(flagObjects) do
        --print("x:"..obj.x.." y:"..obj.y)
        flagX = obj.x
        flagY = obj.y
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