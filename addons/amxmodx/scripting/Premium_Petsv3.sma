/*
 * =====================================================================
 *  Novaria Zombie Escape
 *  GitHub: https://github.com/merhabalarrdev
 * ---------------------------------------------------------------------
 *  [TR] Bu eklenti/paket Turkce olarak gelistirilmis ve topluluga
 *  UCRETSIZ olarak sunulmustur. Kaynak kodu ve derlenmis hali HICBIR
 *  SEKILDE PARAYLA SATILAMAZ, ticari amacla pazarlanamaz ya da kendi
 *  urununuzmus gibi el degistiremezsiniz. Kendi sunucunuzda ozgurce
 *  kullanabilir, inceleyebilir, duzenleyebilir ve gelistirebilirsiniz.
 *  Guncel surumu takip etmek icin lutfen yukaridaki GitHub sayfasini
 *  ziyaret edin. Firsatcilara karsi uyarilmis olun.
 *
 *  [EN] This plugin/package was developed in Turkish and is provided
 *  to the community FREE OF CHARGE. Neither the source code nor the
 *  compiled binary may be SOLD FOR MONEY, marketed commercially, or
 *  passed off as your own product under any circumstances. You are
 *  free to use, review, modify and improve it on your own server.
 *  Please visit the GitHub page above for the latest version. Be
 *  warned against opportunists reselling this content.
 *
 *  [KO] 이 플러그인/패키지는 터키어로 개발되었으며 커뮤니티에게
 *  무료로 제공됩니다. 소스 코드와 컴파일된 파일 모두 어떠한
 *  경우에도 판매하거나 상업적으로 거래하거나 자신의 제품인 것처럼
 *  둔갑시킬 수 없습니다. 자신의 서버에서 자유롭게 사용, 검토, 수정
 *  및 개선하실 수 있습니다. 최신 버전은 위의 GitHub 페이지를
 *  방문해 주세요. 무단 판매자들에게 경고합니다.
 * =====================================================================
 */
#include <amxmodx>
#include <fakemeta>
#include <reapi>
#include <xs>
#include <nvault>
#include <amxmisc>

#define PLUGIN_VERSION "3.0"

#define PRO_PUBLIC 1
#define ZOMBIE_PLAGUE 2
#define JAILBREAK 3
#define BIOHAZARD 4

// ACTIVE_MOD ayarını kendi modunuza göre değiştirin:
// 1: PRO_PUBLIC (CS Para Sistemi)
// 2: ZOMBIE_PLAGUE (Ammo Pack Sistemi) 
// 3: JAILBREAK (Coin Sistemi)
// 4: BIOHAZARD (BioPoint Sistemi)
#define ACTIVE_MOD ZOMBIE_PLAGUE // buraya sadece yukarıdaki modunuz ne ise onu yukardıdaki yazdığı şekilde giriniz yoksa hata alabilirsiniz.

#define MENU_IMMUNITY 1 // 1 = Sadece adminler /pet menüsünü açabilsin, 0 = Herkes açabilsin

#if ACTIVE_MOD == PRO_PUBLIC
    #include <cstrike>
#elseif ACTIVE_MOD == ZOMBIE_PLAGUE
    #include <zombieplague>
#elseif ACTIVE_MOD == BIOHAZARD
    forward bio_get_packs(id);
    forward bio_set_packs(id, value);
    forward nGetUserCoin(id);
    forward nSetUserCoin(id, value);
    
    public bio_get_packs(id) { return 0; }
    public bio_set_packs(id, value) { return 0; }
    public nGetUserCoin(id) { return 0; }
    public nSetUserCoin(id, value) { return 0; }
#elseif ACTIVE_MOD == JAILBREAK
    forward get_user_coin(id);
    forward set_user_coin(id, value);
    
    public get_user_coin(id) { return 0; }
    public set_user_coin(id, value) { return 0; }
#endif

#define var_water_time var_fuser1

#define CHAT_TAG "[nVa]"
#define CHAT_TAG_COLOR "^4"
#define MENU_TAG "\r(Novaria)" 
#define KSATAG "\r(nva)\w->  "
#define MENU_TAG_COLOR "\r"

enum _:eCvars {
    Float: MAX_JUMP_HEIGHT,
    Float: START_FOLLOW_DISTANTION,
    Float: TELEPTORT_DISTANTION,
    Float: MAX_SPEED,
    Float: MAX_RADIUS_SPAWN,
    PET_IS_SPAWN
}

new g_ArrayCvars[eCvars];
new g_Vault;

enum eDataPet {
    PET_NAME[32], 
    PET_MODEL[64],
    PET_FLAG[2],
    PET_IDLE,
    PET_JUMP,
    PET_RUN,
    PET_DEATH,
    PET_MOVE_TYPE,
    PET_PRICE
};

enum {
    SEQ_SPAWN = 0,
    SEQ_IDLE,
    SEQ_FLY_IDLE,
    SEQ_DEATH,
    SEQ_RUN,
    SEQ_FLY_RUN,
    SEQ_FLY_DEATH
};

new Array:g_DataPets;
new g_iTotalPets;

new g_iCounter[MAX_PLAYERS + 1];
new bool:g_bIsSpawn[MAX_PLAYERS];
new g_iEntityId[MAX_PLAYERS + 1];
new bool:g_bRoundEnd;

new Array:g_bPetOwned[MAX_PLAYERS + 1];
new g_iActivePet[MAX_PLAYERS + 1] = {-1, ...};
new g_iCurrentPetIndex[MAX_PLAYERS + 1];

new Array:g_iOwnedPets[MAX_PLAYERS + 1];

public plugin_precache() {
    LoadPetsFromINI();
    CreateCvars();
}

public plugin_init() {
    register_plugin("Premium Pet Sistemi v3.0", PLUGIN_VERSION, "Merhabalarr");

    register_dictionary("PRE_Petsv3.txt");

    g_Vault = nvault_open("PRE_Petsv3");
    if(g_Vault == INVALID_HANDLE)
        set_fail_state("nvault açılamadı.");

    register_clcmd("say /pets", "Show_MainMenu");
    register_clcmd("say /pet", "Show_MainMenu");

    if(g_ArrayCvars[PET_IS_SPAWN] == 1) {
        RegisterHookChain(RG_CBasePlayer_Spawn, "Hook_PlayerSpawn_Post", true);
    }
    
    RegisterHookChain(RG_CSGameRules_RestartRound, "HookRoundStart", false);
    RegisterHookChain(RG_RoundEnd, "Hook_RoundEnd", true);
    
    if(g_ArrayCvars[PET_IS_SPAWN] < 2)
        RegisterHookChain(RG_CBasePlayer_Killed, "Hook_PlayerKilled_Post", true);
}

public plugin_end() {
    nvault_close(g_Vault);
    
    if(g_DataPets != Invalid_Array) {
        ArrayDestroy(g_DataPets);
    }
    
    for(new i = 1; i <= MaxClients; i++) {
        if(g_bPetOwned[i] != Invalid_Array) {
            ArrayDestroy(g_bPetOwned[i]);
        }
        if(g_iOwnedPets[i] != Invalid_Array) {
            ArrayDestroy(g_iOwnedPets[i]);
        }
    }
}

public client_putinserver(id) {
    if(g_ArrayCvars[PET_IS_SPAWN] == 1)
        g_bIsSpawn[id] = false;
        
    if(g_iTotalPets > 0) {
        g_bPetOwned[id] = ArrayCreate(1, g_iTotalPets);
        g_iOwnedPets[id] = ArrayCreate();
        for(new i = 0; i < g_iTotalPets; i++) {
            ArrayPushCell(g_bPetOwned[id], 0);
        }
    }
    
    LoadPlayerData(id);
}

public client_disconnected(id) {
    SavePlayerData(id);
    
    if(g_bPetOwned[id] != Invalid_Array) {
        ArrayDestroy(g_bPetOwned[id]);
        g_bPetOwned[id] = Invalid_Array;
    }
    
    if(g_iOwnedPets[id] != Invalid_Array) {
        ArrayDestroy(g_iOwnedPets[id]);
        g_iOwnedPets[id] = Invalid_Array;
    }
    
    if(g_iEntityId[id] && is_valid_ent(g_iEntityId[id])) {
        RemoveEntity(g_iEntityId[id]);
    }
}

LoadPetsFromINI() {
    new szConfigsDir[64], szFile[128];
    get_configsdir(szConfigsDir, charsmax(szConfigsDir));
    formatex(szFile, charsmax(szFile), "%s/PRE_Pets.ini", szConfigsDir);
    
    if(!file_exists(szFile)) {
        CreateDefaultPetsINI(szFile);
        return;
    }
    
    g_DataPets = ArrayCreate(eDataPet);
    g_iTotalPets = 0;
    
    new iFile = fopen(szFile, "rt");
    if(!iFile) {
        set_fail_state("PRE_Pets.ini dosyası açılamadı");
        return;
    }
    
    new szLine[256], szTemp[eDataPet];
    
    fgets(iFile, szLine, charsmax(szLine));
    
    while(!feof(iFile)) {
        fgets(iFile, szLine, charsmax(szLine));
        trim(szLine);
        
        if(!szLine[0] || szLine[0] == ';' || szLine[0] == '#' || szLine[0] == '/')
            continue;
        
        while(replace(szLine, charsmax(szLine), "  ", " ")) {}
        trim(szLine);
        
        new szFields[9][64];
        parse(szLine, 
            szFields[0], charsmax(szFields[]),
            szFields[1], charsmax(szFields[]),
            szFields[2], charsmax(szFields[]),
            szFields[3], charsmax(szFields[]),
            szFields[4], charsmax(szFields[]),
            szFields[5], charsmax(szFields[]),
            szFields[6], charsmax(szFields[]),
            szFields[7], charsmax(szFields[]),
            szFields[8], charsmax(szFields[]));
        
        trim(szFields[0]); trim(szFields[1]); trim(szFields[2]);
        trim(szFields[3]); trim(szFields[4]); trim(szFields[5]); 
        trim(szFields[6]); trim(szFields[7]); trim(szFields[8]);
        
        copy(szTemp[PET_NAME], 31, szFields[0]);
        copy(szTemp[PET_MODEL], 63, szFields[1]);
        copy(szTemp[PET_FLAG], 1, szFields[2]);
        
        szTemp[PET_IDLE] = str_to_num(szFields[3]);
        szTemp[PET_JUMP] = str_to_num(szFields[4]);
        szTemp[PET_RUN] = str_to_num(szFields[5]);
        szTemp[PET_DEATH] = str_to_num(szFields[6]);
        szTemp[PET_MOVE_TYPE] = str_to_num(szFields[7]);
        szTemp[PET_PRICE] = str_to_num(szFields[8]);
        
        if(equal(szFields[2], "all")) {
            szTemp[PET_FLAG][0] = 0;
        }
        
        if(szTemp[PET_MOVE_TYPE] != 1 && szTemp[PET_MOVE_TYPE] != 2) {
            szTemp[PET_MOVE_TYPE] = 1;
        }
        
        if(file_exists(szTemp[PET_MODEL])) {
            precache_model(szTemp[PET_MODEL]);
            ArrayPushArray(g_DataPets, szTemp);
            g_iTotalPets++;
        }
    }
    
    fclose(iFile);
    
    if(g_iTotalPets == 0) {
        set_fail_state("PRE_Pets.ini dosyasından hiç Evcil Hayvan yüklenemedi lütfen Evcil Hayvan yükleyiniz.");
    }
}

CreateDefaultPetsINI(szFile[]) {
    new iFile = fopen(szFile, "wt");
    if(!iFile) {
        return;
    }
    
    fputs(iFile, "^"Pet Name^" ^"Pet File Path^" ^"Flag^" ^"Idle^" ^"Jump^" ^"Run^" ^"Death^" ^"MoveType^" ^"Price^" ^"#Author: Merhabalarr^"^n");
    
    fclose(iFile);
} 

stock GetUserCurrency(id) {
    #if ACTIVE_MOD == PRO_PUBLIC
        return cs_get_user_money(id);
    #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
        return zp_get_user_ammo_packs(id);
    #elseif ACTIVE_MOD == BIOHAZARD
        return bio_get_packs(id);
    #elseif ACTIVE_MOD == JAILBREAK
        return get_user_coin(id);
    #endif
}

stock SetUserCurrency(id, amount) {
    #if ACTIVE_MOD == PRO_PUBLIC
        cs_set_user_money(id, amount);
    #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
        zp_set_user_ammo_packs(id, amount);
    #elseif ACTIVE_MOD == BIOHAZARD
        bio_set_packs(id, amount);
    #elseif ACTIVE_MOD == JAILBREAK
        set_user_coin(id, amount);
    #endif
}

stock GetPetPrice(index) {
    static data[eDataPet];
    if(g_DataPets != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        ArrayGetArray(g_DataPets, index, data);
        return data[PET_PRICE];
    }
    return 0;
}

stock GetPetName(index, output[], len) {
    static data[eDataPet];
    if(g_DataPets != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        ArrayGetArray(g_DataPets, index, data);
        copy(output, len, data[PET_NAME]);
    } else {
        output[0] = '^0';
    }
}

stock GetPetModel(index, output[], len) {
    static data[eDataPet];
    if(g_DataPets != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        ArrayGetArray(g_DataPets, index, data);
        copy(output, len, data[PET_MODEL]);
    } else {
        output[0] = '^0';
    }
}

stock GetPetFlag(index, output[], len) {
    static data[eDataPet];
    if(g_DataPets != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        ArrayGetArray(g_DataPets, index, data);
        copy(output, len, data[PET_FLAG]);
    } else {
        output[0] = '^0';
    }
}

stock GetPetMoveType(index) {
    static data[eDataPet];
    if(g_DataPets != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        ArrayGetArray(g_DataPets, index, data);
        return data[PET_MOVE_TYPE];
    }
    return 1;
}

stock GetPetOwned(id, index) {
    if(g_bPetOwned[id] != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        return ArrayGetCell(g_bPetOwned[id], index);
    }
    return 0;
}

stock SetPetOwned(id, index, value) {
    if(g_bPetOwned[id] != Invalid_Array && index >= 0 && index < g_iTotalPets) {
        ArraySetCell(g_bPetOwned[id], index, value);
        UpdateOwnedPetsList(id, index);
    }
}

stock UpdateOwnedPetsList(id, newPetIndex = -1) {
    if(g_iOwnedPets[id] != Invalid_Array) {
        if(newPetIndex != -1 && GetPetOwned(id, newPetIndex)) {
            new iSize = ArraySize(g_iOwnedPets[id]);
            new bool:bAlreadyExists = false;
            
            for(new i = 0; i < iSize; i++) {
                if(ArrayGetCell(g_iOwnedPets[id], i) == newPetIndex) {
                    bAlreadyExists = true;
                    break;
                }
            }
            
            if(!bAlreadyExists) {
                ArrayPushCell(g_iOwnedPets[id], newPetIndex);
            }
        } else {
            ArrayClear(g_iOwnedPets[id]);
            
            for(new i = 0; i < g_iTotalPets; i++) {
                if(GetPetOwned(id, i)) {
                    ArrayPushCell(g_iOwnedPets[id], i);
                }
            }
        }
    }
}

stock GetOwnedPetsCount(id) {
    if(g_iOwnedPets[id] != Invalid_Array) {
        return ArraySize(g_iOwnedPets[id]);
    }
    return 0;
}

stock GetOwnedPetIndex(id, list_index) {
    if(g_iOwnedPets[id] != Invalid_Array && list_index >= 0 && list_index < GetOwnedPetsCount(id)) {
        return ArrayGetCell(g_iOwnedPets[id], list_index);
    }
    return -1;
}

stock PetPrint(id, const szMessage[], any:...) {
    new szFormattedMessage[192];
    vformat(szFormattedMessage, charsmax(szFormattedMessage), szMessage, 3);
    
    client_print_color(id, print_team_default, "%s%s %s", CHAT_TAG_COLOR, CHAT_TAG, szFormattedMessage);
}

stock AdminPetPrint(id, const szMessage[], any:...) {
    new szFormattedMessage[192];
    vformat(szFormattedMessage, charsmax(szFormattedMessage), szMessage, 3);
    
    client_print_color(id, print_team_default, "%s%s %s", CHAT_TAG_COLOR, CHAT_TAG, szFormattedMessage);
}

// ---- Multi-language (EN/TR/KO) helpers - dictionary: PRE_Petsv3.txt ----

// Chat message translated via the player's own language, with format args (like PetPrint but by lang key)
stock PetPrintL(id, const key[], any:...) {
    new szLang[192], szMsg[192];
    LookupLangKey(szLang, charsmax(szLang), key, id);
    if(numargs() > 2) {
        vformat(szMsg, charsmax(szMsg), szLang, 3);
    } else {
        copy(szMsg, charsmax(szMsg), szLang);
    }
    client_print_color(id, print_team_default, "%s%s %s", CHAT_TAG_COLOR, CHAT_TAG, szMsg);
}

stock AdminPetPrintL(id, const key[], any:...) {
    new szLang[192], szMsg[192];
    LookupLangKey(szLang, charsmax(szLang), key, id);
    if(numargs() > 2) {
        vformat(szMsg, charsmax(szMsg), szLang, 3);
    } else {
        copy(szMsg, charsmax(szMsg), szLang);
    }
    client_print_color(id, print_team_default, "%s%s %s", CHAT_TAG_COLOR, CHAT_TAG, szMsg);
}

// Broadcasts a translated message to every connected player, in each player's own language
stock BroadcastL(const key[], any:...) {
    new szLang[192], szMsg[192];
    for(new i = 1; i <= MaxClients; i++) {
        if(is_user_connected(i)) {
            LookupLangKey(szLang, charsmax(szLang), key, i);
            if(numargs() > 1) {
                vformat(szMsg, charsmax(szMsg), szLang, 2);
            } else {
                copy(szMsg, charsmax(szMsg), szLang);
            }
            client_print_color(i, print_team_default, "%s%s %s", CHAT_TAG_COLOR, CHAT_TAG, szMsg);
        }
    }
}

// Builds a menu title as: "\y<MENU_TAG> \w-> " + translated key (optionally with format args)
stock FormatMenuTitleL(id, szOut[], len, const key[], any:...) {
    new szLang[160], szTrans[160];
    LookupLangKey(szLang, charsmax(szLang), key, id);
    if(numargs() > 4) {
        vformat(szTrans, charsmax(szTrans), szLang, 5);
    } else {
        copy(szTrans, charsmax(szTrans), szLang);
    }
    formatex(szOut, len, "\y%s \w-> %s", MENU_TAG, szTrans);
}

// Generic: resolves a dictionary key (with optional format args) into szOut, for menu items/labels
stock FormatL(id, szOut[], len, const key[], any:...) {
    new szLang[192];
    LookupLangKey(szLang, charsmax(szLang), key, id);
    if(numargs() > 4) {
        vformat(szOut, len, szLang, 5);
    } else {
        copy(szOut, len, szLang);
    }
}

// Sets the localized Back/Next/Exit (or Home) menu footer in one call
stock SetMenuNavL(id, menu, const exitKey[] = "MENU_EXIT") {
    new szBack[32], szNext[32], szExit[32];
    FormatL(id, szBack, charsmax(szBack), "MENU_BACK");
    FormatL(id, szNext, charsmax(szNext), "MENU_NEXT");
    FormatL(id, szExit, charsmax(szExit), exitKey);
    menu_setprop(menu, MPROP_BACKNAME, fmt("\w%s", szBack));
    menu_setprop(menu, MPROP_NEXTNAME, fmt("\w%s", szNext));
    menu_setprop(menu, MPROP_EXITNAME, fmt("\w%s", szExit));
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
}

public Hook_PlayerSpawn_Post(id) {
    if(!is_user_connected(id) || !is_user_alive(id) || g_bRoundEnd)
        return;

    if(g_iActivePet[id] != -1) {        
        if(is_valid_ent(g_iEntityId[id])) {
            RemoveEntity(g_iEntityId[id]);
        }
        g_iCounter[id] = g_iActivePet[id];
        CreatePet(id);
    }
    
    if(g_ArrayCvars[PET_IS_SPAWN] == 1)
        g_bIsSpawn[id] = true;
}

public HookRoundStart() {
    g_bRoundEnd = false;
    
    for(new i = 1; i <= MaxClients; i++) {
        if(is_user_connected(i) && is_user_alive(i) && g_iActivePet[i] != -1) {            
            if(is_valid_ent(g_iEntityId[i])) {
                RemoveEntity(g_iEntityId[i]);
            }
            g_iCounter[i] = g_iActivePet[i];
            CreatePet(i);
        }
    }
}

public Hook_RoundEnd(WinStatus: status, ScenarioEventEndRound: event, Float: tmDelay) {
    g_bRoundEnd = true;
}

public Hook_PlayerKilled_Post(id) {
    if(!is_user_connected(id) || g_ArrayCvars[PET_IS_SPAWN] == 2)
        return;
}
public Show_MainMenu(id) {
    if(!is_user_connected(id))
        return PLUGIN_HANDLED;

#if MENU_IMMUNITY == 1
    if(!(get_user_flags(id) & ADMIN_RCON)) {
        PetPrintL(id, "NO_ACCESS");
        return PLUGIN_HANDLED;
    }
#endif

    new szMenuTitle[128], szItem[96], szBack[32], szNext[32], szExit[32];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "MAIN_MENU_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "MainMenu_Handler");
    
    FormatL(id, szItem, charsmax(szItem), "MENU_ITEM_BUY_PET");
    menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
    FormatL(id, szItem, charsmax(szItem), "MENU_ITEM_MY_PETS");
    menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
    
    FormatL(id, szItem, charsmax(szItem), "MENU_ITEM_ADMIN_PANEL");
    if(get_user_flags(id) & ADMIN_RCON) {
        menu_addblank(iMenu, 0);
        menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
    } else {
        menu_addblank(iMenu, 0);
        menu_additem(iMenu, fmt("%s\d%s", KSATAG, szItem));
    }
    
    FormatL(id, szBack, charsmax(szBack), "MENU_BACK");
    FormatL(id, szNext, charsmax(szNext), "MENU_NEXT");
    FormatL(id, szExit, charsmax(szExit), "MENU_EXIT");
    menu_setprop(iMenu, MPROP_BACKNAME, fmt("\w%s", szBack));
    menu_setprop(iMenu, MPROP_NEXTNAME, fmt("\w%s", szNext));
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("\w%s", szExit)); 
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
    
    menu_display(id, iMenu, 0);
    
    return PLUGIN_HANDLED;
}

public MainMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    switch(item) {
        case 0: Show_BuyMenu(id);
        case 1: Show_MyPetsMenu(id);
        case 2: {
            if(get_user_flags(id) & ADMIN_RCON) {
                Show_AdminPanel(id);
            } else {
                Show_MainMenu(id);
            }
        }
    }
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Show_AdminPanel(id) {
    if(!(get_user_flags(id) & ADMIN_RCON)) {
        PetPrintL(id, "NO_ACCESS");
        return;
    }

    new szMenuTitle[128], szItem[96];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "MENU_ITEM_ADMIN_PANEL");
    
    new iMenu = menu_create(szMenuTitle, "AdminPanel_Handler");
    
    FormatL(id, szItem, charsmax(szItem), "ADMIN_ITEM_GIVE_PET");
    menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
    FormatL(id, szItem, charsmax(szItem), "ADMIN_ITEM_TAKE_PET");
    menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
    FormatL(id, szItem, charsmax(szItem), "ADMIN_ITEM_RESET_DATA");
    menu_additem(iMenu, fmt("%s\r%s", KSATAG, szItem));
    
    SetMenuNavL(id, iMenu);
    
    menu_display(id, iMenu, 0);
}

public AdminPanel_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    switch(item) {
        case 0: Show_AdminGivePetMenu(id);
        case 1: Show_AdminTakePetMenu(id);
        case 2: Show_AdminResetMenu(id);
    }
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public Show_AdminGivePetMenu(id) {
    if(!(get_user_flags(id) & ADMIN_RCON)) {
        PetPrintL(id, "NO_ACCESS");
        return;
    }
    
    new szMenuTitle[128];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "GIVE_PET_MENU_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "AdminGivePetMenu_Handler");
    
    new players[32], num, i;
    get_players(players, num, "ch");
    
    if(num == 0) {
        new szNone[64];
        FormatL(id, szNone, charsmax(szNone), "NO_PLAYERS_ON_SERVER");
        menu_additem(iMenu, fmt("\d%s", szNone));
    } else {
        for(i = 0; i < num; i++) {
            new player = players[i];
            new szName[32], szInfo[8];
            get_user_name(player, szName, charsmax(szName));
            
            formatex(szInfo, charsmax(szInfo), "g%d", player);
            menu_additem(iMenu, szName, szInfo);
        }
    }
    
    SetMenuNavL(id, iMenu, "MENU_HOME");
    
    menu_display(id, iMenu, 0);
}

public AdminGivePetMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        Show_AdminPanel(id);
        return PLUGIN_HANDLED;
    }
    
    new szInfo[8], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);
    
    if(szInfo[0] == 'g') {
        new target = str_to_num(szInfo[1]);
        if(is_user_connected(target)) {
            g_iCurrentPetIndex[id] = target;
            Show_AdminSelectPetMenu(id, target, true);
        } else {
            PetPrintL(id, "PLAYER_DISCONNECTED");
            Show_AdminGivePetMenu(id);
        }
    }
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Show_AdminTakePetMenu(id) {
    if(!(get_user_flags(id) & ADMIN_RCON)) {
        PetPrintL(id, "NO_ACCESS");
        return;
    }
    
    new szMenuTitle[128];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "TAKE_PET_MENU_TITLE");

    new iMenu = menu_create(szMenuTitle, "AdminTakePetMenu_Handler");

    new players[32], num, i;
    get_players(players, num, "ch");

    if(num == 0) {
        new szNone[64];
        FormatL(id, szNone, charsmax(szNone), "NO_PLAYERS_ON_SERVER");
        menu_additem(iMenu, fmt("\d%s", szNone), "0");
    } else {
        for(i = 0; i < num; i++) {
            new player = players[i];
            new szName[32], szInfo[8];
            get_user_name(player, szName, charsmax(szName));

            num_to_str(player, szInfo, charsmax(szInfo));
            menu_additem(iMenu, szName, szInfo);
        }
    }

    SetMenuNavL(id, iMenu, "MENU_HOME");

    menu_display(id, iMenu, 0);
}

public AdminTakePetMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        Show_AdminPanel(id);
        return PLUGIN_HANDLED;
    }

    new szInfo[8], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);

    new target = str_to_num(szInfo);

    if(is_user_connected(target)) {
        g_iCurrentPetIndex[id] = target;
        Show_AdminSelectPetMenu(id, target, false);
    } else {
        PetPrintL(id, "PLAYER_DISCONNECTED");
        Show_AdminTakePetMenu(id);
    }

    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Show_AdminSelectPetMenu(id, target, bool:giveMode)
{
    if (g_iTotalPets == 0)
        return;

    new szTargetName[32];
    get_user_name(target, szTargetName, charsmax(szTargetName));

    new szMenuTitle[128];

    if (giveMode)
        FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "ADMIN_SELECT_GIVE_TITLE", szTargetName);
    else
        FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "ADMIN_SELECT_TAKE_TITLE", szTargetName);

    new iMenu = menu_create(szMenuTitle, "AdminSelectPetMenu_Handler");

    new szOwned[32], szNotOwned[32];
    FormatL(id, szOwned, charsmax(szOwned), "OWNED");
    FormatL(id, szNotOwned, charsmax(szNotOwned), "NOT_OWNED");

    for (new i = 0; i < g_iTotalPets; i++)
    {
        new szItem[128], szInfo[32], szName[32];

        GetPetName(i, szName, charsmax(szName));
        new iPrice = GetPetPrice(i);
        new owned = GetPetOwned(target, i);

        if (giveMode)
        {
            if (!owned)
            {
                formatex(szInfo, charsmax(szInfo), "give_%d", i);
                formatex(szItem, charsmax(szItem), "%s \r[%d] \d(%s)", szName, iPrice, szNotOwned);
                menu_additem(iMenu, szItem, szInfo);
            }
            else
            {
                formatex(szItem, charsmax(szItem), "%s \r[%d] \y(%s)", szName, iPrice, szOwned);
                menu_additem(iMenu, szItem, "");
            }
        }
        else
        {
            if (owned)
            {
                formatex(szInfo, charsmax(szInfo), "take_%d", i);
                formatex(szItem, charsmax(szItem), "%s \r[%d] \y(%s)", szName, iPrice, szOwned);
                menu_additem(iMenu, szItem, szInfo);
            }
            else
            {
                formatex(szItem, charsmax(szItem), "%s \r[%d] \d(%s)", szName, iPrice, szNotOwned);
                menu_additem(iMenu, szItem, "");
            }
        }
    }

    SetMenuNavL(id, iMenu, "MENU_HOME");

    menu_display(id, iMenu, 0);
}

public AdminSelectPetMenu_Handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        Show_AdminPanel(id);
        return PLUGIN_HANDLED;
    }

    new szInfo[16], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);

    new target = g_iCurrentPetIndex[id];

    menu_destroy(menu);

    if (contain(szInfo, "give_") != -1)
    {
        new iPet = str_to_num(szInfo[5]);
        SetPetOwned(target, iPet, 1);
        SavePlayerData(target);

        new szPetName[32], szTargetName[32], szAdminName[32];
        GetPetName(iPet, szPetName, charsmax(szPetName));
        get_user_name(target, szTargetName, charsmax(szTargetName));
        get_user_name(id, szAdminName, charsmax(szAdminName));

        AdminPetPrintL(id, "ADMIN_GAVE_PET_TO", szPetName, szTargetName);
        AdminPetPrintL(target, "ADMIN_GAVE_PET_NOTICE", szAdminName, szPetName);

        Show_AdminSelectPetMenu(id, target, true);
    }
    else if (contain(szInfo, "take_") != -1)
    {
        new iPet = str_to_num(szInfo[5]);
        SetPetOwned(target, iPet, 0);

        if (g_iActivePet[target] == iPet)
        {
            g_iActivePet[target] = -1;
            if (is_valid_ent(g_iEntityId[target]))
            {
                RemoveEntity(g_iEntityId[target]);
            }
        }

        SavePlayerData(target);

        new szPetName[32], szTargetName[32], szAdminName[32];
        GetPetName(iPet, szPetName, charsmax(szPetName));
        get_user_name(target, szTargetName, charsmax(szTargetName));
        get_user_name(id, szAdminName, charsmax(szAdminName));

        AdminPetPrintL(id, "ADMIN_TOOK_PET_FROM", szPetName, szTargetName);
        AdminPetPrintL(target, "ADMIN_TOOK_PET_NOTICE", szAdminName, szPetName);

        Show_AdminSelectPetMenu(id, target, false);
    }

    return PLUGIN_HANDLED;
}

public Show_AdminResetMenu(id) {
    if(!(get_user_flags(id) & ADMIN_RCON)) {
        PetPrintL(id, "NO_ACCESS");
        return;
    }
    
    new szMenuTitle[128], szItem[96];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "RESET_MENU_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "AdminResetMenu_Handler");
    
    FormatL(id, szItem, charsmax(szItem), "RESET_ITEM_SINGLE");
    menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
    FormatL(id, szItem, charsmax(szItem), "RESET_ITEM_ALL");
    menu_additem(iMenu, fmt("%s\r%s", KSATAG, szItem));
    
    SetMenuNavL(id, iMenu, "MENU_HOME");
    
    menu_display(id, iMenu, 0);
}

public AdminResetMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        Show_AdminPanel(id);
        return PLUGIN_HANDLED;
    }
    
    switch(item) {
        case 0: Show_AdminResetPlayerMenu(id);
        case 1: {
            new szMenuTitle[128], szItem[96];
            FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "RESET_ALL_TITLE");
            
            new iMenu = menu_create(szMenuTitle, "AdminResetAllConfirm_Handler");
            
            FormatL(id, szItem, charsmax(szItem), "RESET_ALL_CONFIRM_YES");
            menu_additem(iMenu, fmt("%s\r%s", KSATAG, szItem));
            FormatL(id, szItem, charsmax(szItem), "RESET_ALL_CONFIRM_NO");
            menu_additem(iMenu, fmt("%s\w%s", KSATAG, szItem));
            
            SetMenuNavL(id, iMenu, "MENU_HOME");
            
            menu_display(id, iMenu, 0);
        }
    }
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public AdminResetAllConfirm_Handler(id, menu, item) {
    menu_destroy(menu);
    
    if(item == 0) {
        nvault_prune(g_Vault, 0, get_systime());
        
        for(new i = 1; i <= MaxClients; i++) {
            if(is_user_connected(i)) {
                for(new j = 0; j < g_iTotalPets; j++) {
                    SetPetOwned(i, j, 0);
                }
                g_iActivePet[i] = -1;
                
                if(is_valid_ent(g_iEntityId[i])) {
                    RemoveEntity(g_iEntityId[i]);
                }
            }
        }
        
        new szAdminName[32];
        get_user_name(id, szAdminName, charsmax(szAdminName));
        
        AdminPetPrintL(id, "RESET_ALL_DONE");
        BroadcastL("RESET_ALL_BROADCAST", szAdminName);
    }
    
    Show_AdminResetMenu(id);
    return PLUGIN_HANDLED;
}

public Show_AdminResetPlayerMenu(id) {
    if(!(get_user_flags(id) & ADMIN_RCON)) {
        PetPrintL(id, "NO_ACCESS");
        return;
    }
    
    new szMenuTitle[128];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "RESET_PLAYER_MENU_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "AdminResetPlayerMenu_Handler");
    
    new players[32], num, i;
    get_players(players, num, "ch");
    
    if(num == 0) {
        new szNone[64];
        FormatL(id, szNone, charsmax(szNone), "NO_PLAYERS_PERIOD");
        menu_additem(iMenu, fmt("\d%s", szNone));
    } else {
        for(i = 0; i < num; i++) {
            new player = players[i];
            new szName[32], szInfo[8];
            get_user_name(player, szName, charsmax(szName));
            
            num_to_str(player, szInfo, charsmax(szInfo));
            menu_additem(iMenu, szName, szInfo);
        }
    }
    
    SetMenuNavL(id, iMenu, "MENU_HOME");
    
    menu_display(id, iMenu, 0);
}

public AdminResetPlayerMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        Show_AdminResetMenu(id);
        return PLUGIN_HANDLED;
    }
    
    new szInfo[8], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);
    
    new target = str_to_num(szInfo);
    if(is_user_connected(target)) {
        for(new i = 0; i < g_iTotalPets; i++) {
            SetPetOwned(target, i, 0);
        }
        g_iActivePet[target] = -1;
        
        if(is_valid_ent(g_iEntityId[target])) {
            RemoveEntity(g_iEntityId[target]);
        }
        
        SavePlayerData(target);
        
        new szTargetName[32], szAdminName[32];
        get_user_name(target, szTargetName, charsmax(szTargetName));
        get_user_name(id, szAdminName, charsmax(szAdminName));
        
        AdminPetPrintL(id, "RESET_PLAYER_DONE_ADMIN", szTargetName);
        AdminPetPrintL(target, "RESET_PLAYER_DONE_TARGET", szAdminName);
    } else {
        PetPrintL(id, "PLAYER_DISCONNECTED");
    }
    
    Show_AdminResetPlayerMenu(id);
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Show_BuyMenu(id) {
    if(g_iTotalPets == 0) {
        PetPrintL(id, "NO_PETS_IN_SYSTEM");
        return;
    }
    
    new szMenuTitle[128];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "BUY_MENU_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "BuyMenu_Handler");
    
    new szOwned[32];
    FormatL(id, szOwned, charsmax(szOwned), "OWNED");
    
    for(new i = 0; i < g_iTotalPets; i++) {
        new szItem[128], szInfo[8];
        new szName[32], szFlag[2];
        
        GetPetName(i, szName, charsmax(szName));
        GetPetFlag(i, szFlag, charsmax(szFlag));
        
        if(GetPetOwned(id, i)) {
            formatex(szItem, charsmax(szItem), "%s\d%s \r[\r%s\r]", KSATAG, szName, szOwned);
            menu_additem(iMenu, szItem);
        } else {
            new iPrice = GetPetPrice(i);
            
            #if ACTIVE_MOD == PRO_PUBLIC
                formatex(szItem, charsmax(szItem), "%s\w%s \r[\y%d$\r]", KSATAG, szName, iPrice);
            #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
                formatex(szItem, charsmax(szItem), "%s\w%s \r[\y%d Ammo\r]", KSATAG, szName, iPrice);
            #elseif ACTIVE_MOD == BIOHAZARD
                formatex(szItem, charsmax(szItem), "%s\w%s \r[\y%d BioPoint\r]", KSATAG, szName, iPrice);
            #elseif ACTIVE_MOD == JAILBREAK
                formatex(szItem, charsmax(szItem), "%s\w%s \r[\y%d Coin\r]", KSATAG, szName, iPrice);
            #endif
            
            if(strlen(szFlag) > 0 && szFlag[0] != '^0') {
                new szFlagLabel[64], szTemp[64];
                FormatL(id, szFlagLabel, charsmax(szFlagLabel), "FLAG_ACCESS_SUFFIX", szFlag);
                formatex(szTemp, charsmax(szTemp), " \r%s", szFlagLabel);
                add(szItem, charsmax(szItem), szTemp);
            }
            
            num_to_str(i, szInfo, charsmax(szInfo));
            menu_additem(iMenu, szItem, szInfo);
        }
    }
    
    SetMenuNavL(id, iMenu);
    
    menu_display(id, iMenu, 0);
}

public BuyMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        Show_MainMenu(id);
        return PLUGIN_HANDLED;
    }
    
    new szInfo[8], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);
    
    if(strlen(szInfo) == 0) {
        menu_destroy(menu);
        Show_BuyMenu(id);
        return PLUGIN_HANDLED;
    }
    
    new iPet = str_to_num(szInfo);
    
    Show_PetInfoMenu(id, iPet, true);
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}

public Show_MyPetsMenu(id) {
    new iOwnedCount = GetOwnedPetsCount(id);
    
    if(iOwnedCount == 0) {
        PetPrintL(id, "NO_PETS_YET");
        Show_MainMenu(id);
        return;
    }
    
    new szMenuTitle[128];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "MY_PETS_MENU_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "MyPetsMenu_Handler");
    
    new szActive[32], szInactive[32], szView[32];
    FormatL(id, szActive, charsmax(szActive), "ACTIVE_LABEL");
    FormatL(id, szInactive, charsmax(szInactive), "INACTIVE_LABEL");
    FormatL(id, szView, charsmax(szView), "VIEW_LABEL");
    
    for(new i = 0; i < iOwnedCount; i++) {
        new szItem[64], szInfo[8];
        new szName[32];
        
        new iPetIndex = GetOwnedPetIndex(id, i);
        GetPetName(iPetIndex, szName, charsmax(szName));
        
        if(g_iActivePet[id] == iPetIndex) {
            formatex(szItem, charsmax(szItem), "%s\w\y%s \r[\r%s\r] \y%s", KSATAG, szName, szActive, szView);
        } else {
            formatex(szItem, charsmax(szItem), "%s\w\y%s \r[\w%s\r] \y%s", KSATAG, szName, szInactive, szView);
        }
        
        num_to_str(iPetIndex, szInfo, charsmax(szInfo));
        menu_additem(iMenu, szItem, szInfo);
    }
    
    SetMenuNavL(id, iMenu, "MENU_HOME");

    menu_display(id, iMenu, 0);
}

   public MyPetsMenu_Handler(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        Show_MainMenu(id);
        return PLUGIN_HANDLED;
    }

    new szInfo[8], szName[64], access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);

    new iPet = str_to_num(szInfo);

    menu_destroy(menu);


    Show_PetOperationsMenu(id, iPet);

    return PLUGIN_HANDLED;
}


public Show_PetOperationsMenu(id, iPet) {
    g_iCurrentPetIndex[id] = iPet;
    
    new szMenuTitle[128];
    new szPetName[32];
    GetPetName(iPet, szPetName, charsmax(szPetName));
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "PET_OPS_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "PetOperationsMenu_Handler");
    
    new szItem[128], szLabel[64];
    
    FormatL(id, szLabel, charsmax(szLabel), "PET_NAME_LABEL", szPetName);
    formatex(szItem, charsmax(szItem), "\y%s", szLabel);
    menu_additem(iMenu, szItem, "", 0);
    
    if(g_iActivePet[id] == iPet) {
        FormatL(id, szItem, charsmax(szItem), "STATUS_LABEL_ACTIVE");
    } else {
        FormatL(id, szItem, charsmax(szItem), "STATUS_LABEL_INACTIVE");
    }
    menu_additem(iMenu, szItem, "", 0);

    menu_addblank(iMenu, 0);

    if(g_iActivePet[id] == iPet) {
        FormatL(id, szLabel, charsmax(szLabel), "DEACTIVATE_PET");
        formatex(szItem, charsmax(szItem), "\r%s", szLabel);
    } else {
        FormatL(id, szLabel, charsmax(szLabel), "ACTIVATE_PET");
        formatex(szItem, charsmax(szItem), "\y%s", szLabel);
    }
    menu_additem(iMenu, szItem, "3", 0);

    FormatL(id, szLabel, charsmax(szLabel), "SELL_PET");
    formatex(szItem, charsmax(szItem), "\r%s", szLabel);
    menu_additem(iMenu, szItem, "4", 0);

    menu_addblank(iMenu, 0);

    FormatL(id, szLabel, charsmax(szLabel), "CHOOSE_ANOTHER_PET");
    formatex(szItem, charsmax(szItem), "\y%s", szLabel);
    menu_additem(iMenu, szItem, "5", 0);

    SetMenuNavL(id, iMenu, "MENU_HOME");
    
    menu_display(id, iMenu, 0);
}

public PetOperationsMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        Show_MainMenu(id);
        return PLUGIN_HANDLED;
    }
    
    new szInfo[3], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);
    
    new iPet = g_iCurrentPetIndex[id];
    
    switch(str_to_num(szInfo)) {
        case 3: {
            if(g_iActivePet[id] == iPet) {
                if(is_valid_ent(g_iEntityId[id])) {
                    RemoveEntity(g_iEntityId[id]);
                }
                g_iActivePet[id] = -1;
                
                new szPetName[32];
                GetPetName(iPet, szPetName, charsmax(szPetName));
                PetPrintL(id, "PET_DEACTIVATED", szPetName);
            } else {
                if(g_iActivePet[id] != -1) {
                    if(is_valid_ent(g_iEntityId[id])) {
                        RemoveEntity(g_iEntityId[id]);
                    }
                    g_iActivePet[id] = -1;
                }
                
                g_iActivePet[id] = iPet;
                g_iCounter[id] = iPet;
                
                if(is_user_alive(id) && !g_bRoundEnd) {
                    CreatePet(id);
                }
                
                new szPetName[32];
                GetPetName(iPet, szPetName, charsmax(szPetName));
                PetPrintL(id, "PET_ACTIVATED", szPetName);
            }
            SavePlayerData(id);
            Show_PetOperationsMenu(id, iPet);
        }
        case 4: {
            new iPrice = GetPetPrice(iPet);
            new iSellPrice = floatround(iPrice * 0.5);
            
            SetPetOwned(id, iPet, 0);
            
            if(g_iActivePet[id] == iPet) {
                if(is_valid_ent(g_iEntityId[id])) {
                    RemoveEntity(g_iEntityId[id]);
                }
                g_iActivePet[id] = -1;
            }
            
            new iCurrentMoney = GetUserCurrency(id);
            SetUserCurrency(id, iCurrentMoney + iSellPrice);
            
            SavePlayerData(id);
            
            new szPetName[32];
            GetPetName(iPet, szPetName, charsmax(szPetName));
            
            #if ACTIVE_MOD == PRO_PUBLIC
                PetPrintL(id, "PET_SOLD_MONEY", szPetName, iSellPrice);
            #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
                PetPrintL(id, "PET_SOLD_AMMO", szPetName, iSellPrice);
            #elseif ACTIVE_MOD == BIOHAZARD
                PetPrintL(id, "PET_SOLD_BIO", szPetName, iSellPrice);
            #elseif ACTIVE_MOD == JAILBREAK
                PetPrintL(id, "PET_SOLD_COIN", szPetName, iSellPrice);
            #endif
            
            Show_MyPetsMenu(id);
        }
        case 5: {
            Show_MyPetsMenu(id);
        }
        default: {
            Show_PetOperationsMenu(id, iPet);
        }
    }
    
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
public Show_PetInfoMenu(id, iPet, bool:isBuyMenu) {
    g_iCurrentPetIndex[id] = iPet;
    
    new szMenuTitle[128];
    FormatMenuTitleL(id, szMenuTitle, charsmax(szMenuTitle), "PET_INFO_TITLE");
    
    new iMenu = menu_create(szMenuTitle, "PetInfoMenu_Handler");
    
    new szItem[128], szLabel[96];
    new szName[32], szFlag[2];
    
    GetPetName(iPet, szName, charsmax(szName));
    GetPetFlag(iPet, szFlag, charsmax(szFlag));
    
    FormatL(id, szLabel, charsmax(szLabel), "PET_NAME_FIELD", szName);
    formatex(szItem, charsmax(szItem), "%s\w%s", KSATAG, szLabel);
    menu_additem(iMenu, szItem, "", 0);
    
    if(strlen(szFlag) > 0 && szFlag[0] != '^0') {
        FormatL(id, szLabel, charsmax(szLabel), "PET_FLAG_FIELD", szFlag);
    } else {
        FormatL(id, szLabel, charsmax(szLabel), "PET_FLAG_ALL");
    }
    formatex(szItem, charsmax(szItem), "%s\w%s", KSATAG, szLabel);
    menu_additem(iMenu, szItem, "", 0);
    
    new iPrice = GetPetPrice(iPet);
    #if ACTIVE_MOD == PRO_PUBLIC
        FormatL(id, szLabel, charsmax(szLabel), "PRICE_FIELD_MONEY", iPrice);
    #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
        FormatL(id, szLabel, charsmax(szLabel), "PRICE_FIELD_AMMO", iPrice);
    #elseif ACTIVE_MOD == BIOHAZARD
        FormatL(id, szLabel, charsmax(szLabel), "PRICE_FIELD_BIO", iPrice);
    #elseif ACTIVE_MOD == JAILBREAK
        FormatL(id, szLabel, charsmax(szLabel), "PRICE_FIELD_COIN", iPrice);
    #endif
    formatex(szItem, charsmax(szItem), "%s\w%s", KSATAG, szLabel);
    menu_additem(iMenu, szItem, "", 0);
    
    menu_addblank(iMenu, 0);
    
    if(isBuyMenu) {
        if(GetPetOwned(id, iPet)) {
            FormatL(id, szLabel, charsmax(szLabel), "ALREADY_PURCHASED");
            formatex(szItem, charsmax(szItem), "%s\d%s", KSATAG, szLabel);
            menu_additem(iMenu, szItem, "", 0);
        } else {
            FormatL(id, szLabel, charsmax(szLabel), "BUY_PET_BUTTON");
            formatex(szItem, charsmax(szItem), "%s\r%s", KSATAG, szLabel);
            menu_additem(iMenu, szItem, "3", 0);
        }
    }
    
    SetMenuNavL(id, iMenu, "MENU_HOME");
    
    menu_display(id, iMenu, 0);
}

public PetInfoMenu_Handler(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        if(g_iCurrentPetIndex[id] >= 0 && GetPetOwned(id, g_iCurrentPetIndex[id])) {
            Show_MyPetsMenu(id);
        } else {
            Show_BuyMenu(id);
        }
        return PLUGIN_HANDLED;
    }
    
    new szInfo[3], szName[64];
    new access, callback;
    menu_item_getinfo(menu, item, access, szInfo, charsmax(szInfo), szName, charsmax(szName), callback);
    
    if(strlen(szInfo) == 0) {
        menu_destroy(menu);
        Show_PetInfoMenu(id, g_iCurrentPetIndex[id], true);
        return PLUGIN_HANDLED;
    }
    
    new iPet = g_iCurrentPetIndex[id];
    
    if(str_to_num(szInfo) == 3) {
        if(GetPetOwned(id, iPet)) {
            PetPrintL(id, "ALREADY_OWN_PET");
            menu_destroy(menu);
            Show_PetInfoMenu(id, iPet, true);
            return PLUGIN_HANDLED;
        }
        
        new szFlag[2];
        GetPetFlag(iPet, szFlag, charsmax(szFlag));
        
        if(strlen(szFlag) > 0 && szFlag[0] != '^0') {
            if(!(get_user_flags(id) & read_flags(szFlag))) {
                PetPrintL(id, "MISSING_FLAG", szFlag);
                menu_destroy(menu);
                Show_PetInfoMenu(id, iPet, true);
                return PLUGIN_HANDLED;
            }
        }
        
        new iPrice = GetPetPrice(iPet);
        new iCurrentMoney = GetUserCurrency(id);
        
        if(iCurrentMoney < iPrice) {
            #if ACTIVE_MOD == PRO_PUBLIC
                PetPrintL(id, "NOT_ENOUGH_MONEY", iPrice, iCurrentMoney);
            #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
                PetPrintL(id, "NOT_ENOUGH_AMMO", iPrice, iCurrentMoney);
            #elseif ACTIVE_MOD == BIOHAZARD
                PetPrintL(id, "NOT_ENOUGH_BIO", iPrice, iCurrentMoney);
            #elseif ACTIVE_MOD == JAILBREAK
                PetPrintL(id, "NOT_ENOUGH_COIN", iPrice, iCurrentMoney);
            #endif
            menu_destroy(menu);
            Show_PetInfoMenu(id, iPet, true);
            return PLUGIN_HANDLED;
        }
        
        SetUserCurrency(id, iCurrentMoney - iPrice);
        SetPetOwned(id, iPet, 1);
        SavePlayerData(id);
        
        new szPetName[32];
        GetPetName(iPet, szPetName, charsmax(szPetName));
        
        #if ACTIVE_MOD == PRO_PUBLIC
            PetPrintL(id, "BOUGHT_PET_MONEY", szPetName, iPrice, GetUserCurrency(id));
        #elseif ACTIVE_MOD == ZOMBIE_PLAGUE
            PetPrintL(id, "BOUGHT_PET_AMMO", szPetName, iPrice, GetUserCurrency(id));
        #elseif ACTIVE_MOD == BIOHAZARD
            PetPrintL(id, "BOUGHT_PET_BIO", szPetName, iPrice, GetUserCurrency(id));
        #elseif ACTIVE_MOD == JAILBREAK
            PetPrintL(id, "BOUGHT_PET_COIN", szPetName, iPrice, GetUserCurrency(id));
        #endif
        
        menu_destroy(menu);
        Show_PetInfoMenu(id, iPet, true); 
        return PLUGIN_HANDLED;
    }
    
    menu_destroy(menu);
    Show_PetInfoMenu(id, iPet, !GetPetOwned(id, iPet));
    return PLUGIN_HANDLED;
}

public CreatePet(const id) {
    if(!is_user_alive(id) || g_bRoundEnd || g_iActivePet[id] == -1)
        return PLUGIN_HANDLED;

    if(is_valid_ent(g_iEntityId[id])) {
        RemoveEntity(g_iEntityId[id]);
    }

    new iEnt = rg_create_entity("info_target");
    new szModel[64];
    
    GetPetModel(g_iCounter[id], szModel, charsmax(szModel));

    new Float:fOrigin[3], Float:fViewOffset[3], Float:fAngles[3], Float:fRight[3];
    
    get_entvar(id, var_origin, fOrigin);
    get_entvar(id, var_view_ofs, fViewOffset);
    get_entvar(id, var_v_angle, fAngles);
    
    fOrigin[2] += fViewOffset[2];
    
    angle_vector(fAngles, ANGLEVECTOR_RIGHT, fRight);
    
    new Float:fPetOrigin[3];
    fPetOrigin[0] = fOrigin[0] + fRight[0] * 35.0;
    fPetOrigin[1] = fOrigin[1] + fRight[1] * 35.0;
    fPetOrigin[2] = fOrigin[2] + 5.0;

    engfunc(EngFunc_SetOrigin, iEnt, fPetOrigin);
    engfunc(EngFunc_SetModel, iEnt, szModel);

    static data[eDataPet];
    ArrayGetArray(g_DataPets, g_iCounter[id], data);
    
    new iPetMoveType = GetPetMoveType(g_iCounter[id]);
    
    if(iPetMoveType == 1) {
        if(data[PET_IDLE] != -1) {
            set_entvar(iEnt, var_sequence, data[PET_IDLE]);
        } else {
            set_entvar(iEnt, var_sequence, SEQ_IDLE);
        }
        set_entvar(iEnt, var_movetype, MOVETYPE_PUSHSTEP);
        set_entvar(iEnt, var_gravity, 1.0);
    } else {
        if(data[PET_IDLE] != -1) {
            set_entvar(iEnt, var_sequence, data[PET_IDLE]);
        } else {
            set_entvar(iEnt, var_sequence, SEQ_FLY_IDLE);
        }
        set_entvar(iEnt, var_movetype, MOVETYPE_FLY);
        set_entvar(iEnt, var_gravity, 0.0);
    }
    
    set_entvar(iEnt, var_frame, 0.0);
    set_entvar(iEnt, var_framerate, 1.0);
    set_entvar(iEnt, var_owner, id);

    set_entvar(iEnt, var_solid, SOLID_NOT);
    
    set_entvar(iEnt, var_rendermode, kRenderNormal);
    set_entvar(iEnt, var_renderamt, 255.0);
    
    g_iEntityId[id] = iEnt;

    if(g_ArrayCvars[PET_IS_SPAWN] == 1)
        g_bIsSpawn[id] = true;

    SetThink(iEnt, "RG_PetThink_Post");
    set_entvar(iEnt, var_nextthink, get_gametime() + 0.1);

    return PLUGIN_HANDLED;
}

public RG_PetThink_Post(iEnt) {
    if(!is_valid_ent(iEnt))
        return;

    static iOwner;
    iOwner = get_entvar(iEnt, var_owner);
    
    if(!is_user_connected(iOwner) || !is_user_alive(iOwner) || get_user_team(iOwner) == 3) {
        set_entvar(iEnt, var_effects, EF_NODRAW);
        set_entvar(iEnt, var_nextthink, 0.0);
        return;
    }

    static Float: fVelocity[3];
    get_entvar(iEnt, var_velocity, fVelocity);

    static Float: p_fOrigin[3], Float: e_fOrigin[3];

    get_entvar(iOwner, var_origin, p_fOrigin);
    get_entvar(iEnt, var_origin, e_fOrigin);

    engfunc(EngFunc_TraceLine, e_fOrigin, p_fOrigin, IGNORE_MONSTERS , iOwner, 0);          

    static Float: fraction;
    get_tr2(0, TR_flFraction, fraction);

    static Float: fDistance;
    fDistance = get_distance_f(p_fOrigin, e_fOrigin);

    static data[eDataPet];
    ArrayGetArray(g_DataPets, g_iCounter[iOwner], data);
    
    new iPetMoveType = GetPetMoveType(g_iCounter[iOwner]);
    
    if(iPetMoveType == 1) {
        if(floatabs(fVelocity[0]) < 1.0 && floatabs(fVelocity[1]) < 1.0 && fDistance < g_ArrayCvars[START_FOLLOW_DISTANTION]) {
            if(data[PET_IDLE] != -1) {
                set_entvar(iEnt, var_sequence, data[PET_IDLE]);
            } else {
                set_entvar(iEnt, var_sequence, SEQ_IDLE);
            }
        }
        else if(fDistance > g_ArrayCvars[START_FOLLOW_DISTANTION] && fDistance < g_ArrayCvars[TELEPTORT_DISTANTION]) {
            if(data[PET_RUN] != -1) {
                set_entvar(iEnt, var_sequence, data[PET_RUN]);
            } else {
                set_entvar(iEnt, var_sequence, SEQ_RUN);
            }

            turn_to_target(iEnt, e_fOrigin, iOwner, p_fOrigin);
                
            static Float: fSpeed;

            fSpeed = fDistance / g_ArrayCvars[MAX_SPEED];

            fVelocity[0] = (p_fOrigin[0] - e_fOrigin[0]) / fSpeed;
            fVelocity[1] = (p_fOrigin[1] - e_fOrigin[1]) / fSpeed;

            if(fDistance > 300.0) {
                fVelocity[0] *= 1.5;
                fVelocity[1] *= 1.5;
            }

            if(fraction == 0.0 && (p_fOrigin[2] - e_fOrigin[2]) < g_ArrayCvars[MAX_JUMP_HEIGHT]) {
                if(data[PET_JUMP] != -1) {
                    set_entvar(iEnt, var_sequence, data[PET_JUMP]);
                }
                fVelocity[2] = 150.0;
                set_entvar(iEnt, var_velocity, fVelocity);
            }
            set_entvar(iEnt, var_velocity, fVelocity);
        }
        else if(fDistance >= g_ArrayCvars[TELEPTORT_DISTANTION]) {
            if(fDistance > 2000.0) {
                new Float:fViewOffset[3], Float:fAngles[3], Float:fRight[3];
                
                get_entvar(iOwner, var_view_ofs, fViewOffset);
                get_entvar(iOwner, var_v_angle, fAngles);
                
                new Float:fHeadOrigin[3];
                fHeadOrigin[0] = p_fOrigin[0];
                fHeadOrigin[1] = p_fOrigin[1];
                fHeadOrigin[2] = p_fOrigin[2] + fViewOffset[2];
                
                angle_vector(fAngles, ANGLEVECTOR_RIGHT, fRight);
                
                new Float:fFinalOrigin[3];
                fFinalOrigin[0] = fHeadOrigin[0] + fRight[0] * 35.0;
                fFinalOrigin[1] = fHeadOrigin[1] + fRight[1] * 35.0;
                fFinalOrigin[2] = fHeadOrigin[2] + 5.0;
                
                set_entvar(iEnt, var_origin, fFinalOrigin);
                set_entvar(iEnt, var_velocity, Float:{0.0, 0.0, 0.0});
            } else {
                fVelocity[0] = (p_fOrigin[0] - e_fOrigin[0]) * 2.0;
                fVelocity[1] = (p_fOrigin[1] - e_fOrigin[1]) * 2.0;
                set_entvar(iEnt, var_velocity, fVelocity);
            }
        }
    } else {
        static Float:p_fVelocity[3];
        get_entvar(iOwner, var_velocity, p_fVelocity);
        
        new Float:fViewOffset[3], Float:fAngles[3], Float:fRight[3];
        
        get_entvar(iOwner, var_view_ofs, fViewOffset);
        get_entvar(iOwner, var_v_angle, fAngles);
        
        new Float:fHeadOrigin[3];
        fHeadOrigin[0] = p_fOrigin[0];
        fHeadOrigin[1] = p_fOrigin[1];
        fHeadOrigin[2] = p_fOrigin[2] + fViewOffset[2];
        
        angle_vector(fAngles, ANGLEVECTOR_RIGHT, fRight);
        
        new Float:fTargetOrigin[3];
        fTargetOrigin[0] = fHeadOrigin[0] + fRight[0] * 35.0;
        fTargetOrigin[1] = fHeadOrigin[1] + fRight[1] * 35.0;
        fTargetOrigin[2] = fHeadOrigin[2] + 5.0;
        
        new Float:fMoveSpeed = 8.0;
        fVelocity[0] = (fTargetOrigin[0] - e_fOrigin[0]) * fMoveSpeed;
        fVelocity[1] = (fTargetOrigin[1] - e_fOrigin[1]) * fMoveSpeed;
        fVelocity[2] = (fTargetOrigin[2] - e_fOrigin[2]) * fMoveSpeed;
        
        new Float:fMaxSpeed = 350.0;
        new Float:fCurrentSpeed = vector_length(fVelocity);
        if(fCurrentSpeed > fMaxSpeed) {
            fVelocity[0] = fVelocity[0] * fMaxSpeed / fCurrentSpeed;
            fVelocity[1] = fVelocity[1] * fMaxSpeed / fCurrentSpeed;
            fVelocity[2] = fVelocity[2] * fMaxSpeed / fCurrentSpeed;
        }
        
        set_entvar(iEnt, var_velocity, fVelocity);
        
        if(fCurrentSpeed > 15.0) {
            if(data[PET_RUN] != -1) {
                set_entvar(iEnt, var_sequence, data[PET_RUN]);
            } else {
                set_entvar(iEnt, var_sequence, SEQ_FLY_RUN);
            }
        } else {
            if(data[PET_IDLE] != -1) {
                set_entvar(iEnt, var_sequence, data[PET_IDLE]);
            } else {
                set_entvar(iEnt, var_sequence, SEQ_FLY_IDLE);
            }
        }
        
        turn_to_target(iEnt, e_fOrigin, iOwner, p_fOrigin);
        
        if(fDistance >= g_ArrayCvars[TELEPTORT_DISTANTION]) {
            if(fDistance > 2000.0) {
                set_entvar(iEnt, var_origin, fTargetOrigin);
                set_entvar(iEnt, var_velocity, Float:{0.0, 0.0, 0.0});
            }
        }
    }

    set_entvar(iEnt, var_nextthink, get_gametime() + 0.01);
}

SavePlayerData(id) {
    if(!is_user_connected(id))
        return;
        
    new szAuthId[35], szData[512];
    get_user_authid(id, szAuthId, charsmax(szAuthId));
    
    if(equal(szAuthId, "BOT"))
        return;
    
    new iLen = 0;
    for(new i = 0; i < g_iTotalPets; i++) {
        if(GetPetOwned(id, i)) {
            iLen += formatex(szData[iLen], charsmax(szData) - iLen, "%d,", i);
        }
    }
    
    if(iLen == 0) {
        formatex(szData, charsmax(szData), "|%d", g_iActivePet[id]);
    } else {
        szData[iLen-1] = '|';
        formatex(szData[iLen], charsmax(szData) - iLen, "%d", g_iActivePet[id]);
    }
    
    nvault_set(g_Vault, szAuthId, szData);
}

LoadPlayerData(id) {
    if(!is_user_connected(id))
        return;
        
    new szAuthId[35], szData[512];
    get_user_authid(id, szAuthId, charsmax(szAuthId));
    
    if(equal(szAuthId, "BOT"))
        return;
    
    for(new i = 0; i < g_iTotalPets; i++) {
        SetPetOwned(id, i, 0);
    }
    g_iActivePet[id] = -1;
    
    if(nvault_get(g_Vault, szAuthId, szData, charsmax(szData))) {
        new szPets[256], szActive[16];
        new iPos = contain(szData, "|");
        
        if(iPos != -1) {
            copy(szPets, iPos, szData);
            copy(szActive, charsmax(szActive), szData[iPos + 1]);
        } else {
            copy(szPets, charsmax(szPets), szData);
            szActive[0] = '^0';
        }
        
        if(strlen(szPets) > 0) {
            new szPetIndex[16], iTempPos = 0;
            while(szPets[iTempPos] != 0) {
                new j = 0;
                while(szPets[iTempPos] != ',' && szPets[iTempPos] != 0 && j < charsmax(szPetIndex) - 1) {
                    szPetIndex[j++] = szPets[iTempPos++];
                }
                szPetIndex[j] = '^0';
                
                if(strlen(szPetIndex) > 0) {
                    new iPet = str_to_num(szPetIndex);
                    if(iPet >= 0 && iPet < g_iTotalPets) {
                        SetPetOwned(id, iPet, 1);
                    }
                }
                
                if(szPets[iTempPos] == ',')
                    iTempPos++;
                else
                    break;
            }
        }
        
        if(strlen(szActive) > 0) {
            g_iActivePet[id] = str_to_num(szActive);
            if(g_iActivePet[id] != -1 && g_iActivePet[id] < g_iTotalPets) {
                g_iCounter[id] = g_iActivePet[id];
            } else {
                g_iActivePet[id] = -1;
            }
        }
        
        UpdateOwnedPetsList(id);
        
        if(g_iActivePet[id] != -1 && is_user_alive(id) && !g_bRoundEnd) {
            CreatePet(id);
        }
    }
}

public RemoveEntity(iEnt) {
    if(!is_valid_ent(iEnt))
        return;
        
    new iOwner = get_entvar(iEnt, var_owner);
    set_entvar(iEnt, var_flags, FL_KILLME);
    set_entvar(iEnt, var_nextthink, 0.0);

    if(iOwner > 0 && iOwner <= MaxClients) {
        g_iEntityId[iOwner] = 0;
    }
}

stock bool:is_valid_ent(ent) {
    if(!pev_valid(ent))
        return false;
    
    new classname[32];
    pev(ent, pev_classname, classname, charsmax(classname));
    
    return (equal(classname, "info_target") || equal(classname, "player") || equal(classname, "hostage_entity"));
}

public CreateCvars() {
    bind_pcvar_float(
        create_cvar(
            .name = "pets_max_jump_height",
            .string = "350.0",
            .flags = FCVAR_NONE,
            .description = "Petin maksimum zıplama yüksekliği"
        ), g_ArrayCvars[MAX_JUMP_HEIGHT]
    );

    bind_pcvar_float(
        create_cvar(
            .name = "pets_follow_distantion",
            .string = "100.0",
            .flags = FCVAR_NONE,
            .description = "Petin takip etmeye başlayacağı mesafe"
        ), g_ArrayCvars[START_FOLLOW_DISTANTION]
    );

    bind_pcvar_float(
        create_cvar(
            .name = "pets_telep_distantion",
            .string = "1250.0",
            .flags = FCVAR_NONE,
            .description = "Petin oyuncuya ışınlanacağı mesafe"
        ), g_ArrayCvars[TELEPTORT_DISTANTION]
    );

    bind_pcvar_float(
        create_cvar(
            .name = "pets_max_speed",
            .string = "370.0",
            .flags = FCVAR_NONE,
            .description = "Petin oyuncuya ulaşma hızı"
        ), g_ArrayCvars[MAX_SPEED]
    );

    bind_pcvar_float(
        create_cvar(
            .name = "pets_max_radius_spawn",
            .string = "200.0",
            .flags = FCVAR_NONE,
            .description = "Petin spawn olacağı maksimum mesafe yarıçapı"
        ), g_ArrayCvars[MAX_RADIUS_SPAWN]
    );
    
    bind_pcvar_num(
        create_cvar(
            .name = "pet_is_spawn",
            .string = "1",
            .flags = FCVAR_NONE,
            .description = "0 - Pet oyuncu öldüğünde ve raund sonunda yok olur.^n1 - 0 ile aynı, ama oyuncu respawn olduğunda geri gelir.^n2 - DM sunucuları için."
        ), g_ArrayCvars[PET_IS_SPAWN]
    );

    AutoExecConfig(true, "pet", "Pets");
}

stock UTIL__RemovePet(iEnt) {
    static data[eDataPet];
    ArrayGetArray(g_DataPets, g_iCounter[get_entvar(iEnt, var_owner)], data);
    
    if(data[PET_DEATH] != -1) {
        set_entvar(iEnt, var_sequence, data[PET_DEATH]);
    } else {
        set_entvar(iEnt, var_sequence, SEQ_DEATH);
    }
    
    set_entvar(iEnt, var_nextthink, get_gametime() + 1.0);
    set_entvar(iEnt, var_framerate, 1.0);
    set_entvar(iEnt, var_frame, 0.0);

    set_task(0.9, "RemoveEntity", iEnt);
}

stock Float:GetDistanceGround(const id) {
    const COORD_BITS = 16;
    const COORD_MULTIPLIER = 8;
    const MIN_Z_COORD = -(1 << (COORD_BITS - 1)) / COORD_MULTIPLIER;
    
    if(pev(id, pev_flags) & FL_ONGROUND)
        return 0.0;

    new Float:vecStart[3], Float:vecEnd[3];

    get_entvar(id, var_origin, vecStart);
    vecEnd = vecStart;
    vecEnd[2] = float(MIN_Z_COORD);
    engfunc(EngFunc_TraceMonsterHull,id,vecStart,vecEnd,DONT_IGNORE_MONSTERS,id,0);
    get_tr2(0,TR_vecEndPos,vecEnd);

    return vecStart[2] - vecEnd[2];
}

stock turn_to_target(iEnt, Float:e_fOrigin[3], Target, Float:t_fOrigin[3]) {
    if(Target) {
        new Float: fAngles[3];
        get_entvar(iEnt, var_angles, fAngles);

        new Float: Fx = t_fOrigin[0] - e_fOrigin[0];
        new Float: Fy = t_fOrigin[1] - e_fOrigin[1];
 
        new Float: fRaduis = floatatan(Fy/Fx, radian);

        fAngles[1] = fRaduis * (180 / 3.14159265359);

        if (t_fOrigin[0] < e_fOrigin[0])
            fAngles[1] -= 180.0;
        
        set_entvar(iEnt, var_angles, fAngles);
    }
}

stock Float: Set_Radius_Spawn(const id, const Float:radius) {
    new Float: fOrigin[3];
    get_entvar(id, var_origin, fOrigin);

    new Float: fAngles, Float:fDistantion;
    fAngles = random_float(0.0, 360.0);
    fDistantion = random_float(50.0, radius);

    new Float: result[3];
    result[0] = fOrigin[0] + fDistantion * floatcos(fAngles, degrees);
    result[1] = fOrigin[1] + fDistantion * floatsin(fAngles, degrees);
    result[2] = fOrigin[2];

    return result;
}

stock bool: is_spawn_location_free(const Float:origin[3]) {
   static tr;
   engfunc(EngFunc_TraceHull, origin, origin, 1, HULL_HEAD, 0, tr);
   if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
      return true;
    
   return false;
}