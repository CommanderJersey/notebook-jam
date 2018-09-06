

function LoadMap(level)
	global roomWidth = 12
	global roomHeight = 9
	
	
	//if planetNum = 1
		OpenToRead(1, "rooms"+Str(level)+".txt")
		//if roomsCleared <> 0 then roomNum = random(1,3)
		//if roomNum <> 1
		//	roomFound = 0
		//	while (roomFound = 0)
		//		if val(ReadLine(1)) = roomNum then roomFound = 1
		//	endwhile
		//endif
	//endif
	totalRooms = Val(ReadLine(1))
	roomNum = 0
	cutLevel = 0
	for k = 1 to totalRooms
		roomNum = k
		global roomMap as integer[1, 1, 9]
		//if planetNum = 4
		//	roomMap as integer[11, 11]
		//endif
		dim roomMap[roomNum, roomWidth, roomHeight]
		for j = 1 to roomHeight
			currentRow$ = ReadLine(1)
			for i = 1 to roomWidth
				if Mid(currentRow$, i, 1) = " "
					roomMap[roomNum, i,j] = 0
				elseif Mid(currentRow$, i, 1) = "a"
					roomMap[roomNum, i,j] = 1
					cutLevel = 1
				elseif Mid(currentRow$, i, 1) = "b"
					roomMap[roomNum, i,j] = 11
				elseif Mid(currentRow$, i, 1) = "c"
					roomMap[roomNum, i,j] = 12
				elseif Mid(currentRow$, i, 1) = "d"
					roomMap[roomNum, i,j] = 13
				else
					roomMap[roomNum, i,j] = Val(Mid(currentRow$, i, 1))
				endif
			next i
		next j
		ReadLine(1)
	next k
	CloseFile(1)
endfunction


function DrawMap()
	global tileSize
	tileSize = w/roomWidth - 10*dRatio#/roomWidth
	//
	for i = 1 to roomWidth
		for j = 1 to roomHeight
			spriteNum = (1000*roomNum)+i+j*roomWidth
			if GetSpriteExists(spriteNum) = 0 then CreateSprite(spriteNum, 0)
			SetSpriteSize(spriteNum, tileSize, tileSize)
			SetSpritePhysicsOff(spriteNum)
			SetSpriteAngle(spriteNum, 0)
			SetSpriteImage(spriteNum, 0)
			SetSpriteDepth(spriteNum, 2)
			//Print(totalRooms)
			//Sync()
			
			if roomNum = 1
				//SetSpritePosition(spriteNum,  tileSize*(i-1) + 5*dRatio#, tileSize*(j-roomHeight-1)+h/2)	//Old method close to spiral
				SetSpritePosition(spriteNum,  tileSize*(i-1) + 5*dRatio#, tileSize*(j-roomHeight-2)+h/2)
				//SetSpriteColor(spriteNum, i*255.0/roomWidth, j*255.0/roomHeight, roomMap[roomNum,i,j]*255, 255)
				SetSpriteColorAlpha(spriteNum, 255)
			else
				SetSpritePosition(spriteNum,  tileSize*(i-1) + 5*dRatio#, tileSize*(-j-1)+h)	//Revert position by editing the -j-1 part to -j-2
				//SetSpriteColor(spriteNum, i*255.0/roomWidth, j*255.0/roomHeight, roomMap[roomNum,i,j]*255, 0)
				SetSpriteColorAlpha(spriteNum, 0)
				SetSpriteAngle(spriteNum, GetSpriteAngle(spriteNum)+180)
			endif
			if roomNum = 2 then SetSpriteColorAlpha(spriteNum, 100)
			if roomNum >= 3 then SetSpritePosition(spriteNum, 999, 999)
			
			tileType = roomMap[roomNum,i,j]
			if tileType = 1 
				SetSpritePhysicsOn(spriteNum, 1)
				SetSpriteImage(spriteNum, block)
			endif
			if tileType = 0 
				SetSpriteImage(spriteNum, blank)
			endif
			if tileType = 2
				if (startSprite = 0 and cutLevel = 1) or (cutLevel = 0) then startSprite = spriteNum
				if (startSprite <> 0 and cutLevel = 1) then startSpriteCut = spriteNum
				SetSpriteImage(spriteNum, blank)
			endif
			if tileType = 3
				SetSpriteImage(spriteNum, star)
				SetSpriteAngle(spriteNum, Random(0, 359))
			endif
			if tileType >= 4 and tileType <=7
				animateWind(spriteNum)
				SetSpriteColorAlpha(spriteNum, 130)
				PlaySprite(spriteNum, 15, 1, 1, 8)
				if tileType = 5 then SetSpriteAngle(spriteNum, GetSpriteAngle(spriteNum)+180)
				if tileType = 6 then SetSpriteAngle(spriteNum, 90)
				if tileType = 7 then SetSpriteAngle(spriteNum, 270)
			endif
			if tileType = 8
				SetSpriteImage(spriteNum, scrap)
				SetSpritePhysicsOn(spriteNum, 1)
			endif
			if tileType = 9 	//Ending tile
				SetSpriteImage(spriteNum, endBlock)
				//SetSpriteImage(spriteNum, LoadImage("ladder.png"))
				//SetSpriteColorAlpha(spriteNum, 254)
			endif
			if tileType > 10
				SetSpritePhysicsOn(spriteNum, 1)
				if tileType = 11 then SetSpriteImage(spriteNum, LoadImage("rubPaper.png"))
				if tileType = 12 then SetSpriteImage(spriteNum, LoadImage("beePaper.png"))
				if tileType = 13 then SetSpriteImage(spriteNum, virposaPaper)
				
			endif
		next j
	next i
	
	for i = 1 to 4
		if GetSpriteExists(20+i) = 0 then CreateSprite(20+i, 0)
		SetSpriteColorAlpha(20+i, 0)
		SetSpritePhysicsOn(20+i, 2)
	next i
	SetSpriteSize(21, 1, h)
	SetSpriteSize(22, w, 1)
	SetSpriteSize(23, 1, h)
	SetSpriteSize(24, w, 1)
	SetSpriteX(23, w)
	SetSpriteY(24, h)
	
endfunction


function animateWind(spriteNum)
	SetSpriteImage(spriteNum, LoadImage("wind1.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind1.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind2.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind3.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind4.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind5.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind6.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind7.png"))
	AddSpriteAnimationFrame(spriteNum, LoadImage("wind8.png"))
endfunction







function MoveRight()
	if accel# < 3 then inc accel#, .3
	//SetSpriteX(1, GetSpriteX(1)+4)
	SetSpritePhysicsVelocity(1, 60*accel#, GetSpritePhysicsVelocityY(1))
	if cutLevel = 1 then SetSpritePhysicsVelocity(11, 60*accel#, GetSpritePhysicsVelocityY(11))
endfunction

function MoveLeft()
	if accel# > -3 then inc accel#, -.3
	//SetSpriteX(1, GetSpriteX(1)-4)
	
	SetSpritePhysicsVelocity(1, 60*accel#, GetSpritePhysicsVelocityY(1))
	if cutLevel = 1 then SetSpritePhysicsVelocity(11, 60*accel#, GetSpritePhysicsVelocityY(11))
endfunction

function MoveUp()
	if accel# > -3 then inc accel#, -.3
	//SetSpriteX(1, GetSpriteX(1)+4)
	SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1), 60*accel#)
	if cutLevel = 1 then SetSpritePhysicsVelocity(11, GetSpritePhysicsVelocityX(11), 60*accel#)
endfunction

function MoveDown()
	if accel# < 3 then inc accel#, .3
	//SetSpriteX(1, GetSpriteX(1)-4)
	
	SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1), 60*accel#)
	if cutLevel = 1 then SetSpritePhysicsVelocity(11, GetSpritePhysicsVelocityX(11), 60*accel#)
endfunction

global walkNum = 0
global facing = 2
function walkAnimate(state)
	//State 1 is left
	//State 2 is right
	//State 3 is up/down
	//State 0 is staying still
	if state = 0
		if GetSpriteAngle(1) > 180 then SetSpriteAngle(1, GetSpriteAngle(1)+1)
		if GetSpriteAngle(1) < 180 then SetSpriteAngle(1, GetSpriteAngle(1)-1)
		//SetSpriteAngle(1, GetSpriteAngle(1)/2)
		
		//if walkNum <> 0 then SetSpriteSize(1, tileSize-5*dRatio#, tileSize-5*dRatio#)
		walkNum = 0
		if GetSoundsPlaying(walkSound) then StopSound(walkSound)
		//Sleep(600)
	else
		inc walkNum, 1
		SetSpriteAngle(1, 10.0*sin(walkNum*13))
		
		if GetSoundsPlaying(walkSound) = 0 then PlaySound(walkSound, volume/3.9, 1)
		
		if (state = 1 and facing = 2) or (state = 2 and facing = 1)
			if walkNum = 1 then PlaySprite(1, 55, 0, 1, 5)
			if walkNum <= 3 
				//SetSpriteSizeWithCentering(1, GetSpriteWidth(1)/2, GetSpriteHeight(1))
			elseif walkNum <= 6
				//SetSpriteSizeWithCentering(1, GetSpriteWidth(1)*2, GetSpriteHeight(1))
			endif
			if walkNum = 4
				SetSpriteFlip(1, facing-1, 0)
			endif
			
			if walkNum = 6
				facing = state
			endif
			if GetSpriteWidth(1)>tileSize-5*dRatio# then SetSpriteSize(1, tileSize-5*dRatio#, GetSpriteHeight(1))
			if walkNum > 6 then walkNum = 0
		endif
		
	endif
endfunction

function MoveTouch(curX, curY)
	changeX# = (curX - touchStartX)*3.5
	changeY# = (curY - touchStartY)*3.5
	
	change# = sqrt(changeX#^2+changeY#^2)
	if change# < 1 then exitfunction
	angle# = ATanFull(changeX#, changeY#)+90
	
	if change# > 185 then change# = 185
	if change# < -185 then change# = -185
	//if changeY# > 200 then changeY# = 200
	//if changeY# < -200 then changeY# = -200
	

	//Sleep(1000)
	
	if changeX# = 0 // and changeX# > -30
		walkAnimate(3)
		//walkNum = 0
		SetSpritePhysicsVelocity(1, -change#*cos(angle#), -change#*sin(angle#))
		if cutLevel = 1 then SetSpritePhysicsVelocity(11, -change#*cos(angle#), -change#*sin(angle#))
	else
		state = 0
		if changeX# < 0 then state = 1
		if changeX# > 0 then state = 2
		walkAnimate(state)
		if state = facing
			SetSpritePhysicsVelocity(1, -change#*cos(angle#), -change#*sin(angle#))
			if cutLevel = 1 then SetSpritePhysicsVelocity(11, -change#*cos(angle#), -change#*sin(angle#))
		endif
	endif
	
	
	//Sleep(100)
	
endfunction

function Flip()
	//Making sure the player doesn't move
	SetSpritePhysicsOff(1)
	if cutLevel = 1 then SetSpritePhysicsOff(11)
	PlaySound(pageSound, volume)
	
	for i = 1 to roomWidth
		for j = 1 to roomHeight
			spriteNum = (1000*roomNum)+i+j*roomWidth
			//SetSpritePosition(spriteNum,  tileSize*(i-1) + 5*dRatio#, tileSize*(-j-2)+h)
			SetSpritePosition(spriteNum,  9999, 9999)
			SetSpriteAngle(spriteNum, GetSpriteAngle(spriteNum)+180)
			if Mod(GetSpriteAngle(spriteNum), 180) <> 0 then SetSpriteAngle(spriteNum, GetSpriteAngle(spriteNum)+180)
			//SetSpriteColor(spriteNum, i*255.0/roomWidth, j*255.0/roomHeight, roomMap[roomNum,i,j]*255, 0)
			SetSpriteColorAlpha(spriteNum, 0)
			
			//For the next room
			SetSpritePosition((1000*(Mod(roomNum+1, totalRooms)+1))+i+j*roomWidth,  tileSize*(i-1) + 5*dRatio#, tileSize*(-j-1)+h)
		
		next j
	next i
	//Make smooth in the future
	SetSpriteImage(900+roomNum, page)
	
	//For the page flipping
	//SetSpriteDepth(47, 1)
	//SetSpriteColorAlpha(47, 255)
	
	roomNum = Mod(roomNum, totalRooms)+1
	for k = 1 to 20
		for i = 1 to roomWidth
			for j = 1 to roomHeight
				spriteNum = (1000*roomNum)+i+j*roomWidth
				SetSpritePosition(spriteNum, tileSize*(i-1) + 5*dRatio#, (GetSpriteY(spriteNum)*4+tileSize*(j-roomHeight-2)+h/2)/5)
				SetSpriteSize(spriteNum, tileSize, tileSize*(k/20.0))
				SetSpriteColorAlpha(spriteNum, 255)
				
				SetSpriteColorAlpha((1000*(Mod(roomNum, totalRooms)+1))+i+j*roomWidth, 100*(k/20.0))
				if k = 4 
					SetSpriteAngle(spriteNum, GetSpriteAngle(spriteNum)+180)
					if Mod(GetSpriteAngle(spriteNum), 180) <> 0 then SetSpriteAngle(spriteNum, GetSpriteAngle(spriteNum)+180)
				endif
			next j
		next i
		//if k > 4	//For the flipping page
			//SetSpriteColorAlpha(47, k*25)
			//SetSpriteSize(47, w, w/.646464*(k/20))
			//SetSpritePosition(47, 0, h/2-GetSpriteHeight(47))
			//Sleep(500)
		//endif
		Sync()
	next k
	
	//SetSpriteColorAlpha(47, 0)
	
	for i = 1 to roomWidth
		for j = 1 to roomHeight
			spriteNum = (1000*roomNum)+i+j*roomWidth
			SetSpritePosition(spriteNum,  tileSize*(i-1) + 5*dRatio#, tileSize*(j-roomHeight-2)+h/2)
			//SetSpriteColor(spriteNum, i*255.0/roomWidth, j*255.0/roomHeight, roomMap[roomNum,i,j]*255, 255)
			SetSpriteColorAlpha(spriteNum, 255)
			if GetSpritePlaying(spriteNum) then SetSpriteColorAlpha(spriteNum, 130)
			SetSpriteColorAlpha((1000*(Mod(roomNum, totalRooms)+1))+i+j*roomWidth, 100)
			//SetSpritePosition((1000*(Mod(roomNum, totalRooms)+1))+i+j*roomWidth,  tileSize*(i-1) + 5*dRatio#, tileSize*(-j-2)+h)
		next j
	next i
	//Make smooth in the future
	SetSpriteImage(900+roomNum, pageGuy)
	
	//if cutLevel = 1 then SetSpriteDepth(11, 2)
	
	SetSpritePhysicsOn(1, 2)
	if cutLevel = 1 then SetSpritePhysicsOn(11, 2)
	
	touchStartX = GetPointerX()
	touchStartY = GetPointerY()
	
endfunction

function NewLevel(level)
	LoadMap(level)
	roomNum = 0
	
	//BAD WORKAROUND, FIX LATER
	for i = 900 to (6000)
		if GetSpriteExists(i) then SetSpritePosition(i, 9999, 9999)
	next i
	
	for i = 1 to totalRooms
		roomNum = i
		DrawMap()
		
	next i
	
	//Seperated for layering purposes
	for i = 1 to totalRooms
		//Pages in the level
		sNum = 900+i
		if GetSpriteExists(sNum) = 0 then CreateSprite(sNum, page)  //LoadImage("paperSheet.png")
		SetSpriteSize(sNum, 50, 70)
		SetSpritePosition(sNum, w/2-30*(totalRooms*1.5)+60*i-GetSpriteWidth(sNum)/2, 60-GetSpriteHeight(sNum)/2)
		SetSpriteImage(sNum, page)
		if i = 1 then SetSpriteImage(sNum, pageGuy)
		SetSpriteDepth(sNum, 1)
		SetSpriteColorAlpha(sNum, 255)
	next i
	roomNum = 1
	
	if Mod(level, 10) = 8
		eraser = 1
		CreateSprite(4, LoadImage("eraser.png"))
		SetSpriteAngle(4, 45)
		//SetSpritePosition(4, GetSpriteX(1026), GetSpriteY(1026))
		SetSpritePosition(4, GetSpriteX(1039)-GetSpriteWidth(4), GetSpriteY(1039)-GetSpriteHeight(4)*2)
		SetSpriteDepth(4, 2)
	endif
	
	if GetSpriteExists(52) = 0
		CreateSprite(52, LoadImage("pause.png"))
		SetSpriteSize(52, 90, 90)
		SetSpritePosition(52, w-10-GetSpriteWidth(52), 8)
		SetSpriteDepth(52, 1)
	endif
	SetSpriteColorAlpha(52, 255)
	
	if GetSpriteExists(1) then SetSpritePosition(1, GetSpriteX(startSprite), GetSpriteY(startSprite))
	if GetSpriteExists(11) then SetSpritePosition(11, GetSpriteX(startSpriteCut), GetSpriteY(startSpriteCut))
	
	if GetSpriteExists(8) then DeleteSprite(8)
	if currentLevel = 1
		CreateSprite(8, LoadImage("instructPage.png"))
		SetSpriteSize(8, 248, 350)
		SetSpritePosition(8,380, 800)
		SetSpriteAngle(8, 328)
		SetSpriteDepth(8, 1)
		

		//SetSpriteSize(8, 248, 350)
		//SetSpritePosition(8, -20, 852)
		//SetSpriteAngle(8, 21)
	endif
	
	cutFinished = 0
	
endfunction

function CreatePlayer()
	if GetSpriteExists(1) = 0 then CreateSprite(1, 0)
	SetSpriteSize(1, tileSize-5*dRatio#, tileSize-5*dRatio#)
	SetSpritePosition(1, GetSpriteX(startSprite), GetSpriteY(startSprite))
	SetSpriteImage(1, LoadImage("flav.png"))
	SetSpriteDepth(1, 2)
	SetSpriteColorAlpha(1, 255)
	//SetSpriteDepth(1, 1)
	if cutLevel <> 1
		AddSpriteAnimationFrame(1, LoadImage("flav2.png"))
		AddSpriteAnimationFrame(1, LoadImage("flav3.png"))
		AddSpriteAnimationFrame(1, LoadImage("flav3.png"))
		AddSpriteAnimationFrame(1, LoadImage("flav2.png"))
		AddSpriteAnimationFrame(1, LoadImage("flav.png"))

		
	
	elseif cutLevel = 1
		SetSpriteSize(1, tileSize/2-3*dRatio#, tileSize-5*dRatio#)
		SetSpriteImage(1, LoadImage("cutFlav.png"))
		
		if GetSpriteExists(11) = 0 then CreateSprite(11, LoadImage("cutFlav.png"))
		SetSpritePosition(11, GetSpriteX(startSpriteCut), GetSpriteY(startSpriteCut))
		SetSpriteSize(11, tileSize/2-3*dRatio#, tileSize-5*dRatio#)
		SetSpriteDepth(11, 2)
		SetSpriteColorAlpha(11, 255)
		
		SetSpritePhysicsOn(11, 2)
		SetSpritePhysicsMass(11, .1) 
		
		if GetSpriteExists(12) = 0 then CreateSprite(12, 0)
		SetSpriteSize(12, tileSize-5*dRatio#, tileSize-5*dRatio#)
		SetSpriteColorAlpha(12, 155)
		SetSpriteImage(12, LoadImage("target.png"))
		AddSpriteAnimationFrame(12, LoadImage("target2.png"))
		AddSpriteAnimationFrame(12, LoadImage("target3.png"))
		AddSpriteAnimationFrame(12, LoadImage("target3.png"))
		AddSpriteAnimationFrame(12, LoadImage("target2.png"))
		AddSpriteAnimationFrame(12, LoadImage("target.png"))
		SetSpriteFlip(12, 0, 1)
		
	endif

	SetSpritePhysicsOn(1, 2)
	//SetPhysicsScale(.3)

	SetPhysicsGravity(0, 0)
	SetSpritePhysicsMass(1, .1) 

	if GetSpriteExists(2) = 0 then CreateSprite(2, 0)
	SetSpriteSize(2, tileSize-5*dRatio#, tileSize-5*dRatio#)
	SetSpriteColorAlpha(2, 155)
	SetSpriteImage(2, LoadImage("target.png"))
	AddSpriteAnimationFrame(2, LoadImage("target2.png"))
	AddSpriteAnimationFrame(2, LoadImage("target3.png"))
	AddSpriteAnimationFrame(2, LoadImage("target3.png"))
	AddSpriteAnimationFrame(2, LoadImage("target2.png"))
	AddSpriteAnimationFrame(2, LoadImage("target.png"))
	SetSpriteFlip(2, 0, 1)


	//SetSpriteX(66, GetSpriteX(66)+GetSpriteWidth(66))
endfunction

function MirrorPlayer()
	SetSpritePosition(2, GetSpriteX(1)+GetSpriteWidth(1)/2-GetSpriteWidth(2)/2, h-(GetSpriteY(1)+GetSpriteHeight(2)))
	if cutLevel = 1 then SetSpritePosition(12, GetSpriteX(11)+GetSpriteWidth(11)/2-GetSpriteWidth(12)/2, h-(GetSpriteY(11)+GetSpriteHeight(12)))
	
endfunction


function DrawGameplayBackground()
	//Black bar, may just make invisible
	
	if GetSpriteExists(6) = 0 then CreateSprite(6, 0)
	SetSpriteSize(6, w, 3*dRatio#)
	SetSpritePosition(6, 0, h/2-GetSpriteHeight(6)/2-tileSize)
	SetSpritePhysicsOn(6, 1)
	SetSpriteColor(6, 10, 10, 20, 0)
	
	//For the color of the level page
	if (currentLevel/10+1) = 2
		colR = 255
		colG = 255
		colB = 180
	elseif (currentLevel/10+1) = 3
		colR = 215
		colG = 255
		colB = 190
	elseif (currentLevel/10+1) = 4
		colR = 190
		colG = 220
		colB = 255
	elseif (currentLevel/10+1) = 5
		colR = 251
		colG = 190
		colB = 251
	endif


	
	//Flipping page
	if GetSpriteExists(47) = 0 then CreateSprite(47, notebookHalf)
	SetSpriteColorAlpha(47, 0)
	SetSpritePosition(47, 0, h/2)
	SetSpriteFlip(47, 0, 1)
	
	//Wooden background
	if GetSpriteExists(51) = 0 then MakeWoodBack()
	//SetSpriteSize(48, w*3, h)

	
	//Metal Spiral
	if GetSpriteExists(49) = 0 then CreateSprite(49, spiral)
	SetSpriteSize(49, w, 56)
	SetSpritePosition(49, 0, h/2-GetSpriteHeight(49)/2+10)
	SetSpriteDepth(49, 4)
	
	//Top Half
	if GetSpriteExists(50) = 0 then CreateSprite(50, notebookHalf)
	SetSpriteSize(50, w, w/.646464)
	SetSpritePosition(50, 2, -GetSpriteHeight(50)/2-2+75)	//Put random number at the end because not sure of actual calculations
	SetSpriteDepth(50, 9996)
	SetSpriteFlip(50, 0, 20)
	if (currentLevel/10+1) <> 1 then SetSpriteColor(50, colR, colG, colB, 255)
	
	//Bottom half
	if GetSpriteExists(48) = 0 then CreateSprite(48, notebookHalf)
	SetSpriteSize(48, w, h)
	SetSpritePosition(48, -1, h/2+1)
	SetSpriteDepth(48, 9996)
	if (currentLevel/10+1) <> 1 then SetSpriteColor(48, colR, colG, colB, 255)
	
	//CreateSprite(51, LoadImage("paperSheet.png"))
	//SetSpriteSize(51, w, h)
	//SetSpriteDepth(51, 9999)
endfunction

function ResetLevel()	//Includes screen transition
	ScreenTransitionStart()
	if GetSpriteExists(4) then DeleteSprite(4)
	eraser = 0
	starsLevel = 0
	
	NewLevel(currentLevel)
	CreatePlayer()
	MirrorPlayer()
	ScreenTransitionEnd()
endfunction

function CutsceneOne()
	/*counter = 1
	//ScreenTransitionEnd()
	
	SetSpriteSize(31, 70, 70)
	SetSpritePosition(31, -80, 500)
	//SetSpriteTransparency(31, 0)
	//SetSpriteColorAlpha(31, 0)
	//SetSpriteDepth(31, 1)
	
	
	//SetSpriteDepth(101, 9)
	//SetTextDepth(101, 9)
	
	//Try using something like this
	//SetSortCreated(1)
	while (counter < 300)
		SetSpriteX(31, GetSpriteX(31)+2)
		SetSpriteX(101, GetSpriteX(101)+20)
		//SetSpriteDepth(31, 1)
		DrawSprite(31)
		inc counter, 1
		Sync()
	endwhile
	
	//ScreenTransitionStart()
	*/
endfunction
