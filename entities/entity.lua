Entity = class('Entity')

function Entity:initialize()
	-- general properties
	self.color = {255, 255, 255, 255}
	self.radius = 25
	self.sides = 250
	self.lineWidth = 1
	self.width = self.radius * 2
	self.height = self.radius * 2

	-- physics
	self.position = vector(0, 0)
	self.velocity = vector(0, 0)
	self.oldVelocity = vector(0, 0)
	self.acceleration = vector(0, 0)
	self.speed = 250
	self.friction = 2
	self.x, self.y = self.position:unpack()
	self.prev_x, self.prev_y = self.position:unpack()

	self.destroy = false
end

function Entity:physicsUpdate(dt)
	self.width, self.height = self.radius*2, self.radius * 2

	self.prev_x, self.prev_y = self.position:unpack()

	-- verlet integration, much more accurate than euler integration for constant acceleration and variable timesteps
    self.acceleration = self.acceleration:normalized() * self.speed
    self.oldVelocity = self.velocity
    self.velocity = self.velocity + (self.acceleration - self.friction*self.velocity) * dt
    self.position = self.position + (self.oldVelocity + self.velocity) * 0.5 * dt

	self.x, self.y = self.position:unpack()

	if self.handleCollision then
		self:checkCollision(self.handleCollision)
	end
end

function Entity:update(dt)

end

function Entity:draw()
	love.graphics.setLineWidth(self.lineWidth)
	love.graphics.push()
	local rgba = {love.graphics.getColor()}
	love.graphics.setColor(self.color)
	
	love.graphics.circle("line", self.position.x, self.position.y, self.radius, self.sides)

	love.graphics.setColor(rgba)
	love.graphics.pop()
	love.graphics.setLineWidth(1)
end

function Entity:checkCollision(callback)
	local collidableObjects = quadtree:getCollidableObjects(self, true)
    for i, obj in pairs(collidableObjects) do

    	local aabbOverlapping = self.x + self.radius + obj.radius > obj.x 
			and self.x < obj.x + self.radius + obj.radius
			and self.y + self.radius + obj.radius > obj.y 
			and self.y < obj.y + self.radius + obj.radius

    	if (aabbOverlapping) then
        	callback(self, obj)
        end
    end
end

function Entity:handleCollision(obj)

end

function Entity:getX()
	return self.position.x
end

function Entity:getY()
	return self.position.y
end