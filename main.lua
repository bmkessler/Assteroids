function love.load(arg)
    debug = true
-- setup the playing window
    height = 600
    width = 800
    love.window.setMode(width,height)
-- Timers
-- We declare these here so we don't have to edit them multiple places
    canShoot = true
    canShootTimerMax = 0.2
    canShootTimer = canShootTimerMax

   newAsteroid = true
   newAsteroidTimerMax = 1.0
   newAsteroidTimer = newAsteroidTimerMax
-- Image Storage
-- Entity Storage

    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 0, true)

    player = { x = 200, y = 500, speed = 10, img = nil, r = 10 }
    player.img = love.graphics.newImage('assets/ship.png')
    player.rotation = 0
    player.body = love.physics.newBody(world, player.x, player.y, "dynamic")
    player.shape = love.physics.newCircleShape(player.r)  -- the ship's physics uses circle of radius r
    player.fixture = love.physics.newFixture(player.body, player.shape) 
    player.fixture:setUserData("player")

    theGround = {}
    theGround.img = love.graphics.rectangle("fill",0,0,1000,100)
    theGround.body = love.physics.newBody(world, 0, 50) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    theGround.shape = love.physics.newRectangleShape(1600, 50) --make a rectangle with a width of 650 and a height of 50
    theGround.fixture = love.physics.newFixture(theGround.body, theGround.shape) --attach shape to body

    bullets = {} -- array of current bullets being drawn and updated
    bulletImg =  love.graphics.circle("fill", 0, 0, 10) -- not being used
    bulletVel = 500

    assteroids ={}
end

function love.update(dt)
    world:update(dt)
    steerShip()
    applyThrust()
    shootBullets(dt)
    generateAsteroid(dt)
    wrapScreen()
end

function love.draw()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.rotation, 1, 1, player.img:getWidth()/2, player.img:getHeight()/2)
    love.graphics.print(text, 0, 0 )
    love.graphics.setColor(72, 160, 14)
    love.graphics.polygon("fill", theGround.body:getWorldPoints(theGround.shape:getPoints()))
    for i, bullet in ipairs(bullets) do
        if i % 2 == 1 then
            love.graphics.setColor(255, 255, 255)
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())
        else
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), bullet.shape:getRadius())
        end

    end
    for i, assteroid in ipairs(assteroids) do
      love.graphics.setColor(255,0,255)
      love.graphics.circle("fill",assteroid.body:getX(), assteroid.body:getY(), assteroid.shape:getRadius())
    end
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.push('quit')
   end
end

function steerShip()
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
    text = player.rotation
end

function applyThrust()
    if love.keyboard.isDown('up') then -- accelerate
       player.body:applyForce(math.sin(player.rotation) * player.speed, -1*math.cos(player.rotation) * player.speed)
    end
end

function shootBullets(dt)
    if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
        -- Create some bullets
        bullet = { x = player.body:getX() , y = player.body:getY() , img = bulletImg, r = 5 }
        bullet.body = love.physics.newBody(world, bullet.x+math.sin(player.rotation)*(bullet.r+player.r), bullet.y-math.cos(player.rotation)*(bullet.r+player.r), "dynamic") --place the bullet at the nose ofthe ship
        bullet.shape = love.physics.newCircleShape(bullet.r) --the ball's shape has a radius of 5
        bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 1) -- Attach fixture to body and give it a density of 1.
        bullet.body:setBullet(true)  -- make sure it won't go through things
        bullet.fixture:setRestitution(0.9) --let the ball bounce
        bullet.fixture:setUserData("bullet")  -- for use in collision ballbacks to identify bullets
        --translate players rotation into bullet dx/dy
        bullet.dx = math.sin(player.rotation) * bulletVel
        bullet.dy = math.cos(player.rotation) * bulletVel * -1
        bullet.body:setLinearVelocity(bullet.dx, bullet.dy)
        table.insert(bullets, bullet)
        canShoot = false -- reset the can shoot timer
        canShootTimer = canShootTimerMax
    end
    -- Time out how far apart our shots can be.
    if canShootTimer > 0 then
      canShootTimer = canShootTimer - (1 * dt)
    else
      canShoot = true
    end
end

function generateAsteroid(dt)
   if newAsteroidTimer > 0 then
      newAsteroidTimer = newAsteroidTimer - (1 * dt)
    else
      newAsteroidTimer = newAsteroidTimerMax
      -- generate a new asteroid
      text = 'ASSTEROID'
      assteroid = {}
      speed = 150
      assteroid.radius = 64  -- assteroid size
      math.randomseed( os.time() )
      dir = math.random(360)
      assteroid.dx = -1*speed*math.abs(math.sin(dir))
      assteroid.dy = speed*math.cos(dir)
      assteroid.x = width+assteroid.radius  -- always appear off the right edge
      assteroid.y = math.random(height)
      assteroid.body = love.physics.newBody(world, assteroid.x, assteroid.y, "dynamic")
      assteroid.shape = love.physics.newCircleShape(assteroid.radius)
      assteroid.fixture = love.physics.newFixture(assteroid.body, assteroid.shape)
      assteroid.body:setBullet(true)  -- make sure it won't go through the paddle
      assteroid.fixture:setRestitution(1.0)  -- make it infinitely bouncy
      assteroid.body:setLinearVelocity(assteroid.dx, assteroid.dy)
      assteroid.fixture:setUserData("assteroid")  -- for handling collision callbacks
      table.insert(assteroids, assteroid) 
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
