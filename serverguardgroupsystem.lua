local self = {}
CAC.ServerGuardGroupSystem = CAC.MakeConstructor (self, CAC.IReadOnlyGroupSystem)

function self:ctor ()
end

-- IReadOnlyGroupSystem
function self:GetId ()
	return "ServerGuardGroupSystem"
end

function self:GetName ()
	return "ServerGuard"
end

function self:IsAvailable ()
	return istable (serverguard)
end

function self:IsDefault ()
	return false
end

-- Groups
function self:GetGroupEnumerator ()
	return CAC.KeyEnumerator (serverguard.ranks:GetStored ())
end

function self:GetGroupReference (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return CAC.GroupReference (self:GetId (), groupId)
end

function self:GroupExists (groupId)
	return serverguard.ranks:GetStored () [groupId] ~= nil
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
	
	return serverguard.ranks:GetVariable (groupId, "color")
end

function self:GetGroupDisplayName (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return serverguard.ranks:GetVariable (groupId, "name")
end

function self:GetGroupIcon (groupId)
	if not self:GroupExists (groupId) then return nil end
	
	return serverguard.ranks:GetVariable (groupId, "texture")
end

-- Users
function self:GetUserGroup (userId)
	local ply = CAC.PlayerMonitor:GetUserEntity (userId)
	if ply and ply:IsValid () then
		return serverguard.player:GetRank (ply)
	end
	
	return nil
end

function self:GetUserGroupEnumerator (userId)
	return CAC.SingleValueEnumerator (self:GetUserGroup (groupId))
end

function self:IsUserInGroup (userId, groupId)
	local userGroupId = self:GetUserGroup (userId)
	if userGroupId == groupId then return true end
	
	return self:IsGroupSubsetOfGroup (userGroupId, groupId)
end

CAC.SystemRegistry:RegisterSystem ("GroupSystem", CAC.ServerGuardGroupSystem ())