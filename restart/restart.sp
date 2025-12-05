#pragma semicolon 1
#include <sourcemod>

public Plugin myinfo = 
{
	name = "Restart",
	author = "SiXin",
	description = "指令重启服务器或重启当前map&服务器无人重启",
	version = "1.0",
	url = "https://steamcommunity.com/id/Si_Xin"
}

public OnPluginStart()
{
	
	RegAdminCmd("sm_restart", Restart, ADMFLAG_ROOT);
	//RegAdminCmd("sm_boom", Restart, ADMFLAG_ROOT);
	RegAdminCmd("sm_restartmap", RestartMap, ADMFLAG_ROOT);
	
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	
}

/*
https://developer.valvesoftware.com/wiki/List_of_Left_4_Dead_2_console_commands_and_variables
crash->cmd->"cheat"->Cause the engine to crash (Debug!!)
*/
//指令重启
public Action Restart(int client, int args) 
{
    SetCommandFlags("crash", GetCommandFlags("crash") & ~FCVAR_CHEAT);
	ServerCommand("crash");
}

//指令重启当前地图
public Action RestartMap(int client,int args)
{
	//PrintToChatAll("地图将在3秒后重启...");
	CreateTimer(3.0, Timer_Restartmap);
	return Plugin_Handled;
}

public Action Timer_Restartmap(Handle timer)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	ServerCommand("changelevel %s", mapname);
	return Plugin_Handled;
}

public Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || (IsClientConnected(client)&&!IsClientInGame(client))) return;
	if(client&&!IsFakeClient(client)&&!PlayerCheck(client))
	{	
		CreateTimer(10.0,NoPlayersRestart);
	}
}

//无人重启
public Action:NoPlayersRestart(Handle:timer,any:client)
{
	if(PlayerCheck(0)) return;
	SetCommandFlags("crash", GetCommandFlags("crash") & ~FCVAR_CHEAT);
	ServerCommand("crash");
}

//玩家检测
bool:PlayerCheck(client)
{
	for (new i = 1; i < MaxClients+1; i++)
		if(IsClientConnected(i)&&!IsFakeClient(i)&&i!=client)
			return true;
	return false;
}