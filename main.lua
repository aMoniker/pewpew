-- <3
function love.load()
    screen = {}
    screen.width = love.graphics.getWidth( )
    screen.height = love.graphics.getHeight( )
    
    zig = pewpew.makeUnit('zig', screen.width / 2, screen.height / 2);
    
    enemies = {}
    for i=1,3 do
        enemies[i] = pewpew.makeUnit('raven', i * 20 + 30, i * 20 + 30)
        enemies[i].direction = (i % 2 > 0) and 'right' or 'left'
    end
end
function love.draw()
    pewpew.moveZig( )
    pewpew.moveEnemies( )
    
    love.graphics.draw(zig.image, zig.x, zig.y, 0, 1, 1, zig.ox, zig.oy)
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, 1, 1, enemy.ox, enemy.oy)
    end
    
    --random rectangle
    love.graphics.setLineStyle('rough')
    love.graphics.setColorMode('replace')
    love.graphics.setColor(0, 0, 147, 150)
    love.graphics.rectangle('line', (zig.x - zig.ox) - 5, (zig.y - zig.oy) - 5, zig.width + 10, zig.height + 10)
end


pewpew = {}
function pewpew.makeUnit(type, x, y)
    local unit = {}
    
    ship_images = {
      ['zig'] = 'images/zig.gif',
      ['raven'] = 'images/enemy_black.gif'
    }
    unit.image = love.graphics.newImage(ship_images[type])
    
    unit.width = unit.image:getWidth( )
    unit.height = unit.image:getHeight( )
    
    unit.ox = unit.width / 2
    unit.oy = unit.width / 2
    
    unit.x = x or unit.ox
    unit.y = y or unit.oy
    
    return unit
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
            
            --break
        end

        if enemy.direction == 'left' then
            if enemy.x - enemy.ox > 0 then
                enemy.x = enemy.x - 3
            else
                enemy.direction = 'right'
            end
            
            --break
        end
    end
end