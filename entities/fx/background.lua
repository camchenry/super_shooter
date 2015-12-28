GridBackground = class("GridBackground")

function GridBackground:initialize()
	self.time = math.random(0, 10)

	self.hue = 0
	self.saturation = 100
	self.lightness = 40
end

function GridBackground:update(dt)
	self.time = self.time + dt

	self.hue = self.hue + dt*2
end

function GridBackground:draw()
	local zoom = math.abs(math.cos(self.time/16))*(1/2) + 2
	local rotation = math.sin(self.time/100)*math.pi
	local r, g, b = husl.husl_to_rgb(self.hue, self.saturation, self.lightness)
	local alpha = math.abs(math.cos(self.time/2.5))*255
	alpha = math.max(alpha, 64)

	love.graphics.setLineWidth(1)
	--love.graphics.setColor(255*math.abs(math.cos(self.time*0.125)), 255*math.abs(math.cos(self.time*.792)), 255*math.abs(math.sin(self.time*.349)), 16*math.abs(math.cos(self.time))+12)
    love.graphics.setColor(r*255, g*255, b*255, alpha)
    love.graphics.scale(zoom)
    love.graphics.rotate(rotation)
    quadtree:draw()
    love.graphics.rotate(-rotation)
    love.graphics.scale(1/zoom)

    love.graphics.setColor(255, 255, 255, 255)
end