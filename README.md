=============================================================================
NOVARIA ZOMBIE ESCAPE - COUNTER-STRIKE 1.6
=============================================================================

Türkiye'den Güney Kore'deki tüm Counter-Strike 1.6 oyuncularına ve geliştirici 
kardeşlerimize kucak dolusu sevgiler ve saygılar! Kore'yi, kültürünüzü ve 
oyun topluluğunuzu çok seviyoruz. Birlikte harika işler başarmaya devam edelim! 🇰🇷❤️🇹🇷

한국의 모든 Counter-Strike 1.6 플레이어 및 개발자 여러분께 튀르키예에서 
깊은 사랑과 응원을 보냅니다. 우리는 여러분의 커뮤니티와 문화를 정말 사랑합니다! 🇰🇷❤️

=============================================================================

-----------------------------------------------------------------------------
🇰🇷 한국어 (KOREAN)
-----------------------------------------------------------------------------

[ 프로젝트 소개 ]
이 레포지토리는 Counter-Strike 1.6을 위한 차세대 커스텀 'Zombie Plague / Zombie Escape' 코어를 포함하고 있습니다. 
기존의 무겁고 복잡한 코어에서 벗어나, 서버 성능(Tickrate/FPS)을 최적화하고 확장성을 극대화하는 데 초점을 맞추어 재설계되었습니다. 
모든 한국의 CS 1.6 서버 관리자분들이 더욱 쾌적하고 안정적인 서버를 운영하시기를 기원합니다!

[ 🛠 상세 개발자 노트 (Developer Notes & API) ]

1. 독립적인 메인 메뉴 시스템 (Modular Main Menu)
과거 버전의 가장 큰 문제점은 채팅 태그, 유저 권한(Role), 언어 시스템, 메뉴 UI가 코어(Core) 플러그인에 하드코딩되어 있었다는 점입니다.
Novaria 코어에서는 이 모든 프론트엔드 요소가 'Novaria_zemainmenu.sma' 플러그인으로 완전히 분리되었습니다.
- 장점: 코어를 수정할 필요 없이 메뉴 디자인이나 텍스트를 마음대로 바꿀 수 있습니다.
- 동기화: 유저의 테마 데이터나 설정은 'nvault'를 통해 코어와 서브 플러그인 간에 안전하게 동기화됩니다.

2. INI 기반의 동적 모델 관리 (Dynamic Model System)
무기, 플레이어(좀비/인간), 하늘(Skybox) 모델을 변경하기 위해 더 이상 SMA 파일을 열고 컴파일할 필요가 없습니다.
서버 루트 폴더에 위치한 'zombieplague.ini' 파일만을 수정하여 모든 리소스를 관리합니다.
[Player Models]
HUMAN = sas, gign, arctic
NEMESIS = nemesis_model
[Weapon Models]
V_KNIFE_HUMAN = models/v_knife.mdl
- 작동 방식: 서버 맵이 변경될 때(Mapchang), 코어가 이 INI 파일을 읽고 자동으로 해당 모델들을 프리캐시(Precache)합니다. 모델을 지우고 싶다면 파일에서 줄을 삭제하기만 하면 됩니다.

3. 엑스트라 아이템 (Extra Items) 커스텀 API
기존의 아이템 추가 방식보다 훨씬 직관적인 API를 제공합니다. 개별 플러그인을 만들어 아래와 같이 등록하세요.
(예시 코드)
new g_item_id;
public plugin_init() {
    register_plugin("Custom Item", "0.1", "Author");
    g_item_id = zp_register_extra_item("강력한 성수 (Holy Water)", 30, ZP 정_TEAM_HUMAN);
}
public zp_extra_item_selected(id, itemid) {
    if (itemid == g_item_id) {
        // 아이템 구매 시 작동할 코드 작성
        client_print(id, print_chat, "성수를 구매했습니다!");
    }
}

4. 확장된 네이티브 API (Extended Native API)
개발자들이 서브 모드를 쉽게 만들 수 있도록 풍부한 API를 지원합니다.
- 상태 확인 (Booleans):
  * zp_get_user_zombie(id) : 유저가 좀비인지 확인
  * zp_get_user_nemesis(id) : 유저가 네메시스인지 확인
  * zp_get_user_survivor(id) : 유저가 생존자인지 확인
  * zp_get_user_first_zombie(id) : 최초 감염자인지 확인
- 데이터 조작 (Getters/Setters):
  * zp_get_user_ammo_packs(id) : 현재 아모팩 개수 반환
  * zp_set_user_ammo_packs(id, amount) : 아모팩 개수 설정
  * zp_get_zombie_maxhealth(id) : 좀비 클래스의 최대 체력 반환
- 강제 액션 (Actions):
  * zp_infect_user(id, infector) : 특정 유저를 좀비로 감염
  * 단zp_disinfect_user(id) : 좀비를 인간으로 치료
  * zp_respawn_user(id) : 유저를 강제로 부활

5. Novaria 전용 VIP 및 코인 시스템 (VIP & Coin System)
기존 아모팩(Ammo Pack) 외에도 레벨업과 코인 시스템이 존재하며, VIP 등급에 따라 차별화된 혜택과 날개(Wings), 꼬리(Trail) 등의 외형 아이템을 제공합니다.
또한 VIP 전용 엑스트라 아이템을 쉽게 추가할 수 있습니다:
(예시 코드)
// 1=VIP, 2=S-VIP, 3=Gold, 4=Diamond, 5=Premium
new g_iVipItemId;
public plugin_init() {
    register_plugin("VIP Weapon", "1.0", "Author");
    
    // 사용법: novaria_vip_extra_items("아이템 이름", "VIP 등급", "가격")
    g_iVipItemId = novaria_vip_extra_items("Thunderbolt", "2", "40"); 
}

-----------------------------------------------------------------------------
🇹🇷 TÜRKÇE (TURKISH)
-----------------------------------------------------------------------------

[ Proje Hakkında ]
Bu depo, Counter-Strike 1.6 için sıfırdan optimize edilerek geliştirilmiş özel bir Zombie Plague / Zombie Escape çekirdeği (core) içerir.
Eski ve hantal kod bloklarından arındırılmış, yüksek FPS ve düşük gecikme (ping) hedeflenerek modüler bir yapıya kavuşturulmuştur.

[ 🛠 Detaylı Geliştirici Notları (Developer Notes & API) ]

1. Bağımsız Ana Menü (Main Menu) Mimarisi
Önceki Zombie Plague sürümlerinde rol, sohbet etiketleri, dil desteği ve menü arayüzleri doğrudan ana çekirdeğin içine gömülüydü.
Novaria sürümünde ise bu yapı tamamen ayrıştırılarak 'Novaria_zemainmenu.sma' adlı ayrı bir eklentiye taşınmıştır.
- Avantajı: Çekirdek eklentiyi derlemek zorunda kalmadan menü görünümlerini ve metinleri özgürce değiştirebilirsiniz.
- Senkronizasyon: Oyuncu tercihleri ve tema ayarları 'nvault' üzerinden modüller arasında kayıpsız bir şekilde aktarılır.

2. INI Dosyası ile Dinamik Model Yönetimi
Oyuncu, silah veya gökyüzü (skybox) modellerini sunucuya eklemek için SMA dosyası düzenleyip derlemenize gerek kalmadı.
'zombieplague.ini' dosyasını kullanarak tüm modelleri yönetebilirsiniz.
[Player Models]
HUMAN = sas, gign
NEMESIS = nemesis_boss
- Nasıl Çalışır: Sunucu harita değiştirdiğinde, çekirdek bu INI dosyasını okur ve yazılı olan modelleri otomatik olarak yükler (precache). Kullanmadığınız modeli sadece dosyadan silmeniz yeterlidir.

3. Ekstra Eşya (Extra Item) Ekleme API'si
Sadece birkaç satır kod ile alt eklentiler (sub-plugins) oluşturarak markete yeni eşyalar ekleyebilirsiniz:
(Örnek Kod)
new g_item_id;
public plugin_init() {
    register_plugin("Ozel Silah", "0.1", "Gelistirici");
    g_item_id = zp_register_extra_item("Lazer Silahi", 25, ZP_TEAM_HUMAN);
}
public zp_extra_item_selected(id, itemid) {
    if (itemid == g_item_id) {
        // Satin alindiktan sonra calisacak kod
        client_print(id, print_chat, "Lazer silahi basariyla alindi!");
    }
}

4. Genişletilmiş Native API Listesi
Kendi oyun modlarınızı (örn. Assassin, Sniper modları) yazabilmeniz için kapsamlı fonksiyonlar:
- Durum Sorguları (Checks):
  * zp_get_user_zombie(id) : Oyuncu zombi mi?
  * zp_get_user_nemesis(id) : Oyuncu Nemesis mi?
  * zp_has_round_started() : Zombi salgını başladı mı?
- Veri İşlemleri (Get/Set):
  * zp_get_user_ammo_packs(id) : Oyuncunun mermi paketini getirir.
  * zp_set_user_ammo_packs(id, miktar) : Oyuncunun mermi paketini ayarlar.
- Aksiyonlar (Actions):
  * zp_infect_user(id, saldirgan) : Oyuncuyu zombiye dönüştürür.
  * zp_disinfect_user(id) : Zombiyi tekrar insana dönüştürür (Antidot).
  * zp_respawn_user(id) : Ölen oyuncuyu canlandırır.

5. Novaria VIP, Level ve Coin Sistemi
Standart Ammo Pack sisteminin ötesinde oyuncular XP ve Coin kazanarak seviye atlayabilir. Ayrıca VIP sınıflarına özel Kanat, Kuyruk gibi kozmetikler bulunur.
Sadece belirli bir VIP sınıfına özel ekstra eşya eklemek artık çok kolaydır:
(Örnek Kod)
// "1" VIP, "2" S-VIP, "3" Gold VIP, "4" Diamond VIP, "5" Premium VIP
new g_iVipItemId;
public plugin_init() {
    register_plugin("VIP Ozel Silah", "0.1", "Yazar");
    
    // Kullanım: novaria_vip_extra_items("Eşya Adı", "VIP Seviyesi", "Fiyat")
    g_iVipItemId = novaria_vip_extra_items("Thunderbolt", "2", "40"); 
}

-----------------------------------------------------------------------------
🇬🇧 ENGLISH (ENGLISH)
-----------------------------------------------------------------------------

[ Project Overview ]
This repository contains a next-generation custom Zombie Plague / Zombie Escape core designed for Counter-Strike 1.6.
It has been rewritten to strip away outdated bloatware, focusing heavily on server stability, higher tickrates, and modular scalability.

[ 🛠 Detailed Developer Notes & API ]

1. Modular Main Menu System
In older versions, roles, chat tags, language logic, and menu UI were hardcoded into the main core plugin.
With the Novaria core, all frontend features have been completely extracted into a standalone plugin: 'Novaria_zemainmenu.sma'.
- Benefit: You can customize your server's look and feel without ever touching or recompiling the core logic.
- Synchronization: User themes and settings are safely shared between the core and sub-plugins via 'nvault'.

2. INI-Based Dynamic Model Management
You no longer need to edit SMA files to change player, weapon, or skybox models.
Everything is dynamically loaded using the 'zombieplague.ini' configuration file.
[Player Models]
HUMAN = sas, gign
NEMESIS = nemesis_model
- How it works: On map change, the core parses this INI file and automatically precaches the defined models. To remove a model, simply delete its line from the text file. No recompilation required.

3. Custom Extra Items API
Creating additional items for the shop is straightforward using our provided natives.
(Example Code)
new g_item_id;
public plugin_init() {
    register_plugin("Custom Item", "0.1", "Author");
    g_item_id = zp_register_extra_item("Holy Grenade", 30, ZP_TEAM_HUMAN);
}
public zp_extra_item_selected(id, itemid) {
    if (itemid == g_item_id) {
        // Logic to give the item
        client_print(id, print_chat, "You bought a Holy Grenade!");
    }
}

4. Extended Native API Reference
A rich set of natives is provided to help developers build sub-mods easily.
- Booleans / Checks:
  * zp_get_user_zombie(id) : Returns true if the player is a zombie.
  * zp_get_user_nemesis(id) : Returns true if the player is a Nemesis.
  * zp_has_round_started() : Returns true if the infection has started.
- Getters / Setters:
  * zp_get_user_ammo_packs(id) : Gets the player's current ammo packs.
  * zp_set_user_ammo_packs(id, amount) : Sets the player's ammo packs.
- Actions:
  * zp_infect_user(id, infector) : Turns a human into a zombie.
  * zp_disinfect_user(id) : Turns a zombie back into a human.
  * zp_respawn_user(id) : Forces a player to respawn.

5. Novaria VIP, Level & Coin System
Beyond the standard Ammo Packs, players can level up by earning XP and Coins. The core features exclusive VIP cosmetics like Wings and Trails.
You can easily register VIP-exclusive extra items to the shop:
(Example Code)
// "1" VIP, "2" S-VIP, "3" Gold VIP, "4" Diamond VIP, "5" Premium VIP
new g_iVipItemId;
public plugin_init() {
    register_plugin("VIP Exclusive Weapon", "0.1", "Author");
    
    // Usage: novaria_vip_extra_items("Item Name", "VIP Tier", "Price")
    g_iVipItemId = novaria_vip_extra_items("Thunderbolt", "2", "40"); 
}
