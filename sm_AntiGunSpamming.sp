/*  SM AntiGunSpam
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
 
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#pragma semicolon 1

#define VERSION "v1.2"

new g_WeaponParent;

new Handle:g_CvarF = INVALID_HANDLE;
new Handle:guns_max = INVALID_HANDLE;

new bool:Blocked = false;


public Plugin:myinfo = 
{
	name = "SM AntiGunSpam",
	author = "Franc1sco steam: franug",
	description = "prevent gun spamming",
	version = VERSION,
	url = "http://steamcommunity.com/id/franug"
};


public OnPluginStart()
{

	g_CvarF = CreateConVar("sm_AntiGunSpam", VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	guns_max = CreateConVar("sm_antigunspam_max", "40", "Number max of weapons on the ground allowed");

	g_WeaponParent = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");

	SetConVarString(g_CvarF, VERSION);

	HookConVarChange(g_CvarF, VersionChange);

	HookEventEx("round_start", Event_RoundStart, EventHookMode_Post);

//        RegAdminCmd("sm_gunsinmap", Command_Showguns, ADMFLAG_SLAY); // this for admin command

        RegConsoleCmd("sm_gunsinmap", Command_Showguns); // this for public command

}

public OnEntityCreated(entity, const String:classname[])
{
  if (!Blocked)
  {
    if (entity > MaxClients && IsValidEntity(entity))
    {
        new entities;
	new maxent = GetMaxEntities(), String:weapon[64];
	for (new i=GetMaxClients();i<maxent;i++)
	{
		if ( IsValidEdict(i) && IsValidEntity(i) )
		{
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ( ( StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1 )
                        {
					entities++;
                        }
		}
	}
	if (entities > GetConVarInt(guns_max))
        {
                new Handle:pack;
                CreateDataTimer(4.0, Checker, pack);
                WritePackCell(pack, entity);
        }
    }
  }
}

public VersionChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SetConVarString(convar, VERSION);
}

public OnMapStart()
{
    Blocked = true;
    CreateTimer(5.0, UnBlock);
}

public Action:UnBlock(Handle:timer)
{
    Blocked = false;
}

public Action:Checker(Handle:timer, Handle:pack)
{
  if (!Blocked)
  {
   new entity;

   ResetPack(pack);
   entity = ReadPackCell(pack);

   new String:weapon[64];

   if ( IsValidEdict(entity) && IsValidEntity(entity) )
   {
	GetEdictClassname(entity, weapon, sizeof(weapon));
	if ( ( StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) && GetEntDataEnt2(entity, g_WeaponParent) == -1 )
        {
			AcceptEntityInput(entity, "Kill");
        }
   }
  }
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    Blocked = true;
    CreateTimer(5.0, UnBlock);
}

public Action:Command_Showguns(client, args)
{
        new entities;
	new maxent = GetMaxEntities(), String:weapon[64];
	for (new i=GetMaxClients();i<maxent;i++)
	{
		if ( IsValidEdict(i) && IsValidEntity(i) )
		{
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ( ( StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1 )
                        {
					entities++;
                        }
		}
	}
//        PrintToChat(client, "\x04[SM_AntiGunSpam] \x01Numero de armas en el suelo: %i", entities); // in spanish (my own language)
        PrintToChat(client, "\x04[SM_AntiGunSpam] \x01Number of weapons on the ground: %i", entities);
}

// si eres español y quieres aprender a hacer plugins entonces agregame
// mi steam es: franug