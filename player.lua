player = world:newRectangleCollider(360, 100, 40, 100, {collision_class = "Player"})
player:setFixedRotation(true)
player.speed = 240
player.animation = animations.idle
player.isMoving = false
player.direction = 1
player.grounded = true


function playerUpdate(dt)
    if player.body then
        getPlayerColliders()
        player.isMoving = false
        local px, py = player:getPosition()

        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.isMoving = true
            player.direction = 1
        end
        
        if love.keyboard.isDown('left') then 
            player:setX(px - player.speed * dt)
            player.isMoving = true
            player.direction = -1
        end
        
        if player:enter('Danger') then 
            player:destroy() 
        end
    end

    if player.grounded then
        if player.isMoving then
            player.animation = animations.run
        else
            player.animation = animations.idle
        end
    else 
        player.animation = animations.jump
    end

    player.animation:update(dt)
end


function drawPlayer()
    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, (0.25 * player.direction), 0.25, 130, 300)
end
