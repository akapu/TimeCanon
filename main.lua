DEBUG = true

W_WIDTH, W_HEIGHT = love.graphics.getDimensions()
WIDTH = 75
HEIGHT = 25
ROTATION_SPEED = math.pi / 6

BULLET_SIZE = 24
BULLET_SPEED = 30
BULLET_PERIOD = 1

ENEMY_PERIOD = 1
ENEMY_SPEED = 20
ENEMY_SIZE = 24

function love.load()
    love.window.setTitle('TimeCanon')

    love.keyboard.keysPressed = {}

    angle = 0

    timer = 0

    bullets = {}

    enemies = {}

    timer_enemy = 0
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'rctrl' and DEBUG then
        debug.debug()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyreleased(key)
    love.keyboard.keysPressed[key] = false
end

function love.update(dt)
    timer = timer + dt

    if timer > BULLET_PERIOD then
        bullets[#bullets + 1] = {
            pos = {x = W_WIDTH/2, y = W_HEIGHT/2},
            dir = {
                x = math.cos(angle),
                y = math.sin(angle)
            },
            to_remove = false
        }
        
        timer = 0
    end 

    for _, bullet in pairs(bullets) do
        bullet.pos.x = bullet.pos.x + bullet.dir.x * BULLET_SPEED * dt
        bullet.pos.y = bullet.pos.y + bullet.dir.y * BULLET_SPEED * dt

        local x = bullet.pos.x
        local fit_horizontally = x >= 0 and x <= W_WIDTH
        
        local y = bullet.pos.y
        local fit_vertically = y >= 0 and y <= W_HEIGHT

        if not fit_horizontally or not fit_vertically then
            bullet.to_remove = true
        end
    end

    for i = 1, #bullets do
        if bullets[i] and bullets[i].to_remove then

            for j = i, #bullets do 
                bullets[j] = bullets[j + 1]
            end

        end
    end

    timer_enemy = timer_enemy + dt

    if timer_enemy > ENEMY_PERIOD then
        enemies[#enemies + 1] = {
            pos = {
                x = love.math.random(0, W_WIDTH),
                y = love.math.random(0, W_HEIGHT)
            },
            dir = random_dir(),
            dead = false
        }

        timer_enemy = 0
    end

    for _, enemy in pairs(enemies) do 
        enemy.pos.x = enemy.pos.x + enemy.dir.x * ENEMY_SPEED * dt
        enemy.pos.y = enemy.pos.y + enemy.dir.y * ENEMY_SPEED * dt

        for _, bullet in pairs(bullets) do
            if collide(enemy, bullet) then
                enemy.dead = true

                break
            end
        end
    end

    for i = 1, #enemies do
        if enemies[i] and enemies[i].dead then

            for j = i, #enemies do 
                enemies[j] = enemies[j + 1]
            end
        end
    end

    local current_speed = 0

    if love.keyboard.keysPressed['left'] then
        current_speed = current_speed - ROTATION_SPEED
    end

    if love.keyboard.keysPressed['right'] then
        current_speed = current_speed + ROTATION_SPEED
    end

    angle = angle + current_speed * dt

    if math.abs(angle) > 2 * math.pi then
        angle = 0
    end
end

function love.draw()
    for _, bullet in pairs(bullets) do
        love.graphics.circle('fill', bullet.pos.x, bullet.pos.y, BULLET_SIZE)
    end

    love.graphics.setColor(1, 0, 0, 1)

    for _, enemy in pairs(enemies) do
        love.graphics.circle('fill', enemy.pos.x, enemy.pos.y, ENEMY_SIZE)
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.push()
	love.graphics.translate(W_WIDTH/2, W_HEIGHT/2)

    love.graphics.rotate(angle)

	love.graphics.rectangle('fill', -WIDTH/2, -HEIGHT/2, WIDTH, HEIGHT)
	love.graphics.pop()
end


function random_dir()
    local angle = love.math.random(0, 2 * math.pi)

    return {
        x = math.cos(angle),
        y = math.sin(angle)
    }
end


function collide(first, second)
    local vector_between = {
        x = first.pos.x - second.pos.x,
        y = first.pos.y - second.pos.y
    }

    local dist = (vector_between.x ^ 2 + vector_between.y ^ 2) ^ 0.5

    if dist < ENEMY_SIZE + BULLET_SIZE - 5 then
        return true
    end

    return false
end