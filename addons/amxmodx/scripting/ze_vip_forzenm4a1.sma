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
#include <fun>
#include <hamsandwich>
#include <cstrike>
#include <zombieplague>

native novaria_vip_extra_items(name[], class[], cost[]);

new g_iVipItemId = -1;

#define is_valid_player(%1) (1 <= %1 <= 32)

new GALIL_V_MODEL[64] = "models/zombie_amxx_ru/v_blue_knight.mdl"
new GALIL_P_MODEL[64] = "models/zombie_amxx_ru/p_blue_knight.mdl"

new GL_V_MODEL[64] = "models/zombie_amxx_ru/v_buffm4_flx.mdl"
new GL_P_MODEL[64] = "models/zombie_amxx_ru/p_buffm4.mdl"

new cvar_dmgmultiplier, cvar_goldbullets, cvar_custommodel, cvar_uclip
new dark_exp
new red_exp
new mod[33]
new userdd[33]
new bool:g_HasGalil[33], g_hasZoom[33]

new m_spriteTexture
new g_itemid = -1

const Wep_galil = ((1<<CSW_GALIL))

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

public plugin_init()
{
    cvar_dmgmultiplier = register_cvar("zp_darknight_dmg_multiplier", "3.5")
    cvar_custommodel = register_cvar("zp_darknight_custom_model", "1")
    cvar_goldbullets = register_cvar("zp_darknight_gold_bullets", "1")
    cvar_uclip = register_cvar("zp_darknight_unlimited_clip", "1")
   
    register_plugin("M4a1 FrozenLava", "1.5", "Korab & Dazz")
 
    register_event("DeathMsg", "Death", "a")
    register_event("WeapPickup","checkModel","b","1=19")
    register_event("CurWeapon","checkWeapon","be","1=1")
 
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
    RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
    RegisterHam(Ham_TraceAttack, "worldspawn", "Fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_breakable", "Fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_wall", "Fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_door", "Fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_door_rotating", "Fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_plat", "Fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_rotating", "Fw_TraceAttack", 1)
    register_forward(FM_CmdStart, "fw_CmdStart")
    g_iVipItemId = novaria_vip_extra_items("FrozenLava M4a1", "1", "100")
}

public plugin_natives()
{    
    register_native("give_flm4a1","zp_flm4")
}

public zp_extra_item_selected(player, itemid)
{
    if (itemid == g_itemid)
    {
        zp_flm4(player)
    }
}

public novaria_item_selected(id, itemid)
{
    if (itemid == g_iVipItemId)
    {
        zp_flm4(id)
    }
}

public Fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
    if(!is_valid_player(iAttacker))
        return
   
    static Float:flEnd[3]
    get_tr2(ptr, TR_vecEndPos, flEnd)
   
    if(get_user_weapon(iAttacker) == CSW_GALIL && g_HasGalil[iAttacker])
    {
        if(iEnt)
        {
            message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
            write_byte(TE_DECAL)
            engfunc(EngFunc_WriteCoord, flEnd[0])
            engfunc(EngFunc_WriteCoord, flEnd[1])
            engfunc(EngFunc_WriteCoord, flEnd[2])
            write_byte(GUNSHOT_DECALS[random_num(0, charsmax(GUNSHOT_DECALS))])
            write_short(iEnt)
            message_end()
        }
        else
        {
            message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
            write_byte(TE_WORLDDECAL)
            engfunc(EngFunc_WriteCoord, flEnd[0])
            engfunc(EngFunc_WriteCoord, flEnd[1])
            engfunc(EngFunc_WriteCoord, flEnd[2])
            write_byte(GUNSHOT_DECALS[random_num(0, charsmax(GUNSHOT_DECALS))])
            message_end()
        }
        
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_GUNSHOTDECAL)
        engfunc(EngFunc_WriteCoord, flEnd[0])
        engfunc(EngFunc_WriteCoord, flEnd[1])
        engfunc(EngFunc_WriteCoord, flEnd[2])
        write_short(iAttacker)
        write_byte(GUNSHOT_DECALS[random_num(0, charsmax(GUNSHOT_DECALS))])
        message_end()
        
        engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flEnd, 0)
        if(mod[iAttacker] == 2)
        {
            write_byte(TE_SPRITE)
            engfunc(EngFunc_WriteCoord,flEnd[0])
            engfunc(EngFunc_WriteCoord,flEnd[1])
            engfunc(EngFunc_WriteCoord,flEnd[2])
            write_short(red_exp)
            write_byte(5)
            write_byte(150)
            message_end()
        }
        else
        {
            write_byte(TE_SPRITE)
            engfunc(EngFunc_WriteCoord,flEnd[0])
            engfunc(EngFunc_WriteCoord,flEnd[1])
            engfunc(EngFunc_WriteCoord,flEnd[2])
            write_short(dark_exp)
            write_byte(5)
            write_byte(150)
            message_end()
        }
        
        if (get_pcvar_num(cvar_goldbullets))
        {
            new vec1[3], vec2[3]
            get_user_origin(iAttacker, vec1, 1)
            get_user_origin(iAttacker, vec2, 3)
            
            if (mod[iAttacker] == 1)
            {
                message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
                write_byte(0)
                write_coord(vec1[0])
                write_coord(vec1[1])
                write_coord(vec1[2])
                write_coord(vec2[0])
                write_coord(vec2[1])
                write_coord(vec2[2])
                write_short(m_spriteTexture)
                write_byte(1)
                write_byte(5)
                write_byte(2)
                write_byte(1)
                write_byte(0)
                write_byte(0)
                write_byte(0)
                write_byte(255)
                write_byte(200)
                write_byte(150)
                message_end()
            }
            else if(mod[iAttacker] == 2)
            { 
                message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
                write_byte(0)
                write_coord(vec1[0])
                write_coord(vec1[1])
                write_coord(vec1[2])
                write_coord(vec2[0])
                write_coord(vec2[1])
                write_coord(vec2[2])
                write_short(m_spriteTexture)
                write_byte(1)
                write_byte(5)
                write_byte(2)
                write_byte(3)
                write_byte(6)
                write_byte(255)
                write_byte(0)
                write_byte(0)
                write_byte(200)
                write_byte(150)
                message_end()
            }
        }
    }
}

public client_connect(id)
{
    g_HasGalil[id] = false
    mod[id] = 0
}

public client_disconnected(id)
{
    g_HasGalil[id] = false
    mod[id] = 0
}

public Death()
{
    g_HasGalil[read_data(2)] = false
}

public fwHamPlayerSpawnPost(id)
{
    g_HasGalil[id] = false
    mod[id] = 0
}

public plugin_precache()
{
    precache_model(GALIL_V_MODEL)
    precache_model(GALIL_P_MODEL)
    precache_model(GL_V_MODEL)
    precache_model(GL_P_MODEL)
    m_spriteTexture = precache_model("sprites/dot.spr")
    precache_sound("weapons/zoom.wav")
    dark_exp=precache_model("sprites/zombie_amxx_ru/blue_explode.spr")
    red_exp=precache_model("sprites/zombie_amxx_ru/red_explode.spr")
}

public zp_user_infected_post(id)
{
    if (zp_get_user_zombie(id))
    {
        g_HasGalil[id] = false
        mod[id] = 0
    }
}

public checkModel(id)
{
    if (zp_get_user_zombie(id))
        return PLUGIN_HANDLED
   
    new szWeapID = read_data(2)
   
    if (szWeapID == CSW_GALIL && g_HasGalil[id] == true && get_pcvar_num(cvar_custommodel))
    {    
        if(mod[id] == 1)
        {
            set_pev(id, pev_viewmodel2, GALIL_V_MODEL)
            set_pev(id, pev_weaponmodel2, GALIL_P_MODEL)
        }
        else
        {
            set_pev(id, pev_viewmodel2, GL_V_MODEL)
            set_pev(id, pev_weaponmodel2, GL_P_MODEL)        
        }
    }
    return PLUGIN_HANDLED
}

public checkWeapon(id)
{
    new plrClip, plrAmmo, plrWeap[32]
    new plrWeapId
   
    plrWeapId = get_user_weapon(id, plrClip, plrAmmo)
   
    if (plrWeapId == CSW_GALIL && g_HasGalil[id])
    {
        checkModel(id)
    }
    else
    {
        return PLUGIN_CONTINUE
    }
   
    if (plrClip == 0 && get_pcvar_num(cvar_uclip))
    {
        get_weaponname(plrWeapId, plrWeap, 31)
        give_item(id, plrWeap)
        engclient_cmd(id, plrWeap)
    }
    return PLUGIN_HANDLED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
    if (is_valid_player(attacker) && get_user_weapon(attacker) == CSW_GALIL && g_HasGalil[attacker])
    {
        if(mod[attacker] == 1)
        {
            SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmgmultiplier))
        }
        else if(mod[attacker] == 2)
        {
            SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmgmultiplier) * 1.5)
        }
    }
    
    if (is_valid_player(attacker) && get_user_weapon(attacker) == CSW_GALIL && g_HasGalil[attacker])
    {
        if(mod[attacker] == 1 && userdd[attacker] < 50)
        {
            userdd[attacker] += 1
        }
        else
        {
            mod[attacker] = 2
            userdd[attacker] = 0
            set_task(5.5, "backtnormal", attacker)
        }
    }
}

public backtnormal(attacker)
{
    mod[attacker] = 1
}

public fw_CmdStart(id, uc_handle, seed)
{
    if(!is_user_alive(id))
        return PLUGIN_HANDLED
    
    if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2))
    {
        new szClip, szAmmo
        new szWeapID = get_user_weapon(id, szClip, szAmmo)
        
        if(szWeapID == CSW_GALIL && g_HasGalil[id] == true && !g_hasZoom[id] == false)
        {
            g_hasZoom[id] = false
            cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
            emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
        }
        else if (szWeapID == CSW_GALIL && g_HasGalil[id] == true && g_hasZoom[id])
        {
            g_hasZoom[id] = false
            cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
        }
    }
    return PLUGIN_HANDLED
}

public zp_flm4(player)
{
    if (user_has_weapon(player, CSW_GALIL))
        drop_prim(player)
    
    give_item(player, "weapon_galil")
    client_print(player, print_chat, "[SunucuTag] Frozen DarkM4a1 satın aldınız")
    g_HasGalil[player] = true
    mod[player] = 1
}

stock drop_prim(id)
{
    new weapons[32], num
    get_user_weapons(id, weapons, num)
    
    for (new i = 0; i < num; i++) {
        if (Wep_galil & (1<<weapons[i]))
        {
            static wname[32]
            get_weaponname(weapons[i], wname, sizeof wname - 1)
            engclient_cmd(id, "drop", wname)
            mod[id] = 0
        }
    }
}