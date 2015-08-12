Entity = class('Entity')

function Entity:initialize()
	-- general properties
	self.color = {255, 255, 255, 255}
	self.radius = 15
	self.sides = 4

	-- physics
	self.position = vector(0, 0)
	self.velocity = vector(0, 0)
	self.acceleration = vector(0, 0)
	self.speed = 850
	self.dragFactor = 0.15

	self.width = self.radius * 2
	self.height = self.radius * 2
	self.x, self.y = self.position:unpack()
	self.prev_x, self.prev_y = self.position:unpack()
end

function Entity:physicsUpdate(dt)
	self.width, self.height = self.radius*2, self.radius * 2

	self.prev_x, self.prev_y = self.position:unpack()
	self.acceleration = self.acceleration - (self.acceleration * self.dragFactor)
	self.velocity = self.velocity - (self.velocity * self.dragFactor)
	self.velocity = self.velocity + self.acceleration * dt
	self.position = self.position + self.velocity * dt

	self.x, self.y = self.position:unpack()
end

function Entity:update(dt)

end

function Entity:draw()
	if self.lineWidth then
		love.graphics.setLineWidth(self.lineWidth)
	else
		love.graphics.setLineWidth(1)
	end

	love.graphics.push()
	local rgba = {love.graphics.getColor()}
	love.graphics.setColor(self.color)

	love.graphics.circle("line", self.position.x, self.position.y, self.radius, self.sides)

	love.graphics.setColor(rgba)
	love.graphics.pop()
	love.graphics.setLineWidth(1)
end