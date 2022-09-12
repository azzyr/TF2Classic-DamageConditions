#include <tf2c>
#include <sdkhooks>
#include <sdktools>
#include <anymap>

#pragma newdecls required
#pragma semicolon 1;

AnyMap WeaponMap;

public Plugin myinfo = 
{
	name = "TF2Classic-CritVsCond",
	author = "azzy",
	description = "Expansion upon TF2Classic's or_crit_vs_playercond attribute, allowing usage of every available condition",
	version = "1.2",
	url = ""
}

public void OnPluginStart()
{
	WeaponMap = new AnyMap();
	
	ParseConfig();

	RegConsoleCmd("sm_critvscond_reload", ReloadCommandHandler, "Reload configuration file");

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i))
			OnClientPutInServer(i);
}

void ParseConfig()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/TF2Classic-CritVsCond.cfg");

	if(!FileExists(path)) 
		SetFailState("[TF2Classic-CritVsCond] Configuration file not found: %s", path);

	KeyValues kv = new KeyValues("Weapons");

	if(!kv.ImportFromFile(path))
		SetFailState("[TF2Classic-CritVsCond] Unable to parse configuration file");

	if(!kv.GotoFirstSubKey())
		SetFailState("[TF2Classic-CritVsCond] No weapons listed");
	
	do
	{
		char weapon[5];
		if(!kv.GetSectionName(weapon, sizeof(weapon)))
			SetFailState("[TF2Classic-CritVsCond] Invalid Configuration File");
		
		int weaponid = StringToInt(weapon);
		int cond = kv.GetNum("cond");
		int crittype = kv.GetNum("crittype");

		if(!weaponid)
			SetFailState("[TF2Classic-CritVsCond] Invalid Weapon ID");

		if(!cond)
			PrintToServer("[TF2Classic-CritVsCond] WARNING: Weapon ID %d may have invalid Cond check value. This is safe to ignore if value has been manually set to 0 (TF_COND_BURNING)", weaponid);

		if(!crittype)
			SetFailState("[TF2Classic-CritVsCond] Invalid Crit Type on weapon ID %d", weaponid);


		int weaponData[2];
		weaponData[0] = cond;
		weaponData[1] = crittype;
		
		WeaponMap.SetArray(weaponid, weaponData, 2);

		PrintToServer("[TF2Classic-CritVsCond] Weapon ID %d parsed", weaponid);
	}
	while(kv.GotoNextKey());
}

public void OnClientPutInServer(int client) 
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damageType, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(weapon == -1)
		return Plugin_Continue;
	
	int weaponIndex;

	char classname[32];
	GetEntityClassname(weapon, classname, 32);

	if(strcmp(classname, "obj_sentrygun") == 0)
		weaponIndex = GetWeaponIndex(GetPlayerWeaponSlot(attacker, TFWeaponSlot_Grenade));
	else
		weaponIndex = GetWeaponIndex(weapon);
	
	int weaponData[2];

	if(WeaponMap.GetArray(weaponIndex, weaponData, 2))
		if(TF2_IsPlayerInCondition(victim, view_as<TFCond>(weaponData[0])))
			switch(weaponData[1])
			{
				case 1:	// crit
				{
					damageType |= DMG_ACID;
					return Plugin_Changed;
				}

				case 2: // minicrit
				{
					if (!TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeath))
					{
						TF2_AddCondition(victim, TFCond_MarkedForDeath);
						SDKHook(victim, SDKHook_OnTakeDamagePost, Hook_RemoveMinicrits);
					}					
				}
			}

	return Plugin_Continue;
}

Action Hook_RemoveMinicrits(int victim)
{
	SDKUnhook(victim, SDKHook_OnTakeDamagePost, Hook_RemoveMinicrits);
	TF2_RemoveCondition(victim, TFCond_MarkedForDeath);
}

public Action ReloadCommandHandler(int client, int args)
{
	PrintToServer("Reloading...");
	ParseConfig();
}

stock bool IsValidEnt(int ent)
{
    return ent > MaxClients && IsValidEntity(ent);
}

stock int GetWeaponIndex(int weapon)
{
    return IsValidEnt(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"):-1;
}
