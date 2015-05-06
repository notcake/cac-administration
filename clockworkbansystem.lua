local self = {}
CAC.ClockworkBanSystem = CAC.MakeConstructor (self, CAC.IBanSystem)

function self:ctor ()
end

-- IReadOnlyBanSystem
function self:GetId ()
	return "ClockworkBanSystem"
end

function self:GetName ()
	return "Clockwork"
end

function self:IsAvailable ()
	return istable (Clockwork)
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
	
	Clockwork.bans:Add (userId, duration, reason)
end

function self:CanBanOfflineUsers ()
	return true
end

CAC.SystemRegistry:RegisterSystem ("BanSystem", CAC.ClockworkBanSystem ())