enemy_spawner = {
    started = false,
    first = true,
    timer = 0
}

function enemy_spawner:init(enemies, period, to_start)
    to_start = to_start or 1

    self.enemies = enemies
    self.period = period
    self.to_start = to_start
    self.started = true
end

function enemy_spawner:update(dt)
    if not self.started then
        return
    end

    self.timer = self.timer + dt

    local border = self.period

    if self.first then
        border = self.to_start
    end

    if self.timer > border then
        local angle = love.math.random() * 2 * math.pi
        local radius = love.math.random(NO_SPAWN_RADIUS, W_WIDTH/2)

        local position = {
            x = math.cos(angle) * radius + W_WIDTH/2,
            y = math.sin(angle) * radius + W_HEIGHT/2 
        }

        enemies[#enemies + 1] = {
            pos = position,
            dir = normalize({
                x = W_WIDTH / 2 - position.x,
                y = W_HEIGHT / 2 - position.y
            }),
            dead = false,
            size = ENEMY_SIZE,
            hp = ENEMY_HP
        }

        self.timer = 0

        self.first = false
    end
end

function enemy_spawner:change_period(diff)
    self.period = self.period - diff

    if self.period < diff then
        self.period = diff
    end
end