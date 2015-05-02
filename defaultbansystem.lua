local self = {}
CAC.DefaultBanSystem = CAC.MakeConstructor (self, CAC.IBanSystem)

function self:ctor ()
end

-- IReadOnlyBanSystem
function self:GetId ()
	return "DefaultBanSystem"
end

function self:GetName ()
	return "Default"
end

function self:IsAvailable ()
	return true
end

function self:IsDefault ()
	return true
end

-- Bans
function self:IsUserBanned (userId)
	return false
end

function self:GetCurrentBan (userId)
	return nil
end

function self:GetBanReason (banId)
	return nil
end

function self:GetBanTimeRemaining (banId)
	return nil
end

function self:GetBannerId (banId)
	return nil
end

-- IBanSystem
function self:Ban (userId, duration, reason, bannerId)
	if duration == math.huge then duration = 0 end
	
	local ply = CAC.PlayerMonitor:GetUserEntity (userId)
	if ply and ply:IsValid () then
		ply:Ban (duration / 60, false)
	else
		RunConsoleCommand ("banid", tostring (duration / 60), userId)
	end
end

function self:CanBanOfflineUsers ()
	return true
end

CAC.SystemRegistry:RegisterSystem ("BanSystem", CAC.DefaultBanSystem ())