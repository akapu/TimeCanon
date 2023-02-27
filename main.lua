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
ENEMY_DAMAGE_PERIOD = 1

play_state = {}

function play_state:update(dt)
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
        local position = {
            x = love.math.random(0, W_WIDTH),
            y = love.math.random(0, W_HEIGHT)
        }

        enemies[#enemies + 1] = {
            pos = position,
            dir = normalize({
                x = W_WIDTH / 2 - position.x,
                y = W_HEIGHT / 2 - position.y
            }),
            dead = false,
            damage_timer = 0
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

        if collide(enemy, canon) then
            enemy.dir = idle_dir

            enemy.damage_timer = enemy.damage_timer + dt

            if enemy.damage_timer > ENEMY_DAMAGE_PERIOD then
                health = health - 1

                if health == 0 then
                    state_machine.state = game_over_state
                end

                enemy.damage_timer = 0
            end
        end
    end

    function play_state:draw()
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

        love.graphics.print("health: " .. health, 0, 0, 0, 2)
    end

    game_over_state = {
        timer = 0,
        time_to_transition = 2,
        alpha = 0
    }

    function game_over_state:update(dt)
        if self.timer < self.time_to_transition then
            self.timer = self.timer + dt

            if self.timer > self.time_to_transition then
                self.timer = self.time_to_transition
            end

            self.alpha = self.timer / self.time_to_transition
        end
    end

    function game_over_state:draw()
        love.graphics.setColor(1, 0, 0, self.alpha)

        love.graphics.rectangle('fill', 0, 0, W_WIDTH, W_HEIGHT)

        love.graphics.setColor(1, 1, 1, 1)
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

function love.load()
    love.window.setTitle('TimeCanon')

    love.keyboard.keysPressed = {}

    angle = 0

    timer = 0

    canon = {pos = {
        x = W_WIDTH / 2,
        y = W_HEIGHT / 2
    }}

    bullets = {}

    enemies = {}

    timer_enemy = 0

    health = 10

    idle_dir = {
        x = 0,
        y = 0
    }

    state_machine = {
        state = play_state
    }

    function state_machine:update(dt)
        self.state:update(dt)
    end

    function state_machine:draw()
        self.state:draw()
    end
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
    state_machine:update(dt)
end

function love.draw()
    state_machine:draw()
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

function normalize(vector)
    local length = (vector.x ^ 2 + vector.y ^ 2) ^ 0.5

    vector.x = vector.x / length
    vector.y = vector.y / length

    return vector
end