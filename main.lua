require 'socket'
require 'pewpew'

-- <3
function love.load()
    local screen_modes = love.graphics.getModes()
    table.sort(screen_modes, function(a, b) return a.width * a.height < b.width * b.height end)
    love.graphics.setMode( screen_modes[#screen_modes].width, screen_modes[#screen_modes].height, false, true, 0 )
    
    pewpew.screen.width = love.graphics.getWidth( )
    pewpew.screen.height = love.graphics.getHeight( )
    
    love.graphics.setColorMode('replace')
    
    pewpew.spawnUnit('zig', pewpew.screen.width / 2, pewpew.screen.height / 2)
    zig.render()
    
    --[[
    for i=1,3 do
        pewpew.spawnUnit('raven', i * 20 + 30, i * 20 + 30)
    end
    --]]
end
function love.update(dt)
    zig.update(dt)
    if #pewpew.enemies < 12 then
        pewpew.spawnUnit('raven', math.random(10, pewpew.screen.width - 10), math.random(50, 500))
    end
    
    for i, p in ipairs(pewpew.projectiles) do
        if p.type == 'laser' then
            p.kk:start()
            p.kk:update(dt)
            
            p.kk2:start()
            p.kk2:update(dt)
        end
    end
end
function love.draw()
    pewpew.debug( )
    
    love.graphics.setColorMode('modulate')
    love.graphics.draw(p, 0, 0)
    love.graphics.draw(p1, 0, 0)
    love.graphics.setColorMode('replace')
    
    pewpew.moveZig( )
    pewpew.moveEnemies( )
    pewpew.moveProjectiles( )
    
    pewpew.checkCollisions( )
    
    love.graphics.draw(zig.image, zig.x, zig.y, 0, 1, 1, zig.ox, zig.oy)
    
    for i, p in ipairs(pewpew.projectiles) do
        love.graphics.setColorMode('modulate')
        if p.type == 'laser' then
            love.graphics.draw(p.kk, 0, 0)
            love.graphics.draw(p.kk2, 0, 0)
        end
        love.graphics.setColorMode('replace')
    end
    
    for i, enemy in ipairs(pewpew.enemies) do
        love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, 1, 1, enemy.ox, enemy.oy)
        
        love.graphics.setLine(1, 'rough')
        love.graphics.setColorMode('replace')
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle('line', enemy.x - enemy.ox, enemy.y - enemy.oy - 20, enemy.width, 10)
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle('fill', enemy.x - enemy.ox + 1, enemy.y - enemy.oy - 19, (enemy.width - 3) * (enemy.current_hp / enemy.total_hp), 8)
    end
    
    if love.keyboard.isDown(' ') and pewpew.timers.laser.ready( ) then
        local laser_sound = love.audio.newSource('sound/laser.wav', 'static')
        love.audio.play(laser_sound)
        
        pewpew.spawnProjectile('laser', zig.x, zig.y, 'up')
    end
end