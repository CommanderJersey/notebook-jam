#include "gameplay.agc"

// Project: PaperChamps 
// Created: 2017-07-24

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "Notebook Jam" )
//SetWindowSize( 1024, 768, 0 )
//SetWindowAllowResize( 1 ) // allow the user to resize the window
SetWindowSize( 620, 1100, 0 )          //Change this for exact resolution

//SetWindowSize( 1500, 2000, 0 ) //iPad
//SetWindowSize( 900, 1870, 0 ) //Longphone
//SetWindowSize(2048, 2732, 0)

global w as integer
//w = GetDeviceWidth()
w = 620
global h as integer
//h = GetDeviceHeight()
h = 1100

global dRatio# as integer
dRatio# =  w/320.0

global accel# = 0
global gravity = 0
global isClimbing = 0
global eraser = 0
global slip = 0
global wind = 0

global roomNum = 0
global totalRooms = 0
global startSprite = 0
global startSpriteCut = 0
global currentLevel = 4
global highestLevel = 34
global maxLevelScroll = 0
global viewOff = 0
global cutLevel = 0
global cutFinished = 0

//Different 'menus'
global mainMenu = 0
global levelSelect = 0
global gamePlay = 1
global paused = 0
global transition = 0

global touchStartX = 0
global touchStartY = 0

global volume = 100
global musicPlaying = 1
global version = 2

starsLevel = 0
dim starsGot[50]
global trophies = 0

// set display properties
SetVirtualResolution( w, h ) // doesn't have to match the window
SetOrientationAllowed( 1, 0, 0, 0 ) // allow both portrait and landscape on mobile devices
SetSyncRate(60, 0 ) // 30fps instead of 60 to save battery //lol
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

/*
SPRITES

1 - Main Character
2 - Mirror Character
4 - Eraser

6 - Middle Block
8 - Instructional paper

11 - 2nd Cut
12 - 2nd Cut Mirror

21-24 Wall Boudaries

31+ Cutscene Sprites

47 - Flipping Page
48 - Wood background for gameplay
49 - Middle Spiral
50 - Background Top
51 - Background Bottom
52 - Pause Button
53 - Pause Sheet
54 - Play Button
55 - Black Alpha layer

101 - Screen Transiotion Sprite

151 - Level Results Notecard
152 - Retry Level
153 - Level Select
154 - Next Level

Level Select:
191-194 Book Selection
201-238 Level Selection
250 - Enter Level Button


901+ Paper sheets
*/

function SaveGame()
	OpenToWrite(1, "paperSave.txt")
	WriteInteger(1, currentLevel)
	WriteInteger(1, highestLevel)
	for i = 1 to 50
		WriteInteger(1, starsGot[i])
	next i
	WriteInteger(1, version)
	CloseFile(1)
endfunction

function LoadGame()
	OpenToRead(1, "paperSave.txt")
	currentLevel = ReadInteger(1)
	highestLevel = ReadInteger(1)
	for i = 1 to 50
		starsGot[i] = ReadInteger(1)
	next i
	version = ReadInteger(1)
	CloseFile(1)
endfunction


Function Button(sprite) 
if GetSpriteExists(sprite) = 0 then exitfunction 0	//Added in to make sure bad buttons aren't targeted
returnValue = 0 `reset value for check
If GetPointerX() > GetSpriteXByOffset( sprite ) - ( GetSpriteWidth( sprite ) / 2 )
 If GetPointerX() < GetSpriteXByOffset( sprite ) + ( GetSpriteWidth( sprite ) / 2 )
   If GetPointerY() > GetSpriteYByOffset( sprite ) - ( GetSpriteHeight( sprite ) / 2 )
    If GetPointerY() < GetSpriteYByOffset( sprite ) + ( GetSpriteHeight( sprite ) / 2 )
      If GetPointerState() = 1
        returnValue = 1
      Endif
     Endif
   Endif
  Endif
Endif
EndFunction returnValue

global block = 1
LoadImage(block, "pencilBlock.png")
global endBlock = 2
LoadImage(endBlock, "ladder.png")
global star = 3
LoadImage(star, "paperClip.png")
//global ice = 4
//LoadImage(ice, "highlight.png")
global scrap = 5
LoadImage(scrap, "scrap.png")
global blank = 6
LoadImage(blank, "blank.png")
global page = 7	//Blank page showing where you are
LoadImage(page, "page.png")
global pageGuy = 8	//Page showing where you are
LoadImage(pageGuy, "pageGuy.png")
global notebookHalf = 9	//Half of the Level background
LoadImage(notebookHalf, "notebookHalf.png")
global spiral = 10
LoadImage(spiral, "spiral.png")
global restart = 11
LoadImage(restart, "restart.png")
global volumeOn = 12
LoadImage(volumeOn, "volumeOn.png")
global volumeOff = 13
LoadImage(volumeOff, "volumeOff.png")
global trophy = 14
LoadImage(trophy, "trophy.png")
global virposaPaper = 15
LoadImage(virposaPaper, "virposaPaper.png")

global mainFont = 21
LoadImage(mainFont, "mainFont.png")
global bookFont = 22
LoadImage(bookFont, "bookFont.png")
global pauseFont = 23
LoadImage(pauseFont, "pauseFont.png")
global loadingFont = 24
LoadImage(loadingFont, "loadFont.png")

//Sound Effects
global pageSound = 1
LoadSound(pageSound, "pageSound.wav")
global pageSlide = 2
LoadSound(pageSlide, "pageSlide.wav")
global walkSound = 3
LoadSound(walkSound, "walk.wav")
global windSound = 4
LoadSound(windSound, "wind.wav")
global chime = 5
LoadSound(chime, "starChime.wav")
global discard = 6
LoadSound(discard, "discard.wav")
global noFlipSound = 7
LoadSound(noFlipSound, "noFlip.wav")

//Music
global selectMenu = 21
LoadMusicOGG(selectMenu, "selectMenu.ogg")
global pageTurner = 22
LoadMusicOGG(pageTurner, "pageTurner.ogg")
global panic3 = 23
LoadMusicOGG(panic3, "panic3.ogg")
global highlight = 24
LoadMusicOGG(highlight, "highlight.ogg")
global sambossa = 25
LoadMusicOGG(sambossa, "sambossa.ogg")
global radiant8 = 26
LoadMusicOGG(radiant8, "radiant8.ogg")
global tornTogether = 27
LoadMusicOGG(tornTogether, "tornTogether.ogg")
global finalChapter = 28
LoadMusicOGG(finalChapter, "finalChapter.ogg")

function menuSwitch(newNum)
	notebookSelect = 0
	levelSelect = 0
	gamePlay = 0
	paused = 0
	
	if newNum = 1 then notebookSelect = 1
	if newNum = 2 then levelSelect = 1
	if newNum = 3 then gamePlay = 1
	if newNum = 4 then paused = 1
endfunction






/*LoadMap()
roomNum = 0
for i = 1 to totalRooms
	roomNum = i
	DrawMap()
next i
roomNum = 1*/

function DrawLevelSelect()
	trophies = 0
	for i = 1 to 5 //Goes to total number of worlds
		sNum = i + 190
		CreateSprite(sNum, LoadImage("bookScrap.png"))
		SetSpriteSize(sNum, 580, 284)
		SetSpritePosition(sNum, 20, 40+300*(i-1))
		if i = 2 then SetSpriteColor(sNum, 255, 255, 180, 255)	//Yellow
		if i = 3 then SetSpriteColor(sNum, 205, 255, 180, 255)	//Green
		if i = 4 then SetSpriteColor(sNum, 190, 220, 255, 255)	//Blue
		if i = 5 then SetSpriteColor(sNum, 221, 160, 221, 255)	//Purple
		
		SetSpriteDepth(sNum, 20)
		//Level Sheets
		
		
		
		if i <= (highestLevel/10+1) and i <= 4
			for j = 1 to 8
				sNum = 200+(i-1)*10+j
				CreateSprite(sNum, LoadImage("levelScrap.png"))
				SetSpritePosition(sNum, 70, GetSpriteY(190+i)+290+150*(j-1)+1200*(i-1))
				SetSpriteSize(sNum, 450, 141)
				if i = 2 then SetSpriteColor(sNum, 255, 255, 180, 255)
				if i = 3 then SetSpriteColor(sNum, 205, 255, 180, 255)
				if i = 4 then SetSpriteColor(sNum, 190, 220, 255, 255)
				SetSpriteAngle(sNum, Random(0, 6)-3)
				if ((i-1)*10+j > highestLevel)
					SetSpriteColor(sNum, GetSpriteColorRed(sNum)-130, GetSpriteColorGreen(sNum)-130, GetSpriteColorBlue(sNum)-130, 255)
					
				endif
				CreateText(sNum, "Chapter " + Str(i) + "-" + Str(j))
				SetTextFontImage(sNum, mainFont)
				SetTextSize(sNum, 50)
				SetTextPosition(sNum, GetSpriteX(sNum)+5, GetSpriteY(sNum)+25)
				SetTextAngle(sNum, Random(0,4)-2)
				SetTextDepth(sNum, 10)
				
				//Paperclips
				for k = 1 to 3
					if starsGot[(i-1)*10+j] >= k
						CreateSprite(sNum*10+k, star)
						SetSpritePosition(sNum*10+k, GetSpriteX(sNum)+296+30*k, GetSpriteY(sNum)+68)
						SetSpriteSize(sNum*10+k, 50, 50)
						SetSpriteAngle(sNum*10+k ,Random(0,8)-4)
					endif
				next k
				
			next j
			
		endif
		
		//Book texts part 1
		sNum = i + 190
		if i = 1 then CreateText(sNum, "Book One")
		if i = 2 then CreateText(sNum, "Book Two")
		if i = 3 then CreateText(sNum, "Book Three")
		if i = 4 then CreateText(sNum, "Book Four")
		if i = 5 then CreateText(sNum, "Bonus Book")
		SetTextDepth(sNum, 10)
		SetTextFontImage(sNum, bookFont)
		SetTextSize(sNum, 58)
		//SetTextAngle(sNum, Random(0, 4)-2)
		
		if (highestLevel/10)+2 > i
			worldStars = 0
			for k = 1 to 8
				inc worldStars, starsGot[(i-1)*10+k]
			next k
			if (highestLevel/10)+1 > i
				CreateText(sNum-10, Str(Round(worldStars*2.5+40)) + "% Done")
			else
				CreateText(sNum-10, Str(Round(worldStars*2.5+(Mod(highestLevel, 10)-1)*5)) + "% Done")
			endif
			SetTextSize(sNum-10, 40)
			SetTextFontImage(sNum-10, bookFont)
			
			if worldStars >= 24
				CreateSprite(sNum-10, trophy)
				SetSpriteSize(sNum-10, 128, 128)
				SetSpritePosition(sNum-10, GetTextX(sNum-10), GetTextY(sNum-10)- 80)
				SetSpriteDepth(sNum-10, 2)
				inc trophies, 1
			endif
		else
			
		endif
		
	next i
	
	//For the bonus book
	for j = 1 to 5
		sNum = 240+j
		CreateSprite(sNum, LoadImage("levelScrap.png"))
		SetSpritePosition(sNum, 70, GetSpriteY(195)+290+150*(j-1)+1200*(4))
		SetSpriteSize(sNum, 450, 141)
		SetSpriteColor(sNum, 221, 160, 221, 255)
		SetSpriteAngle(sNum, Random(0, 6)-3)
		if trophies < j
			if j <> 5 then SetSpriteColor(sNum, GetSpriteColorRed(sNum)-130, GetSpriteColorGreen(sNum)-130, GetSpriteColorBlue(sNum)-130, 255)
			if j = 1 then CreateText(sNum, "1 trophy needed")
			if j = 2 then CreateText(sNum, "2 trophies needed")
			if j = 3 then CreateText(sNum, "3 trophies needed")
			if j = 4 then CreateText(sNum, "4 trophies needed")
		else
			CreateText(sNum, "Chapter B-" + Str(j))
		endif
		if j = 5
			DeleteText(sNum)
			if starsGot[41]+starsGot[42]+starsGot[43]+starsGot[44] =>12
				CreateText(sNum, "The Final Chapter")
			else
				CreateText(sNum, "Get every paperclip")
				SetSpriteColor(sNum, GetSpriteColorRed(sNum)-130, GetSpriteColorGreen(sNum)-130, GetSpriteColorBlue(sNum)-130, 255)
			endif
		endif
		SetTextFontImage(sNum, mainFont)
		SetTextSize(sNum, 50)
		SetTextPosition(sNum, GetSpriteX(sNum)+5, GetSpriteY(sNum)+25)
		SetTextAngle(sNum, Random(0,4)-2)
		SetTextDepth(sNum, 10)
		
		//Paperclips
		for k = 1 to 3
			if starsGot[40+j] >= k
				CreateSprite(sNum*10+k, star)
				SetSpritePosition(sNum*10+k, GetSpriteX(sNum)+296+30*k, GetSpriteY(sNum)+68)
				SetSpriteSize(sNum*10+k, 50, 50)
				SetSpriteAngle(sNum*10+k ,Random(0,8)-4)
			endif
		next k
		
		if j = 5
			worldStars = starsGot[41]+starsGot[42]+starsGot[43]+starsGot[44]+starsGot[45]
			if worldStars >= 15
				CreateSprite(185, trophy)
				SetSpriteSize(185, 128, 128)
				SetSpritePosition(185, GetTextX(sNum-10), GetTextY(sNum-10)- 80)
				SetSpriteDepth(185, 1)
				inc trophies, 1
			endif
		endif
		
	next j
	
	//Repositioning the later book sheets
	if (highestLevel/10+1) = 1
		SetSpriteY(192, GetSpriteY(192)+1200)
		SetSpriteY(193, GetSpriteY(193)+1200)
		SetSpriteY(194, GetSpriteY(194)+1200)
		SetSpriteY(195, GetSpriteY(195)+1200)
		maxLevelScroll = 1700
		//maxLevelScroll = 1850+150
	elseif (highestLevel/10+1) = 2
		SetSpriteY(192, GetSpriteY(192)+1200)
		SetSpriteY(193, GetSpriteY(193)+2400)
		SetSpriteY(194, GetSpriteY(194)+2400)
		SetSpriteY(195, GetSpriteY(195)+2400)
		maxLevelScroll = 2900
		//maxLevelScroll = 3050+150
	elseif (highestLevel/10+1) = 3
		SetSpriteY(192, GetSpriteY(192)+1200)
		SetSpriteY(193, GetSpriteY(193)+2400)
		SetSpriteY(194, GetSpriteY(194)+3600)
		SetSpriteY(195, GetSpriteY(195)+3600)
		maxLevelScroll = 4100
		//maxLevelScroll = 4250+150
	elseif (highestLevel/10+1) = 4
		SetSpriteY(192, GetSpriteY(192)+1200)
		SetSpriteY(193, GetSpriteY(193)+2400)
		SetSpriteY(194, GetSpriteY(194)+3600)
		SetSpriteY(195, GetSpriteY(195)+4800)
		maxLevelScroll = 5900+150  //5450	//Check this later for bonus book spacing
	endif
	//6
	if currentLevel <> 1 then viewOff = GetSpriteY(200+currentLevel)-400
	if viewOff > maxLevelScroll then viewOff = maxLevelScroll
	if viewOff < 0 then viewOff = 0
	SetViewOffset(0, viewOff)
	
	//Book texts part 2
	SetTextPosition(191, GetSpriteX(191)+25, GetSpriteY(191)+50)
	SetTextPosition(192, GetSpriteX(192)+25, GetSpriteY(192)+50)
	SetTextPosition(193, GetSpriteX(193)+25, GetSpriteY(193)+50)
	SetTextPosition(194, GetSpriteX(194)+25, GetSpriteY(194)+50)
	SetTextPosition(195, GetSpriteX(195)+25, GetSpriteY(195)+50)
	
	if GetTextExists(181) then SetTextPosition(181, GetSpriteX(191)+300, GetSpritey(191)+200)
	if GetTextExists(182) then SetTextPosition(182, GetSpriteX(192)+300, GetSpriteY(192)+200)
	if GetTextExists(183) then SetTextPosition(183, GetSpriteX(193)+300, GetSpriteY(193)+200)
	if GetTextExists(184) then SetTextPosition(184, GetSpriteX(194)+300, GetSpriteY(194)+200)
	
	if GetSpriteExists(181) then SetSpritePosition(181, GetTextX(181)+130, GetTextY(181)-160)
	if GetSpriteExists(182) then SetSpritePosition(182, GetTextX(182)+130, GetTextY(182)-160)
	if GetSpriteExists(183) then SetSpritePosition(183, GetTextX(183)+130, GetTextY(183)-160)
	if GetSpriteExists(184) then SetSpritePosition(184, GetTextX(184)+130, GetTextY(184)-160)
	
	if GetSpriteExists(185) then SetSpritePosition(185, GetSpriteX(195)+420, GetSpriteY(195)+120)
	
	
endfunction



function UpdateMusic()
	if GetMusicExistsOGG(musicPlaying) then StopMusicOGG(musicPlaying)
	
	if volume = 0 then exitfunction
	
	if levelSelect = 1
		PlayMusicOGG(selectMenu, volume)
		musicPlaying = selectMenu
	elseif Mod(currentLevel, 10) = 8
		PlayMusicOGG(panic3, volume)
		musicPlaying = panic3
	elseif currentLevel = 45
		PlayMusicOGG(finalChapter, volume)
		musicPlaying = finalChapter
	elseif currentLevel <= 10
		PlayMusicOGG(pageTurner, volume)
		musicPlaying = pageTurner
	elseif currentLevel <= 20
		PlayMusicOGG(highlight, volume)
		musicPlaying = highlight
	elseif currentLevel <= 30
		PlayMusicOGG(sambossa, volume)
		musicPlaying = sambossa
	elseif currentLevel <= 40
		PlayMusicOGG(tornTogether, volume)
		musicPlaying = tornTogether
	elseif currentLevel <= 50
		PlayMusicOGG(radiant8, volume)
		musicPlaying = radiant8
	endif
	
endfunction



function SetSpriteSizeWithCentering(sNum, sizeX, sizeY)
	SetSpritePosition(sNum, GetSpriteX(sNum)+(GetSpriteWidth(sNum)-sizeX)/2, GetSpriteY(sNum)+(GetSpriteHeight(sNum)-sizeY)/2)
	SetSpriteSize(sNum, sizeX, sizeY)
endfunction

function StartPauseScreen()
	SetSpriteColorAlpha(52, 0)
	CreateSprite(55, 0)
	SetSpriteColor(55, 0, 0, 0, 130)
	SetSpriteSize(55, w*3, h*3)
	SetSpritePosition(55, -w*1.5, -h/1.5)
	
	CreateSprite(53, LoadImage("paperSheet.png"))
	SetSpriteSize(53, 480, 740)
	SetSpritePosition(53, w/2-GetSpriteWidth(53)/2, h/2-GetSpriteHeight(53)/2)
	
	
	CreateSprite(54, LoadImage("play.png"))
	SetSpriteSize(54, 100, 100)
	SetSpritePosition(54, GetSpriteX(53)+GetSpriteWidth(53)-GetSpriteWidth(54)-20, GetSpriteY(53)+GetSpriteHeight(53)-GetSpriteHeight(54)-20)
	
	CreateSprite(56, LoadImage("backToLevel.png"))
	SetSpriteSize(56, 100, 100)
	SetSpritePosition(56, GetSpriteX(53)+GetSpriteWidth(53)-GetSpriteWidth(56)-20, GetSpriteY(53)+GetSpriteHeight(53)-GetSpriteHeight(56)-GetSpriteHeight(54)-60)	
	
	//WARNING BUT NOT REALLY: Positioning for 57 and 58 use previous button sizes, but it shouldn't matter since they're the same
	CreateSprite(57, restart)
	SetSpriteSize(57, 100, 100)
	SetSpritePosition(57, GetSpriteX(53)+GetSpriteWidth(53)-GetSpriteWidth(56)-20, GetSpriteY(53)+GetSpriteHeight(53)-GetSpriteHeight(56)-GetSpriteHeight(54)-200)
	
	if volume > 0 then CreateSprite(58, volumeOn)
	if volume = 0 then CreateSprite(58, volumeOff)
	SetSpriteSize(58, 100, 100)
	SetSpritePosition(58, GetSpriteX(53)+GetSpriteWidth(53)-GetSpriteWidth(56)-20, GetSpriteY(53)+GetSpriteHeight(53)-GetSpriteHeight(56)-GetSpriteHeight(54)-340)
	
	//Alpha layer layering
	SetSpriteDepth(55, 1)
	
	for i = 53 to 54
		SetSpriteDepth(i, 1)
	next i
	for i = 56 to 58
		SetSpriteDepth(i, 1)
	next i
	
	CreateText(51, "paused")
	CreateText(52, "volume")
	CreateText(53, "restart")
	CreateText(54, "level menu")
	CreateText(55, "continue")
	for i = 51 to 55
		SetTextFontImage(i, pauseFont)
		SetTextSize(i, 60)
		SetTextPosition(i, 94, 260+(i-51)*140)
		SetTextDepth(i, 1)
	next i
	SetTextX(51, 140)
endfunction

function EndPauseScreen()
	SetSpriteColorAlpha(52, 255)
	for i = 53 to 58
		DeleteSprite(i)
	next i
	for i = 51 to 55
		DeleteText(i)
	next i
endfunction

function ScreenTransitionStart()
	if GetSpriteExists(101) = 0 then CreateSprite(101, LoadImage("conppr_grey.png"))
	transition = 1
	
	FixSpriteToScreen(101, 1)
	SetSpriteSize(101, w*3, h*1.8)
	//SetSpriteSize(101, GetDeviceWidth(), GetDeviceHeight())
	SetSpritePosition(101, -w, -h*.4)
	SetSpriteDepth(101, 1)
	
	CreateText(101, "Loading...")
	FixTextToScreen(101, 1)
	SetTextX(101, 115)
	SetTextSize(101, 70)
	SetTextDepth(101, 1)
	SetTextFontImage(101, loadingFont)
		
	PlaySound(pageSlide, volume*8/10.0)
	
	for i = 1 to 30	
		//SetSpriteY(101, -h+(h*(i)^2)/(30^2))
		SetSpriteY(101, -h*1.8+(h*1.4*(i)^2)/(30^2))
		SetTextY(101, GetSpriteY(101)+GetSpriteHeight(101)/2-50)
		Sync()
	next i
	Sleep(300)
endfunction

function ScreenTransitionEnd()
	SetSpriteDepth(101, 1)
	
	PlaySound(pageSlide, volume*8/10.0)
	
	for i = 1 to 30
		SetSpriteY(101, -h*1.8+(h*1.4*(i+30)^2)/(30^2))
		SetTextY(101, GetSpriteY(101)+GetSpriteHeight(101)/2-50)
		Sync()
	next i
	
	transition = 1
	DeleteSprite(101)
	DeleteText(101)
endfunction

function MakeWoodBack()
	CreateSprite(51, LoadImage("woodBackgroundFull.jpg"))
	SetSpriteSize(51, w*3, h*1.8)
	SetSpritePosition(51, -w, -h*.4)
	SetSpriteDepth(51, 9999)
	FixSpriteToScreen(51, 1)
	
endfunction

if levelSelect = 1
	DrawLevelSelect()
	UpdateMusic()
	MakeWoodBack()

endif

if gamePlay = 1
	
	LoadGame()
	if currentLevel < 1 or currentLevel > 45
		currentLevel = 1
		highestLevel = 1
		version = 2
	endif
	if version = 1
		starsGot[41] = starsGot[31]
		starsGot[42] = starsGot[32]
		starsGot[43] = starsGot[33]
		starsGot[31] = 0
		starsGot[32] = 0
		starsGot[33] = 0
		if highestLevel = 29
			currentLevel = 31
			highestLevel = 31
		endif
		version = 2
	endif
	
	
	
	
	UpdateMusic()
	NewLevel(currentLevel)
	//PlaySound(pageTurner, 60, 1)

	DrawGameplayBackground()

	CreatePlayer()
	
	SetPhysicsWallBottom(1)
	SetPhysicsWallTop(1) 
	SetPhysicsWallLeft(1)
	SetPhysicsWallRight(1)
	

endif


global menuExpanded = 0
global touchTimer = 0
do
    
    
    if GetPointerPressed()
		touchStartX = GetPointerX()
		touchStartY = GetPointerY()
	endif
	
	
    
    if mainMenu
    
    elseif levelSelect
		if GetPointerState()
			//if viewOff < 0 then viewOff = 0
			SetViewOffset(0, (touchStartY-GetPointerY())*1.5+viewOff)
			
			//These are for making sure the scrolling stays in bounds
			if GetViewOffsetY() < -20
				viewOff = -20
				SetViewOffset(0, -20)
			endif
			if GetViewOffsetY() > maxLevelScroll
				viewOff = maxLevelScroll
				SetViewOffset(0, maxLevelScroll)
			endif
		endif
		
		tap = 0
		touchS = 0
		if GetPointerReleased() 
			//touchS makes sure a menu button is actually being pressed
			touchS = GetSpriteHit(touchStartX, touchStartY+GetViewOffsetY())
			if touchTimer < 8 then tap = 1
			
			viewOff = GetViewOffsetY()
			
		endif
		
	
		goToGameplay = 0
		for i = 1 to 4
			
			for j = 1 to 8
				//Transitions form level select to gameplay
				if touchS = 200+j+10*(i-1) and j+10*(i-1) <= highestLevel and tap and Abs(touchStartY-GetPointerY()) < 20 //add part about holding down button for certain amount of time
					currentLevel = j+10*(i-1)
					goToGameplay = 1
				endif
				
				//If something is going wrong with the menus look here first
			
			next j
		next i
		
		//Bonus Levels 
		for i = 1 to 5
			if (((touchS = 240+i) and trophies >= i) or (touchS = 245 and starsGot[41]+starsGot[42]+starsGot[43]+starsGot[44] =>12)) and tap  and Abs(touchStartY-GetPointerY()) < 20
				currentLevel = 40+i
				goToGameplay = 1
			endif
		next i
		
		if goToGameplay = 1
			ScreenTransitionStart()
			for k = 1 to 300
				if GetSpriteExists(k) and k <> 101 then DeleteSprite(k)
				if GetTextExists(k) and k <> 101 then DeleteText(k)
			next k
			if currentLevel = 31
				//CreateSprite(31, LoadImage("flav.png"))
				//CutsceneOne()
			endif
			levelSelect = 0
			gamePlay = 1
			SetViewOffset(0, 0)
			//Start of Creation Code
			startSprite = 0
			NewLevel(currentLevel)

			DrawGameplayBackground()

			CreatePlayer()
			MirrorPlayer()
			UpdateMusic()
			SaveGame() //Maybe take this out idk
			ScreenTransitionEnd()
		endif
		
	elseif gamePlay
		//if slip
			//SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1), GetSpritePhysicsVelocityY(1))
			//if Abs(GetSpritePhysicsVelocityX(1)) > Abs(GetSpritePhysicsVelocityY(1))
				//if GetSpritePhysicsVelocityX(1) < 0
					//SetSpritePhysicsVelocity(1, -200, 0)
				//else
					//SetSpritePhysicsVelocity(1, 200, 0)
				//endif
			//else
				//if GetSpritePhysicsVelocityY(1) < 0
					//SetSpritePhysicsVelocity(1, 0, -200)
				//else
					//SetSpritePhysicsVelocity(1, 0, 200)
				//endif
			//endif
			//if GetRawKeyPressed(32) or (Button(63) and GetPointerPressed())
				//tempS = GetSpriteHit(GetSpriteX(2)+GetSpriteWidth(2)/2, GetSpriteY(2)+GetSpriteHeight(2)/2)
				//if not GetSpriteImageID(tempS) = block then Flip()
			//endif
		if GetRawKeyState(39)
			MoveRight()
			walkAnimate(2)
		elseif GetRawKeyState(37)
			MoveLeft()
			walkAnimate(1)
		elseif GetRawKeyState(38)
			MoveUp()
			walkAnimate(3)
		elseif GetRawKeyState(40)
			MoveDown()
			walkAnimate(3)
		elseif GetRawKeyPressed(32) or (walkNum < 7 and GetPointerReleased())
			//noFlip = 0
			//for i = 1000*(Mod(roomNum, totalRooms)+1)+13 to 120+1000*(Mod(roomNum, totalRooms)+1)
			//	if GetSpriteCollision(1, i) and GetSpriteImageID(i) = block then  noFlip = 1
			//next i
			
			//if noFlip = 0 then Flip()
			//Old method
			tempS = GetSpriteHit(GetSpriteX(2)+GetSpriteWidth(2)/2, GetSpriteY(2)+GetSpriteHeight(2)/2)
			if not GetSpriteImageID(tempS) = block and not GetSpriteImageID(tempS) = virposaPaper
				if cutLevel = 1 then tempS = GetSpriteHit(GetSpriteX(12)+GetSpriteWidth(12)/2, GetSpriteY(12)+GetSpriteHeight(12)/2)
				if cutLevel = 0 then Flip()
				if (cutLevel = 1 and GetSpriteImageID(tempS) <> block) then Flip()
				
				if GetSpriteImageID(tempS) = block
					PlaySprite(12, 40, 0, 1, 6)
					PlaySound(noFlipSound, volume/2, 0)
				endif
				
			else	//For the no-flip sound
				if cutLevel = 1
					if GetSpriteImageID(GetSpriteHit(GetSpriteX(2)+GetSpriteWidth(2)/2, GetSpriteY(2)+GetSpriteHeight(2)/2)) = block
						PlaySprite(2, 40, 0, 1, 6)
						PlaySound(noFlipSound, volume/2, 0)
					endif
					
					if GetSpriteImageID(GetSpriteHit(GetSpriteX(12)+GetSpriteWidth(12)/2, GetSpriteY(12)+GetSpriteHeight(12)/2)) = block
						PlaySprite(12, 40, 0, 1, 6)
						PlaySound(noFlipSound, volume/2, 0)
					endif
				else
					PlaySprite(2, 40, 0, 1, 6)
					PlaySound(noFlipSound, volume/2, 0)
				endif
				
			endif
		
		elseif GetPointerState()
			if touchStartX <> GetPointerX() and touchStartY <> GetPointerY() then MoveTouch(GetPointerX(), GetPointerY())
			
		else
			if abs(accel#) > 0 then accel# = 0 //inc accel#, 
			SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1)/2, GetSpritePhysicsVelocityY(1)/2)
			if cutLevel = 1 then SetSpritePhysicsVelocity(11, GetSpritePhysicsVelocityX(11)/2, GetSpritePhysicsVelocityY(11)/2)
			walkAnimate(0)
		endif
		
		if cutLevel = 1

			SetSpriteAngle(11, GetSpriteAngle(1))
			SetSpriteFlip(11, facing-2, 0)
			//SetSpritePos(
		endif
		
		//Sprite for collision checking
		colS = GetSpriteHit(GetSpriteX(1)+GetSpriteWidth(1)/2, GetSpriteY(1)+GetSpriteHeight(1)/2)
		//colS2 = 1
		if cutLevel = 1 then colS2 = GetSpriteHit(GetSpriteX(11)+GetSpriteWidth(11)/2, GetSpriteY(11)+GetSpriteHeight(11)/2)
		//if cutLevel = 1 then colS2 = GetSpriteHit(GetSpriteX(11)+GetSpriteWidth(11)/2, GetSpriteY(11)+GetSpriteHeight(11)/2)
		if Mod(cutFinished, 2) = 1 then colS = 2	//First sprite done
		if cutFinished/2 = 1 then colS2 = 2		//Second sprite done
		

		//Wind
		//wind = 0
		if GetSpritePlaying(colS)
			if Mod(GetSpriteAngle(colS)+360,360) = 0 then SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1), -50)		//Up
			if Mod(GetSpriteAngle(colS)+360,360) = 180 then SetSpritePhysicsVelocity(1, GetSpritePhysicsVelocityX(1), 50)	//Down
			if Mod(GetSpriteAngle(colS)+360,360) = 90 then SetSpritePhysicsVelocity(1, 50, GetSpritePhysicsVelocityY(1))		//Left
			if Mod(GetSpriteAngle(colS)+360,360) = 270 then SetSpritePhysicsVelocity(1, -50, GetSpritePhysicsVelocityY(1))	//Right
			//wind = 1
		endif
			

			
		//Ice
		//slip = 0
		//if GetSpriteImageID(colS) = ice
		//	slip = 1
		//endif
			
		//Star collecting
		if GetSpriteImageID(colS) = star
			PlaySound(chime, volume/4.6)
			SetSpriteImage(colS, blank)
			inc starsLevel, 1
		endif
		
		
		//Scrap Paper
		if GetSpriteImageID(colS) = scrap
			SetSpritePhysicsOff(colS)
			PlaySound(discard, volume*5.0/7)
			for i = 1 to 15
				SetSpriteAngle(colS, i*23)
				SetSpriteSize(colS, GetSpriteWidth(colS) + 10, GetSpriteHeight(colS) + 10)
				SetSpriteColorAlpha(colS, (15-i)*17)
				
				Sync()
				Sleep(10)
			next i
			SetSpriteImage(colS, blank)
		endif
		
		
		//Moving the eraser 
		if eraser = 1
			
			if (cutLevel = 0 or (roomNum = 1 and cutFinished <> 1)) or cutFinished = 2
				SetSpritePosition(4, ((GetSpriteX(4)+0)*799+GetSpriteX(1)-GetSpriteWidth(4)+GetSpriteWidth(1)/2)/800.0, (GetSpriteY(4)*799+GetSpriteY(1)-GetSpriteHeight(1)-GetSpriteHeight(1)/2)/800.0)
			elseif (roomNum = 2 and cutLevel = 1) or cutFinished = 1
				SetSpritePosition(4, ((GetSpriteX(4)+0)*799+GetSpriteX(11)-GetSpriteWidth(4)+GetSpriteWidth(11)/2)/800.0, (GetSpriteY(4)*799+GetSpriteY(11)-GetSpriteHeight(11)-GetSpriteHeight(11)/2)/800.0)
			
			endif
			
		
			//Block erasing
			contactSprite = GetSpriteHit(GetSpriteX(4)+GetSpriteWidth(4)/2+42, GetSpriteY(4)+GetSpriteHeight(4)+18)
			//DrawLine(0, 0, GetSpriteX(4)+GetSpriteWidth(4)/2+42, GetSpriteY(4)+GetSpriteHeight(4)+18, 0, 0)	//For eraser contact detecting
			if GetSpriteImageID(contactSprite) = block
				SetSpriteColorAlpha(contactSprite, GetSpriteColorAlpha(contactSprite)-3)
			
				if GetSpriteColorAlpha(contactSprite) <= 0
					SetSpriteImage(contactSprite, blank)
					SetSpritePhysicsOff(contactSprite)				
				endif
				
			endif
			
			if GetSpriteCollision(1, 4) then ResetLevel()
			
			//Print(GetSpriteImageID(GetSpriteHit(GetSpriteX(4)+GetSpriteWidth(4)-20, GetSpriteY(4)+GetSpriteHeight(4)-20)))
		endif
		
		//Ending first character
		if (cutLevel = 1 and GetSpriteImageID(colS) = endBlock)
			inc cutFinished, 1
			SetSpriteColorAlpha(1, 170)
			Sync()
			SetSpriteColorAlpha(1, 85)
			SetSpriteColorAlpha(2, 85)
			Sync()
			SetSpriteColorAlpha(1, 0)
			SetSpriteColorAlpha(2, 0)
			SetSpritePhysicsOff(1)
			SetSpritePhysicsOn(1, 3)
			SetSpritePosition(1, -100, -100)
		endif
		
				
		//All clone collisions
		if cutLevel = 1
			
			//Wind for clone
			if GetSpritePlaying(colS2)
				if Mod(GetSpriteAngle(colS2)+360,360) = 0 then SetSpritePhysicsVelocity(11, GetSpritePhysicsVelocityX(11), -50)		//Up
				if Mod(GetSpriteAngle(colS2)+360,360) = 180 then SetSpritePhysicsVelocity(11, GetSpritePhysicsVelocityX(11), 50)	//Down
				if Mod(GetSpriteAngle(colS2)+360,360) = 90 then SetSpritePhysicsVelocity(11, 50, GetSpritePhysicsVelocityY(11))		//Left
				if Mod(GetSpriteAngle(colS2)+360,360) = 270 then SetSpritePhysicsVelocity(11, -50, GetSpritePhysicsVelocityY(11))	//Right
			endif
			
			//Star collecting clone
			if GetSpriteImageID(colS2) = star
				PlaySound(chime, volume/4.6)
				SetSpriteImage(colS2, blank)
				inc starsLevel, 1
			endif
			
			//Scrap Paper clone
			if GetSpriteImageID(colS2) = scrap
				SetSpritePhysicsOff(colS2)
				PlaySound(discard, volume*5.0/7)
				for i = 1 to 15
					SetSpriteAngle(colS2, i*23)
					SetSpriteSize(colS2, GetSpriteWidth(colS2) + 10, GetSpriteHeight(colS2) + 10)
					SetSpriteColorAlpha(colS2, (15-i)*17)
						
					Sync()
					Sleep(10)
				next i
				SetSpriteImage(colS2, blank)
			endif
			
			//Ending second character
			if (cutLevel = 1 and GetSpriteImageID(colS2) = endBlock)
				inc cutFinished, 2
				SetSpriteColorAlpha(11, 170)
				Sync()
				SetSpriteColorAlpha(11, 85)
				SetSpriteColorAlpha(12, 85)
				Sync()
				SetSpriteColorAlpha(11, 0)
				SetSpriteColorAlpha(12, 0)
				SetSpritePhysicsOff(11)
				SetSpritePhysicsOn(11, 3)
				SetSpritePosition(11, -100, -100)
			endif
		endif
		
		//Level ending
		if (GetSpriteImageID(colS) = endBlock and cutLevel = 0) or cutFinished = 3
			ScreenTransitionStart()
			if GetSpriteExists(4) then DeleteSprite(4)
			if GetSoundsPlaying(walkSound) then StopSound(walkSound)
			eraser = 0
			if starsGot[currentLevel] < starsLevel then starsGot[currentLevel] = starsLevel
			if starsGot[currentLevel] > 3 then starsGot[currentLevel] = 3
			starsLevel = 0
			inc currentLevel, 1
			if Mod(currentLevel, 10) = 8 then UpdateMusic()
			if Mod(currentLevel, 10) = 9 and currentLevel < 36
				inc currentLevel, 2
				DrawGameplayBackground()
				UpdateMusic()
			endif
			if currentLevel < 39	//Most Levels
				if currentLevel > highestLevel then highestLevel = currentLevel
				if currentLevel = 31
					//CreateSprite(31, LoadImage("flav.png"))
					//CutsceneOne()
				endif
				startSprite = 0
				NewLevel(currentLevel)
				CreatePlayer()
				MirrorPlayer()
				ScreenTransitionEnd()				
			else	//Last Level and bonus levels
				gamePlay = 0
				levelSelect = 1
				//Deleting Everything old from level
				for k = 1 to 10000
					if GetSpriteExists(k) and k <> 101 then DeleteSprite(k)
				next k
				//currentLevel = 28
				inc currentLevel, -1
				if currentLevel = 40 then currentLevel = 38
				highestLevel = 39
				DrawLevelSelect()
				MakeWoodBack()
				touchTimer = 20	//Added to prevent clicking of new stage
				UpdateMusic()
				ScreenTransitionEnd()
			endif
			SaveGame()
		endif
		
		//Keeping the player constant
		//SetSpriteAngle(1, 0)
		
		//Trying updating when not moving
		if gamePlay = 1 then MirrorPlayer()
		
		
		
		if Button(52) and GetPointerPressed() and gamePlay = 1
			gamePlay = 0
			paused = 1
			StartPauseScreen()
		endif
		
	elseif paused
		
		//Volume
		if Button(58) and GetPointerPressed()
			if volume = 0
				volume = 100
				SetSpriteImage(58, volumeOn)
				if GetMusicPlayingOGG(musicPlaying) = 0 then UpdateMusic()
				SetMusicVolumeOGG(musicPlaying, volume)
			else
				volume = 0
				SetSpriteImage(58, volumeOff)
				SetMusicVolumeOGG(musicPlaying, volume)
			endif
			
		endif
		
		
		if Button(57) and GetPointerPressed()
			paused = 0
			gamePlay = 1
			EndPauseScreen()
			ResetLevel()
			
		endif
		
		//Resume
		if Button(54) and GetPointerPressed()
			paused = 0
			gamePlay = 1
			EndPauseScreen()
			walkNum = 20	//Added to prevent extra flip
		endif
		
		//Level Menu
		if Button(56) and GetPointerPressed()
			paused = 0
			levelSelect = 1
			eraser = 0
			starsLevel = 0
			
			EndPauseScreen()
			ScreenTransitionStart()
			
			//Deleting Everything old from level
			for k = 1 to 10000
				if GetSpriteExists(k) and k <> 101 then DeleteSprite(k)
			next k
			
				DrawLevelSelect()
			MakeWoodBack()
			
			touchTimer = 20	//Added to prevent clicking of new stage
			
			UpdateMusic()
			ScreenTransitionEnd()
		endif
		
	endif
	
	//For level select buttons
	if GetPointerState() then inc touchTimer, 1
	if GetPointerReleased() then touchTimer = 0
	
	//SetPrintColor((60-ScreenFPS())*255/60, 255*ScreenFPS()/60, 0)
    //Print( ScreenFPS() )
    //Print(cutLevel)
    //Print(GetSpriteImageID(GetSpriteHit(GetSpriteX(12)+GetSpriteWidth(12)/2, GetSpriteY(12)+GetSpriteHeight(12)/2)))
    //Print(GetSpriteColorAlpha(1))
    //Print(GetDeviceHeight())
    Sync()
loop


//Eraser wiggle when erasing
//Different poses when moving
//Fan spinning
