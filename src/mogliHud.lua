--
-- mogliBasics
-- This is the specialization for mogliBasics
--
local mogliHudVersion = 1.101

-- change log
-- 1.00 initial version 
-- 1.10 always draw title

local mogliHudClass = g_currentModName..".mogliHud"


--local defaultButtonHeight = 0.042
--local defaultWidthFactor  = 1.15
local defaultButtonWidth  = 0.027
local defaultHeightFactor = 0.875
local defaultBorderFactor = 0.15
local defaultTextFactor   = 0.45

if _G[mogliHudClass] ~= nil and _G[mogliHudClass].version ~= nil and _G[mogliHudClass].version >= mogliHudVersion then
	print("Factory class "..tostring(mogliHudClass).." already exists in version "..tostring(_G[mogliHudClass].version))
else
	_G[mogliHudClass] = {}

	_G[mogliHudClass].version = mogliHudVersion
	
	--print(tostring(mogliHudClass).." version "..tostring(mogliHudVersion))

--=======================================================================================
-- mogliHud.newclass
--=======================================================================================
	local function newClass( _globalClassName_, _level0_ )
		if _G[_globalClassName_] ~= nil and _G[_globalClassName_].factoryVersion ~= nil and _G[_globalClassName_].factoryClassName ~= nil and _G[_globalClassName_].factoryVersion >= mogliHudVersion then
			print(tostring(_globalClassName_).." was already generated by factory "..tostring(_G[_globalClassName_].factoryClassName).." with version "..tostring(_G[_globalClassName_].factoryVersion))
			return
		end
		
		local _newClass_ = {}
		
		_newClass_.factoryClassName = mogliHudClass
		_newClass_.factoryVersion   = mogliHudVersion
		
		if _level0_ == nil then
			_level0_ = "mogliHud_".._newClass_
		end

		------------------------------------------------------------------------
		-- some local helper functions
		------------------------------------------------------------------------
		function _newClass_.bool2int(boolean)
			if boolean then
				return 1;
			end;
			return 0;
		end;

		function _newClass_.printCallstack()
			printCallstack()
		end

		function _newClass_.getText(id)
			if id == nil then
				return "nil";
			end;
			
			if g_i18n:hasText( id ) then
				return g_i18n:getText( id )
			end
			
			return id
		end;

		function _newClass_.getXmlBool(xmlFile, key, default)
			local l = getXMLInt(xmlFile, key);
			if l~= nil then
				return (l == 1);
			end;
			return default;
		end;

		function _newClass_.getXmlFloat(xmlFile, key, default)
			local f = getXMLFloat(xmlFile, key);
			if f ~= nil then
				return f;
			end;
			return default;
		end;

		function _newClass_.getXmlInt(xmlFile, key, default)
			local f = getXMLInt(xmlFile, key);
			if f ~= nil then
				return f;
			end;
			return default;
		end;

		------------------------------------------------------------------------
		-- init
		------------------------------------------------------------------------
		function _newClass_:init( directory, hudName, hudBackground, onTextID, offTextID, showHudKey, x, y, nx, ny, cbOnClick, width, height, text, border, smallNx, smallNy )
			self[_level0_] = {}
			self[_level0_].Directory = directory;

			self[_level0_].BtnWidth     = Utils.getNoNil( width,  defaultButtonWidth )
			self[_level0_].BtnHeight    = Utils.getNoNil( height, defaultHeightFactor * self[_level0_].BtnWidth * g_screenWidth / g_screenHeight )
			self[_level0_].Border       = Utils.getNoNil( border, defaultBorderFactor * self[_level0_].BtnHeight )			
			self[_level0_].TextSize     = Utils.getNoNil( text,   defaultTextFactor   * self[_level0_].BtnHeight )
			self[_level0_].Width        = nx * ( self[_level0_].BtnWidth  + self[_level0_].Border )
			self[_level0_].Height       = ny * ( self[_level0_].BtnHeight + self[_level0_].Border ) + 2 * self[_level0_].Border + self[_level0_].TextSize + math.max( 0.5*self[_level0_].BtnHeight, self[_level0_].TextSize )
			self[_level0_].PosX         = x;   
			self[_level0_].PosY         = y;  
			self[_level0_].TextPosY     = y + 0.5 * self[_level0_].Border
			self[_level0_].TextPosX     = x + 0.5 * self[_level0_].Border;  
			self[_level0_].BtnPosX      = self[_level0_].TextPosX;     
			self[_level0_].BtnPosY      = self[_level0_].TextPosY + self[_level0_].Border + self[_level0_].TextSize + (ny-1) * ( self[_level0_].BtnHeight + self[_level0_].Border ) 
			self[_level0_].TextPosY     = self[_level0_].TextPosY + 0.25 * self[_level0_].TextSize
			if     type( hudBackground ) == "string" then
				self[_level0_].Path       = Utils.getFilename(hudBackground, self[_level0_].Directory)
				self[_level0_].Overlay    = Overlay:new(hudName, self[_level0_].Path, self[_level0_].PosX, self[_level0_].PosY, self[_level0_].Width, self[_level0_].Height);
			else
				local bg = 0.4
				if type( hudBackground ) == "number" then
					bg = hudBackground
				end
				self[_level0_].Overlay    = Overlay:new(hudName, "dataS2/menu/blank.png", self[_level0_].PosX, self[_level0_].PosY, self[_level0_].Width, self[_level0_].Height);
				self[_level0_].Overlay:setColor(0,0,0,bg)
			end
			self[_level0_].GuiActive    = false;
			self[_level0_].GuiShowKey   = showHudKey;
			self[_level0_].GuiOnTextID  = onTextID;
			self[_level0_].GuiOffTextID = offTextID;	
			self[_level0_].CBOnClick    = cbOnClick
			self[_level0_].Status       = 0
			self[_level0_].Title        = ""
			
			_newClass_.addCloseButton( self, nx, ny )
			
			if      smallNx ~= nil 
					and smallNy ~= nil
					and ( smallNx < nx or smallNy < ny ) then
				_newClass_.addResizeButton( self, nx, ny )
				self[_level0_].ResizeSmall  = true
				self[_level0_].SmallWidth   = smallNx * ( self[_level0_].BtnWidth  + self[_level0_].Border )
				self[_level0_].SmallHeight  = smallNy * ( self[_level0_].BtnHeight + self[_level0_].Border ) + 2 * self[_level0_].Border + self[_level0_].TextSize + math.max( 0.5*self[_level0_].BtnHeight, self[_level0_].TextSize )
				self[_level0_].SmallBtnPosY = self[_level0_].TextPosY + self[_level0_].Border + self[_level0_].TextSize + (smallNy-1) * ( self[_level0_].BtnHeight + self[_level0_].Border ) 
			else
				self[_level0_].ResizeSmall  = false
				self[_level0_].SmallWidth   = self[_level0_].Width  
				self[_level0_].SmallHeight  = self[_level0_].Height 
				self[_level0_].SmallBtnPosY = self[_level0_].BtnPosY
			end
		end

		------------------------------------------------------------------------
		-- addButton
		------------------------------------------------------------------------
		function _newClass_:addButton(imgEnabled, imgDisabled, cbOnClick, cbVisible, nx, ny, textEnabled, textDisabled, textCallback, imgCallback, smallNx, smallNy)
			local x = self[_level0_].BtnPosX + (nx-1)*(self[_level0_].BtnWidth+self[_level0_].Border);
			local y = self[_level0_].BtnPosY - (ny-1)*(self[_level0_].BtnHeight+self[_level0_].Border);
			local img1 = Utils.getNoNil( imgEnabled, "empty.dds" )
			local state, result = pcall( Utils.getFilename, img1, self[_level0_].Directory )
			if not state then
				print("ERROR: "..tostring(result).." (img1: "..tostring(img1)..")")
				return
			end
			local overlay = Overlay:new(nil, result, x,y,self[_level0_].BtnWidth,self[_level0_].BtnHeight);
			local img2 = "empty.dds"
			if imgDisabled ~= nil then
				img2 = imgDisabled
			end;
			local overlay2 = overlay
			if img2 ~= img1 then	
				state, result = pcall( Utils.getFilename, img2, self[_level0_].Directory )
				if not state then
					print("ERROR: "..tostring(result).." (img2: "..tostring(img2)..")")
					return 
				end
				overlay2 = Overlay:new(nil, result, x,y,self[_level0_].BtnWidth,self[_level0_].BtnHeight);
			end
			local button = {enabled=true, ovEnabled=overlay, ovDisabled=overlay2, onClick=cbOnClick, onVisible=cbVisible, twoState=(imgDisabled ~= nil), rect={x,y,x+self[_level0_].BtnWidth,y+self[_level0_].BtnHeight}, text1 = textEnabled, text2 = textDisabled, textcb = textCallback, onRender = imgCallback };
			if      smallNx ~= nil 
					and smallNy ~= nil then
			end
			button.overlays = {}
			button.overlays[img1] = overlay
			if img2 ~= img1 then
				button.overlays[img2] = overlay2
			end
			if self[_level0_].Buttons == nil then self[_level0_].Buttons = {}; end
			table.insert(self[_level0_].Buttons, button);
			return button;
		end;

		------------------------------------------------------------------------
		-- onClose
		------------------------------------------------------------------------
		function _newClass_:onClose()
			_newClass_.showGui(self,false)
		end

		------------------------------------------------------------------------
		-- addCloseButton
		------------------------------------------------------------------------
		function _newClass_:addCloseButton(nx, ny)
			local x = self[_level0_].BtnPosX + (nx-1)*(self[_level0_].BtnWidth+self[_level0_].Border) + 0.5*self[_level0_].BtnWidth;
			local y = self[_level0_].BtnPosY + self[_level0_].BtnHeight+self[_level0_].Border;
			local overlay = Overlay:new(nil, Utils.getFilename("close.dds", self[_level0_].Directory), x,y,0.5*self[_level0_].BtnWidth,0.5*self[_level0_].BtnHeight);
			local button = {enabled=true, ovEnabled=overlay, ovDisabled=nil, onClick=_newClass_.onClose, onVisible=nil, twoState=false, rect={x,y,x+0.5*self[_level0_].BtnWidth,y+0.5*self[_level0_].BtnHeight}, text1 = nil, text2 = nil, textcb = nil, onRender = nil };
			button.overlays = {}
			button.overlays["close.dds"] = overlay
			if self[_level0_].Buttons == nil then self[_level0_].Buttons = {}; end
			table.insert(self[_level0_].Buttons, button);
			return button;
		end;

		------------------------------------------------------------------------
		-- onResize
		------------------------------------------------------------------------
		function _newClass_:onResize()
			self[_level0_].ResizeSmall = not self[_level0_].ResizeSmall
		end

		------------------------------------------------------------------------
		-- addResizeButton
		------------------------------------------------------------------------
		function _newClass_:addResizeButton(nx, ny)
			local x = self[_level0_].BtnPosX + (nx-1)*(self[_level0_].BtnWidth+self[_level0_].Border) -- + 0.5*self[_level0_].BtnWidth;
			local y = self[_level0_].BtnPosY + self[_level0_].BtnHeight+self[_level0_].Border;
			local overlay = Overlay:new(nil, Utils.getFilename("resize.dds", self[_level0_].Directory), x,y,0.5*self[_level0_].BtnWidth,0.5*self[_level0_].BtnHeight);
			local button = {enabled=true, ovEnabled=overlay, ovDisabled=nil, onClick=_newClass_.onResize, onVisible=nil, twoState=false, rect={x,y,x+0.5*self[_level0_].BtnWidth,y+0.5*self[_level0_].BtnHeight}, text1 = nil, text2 = nil, textcb = nil, onRender = nil };
			button.overlays = {}
			button.overlays["resize.dds"] = overlay
			if self[_level0_].Buttons == nil then self[_level0_].Buttons = {}; end
			table.insert(self[_level0_].Buttons, button);
			return button;
		end;

		------------------------------------------------------------------------
		-- setStatus
		------------------------------------------------------------------------
		function _newClass_:setStatus(status)
			if self[_level0_] == nil then
			elseif status == nil or status == 0 then
				self[_level0_].Status = 0
			else
				self[_level0_].Status = status
			end
		end

		------------------------------------------------------------------------
		-- setTitle
		------------------------------------------------------------------------
		function _newClass_:setTitle(title)
			if self[_level0_] == nil then
			elseif title == nil then
				self[_level0_].Title = ""
			else
				self[_level0_].Title = _newClass_.getText( title )
			end
		end

		------------------------------------------------------------------------
		-- getInfoText
		------------------------------------------------------------------------
		function _newClass_:getInfoText()
			if self[_level0_] == nil or self[_level0_].InfoText == nil then
				return ""
			end
			return self[_level0_].InfoText
		end

		------------------------------------------------------------------------
		-- setInfoText
		------------------------------------------------------------------------
		function _newClass_:setInfoText(infoText)
			if self[_level0_] == nil then
			elseif infoText == nil then
				self[_level0_].InfoText = nil
			else
				self[_level0_].InfoText = infoText
			end
		end

		------------------------------------------------------------------------
		-- setInfoTextID
		------------------------------------------------------------------------
		function _newClass_:setInfoTextID(infoTextID)
			if self[_level0_] == nil then
			elseif infoTextID == nil then
				self[_level0_].InfoText = nil
			else
				self[_level0_].InfoText = _newClass_.getText( infoTextID )
			end
		end

		------------------------------------------------------------------------
		-- mouseEvent
		------------------------------------------------------------------------
		function _newClass_:onUpdate(dt)
			local posX, posY, posZ = g_inputBinding:captureMouseInput()
		
			if self[_level0_] == nil then
				return 
			end
			self[_level0_].Tooltip = nil;
			local textID, textCB;
			if self[_level0_].GuiActive then
				for _,overlayButton in pairs(self[_level0_].Buttons) do
					if overlayButton.rect[1] <= posX and posX <= overlayButton.rect[3] and overlayButton.rect[2] <= posY and posY <= overlayButton.rect[4] then
						if overlayButton.onClick ~= nil and isDown and button == 1 then
							if overlayButton.enabled then
								if overlayButton.twoState ~= nil then
									overlayButton.onClick(self, true);
								else
									overlayButton.onClick(self);
								end;
								if type(self[_level0_].CBOnClick) == "function" then
									self[_level0_].CBOnClick(self)
								end
							elseif overlayButton.twoState then
								overlayButton.onClick(self, false);
								if type(self[_level0_].CBOnClick) == "function" then
									self[_level0_].CBOnClick(self)
								end
							end;
						end
						if  overlayButton.text1 ~= nil 
								and ( overlayButton.enabled 
									or not overlayButton.twoState 
									or overlayButton.text2 == nil ) then
							textID = overlayButton.text1;
						elseif overlayButton.text2 ~= nil then
							textID = overlayButton.text2;
						end;
						textCB = overlayButton.textcb;
						break;				
					end;
				end;
			end;
			
			if textID ~= nil then
				self[_level0_].Tooltip = _newClass_.getText( textID );
				if textCB ~= nil then 
					self[_level0_].Tooltip = textCB(self,self[_level0_].Tooltip) 
				end
			end
		end

		------------------------------------------------------------------------
		-- renderButtons
		------------------------------------------------------------------------
		function _newClass_:renderButtons()
			for _,button in pairs(self[_level0_].Buttons) do
				if button.onVisible ~= nil then
					button.enabled = button.onVisible(self);
				end;
				local img = nil
				if button.onRender ~= nil then
					img = button.onRender(self)
				end
				if img ~= nil and img ~= "" then
					if button.overlays == nil then
						button.overlays = {}
					end
					local ov
					if button.overlays[img] == nil then
						ov = Overlay:new(nil, Utils.getFilename(img, self[_level0_].Directory), button.rect[1],button.rect[2],self[_level0_].BtnWidth,self[_level0_].BtnHeight);
						button.overlays[img] = ov
					else
						ov = button.overlays[img]
					end
					ov:render()
				elseif button.enabled then
					if button.ovEnabled ~= nil then
						button.ovEnabled:render();
					end;
				else
					if button.ovDisabled ~= nil then
						button.ovDisabled:render();
					end;
				end;
			end;	
		end;

		------------------------------------------------------------------------
		-- mouse event callbacks
		------------------------------------------------------------------------
		function _newClass_:showGui(on)	
			local old = false 
			if self[_level0_] ~= nil then
				old = self[_level0_].GuiActive
			end
			if self.isClient then
				self[_level0_].GuiActive = on;
			else
				self[_level0_].GuiActive = false
			end
			if old ~= self[_level0_].GuiActive then
				g_inputBinding:setShowMouseCursor(on);		
			end
		end;

		------------------------------------------------------------------------
		-- draw
		------------------------------------------------------------------------
		function _newClass_:draw(hideKey,alwaysDrawTitle)
			if self.isClient and self[_level0_] ~= nil then
				local showTitle
				if self[_level0_].GuiActive then
					g_inputBinding:setShowMouseCursor(true);		
					titlePosY = self[_level0_].BtnPosY  + self[_level0_].Border + self[_level0_].BtnHeight
					showTitle = true
				else
					titlePosY = self[_level0_].TextPosY
					showTitle = alwaysDrawTitle
				end
				
				setTextAlignment(RenderText.ALIGN_LEFT);
				if showTitle then
				
					setTextBold(true);		
					if self[_level0_].Status == 0 then
						setTextColor(1,1,1,1);
					elseif self[_level0_].Status == 1 then
						setTextColor(0,1,0,1);
					elseif self[_level0_].Status == 2 then
						setTextColor(1,1,0,1);
					else
						setTextColor(1,0.5,0,1);
					end
					
					renderText(self[_level0_].TextPosX, titlePosY, self[_level0_].TextSize ,self[_level0_].Title);		
				end
				
				setTextBold(false);		
				setTextColor(1,1,1,1);
				
				if self[_level0_].GuiActive then							
					self[_level0_].Overlay:render();
					if     self[_level0_].Tooltip           ~= nil and self[_level0_].Tooltip           ~= "" then
						renderText(self[_level0_].TextPosX, self[_level0_].TextPosY, self[_level0_].TextSize ,self[_level0_].Tooltip);
					elseif self[_level0_].InfoText ~= nil and self[_level0_].InfoText ~= "" then
						renderText(self[_level0_].TextPosX, self[_level0_].TextPosY, self[_level0_].TextSize ,self[_level0_].InfoText);
					end
					_newClass_.renderButtons(self);
				end
			end
		end

		------------------------------------------------------------------------
		-- delete
		------------------------------------------------------------------------
		function _newClass_:delete()
			if self[_level0_] ~= nil and self[_level0_].Buttons ~= nil then
				for _,button in pairs(self[_level0_].Buttons) do
					if button.overlays ~= nil then
						for _,overlay in pairs(button.overlays) do
							pcall(Overlay.delete,overlay)
						end
					end
				end
				self[_level0_].Buttons = nil
			end
			pcall(Overlay.delete,self[_level0_].Overlay)
			self[_level0_] = nil
		end;

		------------------------------------------------------------------------
		-- onLeave
		------------------------------------------------------------------------
		function _newClass_:onLeave()
			if self.isClient and self[_level0_] ~= nil and self[_level0_].GuiActive then
				g_inputBinding:setShowMouseCursor(false);		
			end
		end;

		------------------------------------------------------------------------
		-- onEnter
		------------------------------------------------------------------------
		function _newClass_:onEnter()
			if self[_level0_] ~= nil then
				_newClass_.showGui(self, self[_level0_].GuiActive);
				if self.isClient and self[_level0_].GuiActive then
					g_inputBinding:setShowMouseCursor(true);		
				end
			end
		end;
				
		_G[_globalClassName_] = _newClass_ 
	end
	
	_G[mogliHudClass].newClass = newClass 
end
		
