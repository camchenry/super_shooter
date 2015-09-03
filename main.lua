-- libraries
class = require 'libs.class'
vector = require 'libs.vector'
state = require 'libs.state'
tween = require 'libs.tween'
cron = require 'libs.cron'
shine = require 'libs.shine'
beholder = require 'libs.beholder'
signal = require 'libs.signal'
QuadTree = require 'libs.quadtree'
require 'libs.util'

-- gamestates
require 'states.menu'
require 'states.game'
require 'states.upgrade'
require 'states.options'

-- entities
require 'entities.entity'
require 'entities.bullet'
require 'entities.player'
require 'entities.enemy'
require 'entities.boss.megabyte'
require 'entities.fx.particle'
require 'entities.fx.shake'

require 'entities.ui.button'
require 'entities.ui.checkbox'
require 'entities.ui.input'
require 'entities.ui.list'
require 'entities.ui.sidebarButton'

MOUSE_VALUE = 0

function love.load()
	love.window.setTitle(config.windowTitle)
    love.window.setIcon(love.image.newImageData(config.windowIcon))
	love.graphics.setDefaultFilter(config.filterModeMin, config.filterModeMax, config.anisotropy)
    love.graphics.setFont(font[16])

    state.registerEvents()
    state.switch(menu)

    math.randomseed(os.time()/10)
end

function love.keypressed(key, code)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, mbutton)
    if mbutton == "wd" then
        MOUSE_VALUE = MOUSE_VALUE - 1/1000
    elseif mbutton == "wu" then
        MOUSE_VALUE = MOUSE_VALUE + 1/1000
    end
end

function love.textinput(text)
end

function love.resize(w, h)

end

function love.update(dt)
    tween.update(dt)
end

function love.draw()

end