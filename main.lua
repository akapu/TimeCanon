require 'enemy_spawner'

DEBUG = true

W_WIDTH, W_HEIGHT = love.graphics.getDimensions()
WIDTH = 75
HEIGHT = 25

SIZE_STEP = 5

BULLET_STARTING_SIZE = SIZE_STEP
BULLET_SPEED = 60
BULLET_PERIOD = 1

ENEMY_SPEED = 15
ENEMY_SIZE = 3 * SIZE_STEP

LEVEL_UP_DURATION = 0.75

NO_SPAWN_RADIUS = W_WIDTH * 0.25
STARTING_ENEMY_PERIOD = 4
ENEMY_UP_TIME = 20
ENEMY_PERIOD_STEP = 0.5

play_state = {}

function play_state:update(dt)
    timer = timer + dt

    if timer > BULLET_PERIOD then
        local direction = {
            x = math.cos(angle),
            y = math.sin(angle)
        }

        bullets[#bullets + 1] = {
            pos = {
                x = W_WIDTH/2 + direction.x * (WIDTH/2 - canon.bullet_size/2),
                y = W_HEIGHT/2 + direction.y * (WIDTH/2 - canon.bullet_size/2)
            },
            dir = direction,
            to_remove = false,
            size = canon.bullet_size
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

    enemy_spawner:update(dt)

    level_up:update(dt)

    timer_enemy_up = timer_enemy_up + dt

    if timer_enemy_up > ENEMY_UP_TIME then
        enemy_spawner:change_period(ENEMY_PERIOD_STEP)
        timer_enemy_up = 0
    end

    for _, enemy in pairs(enemies) do 
        enemy.pos.x = enemy.pos.x + enemy.dir.x * ENEMY_SPEED * dt
        enemy.pos.y = enemy.pos.y + enemy.dir.y * ENEMY_SPEED * dt

        for _, bullet in pairs(bullets) do
            if collide(enemy, bullet) then
                local diff = enemy.size - bullet.size

                if diff < 0 then
                    enemy.dead = true
                    bullet.size = math.abs(diff)
                elseif diff > 0 then
                    bullet.to_remove = true
                    enemy.size = math.abs(diff)
                else
                    enemy.dead = true
                    bullet.to_remove = true
                end

                break
            end
        end

        if collide(enemy, canon) then
            health = health - 1
            enemy.dead = true

            if health == 0 then
                state_machine.state = game_over_state
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
        current_speed = current_speed - canon.rotation_speed
    end

    if love.keyboard.keysPressed['right'] then
        current_speed = current_speed + canon.rotation_speed
    end

    angle = angle + current_speed * dt

    if math.abs(angle) > 2 * math.pi then
        if angle > 0 then
            level_up:activate(canon)
        end

        angle = 0
    end
end

function play_state:draw()
    for _, bullet in pairs(bullets) do
        love.graphics.circle('fill', bullet.pos.x, bullet.pos.y, bullet.size)
    end

    love.graphics.setColor(1, 0, 0, 1)

    for _, enemy in pairs(enemies) do
        love.graphics.circle('fill', enemy.pos.x, enemy.pos.y, enemy.size)
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.push()
    love.graphics.translate(W_WIDTH/2, W_HEIGHT/2)

    love.graphics.rotate(angle)

    love.graphics.rectangle('fill', -WIDTH/2, -HEIGHT/2, WIDTH, HEIGHT)
    love.graphics.pop()

    love.graphics.print("health: " .. health, 0, 0, 0, 2)

    level_up:draw()
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

level_up = {
    timer = 0,
    active = false,
    alpha = 0
}

function level_up:activate()
    self.active = true

    bullet_size_up(canon)
end

function level_up:update(dt)
    if not self.active then
        return
    end

    self.timer = self.timer + dt

    if self.timer <= (LEVEL_UP_DURATION / 2) then
        self.alpha = self.timer / (LEVEL_UP_DURATION / 2)
    elseif self.timer < LEVEL_UP_DURATION then
        local time_remaing = LEVEL_UP_DURATION - self.timer
        self.alpha = time_remaing / (LEVEL_UP_DURATION / 2)
    else
        self.active = false
        self.timer = 0
        self.alpha = 0
    end
end

function level_up:draw()
    love.graphics.setColor(0, 1, 0, self.alpha)
    love.graphics.rectangle('fill', 0, 0, W_WIDTH, W_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
end

function love.load()
    love.window.setMode(W_WIDTH, W_HEIGHT, {
        msaa = 2
    })

    love.window.setTitle('TimeCanon')

    love.keyboard.keysPressed = {}

    angle = 0

    timer = 0

    canon = {
        pos = {
            x = W_WIDTH / 2,
            y = W_HEIGHT / 2
        },
        size = math.sqrt((WIDTH/2)^2 + (HEIGHT/2)^2),
        rotation_speed = math.pi/1.5,
        bullet_size = BULLET_STARTING_SIZE
    }

    bullets = {}

    enemies = {}

    timer_enemy_up = 0

    enemy_spawner:init(enemies, STARTING_ENEMY_PERIOD)

    health = 10

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

function bullet_size_up(canon)
    canon.bullet_size = canon.bullet_size + SIZE_STEP
end

function collide(first, second)
    if distance(first.pos, second.pos) < first.size + second.size then
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

function distance(first, second)
    local x = first.x - second.x
    local y = first.y - second.y

    return (x^2 + y^2) ^ 0.5
end