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
#include <amxmisc>
#include <reapi>
#include <nvault>
#include <fakemeta>
#include <regex>
#include <hamsandwich>
#include <zombieplague>
new const szFlag = ADMIN_BAN

#define szCoinTime 15
#define szMaxLevel 33


// ==================== VIP / ROL FLAGLERI ====================
#define Novaria_VIP_FLAG_VIP        ADMIN_LEVEL_A
#define Novaria_VIP_FLAG_SILVER     ADMIN_LEVEL_B
#define Novaria_VIP_FLAG_GOLD       ADMIN_LEVEL_C
#define Novaria_VIP_FLAG_DIAMOND    ADMIN_LEVEL_D
#define Novaria_VIP_FLAG_PREMIUM    ADMIN_LEVEL_E
#define Novaria_VIP_FLAG_YONETICI   ADMIN_LEVEL_F
#define Novaria_VIP_FLAG_ADMIN      ADMIN_LEVEL_H
#define Novaria_VIP_SINIF_KLASIK    0
#define Novaria_VIP_SINIF_VIP       1
#define Novaria_VIP_SINIF_SILVER    2
#define Novaria_VIP_SINIF_GOLD      3
#define Novaria_VIP_SINIF_DIAMOND   4
#define Novaria_VIP_SINIF_PREMIUM   5
#define Novaria_MAX_VIP_ITEM 64
#define Novaria_UNVAN_SAYISI 8
#define Novaria_TUM_STATUS_MASK (Novaria_VIP_FLAG_VIP|Novaria_VIP_FLAG_SILVER|Novaria_VIP_FLAG_GOLD|Novaria_VIP_FLAG_DIAMOND|Novaria_VIP_FLAG_PREMIUM|Novaria_VIP_FLAG_YONETICI|Novaria_VIP_FLAG_ADMIN)
#define Novaria_FULL_ACCESS(%1) (g_iNovariaRol[%1] == 1 || g_iNovariaRol[%1] == 2)
#define Novaria_MAX_ZOMBIE_ITEM 32

#define Novaria_DIL_TR 0
#define Novaria_DIL_EN 1
#define Novaria_DIL_KO 2

#define MUTLUSAAT_KAT_COIN  0
#define MUTLUSAAT_KAT_XP    1
#define MUTLUSAAT_KAT_KASMA 2

#define NUM_KUYRUK_SPR 23
#define TASKID_KUYRUK 88001
#define KUYRUK_TICK 0.1
#define KUYRUK_LIFE 2
#define KUYRUK_MAXDIST 300

#define MAX_KOSTUM 40
#define MAX_KANAT 24
#define MAX_EXTRA_BICAK 60

#define Novaria_SND_EQUIP        0
#define Novaria_SND_INFORMATION  1
#define Novaria_SND_MENU         2
#define Novaria_SND_WAIT         3
#define Novaria_SND_ZPLRS_MENU   4
#define Novaria_SND_ODULBILME    5

#define HUD_RENK_RGB 5
#define HUD_KONUM_VARSAYILAN 0

// ==================== YONETICI PANEL / 관리자 패널 ====================
#define Novaria_YONETICI_SIFRE "1234" //panel sifresi
#define Novaria_ROL_TASK_BASE 9000
#define MSGMODE_TASK_BASE 9750
#define MSGMODE_SURE_TASK_BASE 9850
#define Novaria_YETKI_SURE_MAX_GUN 3650

// ==================== DIGER / 다른 ====================
#define SF_SNOW_STARTOFF 1
new const szNovariaVipEtiket[][] = { "", "VIP", "Silver VIP", "Gold VIP", "Diamond VIP", "Premium VIP" };
new const szNovariaVipMenuAdiKey[][] = { "NOVARIA_TITLE_EXTRAESYAPLATFORMU", "NOVARIA_TITLE_VIPSINIF_1", "NOVARIA_TITLE_VIPSINIF_2", "NOVARIA_TITLE_VIPSINIF_3", "NOVARIA_TITLE_VIPSINIF_4", "NOVARIA_TITLE_VIPSINIF_5" };
new const szNovariaVipSinifUnvanEslesme[6] = { 0, 7, 6, 5, 4, 3 };
new g_szNovariaVipItemAdi[Novaria_MAX_VIP_ITEM][64];
new g_iNovariaVipItemSinif[Novaria_MAX_VIP_ITEM];
new g_iNovariaVipItemFiyat[Novaria_MAX_VIP_ITEM];
new g_iNovariaVipItemPlugin[Novaria_MAX_VIP_ITEM];
new g_iNovariaVipItemSayi = 0;
new g_szNovariaZombieItemAdi[Novaria_MAX_ZOMBIE_ITEM][64];
new g_iNovariaZombieItemFiyat[Novaria_MAX_ZOMBIE_ITEM];
new g_iNovariaZombieItemPlugin[Novaria_MAX_ZOMBIE_ITEM];
new g_iNovariaZombieItemSayi = 0;
new const szNovariaDilAdi[3][] = { "Turkce", "English", "Korean" };
new const szNovariaDilKodu[3][3] = { "tr", "en", "ko" };
stock sNovariaSetClientLang(const IP_IDs, const szLangKodu[]) {
	new iInfoBuffer = engfunc(EngFunc_GetInfoKeyBuffer, IP_IDs);
	engfunc(EngFunc_SetClientKeyValue, IP_IDs, iInfoBuffer, "lang", szLangKodu);
}
new const szOyunModuAdi[12][32] = {
	"", "Infection", "Nemesis", "Assassin", "Survivor", "Sniper",
	"Swarm", "Multi Infection", "Plague", "Armageddon", "Apocalypse", "Nightmare"
};
new const szOyunModuKomut[12][16] = {
	"", "zp_zombie", "zp_nemesis", "zp_assassin", "zp_survivor", "zp_sniper",
	"zp_swarm", "zp_multi", "zp_plague", "zp_armageddon", "zp_apocalypse", "zp_nightmare"
};
new const bool:szOyunModuHedefli[12] = {
	false, true, true, true, true, true,
	false, false, false, false, false, false
};
new const szOyunModuMinOyuncu[12] = {
	0,
	4,
	5,
	5,
	5,
	4,
	6,
	6,
	6,
	8,
	8,
	8
};
#pragma unused szOyunModuMinOyuncu
new g_bOtomatikOyunModu = false;
new g_iOtomatikSecilenMod = 0;
new g_iTekOyuncuSecilenMod = 0;
new g_iMutluSaatCarpanManuel = 0;
new bool:g_bMutluSaatZorlaKapali = false;
new g_szAktifModAdi[32] = "";
new bool:g_bEnfeksiyonBasladi = false;
new bool:g_bMutluSaatKatCoin = true;
new bool:g_bMutluSaatKatXP = true;
new bool:g_bMutluSaatKatKasma = true;

enum _:IPTags {
	SayTag,
	MenuTag,
	KisaTag
}
new szTag[IPTags][64] = {
	"^3[rAs]",
	"rAs",
	"rAs"
};
// Sinif adlari artik sabit Turkce metin degil, dil dosyasindaki key'lere isaret ediyor (TR/EN/KO).
// 클래스 이름은 이제 고정된 터키어 텍스트가 아니라 언어 파일의 키를 참조합니다 (터키어/영어/한국어).
new const szSinifAdiKey[][] = { "NOVARIA_SINIF_SECILMEDI", "NOVARIA_SINIF_KLASIK", "NOVARIA_SINIF_CELIK", "NOVARIA_SINIF_AVCI", "NOVARIA_SINIF_MUTANT" };
enum _:NovariaTemalar {
	sTemaUzun[128],
	sTemaKisa[128],
	sTemaAd[128]
}
// ==================== Yönetici Panelindeki Seçilebilen Temalar / 관리자 패널에서 선택 가능한 테마 ====================
new const szNovariaTema[][NovariaTemalar] = {
	{"\d( \rNovaria Gaming \d) \y~> \w","\r[\ynVr\r] \d~> \w","V3 Tema"},
	{"\d[ \r- \wNovaria Gaming \r- \d] \d-\w","\d[ \r- \wnVr \r- \d] \d-\y","Tema 1"},
	{"\w[\rNovaria Gaming\w] \w~\r> \w","\w[\rnVr\w] \w~\r> \w","Tema 2"},
	{"\r(\w>\yNovaria Gaming\w<\r) \d~ \w","\r(\w>\ynVr\w<\r) \d~ \w","Tema 3"},
	{"\w|\y-\rNovaria Gaming\y-\w| \d~ \y","\w|-\rnVr\w-| \d~\w> \y","Tema 4"},
	{"\rNovaria Gaming \y• \w","\rnVr \y• \w","Tema 5"},
	{"\d[\yNovaria Gaming\d] \rX \w","\d[\ynVr\d] \rX \w","Tema 6"},
	{"\w[\rNovaria Gaming\w] \d@ \w","\w(\rnVr\w) \d@ \y","Tema 7"},
	{"\w[\yNovaria Gaming\w] \d@ \w","\w(\ynVr\w) \d@ \y","Tema 8"},
	{"\w[\y•\r Novaria Gaming \w•] \y->", "\w[\y• \rnVr \y•] \y-> \y", "Tema 9"},
	{"\w[\r{Novaria Gaming}\w] \d@ \w","\w(\r{nVr}\w) \d@ \y","Tema 10"},
	{"\w[\y{Novaria Gaming}\w] \d@ \w","\w(\y{nVr}\w) \d@ \y","Tema 11"},
	{"\w[\y•\r {Novaria Gaming} \w•] \y->", "\w[\y• \r{nVr} \y•] \y-> \y", "Tema 12"}
};
new g_iNovariaTemaAktif = 1;
new const szHumans[][] = { { "" }, { "zpusermodel" }  };
new const szChatSay[] = "^x01{DEAD}^x03[^x04{LEVEL} - {XPLABEL} {XP}^x03] ^x03[^x04{YETKI}^x03] ^x03{NAME}^x01: {FLAG}{MESSAGE}";
new const szReady[][] = {
	"countdown/novaria_s1.mp3",
	"countdown/novaria_s2.mp3",
	"countdown/novaria_s3.mp3",
	"countdown/novaria_s4.mp3",
	"countdown/novaria_s5.mp3",
	"countdown/novaria_s6.mp3",
	"countdown/novaria_s7.mp3"
};

new const szRoundEndSongs[][] = {
	"roundend/novaria_end1.mp3",
	"roundend/novaria_end2.mp3"
};
new g_iSonRoundEndSound = -1;

#define Novaria_ROUNDEND_SES_SURESI 15.0 // Round sonu sarki(lar)inizin gercek suresine gore bu degeri ayarlayin (saniye) / 라운드 종료 시점에 재생되는 곡의 실제 길이에 맞춰 이 값(초 단위)을 조정하세요.
#define TASKID_ROUNDEND_SES_BITTI 9600
new bool:g_bRoundSonuSesiCaliyor = false;

new const szCountDown[][] = {
    "countdown/zpgrs_01.wav",
    "countdown/zpgrs_02.wav",
    "countdown/zpgrs_03.wav",
    "countdown/zpgrs_04.wav",
    "countdown/zpgrs_05.wav",
    "countdown/zpgrs_06.wav",
    "countdown/zpgrs_07.wav",
    "countdown/zpgrs_08.wav",
    "countdown/zpgrs_09.wav",
    "countdown/zpgrs_10.wav"
};
new const szDovizKur[][2] = {
	{10, 15},
	{20, 25},
	{30, 35},
	{40, 45},
	{70, 75},
	{80, 85},
	{90, 100},
	{200, 320}
};

new const szLevel[] = {
    0, 50, 110, 170, 250, 330, 420, 520, 620, 740,
    860, 990, 1130, 1270, 1430, 1590, 1760, 1940, 2120, 2320,
    2520, 2730, 2950, 3170, 3410, 3650, 3900, 4160, 4420, 4700,
    4980, 5270, 5570
};

new const szKuyrukSpr[NUM_KUYRUK_SPR][] = {
	"sprites/novaria_ze/nvr_trail/elektirik.spr",
	"sprites/novaria_ze/nvr_trail/gokkusagi.spr",
	"sprites/novaria_ze/nvr_trail/sis.spr",
	"sprites/novaria_ze/nvr_trail/uzay.spr",
	"sprites/novaria_ze/nvr_trail/zincir.spr",
	"sprites/novaria_ze/nvr_trail/ball.spr",       
	"sprites/novaria_ze/nvr_trail/biohazard.spr",  
	"sprites/novaria_ze/nvr_trail/bulut.spr",       
	"sprites/novaria_ze/nvr_trail/yildiz.spr",       
	"sprites/novaria_ze/nvr_trail/gecemavisi.spr",   
	"sprites/novaria_ze/nvr_trail/gezegen.spr",      
	"sprites/novaria_ze/nvr_trail/gunes.spr",       
	"sprites/novaria_ze/nvr_trail/smile.spr",       
	"sprites/novaria_ze/nvr_trail/letters.spr",    
	"sprites/novaria_ze/nvr_trail/kartanesi.spr",   
	"sprites/novaria_ze/nvr_trail/lego.spr",         
	"sprites/novaria_ze/nvr_trail/love.spr",       
	"sprites/novaria_ze/nvr_trail/serit.spr",        
	"sprites/novaria_ze/nvr_trail/minecraft.spr",    
	"sprites/novaria_ze/nvr_trail/pembeled.spr",     
	"sprites/novaria_ze/nvr_trail/rgb.spr",          
	"sprites/novaria_ze/nvr_trail/beyazkurt.spr",    
	"sprites/novaria_ze/nvr_trail/son.spr",          
};
new const g_iKuyrukSprSize[NUM_KUYRUK_SPR]       = { 10, 10, 10, 10, 10,  10, 10, 10, 10,  10, 10, 10, 10, 10,  10, 10, 10, 10,  10, 10, 10, 10, 10 };
new const g_iKuyrukSprBright[NUM_KUYRUK_SPR]     = { 255,255,255,255,255,  255,255,255,255,255,  255,255,255,255,  255,255,255,255,255 };
new const g_iKuyrukSprColor[NUM_KUYRUK_SPR][3]   = { {255,255,255},{255,255,255},{200,200,200},{150,150,255},{180,180,180},
	{255,255,255},{255,255,255},{255,255,255},{255,255,255}, {255,215,0},{255,215,0},{255,215,0},{255,215,0},{255,215,0}, {150,220,255},{150,220,255},{150,220,255},{150,220,255}, {255,0,255},{255,0,255},{255,0,255},{255,0,255},{255,0,255} };
new g_iKuyrukSpr[NUM_KUYRUK_SPR];
// Her VIP sinifi (SILVER/SVIP, GOLD, DIAMOND, PREMIUM) icin ayrilan deneme trail sayisinin g_iKuyrukSpr icindeki baslangic indexi
new const g_iYPTrailBase[6] = { -1, -1, 5, 9, 14, 18 }; // index: Novaria_VIP_SINIF_* (KLASIK/VIP kullanilmaz)
// Her sinifa ait deneme trail adedi (SVIP=4, GOLD=5, DIAMOND=4, PREMIUM=5)
new const g_iYPTrailCount[6] = { 0, 0, 4, 5, 4, 5 };
new const szYPTrailAdKey[6][5][] = {
    { "", "", "", "", "" },
    { "", "", "", "", "" },
    { "NOVARIA_KUYRUK_YP_SVIP_1", "NOVARIA_KUYRUK_YP_SVIP_2", "NOVARIA_KUYRUK_YP_SVIP_3", "NOVARIA_KUYRUK_YP_SVIP_4", "" },
    { "NOVARIA_KUYRUK_YP_GOLD_1", "NOVARIA_KUYRUK_YP_GOLD_2", "NOVARIA_KUYRUK_YP_GOLD_3", "NOVARIA_KUYRUK_YP_GOLD_4", "NOVARIA_KUYRUK_YP_GOLD_5" },
    { "NOVARIA_KUYRUK_YP_DIAMOND_1", "NOVARIA_KUYRUK_YP_DIAMOND_2", "NOVARIA_KUYRUK_YP_DIAMOND_3", "NOVARIA_KUYRUK_YP_DIAMOND_4", "" },
    { "NOVARIA_KUYRUK_YP_PREMIUM_1", "NOVARIA_KUYRUK_YP_PREMIUM_2", "NOVARIA_KUYRUK_YP_PREMIUM_3", "NOVARIA_KUYRUK_YP_PREMIUM_4", "NOVARIA_KUYRUK_YP_PREMIUM_5" }
};
new g_iYPTrailAktif[MAX_PLAYERS + 1]; 
new g_iKuyrukTaskId[33];
new g_iKuyrukPos[33][3];
new g_iKuyrukIdle[33];
KuyrukTrailBaslat(const id, const iSprIndex) {
	if(iSprIndex < 0 || iSprIndex >= NUM_KUYRUK_SPR) return;
	KuyrukTrailDurdur(id);
	get_user_origin(id, g_iKuyrukPos[id]);
	g_iKuyrukIdle[id] = 0;
	set_task(KUYRUK_TICK, "KuyrukCheckPos", TASKID_KUYRUK+id, "", 0, "b");
	KuyrukMsgGonder(id, iSprIndex);
	g_iKuyrukTaskId[id] = iSprIndex+1;
}
KuyrukTrailDurdur(const id) {
	if(task_exists(TASKID_KUYRUK+id)) remove_task(TASKID_KUYRUK+id);
	KuyrukMsgKill(id);
	g_iKuyrukTaskId[id] = 0;
}
KuyrukMsgKill(const id) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(99);
	write_short(id);
	message_end();
}
KuyrukMsgGonder(const id, const iSprIndex) {
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(22);
	write_short(id);
	write_short(g_iKuyrukSpr[iSprIndex]);
	write_byte(KUYRUK_LIFE*10);
	write_byte(g_iKuyrukSprSize[iSprIndex]);
	write_byte(g_iKuyrukSprColor[iSprIndex][0]);
	write_byte(g_iKuyrukSprColor[iSprIndex][1]);
	write_byte(g_iKuyrukSprColor[iSprIndex][2]);
	write_byte(g_iKuyrukSprBright[iSprIndex]);
	message_end();
}
public KuyrukCheckPos(const iTaskId) {
	new id = iTaskId - TASKID_KUYRUK;
	if(!is_user_alive(id) || !g_iKuyrukTaskId[id]) { KuyrukTrailDurdur(id); return; }
	new origin[3];
	get_user_origin(id, origin);
	if(origin[0]!=g_iKuyrukPos[id][0] || origin[1]!=g_iKuyrukPos[id][1] || origin[2]!=g_iKuyrukPos[id][2]) {
		if(get_distance(origin, g_iKuyrukPos[id]) > KUYRUK_MAXDIST || g_iKuyrukIdle[id] >= floatround(KUYRUK_LIFE/KUYRUK_TICK)/2) {
			KuyrukMsgKill(id);
			KuyrukMsgGonder(id, g_iKuyrukTaskId[id]-1);
		}
		g_iKuyrukPos[id][0] = origin[0]; g_iKuyrukPos[id][1] = origin[1]; g_iKuyrukPos[id][2] = origin[2];
		g_iKuyrukIdle[id] = 0;
	} else if(g_iKuyrukIdle[id] < floatround(KUYRUK_LIFE/KUYRUK_TICK)) {
		g_iKuyrukIdle[id]++;
	}
}
new const szKuyruk[][][] = { { "", "", 0, 0 },
        {"Elektrik Kuyruk", "1", 100,1},{"Gokkusagi Kuyruk", "2", 250,1},
        {"Sis Kuyruk", "3", 350,1},{"Uzay Kuyruk", "4", 500,1},{"Zincir Kuyruk", "5", 750,1}
};
new szKostum[MAX_KOSTUM][5][48];
new g_iKostumSayi = 1;
new const szDeathEffect[][][] = { { "", "", 0 },
	    {"Kuru Kafa","sprites/ZPLEffect/normal_kill.spr",1000},{"Lol Face","sprites/ZPLEffect/lolfacenew.spr",1500},
	    {"Hero","sprites/ZPLEffect/heroicon.spr",5000},{"Kan Delisi","sprites/ZPLEffect/blip3.spr",5500},{"Portal","sprites/ZPLEffect/blip4.spr",5700},
	    {"Zombi Ruhu","sprites/ZPLEffect/blip6.spr",6000},{"Azrail","sprites/ZPLEffect/death_god.spr",6500},{"Hayalet Avcisi","sprites/ZPLEffect/ghost_exp.spr",6800},
	    {"Olum Kuru Kafasi","sprites/ZPLEffect/skull.spr",7000},{"Nukler Bomba","sprites/ZPLEffect/spota.spr",7600}
};
new szKanat[MAX_KANAT][5][48];
new g_iKanatSayi = 1;
new const szKnife[][][] = {
    { "", "", 0, "" },
    { "Default", "models/zp_knife_v6/zp_defaultbicak.mdl", 0, "" },
    { "Juz \r[\y5 Lv.\r]", "models/novaria_ze/novaria_knife/v_juz.mdl", 5, "" },
    { "Axe \r[\y10 Lv.\r]", "models/novaria_ze/novaria_knife/v_axe.mdl", 10, "" },
    { "Axe WareWolf \r[\y15 Lv.\r]", "models/novaria_ze/novaria_knife/v_axe_werewolf.mdl", 15, "" },
    { "Machetetrans \r[\y20 Lv.\r]", "models/novaria_ze/novaria_knife/v_machetetrans.mdl", 20, "" },
    { "Sekira Blood \r[\y26 Lv.\r]", "models/novaria_ze/novaria_knife/v_sekira_blood.mdl", 26, "" },
    { "JD Sekira Blood \r[\y33 Lv.\r]", "models/novaria_ze/novaria_knife/v_jd_blood.mdl", 33, "" }
};
new const szBicakNormal[][][] = {
    { "", "", 0, "" },
    { "Blue", "models/novaria_ze/novaria_knife/v_02blue.mdl", 0, "" },
    { "Razor", "models/novaria_ze/novaria_knife/v_03razor.mdl", 0, "" },
    { "Katana", "models/novaria_ze/novaria_knife/v_04katana.mdl", 0, "" },
    { "Axe", "models/novaria_ze/novaria_knife/v_05axe.mdl", 0, "" },
    { "Daggers", "models/novaria_ze/novaria_knife/v_06daggers.mdl", 0, "" },
    { "Dual Axe", "models/novaria_ze/novaria_knife/v_07dualaxe.mdl", 0, "" },
    { "Bayonet", "models/novaria_ze/novaria_knife/v_08bayonet.mdl", 0, "" },
    { "Skeleton", "models/novaria_ze/novaria_knife/v_09skeleton.mdl", 0, "" },
    { "Crowbar", "models/novaria_ze/novaria_knife/v_10crowbar.mdl", 0, "" },
};
new const szBicakVip[][][] = {
    { "", "", 0, "" },
    { "Vip Deneme Model", "models/novaria_ze/novaria_knife/v_01_fps.mdl", 0, "" },
    { "Vip Deneme Model", "models/novaria_ze/novaria_knife/v_02_karambit.mdl", 0, "" },
    { "Vip Deneme Model", "models/novaria_ze/novaria_knife/v_03_galaxy.mdl", 0, "" },
};
new const szBicakSVip[][][] = {
    { "", "", 0, "" },
};
new const szBicakGoldVip[][][] = {
    { "", "", 0, "" },
    { "Gold Vip Deneme Model", "models/novaria_ze/novaria_knife/v_10_daedric.mdl", 0, "" },  
};
new const szBicakDiamondVip[][][] = {
    { "", "", 0, "" },
    { "Diamond Vip Deneme Model", "models/novaria_ze/novaria_knife/v_05_horseaxe.mdl", 0, "" }, 
};
new const szBicakPremiumVip[][][] = {
    { "", "", 0, "" },
    { "Premium Vip Deneme Model", "models/novaria_ze/novaria_knife/v_06_hammer.mdl", 0, "" }, 
};
new g_iExtraBicakSayi = 0
new g_szExtraBicakAd[MAX_EXTRA_BICAK+1][32]
new g_szExtraBicakGive[MAX_EXTRA_BICAK+1][32]
new g_szExtraBicakRemove[MAX_EXTRA_BICAK+1][32]
new g_iExtraBicakFiyat[MAX_EXTRA_BICAK+1]

new const szSoundEffect[6][] = {
        "novaria_ze/novaria_effect/zpl_equip.wav",   // 0 - Novaria_SND_EQUIP
        "novaria_ze/novaria_effect/information.wav", // 1 - Novaria_SND_INFORMATION
        "novaria_ze/novaria_effect/zpl_menu.wav",    // 2 - Novaria_SND_MENU
        "novaria_ze/novaria_effect/zpl_menu.wav",    // 3 - Novaria_SND_WAIT (ayri dosya yok, zpl_menu.wav ile paylasiyor)
        "novaria_ze/novaria_effect/zplrs_menu.wav",  // 4 - Novaria_SND_ZPLRS_MENU
        "novaria_ze/novaria_effect/odulbilme.wav"    // 5 - Novaria_SND_ODULBILME
};
new const szLevelUpSound[] = "zpl_sound/zplrs_levelup.wav";
// [TR] BUGFIX / KALDIRILDI: szLevelUpSprite (sprites/zplrs_level/levelupkirmizi.spr)
// ve g_iLevelUpSprite (model index) artik kullanilmiyor - level atlayinca
// gorunen sprite ozelligi tamamen kaldirildi, sadece szLevelUpSound (ses)
// calmaya devam ediyor. Bkz. @sGetPlayerLevelUP.
// [KO] 버그수정 / 제거됨: szLevelUpSprite (sprites/zplrs_level/levelupkirmizi.spr)
// 및 g_iLevelUpSprite (모델 인덱스)는 더 이상 사용되지 않습니다. 레벨업 시
// 표시되던 스프라이트 기능이 완전히 제거되었으며, szLevelUpSound(사운드)만
// 계속 재생됩니다. @sGetPlayerLevelUP 참고.
new Float:g_fHumanCelikArmor;
new Float:g_fHumanAvciHiz;
new Float:g_fHumanMutantGravity;
new Float:g_fNightstalkerHiz;
new Float:g_fHeroHiz;
new Float:g_fHeroKalkan;
new const szHudRenkAdi[][] = { "Kirmizi","Yesil","Mavi","Sari","Beyaz","RGB" };
#pragma unused szHudRenkAdi
new const szHudRenkRGB[][3] = {
        {255,20,20},{20,255,20},{20,20,255},{255,255,20},{255,255,255},{255,255,255}
};
new const szSisRenkAdi[][] = { "Kirmizi","Yesil","Mavi","Sari","Mor","Camgobegi","Turuncu","Pembe","Siyah","Beyaz" };
#pragma unused szSisRenkAdi
new const szSisRenkRGB[][3] = {
        {255,0,0},{0,255,0},{0,0,255},{255,255,0},{160,32,240},
        {0,255,255},{255,140,0},{255,105,180},{0,0,0},{255,255,255}
};
new g_iMsgFog;
new const szHudKonumAdi[][] = { "Sol Ust","Ust Orta","Sag Ust","Sol Orta","Orta","Sag Orta","Sol Alt","Alt Orta","Sag Alt" };
#pragma unused szHudKonumAdi
new const Float:szHudKonumXY[][2] = {
        {0.0, 0.13}, {-1.0, 0.05}, {0.75, 0.13},
        {0.0, 0.45}, {-1.0, 0.45}, {0.75, 0.45},
        {0.0, 0.75}, {-1.0, 0.80}, {0.75, 0.75}
};
enum _: szNormals {
           sCoin,sPlayerValue,sPlayerIndex,
           sLevel,sXP,sKnifeID,sMapEngel,
           sSettingsOption[7],sGorevCtKill,sGorevInfectEt,
           sGorevPanzehir,sGorevSureliOyna,sGorevRoundOyna,
           sPlayerIndex2,sVipMapEngel,
           sTurSay,sJump,sYonlendirici,sGoingUID,sKuyrukID,sKuyrukID2,sKostumID,sKostumID2,
           sEffectID,sMapEngel2,sWingID,sKanat,sMapEngel3,sClassValue,
           sMapEngelNemesis,sNemesisClassValue,
           sMapEngelHero,
           sHudRenk,sHudKonum,
           sSisRenk,sSisYogunluk,
           sDilID,
           sHeroClassValue,sZombieClassSaved,
           sBicakKaynak,sNormalBicakID,sExtraBicakAktifID,sExtraBicakSahiplik,
           sVipBicakID
}
enum _: szGlobals {
           sVault,sVaultMenu,sTeamInfo,sSayText,
           sHud,sHud2,sHud3,sAnswer,sCountDown,sCountDownSound,
           Float:sVelocity,sRandomColor
}
enum _: szBools {
           sBlockMsg,sGizle,
           sGorev1,sGorev2,sGorev4,
           sGorev5,sSetting,sSetting2,sHudDurum,
           sHideAllModels,sHideTeamModelsOnly,
           sSisAktif,sBekliyorSifre,sBekliyorSure,
           sSesMenuAktif,sSesLevelAktif,sSesGeriSayimAktif,sSesModAktif,
           sHeroKacak,sHeroHizlanma,sHeroKalkan,
           sSinifKaydiInsan,sSinifKaydiZombi,sSinifKaydiHero,sSinifKaydiNemesis,
           sExtraBicakAktif
}
native set_lights(const Lighting[]);
native get_user_maxlevel(const IP_IDs);
native zp_open_zclass_menu(id);
native zp_get_extra_items_count();
native zp_get_extra_item_info(itemid, name[], namelen, &cost, &team);
new IP_IDszAnt[MAX_CLIENTS+1][szNormals],IP_IDsGlobal[szGlobals],bool:IP_IDsBool[MAX_CLIENTS+1][szBools],IP_IDsCvar[32],bool:IP_IDsKuyrukKaydet[MAX_CLIENTS+1][sizeof(szKuyruk)+1],bool:IP_IDsKostumKaydet[MAX_CLIENTS+1][MAX_KOSTUM+1],IP_IDsUserName[MAX_CLIENTS+1][33],
bool:IP_IDsQuiz,IP_IDsString[33][50],bool:IP_IDsEffectsKaydet[MAX_CLIENTS+1][sizeof(szDeathEffect)+1],IP_IDsEffect[sizeof(szDeathEffect)+1],bool:IP_IDsKanatKaydet[MAX_CLIENTS+1][MAX_KANAT+1],IP_IDsKanatBul[MAX_KANAT+1];
new g_iSinifKontrolDeneme[MAX_CLIENTS+1];
new g_iNovariaRol[MAX_CLIENTS+1];
new g_iYetkiVerHedef[MAX_CLIENTS+1];
new g_iYetkiVerSeviye[MAX_CLIENTS+1];
@sGetRankName(const IP_IDs, szOutput[], iLen) {
    new iLevel = IP_IDszAnt[IP_IDs][sLevel] - 1;
    if(iLevel < 0) iLevel = 0;
    if(iLevel > (szMaxLevel-1)) iLevel = szMaxLevel-1;
    
    new szRankKey[24];
    formatex(szRankKey, charsmax(szRankKey), "NOVARIA_RANK_%02d", iLevel+1);
    format(szOutput, iLen, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], szRankKey);
}
@sGetRolName(const iRol, const IP_IDs, szOutput[], iLen) {
    // Rol adini (User/Yonetici/Admin/VIP...) IP_IDs'nin diline gore
    // novaria_mainmenu.txt icindeki NOVARIA_ROL_00..07 anahtarlarindan okur.
    new iRolSafe = iRol;
    if(iRolSafe < 0) iRolSafe = 0;
    if(iRolSafe >= Novaria_UNVAN_SAYISI) iRolSafe = Novaria_UNVAN_SAYISI - 1;
    new szRolKey[24];
    formatex(szRolKey, charsmax(szRolKey), "NOVARIA_ROL_%02d", iRolSafe);
    format(szOutput, iLen, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], szRolKey);
}
public plugin_init() {
  register_plugin("Zombie Escape Main Menu", "0.3", "Merhabalarr");
  register_dictionary("zombie_plague.txt");
  register_dictionary("novaria_mainmenu.txt");
  RegisterHookChain(RG_CBasePlayer_Spawn, "@sGetPlayerModelControll", true);
  RegisterHookChain(RG_RoundEnd,"@sGetPlayerRoundEnd",1);
  RegisterHookChain(RG_CBasePlayer_Killed, "@sGetPlayerKilled", 1);
  RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "@sGetPlayerWeaponDeploy", .post = false);
  RegisterHookChain(RG_CBasePlayer_Killed,"@sGetPlayerKilled2",.post=true);
  RegisterHookChain(RG_CSGameRules_FlPlayerFallDamage, "@sGetPlayerFallDamage", 1);
  RegisterHookChain(RG_CBasePlayer_TakeDamage,"@sGetPlayerTakeDamage",1);
  RegisterHookChain(RG_CSGameRules_RestartRound, "@sGetPlayerRoundStart", .post = false);
  register_logevent("@sGetPlayerAutoModeRoundStart", 2, "1=Round_Start");
  RegisterHookChain(RG_CBasePlayer_Jump, "@sGetPlayerMultiJumps", false);
  register_event("CurWeapon", "@sGetPlayerCurWeapon", "be", "1=1", "3=1");
  register_event("StatusValue", "@sGetPlayerAimInfo", "be", "1=2", "2!0");
  register_event("StatusValue", "@sGetPlayerAimInfoRemove", "be", "1=1", "2=0");
  register_event("HLTV", "@sGetPlayerCephane", "a", "1=0", "2=0")
  register_forward(FM_AddToFullPack, "@sGetPlayerTeamInvison", 1);
  // BUGFIX (kullanici talebi): level-up sprite ozelligi tamamen kaldirildi,
  // TE_SPRITE dunya-uzayi nesnesi oldugu icin gercek ekrana-sabit (crosshair'e
  // yapisik) bir HUD garanti edilemiyordu; register_forward de kaldirildi.
  register_concmd("amx_coingive","@sGetPlayerGiveCoin",ADMIN_RCON,"<isim> <miktar>");
  register_concmd("amx_coindelete","@sGetPlayerRemoveCoin",ADMIN_RCON,"<isim> <miktar>");
  register_concmd("amx_levelgive","@sGetPlayerGiveLevel",ADMIN_RCON,"<isim> <miktar>, belirlenen kisiye level verir");
  register_concmd("amx_leveldelete","@sGetPlayerRemoveLevel",ADMIN_RCON,"<isim> <miktar>, belirlenen kisiye level alir");
  register_concmd("amx_levelreset","@sGetPlayerResetLevel",ADMIN_RCON,"<isim>, belirlenen kisinin level ve XP'sini 0'a sifirlar");
  register_concmd("amx_givecp","@sGetPlayerGiveAmmo",ADMIN_RCON,"<isim> <miktar>, belirlenen kisiye level verir");
  register_concmd("amx_cpdelete","@sGetPlayerRemoveAmmo",ADMIN_RCON,"<isim> <miktar>, belirlenen kisiye level alir");
  register_clcmd("say","@sGetPlayerHookSay2");register_clcmd("say /ammover","@sGetPlayerMapGiveAp");
  register_clcmd("say /get","@sGetPlayerMapGiveAp");
  register_clcmd("say /insanclass", "@sGetPlayerSinifMenuCreate");
  register_clcmd("say /CoinMenu","@sGetPlayerCoinMenuCreate");register_clcmd("say /KnifeMenu","@sGetPlayerKnifeMenuCreate");
  register_clcmd("say /UserMenu","@sGetPlayerUserMenuCreate");register_clcmd("say /VipMenu","@sGetPlayerVipMenuCreate");
  register_clcmd("say /Coinver","@sGetPlayerMapGiveCoin");register_clcmd("say_team","@sGetPlayerCommondBloced");
  register_clcmd("say_team","@sGetPlayerHookSayTeam");
  register_clcmd("say","@sGetPlayerHookSay");register_clcmd("say","@sGetPlayerCommondBloced");
  IP_IDsGlobal[sTeamInfo] = get_user_msgid("TeamInfo");
  IP_IDsGlobal[sSayText] = get_user_msgid("SayText");
  g_iMsgFog = get_user_msgid("Fog");
  IP_IDsGlobal[sHud] = CreateHudSyncObj();
  IP_IDsGlobal[sHud2] = CreateHudSyncObj();
  IP_IDsGlobal[sHud3] = CreateHudSyncObj();
  // Zombie eleme XP | Zombie kill XP | 좀비 처치 XP
  IP_IDsCvar[1] = register_cvar("zp_ZmElSonuXP", "5");
  // Zombie eleme Coin | Zombie kill Coin | 좀비 처치 코인
  IP_IDsCvar[2] = register_cvar("zp_ZmElSonuCoin", "5");
  // Human eleme XP | Human kill XP | 인간 처치 XP
  IP_IDsCvar[3] = register_cvar("zp_HmElSonuXP", "5");
  // Human eleme Coin | Human kill Coin | 인간 처치 코인
  IP_IDsCvar[4] = register_cvar("zp_HmElSonuCoin", "5");
  // Sure basi Coin | Coin per interval | 시간당 코인
  IP_IDsCvar[7] = register_cvar("zp_SureCoin", "15");
  // Quiz dogru cevap XP | Quiz correct-answer XP | 퀴즈 정답 XP
  IP_IDsCvar[8] = register_cvar("zp_QuizXP", "10");
  // Quiz suresi (sn) | Quiz duration (sec) | 퀴즈 시간(초)
  IP_IDsCvar[9] = register_cvar("zp_QuizSure", "20.0");
  // Harita hediye Coin | Map reward Coin | 맵 보상 코인
  IP_IDsCvar[10] = register_cvar("zp_MapHediyeCoin", "5");
  // Gorev 1 odulu | Task 1 reward | 임무 1 보상
  IP_IDsCvar[11] = register_cvar("zp_Gorev1","100");
  // Gorev 2 odulu | Task 2 reward | 임무 2 보상
  IP_IDsCvar[12] = register_cvar("zp_Gorev2","100");
  // Gorev 3 odulu | Task 3 reward | 임무 3 보상
  IP_IDsCvar[13] = register_cvar("zp_Gorev3","100");
  // Gorev 4 odulu | Task 4 reward | 임무 4 보상
  IP_IDsCvar[14] = register_cvar("zp_Gorev4","100");
  // Maksimum mermi | Max ammo | 최대 탄약
  IP_IDsCvar[15] = register_cvar("zp_MaxAmmo", "20000");
  // Vip AP cekim miktari | Vip AP withdraw amount | VIP AP 인출량
  IP_IDsCvar[17] = register_cvar("zp_VipApCek","500");
  // Round geri sayim (sn) | Round countdown (sec) | 라운드 카운트다운(초)
  IP_IDsCvar[19] = register_cvar("zp_GeriSayim","20");
  // Geri sayim ses esigi | Countdown sound threshold | 카운트다운 소리 임계값
  IP_IDsCvar[20] = register_cvar("zp_GeriSayimSes","10");
  // Harita hediye AP | Map reward AP | 맵 보상 AP
  IP_IDsCvar[25] = register_cvar("zp_MapHediyeAP","85");
  // Oldurme basi XP | XP per kill | 처치당 XP
  IP_IDsCvar[26] = register_cvar("zp_KillXP", "10");
  // Oldurme basi Coin | Coin per kill | 처치당 코인
  IP_IDsCvar[27] = register_cvar("zp_KillCoin", "5");
  // Nemesis oldurme XP | Nemesis kill XP | 네메시스 처치 XP
  IP_IDsCvar[28] = register_cvar("zp_NemesisKillXP", "50");
  // Nemesis oldurme Coin | Nemesis kill Coin | 네메시스 처치 코인
  IP_IDsCvar[29] = register_cvar("zp_NemesisKillCoin", "25");
  // Quiz dogru cevap AP | Quiz correct-answer AP | 퀴즈 정답 AP
  IP_IDsCvar[30] = register_cvar("zp_QuizAP", "30");
  // Happy Hour carpani | Happy Hour multiplier | 해피아워 배율
  IP_IDsCvar[31] = register_cvar("novaria_happyhour_multiplier", "2");
  // Vip zirh miktari | Vip armor amount | VIP 방어구량
  bind_pcvar_num(create_cvar("zp_VipArmor","65.0"), IP_IDsCvar[18]);
  // Sohbet sistemi ac/kapa | Chat system on/off | 채팅 시스템 켜기/끄기
  bind_pcvar_num(create_cvar("zp_Chat","1"),IP_IDsCvar[5]);
  // Oyuncu sohbeti ac/kapa | Player chat on/off | 플레이어 채팅 켜기/끄기
  bind_pcvar_num(create_cvar("zp_PlayerChat","0"),IP_IDsCvar[6]);
  // Ekstra ziplama ac/kapa | Extra jump on/off | 추가 점프 켜기/끄기
  bind_pcvar_num(create_cvar("zp_ekstra_ziplama", "1"), IP_IDsCvar[21]);
  // Ziplama hizi | Jump speed | 점프 속도
  bind_pcvar_float(create_cvar("zp_ziplama_hizi", "275.0"), IP_IDsGlobal[sVelocity]);
  // Human celik zirh | Human steel armor | 인간 강철 방어구
  bind_pcvar_float(create_cvar("novaria_human_celik_armor", "35.0"), g_fHumanCelikArmor);
  // Avci sinifi hizi | Hunter class speed | 헌터 클래스 속도
  bind_pcvar_float(create_cvar("novaria_human_avci_hiz", "500.0"), g_fHumanAvciHiz);
  // Mutant yercekimi carpani | Mutant gravity multiplier | 뮤턴트 중력 배율
  bind_pcvar_float(create_cvar("novaria_human_mutant_gravity", "0.5"), g_fHumanMutantGravity);
  // Nightstalker hizi | Nightstalker speed | 나이트스토커 속도
  bind_pcvar_float(create_cvar("novaria_nightstalker_hiz", "800.0"), g_fNightstalkerHiz);
  // Hero sinifi hizi | Hero class speed | 히어로 클래스 속도
  bind_pcvar_float(create_cvar("novaria_hero_hiz", "600.0"), g_fHeroHiz);
  // Hero kalkan miktari | Hero shield amount | 히어로 방패량
  bind_pcvar_float(create_cvar("novaria_hero_kalkan", "85.0"), g_fHeroKalkan);
  register_clcmd("say","@sGetPlayerYoneticiSifreCheck");
  register_clcmd("yetki_suresigir", "@sGetPlayerYetkiSureCheck");
  // FIX: "yoneticipanel_sifre" komutu artik gercekten sifreyi kontrol eden fonksiyona bagli.
  // 수정: "yoneticipanel_sifre" 명령어가 이제 실제로 비밀번호를 확인하는 함수에 연결되었습니다.
  register_clcmd("yoneticipanel_sifre", "@sGetPlayerYoneticiSifreCheck");
  register_clcmd("say_team /yetkisuresi","@sGetPlayerYetkiSureCheck");
  register_clcmd("say /novariamenu","@sGetPlayerNovariaAnaMenuCreate");
  register_clcmd("say /zpmenu","@sGetPlayerNovariaAnaMenuCreate");
  register_clcmd("say /menu","@sGetPlayerNovariaAnaMenuCreate");
  register_clcmd("novaria_menuac","@sGetPlayerNovariaAnaMenuCreate");
  register_clcmd("novariamenu_ac","@sGetPlayerNovariaAnaMenuCreate");
  set_task(30.0,"@sGetPlayerQuizStart");
}
public @sNovariaVipExtraItemsNative(iPlugin, iParams) {
	if(g_iNovariaVipItemSayi >= Novaria_MAX_VIP_ITEM) return -1;
	new szName[64], szClass[8], szCost[16];
	get_string(1, szName, charsmax(szName));
	get_string(2, szClass, charsmax(szClass));
	get_string(3, szCost, charsmax(szCost));
	new iSinif = str_to_num(szClass);
	if(iSinif < 0 || iSinif > 5) iSinif = 0;
	new iIndex = g_iNovariaVipItemSayi;
	copy(g_szNovariaVipItemAdi[iIndex], charsmax(g_szNovariaVipItemAdi[]), szName);
	g_iNovariaVipItemSinif[iIndex] = iSinif;
	g_iNovariaVipItemFiyat[iIndex] = str_to_num(szCost);
	g_iNovariaVipItemPlugin[iIndex] = iPlugin;
	g_iNovariaVipItemSayi++;
	return iIndex;
}
public @sNovariaZombieExtraItemsNative(iPlugin, iParams) {
	if(g_iNovariaZombieItemSayi >= Novaria_MAX_ZOMBIE_ITEM) return -1;
	new szName[64], szCost[16];
	get_string(1, szName, charsmax(szName));
	get_string(2, szCost, charsmax(szCost));
	new iIndex = g_iNovariaZombieItemSayi;
	copy(g_szNovariaZombieItemAdi[iIndex], charsmax(g_szNovariaZombieItemAdi[]), szName);
	g_iNovariaZombieItemFiyat[iIndex] = str_to_num(szCost);
	g_iNovariaZombieItemPlugin[iIndex] = iPlugin;
	g_iNovariaZombieItemSayi++;
	return iIndex;
}
@sGetPlayerCoinMenuCreate(const IP_IDs) {
	if(!zp_get_user_zombie(IP_IDs)){
		new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_COINMARKET"), "@sGetPlayerCoinMenuCreate_")
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KOSTUM_MARKET"), "1")
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KANAT_MARKET"), "2")
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KUYRUK_MARKET"), "3")
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_EFFECT_MARKET"), "4")
		menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
		menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
		menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
		menu_display(IP_IDs, iMenu);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_A", szTag[SayTag]); sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU); }
	return PLUGIN_HANDLED;
}
@sGetPlayerCoinMenuCreate_(const IP_IDs,const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerKostumMenuCreate(IP_IDs); }
		case 2: { @sGetPlayerWingsMenuCreate(IP_IDs); }
		case 3: { @sGetPlayerTrailMenuCreate(IP_IDs); }
		case 4: { @sGetPlayerSprEffectMenuCreate(IP_IDs); }
	}
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
@sGetPlayerTrailMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KUYRUKMARKET"), "@sGetPlayerTrailMenuCreate_")
	for(new i=1; i < sizeof(szKuyruk); i++) {
	  if(szKuyruk[i][3][0] == 1) {
	  if(!IP_IDsKuyrukKaydet[IP_IDs][i]) {
		menu_additem(iMenu, fmt("%s %s \r(\r%d %L\r)", szTag[KisaTag], szKuyruk[i][0], szKuyruk[i][2], IP_IDs, "NOVARIA_LBL_COIN"), fmt("%d", i));
		} else {
		menu_additem(iMenu, fmt("%s %s \r(%s\r)", szTag[KisaTag], szKuyruk[i][0],
        IP_IDszAnt[IP_IDs][sKuyrukID] == i ? "\rAktif":"\rPasif"), fmt("%d", i));
		}
		}
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
}
@sGetPlayerTrailMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	if(IP_IDsKuyrukKaydet[IP_IDs][szKey]){
	IP_IDszAnt[IP_IDs][sKuyrukID] = IP_IDszAnt[IP_IDs][sKuyrukID] != szKey ? szKey:0;
	if(IP_IDszAnt[IP_IDs][sKuyrukID] == szKey) KuyrukTrailBaslat(IP_IDs, str_to_num(szKuyruk[szKey][1])-1);
	else KuyrukTrailDurdur(IP_IDs);
	IP_IDszAnt[IP_IDs][sKuyrukID2] = false;IP_IDszAnt[IP_IDs][sKuyrukID] != szKey ? client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KUYRUK_PASIF", szTag[SayTag], szKuyruk[szKey][0][0]):
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KUYRUK_AKTIF", szTag[SayTag], szKuyruk[szKey][0][0]);
	@sGetPlayerTrailMenuCreate(IP_IDs);sSaveVault(IP_IDs,1);
	return PLUGIN_HANDLED;
	}
	if(IP_IDszAnt[IP_IDs][sCoin] >= szKuyruk[szKey][2][0]) {
	IP_IDszAnt[IP_IDs][sKuyrukID2] = false;IP_IDszAnt[IP_IDs][sKuyrukID] = szKey;KuyrukTrailBaslat(IP_IDs, str_to_num(szKuyruk[szKey][1])-1);IP_IDsKuyrukKaydet[IP_IDs][szKey] = true;client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KUYRUK_SATINALINDI", szTag[SayTag], szKuyruk[szKey][0][0]);
	IP_IDszAnt[IP_IDs][sCoin] -= szKuyruk[szKey][2][0];sSaveVault(IP_IDs,2);sSaveVault(IP_IDs,1);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_PARA", szTag[SayTag], szKuyruk[szKey][2][0]); sPlayConstSound(IP_IDs, Novaria_SND_WAIT); @sGetPlayerTrailMenuCreate(IP_IDs); }
	menu_destroy(menu); return PLUGIN_HANDLED;
}
@sGetPlayerKostumMenuCreate(const IP_IDs) {
	if(!zp_get_user_zombie(IP_IDs)){
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KOSTUMMARKET"), "@sGetPlayerKostumMenuCreate_")
	for(new i=1; i < g_iKostumSayi; i++) {
	 if(szKostum[i][2][0] == 1) {
	  if(!IP_IDsKostumKaydet[IP_IDs][i]) {
		menu_additem(iMenu, fmt("%s %s \r(\y%d %L\r)", szTag[KisaTag], szKostum[i][0], szKostum[i][3][0], IP_IDs, "NOVARIA_LBL_COIN"), fmt("%d", i));
		} else {
		menu_additem(iMenu, fmt("%s %s \r(%s\r)", szTag[KisaTag], szKostum[i][0],
	IP_IDszAnt[IP_IDs][sKostumID] == i ? "\rAktif":"\rPasif"), fmt("%d", i));
		}
	 }
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_B", szTag[SayTag]); sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU); }
}
@sGetPlayerKostumMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	if(IP_IDsKostumKaydet[IP_IDs][szKey]){
	new bool:bSimdiAktif = (IP_IDszAnt[IP_IDs][sKostumID] != szKey);
	IP_IDszAnt[IP_IDs][sKostumID] = bSimdiAktif ? szKey : 0;
	if(bSimdiAktif) zp_override_user_model(IP_IDs, szKostum[szKey][1][0]);
	else zp_override_user_model(IP_IDs, szHumans[1][0]);
	IP_IDszAnt[IP_IDs][sKostumID2] = false;!bSimdiAktif ? client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KOSTUM_PASIF", szTag[SayTag], szKostum[szKey][0][0]):
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KOSTUM_AKTIF", szTag[SayTag], szKostum[szKey][0][0]);
	IP_IDszAnt[IP_IDs][sPlayerValue] = bSimdiAktif ? 1 : 0;IP_IDszAnt[IP_IDs][sPlayerIndex] = bSimdiAktif ? szKey : 0;
	@sGetPlayerKostumMenuCreate(IP_IDs);sSaveVault(IP_IDs,1);
	return PLUGIN_HANDLED;
	}
	if(IP_IDszAnt[IP_IDs][sLevel] >= szKostum[szKey][4][0]) {
	if(IP_IDszAnt[IP_IDs][sCoin] >= szKostum[szKey][3][0]) {
	IP_IDszAnt[IP_IDs][sKostumID2] = false;IP_IDszAnt[IP_IDs][sKostumID] = szKey;zp_override_user_model(IP_IDs, szKostum[szKey][1][0]);IP_IDsKostumKaydet[IP_IDs][szKey] = true;client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KOSTUM_SATINALINDI", szTag[SayTag], szKostum[szKey][0][0]);
	IP_IDszAnt[IP_IDs][sCoin] -= szKostum[szKey][3][0];sSaveVault(IP_IDs,3);sSaveVault(IP_IDs,1);
	IP_IDszAnt[IP_IDs][sPlayerValue] = 1;IP_IDszAnt[IP_IDs][sPlayerIndex] = szKey;IP_IDszAnt[IP_IDs][sPlayerIndex2] = false;
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_PARA", szTag[SayTag], szKostum[szKey][3][0]); sPlayConstSound(IP_IDs, Novaria_SND_WAIT);  }
	} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_LEVEL", szTag[SayTag], szKostum[szKey][4][0]);
	@sGetPlayerKostumMenuCreate(IP_IDs);
	menu_destroy(menu); return PLUGIN_HANDLED;
}
@sEfektAdi(const IP_IDs, const szKey, szBuf[], iLen) {
	formatex(szBuf, iLen, "%L", IP_IDs, fmt("NOVARIA_EFEKT_%d", szKey));
}
@sGetPlayerSprEffectMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_EFFECTMARKET"), "@sGetPlayerSprEffectMenuCreate_")
	new szEfektAdi[48];
	for(new i=1; i < sizeof(szDeathEffect); i++) {
	  @sEfektAdi(IP_IDs, i, szEfektAdi, charsmax(szEfektAdi));
	  if(!IP_IDsEffectsKaydet[IP_IDs][i]) {
		menu_additem(iMenu, fmt("%s %s \r(\y%d %L\r)", szTag[KisaTag], szEfektAdi, szDeathEffect[i][2], IP_IDs, "NOVARIA_LBL_COIN"), fmt("%d", i));
		} else {
		menu_additem(iMenu, fmt("%s %s \r(%s\r)", szTag[KisaTag], szEfektAdi,
		IP_IDszAnt[IP_IDs][sEffectID] == i ? "\rAktif":"\rPasif"), fmt("%d", i));
		}
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
}
@sGetPlayerSprEffectMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	new szEfektAdiSec[48];
	@sEfektAdi(IP_IDs, szKey, szEfektAdiSec, charsmax(szEfektAdiSec));
	if(IP_IDsEffectsKaydet[IP_IDs][szKey]){
	IP_IDszAnt[IP_IDs][sEffectID] = IP_IDszAnt[IP_IDs][sEffectID] != szKey ? szKey:0;
	IP_IDszAnt[IP_IDs][sEffectID] != szKey ? client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_EFFECT_PASIF", szTag[SayTag], szEfektAdiSec):
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_EFFECT_AKTIF", szTag[SayTag], szEfektAdiSec);
	@sGetPlayerSprEffectMenuCreate(IP_IDs);sSaveVault(IP_IDs,1);
	return PLUGIN_HANDLED;
	}
	if(IP_IDszAnt[IP_IDs][sCoin] >= szDeathEffect[szKey][2][0]) {
	IP_IDszAnt[IP_IDs][sEffectID] = szKey;IP_IDsEffectsKaydet[IP_IDs][szKey] = true;client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_EFFECT_SATINALINDI", szTag[SayTag], szEfektAdiSec);
	IP_IDszAnt[IP_IDs][sCoin] -= szDeathEffect[szKey][2][0];sSaveVault(IP_IDs,5);sSaveVault(IP_IDs,1);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_PARA", szTag[SayTag], szDeathEffect[szKey][2][0]); sPlayConstSound(IP_IDs, Novaria_SND_WAIT); @sGetPlayerSprEffectMenuCreate(IP_IDs); }
	menu_destroy(menu); return PLUGIN_HANDLED;
}
@sGetPlayerWingsMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KANATMARKET"), "@sGetPlayerWingsMenuCreate_")
	for(new i=1; i < g_iKanatSayi; i++) {
	  if(!IP_IDsKanatKaydet[IP_IDs][i]) {
		menu_additem(iMenu, fmt("%s %s \r(\y%d %L\r)", szTag[KisaTag], szKanat[i][0], szKanat[i][3][0], IP_IDs, "NOVARIA_LBL_COIN"), fmt("%d", i));
		} else {
		menu_additem(iMenu, fmt("%s %s \r(%s\r)", szTag[KisaTag], szKanat[i][0],
		IP_IDszAnt[IP_IDs][sWingID] == i ? "\rAktif":"\rPasif"), fmt("%d", i));
		}
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
}
@sGetPlayerWingsMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == 999) {
	            @sWingEntityCreate(IP_IDs,0);
	            menu_destroy(menu);return PLUGIN_HANDLED;
	}
	if(IP_IDsKanatKaydet[IP_IDs][szKey]){
	@sWingEntityCreate(IP_IDs,0);@sWingEntityCreate(IP_IDs,szKey);
	IP_IDszAnt[IP_IDs][sWingID] = IP_IDszAnt[IP_IDs][sWingID] != szKey ? szKey:0;
	IP_IDszAnt[IP_IDs][sWingID] != szKey ? client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KANAT_PASIF", szTag[SayTag], szKanat[szKey][0][0]):
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KANAT_AKTIF", szTag[SayTag], szKanat[szKey][0][0]);
	@sGetPlayerWingsMenuCreate(IP_IDs);sSaveVault(IP_IDs,1);
	return PLUGIN_HANDLED;
	}
	if(IP_IDszAnt[IP_IDs][sLevel] >= szKanat[szKey][4][0]) {
	if(IP_IDszAnt[IP_IDs][sCoin] >= szKanat[szKey][3][0]) {
	@sWingEntityCreate(IP_IDs,0);@sWingEntityCreate(IP_IDs,szKey);
	IP_IDszAnt[IP_IDs][sWingID] = szKey;IP_IDsKanatKaydet[IP_IDs][szKey] = true;client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KANAT_SATINALINDI", szTag[SayTag], szKanat[szKey][0][0]);
	IP_IDszAnt[IP_IDs][sCoin] -= szKanat[szKey][3][0];sSaveVault(IP_IDs,6);sSaveVault(IP_IDs,1);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_PARA", szTag[SayTag], szKanat[szKey][3][0]); sPlayConstSound(IP_IDs, Novaria_SND_WAIT); @sGetPlayerWingsMenuCreate(IP_IDs); }
	} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_LEVEL", szTag[SayTag], szKanat[szKey][4][0]);@sGetPlayerWingsMenuCreate(IP_IDs);
	menu_destroy(menu); return PLUGIN_HANDLED;
}
@sGetPlayerLevelKnifeMenuCreate(const IP_IDs) {
	if(!zp_get_user_zombie(IP_IDs)) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_LEVELBICAKMENU"), "@sGetPlayerLevelKnifeMenuCreate_")
	for(new i=1; i < sizeof(szKnife); i++) {
		menu_additem(iMenu, fmt("%s %s", szTag[KisaTag], szKnife[i][0]), fmt("%d", i));
	}
	menu_addblank2(iMenu);
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "9");
	menu_setprop(iMenu, MPROP_PERPAGE,0);
	menu_display(IP_IDs, iMenu,0);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_C", szTag[SayTag]); sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU); }
}
@sGetPlayerLevelKnifeMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == 9){ menu_destroy(menu);return PLUGIN_HANDLED; }
	if(IP_IDszAnt[IP_IDs][sLevel] >= szKnife[szKey][2][0]){
	@sBicakExtraKapat(IP_IDs);
	IP_IDszAnt[IP_IDs][sBicakKaynak] = 0;
	IP_IDszAnt[IP_IDs][sKnifeID] = szKey;
	new szTemizAd[64];
	sBicakAdiTemizle(szKnife[szKey][0], szTemizAd, charsmax(szTemizAd));
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_BICAK_AKTIF", szTag[SayTag], szTemizAd);
	sSaveVault(IP_IDs, 7);
	if(is_user_alive(IP_IDs)) { rg_remove_item(IP_IDs, "weapon_knife"); rg_give_item(IP_IDs, "weapon_knife"); }
	} else {
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_LEVEL2", szTag[SayTag], szKnife[szKey][2][0]);@sGetPlayerLevelKnifeMenuCreate(IP_IDs);
	return PLUGIN_HANDLED;
	}
	menu_destroy(menu); return PLUGIN_HANDLED;
}
@sGetPlayerKnifeMenuCreate(const IP_IDs) {
    if(!zp_get_user_zombie(IP_IDs)) {
        new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_BICAKMENU"), "@sGetPlayerKnifeMenuCreate_")
        
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NORMALBICAK"), "1");
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_LEVELBICAK"), "2");
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_EXTRABICAK"), "3");
        
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_VIPBICAK"), "4");
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SVIPBICAK"), "5");
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_GOLDVIPBICAK"), "6");
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_DIAMONDVIPBICAK"), "7");
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_PREMIUMVIPBICAK"), "8");
        
        // Cıkıs Butonu
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "9");
        
        menu_setprop(iMenu, MPROP_PERPAGE, 0);
        menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER); // cikis manuel eklendigi icin otomatik exit kapatildi (cift cikis fix)
        menu_display(IP_IDs, iMenu, 0);
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_C", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
    }
}
@sGetPlayerKnifeMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	menu_destroy(menu);
	switch(szKey) {
		case 1: {
			@sGetPlayerNormalKnifeMenuCreate(IP_IDs);
		}
		case 2: {
			@sGetPlayerLevelKnifeMenuCreate(IP_IDs);
		}
		case 3: {
			@sGetPlayerExtraKnifeMenuCreate(IP_IDs);
		}
		case 4: {
			@sGetPlayerVipKnifeMenuCreate(IP_IDs, Novaria_VIP_SINIF_VIP);
		}
		case 5: {
			@sGetPlayerVipKnifeMenuCreate(IP_IDs, Novaria_VIP_SINIF_SILVER);
		}
		case 6: {
			@sGetPlayerVipKnifeMenuCreate(IP_IDs, Novaria_VIP_SINIF_GOLD);
		}
		case 7: {
			@sGetPlayerVipKnifeMenuCreate(IP_IDs, Novaria_VIP_SINIF_DIAMOND);
		}
		case 8: {
			@sGetPlayerVipKnifeMenuCreate(IP_IDs, Novaria_VIP_SINIF_PREMIUM);
		}
	}
	return PLUGIN_HANDLED;
}
@sGetPlayerNormalKnifeMenuCreate(const IP_IDs) {
    if(!zp_get_user_zombie(IP_IDs)) {
        new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_NORMALBICAKMENU"), "@sGetPlayerNormalKnifeMenuCreate_")
        
        for(new i=1; i < sizeof(szBicakNormal); i++) {
            menu_additem(iMenu, fmt("%s %s%s", szTag[KisaTag], szBicakNormal[i][0],
                (IP_IDszAnt[IP_IDs][sBicakKaynak] == 1 && IP_IDszAnt[IP_IDs][sNormalBicakID] == i) ? " \d(\yAktif\d)" : ""), fmt("%d", i));
        }
        
        menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
        menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
        menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"));
        
        menu_setprop(iMenu, MPROP_PERPAGE, 7);
        
        menu_display(IP_IDs, iMenu, 0);
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_C", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
    }
}
@sGetPlayerNormalKnifeMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == 9){ menu_destroy(menu);return PLUGIN_HANDLED; }
	@sBicakExtraKapat(IP_IDs);
	IP_IDszAnt[IP_IDs][sBicakKaynak] = 1;
	IP_IDszAnt[IP_IDs][sNormalBicakID] = szKey;
	new szTemizAd[64];
	sBicakAdiTemizle(szBicakNormal[szKey][0], szTemizAd, charsmax(szTemizAd));
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_BICAK_AKTIF", szTag[SayTag], szTemizAd);
	sSaveVault(IP_IDs, 7);
	if(is_user_alive(IP_IDs)) { rg_remove_item(IP_IDs, "weapon_knife"); rg_give_item(IP_IDs, "weapon_knife"); }
	menu_destroy(menu); return PLUGIN_HANDLED;
}
@sGetPlayerExtraKnifeMenuCreate(const IP_IDs) {
	if(!zp_get_user_zombie(IP_IDs)) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_EXTRABICAKMENU"), "@sGetPlayerExtraKnifeMenuCreate_")
	for(new i=1; i <= g_iExtraBicakSayi; i++) {
		new bool:sahip = bool:(IP_IDszAnt[IP_IDs][sExtraBicakSahiplik] & (1 << (i-1)));
		if(sahip) {
			menu_additem(iMenu, fmt("%s %s \d(%L\d)", szTag[KisaTag], g_szExtraBicakAd[i],
				IP_IDs, (IP_IDszAnt[IP_IDs][sBicakKaynak] == 2 && IP_IDszAnt[IP_IDs][sExtraBicakAktifID] == i) ? "NOVARIA_DURUM_GIYILI" : "NOVARIA_DURUM_SAHIP_GIY"), fmt("%d", i));
		} else {
			menu_additem(iMenu, fmt("%s %s \r(\y%d Jeton\r)", szTag[KisaTag], g_szExtraBicakAd[i], g_iExtraBicakFiyat[i]), fmt("%d", i));
		}
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_setprop(iMenu, MPROP_PERPAGE,7);
	menu_display(IP_IDs, iMenu,0);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_C", szTag[SayTag]); sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU); }
}
@sGetPlayerExtraKnifeMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	menu_destroy(menu);
	if(szKey >= 1 && szKey <= g_iExtraBicakSayi) {
		new bool:zatenSahip = bool:(IP_IDszAnt[IP_IDs][sExtraBicakSahiplik] & (1 << (szKey-1)));
		if(!zatenSahip) {
			if(IP_IDszAnt[IP_IDs][sCoin] >= g_iExtraBicakFiyat[szKey]) {
				IP_IDszAnt[IP_IDs][sCoin] -= g_iExtraBicakFiyat[szKey];
				IP_IDszAnt[IP_IDs][sExtraBicakSahiplik] |= (1 << (szKey-1));
				sSaveVault(IP_IDs, 1);
				client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SILAH_SATINALINDI", szTag[SayTag], g_szExtraBicakAd[szKey]);
			} else {
				client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_PARA", szTag[SayTag], g_iExtraBicakFiyat[szKey]);
				sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
				@sGetPlayerExtraKnifeMenuCreate(IP_IDs);
				return PLUGIN_HANDLED;
			}
		}
		if(IP_IDsBool[IP_IDs][sExtraBicakAktif] && IP_IDszAnt[IP_IDs][sExtraBicakAktifID] != szKey) @sBicakExtraKapat(IP_IDs);
		IP_IDszAnt[IP_IDs][sBicakKaynak] = 2;
		IP_IDszAnt[IP_IDs][sExtraBicakAktifID] = szKey;
		IP_IDsBool[IP_IDs][sExtraBicakAktif] = true;
		if(is_user_alive(IP_IDs)) client_cmd(IP_IDs, g_szExtraBicakGive[szKey]);
	}
	@sGetPlayerExtraKnifeMenuCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerVipKnifeMenuCreate(const IP_IDs, const iSinif) {
	if(zp_get_user_zombie(IP_IDs)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_C", szTag[SayTag]);
		sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
		return;
	}
	if(!Novaria_FULL_ACCESS(IP_IDs) && g_iNovariaRol[IP_IDs] != szNovariaVipSinifUnvanEslesme[iSinif]) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MENU_ACCESS_LEVEL", szTag[SayTag], szNovariaVipEtiket[iSinif]);
		return;
	}
	new iKaynak = iSinif + 2; // Novaria_VIP_SINIF_VIP(1)->3, SILVER(2)->4, GOLD(3)->5, DIAMOND(4)->6, PREMIUM(5)->7
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_VIPBICAKMENU", szNovariaVipEtiket[iSinif]), "@sGetPlayerVipKnifeMenuCreate_")
	new bool:bVarMi = false;
	switch(iSinif) {
		case Novaria_VIP_SINIF_VIP: {
			for(new i = 1; i < sizeof(szBicakVip); i++) {
				menu_additem(iMenu, fmt("%s %s%s", szTag[KisaTag], szBicakVip[i][0],
					(IP_IDszAnt[IP_IDs][sBicakKaynak] == iKaynak && IP_IDszAnt[IP_IDs][sVipBicakID] == i) ? " \d(\yAktif\d)" : ""), fmt("%d_%d", iSinif, i));
				bVarMi = true;
			}
		}
		case Novaria_VIP_SINIF_SILVER: {
			for(new i = 1; i < sizeof(szBicakSVip); i++) {
				menu_additem(iMenu, fmt("%s %s%s", szTag[KisaTag], szBicakSVip[i][0],
					(IP_IDszAnt[IP_IDs][sBicakKaynak] == iKaynak && IP_IDszAnt[IP_IDs][sVipBicakID] == i) ? " \d(\yAktif\d)" : ""), fmt("%d_%d", iSinif, i));
				bVarMi = true;
			}
		}
		case Novaria_VIP_SINIF_GOLD: {
			for(new i = 1; i < sizeof(szBicakGoldVip); i++) {
				menu_additem(iMenu, fmt("%s %s%s", szTag[KisaTag], szBicakGoldVip[i][0],
					(IP_IDszAnt[IP_IDs][sBicakKaynak] == iKaynak && IP_IDszAnt[IP_IDs][sVipBicakID] == i) ? " \d(\yAktif\d)" : ""), fmt("%d_%d", iSinif, i));
				bVarMi = true;
			}
		}
		case Novaria_VIP_SINIF_DIAMOND: {
			for(new i = 1; i < sizeof(szBicakDiamondVip); i++) {
				menu_additem(iMenu, fmt("%s %s%s", szTag[KisaTag], szBicakDiamondVip[i][0],
					(IP_IDszAnt[IP_IDs][sBicakKaynak] == iKaynak && IP_IDszAnt[IP_IDs][sVipBicakID] == i) ? " \d(\yAktif\d)" : ""), fmt("%d_%d", iSinif, i));
				bVarMi = true;
			}
		}
		case Novaria_VIP_SINIF_PREMIUM: {
			for(new i = 1; i < sizeof(szBicakPremiumVip); i++) {
				menu_additem(iMenu, fmt("%s %s%s", szTag[KisaTag], szBicakPremiumVip[i][0],
					(IP_IDszAnt[IP_IDs][sBicakKaynak] == iKaynak && IP_IDszAnt[IP_IDs][sVipBicakID] == i) ? " \d(\yAktif\d)" : ""), fmt("%d_%d", iSinif, i));
				bVarMi = true;
			}
		}
	}
	if(!bVarMi) {
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NO_ITEM_YET"), "-1_-1");
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"));
	menu_setprop(iMenu, MPROP_PERPAGE, 7);
	menu_display(IP_IDs, iMenu, 0);
}
@sGetPlayerVipKnifeMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu); return PLUGIN_HANDLED; }
	new iData[12];
	menu_item_getinfo(menu, item, _, iData, charsmax(iData));
	menu_destroy(menu);
	new szParts[2][6];
	sExplode(iData, "_", szParts, 2, 6);
	new iSinif = str_to_num(szParts[0]);
	new szKey = str_to_num(szParts[1]);
	if(iSinif <= 0 || szKey <= 0) return PLUGIN_HANDLED;
	if(!Novaria_FULL_ACCESS(IP_IDs) && g_iNovariaRol[IP_IDs] != szNovariaVipSinifUnvanEslesme[iSinif]) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_ITEM", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new szTemizAd[64];
	switch(iSinif) {
		case Novaria_VIP_SINIF_VIP: {
			if(szKey >= sizeof(szBicakVip)) return PLUGIN_HANDLED;
			sBicakAdiTemizle(szBicakVip[szKey][0], szTemizAd, charsmax(szTemizAd));
		}
		case Novaria_VIP_SINIF_SILVER: {
			if(szKey >= sizeof(szBicakSVip)) return PLUGIN_HANDLED;
			sBicakAdiTemizle(szBicakSVip[szKey][0], szTemizAd, charsmax(szTemizAd));
		}
		case Novaria_VIP_SINIF_GOLD: {
			if(szKey >= sizeof(szBicakGoldVip)) return PLUGIN_HANDLED;
			sBicakAdiTemizle(szBicakGoldVip[szKey][0], szTemizAd, charsmax(szTemizAd));
		}
		case Novaria_VIP_SINIF_DIAMOND: {
			if(szKey >= sizeof(szBicakDiamondVip)) return PLUGIN_HANDLED;
			sBicakAdiTemizle(szBicakDiamondVip[szKey][0], szTemizAd, charsmax(szTemizAd));
		}
		case Novaria_VIP_SINIF_PREMIUM: {
			if(szKey >= sizeof(szBicakPremiumVip)) return PLUGIN_HANDLED;
			sBicakAdiTemizle(szBicakPremiumVip[szKey][0], szTemizAd, charsmax(szTemizAd));
		}
		default: return PLUGIN_HANDLED;
	}
	@sBicakExtraKapat(IP_IDs);
	IP_IDszAnt[IP_IDs][sBicakKaynak] = iSinif + 2;
	IP_IDszAnt[IP_IDs][sVipBicakID] = szKey;
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_BICAK_AKTIF", szTag[SayTag], szTemizAd);
	sSaveVault(IP_IDs, 7);
	if(is_user_alive(IP_IDs)) { rg_remove_item(IP_IDs, "weapon_knife"); rg_give_item(IP_IDs, "weapon_knife"); }
	return PLUGIN_HANDLED;
}
@sBicakExtraKapat(const IP_IDs) {
	if(IP_IDsBool[IP_IDs][sExtraBicakAktif]) {
		new szKey = IP_IDszAnt[IP_IDs][sExtraBicakAktifID];
		if(szKey > 0 && szKey <= g_iExtraBicakSayi && is_user_connected(IP_IDs)) {
			client_cmd(IP_IDs, g_szExtraBicakRemove[szKey]);
		}
		IP_IDsBool[IP_IDs][sExtraBicakAktif] = false;
	}
}
stock sBicakAdiTemizle(const src[], dest[], len) {
	new i, j, c = strlen(src);
	for(i=0; i<c && j<len; i++) {
		if(src[i]=='\' && (src[i+1]=='r' || src[i+1]=='y' || src[i+1]=='d' || src[i+1]=='w')) { i++; continue; }
		dest[j++] = src[i];
	}
	dest[j] = 0;
}
public @sGetPlayerWeaponDeploy(const iEntity, szViewModel[], szWeaponModel[], iAnim, szAnimExt[], skiplocal) {
	new pPlayer = get_member(iEntity, m_pPlayer);
	new iWeaponID = get_member(iEntity, m_iId);
	if(_:iWeaponID == _:WEAPON_KNIFE) {
		if(IP_IDsBool[pPlayer][sExtraBicakAktif]) return;
		new szKey;
		if(IP_IDszAnt[pPlayer][sBicakKaynak] == 1) {
			szKey = IP_IDszAnt[pPlayer][sNormalBicakID];
			if(szKey <= 0 || szKey >= sizeof(szBicakNormal)) szKey = 1;
			SetHookChainArg(2, ATYPE_STRING, szBicakNormal[szKey][1][0]);
			if(szBicakNormal[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szBicakNormal[szKey][3][0]);
			else SetHookChainArg(3, ATYPE_STRING, szBicakNormal[szKey][1][0]);
		} else if(IP_IDszAnt[pPlayer][sBicakKaynak] >= 3 && IP_IDszAnt[pPlayer][sBicakKaynak] <= 7) {
			szKey = IP_IDszAnt[pPlayer][sVipBicakID];
			switch(IP_IDszAnt[pPlayer][sBicakKaynak]) {
				case 3: {
					if(szKey <= 0 || szKey >= sizeof(szBicakVip)) szKey = 1;
					SetHookChainArg(2, ATYPE_STRING, szBicakVip[szKey][1][0]);
					if(szBicakVip[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szBicakVip[szKey][3][0]);
					else SetHookChainArg(3, ATYPE_STRING, szBicakVip[szKey][1][0]);
				}
				case 4: {
					if(szKey <= 0 || szKey >= sizeof(szBicakSVip)) szKey = 1;
					SetHookChainArg(2, ATYPE_STRING, szBicakSVip[szKey][1][0]);
					if(szBicakSVip[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szBicakSVip[szKey][3][0]);
					else SetHookChainArg(3, ATYPE_STRING, szBicakSVip[szKey][1][0]);
				}
				case 5: {
					if(szKey <= 0 || szKey >= sizeof(szBicakGoldVip)) szKey = 1;
					SetHookChainArg(2, ATYPE_STRING, szBicakGoldVip[szKey][1][0]);
					if(szBicakGoldVip[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szBicakGoldVip[szKey][3][0]);
					else SetHookChainArg(3, ATYPE_STRING, szBicakGoldVip[szKey][1][0]);
				}
				case 6: {
					if(szKey <= 0 || szKey >= sizeof(szBicakDiamondVip)) szKey = 1;
					SetHookChainArg(2, ATYPE_STRING, szBicakDiamondVip[szKey][1][0]);
					if(szBicakDiamondVip[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szBicakDiamondVip[szKey][3][0]);
					else SetHookChainArg(3, ATYPE_STRING, szBicakDiamondVip[szKey][1][0]);
				}
				case 7: {
					if(szKey <= 0 || szKey >= sizeof(szBicakPremiumVip)) szKey = 1;
					SetHookChainArg(2, ATYPE_STRING, szBicakPremiumVip[szKey][1][0]);
					if(szBicakPremiumVip[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szBicakPremiumVip[szKey][3][0]);
					else SetHookChainArg(3, ATYPE_STRING, szBicakPremiumVip[szKey][1][0]);
				}
			}
		} else {
			szKey = IP_IDszAnt[pPlayer][sKnifeID];
			if(szKey <= 0 || szKey >= sizeof(szKnife)) szKey = 1;
			SetHookChainArg(2, ATYPE_STRING, szKnife[szKey][1][0]);
			if(szKnife[szKey][3][0]) SetHookChainArg(3, ATYPE_STRING, szKnife[szKey][3][0]);
			else SetHookChainArg(3, ATYPE_STRING, szKnife[szKey][1][0]);
		}
	}
}
public zp_user_infected_pre(IP_IDs) {
	@sBicakExtraKapat(IP_IDs);
}
@sGetPlayerHumanClassMenuCreate(const IP_IDs) {
    if(IP_IDszAnt[IP_IDs][sMapEngel3] == 0) {
        if(!zp_get_user_zombie(IP_IDs)) {
            new iMenu = menu_create(fmt("%s %L" , szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_INSANSINIFI"), "@sGetPlayerHumanClassMenuCreate_")
            menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CLASS_KLASIK"), "1")
            menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CLASS_CELIK"), "2")
            menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CLASS_AVCI"), "3")
            menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CLASS_MUTANT"), "4")
            menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \d| \y%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
            menu_display(IP_IDs, iMenu);
        } else {
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_HUMANCLASS", szTag[SayTag]);
            sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
        }
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_WAIT_MAP_CHANGE", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
    }
}
@sGetPlayerHumanClassMenuCreate_(const IP_IDs, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) {
        menu_destroy(iMenu);
        IP_IDszAnt[IP_IDs][sClassValue] = -1;
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    switch(szKey) {
        case 1: {
            IP_IDszAnt[IP_IDs][sMapEngel3] = 1;
            IP_IDszAnt[IP_IDs][sClassValue] = 1;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_KLASIK", szTag[SayTag]);
        }
        case 2: {
            IP_IDszAnt[IP_IDs][sMapEngel3] = 1;
            set_entvar(IP_IDs, var_armorvalue, get_entvar(IP_IDs, var_armorvalue) + g_fHumanCelikArmor);
            IP_IDszAnt[IP_IDs][sClassValue] = 2;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_CELIK", szTag[SayTag]);
        }
        case 3: {
            IP_IDszAnt[IP_IDs][sMapEngel3] = 1;
            set_entvar(IP_IDs, var_maxspeed, g_fHumanAvciHiz);
            IP_IDszAnt[IP_IDs][sClassValue] = 3;
            set_task(1.0, "@sGetPlayerAddSpeed", IP_IDs + 1707);
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_AVCI", szTag[SayTag]);
        }
        case 4: {
            IP_IDszAnt[IP_IDs][sMapEngel3] = 1;
            set_entvar(IP_IDs, var_gravity, g_fHumanMutantGravity);
            IP_IDszAnt[IP_IDs][sClassValue] = 4;
            set_task(1.0, "@sGetPlayerAddGravity", IP_IDs + 1708);
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_MUTANT", szTag[SayTag]);
        }
    }
    sPlayConstSound(IP_IDs, Novaria_SND_EQUIP);
    menu_destroy(iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerNemesisClassMenuCreate(const IP_IDs) {
    if(!zp_get_user_nemesis(IP_IDs)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NEMESIS_ONLY", szTag[SayTag]);
        return;
    }
    if(IP_IDszAnt[IP_IDs][sMapEngelNemesis] == 0) {
        new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_NEMESIS_SINIFI"), "@sGetPlayerNemesisClassMenuCreate_")
        menu_additem(iMenu, fmt("%s %L^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NEMESIS_CLASS_KLASIK"), "1")
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NEMESIS_CLASS_CELIK"), "2")
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NEMESIS_CLASS_AVCI"), "3")
        menu_additem(iMenu, fmt("%s %L^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NEMESIS_CLASS_MUTANT"), "4")
        menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
        menu_display(IP_IDs, iMenu);
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_WAIT_MAP_CHANGE", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
    }
}
@sGetPlayerNemesisClassMenuCreate_(const IP_IDs, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) {
        menu_destroy(iMenu);
        IP_IDszAnt[IP_IDs][sNemesisClassValue] = -1;
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    switch(szKey) {
        case 1: {
            IP_IDszAnt[IP_IDs][sMapEngelNemesis] = 1;
            IP_IDszAnt[IP_IDs][sNemesisClassValue] = 1;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_KLASIK", szTag[SayTag]);
        }
        case 2: {
            IP_IDszAnt[IP_IDs][sMapEngelNemesis] = 1;
            set_entvar(IP_IDs, var_armorvalue, get_entvar(IP_IDs, var_armorvalue) + g_fHumanCelikArmor);
            IP_IDszAnt[IP_IDs][sNemesisClassValue] = 2;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_CELIK", szTag[SayTag]);
        }
        case 3: {
            IP_IDszAnt[IP_IDs][sMapEngelNemesis] = 1;
            set_entvar(IP_IDs, var_maxspeed, g_fNightstalkerHiz);
            IP_IDszAnt[IP_IDs][sNemesisClassValue] = 3;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_AVCI", szTag[SayTag]);
        }
        case 4: {
            IP_IDszAnt[IP_IDs][sMapEngelNemesis] = 1;
            set_entvar(IP_IDs, var_gravity, g_fHumanMutantGravity);
            IP_IDszAnt[IP_IDs][sNemesisClassValue] = 4;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_MUTANT", szTag[SayTag]);
        }
    }
    sPlayConstSound(IP_IDs, Novaria_SND_EQUIP);
    menu_destroy(iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerHeroClassMenuCreate(const IP_IDs) {
    if(zp_get_user_zombie(IP_IDs)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_GENERAL", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
        return;
    }
    if(IP_IDszAnt[IP_IDs][sMapEngelHero] == 0) {
        new iMenu = menu_create(fmt("%s %L" , szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_HEROMENU"), "@sGetPlayerHeroClassMenuCreate_")
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_HERO_KLASIK"), "1")
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_HERO_KACAK"), "2")
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_HERO_HIZLANMA"), "3")
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_HERO_KALKAN"), "4")
        menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"));
        menu_display(IP_IDs, iMenu);
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_WAIT_MAP_CHANGE", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
    }
}
@sGetPlayerHeroClassMenuCreate_(const IP_IDs, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) {
        menu_destroy(iMenu);
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    switch(szKey) {
        case 1: {
            IP_IDszAnt[IP_IDs][sMapEngelHero] = 1;
            IP_IDszAnt[IP_IDs][sHeroClassValue] = 1;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_HERO_KLASIK", szTag[SayTag]);
        }
        case 2: {
            IP_IDszAnt[IP_IDs][sMapEngelHero] = 1;
            IP_IDsBool[IP_IDs][sHeroKacak] = true;
            IP_IDszAnt[IP_IDs][sHeroClassValue] = 2;
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_HERO_KACAK", szTag[SayTag]);
        }
        case 3: {
            IP_IDszAnt[IP_IDs][sMapEngelHero] = 1;
            IP_IDsBool[IP_IDs][sHeroHizlanma] = true;
            IP_IDszAnt[IP_IDs][sHeroClassValue] = 3;
            set_entvar(IP_IDs, var_maxspeed, g_fHeroHiz);
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_HERO_HIZLANMA", szTag[SayTag]);
        }
        case 4: {
            IP_IDszAnt[IP_IDs][sMapEngelHero] = 1;
            IP_IDsBool[IP_IDs][sHeroKalkan] = true;
            IP_IDszAnt[IP_IDs][sHeroClassValue] = 4;
            set_entvar(IP_IDs, var_armorvalue, get_entvar(IP_IDs, var_armorvalue) + g_fHeroKalkan);
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CLASS_HERO_KALKAN", szTag[SayTag]);
        }
    }
    sPlayConstSound(IP_IDs, Novaria_SND_EQUIP);
    menu_destroy(iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerSinifKaydetMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_SINIFKAYDET"), "@sGetPlayerSinifKaydetMenuCreate_")
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SINIFKAYDET_INSAN",
        IP_IDsBool[IP_IDs][sSinifKaydiInsan] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "1")
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SINIFKAYDET_ZOMBI",
        IP_IDsBool[IP_IDs][sSinifKaydiZombi] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "2")
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SINIFKAYDET_HERO",
        IP_IDsBool[IP_IDs][sSinifKaydiHero] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "3")
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SINIFKAYDET_NEMESIS",
        IP_IDsBool[IP_IDs][sSinifKaydiNemesis] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "4")
    menu_addblank2(iMenu);
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "0");
    menu_setprop(iMenu, MPROP_PERPAGE, 0);
    menu_display(IP_IDs, iMenu, 0);
    sPlayConstSound(IP_IDs, Novaria_SND_MENU);
    return PLUGIN_HANDLED;
}
@sGetPlayerSinifKaydetMenuCreate_(const IP_IDs, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
    new iData[6], szKey;
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    if(szKey == 0) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
    switch(szKey) {
        case 1: {
            if(IP_IDszAnt[IP_IDs][sClassValue] <= 0) {
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
            } else {
                IP_IDsBool[IP_IDs][sSinifKaydiInsan] = !IP_IDsBool[IP_IDs][sSinifKaydiInsan];
                sSaveVault(IP_IDs, 9);
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], IP_IDsBool[IP_IDs][sSinifKaydiInsan] ? "NOVARIA_MSG_SINIFKAYDET_AKTIF" : "NOVARIA_MSG_SINIFKAYDET_PASIF", szTag[SayTag], fmt("%L", IP_IDs, "NOVARIA_MENU_INSAN_SINIFLARI"));
            }
        }
        case 2: {
            new iZKlas = zp_get_user_next_class(IP_IDs);
            if(iZKlas < 0) iZKlas = zp_get_user_zombie_class(IP_IDs);
            if(iZKlas < 0) {
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
            } else {
                IP_IDsBool[IP_IDs][sSinifKaydiZombi] = !IP_IDsBool[IP_IDs][sSinifKaydiZombi];
                if(IP_IDsBool[IP_IDs][sSinifKaydiZombi]) IP_IDszAnt[IP_IDs][sZombieClassSaved] = iZKlas;
                sSaveVault(IP_IDs, 9);
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], IP_IDsBool[IP_IDs][sSinifKaydiZombi] ? "NOVARIA_MSG_SINIFKAYDET_AKTIF" : "NOVARIA_MSG_SINIFKAYDET_PASIF", szTag[SayTag], fmt("%L", IP_IDs, "NOVARIA_MENU_ZOMBI_SINIFI"));
            }
        }
        case 3: {
            if(IP_IDszAnt[IP_IDs][sHeroClassValue] <= 0) {
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
            } else {
                IP_IDsBool[IP_IDs][sSinifKaydiHero] = !IP_IDsBool[IP_IDs][sSinifKaydiHero];
                sSaveVault(IP_IDs, 9);
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], IP_IDsBool[IP_IDs][sSinifKaydiHero] ? "NOVARIA_MSG_SINIFKAYDET_AKTIF" : "NOVARIA_MSG_SINIFKAYDET_PASIF", szTag[SayTag], fmt("%L", IP_IDs, "NOVARIA_MENU_KAHRAMAN_SINIFI"));
            }
        }
        case 4: {
            if(IP_IDszAnt[IP_IDs][sNemesisClassValue] <= 0) {
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_CLASS_SELECTED", szTag[SayTag]);
            } else {
                IP_IDsBool[IP_IDs][sSinifKaydiNemesis] = !IP_IDsBool[IP_IDs][sSinifKaydiNemesis];
                sSaveVault(IP_IDs, 9);
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], IP_IDsBool[IP_IDs][sSinifKaydiNemesis] ? "NOVARIA_MSG_SINIFKAYDET_AKTIF" : "NOVARIA_MSG_SINIFKAYDET_PASIF", szTag[SayTag], fmt("%L", IP_IDs, "NOVARIA_MENU_NEMESIS_SINIFI"));
            }
        }
    }
    menu_destroy(iMenu);
    @sGetPlayerSinifKaydetMenuCreate(IP_IDs);
    return PLUGIN_HANDLED;
}
@sNovariaHeroKacakNative(iPlugin, iParams) {
    new IP_IDs = get_param(1);
    if(!is_user_connected(IP_IDs)) return 0;
    return IP_IDsBool[IP_IDs][sHeroKacak] ? 1 : 0;
}
@sGetPlayerUserMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L" , szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_PLAYERMENU"), "@sGetPlayerUserMenuCreate_")
    
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_FPSMENU"),"1")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_HUDMENU"),"2")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_GOREVMENU"),"3")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_SISMENU"),"4")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_SESMENU"),"5")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_DOVIZ_ISLEMLERI"), "6")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_DILMENU", szNovariaDilAdi[IP_IDszAnt[IP_IDs][sDilID]]), "7")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_TITLE_SINIFKAYDET"), "8")
    menu_additem(iMenu, fmt("%s %L^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_BUGDAN_KURTUL"), "9") 
    
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "0");
    
    menu_setprop(iMenu, MPROP_PERPAGE, 0);
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER); 
    
    menu_display(IP_IDs, iMenu, 0);
    sPlayConstSound(IP_IDs, Novaria_SND_MENU);
    return PLUGIN_HANDLED;
}
@sGetPlayerUserMenuCreate_(const IP_IDs,const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == 0){ menu_destroy(iMenu);return PLUGIN_HANDLED; }
	switch(szKey) {
		case 1: { @sGetPlayerFpsMenuCreate(IP_IDs); }
		case 2: { @sGetPlayerHudAyarlariMenuCreate(IP_IDs); }
		case 3: { @sGetPlayerGorevMenuCreate(IP_IDs); }
		case 4: { @sGetPlayerSisMenuCreate(IP_IDs); }
		case 5: { @sGetPlayerSesMenuCreate(IP_IDs); }
		case 6: { @sGetPlayerDovizMenuCreate(IP_IDs); }
		case 7: { @sNovariaDilToggle(IP_IDs); }
		case 8: { @sGetPlayerSinifKaydetMenuCreate(IP_IDs); }
		case 9: { @sNovariaBugdanKurtulYap(IP_IDs); }
	}
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
@sNovariaDilToggle(const IP_IDs) {
	// Dil dongusu: Turkce -> Ingilizce -> Korece -> Turkce...
	// 언어 순환: 터키어 -> 영어 -> 한국어 -> 터키어...
	IP_IDszAnt[IP_IDs][sDilID] = (IP_IDszAnt[IP_IDs][sDilID] + 1) % 3;
	sNovariaSetClientLang(IP_IDs, szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]]);
	sSaveVault(IP_IDs, 8);
	// BUGFIX: rol/tag metni (IP_IDsString) sadece @sGetPlayerFlagControll cagrilinca
	// yenileniyor; dil degistirince bu hic cagrilmiyordu, bu yuzden rol adi
	// harita degisene kadar eski dilde kaliyordu.
	@sGetPlayerFlagControll(IP_IDs);
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_LANG_CHANGED", szTag[SayTag], szNovariaDilAdi[IP_IDszAnt[IP_IDs][sDilID]]);
	@sGetPlayerUserMenuCreate(IP_IDs);
}
@sNovariaDilMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_DILMENU"), "@sNovariaDilMenuCreate_")
	menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_DIL_TURKCE", IP_IDszAnt[IP_IDs][sDilID] == Novaria_DIL_TR ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "0")
	menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_DIL_ENGLISH", IP_IDszAnt[IP_IDs][sDilID] == Novaria_DIL_EN ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "1")
	menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_DIL_KOREAN", IP_IDszAnt[IP_IDs][sDilID] == Novaria_DIL_KO ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "2")
	menu_addblank2(iMenu);
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "9");
	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sNovariaDilMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == 9) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	IP_IDszAnt[IP_IDs][sDilID] = szKey;
	sNovariaSetClientLang(IP_IDs, szNovariaDilKodu[szKey]);
	sSaveVault(IP_IDs, 8);
	// BUGFIX: rol/tag metnini de hemen yenile, harita degisene kadar beklemesin.
	@sGetPlayerFlagControll(IP_IDs);
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_LANG_CHANGED", szTag[SayTag], szNovariaDilAdi[szKey]);
	@sGetPlayerUserMenuCreate(IP_IDs);
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
@sGetPlayerDovizMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_DOVIZMENU"), "@sGetPlayerDovizMenuCreate_")
	for(new i = 0; i < sizeof(szDovizKur); i++) {
		menu_additem(iMenu, fmt("%s %d XP Satin AL \r(\y%d %L\r)", szTag[KisaTag], szDovizKur[i][0], szDovizKur[i][1], IP_IDs, "NOVARIA_LBL_COIN"), fmt("%d", i));
	}
	menu_addblank2(iMenu);
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "-1");
	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerDovizMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == -1){ menu_destroy(iMenu);return PLUGIN_HANDLED; }
	if(IP_IDszAnt[IP_IDs][sCoin] >= szDovizKur[szKey][1]) {
		IP_IDszAnt[IP_IDs][sCoin] -= szDovizKur[szKey][1];
		IP_IDszAnt[IP_IDs][sXP] += szDovizKur[szKey][0];
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_XP_BOUGHT", szTag[SayTag], szDovizKur[szKey][1], szDovizKur[szKey][0]);
		sSaveVault(IP_IDs, 1);sSaveVault(IP_IDs, 4);@sGetPlayerCheckLevel(IP_IDs);
	} else {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_COIN", szTag[SayTag], szDovizKur[szKey][1]);
		sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
	}
	@sGetPlayerDovizMenuCreate(IP_IDs);
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
@sGetPlayerFpsMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_FPSMENU"), "@sGetPlayerFpsMenuCreate_");
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_FPS_SABITLE", IP_IDszAnt[IP_IDs][sSettingsOption][1] ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "1");
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_RADAR", IP_IDszAnt[IP_IDs][sSettingsOption][2] ? "\d(\rPasif\d)":"\d(\yAktif\d)"), "2");
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_HUD_GOSTER", IP_IDszAnt[IP_IDs][sSettingsOption][3] ? "\d(\rPasif\d)":"\d(\yAktif\d)"), "3");
    menu_additem(iMenu, fmt("%s %L %s^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CHAT", IP_IDszAnt[IP_IDs][sSettingsOption][4] ? "\d(\rPasif\d)":"\d(\yAktif\d)"), "4");
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_TAKIMINI_GIZLE", IP_IDsBool[IP_IDs][sGizle] ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "6");
    menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_OYUNCULARI_GIZLE", IP_IDsBool[IP_IDs][sHideAllModels] ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "7");
    menu_additem(iMenu, fmt("%s %L %s^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_TAKIM_MODELLERI_GIZLE", IP_IDsBool[IP_IDs][sHideTeamModelsOnly] ? "\d(\yAktif\d)":"\d(\rPasif\d)"), "8");
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_GORUS_ACISI"), "9");
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS"), "0");
    menu_setprop(iMenu, MPROP_PERPAGE, 0);
    menu_display(IP_IDs, iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerFpsMenuCreate_(const IP_IDs,const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey == 0){ menu_destroy(iMenu);return PLUGIN_HANDLED; }
	switch(szKey) {
		case 1: {
		    if(!IP_IDszAnt[IP_IDs][sSettingsOption][1]) {
		        IP_IDszAnt[IP_IDs][sSettingsOption][1] = true;console_cmd(IP_IDs,"fps_max 333");console_cmd(IP_IDs,"fps_modem 333");console_cmd(IP_IDs,"developer 1");console_cmd(IP_IDs,"fps_override 1");console_cmd(IP_IDs,"cl_showfps 1");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SETTINGS_SAVED", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDszAnt[IP_IDs][sSettingsOption][1] = false;console_cmd(IP_IDs,"fps_max 101");console_cmd(IP_IDs,"fps_modem 101");console_cmd(IP_IDs,"developer 0");console_cmd(IP_IDs,"fps_override 1");console_cmd(IP_IDs,"cl_showfps 0");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SETTINGS_RESET", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 2: {
		    if(!IP_IDszAnt[IP_IDs][sSettingsOption][2]) {
		        IP_IDszAnt[IP_IDs][sSettingsOption][2] = true;console_cmd(IP_IDs,"hideradar");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_RADAR_HIDDEN", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDszAnt[IP_IDs][sSettingsOption][2] = false;console_cmd(IP_IDs,"drawradar");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_RADAR_RESET", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 3: {
		    if(!IP_IDszAnt[IP_IDs][sSettingsOption][3]) {
		        IP_IDszAnt[IP_IDs][sSettingsOption][3] = true;console_cmd(IP_IDs,"hud_draw 0");@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDszAnt[IP_IDs][sSettingsOption][3] = false;console_cmd(IP_IDs,"hud_draw 1");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_HUD_RESET", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 4: {
		    if(!IP_IDszAnt[IP_IDs][sSettingsOption][4]) {
		        IP_IDszAnt[IP_IDs][sSettingsOption][4] = true;console_cmd(IP_IDs,"hud_saytext 0");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CHAT_HIDDEN", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDszAnt[IP_IDs][sSettingsOption][4] = false;console_cmd(IP_IDs,"hud_saytext 1");
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CHAT_RESET", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 6: {
		    if(IP_IDsBool[IP_IDs][sGizle]) {
		        IP_IDsBool[IP_IDs][sGizle] = false;
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TEAMMATES_VISIBLE", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDsBool[IP_IDs][sGizle] = true;
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TEAMMATES_HIDDEN", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 7: {
		    if(IP_IDsBool[IP_IDs][sHideAllModels]) {
		        IP_IDsBool[IP_IDs][sHideAllModels] = false;
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_PLAYERMODELS_VISIBLE", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDsBool[IP_IDs][sHideAllModels] = true;
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_PLAYERMODELS_HIDDEN", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 8: {
		    if(IP_IDsBool[IP_IDs][sHideTeamModelsOnly]) {
		        IP_IDsBool[IP_IDs][sHideTeamModelsOnly] = false;
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TEAMMODELS_VISIBLE", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDsBool[IP_IDs][sHideTeamModelsOnly] = true;
		        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TEAMMODELS_HIDDEN", szTag[SayTag]);@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
		case 9: {
		    if(!IP_IDszAnt[IP_IDs][sSettingsOption][5]) {
		        IP_IDszAnt[IP_IDs][sSettingsOption][5] = true;client_cmd(IP_IDs, "say /3pers");@sGetPlayerFpsMenuCreate(IP_IDs);
		        } else {
		        IP_IDszAnt[IP_IDs][sSettingsOption][5] = false;client_cmd(IP_IDs, "say /3pers");@sGetPlayerFpsMenuCreate(IP_IDs);
		    }
		}
	}
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
new const szSisYogunlukTablosu[9][4] = {
	{2,  58, 133, 22},
	{94, 58, 133, 22},
	{20, 59, 79,  115},
	{45, 59, 108, 121},
	{51, 59, 108, 121},
	{71, 59, 12,  49},
	{94, 59, 133, 22},
	{2,  60, 133, 22},
	{14, 60, 82,  139}
};
@sGetPlayerSisSendClient(const IP_IDs) {
	if(!is_user_connected(IP_IDs)) return;
	if(!g_iMsgFog) return;
	if(!IP_IDsBool[IP_IDs][sSisAktif]) {
		message_begin(MSG_ONE, g_iMsgFog, {0,0,0}, IP_IDs);
		write_byte(0);write_byte(0);write_byte(0);
		write_byte(0);write_byte(0);write_byte(0);write_byte(0);
		message_end();
		return;
	}
	message_begin(MSG_ONE, g_iMsgFog, {0,0,0}, IP_IDs);
	write_byte(szSisRenkRGB[IP_IDszAnt[IP_IDs][sSisRenk]][0]);
	write_byte(szSisRenkRGB[IP_IDszAnt[IP_IDs][sSisRenk]][1]);
	write_byte(szSisRenkRGB[IP_IDszAnt[IP_IDs][sSisRenk]][2]);
	write_byte(szSisYogunlukTablosu[IP_IDszAnt[IP_IDs][sSisYogunluk]][2]);
	write_byte(szSisYogunlukTablosu[IP_IDszAnt[IP_IDs][sSisYogunluk]][3]);
	write_byte(szSisYogunlukTablosu[IP_IDszAnt[IP_IDs][sSisYogunluk]][0]);
	write_byte(szSisYogunlukTablosu[IP_IDszAnt[IP_IDs][sSisYogunluk]][1]);
	message_end();
}
@sGetPlayerSisSendClientTask(taskid) {
	@sGetPlayerSisSendClient(taskid - 8800);
}
@sGetPlayerSisMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_SISMENU"), "@sGetPlayerSisMenuCreate_")
    new szSisRenkKey[24]; formatex(szSisRenkKey, charsmax(szSisRenkKey), "FOGCOLOR_%d", IP_IDszAnt[IP_IDs][sSisRenk])
    menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SIS_DURUMU", IP_IDsBool[IP_IDs][sSisAktif] ? "(\rAktif\w)" : "(\rPasif\w)"), "1")
    menu_additem(iMenu, fmt("%s %L: (\r%L\w)", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SIS_RENGI", IP_IDs, szSisRenkKey), "2")
    menu_additem(iMenu, fmt("%s %L: (\r%L\w)", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SIS_YOGUNLUGU", IP_IDs, "NOVARIA_MENU_SIS_SEVIYE_FORMAT", IP_IDszAnt[IP_IDs][sSisYogunluk] + 1), "3")
    menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
    menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
    menu_display(IP_IDs, iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerSisMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: {
			IP_IDsBool[IP_IDs][sSisAktif] = !IP_IDsBool[IP_IDs][sSisAktif];
			@sGetPlayerSisSendClient(IP_IDs);
			if(IP_IDsBool[IP_IDs][sSisAktif]) client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_FOG_ON", szTag[SayTag]);
			else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_FOG_OFF", szTag[SayTag]);
		}
		case 2: {
			IP_IDszAnt[IP_IDs][sSisRenk] = (IP_IDszAnt[IP_IDs][sSisRenk] + 1) % sizeof(szSisRenkAdi);
			@sGetPlayerSisSendClient(IP_IDs);
			new szSisRenkMsgKey[24]; formatex(szSisRenkMsgKey, charsmax(szSisRenkMsgKey), "FOGCOLOR_%d", IP_IDszAnt[IP_IDs][sSisRenk])
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_FOG_COLOR_SET", szTag[SayTag], fmt("%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], szSisRenkMsgKey));
		}
		case 3: {
			IP_IDszAnt[IP_IDs][sSisYogunluk] = (IP_IDszAnt[IP_IDs][sSisYogunluk] + 1) % sizeof(szSisYogunlukTablosu);
			@sGetPlayerSisSendClient(IP_IDs);
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_FOG_DENSITY_SET", szTag[SayTag], IP_IDszAnt[IP_IDs][sSisYogunluk] + 1);
		}
	}
	sSaveVault(IP_IDs, 8);
	menu_destroy(iMenu);
	@sGetPlayerSisMenuCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerSesMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_SESMENU"), "@sGetPlayerSesMenuCreate_")
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SES_MENU", IP_IDsBool[IP_IDs][sSesMenuAktif] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "1")
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SES_LEVEL", IP_IDsBool[IP_IDs][sSesLevelAktif] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "2")
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SES_GERISAYIM", IP_IDsBool[IP_IDs][sSesGeriSayimAktif] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "3")
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SES_MOD", IP_IDsBool[IP_IDs][sSesModAktif] ? fmt("%L", IP_IDs, "NOVARIA_DURUM_AKTIF") : fmt("%L", IP_IDs, "NOVARIA_DURUM_PASIF")), "4")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \\d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \\w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \\r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerSesMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: {
			IP_IDsBool[IP_IDs][sSesMenuAktif] = !IP_IDsBool[IP_IDs][sSesMenuAktif];
		}
		case 2: {
			IP_IDsBool[IP_IDs][sSesLevelAktif] = !IP_IDsBool[IP_IDs][sSesLevelAktif];
		}
		case 3: {
			IP_IDsBool[IP_IDs][sSesGeriSayimAktif] = !IP_IDsBool[IP_IDs][sSesGeriSayimAktif];
		}
		case 4: {
			IP_IDsBool[IP_IDs][sSesModAktif] = !IP_IDsBool[IP_IDs][sSesModAktif];
		}
	}
	sSaveVault(IP_IDs, 8);
	menu_destroy(iMenu);
	@sGetPlayerSesMenuCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerHudAyarlariMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_HUDMENU"), "@sGetPlayerHudAyarlariMenuCreate_")
	new szHudRenkKey[24]; formatex(szHudRenkKey, charsmax(szHudRenkKey), "HUDCOLOR_%d", IP_IDszAnt[IP_IDs][sHudRenk])
	new szHudKonumKey[24]; formatex(szHudKonumKey, charsmax(szHudKonumKey), "HUDPOS_%d", IP_IDszAnt[IP_IDs][sHudKonum])
	menu_additem(iMenu, fmt("%s %L: \r[\e%L\r]", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_RENK_AYARLARI", IP_IDs, szHudRenkKey),"1")
	menu_additem(iMenu, fmt("%s %L: \r[\r%L\r]", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KONUM_AYARLARI", IP_IDs, szHudKonumKey),"2")
	menu_additem(iMenu, fmt("%s %L: \r[\r%L\r]", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_HUD_DURUMU", IP_IDs, IP_IDsBool[IP_IDs][sHudDurum] ? "NOVARIA_DURUM_KAPALI":"NOVARIA_DURUM_ACIK"),"3")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerHudAyarlariMenuCreate_(const IP_IDs,const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: {
			IP_IDszAnt[IP_IDs][sHudRenk] = (IP_IDszAnt[IP_IDs][sHudRenk] + 1) % sizeof(szHudRenkAdi);
			new szHudRenkMsgKey[24]; formatex(szHudRenkMsgKey, charsmax(szHudRenkMsgKey), "HUDCOLOR_%d", IP_IDszAnt[IP_IDs][sHudRenk])
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CURRENT_COLOR", szTag[SayTag], fmt("%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], szHudRenkMsgKey));
		}
		case 2: {
			IP_IDszAnt[IP_IDs][sHudKonum] = (IP_IDszAnt[IP_IDs][sHudKonum] + 1) % sizeof(szHudKonumAdi);
			new szHudKonumMsgKey[24]; formatex(szHudKonumMsgKey, charsmax(szHudKonumMsgKey), "HUDPOS_%d", IP_IDszAnt[IP_IDs][sHudKonum])
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_CURRENT_POSITION", szTag[SayTag], fmt("%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], szHudKonumMsgKey));
		}
		case 3: {
			IP_IDsBool[IP_IDs][sHudDurum] = IP_IDsBool[IP_IDs][sHudDurum] ? false:true;
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_HUD_TOGGLED", szTag[SayTag], fmt("%L", IP_IDs, IP_IDsBool[IP_IDs][sHudDurum] ? "NOVARIA_DURUM_KAPALI":"NOVARIA_DURUM_ACIK"));
		}
	}
	sSaveVault(IP_IDs, 8);
	menu_destroy(iMenu);
	@sGetPlayerHudAyarlariMenuCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerGorevMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L" , szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_GOREVMENU"), "@sGetPlayerGorevMenuCreate_")
	if(IP_IDsBool[IP_IDs][sGorev1]) {
			menu_additem(iMenu, fmt("%s %L%L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV1", get_pcvar_num(IP_IDsCvar[11]), IP_IDszAnt[IP_IDs][sGorevCtKill], IP_IDs, "NOVARIA_GOREV_TAMAMLANDI"),"1")
			} else {
			menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV1", get_pcvar_num(IP_IDsCvar[11]), IP_IDszAnt[IP_IDs][sGorevCtKill]),"1")
		}
	if(IP_IDsBool[IP_IDs][sGorev2]) {
			menu_additem(iMenu, fmt("%s %L%L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV2", get_pcvar_num(IP_IDsCvar[12]), IP_IDszAnt[IP_IDs][sGorevInfectEt], IP_IDs, "NOVARIA_GOREV_TAMAMLANDI"),"2")
			} else {
			menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV2", get_pcvar_num(IP_IDsCvar[12]), IP_IDszAnt[IP_IDs][sGorevInfectEt]),"2")
		}
	if(IP_IDsBool[IP_IDs][sGorev4]) {
			menu_additem(iMenu, fmt("%s %L%L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV3", get_pcvar_num(IP_IDsCvar[13]), IP_IDszAnt[IP_IDs][sGorevSureliOyna], IP_IDs, "NOVARIA_GOREV_TAMAMLANDI"),"3")
			} else {
			menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV3", get_pcvar_num(IP_IDsCvar[13]), IP_IDszAnt[IP_IDs][sGorevSureliOyna]),"3")
		}
	if(IP_IDsBool[IP_IDs][sGorev5]) {
			menu_additem(iMenu, fmt("%s %L%L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV4", get_pcvar_num(IP_IDsCvar[14]), IP_IDszAnt[IP_IDs][sGorevRoundOyna], IP_IDs, "NOVARIA_GOREV_TAMAMLANDI"),"4")
			} else {
			menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_GOREV4", get_pcvar_num(IP_IDsCvar[14]), IP_IDszAnt[IP_IDs][sGorevRoundOyna]),"4")
		}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerGorevMenuCreate_(const IP_IDs,const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: {
			if(IP_IDsBool[IP_IDs][sGorev1]) client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_ALREADY_DONE", szTag[SayTag]);
			else if(IP_IDszAnt[IP_IDs][sGorevCtKill] >= 1){
				IP_IDsBool[IP_IDs][sGorev1] = true;@sGetPlayerGorevMenuCreate(IP_IDs);
				IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[11]);client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_COMPLETED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[11]));sSaveVault(IP_IDs, 1);
			} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NOT_ENOUGH_ZOMBIE_KILLS", szTag[SayTag]);
		}
		case 2: {
			if(IP_IDsBool[IP_IDs][sGorev2]) client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_ALREADY_DONE", szTag[SayTag]);
			else if(IP_IDszAnt[IP_IDs][sGorevInfectEt] >= 5){
				IP_IDsBool[IP_IDs][sGorev2] = true;@sGetPlayerGorevMenuCreate(IP_IDs);
				IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[12]);client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_COMPLETED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[12]));sSaveVault(IP_IDs, 1);
			} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NOT_ENOUGH_INFECTS", szTag[SayTag]);
		}
		case 3: {
			if(IP_IDsBool[IP_IDs][sGorev4]) client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_ALREADY_DONE", szTag[SayTag]);
			else if(IP_IDszAnt[IP_IDs][sGorevSureliOyna] >= 15){
				IP_IDsBool[IP_IDs][sGorev4] = true;@sGetPlayerGorevMenuCreate(IP_IDs);
				IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[13]);client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_COMPLETED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[13]));sSaveVault(IP_IDs, 1);
			} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NOT_ENOUGH_PLAYTIME", szTag[SayTag]);
		}
		case 4: {
			if(IP_IDsBool[IP_IDs][sGorev5]) client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_ALREADY_DONE", szTag[SayTag]);
			else if(IP_IDszAnt[IP_IDs][sGorevRoundOyna] >= 7){
				IP_IDsBool[IP_IDs][sGorev5] = true;@sGetPlayerGorevMenuCreate(IP_IDs);
				IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[14]);client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_TASK_COMPLETED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[14]));sSaveVault(IP_IDs, 1);
			} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NOT_ENOUGH_ROUNDS", szTag[SayTag]);
		}
	}
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
// ==================================================
// YETKILI PLATFORM MENU (VIP / S-VIP / GOLD / DIAMOND / PREMIUM)
// Ekran goruntusundeki menu birebir bu blokla uretiliyor.
// Kendi tema (szTag[MenuTag]/[KisaTag]) sistemi kullanilir.
// ==================================================
new g_iYPAktifSinif[MAX_PLAYERS + 1];
new bool:g_bYPApAlindi[6][MAX_PLAYERS + 1];
new bool:g_bYPJetonAlindi[6][MAX_PLAYERS + 1];
new bool:g_bYPZirhAlindi[6][MAX_PLAYERS + 1];
new bool:g_bYPBombaAlindi[6][MAX_PLAYERS + 1];
new const g_iYPApMiktar[6]    = { 0, 500, 1000, 2000, 3000, 3000 };
new const g_iYPJetonMiktar[6] = { 0, 100, 250,  500,  700,  700  };
new const g_iYPZirhMiktar[6]  = { 0, 0,   0,    0,    0,    100  };
new const szYPMenuAdiKey[][] = { "NOVARIA_TITLE_YP_0", "NOVARIA_TITLE_YP_1", "NOVARIA_TITLE_YP_2", "NOVARIA_TITLE_YP_3", "NOVARIA_TITLE_YP_4", "NOVARIA_TITLE_YP_5" };

// Premium_Petsv3.sma eklentisini "say /pets" client komutu YOLLAMADAN, dogrudan
// plugin-icin plugin cagirisiyla (callfunc) tetikler. Boylece Steam'in
// "Server tried to send invalid command" uyarisi hic olusmaz.
@sYPPetsPluginBul() {
	static iCache = -2; // -2 = henuz aranmadi, -1 = bulunamadi
	if(iCache != -2) return iCache;
	new iNum = get_pluginsnum();
	new szFile[64], szName[64];
	for(new i = 0; i < iNum; i++) {
		get_plugin(i, szFile, charsmax(szFile), szName, charsmax(szName));
		if(containi(szFile, "pet") != -1 || containi(szName, "Pet") != -1) {
			iCache = i;
			return iCache;
		}
	}
	iCache = -1;
	return iCache;
}
@sYPPetsMenuAc(const IP_IDs) {
	new iPluginId = @sYPPetsPluginBul();
	if(iPluginId >= 0) {
		new szPluginFile[64];
		get_plugin(iPluginId, szPluginFile, charsmax(szPluginFile));
		if(callfunc_begin("Show_MainMenu", szPluginFile) > 0) {
			callfunc_push_int(IP_IDs);
			callfunc_end();
			return;
		}
	}
	// Pet eklentisi bulunamadiysa/yuklu degilse bilgi ver (say komutu gonderilmez)
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YP_PET_YOK", szTag[SayTag]);
}

// mainmode.sma icinde zaten yerlesik "unstuck" destegi var (say /unstuck -> menu_game(id,3)).
// Ayri bir stuck.sma eklentisine ihtiyac yok, dogrudan bu komutu tetikliyoruz.
@sNovariaBugdanKurtulYap(const IP_IDs) {
	client_cmd(IP_IDs, "say /unstuck");
}

@sGetPlayerYetkiliPlatformMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_YETKILIPLATFORM"), "@sGetPlayerYetkiliPlatformMenuCreate_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_VIP"), "1")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_SVIP"), "2")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_GOLD"), "3")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_DIAMOND"), "4")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_PREMIUM"), "5")
	if(Novaria_FULL_ACCESS(IP_IDs) || g_iNovariaRol[IP_IDs] == szNovariaVipSinifUnvanEslesme[Novaria_VIP_SINIF_PREMIUM]) {
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_PET_MENU"), "pet")
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER); // cikis manuel eklendigi icin otomatik exit kapatildi (cift cikis fix)
	menu_additem(iMenu, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"), "cikis")
	menu_display(IP_IDs, iMenu);
}
@sGetPlayerYetkiliPlatformMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6];
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	menu_destroy(iMenu);
	if(equal(iData, "cikis")) {
		return PLUGIN_HANDLED;
	}
	if(equal(iData, "pet")) {
		if(Novaria_FULL_ACCESS(IP_IDs) || g_iNovariaRol[IP_IDs] == szNovariaVipSinifUnvanEslesme[Novaria_VIP_SINIF_PREMIUM]) {
			@sYPPetsMenuAc(IP_IDs);
		} else {
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MENU_ACCESS_LEVEL", szTag[SayTag], szNovariaVipEtiket[Novaria_VIP_SINIF_PREMIUM]);
		}
		return PLUGIN_HANDLED;
	}
	new iSinif = str_to_num(iData);
	@sGetPlayerYPSinifMenuAc(IP_IDs, iSinif);
	return PLUGIN_HANDLED;
}
@sGetPlayerYPSinifMenuAc(const IP_IDs, const iSinif) {
	if(!Novaria_FULL_ACCESS(IP_IDs) && g_iNovariaRol[IP_IDs] != szNovariaVipSinifUnvanEslesme[iSinif]) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MENU_ACCESS_LEVEL", szTag[SayTag], szNovariaVipEtiket[iSinif]);
		sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
		return;
	}
	g_iYPAktifSinif[IP_IDs] = iSinif;
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, szYPMenuAdiKey[iSinif]), "@sGetPlayerYPSinifMenuAc_")

	new szAlindiEtiket[24];

	format(szAlindiEtiket, charsmax(szAlindiEtiket), "%s", g_bYPApAlindi[iSinif][IP_IDs] ? " \r[\yAlindi\r]" : "");
	menu_additem(iMenu, fmt("%s %L \r[\y+%d\r]%s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_AP_CEK", g_iYPApMiktar[iSinif], szAlindiEtiket), "ap")

	format(szAlindiEtiket, charsmax(szAlindiEtiket), "%s", g_bYPJetonAlindi[iSinif][IP_IDs] ? " \r[\yAlindi\r]" : "");
	menu_additem(iMenu, fmt("%s %L \r[\y+%d\r]%s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_JETON_CEK", g_iYPJetonMiktar[iSinif], szAlindiEtiket), "jt")

	if(iSinif == Novaria_VIP_SINIF_PREMIUM) {
		format(szAlindiEtiket, charsmax(szAlindiEtiket), "%s", g_bYPZirhAlindi[iSinif][IP_IDs] ? " \r[\yAlindi\r]" : "");
		menu_additem(iMenu, fmt("%s %L \r[\y+%d\r]%s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_ZIRH_CEK", g_iYPZirhMiktar[iSinif], szAlindiEtiket), "zr")
	}
	if(iSinif == Novaria_VIP_SINIF_GOLD || iSinif == Novaria_VIP_SINIF_DIAMOND || iSinif == Novaria_VIP_SINIF_PREMIUM) {
		format(szAlindiEtiket, charsmax(szAlindiEtiket), "%s", g_bYPBombaAlindi[iSinif][IP_IDs] ? " \r[\yAlindi\r]" : "");
		menu_additem(iMenu, fmt("%s %L%s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YP_ATESBUZ_CEK", szAlindiEtiket), "bb")
	}
	if(iSinif != Novaria_VIP_SINIF_VIP) {
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KUYRUK_MENU"), "kr")
	}
	if(iSinif == Novaria_VIP_SINIF_DIAMOND || iSinif == Novaria_VIP_SINIF_PREMIUM) {
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KOSTUM_MARKET"), "ks")
	}

	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
}
@sGetPlayerYPSinifMenuAc_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iSinif = g_iYPAktifSinif[IP_IDs];
	new szData[6];
	menu_item_getinfo(iMenu, iItem, _, szData, charsmax(szData));
	menu_destroy(iMenu);

	if(equal(szData, "ap")) {
		if(!g_bYPApAlindi[iSinif][IP_IDs]) {
			g_bYPApAlindi[iSinif][IP_IDs] = true;
			zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) + g_iYPApMiktar[iSinif]);
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_TRANSFERRED", szTag[SayTag], g_iYPApMiktar[iSinif]);
		} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_ALREADY_TAKEN_MAP", szTag[SayTag]);
		@sGetPlayerYPSinifMenuAc(IP_IDs, iSinif);
	}
	else if(equal(szData, "jt")) {
		if(!g_bYPJetonAlindi[iSinif][IP_IDs]) {
			g_bYPJetonAlindi[iSinif][IP_IDs] = true;
			IP_IDszAnt[IP_IDs][sCoin] += g_iYPJetonMiktar[iSinif];
			sSaveVault(IP_IDs, 1);
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YP_JETON_ALINDI", szTag[SayTag], g_iYPJetonMiktar[iSinif]);
		} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_ALREADY_TAKEN_MAP", szTag[SayTag]);
		@sGetPlayerYPSinifMenuAc(IP_IDs, iSinif);
	}
	else if(equal(szData, "zr")) {
		if(g_bYPZirhAlindi[iSinif][IP_IDs]) {
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_ALREADY_TAKEN_MAP", szTag[SayTag]);
		}
		else if(!is_user_alive(IP_IDs)) {
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YP_OLU_GEREKLI", szTag[SayTag]);
		}
		else {
			g_bYPZirhAlindi[iSinif][IP_IDs] = true;
			set_entvar(IP_IDs, var_armorvalue, get_entvar(IP_IDs, var_armorvalue) + float(g_iYPZirhMiktar[iSinif]));
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YP_ZIRH_ALINDI", szTag[SayTag], g_iYPZirhMiktar[iSinif]);
		}
		@sGetPlayerYPSinifMenuAc(IP_IDs, iSinif);
	}
	else if(equal(szData, "bb")) {
		if(g_bYPBombaAlindi[iSinif][IP_IDs]) {
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_ALREADY_TAKEN_MAP", szTag[SayTag]);
		}
		else if(!is_user_alive(IP_IDs)) {
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YP_OLU_GEREKLI", szTag[SayTag]);
		}
		else {
			g_bYPBombaAlindi[iSinif][IP_IDs] = true;
			rg_give_item(IP_IDs, "weapon_hegrenade");
			rg_give_item(IP_IDs, "weapon_flashbang");
			client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YP_BOMBA_ALINDI", szTag[SayTag]);
		}
		@sGetPlayerYPSinifMenuAc(IP_IDs, iSinif);
	}
	else if(equal(szData, "kr")) { @sGetPlayerYPKuyrukMenuCreate(IP_IDs, iSinif); }
	else if(equal(szData, "ks")) { @sGetPlayerVKostumMenuCreate(IP_IDs); }

	return PLUGIN_HANDLED;
}

@sGetPlayerVipMenuCreate(const IP_IDs) {
		if(get_user_flags(IP_IDs) & szFlag) {
		new iMenu = menu_create(fmt("%s %L" , szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_VIPMENU"), "@sGetPlayerVipMenuCreate_")
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KUYRUK_MENU"), "1")
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KOSTUM_MARKET"), "2")
		menu_additem(iMenu, fmt("%s %L \r[\y+%d\r]^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_AP_CEK", get_pcvar_num(IP_IDsCvar[17])),"4")
		menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
		menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
		menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
		menu_display(IP_IDs, iMenu);
		} else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_VIP_ONLY_MENU", szTag[SayTag]);
}
@sGetPlayerVipMenuCreate_(const IP_IDs,const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu);return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerVKuyrukMenuCreate(IP_IDs); }
		case 2: { @sGetPlayerVKostumMenuCreate(IP_IDs); }
		case 4: {
		     if(IP_IDszAnt[IP_IDs][sVipMapEngel] == 0) {
		         zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) + get_pcvar_num(IP_IDsCvar[17]));
		         IP_IDszAnt[IP_IDs][sVipMapEngel] = true;client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_TRANSFERRED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[17]));
		     } else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AP_ALREADY_TAKEN_MAP", szTag[SayTag]);
		}
	}
	menu_destroy(iMenu);return PLUGIN_HANDLED;
}
@sGetPlayerVKuyrukMenuCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KUYRUKMENU"), "@sGetPlayerVKuyrukMenuCreate_")
	for(new i=1; i < sizeof(szKuyruk); i++) {
	   if(szKuyruk[i][3][0] == 2) {
		menu_additem(iMenu, fmt("%s %s \r[%s\r]", szTag[KisaTag], szKuyruk[i][0],
        IP_IDszAnt[IP_IDs][sKuyrukID2] == i ? "\yAktif":"\rPasif"), fmt("%d", i));
	}
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \y%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \y%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerVKuyrukMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	IP_IDszAnt[IP_IDs][sKuyrukID2] = IP_IDszAnt[IP_IDs][sKuyrukID2] != szKey ? szKey:0;
	IP_IDszAnt[IP_IDs][sKuyrukID] = false;IP_IDszAnt[IP_IDs][sKuyrukID2] = szKey;
	if(IP_IDszAnt[IP_IDs][sKuyrukID2] == szKey) KuyrukTrailBaslat(IP_IDs, str_to_num(szKuyruk[szKey][1])-1);
	else KuyrukTrailDurdur(IP_IDs);
	IP_IDszAnt[IP_IDs][sKuyrukID2] != szKey ? client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KUYRUK_PASIF", szTag[SayTag], szKuyruk[szKey][0][0]):
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KUYRUK_AKTIF", szTag[SayTag], szKuyruk[szKey][0][0]);
	menu_destroy(menu); return PLUGIN_HANDLED;
}
// ==================================================
// YETKILI PLATFORM - TIER'A OZEL DENEME TRAIL (KUYRUK) MENUSU
// SVIP(SILVER) / GOLD / DIAMOND / PREMIUM icin ayri ayri 3'er sprite
// Sprite dosya yolu: sprites/novaria_ze/nvr_trail/
// ==================================================
@sGetPlayerYPKuyrukMenuCreate(const IP_IDs, const iSinif) {
	new iBase = g_iYPTrailBase[iSinif];
	if(iBase == -1) return; // bu sinifin deneme trail'i yok

	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KUYRUKMENU"), "@sGetPlayerYPKuyrukMenuCreate_")
	for(new i = 0; i < g_iYPTrailCount[iSinif]; i++) {
		new iGlobalIndex = iBase + i;
		menu_additem(iMenu, fmt("%s %L \r[%s\r]", szTag[KisaTag], IP_IDs, szYPTrailAdKey[iSinif][i],
			g_iYPTrailAktif[IP_IDs] == iGlobalIndex ? "\yAktif" : "\rPasif"), fmt("%d", iGlobalIndex));
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \y%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \y%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
}
@sGetPlayerYPKuyrukMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT) { menu_destroy(menu); return PLUGIN_HANDLED; }
	new iData[6];
	menu_item_getinfo(menu, item, _, iData, charsmax(iData));
	menu_destroy(menu);
	new iGlobalIndex = str_to_num(iData);

	if(g_iYPTrailAktif[IP_IDs] == iGlobalIndex) {
		// Ayni trail'e tekrar basildi -> kapat
		g_iYPTrailAktif[IP_IDs] = 0;
		KuyrukTrailDurdur(IP_IDs);
		IP_IDszAnt[IP_IDs][sKuyrukID2] = 0;
	} else {
		g_iYPTrailAktif[IP_IDs] = iGlobalIndex;
		IP_IDszAnt[IP_IDs][sKuyrukID2] = 0; // genel kuyruk sistemiyle cakismasin
		KuyrukTrailBaslat(IP_IDs, iGlobalIndex);
	}
	@sGetPlayerYPKuyrukMenuCreate(IP_IDs, g_iYPAktifSinif[IP_IDs]);
	return PLUGIN_HANDLED;
}
@sGetPlayerSinifMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_SINIFPLATFORMU"), "@sGetPlayerSinifMenuCreate_")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_ZOMBI_SINIFI"), "1")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_INSAN_SINIFLARI"), "2")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NEMESIS_SINIFI"), "3")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KAHRAMAN_SINIFI"), "4")
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s | %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
    menu_display(IP_IDs, iMenu);
}
@sGetPlayerSinifMenuCreate_(const IP_IDs, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) {
        menu_destroy(iMenu);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    switch(szKey) {
        case 1: {
            zp_open_zclass_menu(IP_IDs);
        }
        case 2: {
            @sGetPlayerHumanClassMenuCreate(IP_IDs);
        }
        case 3: {
            @sGetPlayerNemesisClassMenuCreate(IP_IDs);
        }
        case 4: {
            @sGetPlayerHeroClassMenuCreate(IP_IDs);
        }
    }
    menu_destroy(iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerVKostumMenuCreate(const IP_IDs) {
    if(!zp_get_user_zombie(IP_IDs)) {
        new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KOSTUMMENU"), "@sGetPlayerVKostumMenuCreate_")
        for(new i=1; i < g_iKostumSayi; i++) {
            if(szKostum[i][2][0] == 2) {
                menu_additem(iMenu, fmt("%s %s \r[\y%s\r]", szTag[KisaTag], szKostum[i][0],
                IP_IDszAnt[IP_IDs][sKostumID2] == i ? "Aktif" : "Pasif"), fmt("%d", i));
            }
        }
        menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
        menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
        menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
        menu_display(IP_IDs, iMenu);
    }
    else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_B", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
    }
}
@sGetPlayerVKostumMenuCreate_(const IP_IDs, const menu, const item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(menu, item, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    if(IP_IDszAnt[IP_IDs][sKostumID2] == szKey) {
        IP_IDszAnt[IP_IDs][sKostumID2] = 0;
        IP_IDszAnt[IP_IDs][sPlayerValue] = 0;
        IP_IDszAnt[IP_IDs][sPlayerIndex2] = 0;
        zp_override_user_model(IP_IDs, szHumans[1][0]);
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KOSTUM_PASIF", szTag[SayTag], szKostum[szKey][0][0]);
    }
    else {
        IP_IDszAnt[IP_IDs][sKostumID2] = szKey;
        IP_IDszAnt[IP_IDs][sKostumID] = 0;
        IP_IDszAnt[IP_IDs][sPlayerValue] = 2;
        IP_IDszAnt[IP_IDs][sPlayerIndex2] = szKey;
        IP_IDszAnt[IP_IDs][sPlayerIndex] = 0;
        zp_override_user_model(IP_IDs, szKostum[szKey][1][0]);
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_KOSTUM_AKTIF", szTag[SayTag], szKostum[szKey][0][0]);
    }
    menu_destroy(menu);
    return PLUGIN_HANDLED;
}
@sNovariaVipExtraAnaMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_EXTRAESYAPLATFORMU"), "@sNovariaVipExtraAnaMenuCreate_")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KLASIK_EXTRA"), "0")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_VIP_EXTRA"), "1")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SVIP_EXTRA"), "2")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_GOLDVIP_EXTRA"), "3")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_DIAMONVIP_EXTRA"), "4")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_PREMIUMVIP_EXTRA"), "5")
    menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
    menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
    menu_display(IP_IDs, iMenu);
}
@sNovariaVipExtraAnaMenuCreate_(const IP_IDs, const menu, const item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(menu, item, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    menu_destroy(menu);
    @sNovariaVipExtraSinifMenuCreate(IP_IDs, szKey);
    return PLUGIN_HANDLED;
}
@sNovariaVipExtraSinifMenuCreate(const IP_IDs, const iSinif) {
    if(iSinif == Novaria_VIP_SINIF_KLASIK) {
        @sNovariaKlasikRealExtraMenuCreate(IP_IDs);
        return;
    }
    if(zp_get_user_zombie(IP_IDs)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_C", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
        return;
    }
    if(iSinif != Novaria_VIP_SINIF_KLASIK && !Novaria_FULL_ACCESS(IP_IDs)) {
        if(g_iNovariaRol[IP_IDs] != szNovariaVipSinifUnvanEslesme[iSinif]) {
            client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MENU_ACCESS_LEVEL", szTag[SayTag], szNovariaVipEtiket[iSinif]);
            return;
        }
    }
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, szNovariaVipMenuAdiKey[iSinif]), "@sNovariaVipExtraSinifMenuCreate_")
    new bool:bVarMi = false;
    for(new i = 0; i < g_iNovariaVipItemSayi; i++) {
        if(g_iNovariaVipItemSinif[i] == iSinif) {
            menu_additem(iMenu, fmt("%s %s \r(\y%d CP\r)", szTag[KisaTag], g_szNovariaVipItemAdi[i], g_iNovariaVipItemFiyat[i]), fmt("%d", i));
            bVarMi = true;
        }
    }
    if(!bVarMi) {
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NO_ITEM_YET"), "-1");
    }
    menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
    menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
    menu_display(IP_IDs, iMenu);
}
@sNovariaKlasikRealExtraMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_KLASIKEKSTRA"), "@sNovariaKlasikRealExtraMenuCreate_")
    new bool:bZombie = bool:zp_get_user_zombie(IP_IDs);
    new bool:bVarMi = false;
    new iCount = zp_get_extra_items_count();
    new szName[32], iCost, iTeam;
    for(new i = 0; i < iCount; i++) {
        if(!zp_get_extra_item_info(i, szName, charsmax(szName), iCost, iTeam)) continue;
        if(bZombie) {
            if(!(iTeam & ZP_TEAM_ZOMBIE)) continue;
        } else {
            if(!(iTeam & ZP_TEAM_HUMAN)) continue;
        }
        // NightVision menuden gizlensin istendi. Kaydini (native_register_extra_item2) mainmode
        // tarafinda silmiyoruz cince EXTRA_NVISION = 0 sabit ID'yi korumak icin oraya bilincli
        // birakilmis (Antidote/Madness/InfBomb ID kaymasin diye) - burada sadece listeden gizliyoruz.
        if(equal(szName, "NightVision")) continue;
        menu_additem(iMenu, fmt("%s %s \r(\y%d Cp\r)", szTag[KisaTag], szName, iCost), fmt("%d", i));
        bVarMi = true;
    }
    if(!bVarMi) {
        menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NO_ITEM_YET"), "-1");
    }
    menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
    menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
    menu_display(IP_IDs, iMenu);
}
@sNovariaKlasikRealExtraMenuCreate_(const IP_IDs, const menu, const item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new iData[6], iItemId;
    menu_item_getinfo(menu, item, _, iData, charsmax(iData));
    iItemId = str_to_num(iData);
    menu_destroy(menu);
    if(iItemId < 0) return PLUGIN_HANDLED;
    zp_force_buy_extra_item(IP_IDs, iItemId, 0);
    return PLUGIN_HANDLED;
}
@sNovariaVipExtraSinifMenuCreate_(const IP_IDs, const menu, const item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    new iData[6], szKey;
    menu_item_getinfo(menu, item, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    menu_destroy(menu);
    if(szKey < 0 || szKey >= g_iNovariaVipItemSayi) return PLUGIN_HANDLED;
    new iSinif = g_iNovariaVipItemSinif[szKey];
    if(iSinif != Novaria_VIP_SINIF_KLASIK && !Novaria_FULL_ACCESS(IP_IDs) && g_iNovariaRol[IP_IDs] != szNovariaVipSinifUnvanEslesme[iSinif]) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_ITEM", szTag[SayTag]);
        return PLUGIN_HANDLED;
    }
    new iCost = g_iNovariaVipItemFiyat[szKey];
    if(iCost > 0 && zp_get_user_ammo_packs(IP_IDs) < iCost) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_AP", szTag[SayTag], iCost);
        sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
        @sNovariaVipExtraSinifMenuCreate(IP_IDs, iSinif);
        return PLUGIN_HANDLED;
    }
    if(iCost > 0) {
        zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) - iCost);
    }
    new iPluginId = g_iNovariaVipItemPlugin[szKey];
    if(iPluginId != -1) {
        new szPluginFile[64];
        get_plugin(iPluginId, szPluginFile, charsmax(szPluginFile));
        if(callfunc_begin("novaria_item_selected", szPluginFile) > 0) {
            callfunc_push_int(IP_IDs);
            callfunc_push_int(szKey);
            callfunc_end();
        }
    }
    client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ESYA_SATINALINDI", szTag[SayTag], g_szNovariaVipItemAdi[szKey]);
    return PLUGIN_HANDLED;
}
@sNovariaZombieExtraMenuCreate(const IP_IDs) {
	if(!zp_get_user_zombie(IP_IDs)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_B", szTag[SayTag]);
		sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
		return;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_ZOMBIEKSTRA"), "@sNovariaZombieExtraMenuCreate_")
	new bool:bVarMi = false;
	for(new i = 0; i < g_iNovariaZombieItemSayi; i++) {
		menu_additem(iMenu, fmt("%s %s \r(\y%d CP\r)", szTag[KisaTag], g_szNovariaZombieItemAdi[i], g_iNovariaZombieItemFiyat[i]), fmt("%d", i));
		bVarMi = true;
	}
	if(!bVarMi) {
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_NO_ITEM_YET"), "-1");
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s \d%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s \w%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"));
	menu_display(IP_IDs, iMenu);
}
@sNovariaZombieExtraMenuCreate_(const IP_IDs, const menu, const item) {
	if(item == MENU_EXIT){ menu_destroy(menu);return PLUGIN_HANDLED; }
	new iData[6],szKey;
	menu_item_getinfo(menu,item,_,iData,charsmax(iData));
	szKey = str_to_num(iData);
	menu_destroy(menu);
	if(szKey < 0 || szKey >= g_iNovariaZombieItemSayi) return PLUGIN_HANDLED;
	if(!zp_get_user_zombie(IP_IDs)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_B", szTag[SayTag]);
		sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU);
		return PLUGIN_HANDLED;
	}
	new iCost = g_iNovariaZombieItemFiyat[szKey];
	if(iCost > 0 && zp_get_user_ammo_packs(IP_IDs) < iCost) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETERSIZ_AP", szTag[SayTag], iCost);
		sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
		@sNovariaZombieExtraMenuCreate(IP_IDs);
		return PLUGIN_HANDLED;
	}
	if(iCost > 0) zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) - iCost);
	new iPluginId = g_iNovariaZombieItemPlugin[szKey];
	if(iPluginId != -1) {
		new szPluginFile[64];
		get_plugin(iPluginId, szPluginFile, charsmax(szPluginFile));
		if(callfunc_begin("novaria_zombie_item_selected", szPluginFile) > 0) {
			callfunc_push_int(IP_IDs);
			callfunc_push_int(szKey);
			callfunc_end();
		}
	}
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ESYA_SATINALINDI", szTag[SayTag], g_szNovariaZombieItemAdi[szKey]);
	return PLUGIN_HANDLED;
}
@sGetPlayerModelControll(IP_IDs) {
            if(!zp_get_user_zombie(IP_IDs)) {
            @sGetPlayerLevelUPArmor(IP_IDs);
            if(get_user_flags(IP_IDs) & szFlag) { set_entvar(IP_IDs, var_armorvalue,  float(IP_IDsCvar[18])); }
            }
            if(!is_user_alive(IP_IDs) || !is_user_connected(IP_IDs)) return;
            set_task(3.0,"@sGetPlayerSpawn",IP_IDs);
            set_task(1.0,"@sGetPlayerClassYetenekControll",IP_IDs+1710);
            @sGetPlayerSinifKaydiSpawnUygula(IP_IDs);
}
@sGetPlayerClassYetenekControll(const iTask) {
    new IP_IDs = iTask - 1710;
    if(!is_user_connected(IP_IDs) || !is_user_alive(IP_IDs)) { g_iSinifKontrolDeneme[IP_IDs] = 0; return PLUGIN_CONTINUE; }
    if(zp_get_user_zombie(IP_IDs) || get_member(IP_IDs, m_iTeam) != TEAM_CT) {
        if(g_iSinifKontrolDeneme[IP_IDs] < 6) {
            g_iSinifKontrolDeneme[IP_IDs]++;
            set_task(1.0,"@sGetPlayerClassYetenekControll",IP_IDs+1710);
        } else {
            g_iSinifKontrolDeneme[IP_IDs] = 0;
        }
        return PLUGIN_CONTINUE;
    }
    g_iSinifKontrolDeneme[IP_IDs] = 0;
    switch(IP_IDszAnt[IP_IDs][sClassValue]) {
        case 0: { return PLUGIN_HANDLED; }
        case 1: {  }
        case 2: { set_entvar(IP_IDs, var_armorvalue, Float: get_entvar(IP_IDs, var_armorvalue) + 35.0); }
        case 3: { set_entvar(IP_IDs,var_maxspeed,500.0);set_task(1.0,"@sGetPlayerAddSpeed",IP_IDs+1707); }
        case 4: { set_entvar(IP_IDs, var_gravity, 0.5);set_task(1.0,"@sGetPlayerAddGravity",IP_IDs+1708); }
    }
    return PLUGIN_CONTINUE;
}
@sGetPlayerAddSpeed(const sTask) {
   new IP_IDs = sTask - 1707;
   if(!is_user_connected(IP_IDs) || !is_user_alive(IP_IDs) || zp_get_user_zombie(IP_IDs)) return;
   set_entvar(IP_IDs, var_maxspeed, 500.0);
   set_task(1.0,"@sGetPlayerAddSpeed",IP_IDs+1707);
}
@sGetPlayerAddGravity(const sTask) {
   new IP_IDs = sTask - 1708;
   if(!is_user_connected(IP_IDs) || !is_user_alive(IP_IDs) || zp_get_user_zombie(IP_IDs)) return;
   set_entvar(IP_IDs, var_gravity, 0.5);
   set_task(1.0,"@sGetPlayerAddGravity",IP_IDs+1708);
}
@sGetPlayerSpawn(const IP_IDs) {
     if(!zp_get_user_zombie(IP_IDs)) {
            switch(IP_IDszAnt[IP_IDs][sPlayerValue]) {
            case 0: { zp_override_user_model(IP_IDs, szHumans[1][0]); }
            case 1: {
            for(new i=1;i<g_iKostumSayi;i++){
            if(szKostum[i][2][0] == 1) {
            zp_override_user_model(IP_IDs, szKostum[IP_IDszAnt[IP_IDs][sPlayerIndex]][1][0]);
            }
            }
            }
            case 2: {
            for(new i=1;i<g_iKostumSayi;i++){
            if(szKostum[i][2][0] == 2) {
            zp_override_user_model(IP_IDs, szKostum[IP_IDszAnt[IP_IDs][sPlayerIndex2]][1][0]);
            }
            }
           }
          }
     }
}
@sGetPlayerLevelUPArmor(const IP_IDs) {
    if(IP_IDszAnt[IP_IDs][sLevel] >= 10 && IP_IDszAnt[IP_IDs][sLevel] <= 19) {
    set_entvar(IP_IDs, var_armorvalue,  10.0);
    } else if(IP_IDszAnt[IP_IDs][sLevel] >= 20 && IP_IDszAnt[IP_IDs][sLevel] <= 29) {
    set_entvar(IP_IDs, var_armorvalue,  15.0);
    } else if(IP_IDszAnt[IP_IDs][sLevel] >= 40) {
    set_entvar(IP_IDs, var_armorvalue,  30.0);
   }
}
@sGetPlayerAimInfo(const IP_IDs) {
    new szName[32], sID = read_data(2), szRankName[32], szAimInfo[192];
    get_user_name(sID, szName, charsmax(szName));
    @sGetRankName(sID, szRankName, charsmax(szRankName));
    format(szAimInfo, charsmax(szAimInfo), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_AIMINFO", szName, get_user_health(sID), get_user_armor(sID), IP_IDszAnt[sID][sCoin], IP_IDszAnt[sID][sLevel], szRankName);
    if(get_member(sID, m_iTeam) == TEAM_TERRORIST) {
        ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud2]);
        ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud3]);
        set_hudmessage(255, 20, 20, -1.0, 0.60, 1, 0.0, 1.0, 0.2, 0.2, -1);
        ShowSyncHudMsg(IP_IDs, IP_IDsGlobal[sHud2], "%s", szAimInfo);
    }
    else if(get_member(sID, m_iTeam) == TEAM_CT) {
        ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud2]);
        ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud3]);
        set_hudmessage(20, 20, 255, -1.0, 0.60, 1, 0.0, 1.0, 0.2, 0.2, -1);
        ShowSyncHudMsg(IP_IDs, IP_IDsGlobal[sHud3], "%s", szAimInfo);
    }
    else {
        ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud2]);
        ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud3]);
    }
}
@sGetPlayerAimInfoRemove(const IP_IDs) {
    ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud2]);
    ClearSyncHud(IP_IDs, IP_IDsGlobal[sHud3]);
}
@sGetPlayerHookSay2(const IP_IDs) {
	new szSay[50],szString[8];
	read_args(szSay, charsmax(szSay));
	remove_quotes(szSay);
	num_to_str(IP_IDsGlobal[sAnswer],szString,7);
	if(equali(szSay,szString) && !IP_IDsQuiz){
		IP_IDszAnt[IP_IDs][sXP] += get_pcvar_num(IP_IDsCvar[8]);sSaveVault(IP_IDs,4);
		remove_task(1051);set_task(get_pcvar_float(IP_IDsCvar[9]),"@sGetPlayerQuizStart",1050);
		IP_IDsQuiz = true;@sGetPlayerRandomCoin(IP_IDs);
	}
}
@sGetPlayerQuizFinish() {
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	for(new iB = 0; iB < iBNum; iB++) {
		client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_TIMEUP", szTag[SayTag], IP_IDsGlobal[sAnswer]);
		client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_NEXT_IN", szTag[SayTag], get_pcvar_num(IP_IDsCvar[9]));
	}
	set_task(get_pcvar_float(IP_IDsCvar[9]),"@sGetPlayerQuizStart",1050);IP_IDsQuiz = true;
}
@sGetPlayerQuizStart() {
    IP_IDsQuiz = false;
    new szKey = random_num(1,4),IP_IDs;
    switch(szKey) {
        case 1: {
            new i = random_num(1,50);
            new l = random_num(1,50);
            new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
            for(new iB = 0; iB < iBNum; iB++)
                client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_ADD", szTag[SayTag], i, l);
            IP_IDsGlobal[sAnswer] = i + l;sPlayConstSound(IP_IDs,Novaria_SND_INFORMATION);
        }
        case 2: {
            new i = random_num(1,10);
            new l = random_num(1,10);
            new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
            for(new iB = 0; iB < iBNum; iB++)
                client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_MUL", szTag[SayTag], i, l);
            IP_IDsGlobal[sAnswer] = i * l;sPlayConstSound(IP_IDs,Novaria_SND_INFORMATION);
        }
        case 3: {
            IP_IDsGlobal[sAnswer] = random_num(1,10);
            new l = random_num(1,20);sPlayConstSound(IP_IDs,Novaria_SND_INFORMATION);
            new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
            for(new iB = 0; iB < iBNum; iB++)
                client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_DIV", szTag[SayTag], IP_IDsGlobal[sAnswer]*l, l);
        }
        case 4: {
            new i = random_num(50,100);
            new l = random_num(1,50);
            new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
            for(new iB = 0; iB < iBNum; iB++)
                client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_SUB", szTag[SayTag], i, l);
            IP_IDsGlobal[sAnswer] = i - l;sPlayConstSound(IP_IDs,Novaria_SND_INFORMATION);
        }
    }
    set_task(get_pcvar_float(IP_IDsCvar[9]),"@sGetPlayerQuizFinish",1051);
}
@sGetPlayerRandomCoin(const IP_IDs) {
    new szName[33],szOduluAP = get_pcvar_num(IP_IDsCvar[30]);
    get_user_name(IP_IDs,szName,charsmax(szName));
    zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) + szOduluAP);
    sPlayConstSound(IP_IDs, Novaria_SND_ODULBILME);
    new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
    for(new iB = 0; iB < iBNum; iB++)
        client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_QUIZ_WINNER", szTag[SayTag], szName, get_pcvar_num(IP_IDsCvar[8]), szOduluAP);
}
@sGetPlayerGiveCoin(IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH],packs[10];
        read_argv(1,kisi,charsmax(kisi));
        read_argv(2,packs,charsmax(packs));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!is_str_num(packs)){return PLUGIN_HANDLED;}
        else{
           IP_IDszAnt[index][sCoin] += str_to_num(packs);sSaveVault(index,1);
           client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_GAVE_COIN", szTag[SayTag], index, str_to_num(packs));
        }
    }
    return PLUGIN_HANDLED;
}
@sGetPlayerRemoveCoin(const IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH],packs[10];
        read_argv(1,kisi,charsmax(kisi));
        read_argv(2,packs,charsmax(packs));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!is_str_num(packs)){return PLUGIN_HANDLED;}
        else{
           IP_IDszAnt[index][sCoin] -= str_to_num(packs);sSaveVault(index,1);
           client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_TOOK_COIN", szTag[SayTag], index, str_to_num(packs));
        }
    }
    return PLUGIN_HANDLED;
}
@sGetPlayerGiveLevel(IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH],packs[10];
        read_argv(1,kisi,charsmax(kisi));
        read_argv(2,packs,charsmax(packs));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!is_str_num(packs)){return PLUGIN_HANDLED;}
        else{
           IP_IDszAnt[index][sXP] += str_to_num(packs);sSaveVault(index,4);@sGetPlayerCheckLevel(index);
           client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_GAVE_XP", szTag[SayTag], index, str_to_num(packs));
        }
    }
    return PLUGIN_HANDLED;
}
// XP degerine gore sLevel'i yeniden hesaplar (asagi yonde de calisir).
// szLevel[] artan sirada esik degerleri tutar; XP hangi esige kadar
// ulasiyorsa sLevel o kadar olur.
stock sRecalcLevelFromXP(const IP_IDs){
    new n = 0;
    while(n < szMaxLevel && IP_IDszAnt[IP_IDs][sXP] >= szLevel[n]) n++;
    IP_IDszAnt[IP_IDs][sLevel] = n;
}
@sGetPlayerRemoveLevel(IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH],packs[10];
        read_argv(1,kisi,charsmax(kisi));
        read_argv(2,packs,charsmax(packs));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!is_str_num(packs)){return PLUGIN_HANDLED;}
        else{
           IP_IDszAnt[index][sXP] -= str_to_num(packs);
           // BUGFIX: XP negatife dusmesin, ayrica sLevel artik XP ile
           // TUTARLI sekilde asagi yonde de yeniden hesaplaniyor
           // (eskiden sadece XP azaliyordu, level hic degismiyordu).
           if(IP_IDszAnt[index][sXP] < 0) IP_IDszAnt[index][sXP] = 0;
           sRecalcLevelFromXP(index);
           sSaveVault(index,4);
           client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_TOOK_XP", szTag[SayTag], index, str_to_num(packs));
        }
    }
    return PLUGIN_HANDLED;
}
// amx_leveldelete sadece XP dusuruyor, sLevel (goruntulenen rutbe/level) hic
// guncellenmiyordu; XP'yi 0 yapsan bile "Level: 32" ekranda kaliyordu. Bu
// komut hem XP'yi hem de sLevel'i gercekten 0'a sifirlar.
@sGetPlayerResetLevel(IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH];
        read_argv(1,kisi,charsmax(kisi));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!index) return PLUGIN_HANDLED;
        IP_IDszAnt[index][sXP] = 0;
        IP_IDszAnt[index][sLevel] = 0;
        sSaveVault(index,4);
        client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_TOOK_XP", szTag[SayTag], index, 0);
    }
    return PLUGIN_HANDLED;
}
@sGetPlayerGiveAmmo(IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH],packs[10];
        read_argv(1,kisi,charsmax(kisi));
        read_argv(2,packs,charsmax(packs));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!is_str_num(packs)){return PLUGIN_HANDLED;}
        else{
           zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) + str_to_num(packs));
           client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_GAVE_AMMO", szTag[SayTag], index, str_to_num(packs));
        }
    }
    return PLUGIN_HANDLED;
}
@sGetPlayerRemoveAmmo(IP_IDs){
    if(get_user_flags(IP_IDs) & ADMIN_RCON){
        new kisi[MAX_NAME_LENGTH],packs[10];
        read_argv(1,kisi,charsmax(kisi));
        read_argv(2,packs,charsmax(packs));
        new index = cmd_target(IP_IDs,kisi,0);
        if(!is_str_num(packs)){return PLUGIN_HANDLED;}
        else{
           zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) - str_to_num(packs));
           client_print_color(index, index, "%L", szNovariaDilKodu[IP_IDszAnt[index][sDilID]], "NOVARIA_MSG_ADMIN_TOOK_AMMO", szTag[SayTag], index, str_to_num(packs));
        }
    }
    return PLUGIN_HANDLED;
}
@sGetPlayerMapGiveCoin(const IP_IDs) {
    if(IP_IDszAnt[IP_IDs][sMapEngel] == 0) {
    client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_COIN_EARNED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[10]));
    IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[10]);IP_IDszAnt[IP_IDs][sMapEngel] = 1;sSaveVault(IP_IDs,1);
    } else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_COIN_ALREADY_MAP", szTag[SayTag]);
}
@sGetPlayerMapGiveAp(const IP_IDs) {
    if(IP_IDszAnt[IP_IDs][sMapEngel2] == 0) {
    client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AMMOPACK_EARNED", szTag[SayTag], get_pcvar_num(IP_IDsCvar[25]));
    zp_set_user_ammo_packs(IP_IDs, zp_get_user_ammo_packs(IP_IDs) + get_pcvar_num(IP_IDsCvar[25]));IP_IDszAnt[IP_IDs][sMapEngel2] = 1;
    } else client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_AMMOPACK_ALREADY_MAP", szTag[SayTag]);
}
@sGetPlayerMultiJumps(const IP_IDs) {
    if(!is_user_alive(IP_IDs)) return HC_CONTINUE;
    if(zp_get_user_zombie(IP_IDs)) {
        IP_IDszAnt[IP_IDs][sJump] = 0;
        return HC_CONTINUE;
    }
    new sFlags = get_entvar(IP_IDs,var_flags);
    new sL_MaxEkstraZipla = @sGetMutluSaatCarpan(MUTLUSAAT_KAT_KASMA) - 1;
    if(~sFlags & FL_ONGROUND && ~get_member(IP_IDs, m_afButtonLast) & IN_JUMP && IP_IDszAnt[IP_IDs][sJump] < sL_MaxEkstraZipla) {
    new Float:szVelocity[3];
    get_entvar(IP_IDs, var_velocity, szVelocity);
    szVelocity[2] = IP_IDsGlobal[sVelocity];
    set_entvar(IP_IDs, var_velocity, szVelocity);
    IP_IDszAnt[IP_IDs][sJump]++;
    } else if(sFlags & FL_ONGROUND) { IP_IDszAnt[IP_IDs][sJump] = 0; }
    return HC_CONTINUE;
}
@sGetPlayerTeamInvison( es_handle, e, ent, host, hostflags, player, pset ){
	if(player) {
		if(host == ent) return;
		if(is_user_alive(host) && IP_IDsBool[host][sHideAllModels] && is_user_alive(ent)){
			set_es( es_handle, ES_Origin, { 999999999.0, 999999999.0, 999999999.0 } );
			return;
		}
		if(is_user_alive(host) && IP_IDsBool[host][sHideTeamModelsOnly] && is_user_alive(ent) && get_user_team(host)==get_user_team(ent)){
			set_es( es_handle, ES_Origin, { 999999999.0, 999999999.0, 999999999.0 } );
			return;
		}
		if(is_user_alive(host) && IP_IDsBool[host][sGizle] && is_user_alive(ent) && get_user_team(host)==get_user_team(ent)){
			set_es( es_handle, ES_Origin, { 999999999.0, 999999999.0, 999999999.0 } );
		}
	}
}
@sGetPlayerTakeDamage(const IP_IDs) {
    new sID = get_user_attacker(IP_IDs);
    if(zp_get_user_zombie(IP_IDs)) { client_print(sID, print_center, "%L", print_center, "NOVARIA_MSG_HP_LABEL", get_user_health(IP_IDs)); }
}

@sGetPlayerKilled(const olen, const olduren, const victim){
	if(IP_IDszAnt[olduren][sEffectID] > 0 && !zp_get_user_zombie(olduren)) {
		sShowEffectSpr(olen,IP_IDsEffect[IP_IDszAnt[olduren][sEffectID]]);
	}
	if(get_member(olduren,m_iTeam) == TEAM_CT)
		if(!IP_IDsBool[olduren][sGorev1]) {
		if(get_member(olen,m_iTeam) == TEAM_TERRORIST) {
			IP_IDszAnt[olduren][sGorevCtKill]++;
		}
	}
	if(get_member(olduren,m_iTeam) == TEAM_TERRORIST)
		if(!IP_IDsBool[olduren][sGorev2]) {
		if(get_member(olen,m_iTeam) == TEAM_CT) {
			IP_IDszAnt[olduren][sGorevInfectEt]++;
		}
	}
	if(olduren != olen && is_user_connected(olduren) && get_member(olduren,m_iTeam) == TEAM_CT && get_member(olen,m_iTeam) == TEAM_TERRORIST) {
        new bNemesisKill = zp_get_user_nemesis(olen);
        new iOduluXP  = bNemesisKill ? get_pcvar_num(IP_IDsCvar[28]) : get_pcvar_num(IP_IDsCvar[26]);
        new iOduluCoin = bNemesisKill ? get_pcvar_num(IP_IDsCvar[29]) : get_pcvar_num(IP_IDsCvar[27]);
        IP_IDszAnt[olduren][sXP] += iOduluXP;
        IP_IDszAnt[olduren][sCoin] += iOduluCoin;
        client_print_color(olduren, olduren, "%L", szNovariaDilKodu[IP_IDszAnt[olduren][sDilID]], "NOVARIA_MSG_KILL_REWARD", szTag[SayTag], bNemesisKill ? "Nemesis'i":"Zombiyi", iOduluXP, iOduluCoin);
        sSaveVault(olduren, 1);
        sSaveVault(olduren, 4);
        @sGetPlayerCheckLevel(olduren);
    }
}
@sGetPlayerKilled2(victim,attacker){
	#pragma unused attacker
	if(!is_user_alive(victim)) set_entvar(victim,var_effects,get_entvar(victim,var_effects)|EF_NODRAW);
}
@sGetPlayerTimed(const IP_IDs) {
	if(!IP_IDsBool[IP_IDs][sGorev4]){
		set_task(60.0,"@sGetPlayerTimed",IP_IDs);
		IP_IDszAnt[IP_IDs][sGorevSureliOyna]++
	}
}
@sGetPlayerCurWeapon(const IP_IDs) {
	static const szMaxClip[] = { 0,13,0,10,0,7,0,30,30,0,15,20,25,30,35,25,12,20,10,30,100,8,30,30,20,0,7,30,30,0,50 };
	new szWeapon = read_data(2);
	if(szMaxClip[szWeapon] < 0) { return PLUGIN_CONTINUE; }
	new szActiviteItem = get_member(IP_IDs, m_pActiveItem);
	set_member(szActiviteItem, m_Weapon_iClip, szMaxClip[szWeapon]);
	return PLUGIN_HANDLED;
}
@sGetPlayerHookSay(const IP_IDs) {
	if(IP_IDsBool[IP_IDs][sBekliyorSifre] || IP_IDsBool[IP_IDs][sBekliyorSure]) {
		return PLUGIN_CONTINUE;
	}
	new sMessage[312];
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage);
	if(!IP_IDsCvar[5])
		return PLUGIN_CONTINUE;
	if(sMessage[0] == '@' || sMessage[0] == '.' || sMessage[0] == '/' || sMessage[0] == '!' || equal(sMessage, ""))
   		return PLUGIN_CONTINUE;
   	if(IP_IDsCvar[6]) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ADMIN_CHAT_CLOSED", szTag[SayTag]);
   		return PLUGIN_HANDLED;
	}
   	if(strlen(sMessage) > 300) {
   		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MSG_TOO_LONG", szTag[SayTag]);
   		return PLUGIN_HANDLED;
   	}
   	new sRet,sError[128],sResult,Regex:sSayCheck;
	sSayCheck = regex_compile("[0-9]", sRet, sError, charsmax(sError));
	sResult = regex_match_all_c(sMessage, sSayCheck, sRet);
	regex_free(sSayCheck);
   	if(sResult > 5) {
   		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ADVERTISING_BLOCKED", szTag[SayTag]);
   		return PLUGIN_HANDLED;
	}
	new sNewData[128],sColor[10];
	copy(sNewData,charsmax(sNewData),szChatSay);
	get_user_team(IP_IDs, sColor, charsmax(sColor));
	is_user_alive(IP_IDs) ? (replace_all(sNewData,charsmax(sNewData),"{DEAD}","")):(replace_all(sNewData,charsmax(sNewData),"{DEAD}","(x) "));
	(get_user_flags(IP_IDs) & ADMIN_RESERVATION) ? replace_all(sNewData,charsmax(sNewData),"{FLAG}","^x04"):replace_all(sNewData,charsmax(sNewData),"{FLAG}", "^x01");
	replace_all(sNewData,charsmax(sNewData),"{YETKI}",fmt("%s", IP_IDsString[IP_IDs]));
	new szChatRankName[32];
	@sGetRankName(IP_IDs, szChatRankName, charsmax(szChatRankName));
	replace_all(sNewData,charsmax(sNewData),"{LEVEL}",szChatRankName);
	new szXPLabel[16];
	format(szXPLabel, charsmax(szXPLabel), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_CHAT_XP_LABEL");
	replace_all(sNewData,charsmax(sNewData),"{XPLABEL}",szXPLabel);
	replace_all(sNewData,charsmax(sNewData),"{XP}",fmt("%d", IP_IDszAnt[IP_IDs][sXP]));
	replace_all(sNewData,charsmax(sNewData),"{MESSAGE}",sMessage);
	replace_all(sNewData,charsmax(sNewData),"{NAME}",fmt("%n",IP_IDs));
	@sGetPlayerSendMesaage(sColor, is_user_alive(IP_IDs) ? 1:0, sNewData);
	return PLUGIN_HANDLED;
}
@sGetPlayerCommondBloced(const IP_IDs) {
   new szArg[192];
   read_args(szArg, charsmax( szArg ));
   remove_quotes(szArg);
   return (szArg[0] == '/');
}
// say_team icin @sGetPlayerHookSay ile birebir ayni tag/rutbe formatlamasi,
// tek fark: mesaj herkese degil sadece gonderenin takimina gidiyor.
@sGetPlayerHookSayTeam(const IP_IDs) {
	if(IP_IDsBool[IP_IDs][sBekliyorSifre] || IP_IDsBool[IP_IDs][sBekliyorSure]) {
		return PLUGIN_CONTINUE;
	}
	new sMessage[312];
	read_args(sMessage, charsmax(sMessage));
	remove_quotes(sMessage);
	if(!IP_IDsCvar[5])
		return PLUGIN_CONTINUE;
	if(sMessage[0] == '@' || sMessage[0] == '.' || sMessage[0] == '/' || sMessage[0] == '!' || equal(sMessage, ""))
   		return PLUGIN_CONTINUE;
   	if(IP_IDsCvar[6]) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ADMIN_CHAT_CLOSED", szTag[SayTag]);
   		return PLUGIN_HANDLED;
	}
   	if(strlen(sMessage) > 300) {
   		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MSG_TOO_LONG", szTag[SayTag]);
   		return PLUGIN_HANDLED;
   	}
   	new sRet,sError[128],sResult,Regex:sSayCheck;
	sSayCheck = regex_compile("[0-9]", sRet, sError, charsmax(sError));
	sResult = regex_match_all_c(sMessage, sSayCheck, sRet);
	regex_free(sSayCheck);
   	if(sResult > 5) {
   		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ADVERTISING_BLOCKED", szTag[SayTag]);
   		return PLUGIN_HANDLED;
	}
	new sNewData[128],sColor[10];
	copy(sNewData,charsmax(sNewData),szChatSay);
	get_user_team(IP_IDs, sColor, charsmax(sColor));
	is_user_alive(IP_IDs) ? (replace_all(sNewData,charsmax(sNewData),"{DEAD}","")):(replace_all(sNewData,charsmax(sNewData),"{DEAD}","(x) "));
	(get_user_flags(IP_IDs) & ADMIN_RESERVATION) ? replace_all(sNewData,charsmax(sNewData),"{FLAG}","^x04"):replace_all(sNewData,charsmax(sNewData),"{FLAG}", "^x01");
	replace_all(sNewData,charsmax(sNewData),"{YETKI}",fmt("%s", IP_IDsString[IP_IDs]));
	new szChatRankName[32];
	@sGetRankName(IP_IDs, szChatRankName, charsmax(szChatRankName));
	replace_all(sNewData,charsmax(sNewData),"{LEVEL}",szChatRankName);
	new szXPLabel[16];
	format(szXPLabel, charsmax(szXPLabel), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_CHAT_XP_LABEL");
	replace_all(sNewData,charsmax(sNewData),"{XPLABEL}",szXPLabel);
	replace_all(sNewData,charsmax(sNewData),"{XP}",fmt("%d", IP_IDszAnt[IP_IDs][sXP]));
	replace_all(sNewData,charsmax(sNewData),"{MESSAGE}",sMessage);
	replace_all(sNewData,charsmax(sNewData),"{NAME}",fmt("%n",IP_IDs));
	@sGetPlayerSendMesaageTeam(get_user_team(IP_IDs), sColor, is_user_alive(IP_IDs) ? 1:0, sNewData);
	return PLUGIN_HANDLED;
}
@sGetPlayerCephane() {
	if(IP_IDsGlobal[sCountDown] > 0) return;
	// Diger plugin round bitisinde "mp3 stop" calistirabiliyor; bu sesin
	// kesilmemesi icin baslatmayi kucuk bir gecikmeyle yapiyoruz.
	remove_task(3163);
	set_task(0.3, "@sGetPlayerCephanePlaySound", 3163);
	remove_task(3162);
	IP_IDsGlobal[sCountDown] = get_pcvar_num(IP_IDsCvar[19]);
	IP_IDsGlobal[sCountDownSound] = get_pcvar_num(IP_IDsCvar[20]);
	@sGetPlayerCountDown();
}
@sGetPlayerCephanePlaySound() {
	// Round sonu sarkisi hala calmasi gerekiyorsa, uzerine yeni/rastgele
	// bir sarki baslatma. Onceden burada ayni sarki "mp3 play" ile bastan
	// tekrar baslatiliyordu; fakat "mp3 play" komutu her cagrildiginda
	// sarkiyi sifirdan baslatiyor, bu da round basinda (oyuncular doguncaya
	// kadar gecen surede) sarkinin bastan tekrar calmasina sebep oluyordu.
	// Sarki zaten calmaya devam ettigi icin burada hicbir sey yapmadan
	// cikmak yeterli; suresi dolunca g_bRoundSonuSesiCaliyor otomatik
	// olarak false olacak (@sRoundSonuSesiBitti).
	if(g_bRoundSonuSesiCaliyor) {
		return;
	}
	new sL_Toplam = sizeof(szReady);
	if(sL_Toplam <= 0) return;
	new sL_Index = random_num(0, sL_Toplam - 1);
	if(sL_Toplam > 1) {
		while(sL_Index == g_iSonRoundEndSound) {
			sL_Index = random_num(0, sL_Toplam - 1);
		}
	}
	g_iSonRoundEndSound = sL_Index;
	client_cmd(0, "mp3 play ^"sound/%s^"", szReady[sL_Index]);
}
@sGetPlayerCountDown() {
    if(IP_IDsGlobal[sCountDown] >= 1) {
        new IP_IDsPlayer[32], sNum;
        get_players(IP_IDsPlayer, sNum);
        set_dhudmessage(random_num(57, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.39, 0, 6.0, 0.001, 0.1, 1.0)
        for(new i = 0; i < sNum; i++) {
            new IP_IDs = IP_IDsPlayer[i];
            new szCountdownMsg[64];
            format(szCountdownMsg, charsmax(szCountdownMsg), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_COUNTDOWN_10PLUS", IP_IDsGlobal[sCountDown]);
            show_dhudmessage(IP_IDs, "%s", szCountdownMsg)
        }
        set_task(1.0, "@sGetPlayerCountDown", 3162);
        if(IP_IDsGlobal[sCountDown] <= 10) {
            new sL_SesIndex = IP_IDsGlobal[sCountDown] - 1;
            if(sL_SesIndex < 0) sL_SesIndex = 0;
            if(sL_SesIndex > charsmax(szCountDown)) sL_SesIndex = charsmax(szCountDown);
            sGetPlayCountSound(szCountDown[sL_SesIndex])
        }
        IP_IDsGlobal[sCountDown]--
    }
}
public plugin_natives() {
	register_native("novaria_vip_extra_items", "@sNovariaVipExtraItemsNative");
	register_native("novaria_zombie_extra_items", "@sNovariaZombieExtraItemsNative");
	register_native("coin_get_user","@sGetCoinNative", 1);
	register_native("coin_set_user","@sSetCoinNative", 1);
	register_native("get_user_xp", "@sGetXPNative", 1)
	register_native("set_user_xp", "@sSetXPNative", 1);
	register_native("get_user_level", "@sGetLevelNative", 1);
	register_native("set_user_level", "@sSetLevelNative", 1);
	register_native("get_user_maxlevel","@sGetMaxLevelNative", 1);
	register_native("novaria_hero_kacak_var", "@sNovariaHeroKacakNative", 1);
	register_native("novaria_register_extra_knife", "@sNovariaRegisterExtraKnifeNative");
}
@sNovariaRegisterExtraKnifeNative(iPlugin, iParams) {
	if(g_iExtraBicakSayi >= MAX_EXTRA_BICAK) return 0;
	new idx = ++g_iExtraBicakSayi;
	get_string(1, g_szExtraBicakAd[idx], 31);
	get_string(2, g_szExtraBicakGive[idx], 31);
	get_string(3, g_szExtraBicakRemove[idx], 31);
	g_iExtraBicakFiyat[idx] = get_param(4);
	return idx;
}
@sGetPlayerRoundStart(const IP_IDs) { IP_IDsGlobal[sRandomColor] = random_num(1, 100);client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_VIRUS_WARNING", szTag[SayTag]); }
@sGetPlayerFallDamage() { SetHookChainReturn(ATYPE_FLOAT, 0);return PLUGIN_HANDLED; }
@sGetHudRGBRenk(&iRed, &iGreen, &iBlue) {
	new iAdim = floatround(get_gametime() * 60.0) % 768;
	new iAsama = iAdim / 256;
	new iKalan = iAdim % 256;
	switch(iAsama) {
		case 0: { iRed = 255 - iKalan; iGreen = iKalan; iBlue = 0; }
		case 1: { iRed = 0; iGreen = 255 - iKalan; iBlue = iKalan; }
		default: { iRed = iKalan; iGreen = 0; iBlue = 255 - iKalan; }
	}
}
@sGetMutluSaatCarpan(const iKategori) {
	if(g_bMutluSaatZorlaKapali) return 1;
	if(iKategori == MUTLUSAAT_KAT_COIN && !g_bMutluSaatKatCoin) return 1;
	if(iKategori == MUTLUSAAT_KAT_XP && !g_bMutluSaatKatXP) return 1;
	if(iKategori == MUTLUSAAT_KAT_KASMA && !g_bMutluSaatKatKasma) return 1;
	new sL_CvarCarpan = 2;
	if(IP_IDsCvar[31]) sL_CvarCarpan = get_pcvar_num(IP_IDsCvar[31]);
	if(sL_CvarCarpan < 1) sL_CvarCarpan = 1;
	if(g_iMutluSaatCarpanManuel > 0) return g_iMutluSaatCarpanManuel;
	new szSaat[3];
	get_time("%H", szSaat, charsmax(szSaat));
	new iSaat = str_to_num(szSaat);
	if(iSaat >= 18 && iSaat < 23) return sL_CvarCarpan;
	if(iSaat >= 1 && iSaat < 7) return sL_CvarCarpan + 1;
	return 1;
}
@sGetPlayerCoinTime(const IP_IDs) { new sL_Carpan = @sGetMutluSaatCarpan(MUTLUSAAT_KAT_COIN);IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[7]) * sL_Carpan;client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_PLAYTIME_COIN_REWARD", szTag[SayTag], szCoinTime, get_pcvar_num(IP_IDsCvar[7]) * sL_Carpan);sSaveVault(IP_IDs,1); }
@sGetCoinNative(IP_IDs) { return IP_IDszAnt[IP_IDs][sCoin]; }
@sSetCoinNative(IP_IDs, ammount) { IP_IDszAnt[IP_IDs][sCoin] = ammount;return 1; }
@sGetXPNative(IP_IDs) { return IP_IDszAnt[IP_IDs][sXP]; }
@sSetXPNative(IP_IDs, amount) { IP_IDszAnt[IP_IDs][sXP] = amount; }
@sGetLevelNative(IP_IDs) { return IP_IDszAnt[IP_IDs][sLevel]; }
@sSetLevelNative(IP_IDs, amount) { IP_IDszAnt[IP_IDs][sLevel] = amount; }
@sGetMaxLevelNative(IP_IDs){
   new szGeriLevel;
   if(IP_IDszAnt[IP_IDs][sLevel] > (szMaxLevel-1)) {
   szGeriLevel = szLevel[szMaxLevel-1]
   } else {
   szGeriLevel = szLevel[IP_IDszAnt[IP_IDs][sLevel]]
   } return szGeriLevel
}
@sGetPlayerRoundEndSoundPlay() {
	// BUGFIX: artik cephane/hazir anonsu (szReady) yerine gercek round-sonu
	// sarki listesinden (szRoundEndSongs) caliyor.
	new sL_Toplam = sizeof(szRoundEndSongs);
	if(sL_Toplam <= 0) return;
	new sL_Index = random_num(0, sL_Toplam - 1);
	if(sL_Toplam > 1) {
		while(sL_Index == g_iSonRoundEndSound) {
			sL_Index = random_num(0, sL_Toplam - 1);
		}
	}
	g_iSonRoundEndSound = sL_Index;
	client_cmd(0, "mp3 play ^"sound/%s^"", szRoundEndSongs[sL_Index]);

	// Sarki calmaya basladi; suresi dolana kadar yeni round baslasa
	// dahi baska bir sarkinin bunun ustune yazilmasini engelle.
	g_bRoundSonuSesiCaliyor = true;
	remove_task(TASKID_ROUNDEND_SES_BITTI);
	set_task(Novaria_ROUNDEND_SES_SURESI, "@sRoundSonuSesiBitti", TASKID_ROUNDEND_SES_BITTI);
}
@sRoundSonuSesiBitti() {
	g_bRoundSonuSesiCaliyor = false;
}
@sGetPlayerRoundEnd(Win_Team) {
    new szWinColorKey[40];
    if(IP_IDsGlobal[sRandomColor] >= 96) 
        copy(szWinColorKey, charsmax(szWinColorKey), "NOVARIA_MSG_WINNING_COLOR_GREEN");
    else if(IP_IDsGlobal[sRandomColor]%2 == 0) 
        copy(szWinColorKey, charsmax(szWinColorKey), "NOVARIA_MSG_WINNING_COLOR_BLACK");
    else 
        copy(szWinColorKey, charsmax(szWinColorKey), "NOVARIA_MSG_WINNING_COLOR_RED");
        
    new szPlayer[32], szNum, sID;
    get_players(szPlayer, szNum);
    
    for(new i; i < szNum; i++) {
        sID = szPlayer[i];
        client_print_color(sID, sID, "%L", szNovariaDilKodu[IP_IDszAnt[sID][sDilID]], szWinColorKey, szTag[SayTag]);
        IP_IDszAnt[sID][sGorevRoundOyna] += 1;
    }
    
    for(new IP_IDs = 1; IP_IDs <= MaxClients; IP_IDs++) {
        if(!is_user_connected(IP_IDs)) { 
            continue; 
        }
        if(IP_IDszAnt[IP_IDs][sTurSay] < 3) {
            IP_IDszAnt[IP_IDs][sTurSay]++;
        }
    }
    
    switch(Win_Team) {
        case WINSTATUS_TERRORISTS: {
            new IP_IDsPlayer[32], sL_NumsT, IP_IDs, sL_CarpanXP1 = @sGetMutluSaatCarpan(MUTLUSAAT_KAT_XP), sL_CarpanCoin1 = @sGetMutluSaatCarpan(MUTLUSAAT_KAT_COIN);
            get_players(IP_IDsPlayer, sL_NumsT, "acehi", "TERRORIST");
            
            for(new i; i < sL_NumsT; i++) {
                IP_IDs = IP_IDsPlayer[i];
                IP_IDszAnt[IP_IDs][sXP] += get_pcvar_num(IP_IDsCvar[1]) * sL_CarpanXP1;
                IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[2]) * sL_CarpanCoin1;
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ALL_INFECTED_REWARD", szTag[SayTag], get_pcvar_num(IP_IDsCvar[1]) * sL_CarpanXP1, get_pcvar_num(IP_IDsCvar[2]) * sL_CarpanCoin1);
                sSaveVault(IP_IDs, 1);
                sSaveVault(IP_IDs, 4);
                @sGetPlayerCheckLevel(IP_IDs);
            }
        }
        case WINSTATUS_CTS: {
            new IP_IDsPlayer[32], sL_NumsCT, IP_IDs, sL_CarpanXP2 = @sGetMutluSaatCarpan(MUTLUSAAT_KAT_XP), sL_CarpanCoin2 = @sGetMutluSaatCarpan(MUTLUSAAT_KAT_COIN);
            get_players(IP_IDsPlayer, sL_NumsCT, "acehi", "CT");
            
            for(new i; i < sL_NumsCT; i++) {
                IP_IDs = IP_IDsPlayer[i];
                IP_IDszAnt[IP_IDs][sXP] += get_pcvar_num(IP_IDsCvar[3]) * sL_CarpanXP2;
                IP_IDszAnt[IP_IDs][sCoin] += get_pcvar_num(IP_IDsCvar[4]) * sL_CarpanCoin2;
                client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SURVIVED_REWARD", szTag[SayTag], get_pcvar_num(IP_IDsCvar[3]) * sL_CarpanXP2, get_pcvar_num(IP_IDsCvar[4]) * sL_CarpanCoin2);
                sSaveVault(IP_IDs, 1);
                sSaveVault(IP_IDs, 4);
                @sGetPlayerCheckLevel(IP_IDs);
            }
        }
    }
    
    remove_task(3164);
    set_task(0.5, "@sGetPlayerRoundEndSoundPlay", 3164);
}
@sGetPlayerMainHud(const IP_IDs) {
    if(!is_user_connected(IP_IDs) || !is_user_alive(IP_IDs) || IP_IDsBool[IP_IDs][sHudDurum]) return;
    new szRankName[32];
    @sGetRankName(IP_IDs, szRankName, charsmax(szRankName));
    new iRenk = IP_IDszAnt[IP_IDs][sHudRenk], iRed, iGreen, iBlue;
    if(iRenk == HUD_RENK_RGB) {
        @sGetHudRGBRenk(iRed, iGreen, iBlue);
    } else {
        iRed = szHudRenkRGB[iRenk][0];
        iGreen = szHudRenkRGB[iRenk][1];
        iBlue = szHudRenkRGB[iRenk][2];
    }
    new Float:fX = szHudKonumXY[IP_IDszAnt[IP_IDs][sHudKonum]][0];
    new Float:fY = szHudKonumXY[IP_IDszAnt[IP_IDs][sHudKonum]][1];
    new sL_Carpan = @sGetMutluSaatCarpan(-1);
    new szMutluSaat[48];
    if(sL_Carpan > 1) {
        format(szMutluSaat, charsmax(szMutluSaat), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_MUTLUSAAT_AKTIF", sL_Carpan);
    } else {
        format(szMutluSaat, charsmax(szMutluSaat), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_MUTLUSAAT_PASIF");
    }
    new szSinifName[32];
    if(IP_IDszAnt[IP_IDs][sClassValue] == -1) {
        format(szSinifName, charsmax(szSinifName), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_CLASS_NOT_SELECTED");
    } else {
        format(szSinifName, charsmax(szSinifName), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], szSinifAdiKey[IP_IDszAnt[IP_IDs][sClassValue]]);
    }
    new szAktifMod[48];
    if(!g_bEnfeksiyonBasladi) {
        format(szAktifMod, charsmax(szAktifMod), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_MOD_BEKLENIYOR");
    } else if(g_szAktifModAdi[0]) {
        format(szAktifMod, charsmax(szAktifMod), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_MOD_AKTIF", g_szAktifModAdi);
    } else {
        format(szAktifMod, charsmax(szAktifMod), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_MOD_NORMAL");
    }
    new szMainHud[256];
    new szXPLabel[24];
    format(szXPLabel, charsmax(szXPLabel), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_CHAT_XP_LABEL");
    format(szMainHud, charsmax(szMainHud), "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_HUD_MAINHUD",
     zp_get_user_ammo_packs(IP_IDs),
     IP_IDszAnt[IP_IDs][sCoin],
     szRankName,
     IP_IDszAnt[IP_IDs][sLevel],
     szXPLabel,
     IP_IDszAnt[IP_IDs][sXP],
     szSinifName,
     szAktifMod,
     szMutluSaat);
    set_hudmessage(iRed, iGreen, iBlue, fX, fY, 0, 0.0, 1.1, 0.0, 0.0, -1);
    ShowSyncHudMsg(IP_IDs, IP_IDsGlobal[sHud], "%s", szMainHud);
}
public plugin_precache() {
     LoadNovariaModeller();
     for(new i=1;i<sizeof(szHumans);i++) { precache_model(fmt("models/player/%s/%s.mdl",szHumans[i],szHumans[i])); }
     for(new i=1;i<g_iKostumSayi;i++) { precache_model(fmt("models/player/%s/%s.mdl", szKostum[i][1],szKostum[i][1])); }
     for(new i=0;i<sizeof(szCountDown);i++) { engfunc(EngFunc_PrecacheSound, szCountDown[i]); }
     for(new i=1;i<sizeof(szDeathEffect);i++) { IP_IDsEffect[i] = precache_model(szDeathEffect[i][1]); }
     for(new i=1; i <g_iKanatSayi;i++) { IP_IDsKanatBul[i] = precache_model(szKanat[i][1]); }
     for(new i=1;i<sizeof(szKnife);i++) {
         precache_model(szKnife[i][1]);
         if(szKnife[i][3][0]) precache_model(szKnife[i][3]);
     }
     for(new i=1;i<sizeof(szBicakNormal);i++) {
         if(file_exists(szBicakNormal[i][1])) precache_model(szBicakNormal[i][1]);
         else log_amx("[Novaria] UYARI: ^"%s^" (Normal Bicak) bulunamadi, precache atlandi.", szBicakNormal[i][1]);
         if(szBicakNormal[i][3][0] && file_exists(szBicakNormal[i][3])) precache_model(szBicakNormal[i][3]);
     }
     // KOK NEDEN DUZELTMESI: VIP/S-Vip/Gold/Diamond/Premium bicak modelleri hic precache edilmiyordu.
     // Bir oyuncu bu menulerden bicak sectiginde, deploy sirasinda precache edilmemis bir model
     // view/world model olarak sunucuya gonderiliyordu; bu da "not precached" nedeniyle SUNUCU CRASH'ine
     // sebep oluyordu. Asagidaki dongu bu 5 tabloyu da precache eder (dosya yoksa loga uyari yazip atlar,
     // boylece crash yerine sadece o model gorunmez/varsayilana duser).
     for(new i=1;i<sizeof(szBicakVip);i++) {
         if(file_exists(szBicakVip[i][1])) precache_model(szBicakVip[i][1]);
         else log_amx("[Novaria] UYARI: ^"%s^" (VIP Bicak) bulunamadi, precache atlandi.", szBicakVip[i][1]);
         if(szBicakVip[i][3][0] && file_exists(szBicakVip[i][3])) precache_model(szBicakVip[i][3]);
     }
     for(new i=1;i<sizeof(szBicakSVip);i++) {
         if(file_exists(szBicakSVip[i][1])) precache_model(szBicakSVip[i][1]);
         else log_amx("[Novaria] UYARI: ^"%s^" (S-Vip Bicak) bulunamadi, precache atlandi.", szBicakSVip[i][1]);
         if(szBicakSVip[i][3][0] && file_exists(szBicakSVip[i][3])) precache_model(szBicakSVip[i][3]);
     }
     for(new i=1;i<sizeof(szBicakGoldVip);i++) {
         if(file_exists(szBicakGoldVip[i][1])) precache_model(szBicakGoldVip[i][1]);
         else log_amx("[Novaria] UYARI: ^"%s^" (Gold Vip Bicak) bulunamadi, precache atlandi.", szBicakGoldVip[i][1]);
         if(szBicakGoldVip[i][3][0] && file_exists(szBicakGoldVip[i][3])) precache_model(szBicakGoldVip[i][3]);
     }
     for(new i=1;i<sizeof(szBicakDiamondVip);i++) {
         if(file_exists(szBicakDiamondVip[i][1])) precache_model(szBicakDiamondVip[i][1]);
         else log_amx("[Novaria] UYARI: ^"%s^" (Diamond Vip Bicak) bulunamadi, precache atlandi.", szBicakDiamondVip[i][1]);
         if(szBicakDiamondVip[i][3][0] && file_exists(szBicakDiamondVip[i][3])) precache_model(szBicakDiamondVip[i][3]);
     }
     for(new i=1;i<sizeof(szBicakPremiumVip);i++) {
         if(file_exists(szBicakPremiumVip[i][1])) precache_model(szBicakPremiumVip[i][1]);
         else log_amx("[Novaria] UYARI: ^"%s^" (Premium Vip Bicak) bulunamadi, precache atlandi.", szBicakPremiumVip[i][1]);
         if(szBicakPremiumVip[i][3][0] && file_exists(szBicakPremiumVip[i][3])) precache_model(szBicakPremiumVip[i][3]);
     }
     for(new i=0;i<sizeof(szSoundEffect);i++) { precache_sound(szSoundEffect[i][0]); }
     for(new i=0;i<sizeof(szReady);i++) 
     { 
         new szReadyPrecache[64];
         format(szReadyPrecache, charsmax(szReadyPrecache), "sound/%s", szReady[i]);
         engfunc(EngFunc_PrecacheGeneric, szReadyPrecache);
     }
     // BUGFIX: round sonu sarkilari (szRoundEndSongs) daha once hic precache
     // edilmiyordu ve @sGetPlayerRoundEndSoundPlay yanlislikla szReady'i
     // kullaniyordu - artik kendi dosyalari var, onlari da precache et.
     for(new i=0;i<sizeof(szRoundEndSongs);i++) 
     { 
         new szRoundEndPrecache[64];
         format(szRoundEndPrecache, charsmax(szRoundEndPrecache), "sound/%s", szRoundEndSongs[i]);
         if(file_exists(szRoundEndPrecache)) engfunc(EngFunc_PrecacheGeneric, szRoundEndPrecache);
         else log_amx("[Novaria] UYARI: ^"%s^" (Round Sonu Sarkisi) bulunamadi, precache atlandi. sound/roundend/ klasorune gercek mp3 dosyalarinizi koyup szRoundEndSongs dizisini guncelleyin.", szRoundEndPrecache);
     }
     precache_sound(szLevelUpSound);
     // BUGFIX: level-up sprite kaldirildigi icin precache_model cagrisi da kaldirildi
     for(new i=0;i<NUM_KUYRUK_SPR;i++) { g_iKuyrukSpr[i] = precache_model(szKuyrukSpr[i]); }
}
LoadNovariaTema() {
	new szData[8], iTimestamp;
	if(nvault_lookup(IP_IDsGlobal[sVault], "novaria_tema_aktif", szData, charsmax(szData), iTimestamp)) {
		NovariaTemaUygulaSessiz(str_to_num(szData));
	}
}
SaveNovariaTema() {
	new szNumToStr[8];
	num_to_str(g_iNovariaTemaAktif, szNumToStr, charsmax(szNumToStr));
	nvault_set(IP_IDsGlobal[sVault], "novaria_tema_aktif", szNumToStr);
}
NovariaTemaUygulaSessiz(const iTema) {
	if(iTema < 0 || iTema >= sizeof(szNovariaTema)) return;
	g_iNovariaTemaAktif = iTema;
	copy(szTag[MenuTag], charsmax(szTag[]), szNovariaTema[iTema][sTemaUzun]);
	copy(szTag[KisaTag], charsmax(szTag[]), szNovariaTema[iTema][sTemaKisa]);
}
NovariaTemaUygula(const IP_IDs, const iTema) {
	if(iTema < 0 || iTema >= sizeof(szNovariaTema)) return;
	NovariaTemaUygulaSessiz(iTema);
	SaveNovariaTema();
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_THEME_ACTIVATED", szTag[SayTag], szNovariaTema[iTema][sTemaAd]);
}
stock Novaria_TirnakliSatirBol(const szText[], szParca[][64], iMaxParca) {
	new iSayac = 0, iLen = strlen(szText), i = 0;
	while(i < iLen && iSayac < iMaxParca) {
		while(i < iLen && szText[i] != '"') i++;
		if(i >= iLen) break;
		i++;
		new iStart = i;
		while(i < iLen && szText[i] != '"') i++;
		new iCopyLen = i - iStart;
		if(iCopyLen > 63) iCopyLen = 63;
		if(iCopyLen < 0) iCopyLen = 0;
		copy(szParca[iSayac], iCopyLen, szText[iStart]);
		szParca[iSayac][iCopyLen] = 0;
		iSayac++;
		if(i < iLen) i++;
	}
	return iSayac;
}
Novaria_ModellerIniOlustur(const szPath[]) {
	new iFile = fopen(szPath, "wt");
	if(!iFile) return;
	fprintf(iFile, "; Model format: ^"Name^" ^"Model^" ^"Type^" ^"Price^" ^"Level^" ^"Category(Karakter/Kanat)^"^n");
	fclose(iFile);
	log_amx("novaria_modeller.ini bulunamadi, BOS olarak olusturuldu (kostum/kanat artik SADECE bu dosyadan yonetilir).");
}
LoadNovariaModeller() {
	new szPath[128];
	get_configsdir(szPath, charsmax(szPath));
	format(szPath, charsmax(szPath), "%s/novaria_modeller.ini", szPath);
	if(!file_exists(szPath))
		Novaria_ModellerIniOlustur(szPath);
	new iFile = fopen(szPath, "rt");
	if(!iFile) {
		log_amx("novaria_modeller.ini acilamadi, modeller yuklenemedi.");
		return;
	}
	g_iKostumSayi = 1;
	g_iKanatSayi = 1;
	new szLine[256], szParca[6][64], iAdet, szYolTest[128];
	while(!feof(iFile)) {
		fgets(iFile, szLine, charsmax(szLine));
		trim(szLine);
		if(!szLine[0] || szLine[0] == ';' || szLine[0] == '#' || szLine[0] == '[') continue;
		iAdet = Novaria_TirnakliSatirBol(szLine, szParca, sizeof(szParca));
		if(iAdet < 6) continue;
		if(equali(szParca[5], "Karakter") || equali(szParca[5], "Kostum")) {
			if(g_iKostumSayi >= MAX_KOSTUM) { log_amx("[Novaria] MAX_KOSTUM limiti (%d) doldu, ^"%s^" atlandi.", MAX_KOSTUM, szParca[0]); continue; }
			replace_all(szParca[1], 63, "models/player/", "");
			format(szYolTest, charsmax(szYolTest), "models/player/%s/%s.mdl", szParca[1], szParca[1]);
			if(!file_exists(szYolTest)) {
				log_amx("Kostum modeli sunucuda bulunamadi (modeller atlandi, cokme onlendi): %s -> %s", szParca[0], szYolTest);
				continue;
			}
			copy(szKostum[g_iKostumSayi][0], 47, szParca[0]);
			copy(szKostum[g_iKostumSayi][1], 47, szParca[1]);
			szKostum[g_iKostumSayi][2][0] = str_to_num(szParca[2]);
			szKostum[g_iKostumSayi][3][0] = str_to_num(szParca[3]);
			szKostum[g_iKostumSayi][4][0] = str_to_num(szParca[4]);
			g_iKostumSayi++;
		}
		else if(equali(szParca[5], "Kanat")) {
			if(g_iKanatSayi >= MAX_KANAT) { log_amx("MAX_KANAT limiti (%d) doldu, ^"%s^" atlandi.", MAX_KANAT, szParca[0]); continue; }
			if(!file_exists(szParca[1])) {
				log_amx("Kanat modeli sunucuda bulunamadi (modeller atlandi, cokme onlendi): %s -> %s", szParca[0], szParca[1]);
				continue;
			}
			copy(szKanat[g_iKanatSayi][0], 47, szParca[0]);
			copy(szKanat[g_iKanatSayi][1], 47, szParca[1]);
			szKanat[g_iKanatSayi][2][0] = str_to_num(szParca[2]);
			szKanat[g_iKanatSayi][3][0] = str_to_num(szParca[3]);
			szKanat[g_iKanatSayi][4][0] = str_to_num(szParca[4]);
			g_iKanatSayi++;
		}
	}
	fclose(iFile);
	log_amx("İni'den yuklendi -> Karakter: %d, Kanat: %d", g_iKostumSayi - 1, g_iKanatSayi - 1);
}
@sGetPlayerNovariaAnaMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_MAINMENU"), "@sGetPlayerNovariaAnaMenuCreate_")

    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SILAH_AL"), "1")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_EXTRA_PLATFORM"), "2")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SINIF_PLATFORM"), "3")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_BICAK_MENU"), "4")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_JETON_MARKET"), "5")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_ENVANTER_MENU"), "6")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_ISLEMLER_AYARLAR"), "7")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YETKILI_PLATFORM"), "8")

    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YONETICI_PANELI"), "9")

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"), "0")
    menu_setprop(iMenu, MPROP_PERPAGE, 0)
    menu_display(IP_IDs, iMenu, 0)

    return PLUGIN_HANDLED;
}
@sGetPlayerNovariaAnaMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { client_cmd(IP_IDs, "buy"); }
		case 2: { @sNovariaVipExtraAnaMenuCreate(IP_IDs); }
		case 3: {
			@sGetPlayerSinifMenuCreate(IP_IDs);
		}
		case 4: { @sGetPlayerKnifeMenuCreate(IP_IDs); }
		case 5: { @sGetPlayerCoinMenuCreate(IP_IDs); }
		case 6: { @sGetPlayerEnvanterMenuCreate(IP_IDs); }
		case 7: { @sGetPlayerUserMenuCreate(IP_IDs); }
		case 8: { @sGetPlayerYetkiliPlatformMenuCreate(IP_IDs); }
		case 9: {
			if(get_user_flags(IP_IDs) & szFlag) {
				@sGetPlayerYoneticiPanelGirisTetikle(IP_IDs);
			}
			else
				client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		}
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
public @sOpenMessageModeTask(taskid) {
	new IP_IDs = taskid - MSGMODE_TASK_BASE;
	// FIX: Duz "messagemode" yerine ozel komutla aciliyor, boylece sifre chate dusmuyor.
	// 수정: 일반 "messagemode" 대신 전용 명령어로 열리므로 비밀번호가 전체 채팅에 노출되지 않습니다.
	if(is_user_connected(IP_IDs)) client_cmd(IP_IDs, "messagemode yoneticipanel_sifre");
}
public @sOpenMessageModeSureTask(taskid) {
	new IP_IDs = taskid - MSGMODE_SURE_TASK_BASE;
	if(is_user_connected(IP_IDs)) client_cmd(IP_IDs, "messagemode");
}
@sGetPlayerYoneticiPanelGirisTetikle(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new szUID[35];
	get_user_authid(IP_IDs, szUID, charsmax(szUID));
	new szKey[64];
	format(szKey, charsmax(szKey), "novaria_yonetici_onay_%s", szUID);
	if(nvault_get(IP_IDsGlobal[sVault], szKey) > 0) {
		if(g_iNovariaRol[IP_IDs] < 1) { g_iNovariaRol[IP_IDs] = 1; @sGetPlayerFlagControll(IP_IDs); }
		@sGetPlayerYoneticiPaneliCreate(IP_IDs);
		return PLUGIN_HANDLED;
	}
	IP_IDsBool[IP_IDs][sBekliyorSifre] = true;
	show_menu(IP_IDs, 0, "");
	client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SIFRE_GIR", szTag[SayTag]);
	set_task(0.8, "@sOpenMessageModeTask", IP_IDs + MSGMODE_TASK_BASE);
	return PLUGIN_HANDLED;
}
@sGetPlayerYoneticiOnayVarMi(const IP_IDs) {
	new szUID[35];
	get_user_authid(IP_IDs, szUID, charsmax(szUID));
	new szKey[64];
	format(szKey, charsmax(szKey), "novaria_yonetici_onay_%s", szUID);
	if(nvault_get(IP_IDsGlobal[sVault], szKey) > 0) {
		if(g_iNovariaRol[IP_IDs] < 1) { g_iNovariaRol[IP_IDs] = 1; @sGetPlayerFlagControll(IP_IDs); }
	}
}
@sGetPlayerYoneticiSifreCheck(const IP_IDs) {
    if(!IP_IDsBool[IP_IDs][sBekliyorSifre]) return PLUGIN_CONTINUE;
    new szMesaj[64];
    read_args(szMesaj, charsmax(szMesaj));
    remove_quotes(szMesaj);
    IP_IDsBool[IP_IDs][sBekliyorSifre] = false;
    if(equal(szMesaj, Novaria_YONETICI_SIFRE)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SIFRE_DOGRU", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_MENU);
        if(g_iNovariaRol[IP_IDs] < 1) {
            g_iNovariaRol[IP_IDs] = 1;
            @sGetPlayerFlagControll(IP_IDs);
        }
        new szUID[35];
        get_user_authid(IP_IDs, szUID, charsmax(szUID));
        new szKey[64];
        format(szKey, charsmax(szKey), "novaria_yonetici_onay_%s", szUID);
        nvault_set(IP_IDsGlobal[sVault], szKey, "1");
        @sGetPlayerYoneticiPaneliCreate(IP_IDs);
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SIFRE_YANLIS", szTag[SayTag]);
        sPlayConstSound(IP_IDs, Novaria_SND_WAIT);
    }
    return PLUGIN_HANDLED;
}
@sGetPlayerEnvanterMenuCreate(const IP_IDs) {
	if(!zp_get_user_zombie(IP_IDs)){
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_ENVANTERIM"), "@sGetPlayerEnvanterMenuCreate_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KOSTUMLERIME_BAK"), "1")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KANATLARIMA_BAK"), "2")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_KUYRUKLARIMA_BAK"), "3")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_EFFECTLERIME_BAK"), "4")
	menu_setprop(iMenu, MPROP_PERPAGE, 0);
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER); // cikis manuel eklendigi icin otomatik exit kapatildi (cift cikis fix)
	menu_additem(iMenu, fmt("%s \r%L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_CIKIS"), "cikis")
	menu_display(IP_IDs, iMenu, 0);
	} else { client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_ZOMBIE_NOACCESS_B", szTag[SayTag]); sPlayConstSound(IP_IDs, Novaria_SND_ZPLRS_MENU); }
	return PLUGIN_HANDLED;
}
@sGetPlayerEnvanterMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	if(equal(iData, "cikis")) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerKostumMenuCreate(IP_IDs); }
		case 2: { @sGetPlayerWingsMenuCreate(IP_IDs); }
		case 3: { @sGetPlayerTrailMenuCreate(IP_IDs); }
		case 4: { @sGetPlayerSprEffectMenuCreate(IP_IDs); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerYoneticiPaneliCreate(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_YONETICIPANEL"), "@sGetPlayerYoneticiPaneliCreate_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_TEKOYUNCU_SECIMI"), "1")
	new szTekOyuncuEtiket[64];
	if(g_iTekOyuncuSecilenMod > 0)
		format(szTekOyuncuEtiket, charsmax(szTekOyuncuEtiket), "%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_TEKOYUNCU_BASLAT_SECILI", szOyunModuAdi[g_iTekOyuncuSecilenMod]);
	else
		format(szTekOyuncuEtiket, charsmax(szTekOyuncuEtiket), "%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_TEKOYUNCU_BASLAT_SECILMEDI");
	format(szTekOyuncuEtiket, charsmax(szTekOyuncuEtiket), "%s^n", szTekOyuncuEtiket);
	menu_additem(iMenu, szTekOyuncuEtiket, "2")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YENIDEN_DOGMUS"), "3")
	menu_additem(iMenu, fmt("%s %L^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YONETICI_ISLEMLERI"), "4")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_OYUNMODU_BASLAT"), "6")
	new szDurumEtiket1[24];
	format(szDurumEtiket1, charsmax(szDurumEtiket1), "%L", IP_IDs, g_bOtomatikOyunModu ? "NOVARIA_DURUM_AKTIF" : "NOVARIA_DURUM_PASIF");
	new szOtomatikEtiket[64];
	format(szOtomatikEtiket, charsmax(szOtomatikEtiket), "%s %L %s^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_OTOMATIK_OYUN_MODU", szDurumEtiket1);
	menu_additem(iMenu, szOtomatikEtiket, "7")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerYoneticiPaneliCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerTekOyuncuModSeciminiCreate(IP_IDs); }
		case 2: { @sGetPlayerTekOyuncuModuBaslat(IP_IDs); }
		case 3: { @sGetPlayerYenidenDogmusOyuncuBaslat(IP_IDs); }
		case 4: { @sGetPlayerYoneticiIslemleriCreate(IP_IDs); }
		case 6: { @sGetPlayerOyunModuMenuCreate(IP_IDs); }
		case 7: { @sGetPlayerOtomatikOyunModuToggle(IP_IDs); @sGetPlayerYoneticiPaneliCreate(IP_IDs); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerTekOyuncuModSeciminiCreate(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_TEKOYUNCU_ISLEMLERI"), "@sGetPlayerTekOyuncuModSeciminiCreate_")
	for(new i = 1; i <= 11; i++) {
		menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODU_LABEL", szOyunModuAdi[i]), fmt("%d", i));
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerTekOyuncuModSeciminiCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	if(szKey >= 1 && szKey <= 11) {
		g_iTekOyuncuSecilenMod = szKey;
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_MODE_SELECTED", szTag[SayTag], szOyunModuAdi[szKey]);
	}
	menu_destroy(iMenu);
	@sGetPlayerYoneticiPaneliCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerTekOyuncuModuBaslat(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	if(g_iTekOyuncuSecilenMod <= 0) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_SELECT_MODE_FIRST", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	@sOyunModuBaslat(g_iTekOyuncuSecilenMod, IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerYenidenDogmusOyuncuBaslat(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_MENU_YENIDEN_DOGMUS"), "@sGetPlayerYenidenDogmusOyuncuBaslat_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_TUM_OLULERI_DOGUR"), "1")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_ZOMBI_INSAN_YAP"), "2")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerYenidenDogmusOyuncuBaslat_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerYenidenDogmusOyuncuTumunuDogur(IP_IDs); }
		case 2: { @sGetPlayerZombiHumanPlayerListCreate(IP_IDs); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerYenidenDogmusOyuncuTumunuDogur(const IP_IDs) {
	new szPlayers[32], iNum, i, iRealCount = 0;
	get_players(szPlayers, iNum, "d");
	for(i = 0; i < iNum; i++) {
		if(!is_user_connected(szPlayers[i])) continue;
		server_cmd("zp_respawn #%d", get_user_userid(szPlayers[i]));
		server_exec();
		iRealCount++;
	}
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	for(new iB = 0; iB < iBNum; iB++)
		client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_RESPAWN_ATTEMPT", szTag[SayTag], iRealCount);
	return PLUGIN_HANDLED;
}
@sGetPlayerZombiHumanPlayerListCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_ZOMBI_INSAN_SEC"), "@sGetPlayerZombiHumanPlayerListCreate_")
	new szDurumEtiket2[24];
	new szDisplay[64], szInfo[12];
	for(new i=1; i <= MaxClients; i++) {
		if(is_user_connected(i) && !is_user_bot(i) && !is_user_hltv(i)) {
			format(szDurumEtiket2, charsmax(szDurumEtiket2), "%L", IP_IDs, zp_get_user_zombie(i) ? "NOVARIA_LABEL_ZOMBI" : "NOVARIA_LABEL_INSAN");
			// NOT: ayni satirda iki kez fmt() kullanmak (ozellikle sayfalama devredeyken) menudeki
			// isim alaninin baska bir ogenin bilgi/index degeriyle karismasina (isim yerine sayi
			// gorunmesine) yol acabiliyordu. Ayri, sabit buffer'lar kullanarak bu riski tamamen kaldirdik.
			format(szDisplay, charsmax(szDisplay), "\w%n \r%s", i, szDurumEtiket2);
			format(szInfo, charsmax(szInfo), "%d", get_user_userid(i));
			menu_additem(iMenu, szDisplay, szInfo);
		}
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerZombiHumanPlayerListCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6];
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	IP_IDszAnt[IP_IDs][sGoingUID] = str_to_num(iData);
	menu_destroy(iMenu);
	@sGetPlayerZombiHumanActionCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerZombiHumanActionCreate(const IP_IDs) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_MENU_ZOMBI_INSAN_YAP"), "@sGetPlayerZombiHumanActionCreate_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_ZOMBI_YAP_R"), "1")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_INSAN_YAP_R"), "2")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerZombiHumanActionCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey, iUserId = IP_IDszAnt[IP_IDs][sGoingUID];
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { server_cmd("zp_zombie #%d", iUserId); server_exec(); }
		case 2: { server_cmd("zp_human #%d", iUserId); server_exec(); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerOtomatikOyunModuToggle(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	g_bOtomatikOyunModu = !g_bOtomatikOyunModu;
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	if(g_bOtomatikOyunModu) {
		for(new iB = 0; iB < iBNum; iB++)
			client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_AUTOMODE_ON", szTag[SayTag]);
		@sOtomatikModSec();
	} else {
		for(new iB = 0; iB < iBNum; iB++)
			client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_AUTOMODE_OFF", szTag[SayTag]);
		g_iOtomatikSecilenMod = 0;
	}
	return PLUGIN_HANDLED;
}
@sOtomatikModSec() {
	g_iOtomatikSecilenMod = random_num(1, 11);
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	for(new iB = 0; iB < iBNum; iB++)
		client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_RANDOM_MODE_NEXT_ROUND", szTag[SayTag], szOyunModuAdi[g_iOtomatikSecilenMod]);
}
@sGetPlayerMutluSaatSetCarpan(const IP_IDs, const iCarpan) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	g_iMutluSaatCarpanManuel = iCarpan;
	g_bMutluSaatZorlaKapali = (iCarpan <= 0); // 0 = zorla kapat, otomatik saat sistemine de dusme
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	if(g_iMutluSaatCarpanManuel > 0) {
		for(new iB = 0; iB < iBNum; iB++)
			client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_HAPPYHOUR_ON", szTag[SayTag], g_iMutluSaatCarpanManuel);
	} else {
		for(new iB = 0; iB < iBNum; iB++)
			client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_HAPPYHOUR_OFF", szTag[SayTag]);
	}
	return PLUGIN_HANDLED;
}
@sGetPlayerMutluSaatKategoriToggle(const IP_IDs, const iKategori) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	switch(iKategori) {
		case MUTLUSAAT_KAT_COIN: g_bMutluSaatKatCoin = !g_bMutluSaatKatCoin;
		case MUTLUSAAT_KAT_XP: g_bMutluSaatKatXP = !g_bMutluSaatKatXP;
		case MUTLUSAAT_KAT_KASMA: g_bMutluSaatKatKasma = !g_bMutluSaatKatKasma;
	}
	return PLUGIN_HANDLED;
}
@sGetPlayerAutoModeRoundStart() {
	g_szAktifModAdi[0] = 0; // yeni tur basladi, onceki turun mod adini temizle
	g_bEnfeksiyonBasladi = false; // enfeksiyon henuz yayilmadi, gecikme suresi (freeze/hazirlik) suruyor
	new Float:fGecikme = 2.0;
	new pCvarDelay = get_cvar_pointer("zp_delay");
	if(pCvarDelay) fGecikme += get_pcvar_float(pCvarDelay);
	if(g_bOtomatikOyunModu && g_iOtomatikSecilenMod > 0) {
		set_task(fGecikme, "@sOtomatikModBaslatTask");
	}
	// Round basi salgin duyurusu: yukaridaki tasklardan (otomatik mod / manuel mod / tek oyuncu modu)
	// sonra calissin ki g_szAktifModAdi o an dogru dolu olsun.
	set_task(fGecikme + 0.5, "@sGetPlayerSalginDuyuru");
}
@sOtomatikModBaslatTask() {
	if(!g_bOtomatikOyunModu) return;
	@sOyunModuBaslat(g_iOtomatikSecilenMod, 0);
	@sOtomatikModSec();
}
@sGetPlayerSalginDuyuru() {
	g_bEnfeksiyonBasladi = true; // hazirlik/gecikme suresi bitti, enfeksiyon fiilen basladi
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	if(g_szAktifModAdi[0]) {
		for(new iB = 0; iB < iBNum; iB++)
			client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_SALGIN_MOD", szTag[SayTag], g_szAktifModAdi);
	} else {
		for(new iB = 0; iB < iBNum; iB++)
			client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_SALGIN_NORMAL", szTag[SayTag]);
	}
	// g_szAktifModAdi burada SIFIRLANMIYOR: HUD'da tur boyunca gosterilmeye devam etsin.
	// Bir sonraki turda @sGetPlayerAutoModeRoundStart basinda temizleniyor.
}
@sGetPlayerYoneticiIslemleriCreate(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_MENU_YONETICI_ISLEMLERI"), "@sGetPlayerYoneticiIslemleriCreate_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_ETKINLIK_ISLEMLERI"), "1")
	menu_additem(iMenu, fmt("%s %L^n", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MENU_TEMALARI"), "2")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_YETKI_VER"), "3")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerYoneticiIslemleriCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
		case 2: { @sGetPlayerMenuTemalariCreate(IP_IDs); }
		case 3: { @sGetPlayerYetkiOyuncuMenuCreate(IP_IDs); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerEtkinlikIslemleriCreate(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_MENU_ETKINLIK_ISLEMLERI"), "@sGetPlayerEtkinlikIslemleriCreate_")
	new szDurumEtiket3[24];
	format(szDurumEtiket3, charsmax(szDurumEtiket3), "%L", IP_IDs, (g_iMutluSaatCarpanManuel == 2) ? "NOVARIA_DURUM_AKTIF" : "NOVARIA_DURUM_PASIF");
	menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MUTLUSAAT_X2", szDurumEtiket3), "1")
	format(szDurumEtiket3, charsmax(szDurumEtiket3), "%L", IP_IDs, (g_iMutluSaatCarpanManuel == 3) ? "NOVARIA_DURUM_AKTIF" : "NOVARIA_DURUM_PASIF");
	menu_additem(iMenu, fmt("%s %L %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MUTLUSAAT_X3", szDurumEtiket3), "2")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MUTLUSAAT_KAPAT"), "3")
	menu_addblank2(iMenu);
	format(szDurumEtiket3, charsmax(szDurumEtiket3), "%L", IP_IDs, g_bMutluSaatKatCoin ? "NOVARIA_DURUM_ACIK" : "NOVARIA_DURUM_KAPALI");
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MUTLUSAAT_KAT_COIN", szDurumEtiket3), "4")
	format(szDurumEtiket3, charsmax(szDurumEtiket3), "%L", IP_IDs, g_bMutluSaatKatXP ? "NOVARIA_DURUM_ACIK" : "NOVARIA_DURUM_KAPALI");
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MUTLUSAAT_KAT_XP", szDurumEtiket3), "5")
	format(szDurumEtiket3, charsmax(szDurumEtiket3), "%L", IP_IDs, g_bMutluSaatKatKasma ? "NOVARIA_DURUM_ACIK" : "NOVARIA_DURUM_KAPALI");
	menu_additem(iMenu, fmt("%s %L: %s", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MUTLUSAAT_KAT_KASMA", szDurumEtiket3), "6")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerEtkinlikIslemleriCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1: { @sGetPlayerMutluSaatSetCarpan(IP_IDs, 2); @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
		case 2: { @sGetPlayerMutluSaatSetCarpan(IP_IDs, 3); @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
		case 3: { @sGetPlayerMutluSaatSetCarpan(IP_IDs, 0); @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
		case 4: { @sGetPlayerMutluSaatKategoriToggle(IP_IDs, MUTLUSAAT_KAT_COIN); @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
		case 5: { @sGetPlayerMutluSaatKategoriToggle(IP_IDs, MUTLUSAAT_KAT_XP); @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
		case 6: { @sGetPlayerMutluSaatKategoriToggle(IP_IDs, MUTLUSAAT_KAT_KASMA); @sGetPlayerEtkinlikIslemleriCreate(IP_IDs); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerYetkiOyuncuMenuCreate(const IP_IDs) {
    if(!(get_user_flags(IP_IDs) & szFlag)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
        return PLUGIN_HANDLED;
    }
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_YETKIMENU"), "@sGetPlayerYetkiOyuncuMenuCreate_")
    new szNum, IP_IDsTarget[32], szName[32];
    get_players(IP_IDsTarget, szNum, "h");
    for(new i = 0; i < szNum; i++) {
        if(is_user_bot(IP_IDsTarget[i]) || is_user_hltv(IP_IDsTarget[i])) continue;
        get_user_name(IP_IDsTarget[i], szName, charsmax(szName));
        menu_additem(iMenu, szName, fmt("%d", IP_IDsTarget[i]));
    }
    menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
    menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
    menu_display(IP_IDs, iMenu);
    return PLUGIN_HANDLED;
}
@sGetPlayerYetkiOyuncuMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szTarget;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szTarget = str_to_num(iData);
	if(!is_user_connected(szTarget)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SECPLAYER", szTag[SayTag]);
		menu_destroy(iMenu); return PLUGIN_HANDLED;
	}
	@sGetPlayerYetkiSeviyeMenuCreate(IP_IDs, szTarget);
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerYetkiSeviyeMenuCreate(const IP_IDs, const szTarget) {
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_YETKIMENU"), "@sGetPlayerYetkiSeviyeMenuCreate_")
	new szRolAdi[32];
	for(new i = 0; i < Novaria_UNVAN_SAYISI; i++) {
		@sGetRolName(i, IP_IDs, szRolAdi, charsmax(szRolAdi));
		menu_additem(iMenu, szRolAdi, fmt("%d_%d", szTarget, i));
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerYetkiSeviyeMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[12], szTarget, szSeviye;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	new szParts[2][6];
	sExplode(iData, "_", szParts, 2, 6);
	szTarget = str_to_num(szParts[0]);
	szSeviye = str_to_num(szParts[1]);
	if(!is_user_connected(szTarget)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SECPLAYER", szTag[SayTag]);
		menu_destroy(iMenu); return PLUGIN_HANDLED;
	}
	g_iYetkiVerHedef[IP_IDs] = szTarget;
	g_iYetkiVerSeviye[IP_IDs] = szSeviye;
	@sGetPlayerYetkiSureTipiMenuCreate(IP_IDs);
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerYetkiSureTipiMenuCreate(const IP_IDs) {
    new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_TITLE_SURETIPIMENU"), "@sGetPlayerYetkiSureTipiMenuCreate_")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SURESIZ"), "1")
    menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_SURELI"), "2")
    menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
    menu_display(IP_IDs, iMenu);
    return PLUGIN_HANDLED;
}

@sGetPlayerYetkiSureTipiMenuCreate_(const IP_IDs, const iMenu, const iItem) {
    if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
    new iData[6], szKey;
    menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
    szKey = str_to_num(iData);
    new szTarget = g_iYetkiVerHedef[IP_IDs];

    if(!is_user_connected(szTarget)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SECPLAYER", szTag[SayTag]);
        menu_destroy(iMenu); return PLUGIN_HANDLED;
    }

    if(szKey == 1) {
        @sGetPlayerYetkiUygula(IP_IDs, szTarget, g_iYetkiVerSeviye[IP_IDs], 0);
    } else if(szKey == 2) {
        show_menu(IP_IDs, 0, "");
        // YENI SISTEM: Oyuncuyu bilgilendir ve sol ustte girdi ekranini (messagemode) ac
        client_print_color(IP_IDs, IP_IDs, "^4[Yetki]^1 Lutfen sol ustte acilan kutuya ^3kac gun^1 yetki verilecegini yazin.");
        client_cmd(IP_IDs, "messagemode yetki_suresigir");
    }
    menu_destroy(iMenu); return PLUGIN_HANDLED;
}


stock sNovariaSureMetniTemizle(const szMesaj[], szTemiz[], const szTemizLen) {
    new i, j = 0;
    for(i = 0; szMesaj[i] != 0 && j < szTemizLen; i++) {
        if(szMesaj[i] >= '0' && szMesaj[i] <= '9') {
            szTemiz[j] = szMesaj[i];
            j++;
        }
    }
    szTemiz[j] = 0;
    return j;
}

stock sNovariaSureMetniOlustur(const IP_IDs, const iGun, szOut[], const szOutLen) {
    if(iGun <= 0) {
        copy(szOut, szOutLen, "^4Suresiz");
        return;
    }
    if(iGun >= 365) {
        new iYil = iGun / 365, iKalanGun = iGun % 365;
        if(iKalanGun > 0)
            format(szOut, szOutLen, "^3%d ^1Yil ^3%d ^1Gun", iYil, iKalanGun);
        else
            format(szOut, szOutLen, "^3%d ^1Yil", iYil);
    } else if(iGun >= 30) {
        new iAy = iGun / 30, iKalanGun = iGun % 30;
        if(iKalanGun > 0)
            format(szOut, szOutLen, "^3%d ^1Ay ^3%d ^1Gun", iAy, iKalanGun);
        else
            format(szOut, szOutLen, "^3%d ^1Ay", iAy);
    } else {
        format(szOut, szOutLen, "^3%d ^1Gun", iGun);
    }
    #pragma unused IP_IDs
}

@sGetPlayerYetkiSureCheck(const IP_IDs) {
    if(!(get_user_flags(IP_IDs) & szFlag)) return PLUGIN_CONTINUE;
    new szMesaj[48];
    read_args(szMesaj, charsmax(szMesaj));
    remove_quotes(szMesaj);
    trim(szMesaj);
    
    new szTarget = g_iYetkiVerHedef[IP_IDs];
    new szSeviye = g_iYetkiVerSeviye[IP_IDs];
    
    if(!is_user_connected(szTarget)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SECPLAYER", szTag[SayTag]);
        return PLUGIN_HANDLED;
    }
    
    new szSadeceRakam[16];
    new iUzunluk = sNovariaSureMetniTemizle(szMesaj, szSadeceRakam, charsmax(szSadeceRakam));
    
    if(iUzunluk == 0) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SURE_GECERSIZ", szTag[SayTag]);
        // YENI SISTEM: Artik komut kullanmadigimiz icin hata mesaji da buna uygun hale getirildi.
        client_print_color(IP_IDs, IP_IDs, "^4[Yetki]^1 Gecerli bir gun sayisi girmediniz. Lutfen sadece rakam kullanin.");
        return PLUGIN_HANDLED;
    }
    
    new iGun = str_to_num(szSadeceRakam);
    if(iGun < 0) iGun = 0;
    if(iGun > Novaria_YETKI_SURE_MAX_GUN) iGun = Novaria_YETKI_SURE_MAX_GUN;
    @sGetPlayerYetkiUygula(IP_IDs, szTarget, szSeviye, iGun);
    return PLUGIN_HANDLED;
}

@sGetPlayerYetkiUygula(const IP_IDs, const szTarget, const szSeviye, const iGun) {
    if(!is_user_connected(szTarget)) {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SECPLAYER", szTag[SayTag]);
        return;
    }
    new szTargetName[32];
    get_user_name(szTarget, szTargetName, charsmax(szTargetName));
    g_iNovariaRol[szTarget] = szSeviye;
    @sGetPlayerFlagControll(szTarget);
    remove_task(szTarget + Novaria_ROL_TASK_BASE);

    // Rol adi her izleyicinin kendi diline gore ayri ayri okunur.
    new szRolAdiIzleyen[32], szRolAdiHedef[32];
    @sGetRolName(szSeviye, IP_IDs, szRolAdiIzleyen, charsmax(szRolAdiIzleyen));
    @sGetRolName(szSeviye, szTarget, szRolAdiHedef, charsmax(szRolAdiHedef));

    if(iGun > 0) {
        set_task(float(iGun) * 86400.0, "@sGetPlayerRolSuresiDoldu", szTarget + Novaria_ROL_TASK_BASE);
        new szSureMetni[48];
        sNovariaSureMetniOlustur(IP_IDs, iGun, szSureMetni, charsmax(szSureMetni));
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_VERILDI_SURELI", szTag[SayTag], szRolAdiIzleyen, szTargetName, szSureMetni);
        client_print_color(szTarget, szTarget, "%L", szNovariaDilKodu[IP_IDszAnt[szTarget][sDilID]], "NOVARIA_MSG_YETKI_ALINDI_SURELI", szTag[SayTag], szRolAdiHedef, szSureMetni);
    } else {
        client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_VERILDI", szTag[SayTag], szRolAdiIzleyen, szTargetName);
        client_print_color(szTarget, szTarget, "%L", szNovariaDilKodu[IP_IDszAnt[szTarget][sDilID]], "NOVARIA_MSG_YETKI_ALINDI", szTag[SayTag], szRolAdiHedef);
    }
}

@sGetPlayerRolSuresiDoldu(const iTaskData) {
    new IP_IDs = iTaskData - Novaria_ROL_TASK_BASE;
    if(!is_user_connected(IP_IDs)) return;
    g_iNovariaRol[IP_IDs] = 0;
    @sGetPlayerFlagControll(IP_IDs);
    client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_YETKI_SURESI_DOLDU", szTag[SayTag]);
}

stock sExplode(const szText[], const szDelim[], szOut[][], const szMax, const szLen) {
    new i, szCount = 0, szBuf[64], szBufPos = 0;
    new szTextLen = strlen(szText);
    for(i = 0; i <= szTextLen; i++) {
        if(szText[i] == szDelim[0] || i == szTextLen) {
            szBuf[szBufPos] = 0;
            copy(szOut[szCount], szLen - 1, szBuf);
            szCount++; szBufPos = 0;
            if(szCount >= szMax) break;
        } else {
            szBuf[szBufPos] = szText[i];
            szBufPos++;
        }
    }
}
@sGetPlayerMenuTemalariCreate(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_MENU_MENU_TEMALARI"), "@sGetPlayerMenuTemalariCreate_")
	new szAktifKoseli[16];
	for(new i = 0; i < sizeof(szNovariaTema); i++) {
		szAktifKoseli[0] = 0;
		if(g_iNovariaTemaAktif == i) format(szAktifKoseli, charsmax(szAktifKoseli), "%L", IP_IDs, "NOVARIA_LABEL_AKTIF_KOSELI");
		menu_additem(iMenu, fmt("%s %s %s", szTag[KisaTag], szNovariaTema[i][sTemaAd], szAktifKoseli), fmt("%d", i));
	}
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetRandomAlivePlayer() {
	new szPlayers[32], iNum;
	get_players(szPlayers, iNum, "a");
	if(iNum <= 0) return 0;
	return szPlayers[random_num(0, iNum-1)];
}
@sOyunModuBaslat(const iKey, const IP_IDs) {
	if(iKey < 1 || iKey > 11) return;
	copy(g_szAktifModAdi, charsmax(g_szAktifModAdi), szOyunModuAdi[iKey]);
	if(szOyunModuHedefli[iKey]) {
		new iHedef = @sGetRandomAlivePlayer();
		if(!iHedef) {
			g_szAktifModAdi[0] = 0; // hedef bulunamadi, mod baslamadi
			new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
			for(new iB = 0; iB < iBNum; iB++)
				client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_NO_TARGETABLE_PLAYERS", szTag[SayTag]);
			return;
		}
		server_cmd("%s #%d", szOyunModuKomut[iKey], get_user_userid(iHedef));
		server_exec();
	} else {
		server_cmd("%s", szOyunModuKomut[iKey]);
		server_exec();
	}
}
@sGetPlayerOyunModuMenuCreate(const IP_IDs) {
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		return PLUGIN_HANDLED;
	}
	new iMenu = menu_create(fmt("%s %L", szTag[MenuTag], IP_IDs, "NOVARIA_MENU_OYUNMODU_BASLAT"), "@sGetPlayerOyunModuMenuCreate_")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_INFECTION"), "1")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_NEMESIS"), "2")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_ASSASSIN"), "3")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_SURVIVOR"), "4")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_SNIPER"), "5")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_SWARM"), "6")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_MULTIINFECTION"), "7")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_PLAGUE"), "8")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_ARMAGEDDON"), "9")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_APOCALYPSE"), "10")
	menu_additem(iMenu, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_MODE_NIGHTMARE"), "11")
	menu_setprop(iMenu, MPROP_BACKNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_GERI"));
	menu_setprop(iMenu, MPROP_NEXTNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_BTN_ILERI"));
	menu_setprop(iMenu, MPROP_EXITNAME, fmt("%s %L", szTag[KisaTag], IP_IDs, "NOVARIA_MENU_CIKIS_R"));
	menu_display(IP_IDs, iMenu);
	return PLUGIN_HANDLED;
}
@sGetPlayerOyunModuMenuCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	if(!(get_user_flags(IP_IDs) & szFlag)) {
		client_print_color(IP_IDs, IP_IDs, "%L", szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]], "NOVARIA_MSG_NO_PERMISSION_MENU", szTag[SayTag]);
		menu_destroy(iMenu); return PLUGIN_HANDLED;
	}
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	switch(szKey) {
		case 1..11: { @sOyunModuBaslat(szKey, IP_IDs); }
	}
	menu_destroy(iMenu); return PLUGIN_HANDLED;
}
@sGetPlayerMenuTemalariCreate_(const IP_IDs, const iMenu, const iItem) {
	if(iItem == MENU_EXIT) { menu_destroy(iMenu); return PLUGIN_HANDLED; }
	new iData[6], szKey;
	menu_item_getinfo(iMenu, iItem, _, iData, charsmax(iData));
	szKey = str_to_num(iData);
	NovariaTemaUygula(IP_IDs, szKey);
	menu_destroy(iMenu);
	@sGetPlayerMenuTemalariCreate(IP_IDs);
	return PLUGIN_HANDLED;
}
@sGetPlayerConnectMenuControll(const IP_IDs) { client_cmd(IP_IDs, "say /novaria_menuac"); }
public client_disconnected(IP_IDs) {
     KuyrukTrailDurdur(IP_IDs);
     sSaveVault(IP_IDs,1);sSaveVault(IP_IDs,2);
     sSaveVault(IP_IDs,3);sSaveVault(IP_IDs,4);
     sSaveVault(IP_IDs,5);sSaveVault(IP_IDs,6);
     sSaveVault(IP_IDs,7);sSaveVault(IP_IDs,8);
     sSaveVault(IP_IDs,9);
     IP_IDsBool[IP_IDs][sSetting] = false;IP_IDsBool[IP_IDs][sSetting2] = false;
     IP_IDszAnt[IP_IDs][sXP] = false;
     IP_IDszAnt[IP_IDs][sLevel] = false;
     IP_IDszAnt[IP_IDs][sKnifeID] = false;
     IP_IDszAnt[IP_IDs][sGorevInfectEt] = false;
     IP_IDszAnt[IP_IDs][sGorevCtKill] = false;
     IP_IDszAnt[IP_IDs][sGorevSureliOyna] = false;
     IP_IDszAnt[IP_IDs][sGorevRoundOyna] = false;
     IP_IDszAnt[IP_IDs][sTurSay] = false;
     remove_task(IP_IDs+77734);
     remove_task(IP_IDs);
     remove_task(IP_IDs+1710);
     // [TR] BUGFIX: kaldirilan level-up sprite sistemine ait discon-temizligi
     // (Novaria_LEVELUP_SPR_TASK_BASE / g_iLevelUpEnt) silindi; artik hicbir
     // task ya da entity olusturulmadigi icin temizlenecek bir sey yok.
     // [KO] 버그수정: 제거된 레벨업 스프라이트 시스템의 접속종료 정리 코드
     // (Novaria_LEVELUP_SPR_TASK_BASE / g_iLevelUpEnt)가 삭제되었습니다.
     // 더 이상 태스크나 엔티티가 생성되지 않으므로 정리할 대상이 없습니다.
     g_iSinifKontrolDeneme[IP_IDs] = 0;
}
public client_putinserver(IP_IDs) {
    IP_IDszAnt[IP_IDs][sKnifeID] = true;
    IP_IDszAnt[IP_IDs][sNormalBicakID] = true;
    IP_IDszAnt[IP_IDs][sBicakKaynak] = 0;
    IP_IDsBool[IP_IDs][sExtraBicakAktif] = false;
    IP_IDszAnt[IP_IDs][sExtraBicakSahiplik] = 0;
    IP_IDsBool[IP_IDs][sBlockMsg] = false;
    IP_IDsBool[IP_IDs][sGizle] = false;
    g_iNovariaRol[IP_IDs] = 0;
    remove_task(IP_IDs + Novaria_ROL_TASK_BASE);
    for(new i = 0; i < 6; i++) {
        g_bYPApAlindi[i][IP_IDs] = false;
        g_bYPJetonAlindi[i][IP_IDs] = false;
        g_bYPZirhAlindi[i][IP_IDs] = false;
        g_bYPBombaAlindi[i][IP_IDs] = false;
    }
    IP_IDszAnt[IP_IDs][sHudRenk] = HUD_RENK_RGB;
    IP_IDszAnt[IP_IDs][sHudKonum] = HUD_KONUM_VARSAYILAN;
    IP_IDsBool[IP_IDs][sHudDurum] = false;
    IP_IDsBool[IP_IDs][sHeroKacak] = false;
    IP_IDsBool[IP_IDs][sHeroHizlanma] = false;
    IP_IDsBool[IP_IDs][sHeroKalkan] = false;
    IP_IDsBool[IP_IDs][sSesMenuAktif] = true;
    IP_IDsBool[IP_IDs][sSesLevelAktif] = true;
    IP_IDsBool[IP_IDs][sSesGeriSayimAktif] = true;
    IP_IDsBool[IP_IDs][sSesModAktif] = true;
    new szClientLang[3];
    get_lang(IP_IDs, szClientLang);
    IP_IDszAnt[IP_IDs][sDilID] = equal(szClientLang, "tr") ? Novaria_DIL_TR : (equal(szClientLang, "ko") ? Novaria_DIL_KO : Novaria_DIL_EN);
    sNovariaSetClientLang(IP_IDs, szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]]);
    if(IP_IDszAnt[IP_IDs][sClassValue] == -1) {  } else IP_IDszAnt[IP_IDs][sClassValue] = IP_IDszAnt[IP_IDs][sClassValue];
    IP_IDszAnt[IP_IDs][sGorevRoundOyna] = false;
    @sWingEntityCreate(IP_IDs,0);
    @sGetPlayerFlagControll(IP_IDs);
    set_task(3.0,"@sGetPlayerTimed",IP_IDs);
    set_task(1.0, "@sGetPlayerMainHud", IP_IDs, _, _, "b");
    set_task(60.0*szCoinTime,"@sGetPlayerCoinTime",IP_IDs, _, _, "b");
    get_user_name(IP_IDs, IP_IDsUserName[IP_IDs], charsmax(IP_IDsUserName[]));
    set_task(0.5,"@sGetPlayerLoadStats",IP_IDs);
    set_task(1.0, "@sGetPlayerYoneticiOnayVarMi", IP_IDs);
    set_task(2.0, "@sGetPlayerSisSendClientTask", IP_IDs+8800);
}
@sGetPlayerLoadStats(const IP_IDs) {
     if(!is_user_connected(IP_IDs)) return;
     sLoadVault(IP_IDs,1);
     sLoadVault(IP_IDs,9);
     @sGetPlayerSinifKaydiUygula(IP_IDs);
}
@sGetPlayerSinifKaydiUygula(const IP_IDs) {
    if(!is_user_connected(IP_IDs)) return;
    if(IP_IDsBool[IP_IDs][sSinifKaydiZombi] && IP_IDszAnt[IP_IDs][sZombieClassSaved] >= 0) {
        zp_set_user_zombie_class(IP_IDs, IP_IDszAnt[IP_IDs][sZombieClassSaved]);
    }
    if(IP_IDsBool[IP_IDs][sSinifKaydiHero] && IP_IDszAnt[IP_IDs][sHeroClassValue] > 0) {
        switch(IP_IDszAnt[IP_IDs][sHeroClassValue]) {
            case 2: { IP_IDsBool[IP_IDs][sHeroKacak] = true; }
            case 3: { IP_IDsBool[IP_IDs][sHeroHizlanma] = true; }
            case 4: { IP_IDsBool[IP_IDs][sHeroKalkan] = true; }
        }
    }
}
@sGetPlayerSinifKaydiSpawnUygula(const IP_IDs) {
    if(!is_user_connected(IP_IDs) || !is_user_alive(IP_IDs) || zp_get_user_zombie(IP_IDs)) return;
    if(IP_IDsBool[IP_IDs][sSinifKaydiHero] && zp_get_user_nemesis(IP_IDs) == 0 && IP_IDszAnt[IP_IDs][sHeroClassValue] > 0) {
        IP_IDszAnt[IP_IDs][sMapEngelHero] = 1;
        switch(IP_IDszAnt[IP_IDs][sHeroClassValue]) {
            case 3: { set_entvar(IP_IDs, var_maxspeed, g_fHeroHiz); }
            case 4: { set_entvar(IP_IDs, var_armorvalue, get_entvar(IP_IDs, var_armorvalue) + g_fHeroKalkan); }
        }
    }
    if(IP_IDsBool[IP_IDs][sSinifKaydiNemesis] && zp_get_user_nemesis(IP_IDs) && IP_IDszAnt[IP_IDs][sNemesisClassValue] > 0) {
        IP_IDszAnt[IP_IDs][sMapEngelNemesis] = 1;
        switch(IP_IDszAnt[IP_IDs][sNemesisClassValue]) {
            case 2: { set_entvar(IP_IDs, var_armorvalue, get_entvar(IP_IDs, var_armorvalue) + g_fHumanCelikArmor); }
            case 3: { set_entvar(IP_IDs, var_maxspeed, g_fNightstalkerHiz); }
            case 4: { set_entvar(IP_IDs, var_gravity, g_fHumanMutantGravity); }
        }
    }
}
@sGetPlayerFlagControll(const IP_IDs) {
	@sGetRolName(g_iNovariaRol[IP_IDs], IP_IDs, IP_IDsString[IP_IDs], 49);
}
@sGetPlayerCheckLevel(IP_IDs){
    // BUGFIX: sinir "szMaxLevel-1" (32) idi, bu yuzden sLevel 32'de kilitleniyor
    // ve son esik (szLevel[32] = 33. seviye XP siniri) hicbir zaman kontrol
    // edilmiyordu. Oyuncu asla 33. seviyeye ulasamiyordu.
    while(IP_IDszAnt[IP_IDs][sLevel] < szMaxLevel){
	    if(IP_IDszAnt[IP_IDs][sXP] >= szLevel[IP_IDszAnt[IP_IDs][sLevel]]){
		    IP_IDszAnt[IP_IDs][sLevel]++;
		    set_task(0.5,"@sGetPlayerLevelUP",IP_IDs+1001);
	    }else break;
	}
}
@sGetPlayerLevelUP(taskid){
	remove_task(taskid);
	new IP_IDs = taskid - 1001, szRankName[32];
	@sGetRankName(IP_IDs, szRankName, charsmax(szRankName));
	// Bir sonraki rutbeye kalan XP (level atlayinca Cavus vb. ile birlikte gosterilsin diye)
	new iXPKalan = 0;
	// BUGFIX: ust sinir szMaxLevel-1 oldugu icin 32->33 gecisinde kalan XP
	// hep 0 gosteriliyordu; artik ust sinir szMaxLevel ile tutarli.
	if(IP_IDszAnt[IP_IDs][sLevel] < szMaxLevel) {
		iXPKalan = szLevel[IP_IDszAnt[IP_IDs][sLevel]] - IP_IDszAnt[IP_IDs][sXP];
		if(iXPKalan < 0) iXPKalan = 0;
	}
	new szBPlayers[32], iBNum; get_players(szBPlayers, iBNum);
	for(new iB = 0; iB < iBNum; iB++) {
		client_print_color(szBPlayers[iB], szBPlayers[iB], "%L", szNovariaDilKodu[IP_IDszAnt[szBPlayers[iB]][sDilID]], "NOVARIA_MSG_LEVELUP", szTag[SayTag], IP_IDs, IP_IDszAnt[IP_IDs][sLevel], szRankName, iXPKalan);
	}
	if(is_user_connected(IP_IDs)) {
		if(IP_IDsBool[IP_IDs][sSesLevelAktif]) {
			rg_send_audio(IP_IDs, szLevelUpSound);
			// BUGFIX: sprite gorseli tamamen kaldirildi (kullanici talebi)
		}
		sSaveVault(IP_IDs, 4);
	}
}
public plugin_cfg() {
	IP_IDsGlobal[sVault] = nvault_open("rezpvault11");
	IP_IDsGlobal[sVaultMenu] = nvault_open("rezpvault_menuu");
	if(IP_IDsGlobal[sVault] == -1) log_amx("[Novaria-UYARI] rezpvault1.vault ACILAMADI! Oyuncu verileri kaydedilemeyecek.");
	if(IP_IDsGlobal[sVaultMenu] == -1) log_amx("[Novaria-UYARI] rezpvault_menu.vault ACILAMADI!");
	LoadNovariaTema();
}
public plugin_end() {
  new sNum, szPlayer[32], sID;
  get_players(szPlayer, sNum);
  for(new i = 0; i < sNum; i++) {
	sID = szPlayer[i];
	sSaveVault(sID, 1);
	sSaveVault(sID, 2);
	sSaveVault(sID, 3);
	sSaveVault(sID, 4);
	sSaveVault(sID, 5);
	sSaveVault(sID, 6);
	sSaveVault(sID, 7);
	sSaveVault(sID, 8);
	sSaveVault(sID, 9);
   }
  if(IP_IDsGlobal[sVault] > 0) nvault_close(IP_IDsGlobal[sVault]);
  if(IP_IDsGlobal[sVaultMenu] > 0) nvault_close(IP_IDsGlobal[sVaultMenu]);
}
stock sLoadVault(const IP_IDs, const iType) {
		new szUID[36],i;
		get_user_authid(IP_IDs,szUID,charsmax(szUID));
		if(szUID[0]) {
		switch(iType) {
			case 1: {
				IP_IDszAnt[IP_IDs][sCoin] = sGetIntData("%s>iCoin",szUID);
				IP_IDszAnt[IP_IDs][sXP] = sGetIntData("%s>iXP",szUID);
				IP_IDszAnt[IP_IDs][sLevel] = sGetIntData("%s>iLevel",szUID);
				for(i=1; i < sizeof(szKuyruk); i++) {
				IP_IDsKuyrukKaydet[IP_IDs][i] = (sGetIntData("%s>iKuyruk>%i>",szUID,i) == 1) ? true : false;
				}
				for(i=1; i < g_iKostumSayi; i++) {
				IP_IDsKostumKaydet[IP_IDs][i] = (sGetIntData("%s>iKostum>%i>",szUID,i) == 1) ? true : false;
				}
				for(i=1; i < sizeof(szDeathEffect); i++) {
				IP_IDsEffectsKaydet[IP_IDs][i] = (sGetIntData("%s>iEffects>%i>",szUID,i) == 1) ? true : false;
				}
				for(i=1; i < g_iKanatSayi; i++) {
				IP_IDsKanatKaydet[IP_IDs][i] = (sGetIntData("%s>iKanat>%i>",szUID,i) == 1) ? true : false;
				}
				// Bicak menu (knife/character model) secimleri artik kaydedilmiyor, her girişte varsayilana donuyor
				IP_IDszAnt[IP_IDs][sKnifeID] = 0;
				IP_IDszAnt[IP_IDs][sNormalBicakID] = 1;
				IP_IDszAnt[IP_IDs][sBicakKaynak] = 0;
				IP_IDszAnt[IP_IDs][sVipBicakID] = 0;
				new szHudData[8], iHudTimestamp;
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iHudRenk",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sHudRenk] = str_to_num(szHudData);
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iHudKonum",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sHudKonum] = str_to_num(szHudData);
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iHudDurum",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDsBool[IP_IDs][sHudDurum] = (str_to_num(szHudData) == 1) ? true : false;
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSisRenk",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sSisRenk] = str_to_num(szHudData);
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSisYogunluk",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sSisYogunluk] = str_to_num(szHudData);
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSisAktif",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDsBool[IP_IDs][sSisAktif] = (str_to_num(szHudData) == 1) ? true : false;
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iDilID",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sDilID] = str_to_num(szHudData);
					sNovariaSetClientLang(IP_IDs, szNovariaDilKodu[IP_IDszAnt[IP_IDs][sDilID]]);
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiInsan",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDsBool[IP_IDs][sSinifKaydiInsan] = (str_to_num(szHudData) == 1) ? true : false;
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiZombi",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDsBool[IP_IDs][sSinifKaydiZombi] = (str_to_num(szHudData) == 1) ? true : false;
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiHero",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDsBool[IP_IDs][sSinifKaydiHero] = (str_to_num(szHudData) == 1) ? true : false;
				}
				if(nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiNemesis",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDsBool[IP_IDs][sSinifKaydiNemesis] = (str_to_num(szHudData) == 1) ? true : false;
				}
				if(IP_IDsBool[IP_IDs][sSinifKaydiInsan] && nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiInsanVal",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sClassValue] = str_to_num(szHudData);
				}
				if(IP_IDsBool[IP_IDs][sSinifKaydiZombi] && nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiZombiVal",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sZombieClassSaved] = str_to_num(szHudData);
				}
				if(IP_IDsBool[IP_IDs][sSinifKaydiHero] && nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiHeroVal",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sHeroClassValue] = str_to_num(szHudData);
				}
				if(IP_IDsBool[IP_IDs][sSinifKaydiNemesis] && nvault_lookup(IP_IDsGlobal[sVault], fmt("%s>iSinifKaydiNemesisVal",szUID), szHudData, charsmax(szHudData), iHudTimestamp)) {
					IP_IDszAnt[IP_IDs][sNemesisClassValue] = str_to_num(szHudData);
				}
			}
		  }
		}
		return PLUGIN_HANDLED;
}
stock sSaveVault(const IP_IDs, const iType) {
		new szUID[36],i;
		get_user_authid(IP_IDs,szUID,charsmax(szUID));
		if(szUID[0]) {
		switch(iType) {
		case 1: { sSetIntData("%s>iCoin",IP_IDszAnt[IP_IDs][sCoin],szUID); }
		case 2: {
			for(i=1; i < sizeof(szKuyruk); i++) {
			         sSetIntData("%s>iKuyruk>%i>",IP_IDsKuyrukKaydet[IP_IDs][i] ? 1:0,szUID,i);
		             }
		}
		case 3: {
			for(i=1; i < g_iKostumSayi; i++) {
			         sSetIntData("%s>iKostum>%i>",IP_IDsKostumKaydet[IP_IDs][i] ? 1:0,szUID,i);
		             }
		}
		case 4: {
			         sSetIntData("%s>iXP",IP_IDszAnt[IP_IDs][sXP],szUID);
			         sSetIntData("%s>iLevel",IP_IDszAnt[IP_IDs][sLevel],szUID);
		}
		case 5: {
			for(i=1; i < sizeof(szDeathEffect); i++) {
			         sSetIntData("%s>iEffects>%i>",IP_IDsEffectsKaydet[IP_IDs][i] ? 1:0,szUID,i);
		             }
		}
		case 6: {
			for(i=1; i < g_iKanatSayi; i++) {
			         sSetIntData("%s>iKanat>%i>",IP_IDsKanatKaydet[IP_IDs][i] ? 1:0,szUID,i);
		             }
		}
		case 7: {
			// Bicak menu (knife/character model) secimleri artik kaydedilmiyor - kasitli olarak devre disi birakildi
		}
		case 8: {
			sSetIntData("%s>iHudRenk",IP_IDszAnt[IP_IDs][sHudRenk],szUID);
			sSetIntData("%s>iHudKonum",IP_IDszAnt[IP_IDs][sHudKonum],szUID);
			sSetIntData("%s>iHudDurum",IP_IDsBool[IP_IDs][sHudDurum] ? 1:0,szUID);
			sSetIntData("%s>iSisRenk",IP_IDszAnt[IP_IDs][sSisRenk],szUID);
			sSetIntData("%s>iSisYogunluk",IP_IDszAnt[IP_IDs][sSisYogunluk],szUID);
			sSetIntData("%s>iSisAktif",IP_IDsBool[IP_IDs][sSisAktif] ? 1:0,szUID);
			sSetIntData("%s>iSesMenuAktif",IP_IDsBool[IP_IDs][sSesMenuAktif] ? 1:0,szUID);
			sSetIntData("%s>iSesLevelAktif",IP_IDsBool[IP_IDs][sSesLevelAktif] ? 1:0,szUID);
			sSetIntData("%s>iSesGeriSayimAktif",IP_IDsBool[IP_IDs][sSesGeriSayimAktif] ? 1:0,szUID);
			sSetIntData("%s>iSesModAktif",IP_IDsBool[IP_IDs][sSesModAktif] ? 1:0,szUID);
			sSetIntData("%s>iDilID",IP_IDszAnt[IP_IDs][sDilID],szUID);
		}
		case 9: {
			sSetIntData("%s>iSinifKaydiInsan",IP_IDsBool[IP_IDs][sSinifKaydiInsan] ? 1:0,szUID);
			sSetIntData("%s>iSinifKaydiZombi",IP_IDsBool[IP_IDs][sSinifKaydiZombi] ? 1:0,szUID);
			sSetIntData("%s>iSinifKaydiHero",IP_IDsBool[IP_IDs][sSinifKaydiHero] ? 1:0,szUID);
			sSetIntData("%s>iSinifKaydiNemesis",IP_IDsBool[IP_IDs][sSinifKaydiNemesis] ? 1:0,szUID);
			sSetIntData("%s>iSinifKaydiInsanVal",IP_IDszAnt[IP_IDs][sClassValue],szUID);
			sSetIntData("%s>iSinifKaydiZombiVal",IP_IDszAnt[IP_IDs][sZombieClassSaved],szUID);
			sSetIntData("%s>iSinifKaydiHeroVal",IP_IDszAnt[IP_IDs][sHeroClassValue],szUID);
			sSetIntData("%s>iSinifKaydiNemesisVal",IP_IDszAnt[IP_IDs][sNemesisClassValue],szUID);
		}
	  }
	}
		return PLUGIN_HANDLED;
}
@sWingEntityCreate(const IP_IDs, const szNumsHat) {
        switch(szNumsHat) {
                case 0: {
                        IP_IDszAnt[IP_IDs][sKanat] > 0 ? rg_remove_enttity(IP_IDszAnt[IP_IDs][sKanat]):(IP_IDszAnt[IP_IDs][sKanat] = 0);
                }
                default: {
                        IP_IDszAnt[IP_IDs][sKanat] = rg_create_entity("info_target");
                        set_entvar(IP_IDszAnt[IP_IDs][sKanat],var_movetype,MOVETYPE_FOLLOW);
                        set_entvar(IP_IDszAnt[IP_IDs][sKanat],var_aiment,IP_IDs);
                        set_entvar(IP_IDszAnt[IP_IDs][sKanat],var_rendermode,kRenderNormal);
                        set_entvar(IP_IDszAnt[IP_IDs][sKanat],var_modelindex,IP_IDsKanatBul[szNumsHat]);
                }
        }
}
rg_remove_enttity(const iEnt){
        if(is_entity(iEnt))
                set_entvar(iEnt,var_flags,FL_KILLME);
}
sPlayConstSound(const IP_IDs, const szNum) {
   if(szNum != Novaria_SND_EQUIP && szNum != Novaria_SND_INFORMATION && szNum != Novaria_SND_MENU && szNum != Novaria_SND_WAIT && szNum != Novaria_SND_ZPLRS_MENU && szNum != Novaria_SND_ODULBILME) return;
   if(szNum == Novaria_SND_MENU) {
        if(!IP_IDsBool[IP_IDs][sSesMenuAktif]) return;
   } else {
        if(!IP_IDsBool[IP_IDs][sSesModAktif]) return;
   }
   if(!IP_IDsBool[IP_IDs][sSetting])  {
        rg_send_audio(IP_IDs, szSoundEffect[szNum]);
   }
}
stock sGetPlayCountSound(const ses[]) {
   new IP_IDsPlayer[32], sNum;
   get_players(IP_IDsPlayer, sNum);
   for(new i = 0; i < sNum; i++) {
        new IP_IDs = IP_IDsPlayer[i];
        if(!IP_IDsBool[IP_IDs][sSesGeriSayimAktif]) continue;
        emit_sound(IP_IDs, CHAN_AUTO, ses, VOL_NORM, ATTN_NORM , 0, PITCH_NORM);
   }
}
stock sGetPlayerBarEffect(IP_IDs, sID) {
    message_begin(MSG_ONE, get_user_msgid("BarTime"), _, IP_IDs);
    write_short(sID);
    message_end();
}

sShowEffectSpr(attacker, sprite) {
    if(!is_user_connected(attacker)) return PLUGIN_CONTINUE;
    static Float:origin[3];
    get_entvar(attacker, var_origin, origin);
    message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
    write_byte(TE_SPRITE);
    write_coord_f(origin[0]);
    write_coord_f(origin[1]);
    write_coord_f(origin[2]+65.0);
    write_short(sprite);
    write_byte(3);
    write_byte(250);
    message_end();
    return PLUGIN_CONTINUE;
}

// BUGFIX (kullanici talebi): @sStartLevelUpSprLoop ve @sLevelUpSprPreThink
// fonksiyonlari tamamen kaldirildi - level-up sprite gorseli artik yok.


stock sGetIntData(const sS_Key[],any:...){
	new sL_FixedData[128];
	vformat(sL_FixedData,127,sS_Key,2);
	return nvault_get(IP_IDsGlobal[sVault],sL_FixedData);
}
stock sSetIntData(const sS_Key[],const iS_Data,any:...){
	new sL_FixedData[128],sL_NumToStr[48];
	vformat(sL_FixedData,127,sS_Key,3);
	num_to_str(iS_Data,sL_NumToStr,47);
	nvault_set(IP_IDsGlobal[sVault],sL_FixedData,sL_NumToStr);
}
stock sGetIntDataMenu(const sS_Key[],any:...){
	new sL_FixedData[128];
	vformat(sL_FixedData,127,sS_Key,2);
	return nvault_get(IP_IDsGlobal[sVaultMenu],sL_FixedData);
}
stock sSetIntDataMenu(const sS_Key[],const iS_Data,any:...){
	new sL_FixedData[128],sL_NumToStr[48];
	vformat(sL_FixedData,127,sS_Key,3);
	num_to_str(iS_Data,sL_NumToStr,47);
	nvault_set(IP_IDsGlobal[sVaultMenu],sL_FixedData,sL_NumToStr);
}
@sGetPlayerSendMesaage(const sColor[], const alive, const sMessage[]) {
    new sTeamName[10];
    for(new IP_IDs = 1; IP_IDs <= MaxClients; IP_IDs++){
        if(!is_user_connected(IP_IDs))
            continue;
        if(alive && is_user_alive(IP_IDs) || !alive && !is_user_alive(IP_IDs) || get_user_flags(IP_IDs) & ADMIN_LEVEL_C){
            get_user_team(IP_IDs, sTeamName, 9);
            @sGetPlayerChangeTeam(IP_IDs, sColor);
            @sGetPlayerWriteMessage(IP_IDs, sMessage);
            @sGetPlayerChangeTeam(IP_IDs, sTeamName);
        }
    }
}
// say_team icin: mesaj sadece gonderenle AYNI takimdaki (ADMIN_LEVEL_C admin'ler her zaman) oyunculara gider.
@sGetPlayerSendMesaageTeam(const iSenderTeam, const sColor[], const alive, const sMessage[]) {
    new sTeamName[10];
    for(new IP_IDs = 1; IP_IDs <= MaxClients; IP_IDs++){
        if(!is_user_connected(IP_IDs))
            continue;
        if(get_user_team(IP_IDs) != iSenderTeam && !(get_user_flags(IP_IDs) & ADMIN_LEVEL_C))
            continue;
        if(alive && is_user_alive(IP_IDs) || !alive && !is_user_alive(IP_IDs) || get_user_flags(IP_IDs) & ADMIN_LEVEL_C){
            get_user_team(IP_IDs, sTeamName, 9);
            @sGetPlayerChangeTeam(IP_IDs, sColor);
            @sGetPlayerWriteMessage(IP_IDs, sMessage);
            @sGetPlayerChangeTeam(IP_IDs, sTeamName);
        }
    }
}
@sGetPlayerChangeTeam(const IP_IDs, const sTeam[]) {
    message_begin(MSG_ONE, IP_IDsGlobal[sTeamInfo], _, IP_IDs);
    write_byte(IP_IDs);
    write_string(sTeam);
    message_end();
}
@sGetPlayerWriteMessage(const IP_IDs, const sMessage[]) {
    message_begin(MSG_ONE, IP_IDsGlobal[sSayText], {0, 0, 0}, IP_IDs);
    write_byte(IP_IDs);
    write_string(sMessage);
    message_end();
}
