local self = {}
CAC.UserReference = CAC.MakeConstructor (self, CAC.Serialization.ISerializable)

function self:ctor (userId)
	self.UserId      = userId
	self.DisplayName = self.UserId
	
	self:UpdateDisplayName ()
end

-- ISerializable
function self:Serialize (outBuffer)
	self:UpdateDisplayName ()
	
	outBuffer:StringN8 (self.UserId     )
	outBuffer:StringN8 (self.DisplayName)
end

function self:Deserialize (inBuffer)
	self:SetUserId (inBuffer:StringN8 ())
	self.DisplayName = inBuffer:StringN8 ()
	
	self:UpdateDisplayName ()
end

function self:Clone (clone)
	clone = clone or self.__ictor ()
	
	clone:Copy (self)
	
	return clone
end

function self:Copy (source)
	self:SetUserId (source:GetUserId ())
	self.DisplayName = source.DisplayName
	
	return self
end

-- Membership
function self:ContainsUser (userId)
	if userId == "STEAM_0:0:0" and
	   game.SinglePlayer () then
		userId = CAC.GetPlayerId (player.GetAll () [1])
	end
	
	return self.UserId == userId
end

function self:MatchesUser (userId)
	return self:ContainsUser (userId)
end

-- UserReference
function self:GetDisplayName ()
	self:UpdateDisplayName ()
	
	return self.DisplayName
end

function self:GetUserId ()
	return self.UserId
end

function self:SetUserId (userId)
	if self.UserId == userId then return self end
	
	self.UserId      = userId
	self.DisplayName = self.UserId
	
	self:UpdateDisplayName ()
	
	return self
end

function self:ToString ()
	return self.UserId
end

-- Internal, do not call
function self:UpdateDisplayName ()
	if not self.UserId then return end
	
	local displayName = CAC.PlayerMonitor:GetUserName (self.UserId)
	if displayName == self.UserId then return end
	
	self.DisplayName = displayName
end