_G.love = require("love") 

local gameOver = false

function love.load()
    love.graphics.setBackgroundColor(0, 1, 0)  

    background = love.graphics.newImage("BG.png")

    Hiro = {
        x = 0,
        y = 0,
        sprite = love.graphics.newImage("sprites/spritesheet.png"),
        animation = {
            direction = "right",
            speed = 60,
            frame = 1,  -- Start with frame 1
            max_frames = 8,
            idle = true,
            timer = 0.1
        }
    }

    SPRITE_WIDTH, SPRITE_HEIGHT = 6021, 569
    QUAD_WIDTH = 669
    QUAD_HEIGHT = SPRITE_HEIGHT  

    local screenHeight = love.graphics.getHeight()  -- Get the screen height
    local scaledHeight = SPRITE_HEIGHT * 0.2  -- Apply scaling factor (0.2)
    Hiro.y = (screenHeight - scaledHeight) / 0.2  -- Set y position to the bottom of the screen 
    --this can be written in update function too , but since this position is going to remain static we write it in load to optimize the code

    quads = {}

    -- Create quads for all frames in the sprite sheet
    for i = 1, 8 do
        quads[i] = love.graphics.newQuad(QUAD_WIDTH * (i - 1), 0, QUAD_WIDTH, QUAD_HEIGHT, SPRITE_WIDTH, SPRITE_HEIGHT)
    end 

    projectiles = {}--enemy , typical boiler plate

    function spawnProjectile ()-- always follows the empty enemy table , part of enemy boiler plate  
        local screenHeight = love.graphics.getHeight()
        projectile = {
            x = math.random(1,love.graphics.getWidth() / 0.2),
            y = -10,
            radius = 20,
            speed = 100
        } 
        table.insert(projectiles , projectile)
    end 

    spawnTimer = 0
end

function love.update(dt)
    
     spawnTimer = spawnTimer + dt
        if spawnTimer > 2 then  -- Spawn a projectile every second
            spawnProjectile()
            spawnTimer = 0
        end
    

  if love.keyboard.isDown("d") then
      Hiro.animation.idle = false 
      Hiro.animation.direction = "right"
  elseif love.keyboard.isDown("a") then 
      Hiro.animation.idle = false
      Hiro.animation.direction = "left"
  else
      Hiro.animation.idle = true 
  end

    local screenWidth = love.graphics.getWidth()  -- Get the screen width
    local scaledWidth = QUAD_WIDTH * 0.2  -- Calculate Hiro's scaled width

    if Hiro.x < 0 then  -- Left boundary
        Hiro.x = 0
    end 
    --[[if Hiro.x + scaledWidth > screenWidth then  -- Right boundary
        Hiro.x = (screenWidth - scaledWidth) 
    end]]

  if not Hiro.animation.idle then
      Hiro.animation.timer = Hiro.animation.timer + dt 

      if Hiro.animation.timer > 0.2 then  -- Adjust the frame timing
          Hiro.animation.timer = 0 

          Hiro.animation.frame = Hiro.animation.frame + 1

          -- Wrap the frame index back to 1 if it exceeds max_frames
          if Hiro.animation.frame > Hiro.animation.max_frames then
              Hiro.animation.frame = 1  -- Reset to frame 1
          end

          -- Update Hiro's position based on direction
          if Hiro.animation.direction == "right"  then
              Hiro.x = Hiro.x + Hiro.animation.speed
          elseif Hiro.animation.direction == "left" then
              Hiro.x = Hiro.x - Hiro.animation.speed
          end
      end
  end 

    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        proj.y = proj.y + proj.speed * dt  -- Projectile moves downward

        -- Calculate Hiro's actual dimensions after scaling
        local scaledWidth = QUAD_WIDTH * 0.2
        local scaledHeight = SPRITE_HEIGHT * 0.2

        -- Adjust coordinates for scaling
        local hiroScaledX = Hiro.x / 0.2
        local hiroScaledY = Hiro.y / 0.2
        local projScaledX = proj.x / 0.2
        local projScaledY = proj.y / 0.2

        -- Collision detection
        local distanceX = (hiroScaledX + scaledWidth / 2) - projScaledX
        local distanceY = (hiroScaledY + scaledHeight / 2) - projScaledY
        local distance = math.sqrt(distanceX^2 + distanceY^2) 

        if distance < (scaledWidth / 2 + proj.radius) then
            gameOver = true  -- Trigger game over on collision
        end
    end
end


function love.draw() 
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(), love.graphics.getHeight() / background:getHeight())
    -- x , y , radians to rotate the image , width scaling , height scaling 
    love.graphics.scale(0.2)  -- Scale down the sprite

        -- Draw the sprite based on the current animation frame
    if Hiro.animation.direction == "right" then 
        love.graphics.draw(Hiro.sprite, quads[Hiro.animation.frame], Hiro.x, Hiro.y)
    else 
        love.graphics.draw(Hiro.sprite, quads[Hiro.animation.frame], Hiro.x, Hiro.y, 0, -1, 1, QUAD_WIDTH, 0) -- radians , x scale , y scale and ox and oy
    end  


    for _ ,proj in ipairs(projectiles) do
        love.graphics.setColor(1,0,0)
        love.graphics.circle("fill",proj.x , proj.y , proj.radius)
    end  

    if gameOver  then 
        love.graphics.setColor(1,1,1)
        love.graphics.printf("GAME OVER!",0,love.graphics.getHeight() / 2, love.graphics.getWidth(),"center") -- text , x ,y , width , alignment.
    end
end

