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
// ============================================================================
//     █████╗ ██████╗  ██████╗ █████╗ ███╗   ██╗ █████╗         ██╗   ██╗
//    ██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║██╔══██╗        ██║   ██║
//    ███████║██████╔╝██║     ███████║██╔██╗ ██║███████║ █████╗ ██║   ██║
//    ██╔══██║██╔══██╗██║     ██╔══██║██║╚██╗██║██╔══██║ ╚════╝ ╚██╗ ██╔╝
//    ██║  ██║██║  ██║╚██████╗██║  ██║██║ ╚████║██║  ██║         ╚████╔╝ 
//    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝          ╚═══╝  
// ============================================================================
//  Plugin:    [ZP] Extra Item: Arcana-V (VIP Edit)
//  Version:   2.0
//  Author:    Kolmi ( divinezavet ) / VIP Edit
// ============================================================================

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>

// Закомментируйте, если вы используете 1.8.2. Если вы используете 1.9.0+ не комментируйте.
#define USE_REAPI

#if defined USE_REAPI
    #include <reapi>
#else
    #include <non_reapi_support>
    #include <cstrike>
    #include <engine>
    
#define HC_CONTINUE HAM_IGNORED
    #define HC_SUPERCEDE HAM_SUPERCEDE
#endif

// Поддержка для старых версий AMXX 1.8.2
#if !defined MaxClients
    #define MaxClients 32
#endif

#define PLUGIN "[ZP] Extra: Arcana-V"
#define VERSION "2.0"
#define AUTHOR "Kolmi"

// ==========================================
// [ VIP EXTRA ITEM INTEGRATION ]
// ==========================================
native novaria_vip_extra_items(name[], class[], cost[]);
new g_iVipItemId = -1;

// ==========================================
// [ НАСТРОЙКИ ОРУЖИЯ | WEAPON SETTINGS ]
// ==========================================
#define WEAPON_NAME         "weapon_m249"
#define WEAPON_CSW          CSW_M249
#define WEAPON_IMPULSE      81023

// Боезапас
#define WEAPON_AMMO         50        // Патроны в обойме
#define WEAPON_BPAMMO       200       // Патроны в запасе

// Настройки урона и скорости
const Float: WEAPON_P_DMG   = 200.0;  // Урон от основного выстрела (ЛКМ)
const Float: WEAPON_P_RATE  = 0.25;   // Задержка основного выстрела
const Float: WEAPON_P_RANGE = 300.0;  // Дальность основного выстрела (радиус поиска цели)
const Float: WEAPON_P_CONE  = 0.707;  // Угол конуса (0.0 = 90° от центра, общий 180°. 0.707 = 45° от центра, общий 90°)
const Float: WEAPON_S_DMG   = 2500.0; // Урон от снаряда (режим ПКМ)
const Float: WEAPON_S_RADIUS = 150.0; // Радиус поражения снаряда
const Float: WEAPON_S_KNOCK  = 5000.0; // Сила отталкивания снаряда
const Float: WEAPON_S_RATE  = 1.0;    // Задержка выстрела снарядом
const Float: RELOAD_TIME    = 2.5;    // Время перезарядки

// Энергия
const Float: MAX_GAUGE      = 100.0;  // Максимум энергии
const Float: GAUGE_REGEN    = 5.0;    // Восстановление энергии в секунду (%)
#define REGEN_OFFHAND       0         // 1 = Реген и в руках и в оффхенде, 0 = Только в руках

// Вторичный режим
const MAX_S_SHOTS           = 3;      // Кол-во выстрелов в режиме ПКМ
const Float: S_MODE_TIME    = 10.0;   // Время действия режима ПКМ (сек)

// ==========================================
// [ НАСТРОЙКИ МОДЕЛЕЙ, ЗВУКОВ, СПРАЙТОВ ]
// ==========================================
new const V_MODEL_A[]   = "models/zpt/v_burstdischargeadv_a.mdl"
new const V_MODEL_B[]   = "models/zpt/v_burstdischargeadv_b.mdl"
new const P_MODEL[]     = "models/zpt/p_burstdischargeadv.mdl"
new const W_MODEL[]     = "models/zpt/w_burstdischargeadv.mdl"
new const PROJ_MODEL[]  = "models/zpt/ef_burstdischargeadv02.mdl"
new const IMPACT_MODEL[]= "models/zpt/ef_burstdischargeadv01.mdl"

new const SPR_MUZZLE[]  = "sprites/zpt/muzzleflash402.spr"
new const SPR_LASER[]   = "sprites/zpt/ef_burstdischargeadv_laser.spr"
new const SPR_WPNLIST[] = "sprites/weapon_burstdischargeadv.txt"

new const SND_SHOOT1[]  = "weapons/burstdischarge1.wav"
new const SND_SHOOT2[]  = "weapons/burstdischarge2.wav"
new const SND_END[]     = "weapons/burstdischarge_change_end.wav"

// ==========================================
// [ MUZZLEFLASH & SPRITE ЭНТИТИ ]
// ==========================================
#define m_maxFrame 35
#define MUZZLE_TIME 0.05
#define MUZZLE_CLASSNAME "ent_arcana_sprite"
#define MIN_FREE_EDICTS 100

new g_iszSpriteKey

#define CustomSprite(%0) (pev(%0, pev_impulse) == g_iszSpriteKey)

// Остальные энтити
#define CLASS_PROJ          "arcana_v_proj"
#define PROJ_IMPULSE        81024
#define IMPACT_IMPULSE      81025

enum {
    ANIM_IDLE = 0,
    ANIM_SHOOTA,
    ANIM_RELOAD,
    ANIM_DRAW,
    ANIM_CHANGE,
    ANIM_SHOOTB,
    ANIM_END,
    ANIM_SHOOTB_END
}

#define TASK_ENDMODE        81051

// ==========================================
// [ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ]
// ==========================================
new bool:g_bModeB[33]
new g_iShotsB[33]
new Float:g_flModeBEndTime[33]
new Float:g_flLastRegen[33]
new g_msgWeaponList, g_msgAmmoX
new g_iSpriteLaserId
new bool:g_bHasArcana[33]

#define IsCustomWeapon(%0) (get_entvar(%0, var_impulse) == WEAPON_IMPULSE)

// ==========================================
// [ ИНИЦИАЛИЗАЦИЯ И ПРЕКЕШ ]
// ==========================================
public plugin_precache() {
    precache_model(V_MODEL_A)
    precache_model(V_MODEL_B)
    precache_model(P_MODEL)
    precache_model(W_MODEL)
    precache_model(PROJ_MODEL)
    precache_model(IMPACT_MODEL)
    
    precache_model(SPR_MUZZLE)
    g_iSpriteLaserId = precache_model(SPR_LASER)
    precache_model("sprites/640hud249.spr")
    precache_model("sprites/640hud248.spr")
    precache_model("sprites/640hud224.spr")
    precache_generic(SPR_WPNLIST)
    
    precache_sound(SND_SHOOT1)
    precache_sound(SND_SHOOT2)
    precache_sound(SND_END)
    
    g_iszSpriteKey = engfunc(EngFunc_AllocString, MUZZLE_CLASSNAME)
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    // Novaria VIP Entegrasyonu
    g_iVipItemId = novaria_vip_extra_items("Arcana-V", "3", "350")
    
#if defined USE_REAPI
    RegisterHookChain(RG_CBasePlayer_Killed, "OnPlayerKilled_Pre", 0)
    RegisterHookChain(RG_CBasePlayer_PreThink, "OnPlayerPreThink_Post", 1)
    RegisterHookChain(RG_CBasePlayer_AddPlayerItem, "OnAddPlayerItem_Post", 1)
    RegisterHookChain(RG_CWeaponBox_SetModel, "CWeaponBox_SetModel_Pre", 0)
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "CWeapon_DefaultReload_Pre", 0)
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "CWeapon_DefaultReload_Post", 1)
#else
    RegisterHam(Ham_Killed, "player", "OnPlayerKilled_Pre", 0)
    RegisterHam(Ham_Player_PreThink, "player", "OnPlayerPreThink_Post", 1)
    RegisterHam(Ham_AddPlayerItem, "player", "OnAddPlayerItem_Post", 1)
    register_forward(FM_SetModel, "CWeaponBox_SetModel_Pre", 0)
    RegisterHam(Ham_Weapon_Reload, WEAPON_NAME, "OnWeaponReload_Post", 1)
#endif
    
    RegisterHam(Ham_Item_Deploy, WEAPON_NAME, "OnItemDeploy_Post", 1)
    RegisterHam(Ham_Weapon_Reload, WEAPON_NAME, "OnWeaponReload_Pre", 0)
    RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_NAME, "OnWeaponIdle_Pre", 0)
    RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_NAME, "OnPrimaryAttack_Pre", 0)
    RegisterHam(Ham_Item_PostFrame, WEAPON_NAME, "OnItemPostFrame_Post", 1)
    
    RegisterHam(Ham_Think, "env_sprite", "CSprite_Think_Pre", 0)
    RegisterHam(Ham_Think, "info_target", "OnInfoTargetThink_Pre", 0)
    RegisterHam(Ham_Touch, "info_target", "OnInfoTargetTouch_Pre", 0)
    
    register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
    
    register_clcmd("weapon_burstdischargeadv", "CmdWeaponSelect")
    
    g_msgWeaponList = get_user_msgid("WeaponList")
    g_msgAmmoX = get_user_msgid("AmmoX")
}

public plugin_natives() {
    register_native("zp_give_user_arcana_v", "native_give_arcana")
}

public native_give_arcana(plugin_id, num_params) {
    new id = get_param(1)
    if (!is_user_alive(id) || zp_get_user_zombie(id)) return false
    novaria_item_selected(id, g_iVipItemId)
    return true
}

public CmdWeaponSelect(id) {
    engclient_cmd(id, WEAPON_NAME)
    return PLUGIN_HANDLED
}

stock Float:GetEntFuser1(ent) {
#if defined USE_REAPI
    return Float:get_entvar(ent, var_fuser1)
#else
    new Float:flVal
    pev(ent, pev_fuser1, flVal)
    return flVal
#endif
}

// ==========================================
// [ ОСНОВНЫЕ ФУНКЦИИ ВЫДАЧИ ОРУЖИЯ ]
// ==========================================
public novaria_item_selected(id, itemid) {
    if (itemid == g_iVipItemId) {
        rg_drop_items_by_slot(id, PRIMARY_WEAPON_SLOT)
        
        new pWeapon = rg_give_item(id, WEAPON_NAME, GT_APPEND)
        if (!is_nullent(pWeapon)) {
            set_entvar(pWeapon, var_impulse, WEAPON_IMPULSE)
            set_entvar(pWeapon, var_fuser1, MAX_GAUGE) // Энергия: 100
            
            set_member(pWeapon, m_Weapon_iClip, WEAPON_AMMO)
#if defined USE_REAPI
            rg_set_user_bpammo(id, WeaponIdType:WEAPON_CSW, WEAPON_BPAMMO)
            rg_switch_weapon(id, pWeapon)
#else
            cs_set_user_bpammo(id, WEAPON_CSW, WEAPON_BPAMMO)
            engclient_cmd(id, WEAPON_NAME)
#endif
            ExecuteHamB(Ham_Item_Deploy, pWeapon)
            
            g_bModeB[id] = false
            g_bHasArcana[id] = true
            g_flLastRegen[id] = get_gametime()
            UpdateHUDAmmo2(id, floatround(MAX_GAUGE))
        }
    }
}

public OnAddPlayerItem_Post(id, pWeapon) {
    if (is_nullent(pWeapon)) return HC_CONTINUE
    
    if (IsCustomWeapon(pWeapon)) {
        g_bHasArcana[id] = true
        SendWeaponList(id, "weapon_burstdischargeadv", 3, 200, 12, 100, 0, 4, WEAPON_CSW, 0)
    } else if (get_member(pWeapon, m_iId) == WEAPON_CSW) {
        SendWeaponList(id, "weapon_m249", 3, 200, -1, -1, 0, 4, WEAPON_CSW, 0)
    }
    return HC_CONTINUE
}

public CWeaponBox_SetModel_Pre(ent, const model[]) {
    if (!is_nullent(ent)) {
#if !defined USE_REAPI
        new szClassName[32]
        get_entvar(ent, var_classname, szClassName, charsmax(szClassName))
        if (!equal(szClassName, "weaponbox")) return FMRES_IGNORED
#endif
        for (new i = 0; i < 6; i++) {
            new pItem = get_member(ent, m_WeaponBox_rgpPlayerItems, i)
            if (!is_nullent(pItem) && IsCustomWeapon(pItem)) {
                new iOwner = get_entvar(ent, var_owner)
                if (iOwner >= 1 && iOwner <= MaxClients)
                    g_bHasArcana[iOwner] = false
#if defined USE_REAPI
                SetHookChainArg(2, ATYPE_STRING, W_MODEL)
                return HC_CONTINUE
#else
                engfunc(EngFunc_SetModel, ent, W_MODEL)
                return FMRES_SUPERCEDE
#endif
            }
        }
    }
#if defined USE_REAPI
    return HC_CONTINUE
#else
    return FMRES_IGNORED
#endif
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle) {
    if (!is_user_alive(id) || !g_bHasArcana[id]) return FMRES_IGNORED
    new pActive = get_member(id, m_pActiveItem)
    if (!is_nullent(pActive) && IsCustomWeapon(pActive)) {
        set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
        return FMRES_HANDLED
    }
    return FMRES_IGNORED
}

// ==========================================
// [ DEPLOY, HOLSTER, RELOAD ]
// ==========================================
public OnItemDeploy_Post(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    if (!is_user_alive(id)) return HAM_IGNORED
    
    set_entvar(id, var_weaponmodel, P_MODEL)
    
    if (g_bModeB[id] && get_gametime() >= g_flModeBEndTime[id]) {
        g_bModeB[id] = false
        g_iShotsB[id] = 0
        set_entvar(pWeapon, var_fuser1, 0.0)
    }
    
    // Анимация доставания
    if (g_bModeB[id]) {
        set_entvar(id, var_viewmodel, V_MODEL_B)
        SendWeaponAnim(id, ANIM_SHOOTB) // Модель Б не имеет draw-анимации
    } else {
        set_entvar(id, var_viewmodel, V_MODEL_A)
        SendWeaponAnim(id, ANIM_DRAW)
    }
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, 1.5)
    set_member(pWeapon, m_Weapon_flNextPrimaryAttack, 1.0)
    set_member(pWeapon, m_Weapon_flNextSecondaryAttack, 1.0)
    
    g_flLastRegen[id] = get_gametime()
    UpdateHUDAmmo2(id, floatround(GetEntFuser1(pWeapon)))
    
    SendWeaponList(id, "weapon_burstdischargeadv", 3, 200, 12, 100, 0, 4, WEAPON_CSW, 0)
    return HAM_IGNORED
}

public OnWeaponReload_Pre(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    new id = get_member(pWeapon, m_pPlayer)
    if (g_bModeB[id]) return HAM_SUPERCEDE // Блокировка перезарядки (R) в режиме Б
    return HAM_IGNORED
}

public OnWeaponIdle_Pre(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    if (get_member(pWeapon, m_Weapon_flTimeWeaponIdle) > 0.0) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    if (!is_user_alive(id)) return HAM_IGNORED
    
    // Idle анимация
    SendWeaponAnim(id, ANIM_IDLE)
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, 3.0)
    return HAM_SUPERCEDE
}

#if defined USE_REAPI
public CWeapon_DefaultReload_Pre(const pWeapon, iClipSize, iAnim, Float:fDelay) {
    if (IsCustomWeapon(pWeapon)) {
        new id = get_member(pWeapon, m_pPlayer)
        if (g_bModeB[id]) return HC_SUPERCEDE 
        
        SetHookChainArg(3, ATYPE_INTEGER, ANIM_RELOAD)
        SetHookChainArg(4, ATYPE_FLOAT, Float:RELOAD_TIME)
        return HC_CONTINUE
    }
    return HC_CONTINUE
}

public CWeapon_DefaultReload_Post(const pWeapon, iClipSize, iAnim, Float:fDelay) {
    if (IsCustomWeapon(pWeapon)) {
        new id = get_member(pWeapon, m_pPlayer)
        
        // Отправляем анимацию перезарядки
        SendWeaponAnim(id, ANIM_RELOAD)
    }
}
#else
public OnWeaponReload_Post(pWeapon) {
    if (IsCustomWeapon(pWeapon)) {
        if (get_member(pWeapon, m_Weapon_fInReload)) {
            new id = get_member(pWeapon, m_pPlayer)
            
            SendWeaponAnim(id, ANIM_RELOAD)
            
            // Ручная настройка времени перезарядки для AMXX 1.8.2
            set_member(id, m_flNextAttack, RELOAD_TIME)
            set_member(pWeapon, m_Weapon_flTimeWeaponIdle, RELOAD_TIME + 0.5)
            set_member(pWeapon, m_Weapon_flNextPrimaryAttack, RELOAD_TIME)
            set_member(pWeapon, m_Weapon_flNextSecondaryAttack, RELOAD_TIME)
        }
    }
    return HAM_IGNORED
}
#endif

// ==========================================
// [ ГЛАВНАЯ ЛОГИКА ОРУЖИЯ И СОСТОЯНИЙ ]
// ==========================================
public client_disconnected(id) {
    ResetPlayerState(id)
}

public OnPlayerKilled_Pre(id, attacker, shouldgib) {
    ResetPlayerState(id)
}

public zp_user_infected_post(id, infector, nemesis) {
    ResetPlayerState(id)
}

stock ResetPlayerState(id) {
    g_bModeB[id] = false
    g_bHasArcana[id] = false
    g_iShotsB[id] = 0
    g_flModeBEndTime[id] = 0.0
    remove_task(id + TASK_ENDMODE)
}

public OnPlayerPreThink_Post(id) {
    if (!is_user_alive(id) || !g_bHasArcana[id]) return HC_CONTINUE
    
    new Float:flTime = get_gametime()
    new pActive = get_member(id, m_pActiveItem)
    new bool:bActiveIsArcana = (!is_nullent(pActive) && IsCustomWeapon(pActive))
    
    if (bActiveIsArcana) {
        // Проверка таймера Mode B
        if (g_bModeB[id]) {
            if (flTime >= g_flModeBEndTime[id]) {
                EndModeB(id, pActive)
            }
        }
        
        // Переключение режима (ПКМ) проверяем здесь
        new iButton = get_entvar(id, var_button)
        new iOldButtons = get_entvar(id, var_oldbuttons)
        
        if ((iButton & IN_ATTACK2) && !(iOldButtons & IN_ATTACK2)) {
            if (!g_bModeB[id]) {
                if (GetEntFuser1(pActive) >= 99.0) {
                    g_bModeB[id] = true
                    g_iShotsB[id] = MAX_S_SHOTS
                    g_flModeBEndTime[id] = flTime + S_MODE_TIME
                    
                    set_entvar(id, var_viewmodel, V_MODEL_B)
                    SendWeaponAnim(id, ANIM_CHANGE)
                    
                    set_entvar(pActive, var_fuser1, 0.0) // Сброс энергии
                    UpdateHUDAmmo2(id, 0)
                    
                    set_member(pActive, m_Weapon_flTimeWeaponIdle, 1.0)
                    set_member(pActive, m_Weapon_flNextPrimaryAttack, 1.0)
                    set_member(pActive, m_Weapon_flNextSecondaryAttack, 1.0)
                    
                    // Блокируем передачу серверу
                    set_entvar(id, var_button, iButton & ~IN_ATTACK2)
                }
            }
        }
    }
    
    // Пассивная регенерация энергии
#if REGEN_OFFHAND
    new pArcana = get_member(id, m_rgpPlayerItems, PRIMARY_WEAPON_SLOT)
    if (!is_nullent(pArcana) && IsCustomWeapon(pArcana)) {
#else
    new pArcana = pActive
    if (bActiveIsArcana) {
#endif
        if (!g_bModeB[id]) {
            new Float:flGauge = GetEntFuser1(pArcana)
            if (flGauge < MAX_GAUGE) {
                new Float:flDelta = flTime - g_flLastRegen[id]
                if (flDelta > 0.0) {
                    new iOldParam = floatround(flGauge)
                    flGauge += (GAUGE_REGEN * flDelta)
                    if (flGauge > MAX_GAUGE) flGauge = MAX_GAUGE
                    
                    set_entvar(pArcana, var_fuser1, flGauge)
                    
                    // Обновляем HUD только если пушка сейчас в руках
                    if (bActiveIsArcana && floatround(flGauge) != iOldParam) {
                        UpdateHUDAmmo2(id, floatround(flGauge))
                    }
                }
            }
        }
        g_flLastRegen[id] = flTime
    }
    
    return HC_CONTINUE
}

public OnItemPostFrame_Post(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    
    // Блокировка лимита патронов на 50, игнорируя нативные 100 у M249
    new iClip = get_member(pWeapon, m_Weapon_iClip)
    if (iClip > WEAPON_AMMO) {
        new id = get_member(pWeapon, m_pPlayer)
        new diff = iClip - WEAPON_AMMO
        set_member(pWeapon, m_Weapon_iClip, WEAPON_AMMO)
        
#if defined USE_REAPI
        new bpammo = rg_get_user_bpammo(id, WeaponIdType:WEAPON_CSW)
        rg_set_user_bpammo(id, WeaponIdType:WEAPON_CSW, bpammo + diff)
#else
        new bpammo = cs_get_user_bpammo(id, WEAPON_CSW)
        cs_set_user_bpammo(id, WEAPON_CSW, bpammo + diff)
#endif
    }
    return HAM_IGNORED
}

public OnPrimaryAttack_Pre(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    if (get_member(pWeapon, m_Weapon_flNextPrimaryAttack) > 0.0) return HAM_SUPERCEDE
    
    if (g_bModeB[id])
        return HandleModeBAttack(id, pWeapon)
    
    return HandleModeAAttack(id, pWeapon)
}

// Обработчик выстрела Режима А (ЛКМ): энергетический конусный луч
HandleModeAAttack(id, pWeapon) {
    new iClip = get_member(pWeapon, m_Weapon_iClip)
    if (iClip <= 0) return HAM_SUPERCEDE
    
    set_member(pWeapon, m_Weapon_iClip, iClip - 1)
    
    SendWeaponAnim(id, ANIM_SHOOTA)
    emit_sound(id, CHAN_WEAPON, SND_SHOOT1, 1.0, ATTN_NORM, 0, PITCH_NORM)
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, WEAPON_P_RATE + 0.5)
    set_member(pWeapon, m_Weapon_flNextPrimaryAttack, WEAPON_P_RATE)
    set_member(pWeapon, m_Weapon_flNextSecondaryAttack, WEAPON_P_RATE)
    
    Weapon_SpriteAttached(id, SPR_MUZZLE, 0.04, 255.0, 1)
    
    DoConeDamage(id)
    
    new Float:vPunch[3]
    vPunch[0] = random_float(-1.5, -0.5)
    set_entvar(id, var_punchangle, vPunch)
    
    return HAM_SUPERCEDE
}

// Обработчик выстрела Режима Б (ПКМ): пробивной энергетический снаряд
HandleModeBAttack(id, pWeapon) {
    if (g_iShotsB[id] > 0) {
        FireModeBProjectile(id)
        SpawnImpactEffect(id) // Модель эффекта у дула
        g_iShotsB[id]--
        
        SendWeaponAnim(id, ANIM_SHOOTB)
        emit_sound(id, CHAN_WEAPON, SND_SHOOT2, 1.0, ATTN_NORM, 0, PITCH_NORM)
        
        Weapon_SpriteAttached(id, SPR_MUZZLE, 0.1, 255.0, 1)
        
        new Float:vPunch[3]
        vPunch[0] = -3.0
        set_entvar(id, var_punchangle, vPunch)
        
        set_member(pWeapon, m_Weapon_flTimeWeaponIdle, WEAPON_S_RATE + 0.5)
        set_member(pWeapon, m_Weapon_flNextPrimaryAttack, WEAPON_S_RATE)
        set_member(pWeapon, m_Weapon_flNextSecondaryAttack, WEAPON_S_RATE)
        
        if (g_iShotsB[id] <= 0) {
            // Последний мощный выстрел (только выстрел, без складывания)
            SendWeaponAnim(id, ANIM_SHOOTB_END)
            
            g_bModeB[id] = false
            set_entvar(pWeapon, var_fuser1, 0.0)
            UpdateHUDAmmo2(id, 0)
            
            // Даем время (0.8 сек) на проигрывание звука выстрела и отдачи
            new Float:flShotDelay = 0.8
            set_member(pWeapon, m_Weapon_flTimeWeaponIdle, flShotDelay)
            set_member(pWeapon, m_Weapon_flNextPrimaryAttack, flShotDelay)
            set_member(pWeapon, m_Weapon_flNextSecondaryAttack, flShotDelay)
            
            // Через 0.8с вызываем EndModeB, которая включит ANIM_END и уберет пушку
            set_task(flShotDelay, "Task_EndModeB", id + TASK_ENDMODE)
        }
    } else {
        EndModeB(id, pWeapon)
    }
    return HAM_SUPERCEDE
}

// ==========================================
// [ ЛОГИКА Mode A И УРОН ]
// ==========================================
DoConeDamage(id) {
    new Float:vOrigin[3], Float:vAngles[3], Float:vForward[3]
    get_entvar(id, var_origin, vOrigin)
    get_entvar(id, var_v_angle, vAngles)
    angle_vector(vAngles, ANGLEVECTOR_FORWARD, vForward)
    
    new Float:vViewOfs[3]
    get_entvar(id, var_view_ofs, vViewOfs)
    vOrigin[0] += vViewOfs[0]
    vOrigin[1] += vViewOfs[1]
    vOrigin[2] += vViewOfs[2]
    
    new bool:bHitZombie = false
    
    for (new target = 1; target <= MaxClients; target++) {
        if (!is_user_alive(target) || id == target) continue
        if (!zp_get_user_zombie(target)) continue
        
        new Float:tOrigin[3]
        get_entvar(target, var_origin, tOrigin)
        
        new Float:vDir[3]
        vDir[0] = tOrigin[0] - vOrigin[0]
        vDir[1] = tOrigin[1] - vOrigin[1]
        vDir[2] = tOrigin[2] - vOrigin[2]
        
        new Float:fDistSq = vDir[0]*vDir[0] + vDir[1]*vDir[1] + vDir[2]*vDir[2]
        if (fDistSq > WEAPON_P_RANGE * WEAPON_P_RANGE) continue
        
        new Float:fLen = floatsqroot(fDistSq)
        if (fLen > 0.0) {
            vDir[0] /= fLen; vDir[1] /= fLen; vDir[2] /= fLen;
        }
        
        new Float:fDot = vForward[0]*vDir[0] + vForward[1]*vDir[1] + vForward[2]*vDir[2]
        
        // Угол конуса 45 градусов вокруг центра
        if (fDot >= WEAPON_P_CONE) {
            // Проверяем, не стоит ли зомби за бетонной стеной
            engfunc(EngFunc_TraceLine, vOrigin, tOrigin, IGNORE_MONSTERS, id, 0)
            new Float:flFraction
            get_tr2(0, TR_flFraction, flFraction)
            if (flFraction < 1.0) continue // Луч ударился в текстуру (стену)
            
            ExecuteHamB(Ham_TakeDamage, target, id, id, WEAPON_P_DMG, DMG_ENERGYBEAM | DMG_NEVERGIB)
            DrawBeamToPoint(id, tOrigin)
            bHitZombie = true
        }
    }
    
    // Если никого не задели, просто стреляем лучом прямо
    if (!bHitZombie) {
        new Float:vTarget[3]
        vTarget[0] = vOrigin[0] + vForward[0] * 4000.0
        vTarget[1] = vOrigin[1] + vForward[1] * 4000.0
        vTarget[2] = vOrigin[2] + vForward[2] * 4000.0
        
        engfunc(EngFunc_TraceLine, vOrigin, vTarget, DONT_IGNORE_MONSTERS, id, 0)
        
        new Float:vEnd[3]
        get_tr2(0, TR_vecEndPos, vEnd)
        DrawBeamToPoint(id, vEnd)
    }
}

public Task_EndModeB(taskid) {
    new id = taskid - TASK_ENDMODE
    if (!is_user_alive(id)) return
    
    new pWeapon = get_member(id, m_pActiveItem)
    if (!is_nullent(pWeapon) && IsCustomWeapon(pWeapon)) {
        EndModeB(id, pWeapon)
    } else {
        g_bModeB[id] = false
    }
}

// ==========================================
// [ ЛОГИКА Mode B И СНАРЯДОВ ]
// ==========================================
EndModeB(id, pWeapon) {
    g_bModeB[id] = false
    set_entvar(pWeapon, var_fuser1, 0.0)
    UpdateHUDAmmo2(id, 0)
    
    set_entvar(id, var_viewmodel, V_MODEL_A)
    SendWeaponAnim(id, ANIM_END)
    emit_sound(id, CHAN_WEAPON, SND_END, 1.0, ATTN_NORM, 0, PITCH_NORM)
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, 1.5)
    set_member(pWeapon, m_Weapon_flNextPrimaryAttack, 1.5)
    set_member(pWeapon, m_Weapon_flNextSecondaryAttack, 1.5)
}

FireModeBProjectile(id) {
    new ent = rg_create_entity("info_target")
    if (is_nullent(ent)) return
    
    set_entvar(ent, var_classname, CLASS_PROJ)
    set_entvar(ent, var_impulse, PROJ_IMPULSE)
    engfunc(EngFunc_SetModel, ent, PROJ_MODEL)
    
    new Float:vOrigin[3], Float:vAngles[3], Float:vFwd[3], Float:vViewOfs[3]
    get_entvar(id, var_origin, vOrigin)
    get_entvar(id, var_v_angle, vAngles)
    get_entvar(id, var_view_ofs, vViewOfs)
    
    angle_vector(vAngles, ANGLEVECTOR_FORWARD, vFwd)
    
    vOrigin[0] += vViewOfs[0] + vFwd[0] * 32.0
    vOrigin[1] += vViewOfs[1] + vFwd[1] * 32.0
    vOrigin[2] += vViewOfs[2] + vFwd[2] * 32.0
    
    set_entvar(ent, var_origin, vOrigin)
    
    set_entvar(ent, var_owner, id)
    set_entvar(ent, var_movetype, MOVETYPE_FLY)
    set_entvar(ent, var_solid, SOLID_TRIGGER) // Прохождение насквозь игроков
    set_entvar(ent, var_mins, Float:{-5.0, -5.0, -5.0})
    set_entvar(ent, var_maxs, Float:{5.0, 5.0, 5.0})
    
    set_entvar(ent, var_rendermode, kRenderTransAdd)
    set_entvar(ent, var_renderamt, 255.0)
    set_entvar(ent, var_sequence, 0)
    set_entvar(ent, var_animtime, get_gametime())
    set_entvar(ent, var_framerate, 1.5)
    
    new Float:vVel[3]
    vVel[0] = vFwd[0] * 1200.0
    vVel[1] = vFwd[1] * 1200.0
    vVel[2] = vFwd[2] * 1200.0
    set_entvar(ent, var_velocity, vVel)
    
    // Ориентируем нос модели строго по направлению полёта
    new Float:vProjAng[3]
    engfunc(EngFunc_VecToAngles, vFwd, vProjAng)
    set_entvar(ent, var_angles, vProjAng)
    
    // Блокируем вращение модели (avelocity = 0)
    set_entvar(ent, var_avelocity, Float:{0.0, 0.0, 0.0})
    
    set_entvar(ent, var_fuser1, get_gametime() + 4.0) // макс. жизнь
    set_entvar(ent, var_iuser1, 0) // Маска задетых игроков (пробитие)
    set_entvar(ent, var_nextthink, get_gametime() + 0.05)
    
    set_task(4.1, "Task_GuaranteeRemove", ent + 100000)
}

public OnInfoTargetThink_Pre(ent) {
    if (is_nullent(ent)) return HAM_IGNORED
    
    new iImpulse = get_entvar(ent, var_impulse)
    
    // Удаление эффекта попадания после анимации
    if (iImpulse == IMPACT_IMPULSE) {
        set_entvar(ent, var_flags, FL_KILLME)
        return HAM_SUPERCEDE
    }
    
    if (iImpulse == PROJ_IMPULSE) {
        new Float:flTime = GetEntFuser1(ent)
        if (get_gametime() >= flTime) {
            set_entvar(ent, var_flags, FL_KILLME)
            return HAM_SUPERCEDE
        }
        
        // --- АОЕ Урон во время полета ---
        new id = get_entvar(ent, var_owner)
        if (!is_user_connected(id)) {
            set_entvar(ent, var_flags, FL_KILLME)
            return HAM_SUPERCEDE
        }
        new Float:vOrigin[3]
        get_entvar(ent, var_origin, vOrigin)
        
        new iHitMask = get_entvar(ent, var_iuser1)
        
        for (new target = 1; target <= MaxClients; target++) {
            if (!is_user_alive(target) || id == target || !zp_get_user_zombie(target)) continue
            
            // Если уже получал урон от этого снаряда, пропускаем
            if (iHitMask & (1 << (target - 1))) continue
            
            new Float:tOrigin[3]
            get_entvar(target, var_origin, tOrigin)
            
            new Float:dx = vOrigin[0] - tOrigin[0]
            new Float:dy = vOrigin[1] - tOrigin[1]
            new Float:dz = vOrigin[2] - tOrigin[2]
            
            if (dx*dx + dy*dy + dz*dz <= WEAPON_S_RADIUS * WEAPON_S_RADIUS) {
                // Проверка препятствия между снарядом и целью
                engfunc(EngFunc_TraceLine, vOrigin, tOrigin, IGNORE_MONSTERS, ent, 0)
                new Float:flFraction
                get_tr2(0, TR_flFraction, flFraction)
                if (flFraction < 1.0) continue // За стеной
                
                // Отмечаем зомби
                iHitMask |= (1 << (target - 1))
                set_entvar(ent, var_iuser1, iHitMask) // сохраняем маску пробитых
                
                ExecuteHamB(Ham_TakeDamage, target, ent, id, WEAPON_S_DMG, DMG_ENERGYBEAM | DMG_NEVERGIB)
                
                // Отталкивание зомби по направлению полета снаряда
                new Float:vProjVel[3]
                get_entvar(ent, var_velocity, vProjVel)
                
                new Float:flLen = floatsqroot(vProjVel[0]*vProjVel[0] + vProjVel[1]*vProjVel[1] + vProjVel[2]*vProjVel[2])
                if (flLen > 0.0) {
                    new Float:vKnock[3]
                    vKnock[0] = (vProjVel[0] / flLen) * WEAPON_S_KNOCK
                    vKnock[1] = (vProjVel[1] / flLen) * WEAPON_S_KNOCK
                    vKnock[2] = (vProjVel[2] / flLen) * WEAPON_S_KNOCK + 150.0 // Приподнимаем
                    set_entvar(target, var_velocity, vKnock)
                }
            }
        }
        
        set_entvar(ent, var_nextthink, get_gametime() + 0.05)
        return HAM_SUPERCEDE
    }
    return HAM_IGNORED
}

public OnInfoTargetTouch_Pre(ent, touched) {
    if (is_nullent(ent)) return HAM_IGNORED
    if (get_entvar(ent, var_impulse) != PROJ_IMPULSE) return HAM_IGNORED
    
    // Удаляем снаряд только если он врезался в стену
    if (!is_user_alive(touched) && !is_user_connected(touched)) {
        set_entvar(ent, var_flags, FL_KILLME)
        return HAM_SUPERCEDE
    }
    
    // Если врезался в игрока, просто пролетает насквозь (так как SOLID_TRIGGER).
    // Урон и отталкивание наносятся в функции Think (АОЕ в радиусе).
    return HAM_SUPERCEDE
}

// ==========================================
// [ УТИЛИТЫ И СПРАЙТЫ ]
// Примечание: Спрайтовый код использует pev/set_pev,
// т.к. env_sprite — энтити FakeMeta-уровня (attachment, spawnflags, frame).
// ==========================================
stock SendWeaponAnim(id, iAnim) {
    set_entvar(id, var_weaponanim, iAnim)
    message_begin(MSG_ONE, SVC_WEAPONANIM, _, id)
    write_byte(iAnim)
    write_byte(0)
    message_end()
}

stock UpdateHUDAmmo2(id, iAmount) {
    message_begin(MSG_ONE, g_msgAmmoX, .player = id)
    write_byte(12) 
    write_byte(iAmount)
    message_end()
}

stock SendWeaponList(id, const wpnName[], pAmmoID, pAmmoMax, sAmmoID, sAmmoMax, slot, number, csw, flags) {
    message_begin(MSG_ONE, g_msgWeaponList, .player = id)
    write_string(wpnName)     
    write_byte(pAmmoID)       
    write_byte(pAmmoMax)      
    write_byte(sAmmoID)       
    write_byte(sAmmoMax)      
    write_byte(slot)          
    write_byte(number)        
    write_byte(csw)           
    write_byte(flags)         
    message_end()
}

// Универсальная функция создания Спрайтов у дула (MuzzleFlash и Лазер)
stock Weapon_SpriteAttached(const iPlayer, const szSprite[], const Float:flScale, const Float:flBrightness, const iAttachment) {
    if (global_get(glb_maxEntities) - engfunc(EngFunc_NumberOfEntities) < MIN_FREE_EDICTS) {
        return FM_NULLENT;
    }
    
    static iszAllocStringCached;
    if (!iszAllocStringCached) {
        iszAllocStringCached = engfunc(EngFunc_AllocString, "env_sprite");
    }
    new iSprite = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
    
    if (pev_valid(iSprite) != 2) return FM_NULLENT;
    
    set_pev(iSprite, pev_model, szSprite);
    set_pev(iSprite, pev_spawnflags, SF_SPRITE_ONCE);
    
    set_pev(iSprite, pev_classname, MUZZLE_CLASSNAME);
    set_pev(iSprite, pev_impulse, g_iszSpriteKey);
    set_pev(iSprite, pev_owner, iPlayer);
    
    // Привязываем ивент к attachment (дуло оружия)
    set_pev(iSprite, pev_aiment, iPlayer);
    set_pev(iSprite, pev_body, iAttachment);
    
    set_pev(iSprite, pev_rendermode, kRenderTransAdd);
    set_pev(iSprite, pev_renderamt, flBrightness);
    set_pev(iSprite, pev_renderfx, kRenderFxNone);
    set_pev(iSprite, pev_scale, flScale);
    
    dllfunc(DLLFunc_Spawn, iSprite);
    set_pev(iSprite, pev_nextthink, get_gametime() + 0.01);
    
    set_task(1.0, "Task_GuaranteeRemoveSprite", iSprite + 200000)
    
    return iSprite;
}

stock DrawBeamToPoint(id, Float:vEnd[3]) {
    // Получаем координаты игрока, чтобы луч гарантированно видели 
    // сам стрелок и все, кто находится рядом с ним
    new Float:vOrigin[3]
    get_entvar(id, var_origin, vOrigin)

    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0)
    write_byte(TE_BEAMENTPOINT)
    write_short(id | 0x1000) // start entity + attachment 1
    engfunc(EngFunc_WriteCoord, vEnd[0])
    engfunc(EngFunc_WriteCoord, vEnd[1])
    engfunc(EngFunc_WriteCoord, vEnd[2])
    write_short(g_iSpriteLaserId) // Sprite index
    write_byte(1) // start frame
    write_byte(35) // framerate
    write_byte(2) // life in 0.1s
    write_byte(120) // line width
    write_byte(0) // amplitude
    write_byte(255) // R
    write_byte(255) // G
    write_byte(255) // B
    write_byte(255) // Brightness
    write_byte(0) // scroll speed
    message_end()
}

public CSprite_Think_Pre(const iSprite) {
    new Float:flFrame;
    if (pev_valid(iSprite) != 2 || !CustomSprite(iSprite)) return HAM_IGNORED;
    
    if (pev(iSprite, pev_frame, flFrame) && ++flFrame - 1.0 < get_pdata_float(iSprite, m_maxFrame, 4)) {
        set_pev(iSprite, pev_frame, flFrame);
        set_pev(iSprite, pev_nextthink, get_gametime() + MUZZLE_TIME);
        return HAM_SUPERCEDE;
    }
    
    set_pev(iSprite, pev_flags, FL_KILLME);
    return HAM_SUPERCEDE;
}

// Эффект выстрела: спавнится у дула игрока
stock SpawnImpactEffect(id) {
    new ent = rg_create_entity("info_target")
    if (is_nullent(ent)) return
    
    new Float:vOrigin[3], Float:vViewOfs[3], Float:vFwd[3], Float:vAngles[3]
    get_entvar(id, var_origin, vOrigin)
    get_entvar(id, var_view_ofs, vViewOfs)
    get_entvar(id, var_v_angle, vAngles)
    angle_vector(vAngles, ANGLEVECTOR_FORWARD, vFwd)
    
    // Позиция: глаза игрока + 40 юнитов вперёд
    vOrigin[0] += vViewOfs[0] + vFwd[0] * 40.0
    vOrigin[1] += vViewOfs[1] + vFwd[1] * 40.0
    vOrigin[2] += vViewOfs[2] + vFwd[2] * 40.0
    
    engfunc(EngFunc_SetModel, ent, IMPACT_MODEL)
    set_entvar(ent, var_origin, vOrigin)
    
    // Ориентируем модель эффекта по направлению взгляда
    new Float:vProjAng[3]
    engfunc(EngFunc_VecToAngles, vFwd, vProjAng)
    set_entvar(ent, var_angles, vProjAng)
    
    set_entvar(ent, var_rendermode, kRenderTransAdd)
    set_entvar(ent, var_renderamt, 255.0)
    set_entvar(ent, var_sequence, 0)
    set_entvar(ent, var_animtime, get_gametime())
    set_entvar(ent, var_framerate, 1.0)
    set_entvar(ent, var_movetype, MOVETYPE_NONE)
    set_entvar(ent, var_solid, SOLID_NOT)
    
    set_entvar(ent, var_classname, "arcana_impact")
    set_entvar(ent, var_impulse, IMPACT_IMPULSE)
    set_entvar(ent, var_fuser1, get_gametime() + 1.0)
    set_entvar(ent, var_nextthink, get_gametime() + 1.0)
    
    set_task(1.1, "Task_GuaranteeRemove", ent + 100000)
}

public Task_GuaranteeRemove(taskid) {
    new ent = taskid - 100000
    if (is_nullent(ent)) return
    
    new iImpulse = get_entvar(ent, var_impulse)
    if (iImpulse == PROJ_IMPULSE || iImpulse == IMPACT_IMPULSE) {
        set_entvar(ent, var_flags, FL_KILLME)
    }
}

public Task_GuaranteeRemoveSprite(taskid) {
    new ent = taskid - 200000
    if (is_nullent(ent)) return
    
    if (CustomSprite(ent)) {
        set_pev(ent, pev_flags, FL_KILLME)
    }
}