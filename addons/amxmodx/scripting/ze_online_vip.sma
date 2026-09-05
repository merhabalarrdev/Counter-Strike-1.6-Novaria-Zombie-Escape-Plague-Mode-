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

/*---------------EDIT ME------------------*/
#define ADMIN_CHECK ADMIN_RESERVATION

static const COLOR[] = "^x04" //green
/*----------------------------------------*/

new maxplayers
new gmsgSayText

public plugin_init() {
	register_plugin("/vips", "1.0", "DPCS")
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	register_clcmd("say", "handle_say")
}

public handle_say(id) {
	new said[192]
	read_args(said,192)
	if( ( containi(said, "who") != -1 && containi(said, "admin") != -1 ) || contain(said, "/vips") != -1 )
		set_task(0.1,"print_adminlist",id)
	return PLUGIN_CONTINUE
}

public print_adminlist(user) 
{
	new adminnames[33][32]
	new message[256]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & ADMIN_CHECK)
				get_user_name(id, adminnames[count++], 31)

	len = format(message, 255, "%s Online VIP: ",COLOR)
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				print_message(user, message)
				len = format(message, 255, "%s ",COLOR)
			}
		}
		print_message(user, message)
	}
	else {
		len += format(message[len], 255-len, "No Online VIP.")
		print_message(user, message)
	}
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}