function love.load(arg)
    debug = true
-- setup the playing window
    height = 600
    width = 800
    love.window.setMode(width,height)
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
    bulletVel = 500
    bulletVelX = 0
    bulletVelY = 0
    theGround = {}
-- Entity Storage
    bullets = {} -- array of current bullets being drawn and updated

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
        bullet = { x = player.body:getX() , y = player.body:getY() , img = bulletImg }
       --bullet.hasBody = false
        --translate players rotation into bullet dx/dy
        bullet.dx = math.sin(player.rotation) * bulletVel
        bullet.dy = math.cos(player.rotation) * bulletVel * -1
        pdx, pdy = player.body:getLinearVelocity( )
        bullet.body = love.physics.newBody(world, bullet.x+math.sin(player.rotation)*dt, bullet.y-math.cos(player.rotation)*dt, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
        bullet.shape = love.physics.newCircleShape(5) --the ball's shape has a radius of 20
        bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 1) -- Attach fixture to body and give it a density of 1.
        bullet.body:setBullet(true)  -- make sure it won't go through things
        bullet.fixture:setRestitution(0.9) --let the ball bounce

        bullet.body:setLinearVelocity(bullet.dx, bullet.dy)

        table.insert(bullets, bullet)
        canShoot = false
        canShootTimer = canShootTimerMax
    end
    -- Time out how far apart our shots can be.
    if canShootTimer > 0 then
      canShootTimer = canShootTimer - (1 * dt)
    else
      canShoot = true
    end
  wrapScreen()
end

function love.draw()

    love.graphics.setColor(255, 255, 255)
    --love.graphics.print(angXText, 100, 0)
    --love.graphics.print(angYText, 300, 0)
    love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.rotation, 1, 1, player.img:getWidth()/2, player.img:getHeight()/2)
    love.graphics.print(text, 0, 0 )
    love.graphics.setColor(72, 160, 14)
    love.graphics.polygon("fill", theGround.body:getWorldPoints(theGround.shape:getPoints()))
    --love.graphics.draw(theGround.img, 100, 100)
    --if theGround.drawn == false then
        --theGround.img = love.graphics.rectangle("fill",100,100,100,100)
        --theGround.drawn = true
    --end
    for i, bullet in ipairs(bullets) do
        if i % 2 == 1 then
            love.graphics.setColor(255, 255, 255)
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())
        else
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())
        end

    end

end

function love.keypressed(key)
   if key == 'escape' then
      love.event.push('quit')
   end
end

function wrapScreen()
  px = player.body:getX()
  py = player.body:getY()
  if px>width then
    player.body:setX(px-width)
  elseif px<0 then
    player.body:setX(px+width)
  end
    if py>height then
    player.body:setY(py-height)
  elseif py<0 then
    player.body:setY(py+height)
  end
end
