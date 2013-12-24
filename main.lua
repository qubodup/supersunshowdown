--[[
Copyright © 2013 Iwan 'qubodup' Gabovitch <qubodup@gmail.com> <qubodup.net>
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

function love.load()
  success = love.window.setMode(800,600)

  gfx = {
    bothalive = love.graphics.newImage("gfx/bothalive.png"),
    bothaiming = love.graphics.newImage("gfx/bothaiming.png"),
    onedead = love.graphics.newImage("gfx/onedead.png"),
    bothdead = love.graphics.newImage("gfx/bothdead.png"),
    sun = love.graphics.newImage("gfx/sun.png"),
  }

  snd = {
    climax = love.audio.newSource("snd/climax.ogg"),
    music = love.audio.newSource("snd/music.ogg"),
    shot = love.audio.newSource("snd/shot.ogg"),
    boing = love.audio.newSource("snd/boing.ogg"),
  }

  -- font
  love.graphics.setFont(love.graphics.setNewFont('fnt/Sancreek.ttf', 24))

  -- timer, gets reset from time to time (at beginnings of stages)
  timer = 0

  -- global state (menu/game-situation) variable
  state = 0 -- 0 prestart, 1 intro, 2 buttonmashing, 3 endsequence, 4 outro

  -- global input variable
  spacepressed = false

  -- global mash variable (spash mash counter)
  mash = 0

  -- global win variable (true when success goal has been reached)
  win = false

end

function love.update(dt)
  timer = timer + dt

  -- state 0
  if state == 0 then
    if spacepressed then
      love.audio.stop(snd.climax)
      love.audio.play(snd.climax)
      state = 1
      spacepressed = false
      timer = 0
    end
  end
  if state == 1 then
    if timer == 0 then
      love.audio.play(snd.music)
    end
    if timer > 10 then
      state = 2
      spacepressed = false
      timer = 0
    end
  end
  if state == 2 then
    if timer == 0 then
      love.audio.play(snd.climax)
    end
    -- transfer spacepressed to energy
    if spacepressed then
      mash = mash + 1
      spacepressed = false
    end
    -- decide win or fail
    if mash > 39 then
      win = true
    end
    -- end of stage
    if win or timer > 6  then
      timer = 0
      state = 3
    end
  end
  if state == 3 and not win then
    if timer == 0 then
      -- shot sound
      love.audio.play(snd.shot)
    end
  elseif state == 3 and win then
    if timer == 0 then
      -- boing sounds
      love.audio.play(snd.boing)
    end
  end
  if state == 3 and timer > 11 then
    love.audio.play(snd.climax)
    spacepressed = false
    timer = 0
    state = 4
  end
  -- restart
  if state == 4 and spacepressed then
    love.audio.stop(snd.climax)
    love.audio.play(snd.climax)
    spacepressed = false
    mash = 0
    win = false
    timer = 0
    state = 0
  end
end

function love.draw()

  if state == 0 then
    love.graphics.draw(gfx.bothalive, 0, 0)
    love.graphics.draw(gfx.sun, 400 - 128, 200 - 128)
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("Press SPACE to start!", 280, 40)
    love.graphics.setColor(255,255,255,255)
  elseif state == 1 then
    -- move sun down slowly
    love.graphics.draw(gfx.bothalive, 0, 0)
    love.graphics.draw(gfx.sun, 400 - 128, 200 - 128 + 4*timer)
    
  elseif state == 2 then
    love.graphics.draw(gfx.bothalive, 0, 0)
    love.graphics.draw(gfx.sun, 400 - 128, 200 - 128 + math.floor(4*10))
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("Mash SPACE now!", 280, 40)
    love.graphics.rectangle("fill", 280, 68, 4*mash, 30)
    love.graphics.setColor(255,255,255,255)
  elseif state == 3 and not win then
    love.graphics.draw(gfx.bothdead, 0, 0)
    love.graphics.draw(gfx.sun, 400 - 128, 200 - 128 + math.floor(4*10))
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("Fail!", 280, 40)
    love.graphics.setColor(255,255,255,255)
  elseif state == 3 and win then
    if timer < 1 then
      love.graphics.draw(gfx.bothalive, 0, 0)
      love.graphics.draw(gfx.sun, 400 - 128, 200 - 128 + math.floor(4*10))
      love.graphics.setColor(0,0,0,255)
      love.graphics.print("Success!", 280, 40)
      love.graphics.setColor(255,255,255,255)
    elseif timer < 2 then
      love.graphics.draw(gfx.onedead, 0, 0)
      love.graphics.draw(gfx.sun, 150-128, 250)
      love.graphics.setColor(0,0,0,255)
      love.graphics.print("Success!", 280, 40)
      love.graphics.setColor(255,255,255,255)
    elseif timer < 3 then
      love.graphics.draw(gfx.bothdead, 0, 0)
      love.graphics.draw(gfx.sun, 550, 250)
      love.graphics.setColor(0,0,0,255)
      love.graphics.print("Success!", 280, 40)
      love.graphics.setColor(255,255,255,255)
    else
      love.graphics.draw(gfx.bothdead, 0, 0)
      love.graphics.setColor(0,0,0,255)
      love.graphics.print("Success!", 280, 40)
      love.graphics.setColor(255,255,255,255)
    end
  elseif state == 4 then
    love.graphics.print("Super Sun Showdown\nby Iwan Gabovitch\nstarted at Berlin Mini Jam\non May 11th 2013\n\nHit space to try again!", 280, 240)
  end

end

function love.keypressed(key)
   if key == " " then
     spacepressed = true
   elseif key == "escape" or key == "q" then
     love.event.push("quit")
   end
end
