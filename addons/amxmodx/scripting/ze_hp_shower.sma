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
#include <hamsandwich>
#include <zombieplague>

#define MAX_PLAYERS    32

// Integers
new g_iMaxPlayers
new g_iPlayerPos[MAX_PLAYERS+1]

// Bools
new bool:g_bIsConnected[33]
new const Float:g_flCoords[][] = 
{
    {0.15, -1.0},
    {0.20, -1.0},
    {0.25, -1.0},
    {0.30, -1.0},
    {0.35, -1.0},
    {0.40, -1.0},
    {0.35, -1.0},
    {0.30, -1.0},
    {0.25, -1.0},
    {0.20, -1.0}
}

// Macros
#define IsConnected(%1) (1 <= %1 <= g_iMaxPlayers && g_bIsConnected[%1])

#define PLUGIN_VERSION "0.1"
#define PLUGIN_AUTHOR "meTaLiCroSS"

public plugin_init() 
{
    register_plugin("[ZP] Addon: Zombie HP Displayer", PLUGIN_VERSION, PLUGIN_AUTHOR)
    
    RegisterHam(Ham_TakeDamage, "player", "fw_Player_TakeDamage_Post", 1)
    
    g_iMaxPlayers = get_maxplayers()
}

public client_putinserver(iId) g_bIsConnected[iId] = true
public client_disconnected(iId) g_bIsConnected[iId] = false

public fw_Player_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, iDamageType)
{
    if(!IsConnected(iAttacker) || iVictim == iAttacker)
        return HAM_IGNORED
    
    if(zp_get_user_zombie(iVictim))
    {
        new iVictimHealth = get_user_health(iVictim)
        if(1 <= iAttacker <= g_iMaxPlayers)
        {
            new iPos = ++g_iPlayerPos[iAttacker]
            if( iPos == sizeof(g_flCoords) )
            {
                iPos = g_iPlayerPos[iAttacker] = 0
            }
            set_hudmessage(0, 40, 80, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
            show_hudmessage(iAttacker, "%d", iVictimHealth)  
        }
    }
    
    return HAM_IGNORED
}