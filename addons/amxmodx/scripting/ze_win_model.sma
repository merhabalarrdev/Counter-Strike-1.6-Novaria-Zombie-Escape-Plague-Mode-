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
#include <zombieplague>

new Hands[33], MaxPlayers, ChekUserHands

// Normal Models
new const MODELS[3][] =
{
	"",
	"models/zombie_plague/novaria_zombie2_win.mdl",
	"models/zombie_plague/novaria_human2_win.mdl"
}

// Fliped Models
new const MODELS_FLIP[3][] =
{
	"",
	"models/zombie_plague/novaria_zombie2_winf.mdl",
	"models/zombie_plague/novaria_human2_winf.mdl"
}

new g_iModelIndex[3], g_iModelIndexFlip[3], g_iWinTeam

public plugin_init()
{
	register_plugin("[ZP] Sub-Plugin: New Win Messages", "1.4", "Shidla / xPaw / 93()|29!/<" )
	register_event("HLTV", "EventRoundStart", "a", "1=0", "2=0" )
	register_event("CurWeapon", "EventCurWeapon", "be", "1=1")

	MaxPlayers = get_maxplayers()

	ChekUserHands = register_cvar("zp_new_win_msg_chek" , "1")
}

public plugin_precache()
{
	for (new i = WIN_ZOMBIES; i <= WIN_HUMANS; i++)
	{
		// Normal Models
		precache_model(MODELS[i])
		g_iModelIndex[i] = engfunc(EngFunc_AllocString, MODELS[i])

		// Fliped Models
		precache_model(MODELS_FLIP[i])
		g_iModelIndexFlip[i] = engfunc(EngFunc_AllocString, MODELS_FLIP[i])
	}
}

public client_connect(id)
{
	if(!is_user_bot(id) && get_pcvar_num (ChekUserHands))
		query_client_cvar(id , "cl_righthand" , "Hands_CVAR_Value")
}

public Hands_CVAR_Value(id, const cvar[], const value[])
{
	if((1 <= id <= MaxPlayers) && get_pcvar_num (ChekUserHands))
		Hands[id] = str_to_num(value)
}

public client_disconnected(id)
{
	if(get_pcvar_num (ChekUserHands))
		Hands[id] = 0
}

public zp_round_ended(iTeam)
{
	if (iTeam == WIN_NO_ONE)
		return
	g_iWinTeam = iTeam
	new iPlayers[32], iNum
	get_players(iPlayers, iNum, "ch")
	
	for (new i; i < iNum; i++)
	{
		if(get_pcvar_num (ChekUserHands))
			client_cmd(iPlayers[i], "cl_righthand ^"1^"")
		
		if (get_user_weapon(iPlayers[i]) != CSW_KNIFE)
			set_pev(iPlayers[i], pev_viewmodel, g_iModelIndexFlip[iTeam])
		else
			set_pev(iPlayers[i], pev_viewmodel, g_iModelIndex[iTeam])
	}
}

public EventRoundStart()
{
	g_iWinTeam = WIN_NO_ONE
	
	if(get_pcvar_num (ChekUserHands))
	{
		for (new i = 1; i <= MaxPlayers; i++)
		{
			if(!is_user_connected(i))
				continue
			
			client_cmd(i, "cl_righthand ^"%d^"", Hands[i])
		}
	}
}

public EventCurWeapon(const id)
{
	if (g_iWinTeam > WIN_NO_ONE)
	{
		if (get_pcvar_num (ChekUserHands))
			client_cmd(id, "cl_righthand ^"1^"")
		
		if (get_user_weapon(id) != CSW_KNIFE)
			set_pev(id, pev_viewmodel, g_iModelIndexFlip[g_iWinTeam])
		else
			set_pev(id, pev_viewmodel, g_iModelIndex[g_iWinTeam])
	}
}