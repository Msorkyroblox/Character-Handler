--[[
WRITTEN BY SIRJLEB - 10/9/22
USAGE:
CharacterModule:State(
	Argument 1: Create or Remove
	Argument 2: The state
	Argument 3: (Time then Argument 4 Character) or (Character)
)
CharacterModule:SpeedOrJump(
	Argument 1: Create or Remove
	Argument 2: The type (Speed or Jump)
	Argument 3 The value of type
	Argument 4: (Time and argument 5 charcter) or Character
) 
]]

local CharacterModule = {}
CharacterModule.__index = CharacterModule

function CharacterModule.new(Character)
	if CharacterModule[Character] == nil then
		Character:SetAttribute("WalkSpeedDefault",16)
		Character:SetAttribute("JumpPowerDefault",50)
		
		Character:WaitForChild("Humanoid").UseJumpPower = true
		Character.Humanoid.WalkSpeed = Character:GetAttribute("WalkSpeedDefault")
		Character.Humanoid.JumpPower = Character:GetAttribute("JumpPowerDefault")
		
		CharacterModule[Character] = setmetatable({
			__statedata = {},
			__movementdata = {
				WalkSpeed = {},
				JumpPower = {},
			},
		},CharacterModule)
		
		Character.AncestryChanged:Connect(function(_,Parent)
			if Parent ~= nil then
				return
			end
 			CharacterModule[Character] = nil
		end)
	end
	
	return CharacterModule[Character]
end

function CharacterModule:State(...)	
	local Arguments = {...}
	
	local Character = Arguments[#Arguments]
	
	local self = CharacterModule.new(Character)
	
	local Action = Arguments[1]
	local StateName = Arguments[2]
	local Time = (typeof(Arguments[3]) == "number" and Arguments[3])
	
	if Action == "Create" then
		self.__statedata[StateName] = (self.__statedata[StateName] == nil and 1) or self.__statedata[StateName] + 1
	elseif Action == "Remove" then
		self.__statedata[StateName] = (self.__statedata[StateName] == nil and 0) or self.__statedata[StateName] - 1
	end
	
	Character:SetAttribute(StateName,(self.__statedata[StateName] > 0 and true) or nil)
 	if Time then
		task.delay(Time,function()
			if Character and Character.Parent then
 				CharacterModule:State(
					"Remove",
					StateName,
					Character
				)
			end
		end)
	end
end

function CharacterModule:SpeedOrJump(...)
	local Arguments = {...}
	
	local Character = Arguments[#Arguments]

	local self = CharacterModule.new(Character)

	local Action = Arguments[1]
	local Type = Arguments[2]
	local Number = Arguments[3]
	
	local Time = (typeof(Arguments[4]) == "number" and Arguments[4])

	if Action == "Create" then
		table.insert(self.__movementdata[Type],Number)
		table.sort(self.__movementdata[Type])
		Character.Humanoid[Type] = self.__movementdata[Type][1]
	elseif Action == "Remove" then
		if table.find(self.__movementdata[Type],Number) then
			table.remove(self.__movementdata[Type],table.find(self.__movementdata[Type],Number))
			table.sort(self.__movementdata[Type])
			Character.Humanoid[Type] = self.__movementdata[Type][1] or Character:GetAttribute(Type.."Default")
		end
	end
	
	if Time then
		task.delay(Time,function()
			if Character and Character.Parent then
				CharacterModule:SpeedOrJump(
					"Remove",
					Type,
					Number,
					Character
				)				
			end
		end)
	end
end

 
return CharacterModule
