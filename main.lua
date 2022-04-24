W_WIDTH, W_HEIGHT = love.graphics.getDimensions()
WIDTH = 75
HEIGHT = 25

function love.conf(t)
	t.console = true
end

function love.load()
    love.window.setTitle('TimeCanon')

    love.keyboard.keysPressed = {}
    love.mouse.isPressed = nil
end

function love.mousePressed(x, y, button, istouch)
    print("pressed")
    love.mouse.isPressed = {
        x = x - W_WIDTH/2,
        y = y - W_HEIGHT/2,
        isTouch = istouch
    }
end

function love.mousereleased()
    love.mouse.isPressed = nil
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.update(dt)
    love.keyboard.keysPressed = {}

    initialPos = love.mouse.isPressed

    if initialPos then
        pos = {
            x = love.mouse.getX() - W_WIDTH/2,
            y = love.mouse.getY() - W_HEIGHT/2
        }

        print(initialPos.x, initialPos.y)
        print(pos.x, pos.y)

        dotProduct = initialPos.x * pos.x + initialPos.y * pos.y
        initialPosLength = math.sqrt(initialPos.x ^ 2 + initialPos.y ^ 2)
        posLength = math.sqrt(pos.x ^ 2 + pos.y ^ 2)

        angle = math.acos(dotProduct / (initialPosLength * posLenght))

    end

end

function love.draw()
    love.graphics.push()
	love.graphics.translate(W_WIDTH/2, W_HEIGHT/2)

    if initialPos then
    	love.graphics.rotate(angle)
    end

	love.graphics.rectangle('fill', -WIDTH/2, -HEIGHT/2, WIDTH, HEIGHT)
	love.graphics.pop()
end
