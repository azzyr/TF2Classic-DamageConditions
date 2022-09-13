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
	version = "1.3",
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
		int minicrit = kv.GetNum("minicrit");
		int selfcond = kv.GetNum("selfcond");

		if(weaponid < 0)
			SetFailState("[TF2Classic-CritVsCond] WARNING: Invalid Weapon ID");

		if(cond < 0 || cond > 114)
			SetFailState("[TF2Classic-CritVsCond] WARNING: Weapon ID %d has invalid Cond Value", weaponid);

		if(minicrit != 0 && minicrit != 1)
			SetFailState("[TF2Classic-CritVsCond] WARNING: Weapon ID %d has invalid Crit Type", weaponid);

		if(selfcond != 0 && selfcond != 1)
			SetFailState("[TF2Classic-CritVsCond] WARNING: Weapon ID %d has invalid Crit Check Mode", weaponid);

		int weaponData[3];
		weaponData[0] = cond;
		weaponData[1] = minicrit;
		weaponData[2] = selfcond;
		
		WeaponMap.SetArray(weaponid, weaponData, 3);

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

	char classname[16];
	GetEntityClassname(weapon, classname, 16);

	if(strcmp(classname, "obj_sentrygun") == 0)
		weaponIndex = GetWeaponIndex(GetPlayerWeaponSlot(attacker, TFWeaponSlot_Grenade));
	else
		weaponIndex = GetWeaponIndex(weapon);
	
	int weaponData[3];

	if(WeaponMap.GetArray(weaponIndex, weaponData, 3))
		if(weaponData[2] ? TF2_IsPlayerInCondition(attacker, view_as<TFCond>(weaponData[0])) : TF2_IsPlayerInCondition(victim, view_as<TFCond>(weaponData[0])))
			switch(weaponData[1])
			{
				case 0:	// crit
				{
					damageType |= DMG_ACID;
					return Plugin_Changed;
				}

				case 1: // minicrit
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
	PrintToServer("[TF2Classic-CritVsCond] Reloading...");
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