require 'socket'
require 'pewpew'

-- <3
function love.load()
    local screen_modes = love.graphics.getModes()
    table.sort(screen_modes, function(a, b) return a.width * a.height < b.width * b.height end)
    love.graphics.setMode( screen_modes[#screen_modes].width, screen_modes[#screen_modes].height, true, true, 0 )
    
    pewpew.screen.width = love.graphics.getWidth( )
    pewpew.screen.height = love.graphics.getHeight( )
    
    love.graphics.setColorMode('replace')
    
    love.graphics.newFont(32) --not working? probably need custom font
    
    --pewpew.playMusic( )
end
function love.update(dt)
    if love.keyboard.isDown('return') and pewpew.playing == false then pewpew.start = true end
    if pewpew.start == true then
        pewpew.spawnUnit('zig', pewpew.screen.width / 2, pewpew.screen.height / 2)
        zig.render()
        
        pewpew.start = false
        pewpew.playing = true
    end
    if pewpew.playing == false then return end
    
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
    
    if love.keyboard.isDown(' ') and pewpew.timers.laser.ready( ) then
        pewpew.playSound('laser')
        pewpew.spawnProjectile('laser', zig.x, zig.y, 'up')
    end
end
function love.draw()
    
    if pewpew.playing == false then
        --title screen
        love.graphics.printf("pewpew, bitches\n(press enter)", 0, pewpew.screen.height / 2, pewpew.screen.width, 'center')
        return
    end
    
    
    pewpew.debug( )
    
    pewpew.moveZig( )
    pewpew.moveEnemies( )
    pewpew.moveProjectiles( )
    
    pewpew.checkCollisions( )
    
    love.graphics.printf(pewpew.score, 0, 20, pewpew.screen.width - 20, 'right')
    
    zig.draw()
    
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
        
        -- health bar
        love.graphics.setLine(1, 'rough')
        love.graphics.setColorMode('replace')
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.rectangle('line', enemy.x - enemy.ox, enemy.y - enemy.oy - 20, enemy.width, 10)
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle('fill', enemy.x - enemy.ox + 1, enemy.y - enemy.oy - 19, (enemy.width - 3) * (enemy.current_hp / enemy.total_hp), 8)
    end
end

function love.keypressed(key, u)
   --Debug mode go
   if key == "lctrl" then
      debug.debug()
   end
end