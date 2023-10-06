pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--variables
s=1 --starting sprite value
d=2 --delay for sprite cylce
jumping = false --boolean for jumping
j = 0 --timer for jump cooldown
g = 0 --timer for gravity accl.
f=false --boolean for sprite flip
a=false --boolean for animation
p={}   --the player table
p.x=64 --player  x position (left)
p.y=64 --player y variable (top)
by=71  --player x position (right)
rx=71  --player y position (bottom)
ytile = 0 --
ybound = 0
move = 4
jready = true --boolean for jump readyness


-->8
--draw
function _draw()
  cls()
  
  //draw map
  map(0,0,0,0,16,16)
  
  //draw player
  spr(s,p.x,p.y,1,1,f)
  
  
  //print debugging info
  print("x"..p.x)
  print("y"..p.y)
  print("rx"..rx)
  print("by"..by)

 
end
-->8
--update
function _update()
	//set animation bool to false 
 a=false
 
 //gravity controls,
 //runs while the player is in the air and not jumping
 if((jumping == false) and (collision(p.x,by+1,3)==false) and (collision(rx,by+1,3)==false)) then
		//increment gravity timer
		g+=1
		//first 3 frames of desent are slower
		if (g<4) then 
			p.y=p.y+5/12
		end
		//after 3 frames fall speed increases 
		if (g>3) then 	
	 	p.y=p.y+5/6
	 end
	end
	
	//jump controls 
	
	//call jump function with jump cooldown
	jump(j)
	
	//decrement jump cooldown while its non zero 
	if(j>0) then
		j-=1
	end
	
	//check if jump cooldown is over
	if(j==0) then
		jumping=false
	end
	
	//check if player is ready to jump
	//runs when the player is standing on the ground
	if((collision(p.x,by+1,3)==true) or (collision(rx,by+1,3)==true)) then
 	//enable jumping
 	jready = true
 	//reset gravity timer
 	g=0
 end
 
 //adjust bottom and right player coordinates
 by=p.y+7
 rx=p.x+7
 
 //left controlls
 if btn(0) then
 	//checks if there is a wall where the player will be moving to
 	//runs if there is no wall detected
 	if((collision(p.x-1,p.y,3)==false) and (collision(p.x-1,by,3)==false)) then
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
 	 //enable jumping
 	 jready=true
  end
  
 end
 
 //right controls 
 if btn(1) then
 	//checks if there is a wall where the player will be moving to
 	//runs if there is no wall detected
 	if((collision(rx+1,p.y,3)==false) and (collision(rx+1,by,3)==false)) then
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
 
 //call animation funtion if there is active animation
 if a then animation() end
 
end

//sprite animation controls 
function animation()
	d=d-1
	if d<0 then
		s=s+1
		if s>3 then s=1 end
		d=2
	end
end


//jump function 
function jump(j)
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
	end
	//the player jumps lower the second 2 frames 
	if (j>1) and (j<4) then
		p.y-=h/6
	end
end
-->8

-->8
function collision(x,y,f)
 // postion of the tile containing the input coordinates
 local tilex = ((x-(x%8))/8)
	local tiley = ((y-(y%8))/8)
	
	//checks if the given tile has flag f
	//returns true if so
	if(fget(mget(tilex,tiley),f) )then
		return true
	end
	
	return false 
end



	
	
__gfx__
0000000008e88e8008e88e8008e88e801cccc1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000877678008776780087767801c1c111100aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000e6776800e6776800e677680cc11c1cc0aaa77a000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700008e678e008e678e008e678e0c1cc11c10a7aa7a000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000088e8000088e8000088e800111cccc10a77aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070006d8856005688d500d5886d0ccc1c1cc0aa77aa000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005000000dd000000660000005c11c111c00aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d65d650065d65d005d65d6011ccc11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000044445544444555444444554444445544444444445500004499999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000044445544455554445555554445545544444444445477774599999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000045444444555554444455444445544444444444444400004499999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000045554445455444554455445545444455444444445477775499999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000045554445455444554444445545455555444444445400005499999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000044555444445555544444455444455444444444444477775599999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000054444444544555545445555454444445444444444400004599999999cccccccc00000000000000000000000000000000000000000000000000000000
0000000055444554554455545444455455454455444444445477774599999999cccccccc00000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001081800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4700000000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700000000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747004747470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700000000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700000000000047474747474747470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000004700000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800004700000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000047000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000470047470000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000047470000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800004747474747474747470000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4800000000000000000000000047470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4700000000000000000000004747470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
