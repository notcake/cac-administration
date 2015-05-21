!cake Anti-Cheat Administration Interfaces
========================
Administration interfaces and implementations used in !cake Anti-Cheat.
Licensed under the MIT license.

Batteries not included.
You should rename the CAC table to something else if you use the code in this repository.

Supported admin mod tasks
------------------------
- Querying of group system
- Querying of user groups
- Submitting bans

Currently unsupported admin mod tasks
------------------------
- Usage of command system
- Modification of groups
- Modification of user groups
- Querying / modification of group or user permissions
- Querying of bans

System Registry
------------------------
```
SystemId : string;

// Not explicitly declared in the code
enum SystemType
{
	ReadOnlyGroupSystem = "GroupSystem",
	BanSystem           = "BanSystem"
}

// Not explicitly declared in the code.
ISystem
{
	SystemId             GetId (); // eg. "ULibGroupSystem"
	string               GetName (); // "ULX Group System"
	bool                 IsAvailable ();
	bool                 IsDefault ();
}

SystemRegistry
{
	Iterator<ISystem>    GetSystemEnumerator (SystemType systemType);
	ISystem              GetSystem (SystemType systemType, SystemId systemId);
	ISystem              GetBestSystem (SystemType systemType);
	
	void                 RegisterSystem (SystemType systemType, ISystem system);
	void                 UnregisterSystem (SystemType systemType, ISystem system);
}

SystemRegistry SystemRegistry;
```

Missing Batteries
------------------------
These functions are not included in this repository.
Implement them however you want or scrap their usage altogether.
You should rename the CAC table to something else if you use the code in this repository.

```
Constructor<T> MakeConstructor (table unfinalizedMethodTable, Constructor<BaseT> baseClassConstructor);
where Constructor<T> : Either<function<(...) -> T>, table with metatable.__call : function<(_, ...) -> T> defined>;

{
	// Iterator returns item, then nil forevermore.
	Iterator<T> SingleValueEnumerator (T item);

	// Iterator should have same behaviour as return value of ipairs (array), dropping the numeric index.
	Iterator<T> ArrayEnumerator (table<int -> T> array);

	// Iterator should have hte same behaviour as return values of pairs (table), dropping the values.
	Iterator<T> KeyEnumerator (table<T -> *> table);
}
where Iterator<T> : function<() -> T>;

Player PlayerMonitor:GetUserEntity (SteamId steamId);
string PlayerMonitor:GetUserName (SteamId steamId);
```

Interfaces
------------------------
```
SteamId       : string;

GroupSystemId : SystemId;
GroupId       : string;

// SystemType == "GroupSystem"
IReadOnlyGroupSystem : ISystem
{
	// Groups
	Iterator<GroupId>    GetGroupEnumerator ();
	GroupId              GetBaseGroup (GroupId groupId);
	Iterator<GroupId>    GetBaseGroupEnumerator ();
	bool                 IsGroupSubsetOfGroup (GroupId baseGroupId, GroupId groupId);
	bool                 IsGroupSupersetOfGroup (GroupId groupId, GroupId baseGroupId);
	
	// Group
	Color                GetGroupColor (GroupId groupId);
	string               GetGroupDisplayName (GroupId groupId);
	string               GetGroupIcon (GroupId groupId); // eg. "icon16/shield.png"
	
	// Users
	GroupId              GetUserGroup (SteamId steamId);
	Iterator<GroupId>    GetUserGroupEnumerator (SteamId steamId);
	bool                 IsUserInGroup (SteamId steamId, GroupId groupId);
}

BanId : *;

IReadOnlyBanSystem : ISystem
{
	// Bans
	bool                 IsUserBanned (SteamId steamId);
	BanId                GetCurrentBan (SteamId steamId);
	string               GetBanReason (BanId banId);
	number               GetBanTimeRemaining (BanId banId); // in seconds
	SteamId              GetBannerId (BanId banId);
}

// SystemType == "BanSystem"
IBanSystem : IReadOnlyBanSystem
{
	void                 Ban (SteamId steamId, number duration, string reason, SteamId? bannerId); // duration in seconds
	bool                 CanBanOfflineUsers ();
}
```

Glue
------------------------
```
Serialization.ISerializable
{
	void                 Serialize (IOutBuffer outBuffer);
	void                 Deserialize (IInBuffer inBuffer);
}

// Not explicitly declared in the code.
Reference : Serialization.ISerializable
{
	Reference            Clone (<typeof (self)>? clone);
	<self>               Copy (<typeof (self)> source);
	
	// Membership
	bool                 ContainsUser (SteamId steamId);
	bool                 MatchesUser (SteamId steamId);
}

GroupReference : Reference
{
	GroupReference (GroupSystemId groupSystemId, GroupId groupId);
	
	// GroupReference
	string               GetDisplayName ();
	string               GetGroupDisplayName (string? fallbackDisplayName);
	string               GetGroupIcon (string? fallbackIcon);
	IReadOnlyGroupSystem GetGroupSystem ();
	<self>               SetGroupSystem (IReadOnlyGroupSystem groupSystem);
	GroupSystemId        GetGroupSystemId ();
	<self>               SetGroupSystemId (GroupSystemId groupSystemId);
	GroupId              GetGroupId ();
	<self>               SetGroupId (GroupId groupId);
	
	string               ToString ();
}

UserReference : Reference
{
	UserReference (SteamId steamId);
	
	// UserReference
	string               GetDisplayName ();
	SteamId              GetUserId ();
	<self>               SetUserId (SteamId steamId);
	
	string               ToString ();
}
```