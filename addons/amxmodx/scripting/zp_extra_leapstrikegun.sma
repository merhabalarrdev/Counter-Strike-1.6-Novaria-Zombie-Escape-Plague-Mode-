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
#include <hamsandwich>
#include <zombieplague>

// ReAPI is required
#include <reapi>

// To enable Abyss version, change 0 to 1
#define ABYSS_VERSION 0

#define PLUGIN "[ZP] Extra Item: Gravity Repulsor"
#define VERSION "1.0"
#define AUTHOR "Kolmi"

// ==========================================
// [ WEAPON CONFIGURATION & VIP MENU ]
// ==========================================
native novaria_vip_extra_items(name[], class[], cost[]);
new g_iVipItemId = -1;

#define WEAPON_NAME         "weapon_p228"
#define WEAPON_CSW          CSW_P228
#define WEAPON_IMPULSE      82031

// Ammo
#define WEAPON_AMMO         50
#define WEAPON_BPAMMO       250

// Damage & Speed
// Damage, Speed & Abilities
const Float: WEAPON_RATE          = 0.3;    // Fire rate
const Float: RELOAD_TIME          = 2.5;     // Reload time
const Float: PROJ_SPEED           = 1500.0;  // Projectile speed
const Float: PROJ_DAMAGE          = 500.0;   // Projectile direct hit damage

const Float: WAVE_DAMAGE          = 100.0;   // Primary attack Wave AoE damage

const Float: DASH_SPEED_FORWARD   = 400.0;   // Right click jump forward velocity
const Float: DASH_SPEED_UP        = 550.0;   // Right click jump upward velocity
const Float: GLIDE_SPEED_FORWARD  = 300.0;   // Glide speed after initial dash
const Float: SLAM_FALL_SPEED      = -800.0;  // Fall speed during slam (right click again)

const Float: JUMP_DAMAGE          = 250.0;   // Damage upon takeoff
const Float: JUMP_RADIUS          = 300.0;   // Takeoff AoE radius
const Float: JUMP_KNOCKBACK       = 500.0;   // Takeoff knockback

const Float: SLAM_DAMAGE          = 550.0;   // Damage upon landing slam
const Float: SLAM_RADIUS          = 200.0;   // Landing slam AoE radius
const Float: SLAM_KNOCKBACK       = 800.0;   // Landing slam knockback

const Float: SLAM_BLOCK_DMG_TIME  = 3.0;     // Fall damage immunity duration after landing

const Float: ENERGY_REGEN_RATE    = 1.0;     // Energy gained per tick
const Float: ENERGY_REGEN_INTERVAL= 0.25;    // Interval between energy regeneration ticks
const Float: ENERGY_GAIN_PER_HIT  = 10.0;    // Energy gained per zombie hit during slam

// ==========================================
// [ MODELS, SOUNDS, SPRITES ]
// ==========================================
#if ABYSS_VERSION == 1
    new const V_MODEL[]         = "models/repulsor_abyss/v_leapstrikegunex.mdl"
    new const P_MODEL[]         = "models/repulsor_abyss/p_leapstrikegunex.mdl"
    new const W_MODEL[]         = "models/repulsor_abyss/w_leapstrikegunex.mdl"

    new const SPR_PROJ[]        = "sprites/repulsor_abyss/ef_leapstrikegunex_projectile.spr"
    new const SPR_WAVE[]        = "sprites/repulsor_abyss/ef_leapstrikegunex_explo.spr"
    new const SPR_JUMP[]        = "sprites/repulsor_abyss/ef_leapstrikegunex_jump.spr"
    new const SPR_FLY[]         = "sprites/repulsor_abyss/ef_leapstrikegunex_fly.spr"
    new const SPR_LAND_EXPLO[]  = "sprites/repulsor_abyss/ef_leapstrikegunex_landexplo_ground.spr"
    new const SPR_HIT[]         = "sprites/repulsor_abyss/ef_leapstrikegunex_hit.spr"
    new const MDL_LANDING[]     = "models/repulsor_abyss/ef_leapstrikegunex_landing.mdl"
    
    new const SND_SHOOT[]       = "weapons/leapstrikegunex-1.wav"
    new const SND_FLY_START[]   = "weapons/leapstrikegun_change_fly_exp.wav"
    new const SND_FLY_IDLE[]    = "weapons/leapstrikegunex_change_fly_idle.wav"
    new const SND_FLY_LAND[]    = "weapons/leapstrikegunex-1_exp.wav"
    new const SND_CHANGE_START[]= "weapons/blaster_clipin.wav"
    new const SND_CHANGE_END[]  = "weapons/blaster_clipout.wav"
    new const SND_RELOAD_1[]    = "weapons/blaster_clipout.wav"
    new const SND_RELOAD_2[]    = ""
    new const SND_DRAW[]        = "weapons/blaster_clipin.wav"
    
    new const SPR_WPNLIST[]     = "sprites/weapon_leapstrikegunex.txt"
    new const SPR_WPNLIST_NAME[]= "weapon_leapstrikegunex"
    new const SPR_WPNLIST_HUD[] = "sprites/640hud255.spr"
#else
    new const V_MODEL[]         = "models/repulsor/vf_leapstrikegun.mdl"
    new const P_MODEL[]         = "models/repulsor/p_leapstrikegun.mdl"
    new const W_MODEL[]         = "models/repulsor/w_leapstrikegun.mdl"

    new const SPR_PROJ[]        = "sprites/repulsor/ef_leapstrikegun_projectile.spr"
    new const SPR_WAVE[]        = "sprites/repulsor/ef_leapstrikegun_explo.spr"
    new const SPR_JUMP[]        = "sprites/repulsor/ef_leapstrikegun_jump.spr"
    new const SPR_FLY[]         = "sprites/repulsor/ef_leapstrikegun_fly.spr"
    new const SPR_LAND_EXPLO[]  = "sprites/repulsor/ef_leapstrikegun_landexplo_ground.spr"
    new const SPR_HIT[]         = "sprites/repulsor/ef_leapstrikegun_hit.spr"
    new const MDL_LANDING[]     = "models/repulsor/ef_leapstrikegun_landing.mdl"
    
    new const SND_SHOOT[]       = "weapons/leapstrikegun1.wav"
    new const SND_FLY_START[]   = "weapons/leapstrikegun_change_fly_exp.wav"
    new const SND_FLY_IDLE[]    = "weapons/leapstrikegun_change_fly_idle.wav"
    new const SND_FLY_LAND[]    = "weapons/leapstrikegun1_exp.wav"
    new const SND_CHANGE_START[]= "weapons/leapstrikegun_change_end.wav"
    new const SND_CHANGE_END[]  = "weapons/leapstrikegun_change_end.wav"
    new const SND_RELOAD_1[]    = "weapons/leapstrikegun_reload1.wav"
    new const SND_RELOAD_2[]    = ""
    new const SND_DRAW[]        = "weapons/linkgun_draw.wav"

    new const SPR_WPNLIST[]     = "sprites/weapon_leapstrikegun.txt"
    new const SPR_WPNLIST_NAME[]= "weapon_leapstrikegun"
    new const SPR_WPNLIST_HUD[] = "sprites/640hud231.spr"
#endif

#if ABYSS_VERSION == 1
new const SPR_MUZZLEFLASH[] = "sprites/muzzleflash408.spr"
#endif

// Scale settings
#define FLY_SPRITE_SCALE    0.25 
#define MUZZLEFLASH_SCALE   0.08 

// ==========================================
// [ ENTITIES & CONSTANTS ]
// ==========================================
#define CLASS_PROJ          "leapstrike_proj"
#define PROJ_IMPULSE        82032
#define CLASS_WAVE          "leapstrike_wave"
#define WAVE_IMPULSE        82033
#define TASK_RELOAD_SOUND   102030

// Muzzle Flash
#define MUZZLE_TIME         0.06
#define MUZZLE_CLASSNAME    "ent_mf_leapstrike"
#define MUZZLE_INTOLERANCE  100
#define MUZZLE_ATTACHMENT   2 
#define m_maxFrame          35

#if ABYSS_VERSION == 1
enum {
    ANIM_IDLE = 1,
    ANIM_SHOOT = 2,
    ANIM_DRAW = 4,
    ANIM_RELOAD = 5,
    ANIM_CHANGE_START = 6,
    ANIM_CHANGE_END = 7,
    ANIM_CHANGE = 8,
    
    ANIM_CHANGE_SHOOT = 9,
    ANIM_CHANGE_DRAW = 11,
    ANIM_CHANGE_RELOAD = 12
}

#define FLY_SOUND_LOOP_TIME 1.95
#define WAVE_RADIUS          225.0   // Abyss - Wave AoE radius
#define WAVE_SCALE_START     1.0     // Abyss - Starting scale of the wave ring
#define WAVE_SCALE_END       2.0     // Abyss - Maximum scale (expansion end)
#define WAVE_SCALE_SPEED     0.3     // Abyss - Expansion speed
#define WAVE_FADE_SPEED      20.0    // Abyss - Fade out speed (lower = longer life)
#define WAVE_ANIMATED        1       // 1 = plays full animation, 0 = locks to 1 frame
#define PROJ_SCALE           0.25    // Abyss - Projectile size
#define HIT_SPRITE_SCALE     5       // Abyss - Hit sprite size
#define PROJ_OFS_FORWARD     32.0    // Abyss - Forward spawn offset
#define PROJ_OFS_RIGHT       6.0     // Abyss - Right spawn offset
#define PROJ_OFS_UP          -6.0    // Abyss - Up spawn offset
#define SECOND_RELOAD_SOUND_DELAY 1.0 // Abyss - Delay for second reload sound
#else
enum {
    ANIM_IDLE = 0,
    ANIM_CHANGE = 1,
    ANIM_SHOOT = 2,
    ANIM_CHANGE_SHOOT = 3,
    ANIM_DRAW = 6,
    ANIM_CHANGE_DRAW = 7,
    ANIM_RELOAD = 8,
    ANIM_CHANGE_RELOAD = 9,
    ANIM_CHANGE_START = 10,
    ANIM_CHANGE_END = 12
}

#define FLY_SOUND_LOOP_TIME 0.7
#define WAVE_RADIUS          270.0   // Normal - Wave AoE radius
#define WAVE_SCALE_START     2.5     // Normal - Starting scale of the wave ring
#define WAVE_SCALE_END       5.0     // Normal - Maximum scale (expansion end)
#define WAVE_SCALE_SPEED     0.3     // Normal - Expansion speed
#define WAVE_FADE_SPEED      25.0    // Normal - Fade out speed (higher = faster fade)
#define WAVE_ANIMATED        0       // 1 = plays full animation, 0 = locks to 1 frame
#define PROJ_SCALE           0.15    // Normal - Projectile size
#define HIT_SPRITE_SCALE     3       // Normal - Hit sprite size
#define PROJ_OFS_FORWARD     32.0    // Normal - Forward spawn offset
#define PROJ_OFS_RIGHT       12.0    // Normal - Right spawn offset
#define PROJ_OFS_UP          -12.0   // Normal - Up spawn offset
#define SECOND_RELOAD_SOUND_DELAY 1.0 // Normal - Delay for second reload sound
#endif

enum {
    STATE_NORMAL = 0,
    STATE_LEAPING,
    STATE_SLAMMING
}

new g_iRepulsorState[33]
new Float:g_flEnergy[33]
new bool:g_bEnergyFull[33]
new Float:g_flNextEnergyRegen[33]
new Float:g_flStateTimer[33]
new Float:g_flNextFlySound[33]
new g_iMsgAmmoX

new bool:g_bHasWeapon[33]

new g_iSprHit
new g_iMuzzleFlashKey
new bool:g_bIsTrackedEntity[2048]

// ==========================================
// [ INIT & PRECACHE ]
// ==========================================
public plugin_precache() {
    precache_model(V_MODEL)
    precache_model(P_MODEL)
    precache_model(W_MODEL)
    
    precache_model(SPR_PROJ)
    precache_model(SPR_WAVE)
    precache_model(SPR_JUMP)
    precache_model(SPR_FLY)
    precache_model(SPR_LAND_EXPLO)
    g_iSprHit = precache_model(SPR_HIT)
    precache_model(MDL_LANDING)
    
#if ABYSS_VERSION == 1
    precache_model(SPR_MUZZLEFLASH)
    g_iMuzzleFlashKey = engfunc(EngFunc_AllocString, MUZZLE_CLASSNAME)
#endif
    
    precache_model(SPR_WPNLIST_HUD)
    precache_generic(SPR_WPNLIST)
    
    precache_sound(SND_SHOOT)
    precache_sound(SND_FLY_START)
    precache_sound(SND_FLY_IDLE)
    precache_sound(SND_FLY_LAND)
    
    if (SND_CHANGE_START[0]) precache_sound(SND_CHANGE_START)
    if (SND_CHANGE_END[0]) precache_sound(SND_CHANGE_END)
    if (SND_RELOAD_1[0]) precache_sound(SND_RELOAD_1)
    if (SND_RELOAD_2[0]) precache_sound(SND_RELOAD_2)
    if (SND_DRAW[0]) precache_sound(SND_DRAW)
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    // Özel VIP menüye kayıt işlemi
    g_iVipItemId = novaria_vip_extra_items("Gravity Repulsor", "3", "650");
    
    RegisterHookChain(RG_CBasePlayer_Killed, "OnPlayerKilled_Pre", 0)
    RegisterHookChain(RG_CBasePlayer_AddPlayerItem, "OnAddPlayerItem_Post", 1)
    RegisterHookChain(RG_CWeaponBox_SetModel, "CWeaponBox_SetModel_Pre", 0)
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultReload, "CWeapon_DefaultReload_Pre", 0)

    RegisterHam(Ham_Item_Deploy, WEAPON_NAME, "OnItemDeploy_Post", 1)
    RegisterHam(Ham_Weapon_WeaponIdle, WEAPON_NAME, "OnWeaponIdle_Pre", 0)
    RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_NAME, "OnPrimaryAttack_Pre", 0)
    RegisterHam(Ham_Item_PostFrame, WEAPON_NAME, "OnItemPostFrame_Post", 1)
    
    RegisterHam(Ham_Touch, "info_target", "OnInfoTargetTouch_Pre", 0)
    RegisterHam(Ham_Think, "info_target", "OnInfoTargetThink_Pre", 0)
    RegisterHam(Ham_Think, "env_sprite", "CMuzzleFlash_Think_Pre", 0)
    RegisterHookChain(RG_CBasePlayer_PreThink, "OnPlayerPreThink", 0)
    
    // For blocking fall damage
    RegisterHookChain(RG_CBasePlayer_TakeDamage, "OnTakeDamage_Pre", 0)
    
    register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
    register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
    
    register_clcmd("weapon_leapstrikegun", "CmdWeaponSelect")
    register_clcmd("weapon_leapstrikegunex", "CmdWeaponSelect")
    
    g_iMsgAmmoX = get_user_msgid("AmmoX")
}

public CmdWeaponSelect(id) {
    engclient_cmd(id, WEAPON_NAME)
    return PLUGIN_HANDLED
}

// ==========================================
// [ WEAPON GIVING & MANAGEMENT ]
// ==========================================
public plugin_natives() {
    register_native("zp_give_user_leapstrikegun", "native_give_weapon", 1)
    register_native("zp_remove_user_leapstrikegun", "native_remove_weapon", 1)
}

public native_give_weapon(id) {
    if (!is_user_alive(id) || zp_get_user_zombie(id)) return false
    
    rg_drop_items_by_slot(id, PISTOL_SLOT)
    
    new pWeapon = rg_give_item(id, WEAPON_NAME, GT_APPEND)
    if (!is_nullent(pWeapon)) {
        set_entvar(pWeapon, var_impulse, WEAPON_IMPULSE)
        set_entvar(pWeapon, var_iuser3, WEAPON_BPAMMO)
        
        rg_set_iteminfo(pWeapon, ItemInfo_iMaxClip, WEAPON_AMMO)
        set_member(pWeapon, m_Weapon_iClip, WEAPON_AMMO)
        rg_set_user_bpammo(id, WeaponIdType:WEAPON_CSW, WEAPON_BPAMMO)
        rg_switch_weapon(id, pWeapon)
        ExecuteHamB(Ham_Item_Deploy, pWeapon)
        g_bHasWeapon[id] = true
        return true
    }
    return false
}

public native_remove_weapon(id) {
    if (!is_user_alive(id)) return false
    
    if (g_bHasWeapon[id]) {
        rg_remove_item(id, WEAPON_NAME)
        g_bHasWeapon[id] = false
        g_iRepulsorState[id] = STATE_NORMAL
        g_flEnergy[id] = 0.0
        g_bEnergyFull[id] = false
        UpdateEnergyHUD(id)
        RemoveFlyAura(id)
        emit_sound(id, CHAN_BODY, SND_FLY_IDLE, 0.0, 0.0, SND_STOP, PITCH_NORM)
        return true
    }
    return false
}

// Özel VIP menüden seçildiğinde silahı veren kısım
public novaria_item_selected(id, itemid) {
    if (itemid == g_iVipItemId) {
        native_give_weapon(id);
    }
}

stock bool:IsCustomWeapon(pWeapon) {
    if (is_nullent(pWeapon)) return false
    return (get_entvar(pWeapon, var_impulse) == WEAPON_IMPULSE)
}

public OnPlayerKilled_Pre(victim, attacker, shouldgib) {
    if (g_bHasWeapon[victim]) {
        g_bHasWeapon[victim] = false
    }
    g_iRepulsorState[victim] = STATE_NORMAL
    g_flEnergy[victim] = 0.0
    g_bEnergyFull[victim] = false
    UpdateEnergyHUD(victim)
    RemoveFlyAura(victim)
    emit_sound(victim, CHAN_BODY, SND_FLY_IDLE, 0.0, 0.0, SND_STOP, PITCH_NORM)
    
    return HC_CONTINUE
}

public zp_user_infected_post(id, infector, nemesis) {
    g_bHasWeapon[id] = false
    g_iRepulsorState[id] = STATE_NORMAL
    g_flEnergy[id] = 0.0
    g_bEnergyFull[id] = false
    UpdateEnergyHUD(id)
    RemoveFlyAura(id)
    emit_sound(id, CHAN_BODY, SND_FLY_IDLE, 0.0, 0.0, SND_STOP, PITCH_NORM)
}

public client_disconnected(id) {
    g_bHasWeapon[id] = false
    g_iRepulsorState[id] = STATE_NORMAL
    g_flEnergy[id] = 0.0
    g_bEnergyFull[id] = false
    RemoveFlyAura(id)
}

// ==========================================
// [ HUD & LISTS ]
// ==========================================
public OnAddPlayerItem_Post(id, pWeapon) {
    if (!is_user_alive(id)) {
        return HC_CONTINUE
    }
    if (IsCustomWeapon(pWeapon)) {
        g_bHasWeapon[id] = true
        new ammo = get_entvar(pWeapon, var_iuser3)
        if (ammo > 0) {
            rg_set_user_bpammo(id, WeaponIdType:WEAPON_CSW, ammo)
        }
        
        rg_set_iteminfo(pWeapon, ItemInfo_iMaxClip, WEAPON_AMMO)
        SendWeaponList(id, SPR_WPNLIST_NAME, 9, 250, 11, 100, 1, 3, WEAPON_CSW, 0)
    } else if (get_member(pWeapon, m_iId) == WEAPON_CSW) {
        SendWeaponList(id, "weapon_p228", 9, 52, -1, -1, 1, 3, WEAPON_CSW, 0)
    }
    return HC_CONTINUE
}

stock SendWeaponList(id, const szName[], iPrimaryAmmoType, iMaxPrimaryAmmo, iSecondaryAmmoType, iMaxSecondaryAmmo, iSlot, iPosition, iId, iFlags) {
    message_begin(MSG_ONE, get_user_msgid("WeaponList"), _, id)
    write_string(szName)
    write_byte(iPrimaryAmmoType)
    write_byte(iMaxPrimaryAmmo)
    write_byte(iSecondaryAmmoType)
    write_byte(iMaxSecondaryAmmo)
    write_byte(iSlot)
    write_byte(iPosition)
    write_byte(iId)
    write_byte(iFlags)
    message_end()
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle) {
    if (!is_user_alive(id) || !g_bHasWeapon[id]) return FMRES_IGNORED
    new pActive = get_member(id, m_pActiveItem)
    if (!is_nullent(pActive) && IsCustomWeapon(pActive)) {
        set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
        return FMRES_HANDLED
    }
    return FMRES_IGNORED
}

public CWeaponBox_SetModel_Pre(ent, const model[]) {
    if (!is_nullent(ent)) {
        for (new i = 0; i < 6; i++) {
            new pItem = get_member(ent, m_WeaponBox_rgpPlayerItems, i)
            if (!is_nullent(pItem) && IsCustomWeapon(pItem)) {
                new iOwner = get_entvar(ent, var_owner)
                if (iOwner >= 1 && iOwner <= MaxClients) {
                    g_bHasWeapon[iOwner] = false
                }
                
                SetHookChainArg(2, ATYPE_STRING, W_MODEL)
                return HC_CONTINUE
            }
        }
    }
    return HC_CONTINUE
}

// ==========================================
// [ DEPLOY, IDLE, RELOAD, POSTFRAME ]
// ==========================================
public OnItemDeploy_Post(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    if (!is_user_alive(id)) return HAM_IGNORED
    
    set_entvar(id, var_viewmodel, V_MODEL)
    set_entvar(id, var_weaponmodel, P_MODEL)
    
    SendWeaponAnim(id, g_bEnergyFull[id] ? ANIM_CHANGE_DRAW : ANIM_DRAW)
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, 1.0)
    set_member(pWeapon, m_Weapon_flNextPrimaryAttack, 1.0)
    set_member(pWeapon, m_Weapon_flNextSecondaryAttack, 1.0)
    
    rg_set_iteminfo(pWeapon, ItemInfo_iMaxClip, WEAPON_AMMO)
    new bpammo = rg_get_user_bpammo(id, WeaponIdType:WEAPON_CSW)

    if (bpammo > 0) set_entvar(pWeapon, var_iuser3, bpammo)
    
    SendWeaponList(id, SPR_WPNLIST_NAME, 9, 250, 11, 100, 1, 3, WEAPON_CSW, 0)
    
    UpdateEnergyHUD(id)
    return HAM_IGNORED
}

public OnWeaponIdle_Pre(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    if (get_member(pWeapon, m_Weapon_flTimeWeaponIdle) > 0.0) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    if (!is_user_alive(id)) return HAM_IGNORED
    
    if (g_bEnergyFull[id]) SendWeaponAnim(id, ANIM_CHANGE)
    else SendWeaponAnim(id, ANIM_IDLE)
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, 3.0)
    
    return HAM_SUPERCEDE
}

public OnItemPostFrame_Post(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    
    new bpammo = rg_get_user_bpammo(id, WeaponIdType:WEAPON_CSW)

    if (bpammo > 0) set_entvar(pWeapon, var_iuser3, bpammo)
    
    new iClip = get_member(pWeapon, m_Weapon_iClip)
    if (iClip > WEAPON_AMMO) {
        new diff = iClip - WEAPON_AMMO
        set_member(pWeapon, m_Weapon_iClip, WEAPON_AMMO)
        
        rg_set_user_bpammo(id, WeaponIdType:WEAPON_CSW, bpammo + diff)
        set_entvar(pWeapon, var_iuser3, bpammo + diff)
    }
    return HAM_IGNORED
}

public CWeapon_DefaultReload_Pre(const pWeapon, iClipSize, iAnim, Float:fDelay) {
    if (IsCustomWeapon(pWeapon)) {
        new id = get_member(pWeapon, m_pPlayer)
        SetHookChainArg(3, ATYPE_INTEGER, g_bEnergyFull[id] ? ANIM_CHANGE_RELOAD : ANIM_RELOAD)
        SetHookChainArg(4, ATYPE_FLOAT, Float:RELOAD_TIME)
        
        new Float:sndDelay = SECOND_RELOAD_SOUND_DELAY
        if (sndDelay > 0.0) {
            remove_task(id + TASK_RELOAD_SOUND)
            set_task(sndDelay, "Task_PlaySecondReloadSound", id + TASK_RELOAD_SOUND)
        }
        
        return HC_CONTINUE
    }
    return HC_CONTINUE
}

public Task_PlaySecondReloadSound(taskid) {
    new id = taskid - TASK_RELOAD_SOUND
    if (!is_user_alive(id) || !g_bHasWeapon[id]) return
    
    new pActive = get_member(id, m_pActiveItem)
    if (is_nullent(pActive) || !IsCustomWeapon(pActive)) return
    
    if (get_member(pActive, m_Weapon_flTimeWeaponIdle) > 0.0) {
        emit_sound(id, CHAN_ITEM, SND_RELOAD_1, 1.0, ATTN_NORM, 0, PITCH_NORM)
    }
}

// ==========================================
// [ PRIMARY ATTACK ]
// ==========================================
public OnPrimaryAttack_Pre(pWeapon) {
    if (!IsCustomWeapon(pWeapon)) return HAM_IGNORED
    
    new id = get_member(pWeapon, m_pPlayer)
    
    if (get_member(pWeapon, m_Weapon_flNextPrimaryAttack) > 0.0) return HAM_SUPERCEDE
    
    new iClip = get_member(pWeapon, m_Weapon_iClip)
    if (iClip <= 0) {
        ExecuteHam(Ham_Weapon_PlayEmptySound, pWeapon)
        set_member(pWeapon, m_Weapon_flNextPrimaryAttack, 0.2)
        return HAM_SUPERCEDE
    }
    
    set_member(pWeapon, m_Weapon_iClip, iClip - 1)
    
    SendWeaponAnim(id, g_bEnergyFull[id] ? ANIM_CHANGE_SHOOT : ANIM_SHOOT)
    emit_sound(id, CHAN_ITEM, SND_SHOOT, 1.0, ATTN_NORM, 0, PITCH_NORM)
    
    set_member(pWeapon, m_Weapon_flTimeWeaponIdle, WEAPON_RATE + 0.5)
    set_member(pWeapon, m_Weapon_flNextPrimaryAttack, WEAPON_RATE)
    set_member(pWeapon, m_Weapon_flNextSecondaryAttack, WEAPON_RATE)
    
    new Float:vPunch[3]
    vPunch[0] = random_float(-3.0, -1.0)
    vPunch[1] = random_float(-1.0, 1.0)
    set_entvar(id, var_punchangle, vPunch)
    
#if ABYSS_VERSION == 1
    Weapon_MuzzleFlash(id, SPR_MUZZLEFLASH, MUZZLEFLASH_SCALE, 255.0, MUZZLE_ATTACHMENT)
#endif
    
    FireProjectile(id)
    CreateWave(id)
    
    return HAM_SUPERCEDE
}

// ==========================================
// [ PROJECTILE & WAVE SPAWN ]
// ==========================================
FireProjectile(id) {
    new ent = rg_create_entity("info_target")
    if (is_nullent(ent)) return
    
    set_entvar(ent, var_classname, CLASS_PROJ)
    set_entvar(ent, var_impulse, PROJ_IMPULSE)
    engfunc(EngFunc_SetModel, ent, SPR_PROJ)
    
    new Float:vOrigin[3], Float:vAngles[3], Float:vFwd[3], Float:vRight[3], Float:vUp[3]
    get_entvar(id, var_origin, vOrigin)
    get_entvar(id, var_v_angle, vAngles)
    
    new Float:vViewOfs[3]
    get_entvar(id, var_view_ofs, vViewOfs)
    
    engfunc(EngFunc_MakeVectors, vAngles)
    global_get(glb_v_forward, vFwd)
    global_get(glb_v_right, vRight)
    global_get(glb_v_up, vUp)
    
    // Spawn a bit forward and to the right
    vOrigin[0] += vViewOfs[0] + vFwd[0] * PROJ_OFS_FORWARD + vRight[0] * PROJ_OFS_RIGHT + vUp[0] * PROJ_OFS_UP
    vOrigin[1] += vViewOfs[1] + vFwd[1] * PROJ_OFS_FORWARD + vRight[1] * PROJ_OFS_RIGHT + vUp[1] * PROJ_OFS_UP
    vOrigin[2] += vViewOfs[2] + vFwd[2] * PROJ_OFS_FORWARD + vRight[2] * PROJ_OFS_RIGHT + vUp[2] * PROJ_OFS_UP
    
    set_entvar(ent, var_origin, vOrigin)
    set_entvar(ent, var_owner, id)
    set_entvar(ent, var_movetype, MOVETYPE_FLY)
    set_entvar(ent, var_solid, SOLID_BBOX)
    set_entvar(ent, var_mins, Float:{-1.0, -1.0, -1.0})
    set_entvar(ent, var_maxs, Float:{1.0, 1.0, 1.0})
    
    set_entvar(ent, var_rendermode, kRenderTransAdd)
    set_entvar(ent, var_renderamt, 255.0)
    set_entvar(ent, var_scale, PROJ_SCALE)
    set_entvar(ent, var_frame, 0.0)
    
    new Float:vVel[3]
    vVel[0] = vFwd[0] * PROJ_SPEED
    vVel[1] = vFwd[1] * PROJ_SPEED
    vVel[2] = vFwd[2] * PROJ_SPEED
    set_entvar(ent, var_velocity, vVel)
    
    new Float:vProjAng[3]
    engfunc(EngFunc_VecToAngles, vFwd, vProjAng)
    set_entvar(ent, var_angles, vProjAng)
    
    set_entvar(ent, var_nextthink, get_gametime() + 0.05)
    set_entvar(ent, var_iuser1, 0) // 0 = moving, 1 = exploded
    set_entvar(ent, var_fuser1, get_gametime() + 5.0) // 5s max lifetime to prevent leaks
}

CreateWave(id) {
    new Float:vOrigin[3]
    get_entvar(id, var_origin, vOrigin)
    
    // Trace to ground
    new Float:vEnd[3]
    vEnd[0] = vOrigin[0]
    vEnd[1] = vOrigin[1]
    vEnd[2] = vOrigin[2] - 1000.0
    
    engfunc(EngFunc_TraceLine, vOrigin, vEnd, IGNORE_MONSTERS, id, 0)
    new Float:vGround[3]
    get_tr2(0, TR_vecEndPos, vGround)
    vGround[2] += 1.0 // Slight offset to prevent z-fighting
    
    new ent = rg_create_entity("info_target")
    if (!is_nullent(ent)) {
        set_entvar(ent, var_classname, CLASS_WAVE)
        set_entvar(ent, var_impulse, WAVE_IMPULSE)
        set_entvar(ent, var_owner, id) // Set owner for following logic
        g_bIsTrackedEntity[ent] = true
        engfunc(EngFunc_SetModel, ent, SPR_WAVE)
        set_entvar(ent, var_origin, vGround)
        set_entvar(ent, var_solid, SOLID_NOT)
        
        // Force server to treat entity as following player (prevents sprite disappearance bug)
        set_entvar(ent, var_movetype, MOVETYPE_FOLLOW)
        set_entvar(ent, var_aiment, id)
        
        // Angles to lay flat on the ground (only works for oriented sprites)
        new Float:vAng[3]
        vAng[0] = 90.0
        vAng[1] = 0.0
        vAng[2] = 0.0
        set_entvar(ent, var_angles, vAng)
        
        set_entvar(ent, var_rendermode, kRenderTransAdd)
        set_entvar(ent, var_renderamt, 255.0)
        set_entvar(ent, var_scale, WAVE_SCALE_START)
#if WAVE_ANIMATED == 1
        set_entvar(ent, var_frame, 0.0) // start full animation
#else
        set_entvar(ent, var_frame, 5.0) // 5 frame is the desired thin ring
#endif
        
        // Start think
        set_entvar(ent, var_nextthink, get_gametime() + 0.05)
    }
    
    DealWaveDamage(id)
}

DealWaveDamage(id) {
    new Float:vOrigin[3]
    get_entvar(id, var_origin, vOrigin)
    
    for (new target = 1; target <= MaxClients; target++) {
        if (!is_user_alive(target) || id == target) continue
        if (!zp_get_user_zombie(target)) continue
        
        new Float:tOrigin[3]
        get_entvar(target, var_origin, tOrigin)
        
        new Float:dx = vOrigin[0] - tOrigin[0]
        new Float:dy = vOrigin[1] - tOrigin[1]
        new Float:dz = vOrigin[2] - tOrigin[2]
        
        if (dx*dx + dy*dy + dz*dz <= WAVE_RADIUS * WAVE_RADIUS) {
            ExecuteHamB(Ham_TakeDamage, target, id, id, WAVE_DAMAGE, DMG_ENERGYBEAM | DMG_NEVERGIB)
        }
    }
}

// ==========================================
// [ PROJECTILE TOUCH & THINK ]
// ==========================================
public OnInfoTargetTouch_Pre(ent, id) {
    if (is_nullent(ent)) return HAM_IGNORED
    
    if (get_entvar(ent, var_impulse) == PROJ_IMPULSE) {
        if (get_entvar(ent, var_iuser1) == 1) return HAM_SUPERCEDE // Already exploded
        
        new owner = get_entvar(ent, var_owner)
        if (id == owner) return HAM_SUPERCEDE // Ignore owner
        
        // Stop the projectile
        set_entvar(ent, var_velocity, Float:{0.0, 0.0, 0.0})
        set_entvar(ent, var_movetype, MOVETYPE_NONE)
        set_entvar(ent, var_solid, SOLID_NOT)
        
        // Check sky
        new Float:vProjOrigin[3]
        get_entvar(ent, var_origin, vProjOrigin)
        new engFlags = engfunc(EngFunc_PointContents, vProjOrigin)
        if (engFlags == CONTENTS_SKY) {
            set_entvar(ent, var_flags, FL_KILLME)
            return HAM_SUPERCEDE
        }
        
        // Spawn hit sprite ALWAYS
        new Float:vOrigin[3]
        get_entvar(ent, var_origin, vOrigin)
        
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_EXPLOSION)
        engfunc(EngFunc_WriteCoord, vOrigin[0])
        engfunc(EngFunc_WriteCoord, vOrigin[1])
        engfunc(EngFunc_WriteCoord, vOrigin[2])
        write_short(g_iSprHit)
        write_byte(HIT_SPRITE_SCALE) // Scale
        write_byte(20) // Framerate
        write_byte(14) // TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES
        message_end()
        
        // Deal damage if it hit a zombie
        if (id >= 1 && id <= MaxClients && is_user_alive(id) && zp_get_user_zombie(id)) {
            ExecuteHamB(Ham_TakeDamage, id, owner, owner, PROJ_DAMAGE, DMG_ENERGYBEAM)
        }
        
        // Remove projectile immediately
        set_entvar(ent, var_flags, FL_KILLME)
        return HAM_SUPERCEDE
    }
    
    return HAM_IGNORED
}

public OnInfoTargetThink_Pre(ent) {
    if (is_nullent(ent)) return HAM_IGNORED
    
    new iImpulse = get_entvar(ent, var_impulse)
    
    if (iImpulse == 82035) {
        set_entvar(ent, var_flags, FL_KILLME)
        return HAM_SUPERCEDE
    }
    
    if (iImpulse == PROJ_IMPULSE) {
        new iState = get_entvar(ent, var_iuser1)
        if (iState == 0) {
            // Anti-leak: remove if alive for > 5 seconds without hitting anything
            new Float:flDieTime = get_entvar(ent, var_fuser1)
            if (get_gametime() > flDieTime) {
                set_entvar(ent, var_flags, FL_KILLME)
                return HAM_SUPERCEDE
            }
            
            // Moving animation
            new Float:frame = get_entvar(ent, var_frame)
            frame += 1.0
            if (frame > 255.0) frame = 0.0 // Assuming max frames, wrap around safely
            set_entvar(ent, var_frame, frame)
            set_entvar(ent, var_nextthink, get_gametime() + 0.05)
        }
    }
    else if (iImpulse == WAVE_IMPULSE) {
        new Float:scale = get_entvar(ent, var_scale)
        new Float:amt = get_entvar(ent, var_renderamt)
        new Float:frame = get_entvar(ent, var_frame)
        
        if (scale < WAVE_SCALE_END) {
            scale += WAVE_SCALE_SPEED
            if (scale > WAVE_SCALE_END) scale = WAVE_SCALE_END
        }
        
        amt -= WAVE_FADE_SPEED // Fade out speed
        
#if WAVE_ANIMATED == 1
        frame += 1.0 // Advance animation frame (will reach 25 frames)
#endif
        
        if (amt <= 0.0) {
            g_bIsTrackedEntity[ent] = false
            set_entvar(ent, var_flags, FL_KILLME)
            return HAM_SUPERCEDE
        }
        
#if WAVE_ANIMATED == 1
        if (frame > 255.0) frame = 0.0
#endif
        set_entvar(ent, var_frame, frame)
        set_entvar(ent, var_scale, scale)
        set_entvar(ent, var_renderamt, amt)
        set_entvar(ent, var_nextthink, get_gametime() + 0.05)
    }
    
    return HAM_IGNORED
}

// ==========================================
// [ ABILITIES & PRETHINK ]
// ==========================================
UpdateEnergyHUD(id) {
    if (!is_user_alive(id) || !g_bHasWeapon[id]) return
    new pActive = get_member(id, m_pActiveItem)
    if (is_nullent(pActive) || !IsCustomWeapon(pActive)) return

    message_begin(MSG_ONE, g_iMsgAmmoX, _, id)
    write_byte(11) // Ammo type
    write_byte(floatround(g_flEnergy[id]))
    message_end()
}

public OnPlayerPreThink(id) {
    if (!is_user_alive(id)) return HC_CONTINUE
    
    new Float:time = get_gametime()
    
    if (g_bHasWeapon[id] && g_iRepulsorState[id] == STATE_NORMAL && g_flEnergy[id] < 100.0) {
        if (time >= g_flNextEnergyRegen[id]) {
            g_flEnergy[id] += ENERGY_REGEN_RATE
            if (g_flEnergy[id] >= 100.0) {
                g_flEnergy[id] = 100.0
                g_bEnergyFull[id] = true
                new pActive = get_member(id, m_pActiveItem)
                if (!is_nullent(pActive) && IsCustomWeapon(pActive)) {
                    // Prevent interrupting reload or attack animations
                    if (get_member(pActive, m_Weapon_flNextPrimaryAttack) <= 0.1) {
                        SendWeaponAnim(id, ANIM_CHANGE_START)
                        set_member(pActive, m_Weapon_flTimeWeaponIdle, 1.0)
                    }
                }
            }
            g_flNextEnergyRegen[id] = time + ENERGY_REGEN_INTERVAL
            UpdateEnergyHUD(id)
        }
    }
    
    new iState = g_iRepulsorState[id]
    
    new buttons = get_entvar(id, var_button)
    new oldbuttons = get_entvar(id, var_oldbuttons)
    if ((buttons & IN_ATTACK2) && !(oldbuttons & IN_ATTACK2)) {
        if (g_bHasWeapon[id]) {
            new pActive = get_member(id, m_pActiveItem)
            if (!is_nullent(pActive) && IsCustomWeapon(pActive)) {
                if (iState == STATE_NORMAL && g_flEnergy[id] >= 100.0) {
                    g_flEnergy[id] = 0.0
                    g_bEnergyFull[id] = false
                    UpdateEnergyHUD(id)
                    
                    SendWeaponAnim(id, ANIM_CHANGE_END)
                    set_member(pActive, m_Weapon_flTimeWeaponIdle, 1.5)
                    set_member(pActive, m_Weapon_flNextPrimaryAttack, 1.5)
                    
                    g_iRepulsorState[id] = STATE_LEAPING
                    g_flStateTimer[id] = time + 5.0 // 5s flight
                    
                    new Float:vAng[3], Float:vFwd[3]
                    get_entvar(id, var_v_angle, vAng)
                    engfunc(EngFunc_MakeVectors, vAng)
                    global_get(glb_v_forward, vFwd)
                    
                    new Float:vel[3]
                    vel[0] = vFwd[0] * DASH_SPEED_FORWARD
                    vel[1] = vFwd[1] * DASH_SPEED_FORWARD
                    vel[2] = DASH_SPEED_UP
                    set_entvar(id, var_velocity, vel)
                    set_entvar(id, var_gravity, 0.0001) // start flying
                    
                    emit_sound(id, CHAN_ITEM, SND_FLY_START, 1.0, ATTN_NORM, 0, PITCH_NORM)
                    emit_sound(id, CHAN_BODY, SND_FLY_IDLE, 1.0, ATTN_NORM, 0, PITCH_NORM)
                    g_flNextFlySound[id] = time + FLY_SOUND_LOOP_TIME
                    
                    CreateFlyAura(id)
                    
                    new Float:vOrigin[3]
                    get_entvar(id, var_origin, vOrigin)
                    vOrigin[2] -= 36.0
                    
                    new entSpr = rg_create_entity("env_sprite")
                    if (!is_nullent(entSpr)) {
                        set_entvar(entSpr, var_classname, "ef_jump_spr")
                        engfunc(EngFunc_SetModel, entSpr, SPR_JUMP)
                        vOrigin[2] += 2.0
                        set_entvar(entSpr, var_origin, vOrigin)
                        new Float:vSprAng[3]
                        vSprAng[0] = 90.0
                        vSprAng[1] = 0.0
                        vSprAng[2] = 0.0
                        set_entvar(entSpr, var_angles, vSprAng)
                        set_entvar(entSpr, var_rendermode, kRenderTransAdd)
                        set_entvar(entSpr, var_renderamt, 255.0)
                        set_entvar(entSpr, var_scale, 1.0)
                        set_entvar(entSpr, var_framerate, 20.0)
                        set_entvar(entSpr, var_spawnflags, 3) // STARTON + ONCE
                        dllfunc(DLLFunc_Spawn, entSpr)
                    }
                    
                    DealAoEDamage(id, JUMP_RADIUS, JUMP_DAMAGE, JUMP_KNOCKBACK)
                }
                else if (iState == STATE_LEAPING) {
                    StartSlam(id)
                }
            }
        }
    }
    
    // Refresh iState in case it was changed above
    iState = g_iRepulsorState[id]
    
    if (iState != STATE_NORMAL) {
        if (iState == STATE_LEAPING) {
            set_entvar(id, var_gravity, 0.0001) // Zero gravity during 5s flight
            
            if (time >= g_flNextFlySound[id]) {
                emit_sound(id, CHAN_BODY, SND_FLY_IDLE, 1.0, ATTN_NORM, 0, PITCH_NORM)
                g_flNextFlySound[id] = time + FLY_SOUND_LOOP_TIME
            }
            
            // After 0.3s of initial dash, lock height and glide forward
            if (g_flStateTimer[id] - time < 4.7) {
                new Float:vAng[3], Float:vFwd[3]
                get_entvar(id, var_v_angle, vAng)
                engfunc(EngFunc_MakeVectors, vAng)
                global_get(glb_v_forward, vFwd)
                
                new Float:vel[3]
                vel[0] = vFwd[0] * GLIDE_SPEED_FORWARD
                vel[1] = vFwd[1] * GLIDE_SPEED_FORWARD
                vel[2] = 0.0 // lock Z velocity
                set_entvar(id, var_velocity, vel)
            }
            
            if (time >= g_flStateTimer[id]) {
                StartSlam(id)
            }
        }
        else if (iState == STATE_SLAMMING) {
            new Float:vel[3]
            get_entvar(id, var_velocity, vel)
            vel[2] = SLAM_FALL_SPEED
            set_entvar(id, var_velocity, vel)
            
            if (get_entvar(id, var_flags) & FL_ONGROUND) {
                DoLandingImpact(id)
            }
        }
    }
    return HC_CONTINUE
}

StartSlam(id) {
    g_iRepulsorState[id] = STATE_SLAMMING
    set_entvar(id, var_gravity, 1.0)
    RemoveFlyAura(id)
    emit_sound(id, CHAN_BODY, SND_FLY_IDLE, 0.0, 0.0, SND_STOP, PITCH_NORM)
}

DoLandingImpact(id) {
    g_iRepulsorState[id] = STATE_NORMAL
    set_entvar(id, var_gravity, 1.0)
    g_flStateTimer[id] = get_gametime() + SLAM_BLOCK_DMG_TIME
    
    emit_sound(id, CHAN_ITEM, SND_FLY_LAND, 1.0, ATTN_NORM, 0, PITCH_NORM)
    
    new Float:vOrigin[3]
    get_entvar(id, var_origin, vOrigin)
    vOrigin[2] -= 36.0
    
    new ent = rg_create_entity("info_target")
    if (!is_nullent(ent)) {
        set_entvar(ent, var_classname, "ef_landing_mdl")
        set_entvar(ent, var_solid, SOLID_NOT)
        engfunc(EngFunc_SetModel, ent, MDL_LANDING)
        set_entvar(ent, var_origin, vOrigin)
        set_entvar(ent, var_sequence, 0)
        set_entvar(ent, var_animtime, get_gametime())
        set_entvar(ent, var_framerate, 1.0)
        set_entvar(ent, var_impulse, 82035)
        set_entvar(ent, var_nextthink, get_gametime() + 2.0)
    }
    
    new expl = rg_create_entity("env_sprite")
    if (!is_nullent(expl)) {
        set_entvar(expl, var_classname, "ef_land_expl")
        engfunc(EngFunc_SetModel, expl, SPR_LAND_EXPLO)
        vOrigin[2] += 2.0
        set_entvar(expl, var_origin, vOrigin)
        new Float:vAng[3]
        vAng[0] = 90.0
        vAng[1] = 0.0
        vAng[2] = 0.0
        set_entvar(expl, var_angles, vAng)
        set_entvar(expl, var_rendermode, kRenderTransAdd)
        set_entvar(expl, var_renderamt, 255.0)
        set_entvar(expl, var_scale, 1.5)
        set_entvar(expl, var_framerate, 20.0)
        set_entvar(expl, var_spawnflags, 3)
        dllfunc(DLLFunc_Spawn, expl)
    }
    
    new hits = DealAoEDamage(id, SLAM_RADIUS, SLAM_DAMAGE, SLAM_KNOCKBACK)
    if (hits > 0) {
        g_flEnergy[id] += hits * ENERGY_GAIN_PER_HIT
        if (g_flEnergy[id] > 100.0) g_flEnergy[id] = 100.0
        UpdateEnergyHUD(id)
    }
}

DealAoEDamage(id, Float:radius, Float:damage, Float:knockback) {
    new hit_count = 0
    new Float:vOrigin[3]
    get_entvar(id, var_origin, vOrigin)
    
    for (new target = 1; target <= MaxClients; target++) {
        if (!is_user_alive(target) || id == target) continue
        if (!zp_get_user_zombie(target)) continue
        
        new Float:tOrigin[3]
        get_entvar(target, var_origin, tOrigin)
        
        new Float:dx = vOrigin[0] - tOrigin[0]
        new Float:dy = vOrigin[1] - tOrigin[1]
        new Float:dz = vOrigin[2] - tOrigin[2]
        new Float:dist = floatsqroot(dx*dx + dy*dy + dz*dz)
        if (dist < 1.0) dist = 1.0;
        
        if (dist <= radius) {
            ExecuteHamB(Ham_TakeDamage, target, id, id, damage, DMG_ENERGYBEAM | DMG_NEVERGIB)
            
            new Float:vDir[3]
            vDir[0] = dx / dist * -knockback
            vDir[1] = dy / dist * -knockback
            vDir[2] = 200.0 // knock up slightly
            set_entvar(target, var_velocity, vDir)
            hit_count++
        }
    }
    return hit_count
}

public OnTakeDamage_Pre(victim, inflictor, attacker, Float:damage, damage_bits) {
    if (damage_bits & DMG_FALL) {
        if (g_bHasWeapon[victim]) {
            new iState = g_iRepulsorState[victim]
            if (iState == STATE_SLAMMING || (iState == STATE_NORMAL && get_gametime() < g_flStateTimer[victim])) {
                SetHookChainReturn(ATYPE_INTEGER, 0)
                return HC_SUPERCEDE
            }
        }
    }
    return HC_CONTINUE
}

#define FLY_AURA_IMPULSE 82034
CreateFlyAura(id) {
    new ent = rg_create_entity("env_sprite")
    if (!is_nullent(ent)) {
        set_entvar(ent, var_classname, "ef_fly_aura")
        set_entvar(ent, var_impulse, FLY_AURA_IMPULSE)
        set_entvar(ent, var_owner, id)
        g_bIsTrackedEntity[ent] = true
        engfunc(EngFunc_SetModel, ent, SPR_FLY)
        set_entvar(ent, var_rendermode, kRenderTransAdd)
        set_entvar(ent, var_renderamt, 255.0)
        set_entvar(ent, var_scale, FLY_SPRITE_SCALE)
        set_entvar(ent, var_framerate, 20.0)
        set_entvar(ent, var_spawnflags, 1) // START_ON (looping)
        dllfunc(DLLFunc_Spawn, ent)
        
        set_entvar(ent, var_movetype, MOVETYPE_NONE)
    }
}

RemoveFlyAura(id) {
    new ent = -1
    while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "ef_fly_aura")) > 0) {
        if (!is_nullent(ent) && get_entvar(ent, var_owner) == id) {
            g_bIsTrackedEntity[ent] = false
            set_entvar(ent, var_flags, FL_KILLME)
        }
    }
}


public fw_AddToFullPack_Post(es, e, ent, host, hostflags, player, pSet) {
    if (player || !g_bIsTrackedEntity[ent]) return FMRES_IGNORED
    
    new impulse = get_entvar(ent, var_impulse)
    if (impulse == WAVE_IMPULSE || impulse == FLY_AURA_IMPULSE) {
        new id = get_entvar(ent, var_owner)
        if (id >= 1 && id <= MaxClients && is_user_alive(id)) {
            new Float:vOrigin[3]
            get_entvar(id, var_origin, vOrigin)
            
            new flags = get_entvar(id, var_flags)
            if (flags & FL_DUCKING) {
                vOrigin[2] -= 18.0
            } else {
                vOrigin[2] -= 36.0
            }
            vOrigin[2] += 1.0 // Легкий отступ от пола
            
            set_es(es, ES_Origin, vOrigin)
            
            // Фиксируем углы
            new Float:vAng[3]
            vAng[0] = 90.0
            vAng[1] = 0.0
            vAng[2] = 0.0
            set_es(es, ES_Angles, vAng)
            
            // Отключаем интерполяцию клиента
            set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NOINTERP)
        }
    } else {
        g_bIsTrackedEntity[ent] = false
    }
    return FMRES_IGNORED
}

stock SendWeaponAnim(id, iAnim) {
    set_entvar(id, var_weaponanim, iAnim)
    message_begin(MSG_ONE, SVC_WEAPONANIM, _, id)
    write_byte(iAnim)
    write_byte(0)
    message_end()
}

// ==========================================
// [ MUZZLEFLASH HELPER (KORD) ]
// ==========================================
#define CustomMuzzle(%0) (pev(%0, pev_impulse) == g_iMuzzleFlashKey)
#define Sprite_SetScale(%0,%1) set_pev(%0, pev_scale, %1)

stock Sprite_SetTransparency(const iSprite, const iRendermode, const Float: flAmt, const iFx = kRenderFxNone)
{
	set_pev(iSprite, pev_rendermode, iRendermode);
	set_pev(iSprite, pev_renderamt, flAmt);
	set_pev(iSprite, pev_renderfx, iFx);
}

stock Weapon_MuzzleFlash(const iPlayer, const szMuzzleSprite[], const Float: flScale, const Float: flBrightness, const iAttachment)
{
	if (global_get(glb_maxEntities) - engfunc(EngFunc_NumberOfEntities) < MUZZLE_INTOLERANCE)
	{
		return FM_NULLENT;
	}
	
	static iSprite, iszAllocStringCached;
	if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "env_sprite")))
	{
		iSprite = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
	}
	
	if(pev_valid(iSprite) != 2)
	{
		return FM_NULLENT;
	}
	
	set_pev(iSprite, pev_model, szMuzzleSprite);
	set_pev(iSprite, pev_spawnflags, SF_SPRITE_ONCE);
	
	set_pev(iSprite, pev_classname, MUZZLE_CLASSNAME);
	set_pev(iSprite, pev_impulse, g_iMuzzleFlashKey);
	set_pev(iSprite, pev_owner, iPlayer);
	
	set_pev(iSprite, pev_aiment, iPlayer);
	set_pev(iSprite, pev_body, iAttachment);
	
	Sprite_SetTransparency(iSprite, kRenderTransAdd, flBrightness);
	Sprite_SetScale(iSprite, flScale);
	
	dllfunc(DLLFunc_Spawn, iSprite)

	return iSprite;
}

public CMuzzleFlash_Think_Pre(const iSprite)
{
	static Float: flFrame;
	
	if (pev_valid(iSprite) != 2 || !CustomMuzzle(iSprite))
	{
		return HAM_IGNORED;
	}
	
	if (pev(iSprite, pev_frame, flFrame) && ++flFrame - 1.0 < get_pdata_float(iSprite, m_maxFrame, 4))
	{
		set_pev(iSprite, pev_frame, flFrame);
		set_pev(iSprite, pev_nextthink, get_gametime() + MUZZLE_TIME);
		
		return HAM_SUPERCEDE;
	}

	set_pev(iSprite, pev_flags, FL_KILLME);
	return HAM_SUPERCEDE;
}