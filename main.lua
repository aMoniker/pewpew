require "socket"

-- <3
function love.load()
    local screen_modes = love.graphics.getModes()
    table.sort(screen_modes, function(a, b) return a.width * a.height < b.width * b.height end)

    love.graphics.setMode( screen_modes[#screen_modes].width, screen_modes[#screen_modes].height, false, true, 0 )
    --love.graphics.setMode(1000, 1000, true, true, 0)
    --love.graphics.toggleFullscreen( )
    --love.graphics.setBackgroundColor(0, 0, 100, 5)
    
    enemies = {}
    projectiles = {}
    screen = {}
    screen.width = love.graphics.getWidth( )
    screen.height = love.graphics.getHeight( )
    
    love.graphics.setColorMode('replace')
    
    pewpew.spawnUnit('zig', screen.width / 2, screen.height / 2)
    zig.render()
    
    for i=1,3 do
        pewpew.spawnUnit('raven', i * 20 + 30, i * 20 + 30)
    end
end
function love.update(dt)
    zig.update(dt)
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
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, 1, 1, enemy.ox, enemy.oy)
    end
    
    if love.keyboard.isDown(' ') and pewpew.timers.laser.ready( ) then
        pewpew.spawnProjectile('laser', zig.x, zig.y, 'up')
    end
    
    --[[random rectangle
    love.graphics.setLine( 1, 'rough' )
    love.graphics.setColorMode('replace')
    love.graphics.setColor(0, 0, 147, 150)
    love.graphics.rectangle('line', (zig.x - zig.ox) - 5, (zig.y - zig.oy) - 5, zig.width + 10, zig.height + 10)
    --]]
end

pewpew = {}
pewpew.debug_queue = {}
pewpew.timers = {}
pewpew.timers.laser = {
     delay = 200
    ,last_fired = nil
    ,ready = function()
        if not pewpew.timers.laser.last_fired then
            pewpew.timers.laser.last_fired = socket.gettime()*1000
            return true
        end
        
        local time = socket.gettime() * 1000
        if time - pewpew.timers.laser.last_fired >= pewpew.timers.laser.delay then
            pewpew.timers.laser.last_fired = socket.gettime()*1000
            return true
        end
        return false
     end
}

function pewpew.spawnUnit(type, x, y)
    local unit = {}
    
    unit_types = {
        zig = {
            image = 'images/zig.gif'
            ,role = 'player'
            ,render = function()
                -- shouldn't be using globals in these functions
                round_particle = love.graphics.newImage('images/part1.png');
                zig.p = love.graphics.newParticleSystem(round_particle, 1000)
                    p = zig.p
                    p:setEmissionRate(300)
                    p:setSpeed(50, 50)
                    p:setSize(1.5, 0.1)
                    p:setColor(0, 50, 255, 255, 0, 0, 150, 0)
                    p:setPosition(400, 300)
                    p:setLifetime(0)
                    p:setParticleLife(0.05)
                    p:setDirection(7.851)
                    p:setSpread(0)
                    p:setTangentialAcceleration(0)
                    p:setRadialAcceleration(1)
                    p:setGravity(15)
                    p:stop()

                zig.p1 = love.graphics.newParticleSystem(round_particle, 1000)
                    p1 = zig.p1
                    p1:setEmissionRate(300)
                    p1:setSpeed(100, 150)
                    p1:setSize(0.8, 0.1)
                    p1:setColor(255, 255, 255, 200, 200, 0, 0, 100)
                    p1:setPosition(400, 300)
                    p1:setLifetime(0)
                    p1:setParticleLife(0.05)
                    p1:setDirection(7.853)
                    p1:setSpread(0)
                    p1:setTangentialAcceleration(0)
                    p1:setRadialAcceleration(1)
                    p1:setGravity(15)
                    p1:stop()
            end
            ,update = function(dt)
                zig.p:setPosition(zig.x, zig.y + 1)
                zig.p:start()

                zig.p1:setPosition(zig.x, zig.y + 1)
                zig.p1:start()

                zig.p:update(dt)
                zig.p1:update(dt)
            end
      }
      ,raven = {
           image = 'images/enemy_black.gif'
          ,role = 'enemy'
      }
    }
    
    unit = unit_types[type]
    
    unit.image = love.graphics.newImage(unit_types[type].image)
    
    unit.width = unit.image:getWidth( )
    unit.height = unit.image:getHeight( )
    
    unit.ox = unit.width / 2
    unit.oy = unit.width / 2
    
    unit.x = x or unit.ox
    unit.y = y or unit.oy
    
    if type == 'zig' then
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
    local speed = 6
    if love.keyboard.isDown("right") then
        zig.x = zig.x + speed
    end
    
    if love.keyboard.isDown('left') then
        zig.x = zig.x - speed
    end
    
    if love.keyboard.isDown('up') then
        zig.y = zig.y - speed
    end
    
    if love.keyboard.isDown('down') then
        zig.y = zig.y + speed
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
function pewpew.moveProjectiles()
    for i, p in ipairs(projectiles) do
        if p.type == 'laser' then
            love.graphics.setLine( 3, 'rough' )
            love.graphics.setColor( 255, 0, 0, 255 )
            love.graphics.line( p.line_x, p.line_y, p.line_x1, p.line_y1 )
        end
        
        if p.direction == 'up' then
            p.line_y = p.line_y - 10
            p.line_y1 = p.line_y1 - 10
            if p.line_y <= 0 then table.remove(projectiles, i) end
        end
    end
end

function pewpew.checkCollisions()
    for i, e in ipairs(enemies) do
        for n, p in ipairs(projectiles) do
            if pewpew.checkCollision(e.x,e.y,e.width,e.height, p.line_x-1,p.line_y1,3,10) then --hardcoded line values not good
                --enemies.remove(e)
                --projectiles.remove(e)
                table.remove(enemies, i)
                table.remove(projectiles, n)
            end
        end
    end
end
function pewpew.checkCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
    local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
    return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

function pewpew.debug( obj )
    if obj ~= nil then
        pewpew.debug_queue[#pewpew.debug_queue + 1] = obj
    else
        local x = 10
        local y = 10
        for i, obj in ipairs(pewpew.debug_queue) do
            love.graphics.print( tostring(obj), x, y, 0, 1, 1 )
            y = y + 10
        end
    end
end