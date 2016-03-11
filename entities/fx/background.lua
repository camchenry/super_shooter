GridBackground = class("GridBackground")

function GridBackground:initialize()
	self.time = math.random(0, 10)

    self.columns = 32 
    self.rows = 32
    self.width = 3000
    self.height = 2000

	self.hue = 0
	self.saturation = 100
	self.lightness = 40
end

function GridBackground:update(dt)
	self.time = self.time + dt

    if self.hue >= 360 then
        self.hue = 0
    end
	self.hue = self.hue + dt*2
end

function GridBackground:draw()
	local zoom = math.abs(math.cos(self.time/16))*(1/2) + 2
	local rotation = math.sin(self.time/100)*math.pi
	local r, g, b = husl.husl_to_rgb(self.hue, self.saturation, self.lightness)
	local alpha = math.abs(math.cos(self.time/2.5))*255
	alpha = math.max(math.min(alpha, 200), 64)
    
    love.graphics.push()
	love.graphics.setLineWidth(1)
    love.graphics.setColor(r*255, g*255, b*255, alpha)
    love.graphics.scale(zoom)
    love.graphics.rotate(rotation)
    love.graphics.translate(-self.width/2, -self.height/2)
    local xStep = self.width/self.columns
    local yStep = self.height/self.rows

    for x=0, self.width, xStep do
        love.graphics.line(x, 0, x, self.height)
    end
    for y=0, self.height, yStep do
        love.graphics.line(0, y, self.width, y)
    end

    love.graphics.pop()
    love.graphics.setColor(255, 255, 255, 255)
end
