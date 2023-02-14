W_WIDTH, W_HEIGHT = love.graphics.getDimensions()
WIDTH = 75
HEIGHT = 25
ROTATION_SPEED = math.pi / 6

BULLET_SIZE = 24
BULLET_SPEED = 30
BULLET_PERIOD = 1

function love.load()
    love.window.setTitle('TimeCanon')

    love.keyboard.keysPressed = {}

    angle = 0

    timer = 0

    bullets = {}
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
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
            }}
        
        timer = 0
    end 

    for _, bullet in pairs(bullets) do
        bullet.pos.x = bullet.pos.x + bullet.dir.x * BULLET_SPEED * dt
        bullet.pos.y = bullet.pos.y + bullet.dir.y * BULLET_SPEED * dt
    end

    local current_speed = 0

    if love.keyboard.keysPressed['left'] then
        current_speed = current_speed - ROTATION_SPEED
    end

    if love.keyboard.keysPressed['right'] then
        current_speed = current_speed + ROTATION_SPEED
    end

    angle = angle + current_speed * dt
end

function love.draw()
    for _, bullet in pairs(bullets) do
        love.graphics.circle('fill', bullet.pos.x, bullet.pos.y, BULLET_SIZE)
    end

    love.graphics.push()
	love.graphics.translate(W_WIDTH/2, W_HEIGHT/2)

    love.graphics.rotate(angle)

	love.graphics.rectangle('fill', -WIDTH/2, -HEIGHT/2, WIDTH, HEIGHT)
	love.graphics.pop()
end
