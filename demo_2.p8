pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--variables 
s=1 --starting sprite value
d=2 --delay for sprite cylce
jumping = false --boolean for jumping
j = 0 --timer for jump cooldown
g = 0 --timer for gravity accl.
max_g=15 -- max gravity accl.
f=false --boolean for sprite flip
a=false --boolean for animation
p={}   --the player table
p.x=64 --player  x position (left)
p.y=64 --player y variable (top)

---------------------ims
p.w=8 --player width
p.h=8 --player height
p.hurt=false --was the player hurt?
p.hc=2 -- frames of hurt
-- simple camera
cam_x=0
cam_y=0
p.crouching=false
p.standing=true -- only turns false when crouching or jumping
p.walking=false -- tracks if the player is walking
p.cs=true -- remembers if the player can stand
-- enemy (only one)
ene={}
ene.s=16
ene.x=150
ene.y=88
ene.action="left" -- goes either left or right
ene.found=false -- did the enemy find the player?
ene.flp=false
ene.hp=2

-- anim tables
walk={1,2,3,4}
jump={6,7,1} -- midair,impact,norm

---------------------ims


by=71  --player x position (right)
rx=71  --player y position (bottom)
ytile = 0 --
ybound = 0
move = 4
jready = true --boolean for jump readyness
w1 = 0
w2 = 0

--------------------------------* kylie
tile_x = 0
tile_y = 0
map_tile = 0
flag_tile = 0


local hook_x, hook_y = -100 -- position of the grappling hook at its current position
local hook_launched = false -- flag to track whether the grappling hook has been launched
local rope_length = 20 -- rope length (adjust as needed)
local hook_speed = 4 -- hook speed (adjust as needed)
local grappling_hook_sprite = 49 --the end of the grapple

local player_speed = 2
----------------------------------*kylie

hp = 10
max_hp = 15

-----> menu init
scene ="menu" --starting game state (main menu)

gem_count=0 -- green gem count

dmgtimer = 0 -- dmg cooldown
dmgcounter = 0 -- freezes damage
-->8
-- draw --

----------------------------------#kylie
-- define off-screen coordinates
local offscreen_x = -100
local offscreen_y = -100

-- define rope start and end coordinates
local rope_start_x = offscreen_x
local rope_start_y = offscreen_y
local rope_end_x = offscreen_x
local rope_end_y = offscreen_y

-- define rope visibility flag
local hook_launched = false
----------------------------------#kylie

-- _draw func
function _draw()
  if scene=="menu" then
  	draw_menu()
  elseif scene=="game_easy" then
  	draw_game()
	draw_enemy_health()
	handle_grapple_enemy_collision()
  elseif scene=="game_hard" then
  	draw_game()
	draw_enemy_health()
	handle_grapple_enemy_collision()
  end
end -- end of _draw

-- draws the hearts on the
-- top of the screen
function draw_health()
	local hx=p.x-60  --init heart x
	local hy=p.y-60  --init heart y
		
	for i=1,hp do
		spr(9,hx,hy)
		hx=hx+8
	end -- end of for loop
	
end --end of draw_health

-->8
-- damage enemies collision -- 
function handle_grapple_enemy_collision()
    if hook_launched then
        local dx = rope_end_x - hook_x
        local dy = rope_end_y - hook_y
        local distance = sqrt(dx * dx + dy * dy)

        if distance > 1 then
            local hook_direction_x = dx / distance
            local hook_direction_y = dy / distance

            for i = 1, 10 do  -- Assuming 10 segments, adjust as needed
                local segment_x = hook_x + i * (dx / 10)
                local segment_y = hook_y + i * (dy / 10)

                -- Check for collision with the enemy
                if damage_grapple_collision(segment_x, segment_y, 6) then
                    ene.hp = max(0, ene.hp - 1)  -- Reduce enemy health by 1

                    if ene.hp == 0 then
                        ene.s = 0  -- Set the enemy sprite to 0 or any other value to indicate disappearance
                    end

                    hook_launched = false
                    print("Enemy hit!")  -- Add this line to print when the enemy is hit
                    break  -- Stop checking further segments if there's a collision
                end
            end
        else
            hook_launched = false
        end
    end
end

-- draws the gem count
-- on the bottom of the screen
function draw_gem_count()
	local hx=p.x-60
	local hy=p.y+60
	
	spr(12,hx,hy) -- draws gem sprite
	print("x"..gem_count,hx+8,hy+2,7)
end -- end of d_g_c


-->8
-- update --

function _update()
	if scene=="menu" then
		update_menu()
	elseif scene=="game_easy" then
		update_game()
	elseif scene=="game_hard" then
		update_game()
	end
end -- end of _update


-- updates player animation
function animate()
	d=d-1
	
	-- change the animation spot
	if p.hurt==true then  --doesnt work??
		d=2
		s=8
	elseif p.crouching==true then
		d=2
		s=5	
	elseif jumping==true then
		d=2
		s=6
	elseif p.standing==true and p.walking== false then
		d=2
		s=1
	elseif d<0 and p.walking then
		s=s+1
		if s>4 then s=1 end
		d=2
	end
end -- end of animate


//jump function 
function jump(j,w1,w2)
		//h is the max jump height
	h=12
	//loop from h to 1
	//finds the max height the player can jump without colliding with a wall
	for i=h,1,-1 do
		if((collision(p.x,p.y-i,3)==true) or (collision(rx,p.y-i,3)==true)) then  
	 		h=i+1
		end
	end
	//the player jumps higher the first 2 frames 
	if (j>3) then
		p.y-=h/3
		--pushes the player off the wall if wall jumping
		if (w1>0) then
			p.x+=3
		end
		--pushes the player off the wall if wall jumping
		if (w2>0) then
			p.x-=3
		end
	end
	//the player jumps lower the second 2 frames 
	if (j>1) and (j<4) then
		p.y-=h/6
	end
end -- end of jump


-->8
-- shadow mask --
-- ims

-- before the level is drawn
function shadow_mask()
	if scene=="game_easy" then
		clip(30,30,70,70) --easy mode shadow
	elseif scene=="game_hard" then
		clip(40,40,50,50) --hard mode shadow
	end
end -- end of shadow_mask

-->8
-- enemy health bar -- 
function draw_enemy_health()
    local bar_width = 10  -- Adjust the width of the health bar as needed
    local bar_height = 0   -- Adjust the height of the health bar as needed
    local health_percent = ene.hp / max_hp

    -- Calculate the position for the health bar
    local bar_x = ene.x - (bar_width - 1) / 2
    local bar_y = ene.y - bar_height - 1

    -- Calculate the width of the filled part based on the health percentage
    local filled_width = bar_width * health_percent

    -- Draw the background of the health bar (empty part) in red
    rectfill(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, 8)

    -- Draw the actual health part of the health bar, with color based on health percentage
    local health_color = flr(8 * (1 - health_percent)) + 8
    rectfill(bar_x, bar_y, bar_x + filled_width, bar_y + bar_height, health_color)
end


-->8
-- collision --

function collision(x,y,f)
 // postion of the tile 
 // containing the input 
 // coordinates
 local tilex = ((x-(x%8))/8)
	local tiley = ((y-(y%8))/8)
	
	//checks if the given tile has flag f
	//returns true if so
	if(fget(mget(tilex,tiley),f) )then
		return true
	end
	
	return false 
end -- end of collision


-- enemy collision --
function enemy_collision(pl,en)
	

	return false
end -- end of enemy_collision

-->8
-- enemy damage collision -- 
function damage_grapple_collision(x, y, f)
    local tile_x = flr(x / 8)
    local tile_y = flr(y / 8)
    if fget(mget(tile_x, tile_y), f) then
					--dmgtimer = 3 -- if colliding, mark with timer
					return true --collision detected
				end
			return false
end



	
	
-->8
-- grapple collision --
-- kylie
function grapple_collision(x,y,f)
 local tile_x = flr(x / 8)
 local tile_y = flr(y / 8)
    
 map_tile = mget(tile_x, tile_y)
 flag_tile = fget(map_tile)

 local tile_left = mget(tile_x, tile_y) -- check the current tile and adjacent tiles
 local tile_right = mget(tile_x + 1, tile_y)
 local tile_up = mget(tile_x, tile_y - 1)
 local tile_down = mget(tile_x, tile_y + 1)

 -- check if the current tile or any adjacent tile has the specified flag (4 in this case)
 if fget(tile_left, f) or fget(tile_right, f) or fget(tile_up, f)  then
  return true -- collision detected
 end
    
  return false
end
----------------------------------&kylie
-->8
-- enemy ai --
-- very simplistic, just goes
-- back and forth

function enemy_movement()
	eby=ene.y+7
	erx=ene.x+7
	
	-- determines where the enemy
	-- is in comparison to the player
	if ene.x > p.x then
		ene.flp=false
		ene.action="left"
	else
		ene.flp=true
		ene.action="right"
	end
	
	
	-- enemy is going left
	if ene.action=="left" then
		-- if enemy is going left and runs into wall
		-- turn around and move right
		if not((collision(ene.x-1,ene.y,3)==true) and (collision(ene.x-1,eby,3)==true)) then
			ene.x-=0.50
		end
	end
	
	-- enemy is going right
	if ene.action=="right" then		
		-- if enemy is going right and runs into wall
		-- turn around and move left
		if not((collision(erx+1,ene.y,3)==true) and (collision(erx,eby,3)==true)) then
			ene.x+=0.50
		end
	end
	

end -- end of enemy_ai


-- check if the enemy can jump
function enemy_jump()
	--

end -- end of enemy_jump
-->8
-- draw_game --

-- draw menu screen
function draw_menu()
	cls()
	print("diver: ruins resurfaced", 18, 53)
	print("press z to start in easy mode", 5, 63)
	print("press x to start in hard mode", 5, 73)
end


-- draw_game
function draw_game()
cls()
  --check if player is alive
  if (hp>0) then
  
  	------------------ims
  	-- draw health ui
	  draw_health()
	  
	  -- draw gem ui
	  draw_gem_count()
	  
	  -- shadow mask
	  shadow_mask()
	  ------------------ims
	  
	  
	  //draw map
	  map(0,0,0,0,128,50)
	  
	  //draw player
	  spr(s,p.x,p.y,1,1,f)
	  
	  -- draw enemy
  spr(ene.s,ene.x,ene.y,1,1,ene.flp)
	  
	  ----------------------------------$kylie
		// draw the grappling hook as a line
		// line(hook_x, hook_y, p.x, p.y, 8)
			  -- draw the rope if it's visible
			  if hook_launched then
		 local num_segments = 10  -- adjust the number of rope segments as needed
		 local segment_length_x = (rope_end_x - hook_x) / num_segments
		 local segment_length_y = (rope_end_y - hook_y) / num_segments
	  
		 for i = 1, num_segments do
		  local segment_x = hook_x + i * segment_length_x
		  local segment_y = hook_y + i * segment_length_y

		-- Check for collision with the enemy
		  if damage_grapple_collision(segment_x, segment_y, 6) then
			ene.hp = max(0, ene.hp - 1)  -- Reduce enemy health by 1

			if ene.hp == 0 then
				ene.s = 0  -- Set the enemy sprite to 0 or any other value to indicate disappearance
			end

			hook_launched = false
			print("Enemy hit!")  -- Add this line to print when the enemy is hit
			break  -- Stop checking further segments if there's a collision
		  end
		  -- check for collision with flag 4 (ice tiles)
		  if grapple_collision(segment_x, segment_y, 3) then
		   p.x = hook_x
		   p.y = hook_y
		   break  -- stop the rope when it hits a flag 4 tile
		  end
	  
		-- Assuming this is the line where you draw the rope segment
			if i < num_segments then
				-- Use sprite #48 for other segments
				spr(48, segment_x, segment_y, 1, 1)
			else

					-- Use sprite #49 for other directions
					if p.left then
						-- Hook is moving left
						spr(49, segment_x, segment_y, 1, 1, true)
					
					elseif p.right then
						-- Hook is moving right
						spr(0, segment_x, segment_y, 1, 1, true)  -- Flip sprite for right
					
					elseif p.up then
						-- Hook is moving up
						spr(50, segment_x, segment_y, 1, 1, true)
					end
				
				end
	end
end
	  
			//print debugging info
			--print("x"..p.x)
			--print("y"..p.y)
			--print("rx"..rx)
			--print("by"..by)
		  ----------------------------------$kylie
	
	  	//print debugging info
	  	--print("x"..p.x)
	  	--print("y"..p.y)
	  	--print("rx"..rx)
	  	--print("by"..by)
	    
	   
	  
	   
		----------------------------------$kylie
  --game over logic
  else 
  	map(0,0,0,0,128,20)
  	print("game over",p.x-8,p.y,8)
  end
end
-->8
-- update_game --

-- update menu
function update_menu()
	if btnp(4) then --o
		scene="game_easy"
		hp=max_hp
	end
	if btnp(5) then --x
		scene="game_hard"
	end
end -- end of update_menu()


-- updates game
function update_game()
	--check if player is alive
if (hp>0) then
-- check if player is damaged
if dmgcounter>0 then
	dmgcounter = dmgcounter-1
else
----------------------------------<3kylie
	 -- grappling hook logic
	 if btnp(4) then -- "z" key
		 local hook_direction_x = 0
		  local hook_direction_y = 0
	
		  if btn(0) then  -- left button pressed
		   hook_direction_x = -1
		end
	   if btn(1) then  -- right button pressed
		hook_direction_x = 1
		end
	   if btn(2) then  -- up button pressed
		hook_direction_y = -1
		end
	
	   if hook_direction_x ~= 0 or hook_direction_y ~= 0 then
		hook_launched = true
		hook_x = p.x  -- set the hook's starting x coordinate
		hook_y = p.y  -- set the hook's starting y coordinate
	
		-- calculate the direction and distance
		local direction_length = sqrt(hook_direction_x^2 + hook_direction_y^2)
		local hook_dx = hook_direction_x / direction_length * rope_length
		local hook_dy = hook_direction_y / direction_length * rope_length
	
		rope_end_x = hook_x + hook_dx -- endpoint x coordinate
		rope_end_y = hook_y + hook_dy -- endpoint y coordinate
		print(grappling_hook_sprite, rope_end_x, rope_end_y, 1, 1)
	
		-- increase player speed while using the grappling hook
		player_speed = hook_speed
	   end
	 end
	
	 if hook_launched then
	 
	  local dx = rope_end_x - hook_x -- horizontal distance the hook has moved
	  local dy = rope_end_y - hook_y -- vertical distance
	  local distance = sqrt(dx * dx + dy * dy) -- calculate the distance
	
	  if distance > 1 then
	   local hook_direction_x = dx / distance
	   local hook_direction_y = dy / distance
	
	   -- update the player's position
	   --p.x = hook_x
	   --p.y = hook_y
	
	   -- check for collision with background platforms for the rope
	   if grapple_collision(hook_x, hook_y, 3) then
		p.x = hook_x
		p.y = hook_y
	
		hook_launched = false
		
		-- adjust the player's position to the end of the rope
		--p.x -= 0.5
		--p.x = rope_end_x
		--p.y = rope_end_y
	
	   end
	   hook_x = hook_x + hook_direction_x * hook_speed --segments
	   hook_y = hook_y + hook_direction_y * hook_speed
	   -- adjust the hook_x and hook_y to stop just before the platform
	   --local tile_x = flr(hook_x / 8) -- assuming 8x8 pixel tiles
	   --local tile_y = flr(hook_y / 8)
	   --hook_x = tile_x * 8 - hook_direction_x * hook_speed
	   --hook_y = tile_y * 8 - hook_direction_y * hook_speed
	   --end
	   --end
	   -- check if the hook reaches the screen edge
	   if hook_x < 0 or hook_x > 1000 or hook_y < 0 or hook_y > 1000 then
		hook_launched = false
	   end
	   else
		hook_launched = false
	   end
	  end
	
		-- check if the "z" button is pressed to retract the grappling hook
		if btnp(5) then
			hook_launched = false
			player_speed = 2
		end
	----------------------------------<3kylie

	//set animation bool to false 
 a=false
 p.standing=true -- automatically standing
 p.walking=false

	-- simplistic enemy movement
	enemy_movement()
	
	
	
	
 
 --spike detecion
 if ((collision(p.x,by,6)==true) and (collision(rx,by,6)==true)) then 
		--move player to last safe tile
		p.y = gy*8
		p.x = gx*8
		--turn off gravity and decrement health
		p.hurt=true
		dmgcounter=15
		g=0
		jumping=true 
		hp-=1
		dmgtimer=5
 end
 
 //gravity controls,
 //runs while the player is in the air and not jumping
 if((jumping == false) and (collision(p.x,by+1,3)==false) and (collision(rx,by+1,3)==false)) then
		if g < max_g then
			//increment gravity timer
			g+=0.75
		end
		--move player 
		if ((collision(p.x,by+g*(5/12),3)==false) and (collision(rx,by+g*(5/12),3)==false)) then	
			p.y=p.y+g*(5/12)
		--move player by an adjusted amount if they would be moving into the floor
		else 
			p.y=8*(((p.y+g*(5/12))-((p.y+g*(5/12))%8))/8)
		end
	end
	
	
	
	//jump controls 	
	//call jump function with jump varables  cooldown
	jump(j,w1,w2)
	--decrement wall jump timers
	if(w1>0) then
		w1-=1
	end
	if(w2>0) then
		w2-=1
	end
	
	//decrement jump cooldown while its non zero 
	if(j>0) then
		j-=1
	end
	
	
	//check if jump cooldown is over
	if(j==0) then
		jumping=false
	end
	
	//check if player is ready to 
	//jump
	//runs when the player is 
	//standing on the ground
	if((collision(p.x,by+1,3)==true) or (collision(rx,by+1,3)==true)) then
 	//enable jumping
 	jready = true
 	//reset gravity timer
 	g=0
 	//save player position (last safe tile)
 	if((collision(p.x,by+1,3)==true) and (collision(rx,by+1,3)==true)) then
 		gx = ((p.x-(p.x%8))/8)
 		gy = ((p.y-(p.y%8))/8)
 	end
 end
 
 //adjust bottom and right player coordinates
 by=p.y+7
 rx=p.x+7
 
 if(dmgtimer > 0) then
		dmgtimer = dmgtimer-1
	end
	
	if(dmgtimer == 0) then
		p.hurt = false
	end
	
	--very quick enemy detection
	if (ecollision(ene.x+1,ene.x+6,ene.y,ene.y+7,p.x,rx,p.y,by) and (dmgtimer == 0)) then
	 p.hurt=true
	 hp-=1
	 dmgtimer = 10
	end
	
 //left controlls
 if btn(0) then
 	
 	-- checks if the player is crouching
  -- and next to a half-wall
  if((collision(p.x-1,p.y,5)==true) and (collision(p.x-1,by,5)==true)) then
  		if p.crouching==true then
  			p.x-=1
  		end 
 	//checks if there is a wall 
 	//where the player will be 
 	//moving to
 	//runs if there is no wall 
 	//detected
 	elseif((collision(p.x-1,p.y,3)==false) and (collision(p.x-1,by,3)==false)) then
 		p.walking=true
 		p.standing=false
 		//move player to the left
 	 p.x-=1
 	 //flip player sprite
  	f=true
  	//start animation
  	a=true
  end
  //checks if an ice wall is detected where the player will be moving
  //runs if an ice wall is detected
  if((collision(p.x-1,p.y,4)==true) and  (collision(p.x-1,by,4)==true)) then
 	 //halt gravity
 	 jumping=true
 	 //enable jumping if cooldown is over
 	 if (j==0) then
 	 	jready=true
 	 end
 	 --reset gravity timer and set wall jump timer
 	 g=0
 	 w1=2
  end
  
 end
 
 //right controls 
 if btn(1) then
 	
 	if((collision(rx+1,p.y,5)==true) and (collision(rx+1,by,5)==true)) then
  		if p.crouching==true then
  			p.x+=1
  		end
 	//checks if there is a wall where the player will be moving to
 	//runs if there is no wall detected
 	elseif((collision(rx+1,p.y,3)==false) and (collision(rx+1,by,3)==false)) then
 	 p.walking=true
 		p.standing=false
 	 //move player to the right
 	 p.x+=1
 	 //flip player sprtie
 	 f=false
 	 //start animation
 	 a=true
  end
  //checks if there is an ice wall where the player will be moving to
 	//runs if there is an ice wall detected
  if((collision(rx+1,p.y,4)==true) and (collision(rx+1,by,4)==true)) then
 	 //halt gravity
 	 jumping=true
 	 //enable jumping if cooldown is over
 	 if (j==0) then
 	 	jready=true
 	 end
 	 --reset gravity timer and set wall jump timer
 	 g=0
 	 w2=2
  end
 end
 
 //up controls 
 if btn(2) then
	 //checks if the player is able to jump
	 //runs if so
	 if(jready) then
	 	//checks if there is a wall where the player will move
	 	//runs if no wall is detected
		 if((collision(p.x,p.y-1,3)==false) and (collision(rx,p.y-1,3)==false)) then 
	 	 p.standing=false
	 	 //halt gravity
	 	 jumping = true
	 	 //start animation
	 	 a=true
	 	 //disable jumping
	 	 jready = false
	 	 //set jump cooldown
	 	 j=5
	 	end
	 end
	end
 
 ---------------ims
	-- crouch
	if btn(⬇️) then
		p.crouching=true
		p.standing=false
		p.walking=false
		a=true
	else
		if p.cs then -- only activates if player can stand
			p.standing=true
			p.crouching=false
		end
	end -- end of ⬇️
	
	---------------ims
 
 //call animation funtion if 
 //there is active animation
 if a then animate() end
 
 --simple camera movement
 cam_x=p.x-64+(p.w/2)
 cam_y=p.y-64+(p.w/2)
 camera(cam_x,cam_y)
	end -- end of dmgcounter if statement
	end -- end of 
	-- adds sound effects to the
	-- game
	update_sound()
	
end -- end of update_game()


-- sound effects
function update_sound()
	-- checks to see if sound is
	-- already playing
	local i=stat(16) 
 
 if i>-1 then 
   elseif (btn(2)) then sfx(02)
 end

end -- end of update_sound()
-->8
--parameters,
--exl = left x pos of eneme
--exr = right y pos of enemy
--eyt = top y pos of enemy
--eyb = bottom y pos of enemy
--lx = left x pos of player
--rx = right x pos of player
--ty = top y pos of player
--by = bottom y pos of plauer
function ecollision(exl,exr,eyt,eyb,lx,rx,ty,by)
	collison = false 
	if((by>=eyt) and (by<=eyb)) then
		if((rx>=exl) and (rx<=exr)) then
			collison = true
		end
		if((lx>=exl) and (lx<=exr)) then
			collison = true
		end
	end
	if((ty>=eyt) and (ty<=eyb)) then
		if((rx>=exl) and (rx<=exr)) then
			collison = true
		end
		if((lx>=exl) and (lx<=exr)) then
			collison = true
		end
	end
	return collison
end
__gfx__
0000000000ccaac00000000000ccaac000ccaac00000000000ccaac0000000000088888000000000000000000000000000000000000880000000000000000000
000000000cd6996000ccaac00cd699600cd69960000000000cd6996000ccaac008888880022022000000000000000000000b7000008788000000000000000000
007007000d4144100cd699600d4144100d414410000000000d4144100cd699600888888028827720000000000700000000b37700087788800000000000000000
00077000004444400d414410004444400044444000000000004444400d414410008888802888772000000700776000000b3bb770877788880000000000000000
0007700004cccc000044444004cccc0004cccc000ccaacc004cccc004044444008888800288888200700766076600600033bb3b0eeee22220000000000000000
0070070040cccc0004cccc0040cccc0040cccc00456996544066666004cccc008088880002888200766076d076d076d000333b000eee22200000000000000000
0000000000666660406666dd0066666000dd66600414414000d000d000666660008888800028200076d06dd066d07dd00003b00000ee24000000000000000000
0000000000dd00dd00dd000000dd00dd000000ddd6cccc6d0d000d0000dd0dd00088008800020000ddd0ddd0ddd0ddd000000000000e40000000000000000000
000010100000101000001010000010100101000c0000000000000000000000000000000000000000ddd0ddd0ddd0ddd000000000000000000000000000000000
000100010001000100010001000100011000100001010000000000000000000000000000000000006dd06dd06dd06dd000000000000000000000000000000000
00111111001111110011111100111111119111901000100c0000000000000000000000000000000066d076d076d06dd000000000000000000000000000000000
0091910000919100009191000091910000191900119111900000000000000000000000000000000076d00700070066d000000000000000000000000000000000
0011110000111100001111000011110010911190001919000000000000000000000000000000000007000000000076d000000000000000000000000000000000
00011110000111100001111000011110011110000191119000000000000000000000000000000000000000000000070000000000000000000000000000000000
00011101001111010001110100011101001110001011100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010100000001000001010000010000010001000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000
92aaa999424424244244242444444444444444444444444444999999999999449999994444999999444444444444444499999944999999990000000000000000
94aa9999441444444414444499999999999999994499999944999999999999449999994444999999444444444444444499999944999999990000000000000000
4141444499499999994aaa9999999999999999994499999944999999999999449999994444999999449999999999994499999944999999990000000000000000
9994aaa999499999944aa99944444444444444444444444444999999999999449999994444999999449999999999994499999944999999990000000000000000
9994aa99441414444414144499999999999999994499999944999999999999449999994444999999449999999999994499999944999999990000000000000000
41414244a9a94aa9aaa94aa999999999999999994499999944999999999999449999994444999999449999999999994499999944999999990000000000000000
a4aaa9a999994999aa99499944444444444444444444444444999999999999449999994444444444449999999999994444444444999999990000000000000000
a4999999444414444444144444444444444444444499999944999999999999449999994444444444449999999999994444444444999999990000000000000000
000000000000000000066d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000007700007060d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000700700600d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000dd0000060700600d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000ddd666660000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000d0000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000d0000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000dd00000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccccccccccccccccccc7ccccccc777ccccc7ccccccc7ccccccc766ccccc07777777777777777777777777777777
00000000ccccccccc77cccccccc7cccccccccccccccccccccccccccc7ccccccc777ccccc7ccccccc6ccccccc776ccccc7777cccccccccccc777cccccccccc777
00000000ccccccccc77cc7cccccccccccccccccccccccccccccccccc7ccccccc77cccccc7ccccccc7ccccccc77cccccc777ccccccccccccc77cccccccccccc77
00000000ccccccccccccccccccccc77ccccccccccccccccccccccccc7ccccccc7ccccccc7ccccccc7ccccccc77cccccc77cccccccccccccccccccccccccccccc
00000000ccccccccccccccccccccc77ccccccccccccccccccccccccc77cccccc7ccccccc77cccccc7ccccccc7ccccccc7ccccccccccccccccccccccccccccccc
00000000ccccccccccccc7ccccccccccccccc777ccc77ccc77cccccc777ccccc77cccccc77cccccc6ccccccc7ccccccc7ccccccccccccccccccccccccccccccc
00000000ccccccccccc7cc7ccc7ccccccccc7777cc7777cc7777cccc7777cccc777ccccc777ccccc6ccccccc7ccccccc7ccccccccccccccccccccccccccccccc
00000000cccccccccccccccccccccccc77777777667777677777777707777777777ccccc777ccccc7ccccccc7ccccccc7ccccccccccccccccccccccccccccccc
7777677777777771ccccccc7ccccccc7ccccc777ccccc777ccccccc707777777077777777777777777777777777777777777777077777770cccccccc07777770
7776c777cccc7777ccccccc7ccccccc7ccccc777ccccc777ccccccc777cccccc77cccccccccccccccccccccccccccccccccccc77cccccc77cccccccc77ccccc7
77cccc77ccccc777ccccccc7ccccccc7cccccc77cccccc77ccccccc77cccccc77ccccccccccccccccccccc7cccc77cccccccccc7ccccccc7cccccccc7ccc7cc7
cccccccccccccc77ccccccc7ccccccc7ccccccc7ccccccc7ccccccc77ccccccc7cccccccccccccccccc7ccccccc77ccccc7cccc7ccccccc7cccccccc7c7cccc7
ccccccccccccccc7ccccccc7ccccccc7ccccccc7ccccccc7cccccc777ccccccc7cccccccccccccccc77cccccccccc77cccc77cc7ccccccc7cccccccc7ccc77c7
ccccccccccccccc7ccccccc7cccccc77cccccc77ccccccc7ccccc7777cc7cccc7cccccccccccccccc77cccccc7ccc77cccc77cc7ccccccc7cccccccc7ccc77c7
ccccccccccccccc7ccccccc7ccccc777ccccc777ccccccc7cccc777777cccccc77cccccccccccccccccccccccccccccccccccc77cccccc77cccccccc7ccccc77
ccccccccccccccc7ccccccc7ccccc777ccccc777ccccccc777777770077777770777777777777777777777777777777777777770777777707777777707777770
07777770711111777111177771111117711111170777777007777770777777777777777707777777777777777777777700007000007000000000000001111111
77cccc77711117777111771771111117711111177711117700777700777777707777777700777077777777777777777700077000007000000007000000111111
7cccccc7711177777117711771111117711111177111111700777700077777000777777700777077777777777777777000077000007700000007000000111111
7cccccc7711777177177111771111117711111177111111700777000007770000777777700070077770707777770777000077700077707000077000000111111
7cccccc7717771177771111771111117711111177111111700077000007770000077707000000077770707777770770000077700077707007077707000111111
7cccccc7777711177711111771111117711111177111111700077000000700000077700000000077770007700700770000077700077707007077707000111111
77cccc77777111177111111771111117771111777111111700007000000000000007000000000077770007000700770000777700077777707777777000111111
07777770771111777111111771111117077777707111111700007000000000000007000000000007700000000000700007777770777777777777777700111111
1111111011111100001111110011111111111100ccccccccccccc77cccccccc77ccccccc7cccccc77cccccc70777777000000000000000000000000000000000
1111110011111100001111110011111111111100ccccccccccccc77cccccccc77ccccccc7cccccc77cccccc77cccccc700000000000000000000000000000000
1111110011111100001111110011111111111100cccccccccc7cccccccccccc77ccccccc7cccccc77cccccc77cccccc700000000000000000000000000000000
1111110011111100001111110011111111111100777777777777777777777770077777777cccccc77cccccc77cccccc700000000000000000000000000000000
1111110011111100001111110011111111111100000000000000000000000000000000007cccccc77cccccc77cccccc700000000000000000000000000000000
1111110011111100001111110011111111111100000000000000000000000000000000007cccccc77cccccc77cccccc700000000000000000000000000000000
1111110011111100001111110011111111111100000000000000000000000000000000007cccccc77cccccc77cccccc700000000000000000000000000000000
111111001111110000111111011111111111111000000000000000000000000000000000077777707cccccc77cccccc700000000000000000000000000000000
14140000141414001414140014141414141414141414140000000000140000000014140000001414141414141414141414141414141414141414141414141414
1414d4d4d4d4d4141414141414141414141414141414141414140000141414141414141414141414141414141414141414000000001414141414141414141414
14140000141414001414141414141414141414141414141414141414141414141400000000000000000000000000000000000014141414141414141414141414
14141414141414141414141414141414141414141414141400000014141414141414141414141414141414141414141414141414000000141414141414141414
14140000141414001414141414141414141414141414141414141414141414141414141414141414141414141414141414140000000000141414141414141414
14141414141414141414141414141414141414141414000000141414141414141414141414141414141414141414141414141414141400001414141414141414
14140000141414001414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414000000141414141414
14141414141414141414141414000000000000000000001414141414141414141414141414141414141414141414141414141414141414001414141414141414
14140000141414000014141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141400000000001414
14141414141414141414140000001414141414141414141414141414141414141414141414141414141414141414141414141414141414140014141414141414
14140000141414140014141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414140000
00000000000000000000000014141414141414141414141414141414141414141414141414141414141414141414141414141414141414140000141414141414
14140000141414140014141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141400141414141414
14140000141414141400141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14140000141414141400000000141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14140000141414141400001400000000000000141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14140000141414141414140000141414141414000000000000000014141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14140000141414141414141400000014141414141414141414140000000000000000141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14140000141414141414141414141400000014141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14000000141414141414141414141414140000000000000000141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14000000141414141414141414141414141414141414141414000000000000001414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414
14000000141414141414141414141414141414141414141414141414141414141400000000000000000014141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141400001414141414
14000000141414141414141414141414141414141414141414141414141414141414141414141414140000000000000000000000000000141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141400141414141414
14140000141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414001414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414140000141414141414
14140000141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414000000141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414000014141414141414
14141400141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414000000140000
00000000000000001400140014001400001400001400000000141414141414141414141414141414141414141414141414141400000000001414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414000000000000000000000014141414141414141414000000000014141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141400000000000000000000001414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
14141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414
__label__
46645664666466444664554444446664444555444444554444445544444455444444444444444444444444445500004444445544444455444445554444445544
64446564464465646444564444446564455554445555554455555544455455444444444444444444444444445477774545545544444455444555544444445544
65446464464464646664444445446464555554444455444444554444455444444444444444444444444444444400004445544444454444445555544445444444
65556465465564654565464545556465455444554455445544554455454444554444444444444444444444445477775445444455455544454554445545554445
46656645666564656655444545556665455444554444445544444455454555554444444444444444444444445400005445455555455544454554445545554445
44555444445554444455544444555444445555544444455444444554444554444444444444444444444444444477775544455444445554444455555444555444
54444444544444445444444454444444544555545445555454455554544444454444444444444444444444444400004554444445544444445445555454444444
55444554554445545544455455444554554455545444455454444554554544554444444444444444444444445477774555454455554445545544555455444554
44445544444455444444554444445544444455444444554444444444444444444444444444444444444444445500004444444444444455444444554444445544
44445544444455444444554444445544555555444554554444444444444444444444444444444444444444445477774544444444455455445555554455555544
45444444454444444544444445444444445544444554444444444444444444444444444444444444444444444400004444444444455444444455444444554444
45554445455544454555444545554445445544554544445544444444444444444444444444444444444444445477775444444444454444554455445544554455
45554445455544454555444545554445444444554545555544444444444444444444444444444444444444445400005444444444454555554444445544444455
44555444445554444455544444555444444445544445544444444444444444444444444444444444444444444477775544444444444554444444455444444554
54444444544444445444444454444444544555545444444544444444444444444444444444444444444444444400004544444444544444455445555454455554
55444554554445545544455455444554544445545545445544444444444444444444444444444444444444445477774544444444554544555444455454444554
44445544444455444444554444445544444444444444444444444444444444444444444444444444444444445500004444444444444455444444554444445544
55555544555555445555554455555544444444444444444444444444444444444444444444444444444444445477774544444444444455445555554455555544
44554444445544444455444444554444444444444444444444444444444444444444444444444444444444444400004444444444454444444455444444554444
44554455445544554455445544554455444444444444444444444444444444444444444444444444444444445477775444444444455544454455445544554455
44444455444444554444445544444455444444444444444444444444444444444444444444444444444444445400005444444444455544454444445544444455
44444554444445544444455444444554444444444444444444444444444444444444444444444444444444444477775544444444445554444444455444444554
54455554544555545445555454455554444444444444444444444444444444444444444444444444444444444400004544444444544444445445555454455554
54444554544445545444455454444554444444444444444444444444444444444444444444444444444444445477774544444444554445545444455454444554
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444445500004444444444444444444444554444445544
44444444444444444444444441cccc11144444444444444444444444444444444444444444444444444444445477774544444444444444444444554445545544
44444444444444444444444441c1c111144444444444444444444444444444444444444444444444444444444400004444444444444444444544444445544444
4444444444444444444444444cc11c1cc44444444444444444444444444444444444444444444444444444445477775444444444444444444555444545444455
4444444444444444444444444c1cc11c144444444444444444444444444444444444444444444444444444445400005444444444444444444555444545455555
4444444444444444444444444111cccc144444444444444444444444444444444444444444444444444444444477775544444444444444444455544444455444
4444444444444444444444444ccc1c1cc44444444444444444444444444444444444444444444444444444444400004544444444444444445444444454444445
4444444444444444444444444c11c111c44444444444444444444444444444444444444444444444444444445477774544444444444444445544455455454455
444444444444444444444444411ccc11c44444444444444444445544444455444444444444444444444444445500004444444444444444444444444444444444
44444444444444444444444444444444444444444444444455555544555555444444444444444444444444445477774544444444444444444444444444444444
44444444444444444444444444444444444444444444444444554444445544444444444444444444444444444400004444444444444444444444444444444444
44444444444444444444444444444444444444444444444444554455445544554444444444444444444444445477775444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444455444444554444444444444444444444445400005444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444554444445544444444444444444444444444477775544444444444444444444444444444444
44444444444444444444444444444444444444444444444454455554544555544444444444444444444444444400004544444444444444444444444444444444
44444444444444444444444444444444444444444444444454444554544445544444444444444444444444445477774544444444444444444444444444444444
44444444444455444444554444444444444444444444444444444444444455444444554444445544444455445500004444445544444444444444444444444444
44444444455455444554554444444444444444444444444444444444555555444554554455555544455455445477774545545544444444444444444444444444
44444444455444444554444444444444444444444444444444444444445544444554444444554444455444444400004445544444444444444444444444444444
44444444454444554544445544444444444444444444444444444444445544554544445544554455454444555477775445444455444444444444444444444444
44444444454555554545555544444444444444444444444444444444444444554545555544444455454555555400005445455555444444444444444444444444
44444444444554444445544444444444444444444444444444444444444445544445544444444554444554444477775544455444444444444444444444444444
44444444544444455444444544444444444444444444444444444444544555545444444554455554544444454400004554444445444444444444444444444444
44444444554544555545445544444444444444444444444444444444544445545545445554444554554544555477774555454455444444444444444444444444
44444444444444444444554444455544444455444444444444444444444444444444554444445544444455445500004444445544444455444444444444444444
44444444444444444444554445555444444455444444444444444444444444445555554444445544444455445477774545545544555555444444444444444444
44444444444444444544444455555444454444444444444444444444444444444455444445444444454444444400004445544444445544444444444444444444
44444444444444444555444545544455455544454444444444444444444444444455445545554445455544455477775445444455445544554444444444444444
44444444444444444555444545544455455544454444444444444444444444444444445545554445455544455400005445455555444444554444444444444444
44444444444444444455544444555554445554444444444444444444444444444444455444555444445554444477775544455444444445544444444444444444
44444444444444445444444454455554544444444444444444444444444444445445555454444444544444444400004554444445544555544444444444444444
44444444444444445544455455445554554445544444444444444444444444445444455455444554554445545477774555454455544445544444444444444444
44445544444444444445554444445544444455444444444444444444444444444444554444445544444455445500004444445544444555444444444444444444
45545544444444444555544455555544455455444444444444444444444444445555554455555544444455445477774545545544455554444444444444444444
45544444444444445555544444554444455444444444444444444444444444444455444444554444454444444400004445544444555554444444444444444444
45444455444444444554445544554455454444554444444444444444444444444455445544554455455544455477775445444455455444554444444444444444
45455555444444444554445544444455454555554444444444444444444444444444445544444455455544455400005445455555455444554444444444444444
44455444444444444455555444444554444554444444444444444444444444444444455444444554445554444477775544455444445555544444444444444444
54444445444444445445555454455554544444454444444444444444444444445445555454455554544444444400004554444445544555544444444444444444
55454455444444445544555454444554554544554444444444444444444444445444455454444554554445545477774555454455554455544444444444444444
444455444444554444445544444455444444554444445544444455444444444448e88e8444444444444444445500004444444444444444444444444444444444
55555544555555445555554444445544444455444444554455555544444444444877678444444444444444445477774544444444444444444444444444444444
44554444445544444455444445444444454444444544444444554444444444444e67768444444444444444444400004444444444444444444444444444444444
445544554455445544554455455544454555444545554445445544554444444448e678e444444444444444445477775444444444444444444444444444444444
44444455444444554444445545554445455544454555444544444455444444444488e84444444444444444445400005444444444444444444444444444444444
444445544444455444444554445554444455544444555444444445544444444446d8856444444444444444444477775544444444444444444444444444444444
54455554544555545445555454444444544444445444444454455554444444445444444d44444444444444444400004544444444444444444444444444444444
54444554544445545444455455444554554445545544455454444554444444444d65d65444444444444444445477774544444444444444444444444444444444
44444444444455444445554444445544444455444444554444455544444444444444444444444444444444445500004444444444444444444444444444444444
44444444555555444555544444445544444455444444554445555444444444444444444444444444444444445477774544444444444444444444444444444444
44444444445544445555544445444444454444444544444455555444444444444444444444444444444444444400004444444444444444444444444444444444
44444444445544554554445545554445455544454555444545544455444444444444444444444444444444445477775444444444444444444444444444444444
44444444444444554554445545554445455544454555444545544455444444444444444444444444444444445400005444444444444444444444444444444444
44444444444445544455555444555444445554444455544444555554444444444444444444444444444444444477775544444444444444444444444444444444
44444444544555545445555454444444544444445444444454455554444444444444444444444444444444444400004544444444444444444444444444444444
44444444544445545544555455444554554445545544455455445554444444444444444444444444444444445477774544444444444444444444444444444444
44444444444444444444444444455544444555444445554444455544444444444444444444444444444444445500004444444444444455444444554444445544
44444444444444444444444445555444455554444555544445555444444444444444444444444444444444445477774544444444455455444554554445545544
44444444444444444444444455555444555554445555544455555444444444444444444444444444444444444400004444444444455444444554444445544444
44444444444444444444444445544455455444554554445545544455444444444444444444444444444444445477775444444444454444554544445545444455
44444444444444444444444445544455455444554554445545544455444444444444444444444444444444445400005444444444454555554545555545455555
44444444444444444444444444555554445555544455555444555554444444444444444444444444444444444477775544444444444554444445544444455444
44444444444444444444444454455554544555545445555454455554444444444444444444444444444444444400004544444444544444455444444554444445
44444444444444444444444455445554554455545544555455445554444444444444444444444444444444445477774544444444554544555545445555454455
44445544444444444444444444445544444455444444554444444444444444444444444444444444444444445500004444444444444455444444554444455544
45545544444444444444444445545544455455444554554444444444444444444444444444444444444444445477774544444444555555444444554445555444
45544444444444444444444445544444455444444554444444444444444444444444444444444444444444444400004444444444445544444544444455555444
45444455444444444444444445444455454444554544445544444444444444444444444444444444444444445477775444444444445544554555444545544455
45455555444444444444444445455555454555554545555544444444444444444444444444444444444444445400005444444444444444554555444545544455
44455444444444444444444444455444444554444445544444444444444444444444444444444444444444444477775544444444444445544455544444555554
54444445444444444444444454444445544444455444444544444444444444444444444444444444444444444400004544444444544555545444444454455554
55454455444444444444444455454455554544555545445544444444444444444444444444444444444444445477774544444444544445545544455455445554
44455544444444444444444444444444444444444444444444444444444555444444554444444444444444445500004444455544444455444444554444455544
45555444444444444444444444444444444444444444444444444444455554444444554444444444444444445477774545555444555555444444554445555444
55555444444444444444444444444444444444444444444444444444555554444544444444444444444444444400004455555444445544444544444455555444
45544455444444444444444444444444444444444444444444444444455444554555444544444444444444445477775445544455445544554555444545544455
45544455444444444444444444444444444444444444444444444444455444554555444544444444444444445400005445544455444444554555444545544455
445555544444444444444444444444444444444444aaaa4444444444445555544455544444444444444444444477775544555554444445544455544444555554
54455554444444444444444444444444444444444aaa77a444444444544555545444444444444444444444444400004554455554544555545444444454455554
55445554444444444444444444444444444444444a7aa7a444444444554455545544455444444444444444445477774555445554544445545544455455445554
44445544444455444444444444444444444444444a77aaa444444444444555444445554444445544444444445500004444445544444455444444554444455544
55555544555555444444444444444444444444444aa77aa444444444455554444555544445545544444444445477774545545544444455444444554445555444
445544444455444444444444444444444444444444aaaa4444444444555554445555544445544444444444444400004445544444454444444544444455555444
44554455445544554444444444444444444444444444444444444444455444554554445545444455444444445477775445444455455544454555444545544455
44444455444444554444444444444444444444444444444444444444455444554554445545455555444444445400005445455555455544454555444545544455
44444554444445544444444444444444444444444444444444444444445555544455555444455444444444444477775544455444445554444455544444555554
54455554544555544444444444444444444444444444444444444444544555545445555454444445444444444400004554444445544444445444444454455554
54444554544445544444444444444444444444444444444444444444554455545544555455454455444444445477774555454455554445545544455455445554
44445544444455444445554444444444444444444444444444444444444455444444554444444444444444445500004444445544444455444444554444445544
44445544555555444555544444444444444444444444444444444444455455444554554444444444444444445477774545545544455455444554554455555544
45444444445544445555544444444444444444444444444444444444455444444554444444444444444444444400004445544444455444444554444444554444
45554445445544554554445544444444444444444444444444444444454444554544445544444444444444445477775445444455454444554544445544554455
45554445444444554554445544444444444444444444444444444444454555554545555544444444444444445400005445455555454555554545555544444455
44555444444445544455555444444444444444444444444444444444444554444445544444444444444444444477775544455444444554444445544444444554
54444444544555545445555444444444444444444444444444444444544444455444444544444444444444444400004554444445544444455444444554455554
55444554544445545544555444444444444444444444444444444444554544555545445544444444444444445477774555454455554544555545445554444554
44445544444455444444554444445544444455444444444444444444444444444444444444444444444444445500004444444444444455444444554444445544
55555544444455445555554445545544455455444444444444444444444444444444444444444444444444445477774544444444444455444444554444445544
44554444454444444455444445544444455444444444444444444444444444444444444444444444444444444400004444444444454444444544444445444444
44554455455544454455445545444455454444554444444444444444444444444444444444444444444444445477775444444444455544454555444545554445
44444455455544454444445545455555454555554444444444444444444444444444444444444444444444445400005444444444455544454555444545554445
44444554445554444444455444455444444554444444444444444444444444444444444444444444444444444477775544444444445554444455544444555444
54455554544444445445555454444445544444454444444444444444444444444444444444444444444444444400004544444444544444445444444454444444
54444554554445545444455455454455554544554444444444444444444444444444444444444444444444445477774544444444554445545544455455444554

__gff__
0000000000000000000040400200000049494949000000000000404000000000080808080808080808080808080800000000000000000000000000000000000000080808080808080808080808080808080808080808080808080808080808080818181818180000000000000000000000000000002020202008080800000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414141414141414141414141414141414141414141414141414141414241414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
414141414141414141414141414141424141414141414241414141414142414141414141414141414141414141414141414141414141415e5e5e41414141414141414141414141414141414141414141414141414141414141414142414143414141414141414141414141414141414141414141414141414141414141414141
4141414141414141414141414143414141415e5e5e5e5e5e5e5e5e5e5e5e5e414141414141414142414141414141414141414141414152000000475e4143415e4544465e5e5e5e414241414141414141434141414141414141414341414141414141414141414141414141414141414141414141414141414141434141414141
4142415e41414141414141414241414141525f00006667676f706a6b0000674a41414141414141414141414141434141414141414141520c00000000475e5600660067686b6b0047455e5e5e5e5e455e5e5e5e4544465e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e415e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e414141
4141525f4a4341414141414141414141415600000000000072710000000000475e414141434145444641414141414141414141414141415100000000000000000000000000000000000000000000006f7000686800000000000000000000000000000069696a0000006a6b007a000000000066666f70006f706a6a6b004a4143
4141414d41414141414141414141414156660000000000007271000000000000004a424141520000004745414143414141414141414141414d4f4e4d4d4d5c0000000000000000000000000000000072710000000000000000000000000000000000000000000000000000007a000000000000007271007271000000004a4241
41415e455e5e5e5e44465e455e5e5e5600000000000000007271000000000000004a4141415600000066684a414141414141414141414141414141414152650000000000000000000000006e6d6e0073740000000000000000000000000000000000000000000000000000007a0000000000000073746c7374000000004a4141
41530000660000000000000068696a00000000000000000073740000000000006d787675770000000000004a41424141414142414141414141414141415262000057595c5f58594d4d4d4f504e4d4d4d4d4d4d4f4e4d51650000000000000058595d0000000000000000000079000000004c4d4d4d4d4d4d5100000000494141
41540000000000000000000000000000000000000000004c4d4d510000004c4d4d4f504e516500000000004a43414141414141414341414141414141415261000000000000000047414141415e5e5e45455e5e414141526300005859595c0000000000585c005f0060000000000000004c414142414141415200000000484141
41550c6c00000000000000006e000000000000000000004a4141520000004a414143414152630000000000475e5e5e5e5e5e5e455e4446455e4142414152610000000000000000654a415e56000066660000004742415262000000000000000000000000000000000000000000006c6d4a41414142414141520b0b00004b4141
41414d515f4c4d4f4e4f504e4d51000000000000004c4d41414341515f4c41414141414152610000000000006b6a69000000000000000000004741414152620000000000000000634a52650000000000000000004741526100000000000058595d00000000000000000000005859595941415e5e5e5e41415e595c0000474141
414142414d414141424141414141510000000000004a4141414141414d414141414141415262000000000000000000000000000000000000000047414152640000000000000000634a5262000000000000000000654a52610000000000000000000000000000000000000000000000004a52000000004a520000000000654a41
5f4141414341414141415e414141414d4f504e4d4d414142414141414141414141414142526400006c6d000058595c00006d6e6d00000000000000475e5e595d5f5759595c0000614a526300000000000c000000624a52620000000000000000007b00000000000000000000000000004a520000000047560000000000624a41
414141414141414141525f4a41434141414141414141414141415e414141414141414141414d4f504e4d5100000000004c4d4f504e510000000000696f706b6700000000000000624a5263000000006000000000634a52640000000000000000005f0058595d000000000000000000004a520c00000000000000000000614a41
4141414141414142415e595e5e5e5e5e5e4446455e5e5e5e5e565f475e5e5e4141414141414141414141520a0a0b0b0a4a42414141415100000000007271000000000000000000644a526200005f0a0a0a5f0000614a414d4d51000000000000006600000000007b00000000000000004a414d4d4d4d4d650000000000624941
414141414446455e566668686a000000000000000000000000000000000000475e414141414141424141414d4d4d4d4d4141414141434151000000007271000000000000004c4d4d4152620000585959595c0000624a42414352000000000000000000000000007a6c6d6c000000000c4a414141414141610000000000634841
414141560000007a00000000000000414141414f50504e4f4e4d4d4d4d51000000475e5e4141414141414141414141414141414141414141510000007374000000006c6d004a4141425264000000474156000000644a414141414d4d4d4d4d4d4d4d4d4d4d4d4d414d4d4d4d4d4d4d4d414141414141416100000a0a0b644b41
414152000000007a000000000000000041414141414141414141434141414d5100000000474544465e5e5e5e5e5e5e5e4141414141414141414f5050504e4d4d4d4d4d4d4d414241415e5c000000657a650000584d414143414141414141414141414141414141414142415e4141414141414141414141620000585a594d4141
41415600004c4d4d5100000000000000414141414141414142414141414141414f4e51000000000000000000000000004a415e44464541414141414141415e5e5e5e5e5e4141415e560000000000617a610000004741414141414141414141424141415e41414141414152604a41414141414141414141630000006900494141
41410000004141414100000000000000414141414141414141414141414141414141414d4d4d4f504e4d4d5100000000475600000000474141415e5e5e56000000000000475e5600000000000000617a620000000047414341414241414141414141525f4a4141414141414d41415e5e5e454446455e56640000000000484141
41410000004141414100000000000000414141414141414141414141414141414141414141414141414141414d4d510000000000000000475e560000000000000000000065000000000000000000627a620000000000475e5e5e5e5e5e454544465e5e595e5e5e4141414141415600000069696600006600000000000d4b4141
414100004141414141410041414141414141414141414141414141414141414141414141424141414141414143414159594d4d5c000000006b660000000000000000000062000000000000000000647a646d6d00000000696a6b000000000000000000006767004a41414141525f0000000000000000000000004c4d4d414141
414100004141414141000041414141414141414141414141414141414141414141414141414141414141414141415600004756000000600000000000000000005f000000630000000000574f504e4d414d4f4e51000000000000000000000000000000000000004a41414141415d00000000000000000000004c414141414241
41410000414141414100000000000000000041000000000000414141414141414141414141414141414141415e5600000000000000000000000000000000000a0b0a0000630000000000004941414141424141414d510000000000006c000000000000000000007875757576770000000000000000000000004a414141414141
41410000414141410000004141414141414141414141414100000041414141414141414141414141414141520c000000000000005f00000000000000000000585a5d0000610000000000004b414241424141414141414d4d510000007b00007b00007b00004c4d4d4d4d4d4d4d4d510a0a0b7b0b0b7b0a0b4c4141415f4a4141
41410000414141410041000041414141414141414141414141410000414141414141414141414141414141414d4d4d51006c6c00006d6d6000000000000000657a6500006200000a0b0b0a4a414141414141414141414341520a0a0b7a0a0a7a0a0a7a0a0a4a4141414141414141414d4d4d414d4d414d4d414141414d414141
4141000041414100004100000041414141414141414141414141410000414141414141414141414141414141414241414d4f504e4f4e4d4d51000000000000627a610000640000654c4d4d41414141414141414141414141414d4f4e414d4d414d4d414d4d414141414141414341414141414141414141414141414143414141
4141000041414100414141000000414141414141414141414141414100004141414141414141414141414141414141414141414141414141414d5100000000647a610000000000624a41414141414141414141414141414141424141414141424141414141414141414141414141414141414141414141414141434141414141
41410000414141004141410041000041414141414141414141414141410000414141414141414141414141414141414341414141414143414141414d4f504e4d52620000000000624a41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
4141000041414100414141004141414100004141414141414141414141410000414141414141414141414141414141414141414141414141414341414141414152630000000000634a41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
41410000414141004141410041414141410000004141414141414141414141410041414141414141414141414141414141414141414141414141414141434141526400005f0000644a41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141
4141000041414100414141004141414141414141000000414141414141414141410000004141414141414141414141414141414141414141414141414141414141520a0a0b0a0b4c4141414141414141414141414141414141414100000000000000000000000000000000000000000000004141414141414141414141414141
__sfx__
000100000071001710037100671007710057100372002720007200072001720037200572007720097200a72009720077200572002720007200072002720047200675008750097500875005750027500075014700
011000000a1500015000150011500115001150001500015001150021500415002150221502515027150281501c1501715013150101500d1500015001150011500115001150011500115000150001500015000150
000200000677008770097600a7600a7500b7500c7400d7400e7200e72000000317002d7003400039700000000000000000000000000000000000003a000357003000032700000000000000000000000000000000
__music__
00 01424344

