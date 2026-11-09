#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "HLD rebel rush filter",
	author = "Train",
	description = "",
	version = "1.0",
	url = ""
}

StringMap g_CyrillicMap;

bool g_Renaming[MAXPLAYERS + 1];

#define USERNAME_MAX 128
#define MAX_MESSAGE_LENGTH 256

#define NAME_FILTER_NOTHING 0
#define NAME_FILTER_RENAME 1
#define NAME_FILTER_KICK 2

#define GENERIC_NAME_FILE "addons/sourcemod/data/rebel_rush_generic_names.txt"
#define FALLBACK_NAME "beefaroniman123"
#define TRANSLATIONS_FILE "rebelrush.phrases"

ConVar g_cvUnicodeNameBehavior;
ConVar g_cvUnicodeChatFilter;

ArrayList g_GenericNames;

public void OnPluginStart()
{
	HookEvent("player_changename", Event_PlayerChangeName, EventHookMode_Pre);
	AddCommandListener(Command_Say, "say");
    AddCommandListener(Command_Say, "say_team");
	for (int i = 0; i <= MAXPLAYERS; ++i)
		g_Renaming[i] = false;
		
	g_cvUnicodeNameBehavior = CreateConVar("rebel_rush_unicode_name_behavior", "1", "0 - Do nothing, 1 - Rename, 2 - Kick", FCVAR_ARCHIVE);
	g_cvUnicodeChatFilter = CreateConVar("rebel_rush_unicode_chat_filter", "1", "Filter unicode messages from chat", FCVAR_ARCHIVE);
	LoadTranslations(TRANSLATIONS_FILE);
	InitCyrillicMap();
	LoadGenericNames();
}

void InitCyrillicMap()
{
    g_CyrillicMap = new StringMap();

    g_CyrillicMap.SetString("а", "a");
    g_CyrillicMap.SetString("А", "A");
    g_CyrillicMap.SetString("б", "b");
    g_CyrillicMap.SetString("Б", "B");
    g_CyrillicMap.SetString("в", "v");
    g_CyrillicMap.SetString("В", "V");
    g_CyrillicMap.SetString("д", "d");
    g_CyrillicMap.SetString("Д", "D");
    g_CyrillicMap.SetString("ж", "zh");
    g_CyrillicMap.SetString("Ж", "Zh");
    g_CyrillicMap.SetString("з", "z");
    g_CyrillicMap.SetString("З", "Z");
    g_CyrillicMap.SetString("к", "k");
    g_CyrillicMap.SetString("К", "K");
    g_CyrillicMap.SetString("л", "l");
    g_CyrillicMap.SetString("Л", "L");
    g_CyrillicMap.SetString("м", "m");
    g_CyrillicMap.SetString("М", "M");
    g_CyrillicMap.SetString("н", "n");
    g_CyrillicMap.SetString("Н", "N");
    g_CyrillicMap.SetString("о", "o");
    g_CyrillicMap.SetString("О", "O");
    g_CyrillicMap.SetString("п", "p");
    g_CyrillicMap.SetString("П", "P");
    g_CyrillicMap.SetString("р", "r");
    g_CyrillicMap.SetString("Р", "R");
    g_CyrillicMap.SetString("с", "s");
    g_CyrillicMap.SetString("С", "S");
    g_CyrillicMap.SetString("т", "t");
    g_CyrillicMap.SetString("Т", "T");
    g_CyrillicMap.SetString("у", "u");
    g_CyrillicMap.SetString("У", "U");
    g_CyrillicMap.SetString("ф", "f");
    g_CyrillicMap.SetString("Ф", "F");
    g_CyrillicMap.SetString("ц", "c");
    g_CyrillicMap.SetString("Ц", "C");
    g_CyrillicMap.SetString("ч", "ch");
    g_CyrillicMap.SetString("Ч", "Ch");
    g_CyrillicMap.SetString("ш", "sh");
    g_CyrillicMap.SetString("Ш", "Sh");
    g_CyrillicMap.SetString("щ", "sch");
    g_CyrillicMap.SetString("Щ", "Sch");
    g_CyrillicMap.SetString("ь", "'");
    g_CyrillicMap.SetString("Ь", "'");
    g_CyrillicMap.SetString("ю", "ju");
    g_CyrillicMap.SetString("Ю", "Ju");
    g_CyrillicMap.SetString("я", "ja");
    g_CyrillicMap.SetString("Я", "Ja");
    g_CyrillicMap.SetString("ё", "jo");
    g_CyrillicMap.SetString("Ё", "Jo");
    g_CyrillicMap.SetString("и", "i");
    g_CyrillicMap.SetString("И", "I");
    g_CyrillicMap.SetString("й", "j");
    g_CyrillicMap.SetString("Й", "J");
    g_CyrillicMap.SetString("х", "h");
    g_CyrillicMap.SetString("Х", "H");
    g_CyrillicMap.SetString("ъ", "'");
    g_CyrillicMap.SetString("Ъ", "'");
    g_CyrillicMap.SetString("ы", "y");
    g_CyrillicMap.SetString("Ы", "Y");
    g_CyrillicMap.SetString("э", "e");
    g_CyrillicMap.SetString("Э", "E");
    g_CyrillicMap.SetString("е", "e");
    g_CyrillicMap.SetString("Е", "E");
    g_CyrillicMap.SetString("г", "g");
    g_CyrillicMap.SetString("Г", "G");
    g_CyrillicMap.SetString("ґ", "g");
    g_CyrillicMap.SetString("Ґ", "G");
    g_CyrillicMap.SetString("і", "i");
    g_CyrillicMap.SetString("І", "I");
    g_CyrillicMap.SetString("ї", "ji");
    g_CyrillicMap.SetString("Ї", "Ji");
    g_CyrillicMap.SetString("ў", "u");
    g_CyrillicMap.SetString("Ў", "U");
    g_CyrillicMap.SetString("ђ", "dj");
    g_CyrillicMap.SetString("Ђ", "Dj");
    g_CyrillicMap.SetString("ј", "j");
    g_CyrillicMap.SetString("Ј", "J");
    g_CyrillicMap.SetString("љ", "lj");
    g_CyrillicMap.SetString("Љ", "Lj");
    g_CyrillicMap.SetString("њ", "nj");
    g_CyrillicMap.SetString("Њ", "Nj");
    g_CyrillicMap.SetString("ћ", "ch");
    g_CyrillicMap.SetString("Ћ", "Ch");
    g_CyrillicMap.SetString("џ", "dzh");
    g_CyrillicMap.SetString("Џ", "Dzh");
    g_CyrillicMap.SetString("ќ", "kj");
    g_CyrillicMap.SetString("Ќ", "Kj");
    g_CyrillicMap.SetString("ѓ", "gj");
    g_CyrillicMap.SetString("Ѓ", "Gj");
    g_CyrillicMap.SetString("ѕ", "dz");
    g_CyrillicMap.SetString("Ѕ", "Dz");
}

void LoadGenericNames()
{
    if (g_GenericNames != null)
        delete g_GenericNames;

    g_GenericNames = new ArrayList(ByteCountToCells(256));

    File file = OpenFile(GENERIC_NAME_FILE, "r");
    if (file == null)
    {
        LogError("Failed to open %s", GENERIC_NAME_FILE);
        return;
    }

    char line[256];

    while (!file.EndOfFile() && file.ReadLine(line, sizeof(line)))
    {
        TrimString(line);

        if (line[0] == '\0')
            continue;

        g_GenericNames.PushString(line);
    }

    delete file;
}

bool GetGenericName(char[] output, int maxlen)
{
    if (g_GenericNames == null || g_GenericNames.Length == 0)
    {
        strcopy(output, maxlen, FALLBACK_NAME);
        return false;
    }

    int index = GetRandomInt(0, g_GenericNames.Length - 1);
    g_GenericNames.GetString(index, output, maxlen);

    return true;
}

bool StringContainsUnicode(const char[] str)
{
	for (int i = 0; str[i] != 0; ++i)
	{
		if (IsCharMB(str[i]))
			return true;
	}
	
	return false;
}

void ResolveCyrillicName(const char[] username, char[] res, int len)
{
    char temp[5];
    char translated[16];

    res[0] = '\0';

    int pos = 0;

    while (username[pos] != '\0')
    {
        int sz = IsCharMB(username[pos]);
        if (sz == 0)
            sz = 1;

        for (int i = 0; i < sz; i++)
            temp[i] = username[pos + i];

        temp[sz] = '\0';

        if (g_CyrillicMap.GetString(temp, translated, sizeof(translated)))
            StrCat(res, len, translated);
        else
        {
            if (sz != 1)
            {
                // Unsupported character, revert to a generic name
                GetGenericName(res, len);
                return;
            }

            StrCat(res, len, temp);
        }

        pos += sz;
    }
}

void RenamePlayerIfNecessary(int client, const char[] name)
{
	if (g_Renaming[client])
		return;
	
	g_Renaming[client] = true;
	
	char res[USERNAME_MAX];
	
	ResolveCyrillicName(name, res, USERNAME_MAX);
	if (!StrEqual(name, res))
		SetClientName(client, res);
	
	g_Renaming[client] = false;
}

public void OnClientPutInServer(int client)
{
	char username[USERNAME_MAX];
	if (!GetClientName(client, username, USERNAME_MAX))
		return;
		
	int g_filter = g_cvUnicodeNameBehavior.IntValue;
	if (g_filter == NAME_FILTER_RENAME)
		RenamePlayerIfNecessary(client, username);
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
	char username[USERNAME_MAX];
	if (GetClientName(client, username, USERNAME_MAX))
	{
		int g_filter = g_cvUnicodeNameBehavior.IntValue;
		if (StringContainsUnicode(username) && g_filter == NAME_FILTER_KICK)
		{
			FormatEx(rejectmsg, maxlen, "%T", "UnicodeUsernameWarning", client);
			return false;
		}
	}
		
	return true;
}

public Action Event_PlayerChangeName(Event event, const char[] name, bool dontBroadcast)
{
	int g_filter = g_cvUnicodeNameBehavior.IntValue;
	if (g_filter == NAME_FILTER_NOTHING)
		return Plugin_Continue;
		
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client > 0 && IsClientInGame(client) && !g_Renaming[client])
	{
	   char newName[USERNAME_MAX];
	   event.GetString("newname", newName, USERNAME_MAX, "Unknown");
	   if (g_filter == NAME_FILTER_RENAME)
			RenamePlayerIfNecessary(client, newName);
		else //if (g_filter == NAME_FILTER_KICK)
		{
			char msg[256];
			FormatEx(msg, sizeof(msg), "%T", "UnicodeUsernameWarning", client);
			KickClient(client, msg);
		}
	   return Plugin_Handled;
	}

    return Plugin_Continue;
}

public Action Command_Say(int client, const char[] command, int argc)
{
    char text[256];
    GetCmdArgString(text, sizeof(text));
    StripQuotes(text);
	int g_filter = g_cvUnicodeChatFilter.IntValue;

    if (g_filter != 0 && StringContainsUnicode(text))
    {
		char msg[256];
		FormatEx(msg, sizeof(msg), "%T", "UnicodeChatWarning", client);
		PrintToChat(client, msg);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}