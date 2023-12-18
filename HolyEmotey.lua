local addonName, addon = ...
local radiansToDegrees = 180 / math.pi
local minimapRadius = 80 -- Standard minimap radius, adjust as needed

function createEmoteConfig(name, order)
    return {
        name = name,
        type = "toggle",
        order = order,
        width = "single",
        get = function() return HolyEmotey.db.profile[name] end,
        set = function(info, val) HolyEmotey.db.profile[name] = val; end,
    }
end

function getOptionArgs()
	local args = {}
	for i, name in ipairs(addon.emoteList) do
		args[name] = createEmoteConfig(name, i)
	end
	return args
end

addon.options = {
	name = "HolyEmotey",
	handler = HolyEmotey,
	type = "group",
	args = getOptionArgs(),
}

-- Default Saved Variables
addon.defaults = {
	profile = {
		beg=true,blush=true,bow=true,bye=true,cackle=true,cheer=true,chicken=true,clap=true,confused=true,congrats=true,cower=true,cry=true,dance=true,flex=true,flirt=true,gasp=true,golfclap=true,grin=true,grovel=true,healme=true,helpme=true,hi=true,hug=true,jk=true,kiss=true,kneel=true,laugh=true,lay=true,lost=true,mad=true,moan=true,moo=true,moon=true,no=true,nod=true,oom=true,pat=true,plead=true,point=true,poke=true,ponder=true,pray=true,purr=true,read=true,roar=true,rolleyes=true,rude=true,salute=true,scared=true,sexy=true,shoo=true,shrug=true,shy=true,sigh=true,silly=true,slap=true,sleep=true,smile=true,sorry=true,stare=true,strut=true,surrender=true,talkex=true,tap=true,taunt=true,thanks=true,ty=true,violin=true,wait=true,wave=true,welcome=true,whistle=true,whoa=true,wink=true,yawn=true,yes=true,yw=true,
	},
}

HolyEmotey = LibStub("AceAddon-3.0"):NewAddon("HolyEmotey", "AceConsole-3.0") --, "AceHook-3.0", "AceEvent-3.0")

function HolyEmotey:OnInitialize()
	HolyEmotey.db = LibStub("AceDB-3.0"):New("HolyEmoteyDB", addon.defaults)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("HolyEmotey", addon.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HolyEmotey")

	SLASH_HOLYEMOTEY1 = "/holyemotey"
	SLASH_HOLYEMOTEY2 = "/emotey"
	SlashCmdList["HOLYEMOTEY"] = function(msg)
		showEmotePanel()
	 end 
end

function showSettings()
    InterfaceOptionsFrame_OpenToCategory("HolyEmotey")
    InterfaceOptionsFrame_OpenToCategory("HolyEmotey") -- Call twice due to a known Blizzard bug
end

function doEmote(button)
	local emoteCmd = '/' .. button:GetText():upper();
	DEFAULT_CHAT_FRAME.editBox:SetText(emoteCmd) ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

function showEmotePanel()
	if holyemotey_main_frame and holyemotey_main_frame:IsShown() then
		holyemotey_main_frame:Hide()
		return
	end
	
    if areEmotesLoaded then
        local oldButtons = { holyemotey_main_frame:GetChildren() }

        -- Hide and tag all buttons for potential reuse
        for _, button in ipairs(oldButtons) do
            if button:GetName() then
                button:Hide()
                button.isUsed = false
            end
        end
    end

    renderEmotes()

    areEmotesLoaded = true
    holyemotey_main_frame:Show()
end

function renderEmotes()

	local emoteList = {}
	for key,emote in ipairs(addon.emoteList) do
		if HolyEmotey.db.profile[emote] then
			table.insert(emoteList, emote)
		end
	end

	local count = table.getn(emoteList)
	local columns = math.ceil(count/16)
	local width = columns*100 
	local maxHeight = 400
	local yOffset = -25
	
	holyemotey_main_frame:SetHeight(maxHeight)
	holyemotey_main_frame:SetWidth(width)

	local x = 2
	local y = yOffset

	for key, emote in ipairs(emoteList) do
        local button = findOrCreateButton(emote)
        positionButton(button, x, y)

        -- Calculate position for next button
        y = y - 23
        if y < (-1 * maxHeight) + 20 then
            y = yOffset
            x = x + 100
        end
    end
end

function findOrCreateButton(name)
    local button = findButtonByName(name)

    if not button then
        button = CreateFrame("Button", name, holyemotey_main_frame, "UIPanelButtonTemplate")
        button:SetWidth(80)
        button:SetHeight(22)
        button:SetScript("OnClick", function(self, arg1)
            doEmote(button)
        end)
    end

    button.isUsed = true
    return button
end

function findButtonByName(name)
    local children = { holyemotey_main_frame:GetChildren() }
    for _, button in ipairs(children) do
        if button:GetName() == name then
            return button
        end
    end
    return nil
end

function positionButton(button, x, y)
    button:SetPoint("TOP", 0, y)
    button:SetPoint("LEFT", x, 0)
    button:SetText(button:GetName())
    button:Show()
end
