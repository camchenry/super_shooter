-- libraries
class = require 'libs.class'
vector = require 'libs.vector'
state = require 'libs.state'
tween = require 'libs.tween'
cron = require 'libs.cron'
shine = require 'libs.shine'
signal = require 'libs.signal'
QuadTree = require 'libs.quadtree'
serialize = require 'libs.ser'
require 'libs.util'

-- gamestates
require 'states.menu'
require 'states.game'
require 'states.options'
require 'states.pause'

-- entities
require 'entities.entity'
require 'entities.bullet'
require 'entities.player'
require 'entities.enemy'
require 'entities.boss.megabyte'
require 'entities.boss.arena'
require 'entities.fx.particle'
require 'entities.fx.shake'

require 'entities.sound.sound'

require 'entities.ui.button'
require 'entities.ui.checkbox'
require 'entities.ui.input'
require 'entities.ui.list'
require 'entities.ui.slider'

function love.load()
	love.window.setTitle(config.windowTitle)
    love.window.setIcon(love.image.newImageData(config.windowIcon))
	love.graphics.setDefaultFilter(config.filterModeMin, config.filterModeMax, config.anisotropy)
    love.graphics.setFont(font[16])

    math.randomseed(os.time()/10)

    crosshairImage = love.graphics.newImage("img/crosshair.png")
    cursorImage = love.graphics.newImage("img/cursor.png")
    crosshair = love.mouse.newCursor(crosshairImage:getData(), 16, 16)
    cursor = love.mouse.newCursor(cursorImage:getData(), 0, 0)
    love.mouse.setCursor(cursor)

    soundControl = Sound:new()

    if love.filesystem.exists("config.txt") then
        options:load()
    end

    state.registerEvents()
    state.switch(menu)
end

function love.keypressed(key, code)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, mbutton)

end

function love.textinput(text)
end

function love.resize(w, h)

end

function love.update(dt)
    tween.update(dt)
    soundControl:update(dt)
end

function love.draw()

end