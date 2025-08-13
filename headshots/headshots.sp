#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
    name = "HeadshotSound",
    author = "Sixin",
    description = "播放爆头击杀音效",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/id/Si_Xin/"
};

// 音效文件配置
char g_sSpecialHS[][] = {
    "level/timer_bell.wav",
    "level/bell_normal.wav"
};

char g_sCommonHS[][] = {
    "level/timer_bell.wav",
    "level/bell_normal.wav"
};

// 冷却时间（秒）
const float COOLDOWN = 0.01;
float g_fLastSound[MAXPLAYERS + 1];

public void OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("infected_death", Event_InfectedDeath, EventHookMode_Post);
}

public void OnMapStart()
{
    // 预缓存所有音效
    for (int i = 0; i < sizeof(g_sSpecialHS); i++)
    {
        PrecacheSound(g_sSpecialHS[i]);
        AddFileToDownloadsTable(Path_Sound(g_sSpecialHS[i]));
    }
    
    for (int i = 0; i < sizeof(g_sCommonHS); i++)
    {
        PrecacheSound(g_sCommonHS[i]);
        AddFileToDownloadsTable(Path_Sound(g_sCommonHS[i]));
    }
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (!victim || GetClientTeam(victim) != 3) return Plugin_Continue; // 仅限感染者团队
    
    // 检查爆头和攻击者
    if (event.GetBool("headshot"))
    {
        int attacker = GetClientOfUserId(event.GetInt("attacker"));
        PlayHeadshotSound(attacker, true);
    }
    return Plugin_Continue;
}

public Action Event_InfectedDeath(Event event, const char[] name, bool dontBroadcast)
{
    // 检查普通感染者爆头
    if (event.GetBool("headshot"))
    {
        int attacker = GetClientOfUserId(event.GetInt("attacker"));
        PlayHeadshotSound(attacker, false);
    }
    return Plugin_Continue;
}

void PlayHeadshotSound(int client, bool isSpecial)
{
    if (!IsValidClient(client)) return;
    
    // 冷却时间检查
    float fCurrentTime = GetGameTime();
    if (fCurrentTime - g_fLastSound[client] < COOLDOWN) return;
    g_fLastSound[client] = fCurrentTime;
    
    // 随机选择音效
    static char sound[PLATFORM_MAX_PATH];
    if (isSpecial) {
        strcopy(sound, sizeof(sound), g_sSpecialHS[GetRandomInt(0, sizeof(g_sSpecialHS) - 1)]);
    } else {
        strcopy(sound, sizeof(sound), g_sCommonHS[GetRandomInt(0, sizeof(g_sCommonHS) - 1)]);
    }
    
    // 仅对击杀者播放
    EmitSoundToClient(client, sound, _, SNDCHAN_STATIC, SNDLEVEL_NORMAL, _, 0.8);
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MaxClients && 
            IsClientInGame(client) && 
            !IsFakeClient(client) && 
            GetClientTeam(client) == 2); // 仅生还者团队
}

// 获取音效文件的完整路径
char[] Path_Sound(const char[] sound)
{
    char buffer[PLATFORM_MAX_PATH];
    Format(buffer, sizeof(buffer), "sound/%s", sound);
    return buffer;
}