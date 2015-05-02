local self = {}
CAC.ULibGroupSystem = CAC.MakeConstructor (self, CAC.IReadOnlyGroupSystem)

function self:ctor ()
end

-- IReadOnlyGroupSystem
function self:GetId ()
	return "ULibGroupSystem"
end

function self:GetName ()
	return "ULX"
end

function self:IsAvailable ()
	return istable (ULib) and istable (ULib.ucl)
end

function self:IsDefault ()
	return false
end

-- Groups
function self:GetGroupEnumerator ()
	return CAC.KeyEnumerator (ULib.ucl.groups)
end

function self:GetGroupReference (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return CAC.GroupReference (self:GetId (), groupId)
end

function self:GroupExists (groupId)
	return ULib.ucl.groups [groupId] ~= nil
end

function self:GetBaseGroup (groupId)
	local baseGroupId = ULib.ucl.groupInheritsFrom (groupId)
	
	if baseGroupId == false then return nil end
	
	return baseGroupId
end

function self:GetBaseGroupEnumerator (groupId)
	return CAC.SingleValueEnumerator (self:GetBaseGroup (groupId))
end

function self:IsGroupSubsetOfGroup (groupId, baseGroupId)
	-- Does groupId inherit from baseGroupId?
	groupId = self:GetBaseGroup (groupId)
	
	while groupId do
		if groupId == baseGroupId then return true end
		
		groupId = self:GetBaseGroup (groupId)
	end
	
	return false
end

function self:IsGroupSupersetOfGroup (baseGroupId, groupId)
	-- Does groupId inherit from baseGroupId?
	return self:IsGroupSubsetOfGroup (groupId, baseGroupId)
end

-- Group
function self:GetGroupColor (groupId)
	if groupId == ULib.ACCESS_SUPERADMIN or self:IsGroupSubsetOfGroup (groupId, ULib.ACCESS_SUPERADMIN) then return Color (255,   0,   0, 255) end
	if groupId == ULib.ADMIN             or self:IsGroupSubsetOfGroup (groupId, ULib.ACCESS_ADMIN     ) then return Color (255, 127,   0, 255) end
	
	return Color (127, 127, 127, 255)
end

function self:GetGroupDisplayName (groupId)
	return groupId
end

function self:GetGroupIcon (groupId)
	if groupId == ULib.ACCESS_SUPERADMIN or self:IsGroupSubsetOfGroup (groupId, ULib.ACCESS_SUPERADMIN) then return "icon16/shield_add.png" end
	if groupId == ULib.ACCESS_ADMIN      or self:IsGroupSubsetOfGroup (groupId, ULib.ACCESS_ADMIN     ) then return "icon16/shield.png"     end
	
	return "icon16/user.png"
end

-- Users
function self:GetUserGroup (userId)
	local ply = CAC.PlayerMonitor:GetUserEntity (userId)
	if ply and ply:IsValid () then
		return ply:GetUserGroup ()
	end
	
	return ULib.ACCESS_ALL
end

function self:GetUserGroupEnumerator (userId)
	return CAC.SingleValueEnumerator (self:GetUserGroup (groupId))
end

function self:IsUserInGroup (userId, groupId)
	local userGroupId = self:GetUserGroup (userId)
	if userGroupId == groupId then return true end
	
	return self:IsGroupSubsetOfGroup (userGroupId, groupId)
end

CAC.SystemRegistry:RegisterSystem ("GroupSystem", CAC.ULibGroupSystem ())