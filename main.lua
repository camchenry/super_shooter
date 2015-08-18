-- libraries
class = require 'libs.class'
vector = require 'libs.vector'
state = require 'libs.state'
tween = require 'libs.tween'
cron = require 'libs.cron'
shine = require 'libs.shine'
QuadTree = require 'libs.quadtree'
require 'libs.util'

-- gamestates
require 'states.menu'
require 'states.game'

-- entities
require 'entities.entity'
require 'entities.bullet'
require 'entities.player'
require 'entities.enemy'
require 'entities.boss.megabyte'

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