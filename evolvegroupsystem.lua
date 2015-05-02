local self = {}
CAC.EvolveGroupSystem = CAC.MakeConstructor (self, CAC.IReadOnlyGroupSystem)

function self:ctor ()
end

-- IReadOnlyGroupSystem
function self:GetId ()
	return "EvolveGroupSystem"
end

function self:GetName ()
	return "Evolve"
end

function self:IsAvailable ()
	return istable (evolve)
end

function self:IsDefault ()
	return false
end

-- Groups
function self:GetGroupEnumerator ()
	return CAC.KeyEnumerator (evolve.ranks)
end

function self:GetGroupReference (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return CAC.GroupReference (self:GetId (), groupId)
end

function self:GroupExists (groupId)
	return evolve.ranks [groupId] ~= nil
end

function self:GetBaseGroup (groupId)
	return nil
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
	if not self:GroupExists (groupId) then return nil end
	
	return evolve.ranks [groupId].Color
end

function self:GetGroupDisplayName (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return evolve.ranks [groupId].Title
end

function self:GetGroupIcon (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return "icon16/" .. evolve.ranks [groupId].Icon .. ".png"
end

-- Users
function self:IsUserInGroup (userId, groupId)
	local userGroupId = self:GetUserGroup (userId)
	if userGroupId == groupId then return true end
	
	return self:IsGroupSubsetOfGroup (userGroupId, groupId)
end

function self:GetUserGroup (userId)
	local ply = CAC.PlayerMonitor:GetUserEntity (userId)
	if ply and not ply:IsValid () then ply = nil end
	
	if ply then
		return ply:GetNWString ("EV_UserGroup")
	end
	
	local uniqueId = CAC.SteamIdToUniqueId (userId)
	return evolve:GetProperty (uniqueId, "Rank")
end

function self:GetUserGroupEnumerator (userId)
	return CAC.SingleValueEnumerator (self:GetUserGroup (groupId))
end

CAC.SystemRegistry:RegisterSystem ("GroupSystem", CAC.EvolveGroupSystem ())