debug = true
--love.physics.setMeter(64)
world = nil
player = { x = 200, y = 500, speed = 10, img = nil }
-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
text = math.sin(.2)
angXText = math.cos(.25)
angYText = math.sin(.25)
-- Image Storage
bulletImg = nil
bulletVel = 50
bulletVelX = 0
bulletVelY = 0
theGround = {}
-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated

function love.load(arg)
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)

    player.img = love.graphics.newImage('assets/ship.png')
    player.rotation = 0
    --we now have an asset ready to be used inside Love
    --bulletImg = love.graphics.newImage('assets/plane.png')
    bulletImg =  love.graphics.circle("fill", 0, 0, 10)
    player.body = love.physics.newBody(world, player.x, player.y, "dynamic")
    player.shape = love.physics.newCircleShape(10)  -- the ship's physics is the same size as the bullets
    player.fixture = love.physics.newFixture(player.body, player.shape) 

    love.graphics.setColor(255,255,255)
    theGround.img = love.graphics.rectangle("fill",0,0,1000,100)
    theGround.drawn = false
    theGround.body = love.physics.newBody(world, 0, 50) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    theGround.shape = love.physics.newRectangleShape(1600, 50) --make a rectangle with a width of 650 and a height of 50
    theGround.fixture = love.physics.newFixture(theGround.body, theGround.shape) --attach shape to body

    --theGround.body =


end

function love.update(dt)
    world:update(dt)
    	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
--catch rotation first
    if love.keyboard.isDown('right') then --rotate right
        player.rotation = player.rotation + (.01 * math.pi)
        if player.rotation > math.pi then
            player.rotation = player.rotation * -1
        elseif player.rotation < (math.pi * -1)then
            player.rotation = player.rotation * -1
        end
    elseif love.keyboard.isDown('left') then --rotate left
        player.rotation = player.rotation - (.01 * math.pi)
        if player.rotation > math.pi then
            player.rotation = player.rotation * -1
        elseif player.rotation < (math.pi * -1)then
            player.rotation = player.rotation * -1
        end
    end
-- handle thrust 
    if love.keyboard.isDown('up') then -- accelerate
       player.body:applyForce(math.sin(player.rotation) * player.speed, -1*math.cos(player.rotation) * player.speed)
    end

    text = player.rotation

    if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
        -- Create some bullets
        newBullet = { x = player.body:getX() , y = player.body:getY() , img = bulletImg }
        newBullet.hasBody = false
        --translate players rotation into bullet dx/dy
        newBullet.dx = math.sin(player.rotation) * bulletVel
        newBullet.dy = math.cos(player.rotation) * bulletVel * -1

        table.insert(bullets, newBullet)
        canShoot = false
        canShootTimer = canShootTimerMax
    end
    -- Time out how far apart our shots can be.
    canShootTimer = canShootTimer - (1 * dt)
    if canShootTimer < 0 then
      canShoot = true
    end

    for i, bullet in ipairs(bullets) do
        --bullet.y = bullet.y - (250 * dt)

        if bullet.hasBody == true then
            bullet.body:applyForce(bullet.dx, bullet.dy)
            --text = "Force Applied"
            --love.graphics.print( "Force applied", 100, 100 )
        end
        if bullet.y < 0 then -- remove bullets when they pass off the screen
            table.remove(bullets, i)
        end
    end

end

function love.draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(text, 0, 0 )
    --love.graphics.print(angXText, 100, 0)
    --love.graphics.print(angYText, 300, 0)
    love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.rotation, 1, 1, player.img:getWidth()/2, player.img:getHeight()/2)
    love.graphics.setColor(72, 160, 14)
    love.graphics.polygon("fill", theGround.body:getWorldPoints(theGround.shape:getPoints()))
    --love.graphics.draw(theGround.img, 100, 100)
    --if theGround.drawn == false then
        --theGround.img = love.graphics.rectangle("fill",100,100,100,100)
        --theGround.drawn = true
    --end
    for i, bullet in ipairs(bullets) do
        if bullet.hasBody == false then
            love.graphics.setColor(0, 0, 255)
            bullet.body = love.physics.newBody(world, bullet.x, bullet.y, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
            bullet.shape = love.physics.newCircleShape(5) --the ball's shape has a radius of 20
            bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 1) -- Attach fixture to body and give it a density of 1.
            bullet.fixture:setRestitution(0.9) --let the ball bounce
            bullet.hasBody = true
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())

        elseif i % 2 == 1 then
            --love.graphics.setColor(255, 255, 255)
            --love.graphics.circle("fill", bullet.x, bullet.y, 10, 100)
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())
        else
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())
            --love.graphics.setColor(255, 0, 0)
            --love.graphics.circle("fill", bullet.x, bullet.y, 10, 100)
            --love.graphics.draw(bullet.img, bullet.x, bullet.y)
        end

    end

end
