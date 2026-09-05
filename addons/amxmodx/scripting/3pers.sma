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
#include <engine>

#define PLUGIN    "3Rd view"
#define AUTHOR    "Ferrari & Sylvanor"
#define VERSION    "1.0"

#define MAX_PLAYERS 32

new g_pCamera

// pas besoin de taguer bool, fais comme tu veux cependant.
new g_bCamera[ MAX_PLAYERS + 1 ]

public plugin_precache() 
{      
	precache_model( "models/rpgrocket.mdl" ); 
}
public plugin_init()
{
    // register_plugin �a peut pas faire de mal non plus

    g_pCamera = register_cvar("amx_3rdview", "1")
    register_clcmd("say /3pers", "cmdCamera")
    register_clcmd("say_team /3pers", "cmdCamera")

}

public client_putinserver( id )
{
    g_bCamera[ id ] = false
}

public cmdCamera( id )
{
    if( get_pcvar_num( g_pCamera ) )
    {
        if( (g_bCamera[ id ] = !g_bCamera[ id ]) )
        {
            set_view( id, CAMERA_3RDPERSON )
        }
        else
        {
            set_view( id, CAMERA_NONE );
        }
    }
    return PLUGIN_HANDLED // PLUGIN_CONTINUE ou m�me rien du tout si tu veux pouvoir voir la commande dans le tchat.
}  