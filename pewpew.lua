pewpew = {
     start = false
    ,playing = false
}
pewpew.screen = {}

pewpew.enemies = {}
pewpew.projectiles = {}

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
                zig.p = love.graphics.newParticleSystem(round_particle, 100)
                    local p = zig.p
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
                    p:setGravity(1500)
                    p:stop()

                zig.p1 = love.graphics.newParticleSystem(round_particle, 100)
                    local p1 = zig.p1
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
            ,draw = function()
                love.graphics.setColorMode('modulate')
                love.graphics.draw(zig.p, 0, 0)
                love.graphics.draw(zig.p1, 0, 0)
                love.graphics.setColorMode('replace')
                
                love.graphics.draw(zig.image, zig.x, zig.y, 0, 1, 1, zig.ox, zig.oy)
            end
      }
      ,raven = {
           image = 'images/enemy_black.gif'
          ,role = 'enemy'
          ,total_hp = 100
          ,current_hp = 100
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
        unit.direction = (#pewpew.enemies % 2 > 0) and 'right' or 'left'
        pewpew.enemies[#pewpew.enemies + 1] = unit
    end
end
function pewpew.spawnProjectile(type, x, y, direction)
    local projectile = {
          type = type
         ,x = x
         ,y = y
    }
    
    if type == 'laser' then
        local round_particle = love.graphics.newImage('images/part1.png');
        kk = love.graphics.newParticleSystem(round_particle, 100)
            kk:setEmissionRate(100)
            kk:setSpeed(50, 50)
            kk:setSize(0.2, 0.2)
            kk:setColor(255, 0, 0, 255, 255, 255, 255, 200)
            kk:setPosition(-900, -900)
            kk:setLifetime(200)
            kk:setParticleLife(0.1)
            kk:setDirection(7.851)
            kk:setSpread(1000)
            kk:setTangentialAcceleration(0)
            kk:setRadialAcceleration(1)
            kk:setGravity(150)
            kk:stop()
            

        kk2 = love.graphics.newParticleSystem(round_particle, 100)
            kk2:setEmissionRate(100)
            kk2:setSpeed(50, 0)
            kk2:setSize(0.3, 0.3)
            kk2:setColor(255, 100, 100, 200, 0, 0, 0, 0)
            kk2:setPosition(-900, -900)
            kk2:setLifetime(200)
            kk2:setParticleLife(0.5)
            kk2:setDirection(7.851)
            kk2:setSpread(100)
            kk2:setTangentialAcceleration(0)
            kk2:setRadialAcceleration(-100)
            kk2:setGravity(100)
            kk2:stop()
            
        projectile.kk = kk
        projectile.kk2 = kk2
    end
    
    pewpew.projectiles[#pewpew.projectiles + 1] = projectile
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
    for i, enemy in ipairs(pewpew.enemies) do
        if enemy.direction == nil then enemy.direction = 'right' end
        
        if enemy.direction == 'right' then
            if enemy.x + enemy.ox < pewpew.screen.width then
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
    for i, p in ipairs(pewpew.projectiles) do
        if p.type == 'laser' then
            p.y = p.y - 12
            p.kk:setPosition(p.x, p.y)
            p.kk2:setPosition(p.x, p.y)
            if p.y <= -1000 then table.remove(pewpew.projectiles, i) end
        end
    end
end

function pewpew.checkCollisions()
    for i, e in ipairs(pewpew.enemies) do
        for n, p in ipairs(pewpew.projectiles) do
            if pewpew.checkCollision(e.x - e.ox, e.y - e.oy, e.width, e.height * 0.6, p.x, p.y, 1, 1) then
                e.current_hp = e.current_hp - 10
                
                local hit_sound
                if(e.current_hp <= 0) then
                    hit_sound = love.audio.newSource('sound/explode.wav', 'static')

                    table.remove(pewpew.enemies, i)
                    --table.remove(pewpew.projectiles, n)
                else
                    hit_sound = love.audio.newSource('sound/hit.wav', 'static')
                end
                
                love.audio.play(hit_sound)
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