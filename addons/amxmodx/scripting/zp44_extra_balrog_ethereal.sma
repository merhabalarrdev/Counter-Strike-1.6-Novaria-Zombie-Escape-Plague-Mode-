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
#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >
#include < zombie_plague_v44 >

#define ITEM_NAME "[Balrog] Ethereal"
#define ITEM_COST "35"
#define ITEM_CLASS "4" // VIP menüsü için sınıf (class)

#define WEAPON_BITSUM ((1<<CSW_SCOUT) | (1<<CSW_XM1014) | (1<<CSW_MAC10) | (1<<CSW_AUG) | (1<<CSW_UMP45) | (1<<CSW_SG550) | (1<<CSW_UMP45) | (1<<CSW_FAMAS) | (1<<CSW_AWP) | (1<<CSW_MP5NAVY) | (1<<CSW_M249) | (1<<CSW_M3) | (1<<CSW_M4A1) | (1<<CSW_TMP) | (1<<CSW_G3SG1) | (1<<CSW_SG552) | (1<<CSW_AK47) | (1<<CSW_P90))

new const VERSION[] = "1.3";

new g_clipammo[33], g_has_balrog[33], g_iVipItemId, g_hamczbots, g_laserbeam_spr, g_event_balrog, g_primaryattack, cvar_balrog_damage_x, cvar_balrog_bpammo, cvar_balrog_shotspd, cvar_balrog_oneround, cvar_balrog_clip, cvar_botquota;

new const SHOT_SOUND[][] = {"weapons/ethereal_shoot.wav"}

new const BALROG_SOUNDS[][] = {"weapons/ethereal_reload.wav", "weapons/ethereal_idle1.wav", "weapons/ethereal_draw.wav"}

new const GUNSHOT_DECALS[] = {41, 42, 43, 44, 45}

new const V_BALROG_MDL[64] = "models/zombie_plague/v_balrog_ethereal.mdl";
new const P_BALROG_MDL[64] = "models/zombie_plague/p_balrog_ethereal.mdl";
new const W_BALROG_MDL[64] = "models/zombie_plague/w_balrog_ethereal.mdl";

// VIP Menu Integration Native
native novaria_vip_extra_items(name[], class[], cost[]);

public plugin_init()
{
	// Plugin Register
	register_plugin("[ZP:44] Extra Item: Balrog Ethereal", VERSION, "CrazY");

	// Extra Item Register (VIP Native kullanildi)
	g_iVipItemId = novaria_vip_extra_items(ITEM_NAME, ITEM_CLASS, ITEM_COST);

	// Cvars Register
	cvar_balrog_damage_x = register_cvar("zp_balrog_damage_x", "3.0");
	cvar_balrog_clip = register_cvar("zp_balrog_clip", "40");
	cvar_balrog_bpammo = register_cvar("zp_balrog_bpammo", "200");
	cvar_balrog_shotspd = register_cvar("zp_balrog_shot_speed", "0.11");
	cvar_balrog_oneround = register_cvar("zp_balrog_oneround", "0");

	// Cvar Pointer
	cvar_botquota = get_cvar_pointer("bot_quota");

	// Admin command
	register_concmd("zp_give_balrog", "cmd_give_balrog", 0);

	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");

	// Forwards
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1);
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1);
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent");
	register_forward(FM_SetModel, "fw_SetModel");

	// HAM Forwards
	RegisterHam(Ham_Item_PostFrame, "weapon_ump45", "fw_ItemPostFrame");
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_PrimaryAttack");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_PrimaryAttack_Post", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_ump45", "fw_ItemDeploy_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Item_AddToPlayer, "weapon_ump45", "fw_AddToPlayer");
}

public plugin_precache()
{
	precache_model(V_BALROG_MDL);
	precache_model(P_BALROG_MDL);
	precache_model(W_BALROG_MDL);
	g_laserbeam_spr = precache_model("sprites/laserbeam.spr");
	for(new i = 0; i < sizeof SHOT_SOUND; i++) precache_sound(SHOT_SOUND[i]);
	for(new i = 0; i < sizeof BALROG_SOUNDS; i++) precache_sound(BALROG_SOUNDS[i]);
}

public client_disconnected(id)
{
	g_has_balrog[id] = false;
}

public client_connect(id)
{
	g_has_balrog[id] = false;
}

public zp_user_humanized_post(id, human)
{
	g_has_balrog[id] = false;
}

public zp_user_infected_post(id)
{
	g_has_balrog[id] = false;
}

public client_putinserver(id)
{
	g_has_balrog[id] = false;

	if (is_user_bot(id) && !g_hamczbots && cvar_botquota)
	{
		set_task(0.1, "register_ham_czbots", id);
	}
}

public event_round_start()
{
	if (get_pcvar_num(cvar_balrog_oneround))
		for (new i = 1; i <= get_maxplayers(); i++) g_has_balrog[i] = false;
}

public register_ham_czbots(id)
{
	if (g_hamczbots || !is_user_bot(id) || !get_pcvar_num(cvar_botquota))
		return;

	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage");

	g_hamczbots = true;
}

// Yeni VIP Menu Item Secme Fonksiyonu
public novaria_item_selected(id, itemid)
{
	if (itemid == g_iVipItemId)
	{
		client_print(id, print_chat, "[ZP] You bought %s.", ITEM_NAME);
		command_give_balrog(id);
	}
}

public cmd_give_balrog(id, level, cid)
{
	if((get_user_flags(id) & level) != level)
	{
		return PLUGIN_HANDLED;
	}

	static arg[32], player;
	read_argv(1, arg, charsmax(arg));
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF));
	
	if (!player) return PLUGIN_HANDLED;

	client_print(player, print_chat, "[ZP] You won a %s.", ITEM_NAME);
	command_give_balrog(player);

	return PLUGIN_HANDLED;
}

public command_give_balrog(player)
{
	drop_primary(player);
	g_has_balrog[player] = true;
	new weaponid = give_item(player, "weapon_ump45");
	cs_set_weapon_ammo(weaponid, get_pcvar_num(cvar_balrog_clip));
	cs_set_user_bpammo(player, CSW_UMP45, get_pcvar_num(cvar_balrog_bpammo));
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if (is_user_alive(id) && get_user_weapon(id) == CSW_UMP45 && g_has_balrog[id])
	{
		set_cd(cd_handle, CD_flNextAttack, halflife_time () + 0.001);
	}
}

public fw_PrecacheEvent_Post(type, const name[])
{
	if (equal("events/ump45.sc", name))
	{
		g_event_balrog = get_orig_retval();
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_event_balrog) || !g_primaryattack)
		return FMRES_IGNORED;

	if (!(1 <= invoker <= get_maxplayers()))
    	return FMRES_IGNORED;

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2);
	return FMRES_SUPERCEDE;
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity) || !equal(model, "models/w_ump45.mdl")) return FMRES_IGNORED;
	
	static szClassName[33]; pev(entity, pev_classname, szClassName, charsmax(szClassName));
	if(!equal(szClassName, "weaponbox")) return FMRES_IGNORED;
	
	static owner, wpn;
	owner = pev(entity, pev_owner);
	wpn = find_ent_by_owner(-1, "weapon_ump45", entity);
	
	if(g_has_balrog[owner] && pev_valid(wpn))
	{
		g_has_balrog[owner] = false;
		set_pev(wpn, pev_impulse, 10992);
		engfunc(EngFunc_SetModel, entity, W_BALROG_MDL);
		
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}

public fw_AddToPlayer(wpn, id)
{
	if(pev_valid(wpn) && is_user_connected(id) && pev(wpn, pev_impulse) == 10992)
	{
		g_has_balrog[id] = true;
		set_pev(wpn, pev_impulse, 0);
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}

public fw_ItemPostFrame(weapon_entity)
{
	new id = pev(weapon_entity, pev_owner);

	if(!g_has_balrog[id] || !is_user_connected(id) || !pev_valid(weapon_entity))
		return HAM_IGNORED;

	static iClipExtra; iClipExtra = get_pcvar_num(cvar_balrog_clip);

	new Float:flNextAttack = get_pdata_float(id, 83, 5);

	new iBpAmmo = cs_get_user_bpammo(id, CSW_UMP45);
	new iClip = get_pdata_int(weapon_entity, 51, 4);

	new fInReload = get_pdata_int(weapon_entity, 54, 4);

	if(fInReload && flNextAttack <= 0.0)
	{
		new Clp = min(iClipExtra - iClip, iBpAmmo);
		set_pdata_int(weapon_entity, 51, iClip + Clp, 4);
		cs_set_user_bpammo(id, CSW_UMP45, iBpAmmo-Clp);
		set_pdata_int(weapon_entity, 54, 0, 4);
		fInReload = 0;

		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if (is_user_alive(iAttacker) && get_user_weapon(iAttacker) == CSW_UMP45 && g_has_balrog[iAttacker])
	{
	    static Float:flEnd[3];
	    get_tr2(ptr, TR_vecEndPos, flEnd);
	    if(iEnt)
	    {
	        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	        write_byte(TE_DECAL);
	        engfunc(EngFunc_WriteCoord, flEnd[0]);
	        engfunc(EngFunc_WriteCoord, flEnd[1]);
	        engfunc(EngFunc_WriteCoord, flEnd[2]);
	        write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)]);
	        write_short(iEnt);
	        message_end();
	    } else {
	        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	        write_byte(TE_WORLDDECAL);
	        engfunc(EngFunc_WriteCoord, flEnd[0]);
	        engfunc(EngFunc_WriteCoord, flEnd[1]);
	        engfunc(EngFunc_WriteCoord, flEnd[2]);
	        write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)]);
	        message_end();
	    }
	    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	    write_byte(TE_GUNSHOTDECAL);
	    engfunc(EngFunc_WriteCoord, flEnd[0]);
	    engfunc(EngFunc_WriteCoord, flEnd[1]);
	    engfunc(EngFunc_WriteCoord, flEnd[2]);
	    write_short(iAttacker);
	    write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)]);
	    message_end();
    }
}

public fw_PrimaryAttack(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4);

	if (g_has_balrog[id])
	{
		g_clipammo[id] = cs_get_weapon_ammo(weapon_entity);
		g_primaryattack = 1;
	}
}

public fw_PrimaryAttack_Post(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4);

	if (g_has_balrog[id] && g_clipammo[id])
	{
		g_primaryattack = 0;
		set_pdata_float(weapon_entity, 46, get_pcvar_float(cvar_balrog_shotspd), 4);
		emit_sound(id, CHAN_WEAPON, SHOT_SOUND[random_num(0, sizeof SHOT_SOUND - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		MAKE_LaserBeam(id, 7, 100, 0, 0);
		UTIL_PlayWeaponAnimation(id, random_num(3, 5));
	}
}

public fw_ItemDeploy_Post(weapon_entity)
{
	static id; id = get_weapon_ent_owner(weapon_entity);

	if (pev_valid(id) && g_has_balrog[id])
	{
		set_pev(id, pev_viewmodel2, V_BALROG_MDL);
		set_pev(id, pev_weaponmodel2, P_BALROG_MDL);
	}
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if(is_user_alive(attacker) && get_user_weapon(attacker) == CSW_UMP45 && g_has_balrog[attacker])
	{
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_balrog_damage_x));
	}
}

stock MAKE_LaserBeam(id, Size, R, G, B) 
{
    static End[3];
    get_user_origin(id, End, 3);	
	
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte (TE_BEAMENTPOINT);
    write_short( id |0x1000 );
    write_coord(End[0]);
    write_coord(End[1]);
    write_coord(End[2]);
    write_short(g_laserbeam_spr);
    write_byte(0);
    write_byte(1);
    write_byte(1);
    write_byte(Size);
    write_byte(4);
    write_byte(R);
    write_byte(G);
    write_byte(B);
    write_byte(255);
    write_byte(0);
    message_end();
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence);
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player);
	write_byte(Sequence);
	write_byte(pev(Player, pev_body));
	message_end();
}

stock get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, 41, 4);
}

stock give_item(index, const item[]) 
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

stock drop_primary(id)
{
	new weapons[32], num;
	get_user_weapons(id, weapons, num);
	for (new i = 0; i < num; i++)
	{
		if (WEAPON_BITSUM & (1<<weapons[i]))
		{
			static wname[32];
			get_weaponname(weapons[i], wname, sizeof wname - 1);
			engclient_cmd(id, "drop", wname);
		}
	}
}