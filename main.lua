W_WIDTH, W_HEIGHT = love.graphics.getDimensions()
WIDTH = 75
HEIGHT = 25
ROTATION_SPEED = math.pi / 6

function love.load()
    love.window.setTitle('TimeCanon')

    love.keyboard.keysPressed = {}

    angle = 0
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
    love.graphics.push()
	love.graphics.translate(W_WIDTH/2, W_HEIGHT/2)

    love.graphics.rotate(angle)

	love.graphics.rectangle('fill', -WIDTH/2, -HEIGHT/2, WIDTH, HEIGHT)
	love.graphics.pop()
end
