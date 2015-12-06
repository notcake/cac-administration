# !cake Anti-Cheat Administration Interfaces
Administration interfaces and implementations used in !cake Anti-Cheat.  
Licensed under the MIT license.

Batteries not included. Not guaranteed to be suitable for your needs.  
Some work is required to get this to run - see the [Missing Batteries](#missing-batteries) section.  
You should rename the CAC table to something else if you use the code in this repository.

## Examples
**Print whether the local client is in the "admin" group in the "best" installed admin mod.**
```Lua
local groupSystem = SystemRegistry:GetBestSystem ("GroupSystem")
print (groupSystem:IsUserInGroup (LocalPlayer ():SteamID (), "admin"))
```

**Print a list of all groups in the "best" installed admin mod.**
```Lua
local groupSystem = SystemRegistry:GetBestSystem ("GroupSystem")
print (groupSystem:GetName () .. " groups:")
for groupId in groupSystem:GetGroupEnumerator () do
	local groupDisplayName = groupSystem:GetGroupDisplayName (groupId)
	print ("\t" .. groupDisplayName)
end
```

**Ban a user using the "best" installed admin mod.**
```Lua
local banSystem = SystemRegistry:GetBestSystem ("BanSystem")
banSystem:Ban (LocalPlayer ():SteamID (), 3600, "Test ban", nil)
```

## Supported functionality
### Supported admin mod tasks
See the [Interfaces](#interfaces) section.

- Querying of group system
- Querying of user groups
- Submitting bans

### Currently unsupported admin mod tasks
None of these are required at all for !cake Anti-Cheat, apart from ban querying.

- Usage of command system
- Modification of groups
- Modification of user groups
- Querying / modification of group or user permissions
- Querying of bans

### Currently missing functions
These are not required at all for !cake Anti-Cheat, since Player:IsAdmin () is sufficient.

```C#
bool IReadOnlyGroupSystem:IsGroupAdmin (GroupId groupId)
bool IReadOnlyGroupSystem:IsGroupSuperAdmin (GroupId groupId)

bool IReadOnlyGroupSystem:IsUserAdmin (SteamId steamId)
bool IReadOnlyGroupSystem:IsUserSuperAdmin (SteamId steamId)
```

### Supported administration addons
- ULib / ULX
- Evolve
- ServerGuard
- Vermilion 2
- ULX SourceBans ban system
- ULX SourceBans ban system (Blasteh)
- SourceBans ban system
- ASSMod ban system
- Clockwork ban system

### Currently missing support
- Moderator
- All other admin mods not on the previous list

## "Documentation"
### System Registry
```C#
SystemId : string;

// Not explicitly declared in the code
enum SystemType
{
	ReadOnlyGroupSystem = "GroupSystem",
	BanSystem           = "BanSystem"
}

// Not explicitly declared in the code.
interface ISystem
{
	SystemId                   GetId ();       // eg. "ULibGroupSystem"
	string                     GetName ();     // eg. "ULX Group System"
	bool                       IsAvailable (); // true if the addon is installed
	bool                       IsDefault ();   // true if this system should only be used as a last resort
}

class SystemRegistry
{
	Iterator<ISystem>          GetSystemEnumerator (SystemType systemType);
	ISystem                    GetSystem (SystemType systemType, SystemId systemId);
	ISystem                    GetBestSystem (SystemType systemType);
	
	void                       RegisterSystem (SystemType systemType, ISystem system);
	void                       UnregisterSystem (SystemType systemType, ISystem system);
}

SystemRegistry SystemRegistry;
```

### Interfaces
```C#
SteamId       : string;
```

#### Group Systems
```C#
GroupSystemId : SystemId;
GroupId       : string;

// SystemType == "GroupSystem"
interface IReadOnlyGroupSystem : ISystem
{
	// Groups
	Iterator<GroupId>          GetGroupEnumerator ();
	GroupId                    GetBaseGroup (GroupId groupId);
	Iterator<GroupId>          GetBaseGroupEnumerator ();
	bool                       IsGroupSubsetOfGroup (GroupId baseGroupId, GroupId groupId);
	bool                       IsGroupSupersetOfGroup (GroupId groupId, GroupId baseGroupId);
	
	// Group
	Color                      GetGroupColor (GroupId groupId);
	string                     GetGroupDisplayName (GroupId groupId);
	string                     GetGroupIcon (GroupId groupId); // eg. "icon16/shield.png"
	
	// Users
	GroupId                    GetUserGroup (SteamId steamId);
	Iterator<GroupId>          GetUserGroupEnumerator (SteamId steamId);
	bool                       IsUserInGroup (SteamId steamId, GroupId groupId);
}
```

#### Ban Systems
```C#
BanId : *;

interface IReadOnlyBanSystem : ISystem
{
	// Bans
	bool                       IsUserBanned (SteamId steamId);
	BanId?                     GetCurrentBan (SteamId steamId);
	string                     GetBanReason (BanId banId);
	number                     GetBanTimeRemaining (BanId banId); // in seconds
	SteamId                    GetBannerId (BanId banId);
}

// SystemType == "BanSystem"
interface IBanSystem : IReadOnlyBanSystem
{
	void                       Ban (SteamId steamId, number duration, string reason, SteamId? bannerId); // duration in seconds
	bool                       CanBanOfflineUsers ();
}
```

### Miscellaneous
```C#
interface Serialization.ISerializable
{
	void                       Serialize (IOutBuffer outBuffer);
	void                       Deserialize (IInBuffer inBuffer);
}

// Not explicitly declared in the code.
interface IActorReference : Serialization.ISerializable
{
	<typeof (self)>            Clone (<typeof (self)>? clone);
	<self>                     Copy (<typeof (self)> source);
	
	// Reference
	string                     GetDisplayName ();
	bool                       IsGroupReference ();
	bool                       IsUserReference ();
	string                     ToString ()
	
	// Membership
	bool                       ContainsUser (SteamId steamId);
	bool                       MatchesUser (SteamId steamId);
}

class GroupReference : IActorReference
{
	GroupReference (GroupSystemId groupSystemId, GroupId groupId);
	
	// GroupReference
	string                     GetGroupDisplayName (string? fallbackDisplayName);
	string                     GetGroupIcon (string? fallbackIcon);
	IReadOnlyGroupSystem       GetGroupSystem ();
	<self>                     SetGroupSystem (IReadOnlyGroupSystem groupSystem);
	GroupSystemId              GetGroupSystemId ();
	<self>                     SetGroupSystemId (GroupSystemId groupSystemId);
	GroupId                    GetGroupId ();
	<self>                     SetGroupId (GroupId groupId);
}

class UserReference : IActorReference
{
	UserReference (SteamId steamId);
	
	// UserReference
	SteamId                    GetUserId ();
	<self>                     SetUserId (SteamId steamId);
}
```

#### Partial system implementations
```C#
abstract class SimpleReadOnlyGroupSystem : IReadOnlyGroupSystem
{
	// ISystem
	abstract SystemId          GetId ();
	abstract string            GetName ();
	abstract bool              IsAvailable ();
	bool                       IsDefault ();
	
	// IReadOnlyGroupSystem
	// Groups
	abstract Iterator<GroupId> GetGroupEnumerator ();
	abstract GroupId           GetBaseGroup (GroupId groupId);
	Iterator<GroupId>          GetBaseGroupEnumerator ();
	bool                       IsGroupSubsetOfGroup (GroupId baseGroupId, GroupId groupId);
	bool                       IsGroupSupersetOfGroup (GroupId groupId, GroupId baseGroupId);
	
	// Group
	abstract Color             GetGroupColor (GroupId groupId);
	abstract string            GetGroupDisplayName (GroupId groupId);
	abstract string            GetGroupIcon (GroupId groupId); // eg. "icon16/shield.png"
	
	// Users
	abstract GroupId           GetUserGroup (SteamId steamId);
	Iterator<GroupId>          GetUserGroupEnumerator (SteamId steamId);
	bool                       IsUserInGroup (SteamId steamId, GroupId groupId);
	
	// SimpleReadOnlyGroupSystem
	GroupReference             GetGroupReference (GroupId groupId);
}

// Pretty much useless
abstract class BanSystem : IBanSystem
{
	// ISystem
	abstract SystemId          GetId ();
	abstract string            GetName ();
	abstract bool              IsAvailable ();
	bool                       IsDefault ();
	
	// IReadOnlyBanSystem
	// All implementations return nil or false
	bool                       IsUserBanned (SteamId steamId);
	BanId?                     GetCurrentBan (SteamId steamId);
	string                     GetBanReason (BanId banId);
	number                     GetBanTimeRemaining (BanId banId); // in seconds
	SteamId                    GetBannerId (BanId banId);
	
	// IBanSystem
	abstract void              Ban (SteamId steamId, number duration, string reason, SteamId? bannerId); // duration in seconds
	abstract bool              CanBanOfflineUsers ();
}

```

### Missing Batteries
These functions are not included in this repository.  
Implement them however you want or scrap their usage altogether.  
You should rename the CAC table to something else if you use the code in this repository in production.

#### Lazy way to get this to work
```Lua
include ("glib/glib.lua") -- https://github.com/notcake/glib

CAC = GLib

include ("administration/systemregistry.lua")
include ("administration/ireadonlygroupsystem.lua")
include ("administration/ireadonlybansystem.lua")
include ("administration/ibansystem.lua")

include ("administration/simplereadonlygroupsystem.lua")
include ("administration/bansystem.lua")

include ("administration/iactorreference.lua")
include ("administration/groupreference.lua")
include ("administration/userreference.lua")

include ("administration/defaultgroupsystem.lua")
include ("administration/ulibgroupsystem.lua")
include ("administration/evolvegroupsystem.lua")
include ("administration/moderatorgroupsystem.lua")
include ("administration/serverguardgroupsystem.lua")
include ("administration/vermilion2groupsystem.lua")
include ("administration/maestrogroupsystem.lua")

include ("administration/defaultbansystem.lua")
include ("administration/ulibbansystem.lua")
include ("administration/ulxsourcebansbansystem.lua")
include ("administration/ulxsourcebansbansystem2.lua")
include ("administration/evolvebansystem.lua")
include ("administration/moderatorbansystem.lua")
include ("administration/sourcebansbansystem.lua")
include ("administration/assmodbansystem.lua")
include ("administration/serverguardbansystem.lua")
include ("administration/vermilion2bansystem.lua")
include ("administration/maestrobansystem.lua")
include ("administration/clockworkbansystem.lua")
```

#### Things you have to implement if you don't choose the lazy way
```C#
Constructor<T> MakeConstructor (table unfinalizedMethodTable, Constructor<BaseT> baseClassConstructor);
where Constructor<T> : Either<function<(...) -> T>, table with metatable.__call : function<(_, ...) -> T> defined>;

Constructor<Serialization.ISerializable> Serialization.ISerializable = nil;

{
	// Iterator returns item, then nil forevermore.
	Iterator<T> SingleValueEnumerator (T item);

	// Iterator should have same behaviour as return value of ipairs (array), dropping the numeric index.
	Iterator<T> ArrayEnumerator (table<int -> T> array);

	// Iterator should have the same behaviour as return values of pairs (table), dropping the values.
	Iterator<T> KeyEnumerator (table<T -> *> table);
}
where Iterator<T> : function<() -> T>;

Player PlayerMonitor:GetUserEntity (SteamId steamId);
string PlayerMonitor:GetUserName (SteamId steamId);
```

#### Partial implementation
```Lua
-- MakeConstructor = function (methodTable, baseConstructor)

Serialization = Serialization or {}

SingleValueEnumerator = function (item)
	return function ()
		local v = item
		item = nil
		return v
	end
end

ArrayEnumerator = function (array)
	local i = 0
	return function ()
		i = i + 1
		return array [i]
	end
end

-- KeyEnumerator = function (t)

PlayerMonitor = {}
PlayerMonitor.GetUserEntity = function (self, steamId)
	for _, ply in ipairs (player.GetAll ()) do
		if ply:SteamID () == steamId then
			return ply
		end
	end
	return nil
end

PlayerMonitor.GetUserName = function (self, steamId)
	local ply = self:GetUserEntity (steamId)
	if not ply or not ply:IsValid () then return steamId end
	return ply:Name ()
end
```