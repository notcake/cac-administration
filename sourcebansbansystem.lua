local self = {}
CAC.SourceBansBanSystem = CAC.MakeConstructor (self, CAC.IBanSystem)

function self:ctor ()
end

-- IReadOnlyBanSystem
function self:GetId ()
	return "SourceBansBanSystem"
end

function self:GetName ()
	return "SourceBans"
end

function self:IsAvailable ()
	return istable (sourcebans)
end

function self:IsDefault ()
	return false
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
	
	local banner = CAC.PlayerMonitor:GetUserEntity (bannerId) or NULL
	if not banner:IsValid () then banner = NULL end
	
	sourcebans.BanPlayerBySteamID (userId, duration, reason, banner)
end

function self:CanBanOfflineUsers ()
	return true
end

CAC.SystemRegistry:RegisterSystem ("BanSystem", CAC.SourceBansBanSystem ())