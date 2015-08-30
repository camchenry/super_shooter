upgrades = {}

UpgradeBox = class('UpgradeBox')

function UpgradeBox:initialize(x, y, w, h, title, text, img)
    self.x, self.y = x, y
    self.width, self.height = w, h

    self.image = nil

    if img ~= nil then
        if type(img) == "string" then
            self.image = love.graphics.newImage(img)
        else
            self.image = img
        end
    end

    self.title = title
    self.text = text

    self.black, self.white = {0, 0, 0}, {255, 255, 255}
    self.foreground = self.white
    self.background = self.black

    self.x = self.x - self.width/2
end

function UpgradeBox:update(dt)
    local mx, my = love.mouse.getX(), love.mouse.getY()

    if (mx >= self.x and mx <= self.x+self.width and
       my >= self.y and my <= self.y+self.height) or self.selected then

        self.background = self.white
        self.foreground = self.black
    else
        self.background = {0, 0, 0, 0}
        self.foreground = self.white
   end
end

function UpgradeBox:mousepressed(x, y, button)
    self.selected = (x >= self.x and x <= self.x+self.width and
                     y >= self.y and y <= self.y+self.height)
end

function UpgradeBox:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)
    --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.image, self.x+self.width/2-self.image:getWidth()/2, self.y+25)

    love.graphics.setColor(self.foreground)
    if self.title then
        love.graphics.setFont(fontBold[24])
        local text = self.title
        local x = self.x+self.width/2 - love.graphics.getFont():getWidth(text)/2
        local y = self.y+self.image:getHeight()+45
        love.graphics.print(text, x, y)
    end
    if self.text then
        love.graphics.setFont(font[18])
        local text = self.text
        local x = self.x+self.width/2 - love.graphics.getFont():getWidth(text)/2
        local y = self.y+self.image:getHeight()+75
        love.graphics.print(text, x, y)
    end
end

function upgrades:addElement(e)
    table.insert(self.elements, e)
    return e
end

function upgrades:init()
	self.bits = 0
    self.enemyObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.elements = {}

    self.box1 = self:addElement(UpgradeBox:new(love.graphics.getWidth()/2-250, 300, 250, 250, "DEFENSIVE", "+15 health", "img/defensive.png"))
    self.box2 = self:addElement(UpgradeBox:new(love.graphics.getWidth()/2+250, 300, 250, 250, "OFFENSIVE", "+5 damage", "img/offensive.png"))
end

function upgrades:enter()
    love.mouse.setCursor(cursor)
end

function upgrades:update(dt)
    for i, e in ipairs(self.elements) do
        e:update(dt)
    end

    for i, e in ipairs(self.elements) do
        if e.selected then
            self.confirmVisible = true
            break
        else
            self.confirmVisible = false
        end
    end
end

function upgrades:draw()
    love.graphics.setColor(255, 255, 255)
    pause_effect(function()
        game:draw()
    end)

    love.graphics.setColor(0, 0, 0, 80)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255)

    love.graphics.setFont(fontLight[50])
    local text = "CHOOSE AN UPGRADE"
    local x = love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(text)/2
    local y = 150
    love.graphics.print(text, x, y)

    if self.confirmVisible then
        love.graphics.setFont(font[36])
        local text = "CONTINUE"
        local x = love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(text)/2
        local y = love.graphics.getHeight()-150
        love.graphics.print(text, x, y)
    end

    for i, e in ipairs(self.elements) do
        e:draw()
    end
end

function upgrades:keypressed(key, isrepeat)

end

function upgrades:mousepressed(x, y, button)
    for i, e in ipairs(self.elements) do
        e:mousepressed(x, y, button)
    end

    if self.confirmVisible then
        if y >= love.graphics.getHeight() - 200 then
            state.switch(game)
        end
    end
end

function upgrades:onEnemyDeath(enemy)
    if enemy:isInstanceOf(LineEnemy) then
        self.bits = self.bits + 10
    elseif enemy:isInstanceOf(Blob) then
        self.bits = self.bits + 5
    end
end

function upgrades:areAvailable() 
	return self.bits > 35
end