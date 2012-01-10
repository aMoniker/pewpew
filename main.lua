-- <3
function love.load()
    enemies = {}
    projectiles = {}
    screen = {}
    screen.width = love.graphics.getWidth( )
    screen.height = love.graphics.getHeight( )
    
    pewpew.spawnUnit('zig', screen.width / 2, screen.height / 2)
    for i=1,3 do
        pewpew.spawnUnit('raven', i * 20 + 30, i * 20 + 30)
    end
end
function love.draw()
    pewpew.moveZig( )
    pewpew.moveEnemies( )
    pewpew.moveProjectiles( )
    
    love.graphics.draw(zig.image, zig.x, zig.y, 0, 1, 1, zig.ox, zig.oy)
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, 1, 1, enemy.ox, enemy.oy)
    end
    
    --random rectangle
    love.graphics.setLine( 1, 'rough' )
    love.graphics.setColorMode('replace')
    love.graphics.setColor(0, 0, 147, 150)
    love.graphics.rectangle('line', (zig.x - zig.ox) - 5, (zig.y - zig.oy) - 5, zig.width + 10, zig.height + 10)
end
function love.keypressed(key, u)
    if key == ' ' then
        pewpew.spawnProjectile('laser', zig.x, zig.y, 'up')
    end
end



pewpew = {}
function pewpew.spawnUnit(type, x, y)
    local unit = {}
    
    unit_types = {
       zig = {
           image = 'images/zig.gif'
          ,role = 'player'
      }
      ,raven = {
           image = 'images/enemy_black.gif'
          ,role = 'enemy'
      }
    }
    
    unit.image = love.graphics.newImage(unit_types[type].image)
    
    unit.width = unit.image:getWidth( )
    unit.height = unit.image:getHeight( )
    
    unit.ox = unit.width / 2
    unit.oy = unit.width / 2
    
    unit.x = x or unit.ox
    unit.y = y or unit.oy
    
    if unit_types[type].role == 'player' then
        zig = unit
    end
    
    if unit_types[type].role == 'enemy' then
        unit.direction = (#enemies % 2 > 0) and 'right' or 'left'
        enemies[#enemies + 1] = unit
    end
end
function pewpew.spawnProjectile(type, x, y, direction)
    local projectile = {
         type = type
        ,direction = direction
        ,line_x = x
        ,line_y = y
        ,line_x1 = x
        ,line_y1 = y - 10
    }
    
    projectiles[#projectiles + 1] = projectile
end

function pewpew.moveZig()
    if love.keyboard.isDown("right") then
        zig.x = zig.x + 2
    end
    
    if love.keyboard.isDown('left') then
        zig.x = zig.x - 2
    end
    
    if love.keyboard.isDown('up') then
        zig.y = zig.y - 2
    end
    
    if love.keyboard.isDown('down') then
        zig.y = zig.y + 2
    end
end
function pewpew.moveEnemies()
    for i, enemy in ipairs(enemies) do
        if enemy.direction == nil then enemy.direction = 'right' end
        
        if enemy.direction == 'right' then
            if enemy.x + enemy.ox < screen.width then
                enemy.x = enemy.x + 3
            else
                enemy.direction = 'left' 
            end
        end

        if enemy.direction == 'left' then
            if enemy.x - enemy.ox > 0 then
                enemy.x = enemy.x - 3
            else
                enemy.direction = 'right'
            end
        end
    end
end
function pewpew.moveProjectiles( )
    for i, p in ipairs(projectiles) do
        if p.type == 'laser' then
            love.graphics.setLine( 3, 'rough' )
            love.graphics.setColor( 255, 0, 0, 255 )
            love.graphics.line( p.line_x, p.line_y, p.line_x1, p.line_y1 )
        end
        
        if p.direction == 'up' then
            p.line_y = p.line_y - 4
            p.line_y1 = p.line_y1 - 4
        end
    end
end