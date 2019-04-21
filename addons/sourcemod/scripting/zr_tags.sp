#include <sourcemod>
#include <cstrike>
#include <scp>
#include <zombiereloaded>

#pragma newdecls required

ConVar g_CVAR_EnableChatTags;
ConVar g_CVAR_EnableClanTags;

int g_EnableChatTags;
int g_EnableClanTags;

bool MotherZombie[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[CS:GO ZR] Tags for Zombie Reloaded",
	description = "Chat and Clan Tags for Zombie Reloaded",
	author = "Hallucinogenic Troll",
	version = "1.0",
	url = "PTFun.net"
};

public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	
	g_CVAR_EnableChatTags = CreateConVar("zr_chattags_enable", "0", "Enables the Chat Tags for Zombies, Mother Zombies and Humans", _, true, 0.0, true, 1.0);
	g_CVAR_EnableClanTags = CreateConVar("zr_clantags_enable", "0", "Enables the Clan Tags for Zombies, Mother Zombies and Humans", _, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "zr_chat_clan_tags");
}

public void OnConfigsExecuted()
{
	g_EnableChatTags = g_CVAR_EnableChatTags.IntValue;
	g_EnableClanTags = g_CVAR_EnableClanTags.IntValue;
	
	if(g_EnableClanTags)
		CreateTimer(0.1, Timer_CheckDelay, _, TIMER_REPEAT);
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsValidClient(client))
		return;
	
	MotherZombie[client] = false;
}

public Action Timer_CheckDelay(Handle timer)
{
	if(g_EnableClanTags)	
		for (int i = 0; i < MaxClients; i++)
			if(IsValidClient(i))
				CheckTag(i);
}

public void CheckTag(int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		char tag[40];
		if(ZR_IsClientHuman(client))
			Format(tag, sizeof(tag), "[Human] ");
		else if(ZR_IsClientZombie(client))
		{
			if(MotherZombie[client])
				Format(tag, sizeof(tag), "[MotherZombie] ")
			else	
				Format(tag, sizeof(tag), "[Zombie] ");
		}
		
		CS_SetClientClanTag(client, tag);
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for(int client = 0; client < MaxClients; client++)
		MotherZombie[client] = false;
}

public int ZR_OnClientInfected(int client, int attacker, bool motherInfect, bool respawnOverride, bool respawn)
{
	if(IsValidClient(client))
	{
		if(motherInfect)
			MotherZombie[client] = true;
		else
			MotherZombie[client] = false;
	}
}

public Action OnChatMessage(int &client, Handle hRecipients, char[] name, char[] message)
{
	if(g_EnableChatTags)
	{
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			char tag[40];
			if(ZR_IsClientHuman(client))
				Format(tag, sizeof(tag), "\x0B[Human]\x01");
			else if(ZR_IsClientZombie(client))
			{
				if(MotherZombie[client])
					Format(tag, sizeof(tag), "\x07[MotherZombie]\x01")
				else	
					Format(tag, sizeof(tag), "\x02[Zombie]\x01");
			}
			else
				return Plugin_Continue;
			
			Format(name, MAXLENGTH_MESSAGE, " %s %s", tag, name);
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
		return true;
	
	return false;
}
