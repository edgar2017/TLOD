/*
Current updates:
 * Added campfires
 * changed craft dialog style
 * Uncooked fish/meat can be cooked with a campfire
*/

#include <a_samp>
#include <sscanf2>
#include <a_mysql>
#include <KickBan>
#include <progress2>
#include <MapAndreas>
#include <FCNPC>
#include <zcmd>

#undef  MAX_PLAYERS
#undef 	MAX_VEHICLES

#define COLOR_INVISIBLE 0xFFFFFF00
#define COLOR_WHITE 	0xFFFFFFFF
#define COLOR_BLACK 	0x000000FF
#define COLOR_BLUE 		0x0000DDFF
#define COLOR_RED2      0xFF0000AA
#define COLOR_RED 		0xAA3333AA
#define COLOR_GREEN 	0x00FF00FF
#define COLOR_PURPLE 	0xC2A2DAAA
#define COLOR_YELLOW 	0xFFFF00AA
#define COLOR_GREY 		0xAFAFAFAA
#define COLOR_ORANGE 	0xFF5F11FF
#define COLOR_BROWN 	0x804000FF
#define COLOR_CYAN 		0x00FFFFFF
#define COLOR_PINK 		0xFF80C0FF

#define CHAT_WHITE 		"{FFFFFF}"
#define CHAT_GREY 		"{AFAFAF}"
#define CHAT_RED 		"{FF0000}"
#define CHAT_YELLOW 	"{FFFF00}"
#define CHAT_LIGHTBLUE 	"{33CCFF}"
#define CHAT_BLACK      "{0E0101}"
#define CHAT_GREEN	   	"{6EF83C}"
#define CHAT_ORANGE     "{FFAF00}"
#define CHAT_LIME       "{B7FF00}"
#define CHAT_CYAN       "{00FFEE}"
#define CHAT_PARAM   	"{3FCD02}"
#define CHAT_SERVER     "{E6FF8A}"
#define CHAT_VALUE    	"{A3E4FF}"
#define CHAT_BROWN   	"{804000}"

#define ModelUnknown    18631
#define ModelDeerSkin 	2386
#define ModelBandage 	1575
#define ModelMedkit 	1580
#define ModelPizza 		1582
#define ModelBurger 	2703
#define ModelSoda 		2601
#define ModelWater 		1950
#define ModelEWater 	1951
#define ModelHammer 	18635
#define ModelGate1 		2930
#define ModelGate2 		3050
#define ModelWall 		19356
#define ModelWalldoor 	19386
#define ModelBag5 		363
#define ModelBag10 		3026
#define ModelBag20 		371
#define ModelBag30 		2663
#define ModelBag40 		2060
#define ModelBag50 		1310
#define ModelToolbox	2694
#define ModelBox 		1271
#define ModelRope       19087
#define ModelRake       18890
#define ModelBed 		1647//14866 //2384
#define ModelEngine 	920
#define ModelMeatBag    2803
#define ModelMeatUC 	2806
#define ModelMeatC 		2804
#define ModelFishUC 	1600
#define ModelFishC 		1599
#define ModelFishRob 	18632
#define ModelIron 		905
#define ModelCU 		2936
#define ModelGolf 		333
#define ModelNight 		334
#define ModelKnife 		335
#define ModelBaseball 	336
#define ModelShovel 	337
#define ModelPool 		338
#define ModelKatana 	339
#define ModelChainsaw 	341
#define ModelPurple 	321
#define ModelDildo 		322
#define ModelVibrator 	323
#define ModelSilver 	324
#define ModelFlowers 	325
#define ModelCane 		326
#define ModelGrenade 	342
#define ModelTearGas 	343
#define ModelMolotov 	344
#define Model9mm 		346
#define ModelSilenced 	347
#define ModelDeagle 	348
#define ModelShotgun 	349
#define ModelSawnoff 	350
#define ModelCombat 	351
#define ModelUzi 		352
#define ModelMp5 		353
#define ModelAK47 		355
#define ModelM4 		356
#define ModelTec9 		372
#define ModelRifle 		357
#define ModelSniper 	358
#define ModelSpraycan 	365
#define ModelFire 		366
#define ModelArmour     1242
#define ModelCamera 	367
#define ModelAColt 		2037
#define ModelAShotgun 	2039
#define ModelASMS 		2038
#define ModelAAus 		2040
#define ModelARifle 	2969
#define ModelGascan 	1650
#define ModelEGascan 	2057
#define ModelGpsMap 	19513
#define ModelWood 		1463
#define ModelCampfire	841

#define pLoop() 		for(new i = 0, j = GetMaxPlayers(); i < j; i++) if(IsPlayerConnected(i))
#define Loop(%0)    	for(new i = 0; i < %0; i++)
#define LoopEx(%0,%1)   for(new i = %0, j = %1; i < j; i++)
#define PRESSED(%0) 	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define GNAME 			"TLOD 1.0"
#define MNAME 			"|-[LandDeath]-|"
#define HNAME 			"The Land Of Death"

#define MAX_ZOMBIES     100
#define MAX_PLAYERS     30
#define MAX_VEHICLES    50
#define MAX_INV_ITEMS   50

//try to do the total amount less than 1000 (1000 = max objects)
#define MAX_ITEMS       350
#define MAX_DEERS 		50
#define MAX_TREES		450
#define MAX_BOXES       100

#define SQL_PASSWORD    ""
#define SQL_USER        "TLOD"
#define SQL_DB          "TLOD"
#define SQL_SERVER      "127.0.0.1"

new g_SQL = -1;

enum
{
    DIALOG_UNUSED,
    DIALOG_CRAFT,
    DIALOG_INVENTORY,
    DIALOG_INVENTORY2,
    DIALOG_INVENTORY3,
    DIALOG_REGISTER,
    DIALOG_LOGIN,
    DIALOG_GPS
};

enum e_items
{
	ItemObject,
	Text3D:ItemText,
    ItemModel,
    ItemAmount,
    Float:ItemPos[3],
    Float:ItemRot[3]
};

new Items[MAX_ITEMS][e_items];

enum e_player
{
	Name[MAX_PLAYER_NAME],
	Password[32],
	IP[16],
	Adminlevel,
	Float:SpawnPos[3],
	Skin,
	Timer[4],
	InvSize,
	Float:Hunger,
	Float:Thirst,
	Float:Sleep,
	Float:Experience,
	Level,
	PlayerBar:SleepBar,
	PlayerBar:MiningBar,
	PlayerBar:HungerBar,
	PlayerBar:ThirstBar,
	PlayerBar:ExpBar,
	bool:Logged,
	bool:Died,
	tmpSlot,
	Kills[3], //[0] = player/human kills, [1] = zombie kills, [2] = deers killed
	Count[3] //[0] = items picked up, [1] = items crafted, [2] = trees chopped
};

new Player[MAX_PLAYERS][e_player],PlayerText:FuelText;

enum e_inv
{
	Item,
	Name[32],
	Amount
}
new PlayerInv[MAX_PLAYERS][MAX_INV_ITEMS][e_inv];
new Deers[MAX_DEERS];

enum e_trees
{
	TreeObject,
	Float:Health,
	TreeModel,
	Text3D:TreeText,
	Float:SpawnPos[3]
};

new Trees[MAX_TREES][e_trees];

enum e_boxes
{
	BoxObject,
	Float:SpawnPos[3],
	b_Items[10]
	//owner ??
};

new Boxes[MAX_BOXES][e_boxes];

enum e_vehicles
{
	Veh,
	VehModel,
	Float:Fuel,
	bool:Engine,
	Float:SpawnPos[4]
};

new Vehicles[MAX_VEHICLES][e_vehicles];

enum e_campf
{
	Float:SpawnPos[3],
	CampfObject[2],
	bool:Occupied
};

new CampFire[MAX_BOXES][e_campf];

enum e_server
{
	cTrees,
	cVehicles,
	iFood[5],
	iBuild[5],
	iWeapons[6],
	iStuff[8]
};
new Server_Data[e_server];
new Float:RandomSpawns[][] =
{
	{-89.0351,-1564.9932,3.0043,105.2555},
	{-88.2427,-1202.1268,2.8906,295.5774},
	{-359.7300,-1042.5619,59.3953,151.4224},
	{-583.7015,-1056.2892,23.1733,220.9766},
	{-572.4352,-1498.3156,9.5611,315.5179},
	{-365.9491,-1418.1000,25.7266,197.9067},
	{-1097.9579,-1622.5590,76.3672,62.8151},
	{-1059.6812,-1193.8805,129.2188,87.8313},
	{-1434.7700,-1496.1621,101.7292,186.8205},
	{-1845.9764,-1707.5901,41.1129,25.4613},
	{-2204.0164,-2309.8787,31.3750,49.2681}
};

new Float:DeerSpawn[][3]=
{
	{-475.22012, -387.80862, 14.93388},
	{-814.95184, -789.86145, 152.69458},
	{-820.04846, -801.82751, 149.54356},
	{-843.11810, -812.59625, 149.03250},
	{-1061.10583, -989.05859, 128.63142},
	{-1087.23853, -975.28485, 128.63142},
	{-1095.62305, -949.64294, 128.63142},
	{-998.71204, -1580.69971, 75.74928},
	{-993.51556, -1585.88379, 75.74928},
	{-815.17487, -2020.73645, 14.63516},
	{-448.08316, -2160.36255, 86.19398},
	{-710.33075, -2455.31836, 67.16925},
	{-692.01318, -2439.49121, 64.41492},
	{-1322.94849, -2110.92896, 27.15998},
	{-1264.87451, -2112.70215, 24.73434},
	{-1659.87561, -2194.57227, 32.78931},
	{ -1792.07507, -2175.78125, 72.54773},
	{ -1939.97278, -1903.64844, 83.94247},
	{ -2087.59448, -2138.61768, 47.42846},
	{-2066.40259, -2158.11450, 47.42846},
	{-2079.26050, -2160.11963, 47.42846}
};

new s_string[64],m_string[128],b_string[256];

forward FCNPC_Moving(npcid);
forward FCNPC_ResetKeys(npcid);
forward FCNPC_DoRespawn(npcid);
forward Update(playerid);
forward Float:frandom(Float:max, Float:min = 0.0, dp = 4);
forward MoveDeer(deerid);
forward UpdateHT(playerid);
forward UpdateSleep(playerid);
forward UpdateFuel(playerid);
forward RespawnDeer(deerid);

forward OnPlayerAccountCheck(playerid);
forward OnPlayerLogin(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerInventoryLoad(playerid);
forward OnTreesLoaded();
forward OnVehiclesLoaded();
forward RegrowTree(treeid);
forward EndFishing(playerid);
forward Cook(campfireid, playerid, item);

#define GivePlayerScore(%0,%1) 	SetPlayerScore(%0,GetPlayerScore(%0)+%1)
#define GivePlayerHunger(%0,%1) Player[%0][Hunger] += %1
#define SetPlayerHunger(%0,%1)  Player[%0][Hunger] = %1
#define SetPlayerThirst(%0,%1) 	Player[%0][Thirst] = %1

main()
{
	print("\n----------------------------------");
	print(" TLOD rescripted by Michael@Belgium ");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	//mysql_log(LOG_ALL);
	g_SQL = mysql_connect(SQL_SERVER, SQL_USER, SQL_DB, SQL_PASSWORD);
	if(mysql_errno() != 0)	print("Could not connect to database!");
	
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
	ShowPlayerMarkers(false);
    ShowNameTags(false);
    ManualVehicleEngineAndLights();
    
	SetGameModeText(GNAME);
	SendRconCommand("mapname "MNAME"");
	SendRconCommand("hostname "HNAME"");
	
	ZombieInit();
	ItemInit();

    mysql_tquery(g_SQL,"SELECT * FROM tree_data","OnTreesLoaded");
    mysql_tquery(g_SQL,"SELECT * FROM vehicle_data","OnVehiclesLoaded");
	
	Create3DTextLabel("Fish Point\n/fish", 0x008080FF,-1219.8186,-2363.8599,1.0119, 40.0, 0, 1);
	Create3DTextLabel("Fish Point\n/fish", 0x008080FF,-1207.7113,-2602.2327,1.0976, 40.0, 0, 1);
	Create3DTextLabel("Fish Point\n/fish", 0x008080FF,-1178.8430,-2632.9854,11.7578, 40.0, 0, 1);

	CreateObject(13025, -569.18439, -1025.00049, 26.06928,   0.00000, 0.00000, 146.15991);
	CreateObject(13025, -80.48787, -1187.38989, 3.11425,   0.00000, 0.00000, -21.71999);
	CreateObject(13025, 30.16006, -2660.07666, 41.81733,   0.00000, 0.00000, 3.90000);
	CreateObject(13025, -1613.63513, -2697.45264, 49.81577,   0.00000, 0.00000, 144.53995);
	CreateObject(1808, -1619.20398, -2695.95630, 47.65625,   0.00000, 0.00000, -35.28000);
	CreateObject(1808, 24.93391, -2651.37744, 39.49156,   0.00000, 0.00000, -85.92000);
	CreateObject(1808, -91.04531, -1566.41492, 1.63277,   0.00000, 0.00000, 43.98000);
	CreateObject(1808, -83.88015, -1182.52478, 0.88781,   0.00000, 0.00000, -114.84000);
	CreateObject(17019, -541.31757, -502.61526, 30.52344,   3.14159, 0.00000, 0.55080);
	CreateObject(16564, -582.34985, -518.44684, 24.49944,   0.00000, 0.00000, -90.12000);
	CreateObject(16302, -1039.89233, -2287.09058, 52.87072,   0.00000, 0.00000, 0.00000);
	CreateObject(16085, -1037.16040, -2303.47852, 54.55200,   0.00000, 0.00000, 0.00000);
	CreateObject(18249, -1002.49091, -2315.20459, 62.75808,   0.00000, 0.00000, 0.00000);
	CreateObject(16302, -1047.35205, -2322.59985, 58.81273,   0.00000, 0.00000, 0.00000);
	CreateObject(18251, -1384.31982, -2395.00488, 41.23079,   0.00000, 0.00000, 0.00000);
	CreateObject(18245, -1333.90210, -2374.75415, 44.34923,   0.00000, 0.00000, 0.00000);
	CreateObject(16302, -1310.52820, -2407.88208, 25.79182,   0.00000, 0.00000, 0.00000);
	CreateObject(16302, -1319.30713, -2424.81299, 28.07441,   0.00000, 0.00000, 0.00000);
	CreateObject(16564, -1557.61255, -2734.97998, 47.39766,   0.00000, 0.00000, 143.52000);
	CreateObject(1984,63.741,-3173.208,11.903,0.000,0.000,-10.000,300.000);
	CreateObject(2403,60.230,-3172.900,11.943,0.000,0.000,178.099,300.000);
	CreateObject(2496,55.381,-3172.776,14.013,0.000,0.000,82.100,300.000);
	CreateObject(19366,65.724,-3177.212,12.483,0.000,0.000,-9.000,300.000);
	CreateObject(341,55.397,-3172.837,12.872,-5.700,25.500,-79.500,300.000);
	CreateObject(342,55.401,-3173.831,12.703,0.000,0.000,0.000,300.000);
	CreateObject(344,55.596,-3173.876,12.793,0.000,0.000,0.000,300.000);
	CreateObject(358,55.879,-3175.214,14.023,0.000,0.000,-53.700,300.000);
	CreateObject(351,56.981,-3176.620,13.193,0.000,0.000,-29.300,300.000);
	CreateObject(355,59.036,-3177.690,14.223,0.000,0.000,-4.399,300.000);
	CreateObject(371,57.961,-3177.329,13.863,0.000,0.000,162.400,300.000);
	CreateObject(2969,56.117,-3174.970,12.723,0.000,0.000,-60.500,300.000);
	CreateObject(2039,57.333,-3176.375,12.743,0.000,0.000,-44.099,300.000);
	CreateObject(2040,59.217,-3177.364,12.723,0.000,0.000,76.999,300.000);
	CreateObject(4866, 53.95642, -1536.57849, 12.47890,   -90.06003, 28.26000, -67.49998);
	CreateObject(4866, 23.34987, -1840.43970, 12.47890,   -90.06003, 28.26000, -67.49998);
	CreateObject(4866, 34.19810, -2141.02393, 12.47890,   -90.06003, 28.26000, -51.71999);
	CreateObject(4866, 87.55744, -2443.65918, 12.47890,   -90.06003, 28.26000, -51.71999);
	CreateObject(4866, 123.87428, -2751.13599, 12.47890,   -90.06003, 28.26000, -58.38000);
	CreateObject(4866, 136.79112, -3058.56812, 12.47890,   -90.06003, 28.26000, -60.24001);
	CreateObject(4866, -8.47176, -3225.43555, 12.47890,   -90.06003, 28.26000, -146.34001);
	CreateObject(4866, -195.89497, -3215.15234, 12.47890,   -90.06003, 28.26000, -162.35999);
	CreateObject(4866, -497.08722, -3158.93286, 12.47890,   -90.06003, 28.26000, -162.35999);
	CreateObject(4866, -774.59283, -3106.90259, 12.47890,   -90.06003, 28.26000, -162.35999);
	CreateObject(4866, -1344.28247, -3100.50952, 12.47890,   -90.06003, 28.26000, -149.10007);
	CreateObject(4866, -1051.24207, -3087.19946, 12.47890,   -90.06003, 28.26000, -149.10007);
	CreateObject(4866, -1593.91125, -3049.55225, 12.47890,   -90.06003, 28.26000, -178.32002);
	CreateObject(4866, -1884.95886, -2990.28662, 12.47890,   -90.06003, 28.26000, -148.14001);
	CreateObject(4866, -2162.46606, -3007.53516, 12.47890,   -90.06003, 28.26000, -148.14001);
	CreateObject(4866, -2453.93506, -3025.89111, 12.47890,   -90.06003, 28.26000, -148.14001);
	CreateObject(4866, -2702.73071, -2929.89673, 12.47890,   -90.06003, 28.26000, -196.49997);
	CreateObject(4866, -2894.79785, -2727.39404, 12.47890,   -90.06003, 28.26000, -200.10004);
	CreateObject(4866, -3012.57837, -2564.89136, 12.47890,   -90.06003, 28.26000, -217.74004);
	CreateObject(4866, -3041.74561, -2378.55835, 12.47890,   -90.06003, 28.26000, -253.14003);
	CreateObject(4866, -3024.46069, -2074.15967, 12.47890,   -90.06003, 28.26000, -236.70004);
	CreateObject(4866, -3041.74561, -2378.55835, 12.47890,   -90.06003, 28.26000, -253.14003);
	CreateObject(4866, -3049.73340, -1791.02930, 12.47890,   -90.06003, 28.26000, -236.70004);
	CreateObject(4866, -3068.02661, -1489.39417, 12.47890,   -90.06003, 28.26000, -239.87999);
	CreateObject(4866, -3056.78833, -1208.80261, 12.47890,   -90.06003, 28.26000, -248.28000);
	CreateObject(4866, -3032.86523, -933.17401, 12.47890,   -90.06003, 28.26000, -245.16000);
	CreateObject(4866, -3015.45435, -642.26312, 12.47890,   -90.06003, 28.26000, -245.16000);
	CreateObject(4866, -2891.90161, -400.04306, 13.75185,   -90.06003, 28.26000, -293.28000);
	CreateObject(4866, -2634.49219, -248.12166, 13.75185,   -90.06003, 28.26000, -308.88000);
	CreateObject(4866, -2419.67944, -207.85178, 13.62707,   -90.06003, 28.26000, -328.79999);
	CreateObject(4866, -2236.95020, -250.66141, 13.62707,   -90.06003, 28.26000, -349.08002);
	CreateObject(4866, -1949.58630, -305.13113, 13.62707,   -90.06003, 28.26000, -335.52002);
	CreateObject(4866, -1766.48254, -317.24445, 13.62707,   -90.06003, 28.26000, -335.52002);
	CreateObject(4866, -1739.90552, -450.19754, 13.62707,   -90.06003, 28.26000, -422.75998);
	CreateObject(4866, -1617.38184, -691.26740, 13.62707,   -90.06003, 28.26000, -366.12003);
	CreateObject(4866, -1447.85901, -714.31012, 13.62707,   -90.06003, 28.26000, -333.96011);
	CreateObject(4866, -1261.79248, -604.54236, 13.62707,   -90.06003, 28.26000, -281.64005);
	CreateObject(4866, -1070.10583, -375.71603, 13.62707,   -90.06003, 28.26000, -281.64005);
	CreateObject(4866, -863.35443, -289.51999, 13.62707,   -90.06003, 28.26000, -332.76001);
	CreateObject(17003, -981.99670, -331.88913, -27.28906,   -5.49841, 25.62000, 2.90597);
	CreateObject(4866, -556.85071, -295.15253, 13.62707,   -90.06003, 28.26000, -332.76001);
	CreateObject(4866, -274.89139, -380.26736, 13.62707,   -90.06003, 28.26000, -364.80002);
	CreateObject(4866, -164.29951, -582.86426, 13.62707,   -90.06003, 28.26000, -427.08002);
	CreateObject(4866, -71.10585, -810.53070, 13.62707,   -90.06003, 28.26000, -366.96005);
	CreateObject(4866, 63.74768, -1001.08533, 13.62707,   -90.06003, 28.26000, -401.45999);
	CreateObject(4866, 81.98046, -1233.04297, 13.62707,   -90.06003, 28.26000, -426.53998);
	CreateObject(13676, 78.38329, -1270.76038, 13.69531,   -0.66000, -6.12000, 0.00000);
	CreateObject(16118, 43.38285, -3195.50073, 9.80049,   0.00000, 0.00000, 0.00000);
	CreateObject(16118, 41.44685, -3157.80005, 9.80049,   0.00000, 0.00000, 0.00000);
	CreateObject(16118, 59.22781, -3125.85596, 9.80049,   0.00000, 0.00000, -73.02000);
	CreateObject(16118, 44.20632, -3208.07642, 9.80049,   0.00000, 0.00000, 0.00000);
	CreateObject(16118, 44.20632, -3208.07642, 21.20592,   0.00000, 0.00000, 0.00000);
	CreateObject(16118, 41.40242, -3161.68286, 24.11050,   0.00000, 0.00000, 0.00000);
	CreateObject(16118, 59.22781, -3125.85596, 21.55944,   0.00000, 0.00000, -73.02000);
	CreateObject(16118, 74.64277, -3118.03369, 9.80049,   0.00000, 0.00000, -92.22001);
	CreateObject(11490, 58.87569, -3173.25024, 10.43533,   0.00000, 0.00000, 81.06000);
	CreateObject(11491, 69.88630, -3174.94702, 11.91860,   0.00000, 0.00000, 80.22003);
	CreateObject(683, 70.03974, -3138.18530, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 84.10891, -3133.72412, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 96.85801, -3129.50122, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(671, 108.77918, -3123.64771, 6.16799,   0.00000, 0.00000, 0.00000);
	CreateObject(820, 82.56509, -3198.46167, 9.99539,   0.00000, 0.00000, 0.00000);
	CreateObject(820, 78.33753, -3191.66699, 9.99539,   0.00000, 0.00000, 0.00000);
	CreateObject(820, 84.27471, -3193.58301, 9.99539,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 58.09752, -3142.79224, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 79.42802, -3141.68628, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 104.51070, -3141.59204, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 117.82845, -3137.30591, 2.95848,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 135.60126, -3153.46753, 3.50775,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 128.50372, -3145.52808, 3.00980,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 111.22687, -3129.04810, 1.40254,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 150.75606, -3162.17798, 0.11985,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 144.46600, -3159.92383, 2.26505,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 147.32910, -3174.03174, 2.54145,   0.00000, 0.00000, 16.56000);
	CreateObject(683, 147.50880, -3202.34058, 4.16957,   0.00000, 0.00000, 38.52000);
	CreateObject(683, 136.44391, -3204.12793, 9.31639,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 147.58864, -3190.18945, 1.59616,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 147.77913, -3180.94849, 2.77645,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 125.31807, -3204.12476, 10.75279,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 115.83434, -3204.17529, 10.53913,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 105.41791, -3203.26392, 11.41172,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 95.27271, -3202.76685, 11.68549,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 84.93418, -3201.77466, 9.86393,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 76.40933, -3201.57764, 11.61779,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 65.02329, -3200.74780, 11.74911,   0.00000, 0.00000, 41.88000);
	CreateObject(683, 57.70544, -3200.47412, 12.88287,   0.00000, 0.00000, 0.00000);
	CreateObject(683, 122.25456, -3142.88916, 4.62099,   0.00000, 0.00000, 0.00000);
	CreateObject(16192, 43.30920, -3159.81763, -32.13888,   0.00000, 0.00000, 54.65999);
	CreateObject(17068, 126.59075, -3123.30713, 0.46947,   0.00000, 0.00000, 145.97997);
	CreateObject(16118, 78.16255, -3217.93433, 10.93601,   0.00000, 0.00000, 86.58002);
	CreateObject(16118, 123.16425, -3216.43579, 10.93601,   0.00000, 0.00000, 86.58002);
	CreateObject(16118, 158.32961, -3216.21753, 10.93601,   0.00000, 0.00000, 86.58002);
	CreateObject(16118, 155.57986, -3191.17480, 10.93601,   0.00000, 0.00000, 173.40002);
	CreateObject(16118, 148.09259, -3157.69116, 10.93601,   0.00000, 0.00000, 203.39999);
	CreateObject(3642, 121.32621, -3206.36279, 15.91735,   0.00000, 0.00000, 183.12001);
	CreateObject(3466, 100.13885, -3205.53589, 13.50996,   0.00000, 0.00000, -90.47999);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid,Player[playerid][Name],MAX_PLAYER_NAME);
    GetPlayerIp(playerid,Player[playerid][IP],16);

    Player[playerid][Adminlevel] = 0;
	Player[playerid][Skin] = random(300);
	Player[playerid][InvSize] = 5;
	Player[playerid][Logged] = false;
	Player[playerid][Died] = false;
	Player[playerid][Timer][0] = SetTimerEx("Update",2000,true,"i",playerid);
	Player[playerid][Timer][1] = SetTimerEx("UpdateHT",40*1000,true,"i",playerid);
	Player[playerid][Timer][2] = SetTimerEx("UpdateSleep",60*1000,true,"i",playerid);
	Player[playerid][SpawnPos][0] = 0.0;
	Player[playerid][SpawnPos][1] = 0.0;
	Player[playerid][SpawnPos][2] = 0.0;
	Player[playerid][HungerBar] = INVALID_PLAYER_BAR_ID;
	Player[playerid][ThirstBar] = INVALID_PLAYER_BAR_ID;
	Player[playerid][MiningBar] = INVALID_PLAYER_BAR_ID;
	Player[playerid][SleepBar] = INVALID_PLAYER_BAR_ID;
	Player[playerid][ExpBar] = INVALID_PLAYER_BAR_ID;
	Player[playerid][Hunger] = 100.0;
	Player[playerid][Thirst] = 100.0;
	Player[playerid][Sleep] = 100.0;
	Player[playerid][Experience] = 0.0;
	Player[playerid][Level] = 0;
	Loop(3) Player[playerid][Kills][i] = 0;
	Loop(3) Player[playerid][Count][i] = 0;
	
	Player[playerid][SleepBar] = CreatePlayerProgressBar(playerid, 548.000000, 56.000000, 62.000000, 5.000000, COLOR_WHITE, 100.000000, BAR_DIRECTION_RIGHT);
	Player[playerid][HungerBar] = CreatePlayerProgressBar(playerid, 548.000000, 42.000000, 62.000000, 5.000000, COLOR_YELLOW, 100.000000, BAR_DIRECTION_RIGHT);
	Player[playerid][ThirstBar] = CreatePlayerProgressBar(playerid, 548.000000, 27.000000, 62.000000, 5.000000, COLOR_BLUE, 100.000000, BAR_DIRECTION_RIGHT);
	Player[playerid][ExpBar] = CreatePlayerProgressBar(playerid, 499.000000, 105.000000, 112.000000, 11.000000, COLOR_ORANGE, 100.000000, BAR_DIRECTION_RIGHT);
	Player[playerid][MiningBar] = CreatePlayerProgressBar(playerid, 256.000000, 435.00, 128.50, 10.50, -16776961, 100.0, BAR_DIRECTION_RIGHT);
    ShowPlayerProgressBar(playerid, Player[playerid][HungerBar]);
    ShowPlayerProgressBar(playerid, Player[playerid][ThirstBar]);
    ShowPlayerProgressBar(playerid, Player[playerid][SleepBar]);
    ShowPlayerProgressBar(playerid, Player[playerid][ExpBar]);
	
	Loop(MAX_INV_ITEMS)	PlayerInv[playerid][i][Item] = -1;
	
	RemoveBuildingForPlayer(playerid, 18548, -1560.6719, -2728.3984, 47.7422, 0.25);
	RemoveBuildingForPlayer(playerid, 1522, -1562.5234, -2732.1406, 47.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 18282, -1560.6719, -2728.3984, 47.7422, 0.25);
	RemoveBuildingForPlayer(playerid, 17349, -542.0078, -522.8438, 29.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 17012, -542.0078, -522.8438, 29.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 13676, 78.4141, -1270.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 13870, 78.4141, -1270.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 17337, -967.9922, -341.2891, -27.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 17003, -967.9922, -341.2891, -27.2891, 0.25);
	
	mysql_format(g_SQL, m_string, sizeof(m_string), "SELECT Last_IP FROM user_data WHERE Name = '%e' LIMIT 1", Player[playerid][Name]);
	mysql_tquery(g_SQL, m_string, "OnPlayerAccountCheck", "d", playerid);
	
	FuelText = CreatePlayerTextDraw(playerid,450.0, 385.0,"_");//450.0, 405.0
	PlayerTextDrawAlignment(playerid,FuelText,0);
	PlayerTextDrawSetProportional(playerid,FuelText,1);
	PlayerTextDrawSetShadow(playerid,FuelText, 1);
	PlayerTextDrawSetOutline(playerid,FuelText, 2);
	PlayerTextDrawLetterSize(playerid,FuelText,0.60,2.0);
	PlayerTextDrawFont(playerid, FuelText, 3);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(Player[playerid][Logged])
	{
		GetPlayerPos(playerid,Player[playerid][SpawnPos][0],Player[playerid][SpawnPos][1],Player[playerid][SpawnPos][2]);

		mysql_format(g_SQL, b_string, sizeof(b_string), "UPDATE user_data SET Sleep = %0.2f, InvSize = %d, Hunger = %0.2f, Thirst = %0.2f, Exp = %0.2f, Score = %d WHERE Name = '%e'",Player[playerid][Sleep],Player[playerid][InvSize],Player[playerid][Hunger],Player[playerid][Thirst],  Player[playerid][Experience],  GetPlayerScore(playerid), Player[playerid][Name]);
		mysql_tquery(g_SQL, b_string);

		mysql_format(g_SQL, b_string, sizeof(b_string), "UPDATE user_data SET Level = %d, Pos_X = %0.2f, Pos_Y = %0.2f, Pos_Z = %0.2f, Last_IP = '%s' WHERE Name = '%e'",Player[playerid][Level], Player[playerid][SpawnPos][0], Player[playerid][SpawnPos][1], Player[playerid][SpawnPos][2], Player[playerid][IP], Player[playerid][Name]);
		mysql_tquery(g_SQL, b_string);

		mysql_format(g_SQL, b_string, sizeof(b_string), "UPDATE user_data SET zKills = %d, hKills = %d, dKills = %d, cItems = %d, cCraft = %d, cTrees = %d WHERE Name = '%e'",Player[playerid][Kills][1],Player[playerid][Kills][0],Player[playerid][Kills][2],Player[playerid][Count][0],Player[playerid][Count][1],Player[playerid][Count][2],Player[playerid][Name]);
		mysql_tquery(g_SQL, b_string);

        SavePlayerInventory(playerid);
	}

  	KillTimer(Player[playerid][Timer][0]);
  	KillTimer(Player[playerid][Timer][1]);
  	KillTimer(Player[playerid][Timer][2]);
  	KillTimer(Player[playerid][Timer][3]);

  	DestroyPlayerProgressBar(playerid, Player[playerid][HungerBar]);
  	DestroyPlayerProgressBar(playerid, Player[playerid][ThirstBar]);
  	DestroyPlayerProgressBar(playerid, Player[playerid][SleepBar]);
  	DestroyPlayerProgressBar(playerid, Player[playerid][ExpBar]);
  	
  	PlayerTextDrawDestroy(playerid,FuelText);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(Player[playerid][Died])
	{
		new Random = random(sizeof(RandomSpawns));
		SetPlayerPos(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2]);
	    SetPlayerFacingAngle(playerid, RandomSpawns[Random][3]);
	}
	else
	{
		SetPlayerPos(playerid,Player[playerid][SpawnPos][0],Player[playerid][SpawnPos][1],Player[playerid][SpawnPos][2]);
	}
    SetPlayerSkin(playerid,Player[playerid][Skin]);
    PreloadAnimLib(playerid,"CRACK");
    PreloadAnimLib(playerid,"BOMBER");
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	DropAllItemsFromInventory(playerid);
	if(killerid != INVALID_PLAYER_ID && !IsPlayerNPC(killerid))
	{
		GivePlayerExperience(killerid,4);
		Player[killerid][Kills][0]++;
	}
	else if(IsPlayerNPC(killerid))
	{
		format(m_string,sizeof(m_string),"[KILL] A zombie has killed %s (%d) !",Player[playerid][Name],playerid),
		SendClientMessageToAll(COLOR_RED, m_string);
	}
	Player[playerid][Died] = true;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	format(m_string,sizeof(m_string),"Use /engine or /lights to toggle [Vehicle ID: %d, Fuel: %0.2f, Engine: %s]",Vehicles[vehicleid-1][Veh],Vehicles[vehicleid-1][Fuel],(Vehicles[vehicleid-1][Engine]) ? ("Yes") : ("No"));
	SendClientMessage(playerid,COLOR_GREY,m_string);
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
        Player[playerid][Timer][3] = SetTimerEx("UpdateFuel",1000,true,"i",playerid);
        PlayerTextDrawShow(playerid,FuelText);
	}
	else if(oldstate == PLAYER_STATE_DRIVER)
	{
		KillTimer(Player[playerid][Timer][3]);
		PlayerTextDrawHide(playerid,FuelText);
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	SpawnPlayer(playerid);
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_FIRE))
	{
	    if(IsPlayerInPointMine(playerid))
	    {
	    	if(GetPlayerWeapon(playerid) != WEAPON_SHOVEL) return SendClientMessage(playerid,COLOR_RED,"You need shovel");
			new Float:mb = GetPlayerProgressBarValue(playerid,Player[playerid][MiningBar]);
			
	 		if(mb >= GetPlayerProgressBarMaxValue(playerid,Player[playerid][MiningBar]))
	 		{
			 	new Float:x,Float:y,Float:z;
			 	GetPlayerPos(playerid,x,y,z);
			 	SetPlayerProgressBarValue(playerid,Player[playerid][MiningBar],0);
			 	HidePlayerProgressBar(playerid,Player[playerid][MiningBar]);
			 	switch(random(2))
			 	{
				 	case 0:CreateItem(ModelIron,1,x,y,z,0,0,0);
				 	case 1:CreateItem(ModelCU,1,x,y,z,0,0,0);
			 	}
	 		}
	 		else
			{
				SetPlayerProgressBarValue(playerid,Player[playerid][MiningBar],mb+frandom(5.0,2.0));
				ShowPlayerProgressBar(playerid,Player[playerid][MiningBar]);
			}
		}
		else HidePlayerProgressBar(playerid,Player[playerid][MiningBar]);
		
		
		Loop(MAX_DEERS)
		{
            new Float:pos[3];
			GetObjectPos(Deers[i],pos[0],pos[1],pos[2]);
			if(IsPlayerInRangeOfPoint(playerid,2,pos[0],pos[1],pos[2]))
			{
				if(GetPlayerWeapon(playerid) != WEAPON_KNIFE) return SendClientMessage(playerid,COLOR_RED,"You need knife or chainsaw to pickup meat");
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4, false, 1, 1, 0, 4000, 1);
				GameTextForPlayer(playerid,"Picking up the meat...",3000,6);
				MapAndreas_FindZ_For2DCoord(pos[0],pos[1],pos[2]);
				CreateItem(ModelMeatUC,1,pos[0],pos[1],pos[2],0,0,0);
				CreateItem(ModelDeerSkin,1,pos[0]+1,pos[1],pos[2],0,0,0);
				Player[playerid][Kills][2]++;
				SetTimerEx("RespawnDeer",100,0,"i",i);
				break;
			}
		}
		
		Loop(MAX_TREES)
		{
			if(Trees[i][TreeObject] == INVALID_OBJECT_ID) continue;
			if(IsPlayerInRangeOfPoint(playerid, 2.5, Trees[i][SpawnPos][0], Trees[i][SpawnPos][1], Trees[i][SpawnPos][2]))
	        {
	        	if(GetPlayerWeapon(playerid) != WEAPON_CHAINSAW) return SendClientMessage(playerid,COLOR_RED,"You need chain saw to cut tree");
	            if(Trees[i][Health] <= 0) return SendClientMessage(playerid, COLOR_RED, "This tree has already been cut down!");
	            new Float:pos[3];
	            GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	            Trees[i][Health] = Trees[i][Health] - frandom(5.0,1.0);
	            UpdateTree(i);
	            
				if(Trees[i][Health] <= 0)
				{
					Trees[i][Health] = 0.0;
					DestroyObject(Trees[i][TreeObject]);
					Delete3DTextLabel(Trees[i][TreeText]);
					Trees[i][TreeObject] = CreateObject(832, Trees[i][SpawnPos][0], Trees[i][SpawnPos][1], Trees[i][SpawnPos][2], 0.0, 0.0, 0.0);

					GivePlayerExperience(playerid,1);
					Player[playerid][Count][2]++;
					CreateItem(ModelWood,2,pos[0]+2,pos[1]+2,pos[2],0,0,0);
					printf("Tree %d has been replaced with a stump.", i);
				}
                break;
			}
		}
	}
	
    if(PRESSED(KEY_CROUCH))
    {
        if(IsInventoryFull(playerid)) return SendClientMessage(playerid, COLOR_RED, "Your backpack is currently full.");
   		Loop(sizeof(Items))
		{
			if(Items[i][ItemObject] == INVALID_OBJECT_ID) continue;
			if(IsPlayerInRangeOfPoint(playerid,3.0,Items[i][ItemPos][0],Items[i][ItemPos][1],Items[i][ItemPos][2]))
			{
				AddItemToInventory(playerid,Items[i][ItemModel],Items[i][ItemAmount]);
			    DestroyObject(Items[i][ItemObject]);
			    Delete3DTextLabel(Items[i][ItemText]);
				Items[i][ItemObject] = INVALID_OBJECT_ID;
				Player[playerid][Count][0]++;
				break;
			}
		}
	}
	
	if(PRESSED(KEY_YES)) cmd_inventory(playerid,"1");
	if(PRESSED(KEY_NO)) cmd_inventory(playerid,"0");
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_INVENTORY:
		{
			if(response)
			{
			    if(PlayerInv[playerid][listitem][Item] == -1) return 0;
			    if(PlayerInv[playerid][listitem][Amount] > 1)
			    {
			    	Player[playerid][tmpSlot] = listitem;
			    	ShowPlayerDialog(playerid, DIALOG_INVENTORY3, DIALOG_STYLE_INPUT, "Drop items", "This item is stacked. How many items do you wanna drop?", "Drop", "Cancel");
			    }
			    else
			    	DropItemFromInventory(playerid,listitem);
			}
		}

		case DIALOG_INVENTORY2:
		{
			if(response)
			{
			    if(PlayerInv[playerid][listitem][Item] == -1) return 0;
			    
		 		switch(PlayerInv[playerid][listitem][Item])
			    {
					case ModelBandage:
					{
						new Float:health;
						GetPlayerHealth(playerid,health);
						SetPlayerHealth(playerid,health+frandom(25,20));
					}
					case ModelMedkit: SetPlayerHealth(playerid,100);
					case ModelBag10: Player[playerid][InvSize] = 10;
					case ModelBag20: Player[playerid][InvSize] = 20;
					case ModelBag30: Player[playerid][InvSize] = 30;
					case ModelBag40: Player[playerid][InvSize] = 40;
					case ModelBag50: Player[playerid][InvSize] = 50;
					
					case ModelEGascan:
					{
						if(IsPlayerInPointGas(playerid)) AddItemToInventory(playerid,ModelGascan);
						else return SendClientMessage(playerid,COLOR_RED,"To refill this empty gascan you need to be near a gasstation.");
					}
					
					case ModelGascan:
					{
						new bool:found = false;
						Loop(MAX_VEHICLES)
						{
       						if(Vehicles[i][Veh] == INVALID_VEHICLE_ID) continue;
							if(IsPlayerInRangeOfPoint(playerid,5.0,Vehicles[i][SpawnPos][0],Vehicles[i][SpawnPos][1],Vehicles[i][SpawnPos][2]))
							{
							    Vehicles[i][Fuel] += frandom(45.0,30.0);
								SendClientMessage(playerid,COLOR_GREEN,"Fuel has been added to this vehicle !");
								AddItemToInventory(playerid,ModelEGascan);
								found = true;
							}
						}
						if(!found) return SendClientMessage(playerid,COLOR_RED,"You need to be near a vehicle for that.");
					}
					case Model9mm: 		GivePlayerWeapon(playerid,WEAPON_COLT45,20);
					case ModelSilenced: GivePlayerWeapon(playerid,WEAPON_SILENCED,20);
					case ModelDeagle: 	GivePlayerWeapon(playerid,WEAPON_DEAGLE,15);
					case ModelShotgun: 	GivePlayerWeapon(playerid,WEAPON_SHOTGUN,25);
					case ModelSawnoff: 	GivePlayerWeapon(playerid,WEAPON_SAWEDOFF,30);
					case ModelMp5: 		GivePlayerWeapon(playerid,WEAPON_MP5,15);
					case ModelChainsaw: 
					{
						if(HasPlayerWeapon(playerid,WEAPON_KNIFE)) AddItemToInventory(playerid, ModelKnife);
						GivePlayerWeapon(playerid,WEAPON_CHAINSAW,1);
						
					}
					case ModelKnife: 	
					{
						if(HasPlayerWeapon(playerid,WEAPON_CHAINSAW)) AddItemToInventory(playerid,ModelChainsaw);
						GivePlayerWeapon(playerid,WEAPON_KNIFE,1);
					}
					case ModelPizza: 	GivePlayerHunger(playerid,50);
					case ModelBurger: 	GivePlayerHunger(playerid,30);
					case ModelSoda: 	SetPlayerThirst(playerid,frandom(50,30));
					case ModelWater: { 	SetPlayerThirst(playerid,frandom(80,50)); AddItemToInventory(playerid,ModelEWater); }
					case ModelEWater:
					{
						if(IsPlayerInPointWater(playerid))	AddItemToInventory(playerid,ModelWater);
						else return SendClientMessage(playerid,COLOR_RED,"You're not near water.");
					}
					case ModelBed: { DropItemFromInventory(playerid,GetItemInInventory(playerid,ModelBed)); return 1; }
					case ModelToolbox:
					{
						new bool:found = false;
						Loop(MAX_VEHICLES)
						{
							if(Vehicles[i][Veh] == INVALID_VEHICLE_ID) continue;
							if(IsPlayerInVehicle(playerid,Vehicles[i][Veh]))
							{
								if(Vehicles[i][Engine])
									return SendClientMessage(playerid,COLOR_RED,"This vehicle's engine doesn't need to be fixed");

								Vehicles[i][Engine] = true;
								SendClientMessage(playerid,COLOR_RED,"You have fixed the engine.");
								found = true;
							}
						}
						if(!found) return SendClientMessage(playerid,COLOR_RED,"You need to be in a vehicle to use this item.");
					}
					case ModelBox:
					{
						new Float:pos[3];
						GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
						CreateBox(pos[0]+frandom(2.0), pos[1]+frandom(2.0), pos[2]);
					}
					case ModelCampfire:
					{
						new Float:pos[3];
						GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
						CreateCampfire(pos[0], pos[1], pos[2]);
					}
					case ModelFishUC, ModelMeatUC:
					{
						new bool:found = false;
						Loop(MAX_BOXES)
						{
							if(IsPlayerInRangeOfPoint(playerid, 3.0, CampFire[i][SpawnPos][0], CampFire[i][SpawnPos][1], CampFire[i][SpawnPos][2]))
							{
								if(CampFire[i][Occupied]) return SendClientMessage(playerid, COLOR_RED, "There is already something cooking.");
								SendClientMessage(playerid, COLOR_RED, "Please wait some seconds untill the meat is cooked.");
								CampFire[i][Occupied] = true;
								SetTimerEx("Cook", 60*1000, false, "iii", i, playerid, PlayerInv[playerid][listitem][Item]);
								found = true;
								break;
							}
						}

						if(!found) return SendClientMessage(playerid, COLOR_RED, "You need to be near a campfire to cook.");
					}
					case ModelDeerSkin, ModelCU, ModelIron, ModelWood: return SendClientMessage(playerid,COLOR_RED,"This item is used to craft");
					case ModelFishRob: 	return SendClientMessage(playerid,COLOR_RED, "This item is used for /fish - You only can drop it");
					case ModelGpsMap: 	return SendClientMessage(playerid,COLOR_RED, "This item is used for /gps - You only can drop it.");
					default: return SendClientMessage(playerid, COLOR_RED, "This item is useless");
				}
				
				format(m_string,sizeof(m_string),"You have used a %s (%d)",PlayerInv[playerid][listitem][Name],PlayerInv[playerid][listitem][Item]);
				SendClientMessage(playerid,COLOR_RED,m_string);
				
				if(PlayerInv[playerid][listitem][Amount] > 1) PlayerInv[playerid][listitem][Amount]--;
				else MoveItemsInInventory(playerid,listitem);
			}
		}

		case DIALOG_INVENTORY3:
		{
			if(!response) 
			{
				Player[playerid][tmpSlot] = 0;
				return 0;
			}
			if(!IsNumeric(inputtext)) return SendClientMessage(playerid, COLOR_RED, "Please enter a number");
			DropItemFromInventory(playerid, Player[playerid][tmpSlot], strval(inputtext));
		}
		
		case DIALOG_LOGIN:
		{
		    if(response)
		    {
                mysql_format(g_SQL, m_string, sizeof(m_string), "SELECT * FROM user_data WHERE Name = '%e' AND Password = SHA1('%s')", Player[playerid][Name],inputtext);
				mysql_tquery(g_SQL, m_string, "OnPlayerLogin", "d", playerid);
			}
		}
		
		case DIALOG_REGISTER:
		{
            if(response)
            {
				mysql_format(g_SQL, m_string, sizeof(m_string), "INSERT INTO user_data (Name, Password, IP, Last_IP) VALUES ('%e', SHA1('%s'), '%s', '%s')", Player[playerid][Name], inputtext, Player[playerid][IP], Player[playerid][IP]);
				mysql_tquery(g_SQL, m_string, "OnPlayerRegister", "d", playerid);
			}
		}

		case DIALOG_CRAFT:
		{
			if(response)
			{
				new Float:pos[3];
				GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
				switch(listitem)
				{
					case 0: //chainsaw
					{
						if(!IsItemInInventory(playerid,ModelRope,1) || !IsItemInInventory(playerid,ModelIron,3)) return SendClientMessage(playerid,COLOR_RED,"You can't craft this item.");
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelRope));
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelIron),3);
						CreateItem(ModelChainsaw,1,pos[0],pos[1]+1,pos[2],0,0,0);
					}

					case 1: //knife
					{
						if(!IsItemInInventory(playerid,ModelWood) || !IsItemInInventory(playerid,ModelIron)) return SendClientMessage(playerid,COLOR_RED,"You can't craft this item.");
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelIron));
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelWood));
						CreateItem(ModelKnife,1,pos[0],pos[1]+1,pos[2],0,0,0);
					}
					
					case 2: // Bed
					{
						if(!IsItemInInventory(playerid,ModelWood,4) || !IsItemInInventory(playerid,ModelDeerSkin,2)) return SendClientMessage(playerid,COLOR_RED,"You can't craft this item.");
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelWood),2);
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelDeerSkin));
						CreateItem(ModelBed,1,pos[0],pos[1]+1,pos[2]+0.5,0,0,0);
					}
					
					case 3: //toolbox
					{
						//3 Copper and 2 Iron and 1 wood
						if(!IsItemInInventory(playerid,ModelIron,2) || !IsItemInInventory(playerid,ModelCU,3) || !IsItemInInventory(playerid,ModelWood)) return SendClientMessage(playerid,COLOR_RED,"You can't craft this item.");
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelIron),2);
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelCU),3);
						RemoveItemFromInventory(playerid,GetItemInInventory(playerid,ModelWood));
						CreateItem(ModelToolbox,1,pos[0],pos[1],pos[2],0,0,0);
					}

					case 4: //fishrob
					{
						if(!IsItemInInventory(playerid,ModelWood) || !IsItemInInventory(playerid, ModelIron) || !IsItemInInventory(playerid,ModelRope)) return SendClientMessage(playerid, COLOR_RED, "You can't craft this item.");
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelWood));
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelIron));
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelRope));
						CreateItem(ModelFishRob, 1,pos[0],pos[1],pos[2],0,0,0);
					}

					case 5: //box
					{
						if(!IsItemInInventory(playerid,ModelWood,10)) return SendClientMessage(playerid, COLOR_RED, "You can't craft this item.");
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelWood), 10);
						CreateItem(ModelBox, 1, pos[0],pos[1],pos[2],0,0,0);
					}

					case 6: //shovel
					{
						if(!IsItemInInventory(playerid,ModelCU,2) || !IsItemInInventory(playerid,ModelWood,2)) return SendClientMessage(playerid, COLOR_RED, "You can't craft this item.");
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelCU),2);
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelWood),2);
						CreateItem(ModelShovel,1, pos[0],pos[1],pos[2],0,0,0);
					}

					case 7: //campfire
					{
						if(!IsItemInInventory(playerid,ModelWood,6) || !IsItemInInventory(playerid,ModelRope) || !IsItemInInventory(playerid,ModelIron,2)) return SendClientMessage(playerid, COLOR_RED, "You can't craft this item.");
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelWood),6);
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelRope));
						RemoveItemFromInventory(playerid, GetItemInInventory(playerid,ModelIron),2);
						CreateItem(ModelCampfire, 1, pos[0],pos[1],pos[2]-1,0,0,0);
					}
				}
				ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.1, false, 1, 1, 0, 4000, 1);
				GivePlayerExperience(playerid,1);
				Player[playerid][Count][1]++;
			}
		}

		case DIALOG_GPS:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: SetPlayerCheckpoint(playerid,-1310.1714,-2407.3848,32.0838,3);
					case 1: SetPlayerCheckpoint(playerid,-1040.0635,-2286.8508,59.0006,3);
					case 2: SetPlayerCheckpoint(playerid,-1219.8186,-2363.8599,1.0119,3);
					case 3: SetPlayerCheckpoint(playerid,-1207.7113,-2602.2327,1.0976,3);
					case 4: SetPlayerCheckpoint(playerid,-1178.8430,-2632.9854,11.7578,3);
				}
				SendClientMessage(playerid, COLOR_GREEN, "A checkpoint has placed on your map.");
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{

	if(IsPlayerNPC(issuerid))
	{
		if(weaponid == 0) 
		{
			new Float:h;
			GetPlayerHealth(playerid, h);
			SetPlayerHealth(playerid, h-10);
		}
	}

	return 1;
}

public EndFishing(playerid)
{
	new Float:pos[3];
	TogglePlayerControllable(playerid, true);
	RemovePlayerAttachedObject(playerid,0);
	SendClientMessage(playerid, COLOR_GREEN, "You catched a fish !");
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	CreateItem(ModelFishUC,1,pos[0], pos[1], pos[2]-0.8, -0.17997, -74.46001, -12.54000);
}

// ================================= COMMANDS =================================
CMD:help(playerid, params[])
{
	new help[256*2];
	strcat(help, CHAT_SERVER"Welcome to The Land Of Death.\n\n"CHAT_PARAM"Server Commands:\n"CHAT_VALUE"All available commands are listed in /cmds\n\n");
	strcat(help, CHAT_PARAM"Progress bars:\n"CHAT_VALUE"There are currently (and always) 4 progressbars displayed on your screen.\n");
	strcat(help, "- "CHAT_LIGHTBLUE"Blue: "CHAT_VALUE"Thirst\n- "CHAT_WHITE"White: "CHAT_VALUE"Sleep\n- "CHAT_YELLOW"Yellow: "CHAT_VALUE"Hunger\n- "CHAT_ORANGE"Orange: Experience/level\n\n");
	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Server help", help, "OK", "");
	return 1;
}

CMD:viewbox(playerid,params[])
{
	new view[256*2],bool:found = false;
	Loop(MAX_BOXES)
	{
		if(IsPlayerInRangeOfPoint(playerid,2,Boxes[i][SpawnPos][0],Boxes[i][SpawnPos][1],Boxes[i][SpawnPos][2]))
		{
			for(new z = 0; z < 10; z++)
			{
				if(Boxes[i][b_Items][z] == -1) continue;
				format(s_string, sizeof(s_string), "[Slot: %d] %s (%d)\n", z, GetItemName(Boxes[i][b_Items][z]),Boxes[i][b_Items][z]);
				strcat(view, s_string);
				found = true;
			}
		}
	}
	if(!found) return SendClientMessage(playerid, COLOR_RED, "You're not near a box.");
	else return ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Box items:", view, "OK", "");
}

CMD:getboxitem(playerid,params[])
{
	new slot,bool:found = false;
	if(IsInventoryFull(playerid)) return SendClientMessage(playerid, COLOR_RED, "Your inventory is full.");
	if(sscanf(params, "d", slot)) return SendClientMessage(playerid, COLOR_RED, "Usage: /getboxitem [slot]");
	Loop(MAX_BOXES)
	{
		if(IsPlayerInRangeOfPoint(playerid,2,Boxes[i][SpawnPos][0],Boxes[i][SpawnPos][1],Boxes[i][SpawnPos][2]))
		{
			if(Boxes[i][b_Items][slot] == -1) return SendClientMessage(playerid, COLOR_RED, "This slot is empty");
			AddItemToInventory(playerid, Boxes[i][b_Items][slot]);
			format(m_string,sizeof(m_string),"You've picked item %s (%d) from the box.",GetItemName(Boxes[i][b_Items][slot]),Boxes[i][b_Items][slot]);
			SendClientMessage(playerid, COLOR_GREEN, m_string);
			Boxes[i][b_Items][slot] = -1;
			found = true;
			break;
		}
	}
	if(!found) return SendClientMessage(playerid, COLOR_RED, "You're not near a box");
	return 1;
}

CMD:addboxitem(playerid,params[])
{
	new slot, bool:found = false,string[128];
	if(sscanf(params, "d", slot)) return SendClientMessage(playerid, COLOR_RED, "Usage: /addboxitem [slot]");
	if(PlayerInv[playerid][slot][Item] == -1) return SendClientMessage(playerid, COLOR_RED, "Invalid slot");
	Loop(MAX_BOXES)
	{
		if(IsPlayerInRangeOfPoint(playerid,2,Boxes[i][SpawnPos][0],Boxes[i][SpawnPos][1],Boxes[i][SpawnPos][2]))
		{
			new free = GetFreeBoxSlot(i);
			if(free == -1) return SendClientMessage(playerid, COLOR_RED, "This box is full.");
			Boxes[i][b_Items][free] = PlayerInv[playerid][slot][Item];
			RemoveItemFromInventory(playerid, slot);
			format(string,sizeof(string),"You added the item %s (%d) in the box.",GetItemName(Boxes[i][b_Items][free]),Boxes[i][b_Items][free]);
			SendClientMessage(playerid, COLOR_GREEN, string);
			found = true;
			break;
		}
	}
	if(!found) SendClientMessage(playerid, COLOR_RED, "You're not near a box !");
	return 1;
}

CMD:fish(playerid,params[])
{
	if(!IsPlayerInPointFish(playerid)) return SendClientMessage(playerid, COLOR_RED, "You're not near a fish point");
	if(!IsItemInInventory(playerid,ModelFishRob)) return SendClientMessage(playerid, COLOR_RED, "You need (to craft) a fishing rob.");
	SetPlayerAttachedObject(playerid, 0, ModelFishRob, 6, 0.000000, 0.015999, 0.000000, -172.100006, 20.499998, 0.000000, 1.000000, 1.000000, 1.000000, 0, 0);
	SendClientMessage(playerid, COLOR_GREEN, "Please wait ...");
	TogglePlayerControllable(playerid,false);
	SetTimerEx("EndFishing",30*1000,false,"i",playerid);
	return 1;
}

CMD:cmds(playerid,params[])
{
	new cmds[256*2];
	strcat(cmds,CHAT_SERVER"Available commands:\n\n"CHAT_PARAM"General: "CHAT_VALUE"/help /gps /fish /stats /sleep\n\n");
	strcat(cmds,CHAT_PARAM"Crafing: "CHAT_VALUE"/craft\n\n"CHAT_PARAM"Vehicle: "CHAT_VALUE"/engine /lights\n\n");
	if(Player[playerid][Adminlevel] > 0) strcat(cmds, CHAT_PARAM"Admin: "CHAT_VALUE"All admin commands are listed in /acmds"); 
	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Server Commands", cmds, "OK","");
	return 1;
}

CMD:gps(playerid,params[])
{
	if(!IsItemInInventory(playerid,ModelGpsMap)) return SendClientMessage(playerid, COLOR_RED, "You don't have a GPS.");
	ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "GPS", "Mine 1\nMine 2\nFish point 1\nFish point 2\nFish point 3", "Go", "Cancel");
	return 1;
}

CMD:pos(playerid,params[])
{
	new Float:pos[3];
	if(sscanf(params,"fff",pos[0],pos[1],pos[2])) return 0;
	SetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	return 1;
}

CMD:stats(playerid,params[])
{
	new stats[256*2],id;
	if(sscanf(params,"d",id)) 
	{
		format(m_string, sizeof(m_string),CHAT_SERVER"Your stats: (%s - %d)\n\n", Player[playerid][Name], playerid);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Hunger: "CHAT_VALUE"%0.2f\n"CHAT_PARAM"Thirst: "CHAT_VALUE"%0.2f\n"CHAT_PARAM"Inventory: "CHAT_VALUE"%d slots used of %d\n",Player[playerid][Hunger],Player[playerid][Thirst],CountInventoryItems(playerid),Player[playerid][InvSize]);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Sleep: "CHAT_VALUE"%0.2f\n\n"CHAT_PARAM"Experience: "CHAT_VALUE"%0.2f/%0.2f\n"CHAT_PARAM"Level: "CHAT_VALUE"%0.2f\n\n",Player[playerid][Sleep],Player[playerid][Experience],GetPlayerProgressBarMaxValue(playerid,Player[playerid][ExpBar]),Player[playerid][Level]);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Zombie kills: "CHAT_VALUE"%d\n"CHAT_PARAM"Human kills: "CHAT_VALUE"%d\n"CHAT_PARAM"Deer kills: "CHAT_VALUE"%d\n\n",Player[playerid][Kills][1],Player[playerid][Kills][0],Player[playerid][Kills][2]);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Items picked up: "CHAT_VALUE"%d\n"CHAT_PARAM"Items crafted: "CHAT_VALUE"%d\n"CHAT_PARAM"Trees chopped: "CHAT_VALUE"%d",Player[playerid][Count][0],Player[playerid][Count][1],Player[playerid][Count][2]);
		strcat(stats,m_string);
	}
	else
	{
		if(!IsPlayerConnected(id)) return SendClientMessage(playerid, COLOR_RED, "This player isn't connected.");
		format(m_string, sizeof(m_string),CHAT_SERVER"Your stats: (%s - %d)\n\n", Player[id][Name], id);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Hunger: "CHAT_VALUE"%0.2f\n"CHAT_PARAM"Thirst: "CHAT_VALUE"%0.2f\n"CHAT_PARAM"Inventory: "CHAT_VALUE"%d slots used of %d\n",Player[id][Hunger],Player[id][Thirst],CountInventoryItems(id),Player[id][InvSize]);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Sleep: "CHAT_VALUE"%0.2f\n\n"CHAT_PARAM"Experience: "CHAT_VALUE"%0.2f/%0.2f\n"CHAT_PARAM"Level: "CHAT_VALUE"%0.2f\n\n",Player[id][Sleep],Player[id][Experience],GetPlayerProgressBarMaxValue(id,Player[id][ExpBar]),Player[id][Level]);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Zombie kills: "CHAT_VALUE"%d\n"CHAT_PARAM"Human kills: "CHAT_VALUE"%d\n"CHAT_PARAM"Deer kills: "CHAT_VALUE"%d\n\n",Player[id][Kills][1],Player[id][Kills][0],Player[id][Kills][2]);
		strcat(stats,m_string);
		format(m_string,sizeof(m_string),CHAT_PARAM"Items picked up: "CHAT_VALUE"%d\n"CHAT_PARAM"Items crafted: "CHAT_VALUE"%d\n"CHAT_PARAM"Trees chopped: "CHAT_VALUE"%d",Player[id][Count][0],Player[id][Count][1],Player[id][Count][2]);
		strcat(stats,m_string);
	}
	ShowPlayerDialog(playerid,DIALOG_UNUSED,DIALOG_STYLE_MSGBOX,"Statistics",stats,"OK","");
	return 1;
}

CMD:engine(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid,COLOR_RED,"You're not a driver");
    if(!Vehicles[GetPlayerVehicleID(playerid)-1][Engine]) return SendClientMessage(playerid,COLOR_RED,"Engine is broken, use a toolbox to fix");
    if(Vehicles[GetPlayerVehicleID(playerid)-1][Fuel] <= 0) return SendClientMessage(playerid,COLOR_RED,"No fuel available.");
    ToggleVehicleEngine(GetPlayerVehicleID(playerid));
	return 1;
}

CMD:lights(playerid, params[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid,COLOR_RED,"You're not a driver");
	new Vehicle = GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(Vehicle, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(Vehicle, engine, (lights == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
	return 1;
}

CMD:craft(playerid,params[])
{
	ShowPlayerDialog(playerid,DIALOG_CRAFT,DIALOG_STYLE_TABLIST_HEADERS,"Crafting","Item\tRequires\nChainsaw\t3x iron + 1x rope\nKnife\t1x wood + 1x iron\nBed\t2x Deer skins + 4x wood\nToolbox\t3x copper + 2x iron + 1x wood\nFishing Rod\t1x iron + 1x wood + 1x rope\nBox\t10x woods + 1x hammer\nShovel\t2x copper + 2x wood\nCampfire\t6x wood + 1x rope + 2x iron","Craft","Cancel");
	return 1;
}

CMD:inventory(playerid,params[])
{
	if(CountInventoryItems(playerid) == 0) return SendClientMessage(playerid,COLOR_RED,"Nuttin' in your fucking inventory.");
	new string[256*2];
	if(strlen(params) == 0) format(params,6,"%d",1);
	if(IsInventoryFull(playerid)) SendClientMessage(playerid, COLOR_RED, "Warning: Your backpack is currently full.");
	Loop(Player[playerid][InvSize])
	{
	    if(PlayerInv[playerid][i][Item] == -1) continue;
		format(s_string,sizeof(s_string),"Slot %d: %s (%d) - Amount: %d\n",i,PlayerInv[playerid][i][Name],PlayerInv[playerid][i][Item],PlayerInv[playerid][i][Amount]);
		strcat(string,s_string);
	}
	format(s_string,sizeof(s_string),"Inventory (%d/%d)",CountInventoryItems(playerid),Player[playerid][InvSize]);
	switch(strval(params))
	{
		case 0: ShowPlayerDialog(playerid,DIALOG_INVENTORY,DIALOG_STYLE_LIST,s_string,string,"Drop","Cancel");
		case 1: ShowPlayerDialog(playerid,DIALOG_INVENTORY2,DIALOG_STYLE_LIST,s_string,string,"Use","Cancel");
	}
	return 1;
}

CMD:sleep(playerid,params[])
{
	Loop(MAX_ITEMS)
	{
		if(Items[i][ItemObject] == INVALID_OBJECT_ID || Items[i][ItemModel] != ModelBed) continue;
        if(IsPlayerInRangeOfPoint(playerid, 5.0, Items[i][ItemPos][0], Items[i][ItemPos][1], Items[i][ItemPos][2]))
        {
            if(Player[playerid][Sleep] > 20) return SendClientMessage(playerid,COLOR_RED,"You can not sleep now");
            ClearAnimations(playerid);
        	ApplyAnimation(playerid,"CRACK","crckidle2",4.1,0,0,0,0,90000,true);
        	GameTextForPlayer(playerid, "~w~Sleeping....", 5000, 1);
        	SendClientMessage(playerid,COLOR_GREEN,"Sleeping takes 1 minute, 30 seconds.");
        	Player[playerid][Sleep] = 100;
			break;
		}
	}
	return 1;
}
// =============================== ADMIN COMMANDS ==============================
CMD:acmds(playerid,params[])
{
	if(Player[playerid][Adminlevel] == 0) return 0;
	new cmds[256*2];
	strcat(cmds, CHAT_SERVER"Available admin commands\n\n");
	strcat(cmds, CHAT_PARAM"Level 1:\n"CHAT_VALUE"/regrowtrees\n\n");
	strcat(cmds, CHAT_PARAM"Level 2:\n"CHAT_VALUE"No commands yet.\n\n");
	strcat(cmds, CHAT_PARAM"Level 3:\n"CHAT_VALUE"/giveitem\n\n");
	strcat(cmds, CHAT_PARAM"Level 4:\n"CHAT_VALUE"No commands yet\n\n");
	strcat(cmds, CHAT_PARAM"Level 5:\n"CHAT_VALUE"/gotodeer /createcar /createtree\n\n");

	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Admin commands", cmds, "OK","");
	return 1;
}

//Level 1
CMD:regrowtrees(playerid,params[])
{
    if(Player[playerid][Adminlevel] == 0) return 0;
    Loop(MAX_TREES)
    {
        if(Trees[i][TreeObject] == INVALID_OBJECT_ID || Trees[i][Health] != 0) continue;
    	RegrowTree(i);
  	}
	return 1;
}

//level 3
CMD:giveitem(playerid,params[])
{
    if(Player[playerid][Adminlevel] < 3) return 0;
    new model,id,amount;
    if(sscanf(params,"udD(1)",id,model,amount)) return SendClientMessage(playerid,COLOR_RED,"/giveitem [player] [modelid] [Optional: amount]");
    if(amount <= 0) return SendClientMessage(playerid, COLOR_RED, "Invalid amount");
	if(IsInventoryFull(playerid)) return SendClientMessage(playerid,COLOR_RED,"The inventory of this player is full !");
	AddItemToInventory(id,model,amount);
	return 1;
}

//level 5
CMD:gotodeer(playerid,params[])
{
	if(Player[playerid][Adminlevel] != 5) return 0;
	new id,Float:pos[3];
	if(sscanf(params,"d",id)) return SendClientMessage(playerid,COLOR_RED,"/gotodeer [deerid]");
	GetObjectPos(Deers[id],pos[0],pos[1],pos[2]);
	SetPlayerPos(playerid,pos[0],pos[1]+5,pos[2]);
	return 1;
}

CMD:createcar(playerid,params[])
{
	if(Player[playerid][Adminlevel] != 5) return 0;
	if(Server_Data[cVehicles] >= MAX_VEHICLES) return SendClientMessage(playerid,COLOR_RED,"Too much vehicles");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,COLOR_RED,"You're not in a vehicle !");
	new Float:pos[4], veh = GetPlayerVehicleID(playerid);
	GetVehiclePos(veh,pos[0],pos[1],pos[2]);
	GetVehicleZAngle(veh, pos[3]);
	
	Server_Data[cVehicles]++;
	CreateCar(GetVehicleModel(veh),pos[0],pos[1],pos[2],pos[3]);
    mysql_format(g_SQL,m_string,sizeof(m_string),"INSERT INTO vehicle_data (Model, Pos_X, Pos_Y, Pos_Z, Rot) VALUES (%d, %0.2f, %0.2f, %0.2f, %0.2f)",GetVehicleModel(veh),pos[0],pos[1],pos[2],pos[3]);
	mysql_tquery(g_SQL,m_string);
	return 1;
}

CMD:createtree(playerid,params[])
{
	if(Player[playerid][Adminlevel] != 5) return 0;
	if(Server_Data[cTrees] >= MAX_TREES) return SendClientMessage(playerid,COLOR_RED,"Too much trees");
	new type, Float:pos[3], randobj;
	if(sscanf(params,"i",type)) return SendClientMessage(playerid,COLOR_RED,"/createtree [type]");
	if(type != 0 && type != 1) return SendClientMessage(playerid,COLOR_RED,"/createtree [0 or 1]");
	
	switch(type)
	{
		case 0:
		{
			switch(random(5))
	        {
	            case 0: randobj = 661;
	            case 1: randobj = 657;
	            case 2: randobj = 654;
	            case 3: randobj = 655;
	            case 4: randobj = 656;
	        }
		}
		
		case 1:
		{
 			switch(random(5))
	        {
	            case 0: randobj = 615;
	            case 1: randobj = 616;
	            case 2: randobj = 617;
	            case 3: randobj = 618;
	            case 4: randobj = 700;
	        }
		}
	}
	Server_Data[cTrees]++;
	
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	CreateTree(randobj,pos[0],pos[1],pos[2]);
	SetPlayerPos(playerid,pos[0]+5,pos[1],pos[2]);

    mysql_format(g_SQL,m_string,sizeof(m_string),"INSERT INTO tree_data (ModelID, Pos_X, Pos_Y, Pos_Z) VALUES (%d, %0.2f, %0.2f, %0.2f)",randobj,pos[0],pos[1],pos[2]);
	mysql_tquery(g_SQL,m_string);
	return 1;
}


// =============================================================================
stock GetFreeBoxSlot(boxid)
{
	for(new i = 0; i < 10; i++)
	{
		if(Boxes[boxid][b_Items][i] != -1) continue;
		return i;	
	}
	return -1;
}

stock IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

stock HasPlayerWeapon(playerid, weaponid)
{
    new weapons[13][2];
    Loop(12)
	{
		GetPlayerWeaponData(playerid, i, weapons[i][0], weapons[i][1]);
		if(weapons[i][0] == weaponid) return true;
    }
    return false;
}

stock GivePlayerExperience(playerid,Float:exp)
{
	Player[playerid][Experience] += exp;
	format(s_string,sizeof(s_string),"[EXP] You gained %0.2f experience.",exp);
	SendClientMessage(playerid, COLOR_ORANGE, s_string);

	if(Player[playerid][Experience] >= GetPlayerProgressBarMaxValue(playerid,Player[playerid][ExpBar]))
	{
		Player[playerid][Experience] = 0;
		Player[playerid][Level]++;
		format(s_string,sizeof(s_string),"%s (%d) reached level %d !",Player[playerid][Name],playerid,Player[playerid][Level]);
		SendClientMessageToAll(COLOR_BROWN,s_string);
		SetPlayerProgressBarMaxValue(playerid, Player[playerid][ExpBar], 10 + (Player[playerid][Level] * 10));
	}
}

stock GetPlayerSpeed(playerid)
{
	new Float:ST[4];
	if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]); else GetPlayerVelocity(playerid,ST[0],ST[1],ST[2]);
	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 180;
	return floatround(ST[3]);
}

stock PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}
	
stock UpdateTree(treeid)
{
	format(s_string,sizeof(s_string),"Tree ID: %d\nHealth: %0.2f",treeid,Trees[treeid][Health]);
    Update3DTextLabelText(Trees[treeid][TreeText],0x008080FF,s_string);
}

stock IsPlayerInPointWater(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid,2,-1619.5463,-2696.4153,48.7427))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,2,-84.4512,-1182.4219,1.8539))  return 1;
	else if(IsPlayerInRangeOfPoint(playerid,2,24.3789,-2651.4944,40.4897))  return 1;
	return 0;
}

stock IsPlayerInPointGas(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid,5,-1609.7786,-2700.4292,48.5391))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,5,-84.7098,-1185.9546,1.7500))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,5,-565.2042,-1027.6069,24.0065))return 1;
	else if(IsPlayerInRangeOfPoint(playerid,5,25.7284,-2660.3860,40.5381))	return 1;
	return 0;
}

stock IsPlayerInPointMine(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid,10,-1310.1714,-2407.3848,32.0838))		return 1;
	else if(IsPlayerInRangeOfPoint(playerid,10,-1318.8688,-2423.9114,34.1446))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,10,-1336.1146,-2415.1379,44.8470))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,10,-1047.7969,-2321.9717,64.8014))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,10,-1040.0635,-2286.8508,59.0006))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,10,-1026.2584,-2277.8066,69.3670))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,10,-1002.6541,-2315.4692,70.3881))	return 1;
	return 0;
}

stock IsPlayerInPointFish(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid,2,-1219.8186,-2363.8599,1.0119))	return 1;
	else if(IsPlayerInRangeOfPoint(playerid,2,-1207.7113,-2602.2327,1.0976)) return 1;
	else if(IsPlayerInRangeOfPoint(playerid,2,-1178.8430,-2632.9854,11.7578)) return 1;
	return 0;
}

stock ToggleVehicleEngine(vehicleid)
{
    new engine,lights,alarm,doors,bonnet,boot,objective;
    GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
    SetVehicleParamsEx(vehicleid, (engine == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
}

stock LosSantosNodes(zoneid)
{
	if((zoneid >= 5 && zoneid <= 7) || (zoneid >= 12 && zoneid <= 15) || (zoneid >= 20 && zoneid <= 23)) return 1;
	return 0;
}

stock GetItemName(model)
{
	new name[32];
	switch(model)
	{
		case ModelDeerSkin: name = "Deerskin";
		case ModelWood: 	name = "Wood";
		case ModelGpsMap: 	name = "GPS";
		case ModelGascan: 	name = "Gascan";
		case ModelEGascan: 	name = "Empty Gascan";
		case ModelARifle: 	name = "Rifle";
		case ModelAAus: 	name = "Aus";
		case ModelASMS: 	name = "SMS";
		case ModelAShotgun: name = "Shotgun";
		case ModelAColt:	name = "Colt";
		case ModelCamera: 	name = "Camera";
		case ModelFire: 	name = "Fire";
		case ModelSpraycan: name = "Spraycan";
		case ModelSniper: 	name = "Sniper";
		case ModelTec9: 	name = "TEC 9";
		case ModelM4: 		name = "M4";
		case ModelAK47: 	name = "AK 47";
		case ModelMp5: 		name = "MP5";
		case ModelUzi: 		name = "UZI";
		case ModelCombat: 	name = "Combat Shutgun";
		case ModelSawnoff: 	name = "Sawnoff";
		case ModelShotgun: 	name = "Shotgun";
		case ModelDeagle: 	name = "Deagle";
		case ModelSilenced: name = "Silenced";
		case Model9mm: 		name = "9MM";
		case ModelMolotov: 	name = "Molotov";
		case ModelTearGas: 	name = "Tear Gas";
		case ModelGrenade: 	name = "Grenade";
		case ModelCane: 	name = "Cane";
		case ModelFlowers: 	name = "Flowers";
		case ModelSilver: 	name = "Silver";
		case ModelVibrator: name = "Vibrator";
		case ModelDildo: 	name = "Dildo";
		case ModelPurple: 	name = "Purple Dildo";
		case ModelChainsaw: name = "Chainsaw";
		case ModelKatana: 	name = "Katana";
		case ModelPool: 	name = "Pool";
		case ModelShovel: 	name = "Shovel";
		case ModelBaseball: name = "Baseball";
		case ModelKnife: 	name = "Knife";
		case ModelNight:	name = "Night Stick";
		case ModelGolf: 	name = "Golfclub";
		case ModelBandage: 	name = "Bandage";
		case ModelMedkit: 	name = "Medkit";
		case ModelPizza: 	name = "Pizza";
		case ModelBurger: 	name = "Burger";
		case ModelSoda: 	name = "Soda";
		case ModelWater: 	name = "Water";
		case ModelEWater: 	name = "Empty Water";
		case ModelHammer: 	name = "Hammer";
		case ModelGate1: 	name = "Gate (#1)";
		case ModelGate2: 	name = "Gate (#2)";
		case ModelWall: 	name = "Wall";
		case ModelWalldoor: name = "Walldoor";
		case ModelBag5: 	name = "Bag (5)";
		case ModelBag10: 	name = "Bag (10)";
		case ModelBag20: 	name = "Bag (20)";
		case ModelBag30: 	name = "Bag (30)";
		case ModelBag40: 	name = "Bag (40)";
		case ModelBag50: 	name = "Bag (50)";
		case ModelToolbox: 	name = "Toolbox";
		case ModelBox: 		name = "Box";
		case ModelBed:		name = "Bed";
		case ModelEngine: 	name = "Engine";
		case ModelMeatUC: 	name = "Meat (Uncooked)";
		case ModelMeatC:	name = "Meat (Cooked)";
		case ModelFishUC: 	name = "Fish (Uncooked)";
		case ModelFishC: 	name = "Fish (Cooked)";
		case ModelFishRob: 	name = "FishRob";
		case ModelIron: 	name = "Iron";
		case ModelCU: 		name = "Copper";
		case ModelRope:		name = "Rope";
		default: 			name = "Unknown";
	}
	return name;
}

stock CreateTree(model,Float:x,Float:y,Float:z)
{
	Loop(MAX_TREES)
	{
		if(Trees[i][TreeObject] != INVALID_OBJECT_ID) continue;
		
		Trees[i][TreeModel] = model;
		Trees[i][SpawnPos][0] = x;
		Trees[i][SpawnPos][1] = y;
		Trees[i][SpawnPos][2] = z;
		Trees[i][Health] = 100.0;
		format(s_string,sizeof(s_string),"Tree ID: %d\nHealth: %0.2f",i,Trees[i][Health]);
		Trees[i][TreeText] = Create3DTextLabel(s_string, 0x008080FF, x,y,z, 40.0, 0, 0);
		Trees[i][TreeObject] = CreateObject(model, x, y, z -1, 0.0, 0.0, 0.0);
		//printf("Tree %d created with model %d and pos %0.2f %0.2f %0.2f",i,model,x,y,z);
		break;
	}
	
}

stock CreateBox(Float:x ,Float:y, Float:z)
{
	Loop(MAX_BOXES)
	{
		if(Boxes[i][BoxObject] != INVALID_OBJECT_ID) continue;
		Boxes[i][BoxObject] = CreateObject(ModelBox, x+1, y, z-0.6, 0.0, 0.0, 0.0);
		Boxes[i][SpawnPos][0] = x;
		Boxes[i][SpawnPos][1] = y;
		Boxes[i][SpawnPos][2] = z;
		for(new index = 0; index < 10; index++) Boxes[i][b_Items][index] = -1;
		printf("Box %d created on pos %0.2f %0.2f %0.2f",i,x,y,z);
		break;
	}
}

stock CreateCar(model,Float:x,Float:y,Float:z,Float:rot)
{
	Loop(MAX_VEHICLES)
	{
		if(Vehicles[i][Veh] != INVALID_VEHICLE_ID) continue;
		
		Vehicles[i][VehModel] = model;
		Vehicles[i][Fuel] = frandom(50.0,30.0);
		Vehicles[i][Engine] = false;
		Vehicles[i][SpawnPos][0] = x;
		Vehicles[i][SpawnPos][1] = y;
		Vehicles[i][SpawnPos][2] = z;
		Vehicles[i][SpawnPos][3] = rot;
		Vehicles[i][Veh] = CreateVehicle(model,x,y,z,rot,random(255)+1,random(255)+1,-1);
		//printf("Vehicle %d/%d created with model %d and pos %0.2f %0.2f %0.2f %0.2f",i,Vehicles[i][Veh],model,x,y,z,rot);
		break;
	}
}

stock CreateCampfire(Float:x, Float:y, Float:z)
{
	Loop(MAX_BOXES)
	{
		if(CampFire[i][CampfObject][0] != INVALID_OBJECT_ID && CampFire[i][CampfObject][1] != INVALID_OBJECT_ID) continue;
		CampFire[i][SpawnPos][0] = x;
		CampFire[i][SpawnPos][1] = y;
		CampFire[i][SpawnPos][2] = z;
		CampFire[i][CampfObject][0] = CreateObject(841, x, y, z-1, 0.0, 0.0, 0.0);
		CampFire[i][CampfObject][1] = CreateObject(18688, x, y, z-2.25, 0.0, 0.0, 0.0);
		CampFire[i][Occupied] = false;
		break;
	}
}

stock GetRandomPosInArea(Float: minX, Float: minY, Float: maxX, Float: maxY, &Float: newX, &Float: newY, &Float: newZ)
{
	newX = frandom(maxX,minX);
	newY = frandom(maxY,minY);
	MapAndreas_FindZ_For2DCoord(newX, newY, newZ);
}

stock CreateRandomItemInArea(Float: minX, Float: minY, Float: maxX, Float: maxY)
{
	new Float: pos[3], randmodel;
	pos[0] = frandom(maxX,minX);
	pos[1] = frandom(maxY,minY);
	
	MapAndreas_FindZ_For2DCoord(pos[0], pos[1], pos[2]);

	switch(random(6))
	{
		case 0: randmodel = (random(2) == 0) ? ModelBandage : ModelMedkit;
		case 1,2: randmodel = Server_Data[iFood][random(sizeof(Server_Data[iFood]))];
		case 3: randmodel = Server_Data[iBuild][random(sizeof(Server_Data[iBuild]))];
		case 4: randmodel = Server_Data[iWeapons][random(sizeof(Server_Data[iWeapons]))];
		case 5: randmodel = Server_Data[iStuff][random(sizeof(Server_Data[iStuff]))];
	}
	
	CreateItem(randmodel, 1, pos[0], pos[1], pos[2], 0.0, 0.0, 0.0);
	
	//printf("[RANDITEM] Created item %d at %0.2f %0.2f %0.2f",randmodel,pos[0], pos[1], pos[2]);
}

stock CreateItem(model,amount,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
	if(model != INVALID_OBJECT_ID)
	{
		Loop(sizeof(Items))
		{
			if(Items[i][ItemObject] != INVALID_OBJECT_ID) continue;
			format(m_string,sizeof(m_string),"{FFFFFF}[{B2E66E}ITEM{FFFFFF}]\n%s (%d)\n[{B2E66E}{FFFFFF}ID: {B2E66E}%d{FFFFFF}]",GetItemName(model),amount,i);

			Items[i][ItemPos][0] = x;
			Items[i][ItemPos][1] = y;
			Items[i][ItemPos][2] = z;
			Items[i][ItemRot][0] = rx;
			Items[i][ItemRot][1] = ry;
			Items[i][ItemRot][2] = rz;
			Items[i][ItemAmount] = amount;
			Items[i][ItemModel] = model;
			Items[i][ItemObject] = CreateObject(Items[i][ItemModel],Items[i][ItemPos][0],Items[i][ItemPos][1],Items[i][ItemPos][2]+0.5,Items[i][ItemRot][0],Items[i][ItemRot][1],Items[i][ItemRot][2]);
			Items[i][ItemText] = Create3DTextLabel(m_string, 0x008080FF,Items[i][ItemPos][0],Items[i][ItemPos][1],Items[i][ItemPos][2]+1,10.0, 0);
			break;
		}
	}
}

stock ZombieInit()
{
	FCNPC_SetUpdateRate(100);
	for(new i = 0; i < MAX_ZOMBIES; i++)
	{
		new name[MAX_PLAYER_NAME], Float:pos[3];
  		format(name, MAX_PLAYER_NAME, "Zombie_%d", i + 1);
		new npcid = FCNPC_Create(name);
		GetRandomPosInArea(-2743.408447, -2880.190673, -263.408447, -728.190673, pos[0], pos[1], pos[2]);
		FCNPC_Spawn(npcid,162,  pos[0], pos[1], pos[2]);
		FCNPC_SetHealth(npcid, 100);
		printf("NPC %i spawned at %0.2f %0.2f %0.2f", npcid, pos[0], pos[1], pos[2]);
		SetTimerEx("FCNPC_Moving",500,true,"i",npcid);
		SetPlayerColor(npcid,COLOR_RED2);
	}
	return 1;
}

stock Float:frandom(Float:max, Float:min = 0.0, dp = 4)
{
    new
        Float:mul = floatpower(10.0, dp),
        imin = floatround(min * mul),
        imax = floatround(max * mul);
    return float(random(imax - imin) + imin) / mul;
}

stock ItemInit()
{
	Loop(MAX_ITEMS) Items[i][ItemObject] = INVALID_OBJECT_ID;
	Loop(MAX_TREES) Trees[i][TreeObject] = INVALID_OBJECT_ID;
	Loop(MAX_BOXES) Boxes[i][BoxObject] = INVALID_OBJECT_ID;
	Loop(MAX_DEERS)
	{
		new Random = random(sizeof(DeerSpawn));
		Deers[i] = CreateObject(19315,DeerSpawn[Random][0],DeerSpawn[Random][1],DeerSpawn[Random][2],0,0,0);
		//printf("Deer id %d created - object id: %d",i,Deers[i]);
		SetTimerEx("MoveDeer",3000,true,"i",i);
 	}

    Server_Data[iFood] 		= {ModelPizza,ModelBurger,ModelSoda,ModelWater,ModelEWater };
	Server_Data[iBuild] 	= {ModelHammer, ModelGate1, ModelGate2, ModelWall, ModelWalldoor};
	Server_Data[iWeapons] 	= {Model9mm, ModelSilenced, ModelDeagle, ModelShotgun, ModelSawnoff, ModelMp5};
	Server_Data[iStuff] 	= {ModelBag10, ModelBag20, ModelBag30, ModelBag40, ModelBag50, ModelGpsMap, ModelGascan, ModelEGascan};

	Loop(MAX_ITEMS-50) CreateRandomItemInArea(-2743.408447, -2880.190673, -263.408447, -728.190673);

}

stock FCNPC_Punch(npcid, Float:x, Float:y, Float:z, PunchResetDelay = 125)
{
	FCNPC_AimAt(npcid, x, y, z, 0);
    FCNPC_StopAim(npcid);
    FCNPC_SetKeys(npcid, 0x80 + 4);
    SetTimerEx("FCNPC_ResetKeys", PunchResetDelay, false, "i", npcid);
    return 1;
}

stock GetWeaponNameEx(weaponid)
{
	new wname[32];
	GetWeaponName(weaponid,wname,sizeof(wname));
	return wname;
}

stock IsInventoryFull(playerid)
{
	return CountInventoryItemsEx(playerid) == Player[playerid][InvSize];
}

stock CountInventoryItems(playerid)
{
	new tmp = 0;
	Loop(MAX_INV_ITEMS)
	{
		if(PlayerInv[playerid][i][Item] != -1) tmp++;
	}
	return tmp;
}

stock CountInventoryItemsEx(playerid)
{
	new tmp = 0;
	Loop(MAX_INV_ITEMS)
	{
		if(PlayerInv[playerid][i][Item] != -1) tmp += PlayerInv[playerid][i][Amount];
	}
	return tmp;
}


stock DropAllItemsFromInventory(playerid)
{
    new Float:pos[3];
    GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	Loop(MAX_INV_ITEMS)
	{
        if(PlayerInv[playerid][i][Item] == -1) continue;
        CreateItem(PlayerInv[playerid][i][Item],PlayerInv[playerid][i][Amount],pos[0]+frandom(5.0),pos[1]+frandom(5.0),pos[2],0.0, 0.0, 0.0);
		PlayerInv[playerid][i][Item] = -1;
		PlayerInv[playerid][i][Name] = EOS;
		PlayerInv[playerid][i][Amount] = 0;
	}
}

stock RemoveItemFromInventory(playerid,slot,amount = 1)
{
    if(PlayerInv[playerid][slot][Item] != -1)
    {
        if(PlayerInv[playerid][slot][Amount] > amount) PlayerInv[playerid][slot][Amount] -= amount;
        else
        {
            PlayerInv[playerid][slot][Item] = -1;
            PlayerInv[playerid][slot][Amount] = 0;
		}
	}
}

stock DropItemFromInventory(playerid,slot, amount = 1)
{
    if(PlayerInv[playerid][slot][Item] != -1 && PlayerInv[playerid][slot][Amount] >= amount)
    {
        ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, false, 0, 0, 0, 0);
   		printf("[DropItemFromInv] Item %s (%d) %ix removed from slot %d by %s (%d)", GetItemName(PlayerInv[playerid][slot][Item]),PlayerInv[playerid][slot][Item],amount,slot,Player[playerid][Name],playerid);
   		new Float:pos[3];
	    GetPlayerPos(playerid,pos[0],pos[1],pos[2]);

	    pos[0] += frandom(2.0,-2.0);
	    pos[1] += frandom(2.0,-2.0);

	    MapAndreas_FindZ_For2DCoord(pos[0],pos[1],pos[2]);
        CreateItem(PlayerInv[playerid][slot][Item],1,pos[0],pos[1],pos[2],0.0, 0.0, 0.0);
		format(m_string,sizeof(m_string),"You dropped %ix item %s (%d) from slot %d",amount,PlayerInv[playerid][slot][Name],PlayerInv[playerid][slot][Item],slot);
		SendClientMessage(playerid,COLOR_RED,m_string);
		if(PlayerInv[playerid][slot][Amount] > amount) PlayerInv[playerid][slot][Amount] -= amount;
		else MoveItemsInInventory(playerid,slot);
	}
}

stock MoveItemsInInventory(playerid,startslot)
{
	PlayerInv[playerid][startslot][Item] = -1;
	PlayerInv[playerid][startslot][Amount] = 0;
	LoopEx(startslot,MAX_INV_ITEMS-1)
	{
	    if(PlayerInv[playerid][i+1][Item] == -1) continue;
        PlayerInv[playerid][i][Item] = PlayerInv[playerid][i+1][Item];
        PlayerInv[playerid][i][Name] = GetItemName(PlayerInv[playerid][i+1][Item]);
        PlayerInv[playerid][i][Amount] = PlayerInv[playerid][i+1][Amount];
        PlayerInv[playerid][i+1][Item] = -1;
        PlayerInv[playerid][i+1][Amount] = 0;
	}
}

stock AddItemToInventory(playerid,modelid,amount = 1)
{
	if(IsItemInInventory(playerid,modelid))
	{
	    new slot = GetItemInInventory(playerid,modelid);
        PlayerInv[playerid][slot][Amount] += amount;
        SendClientMessage(playerid, COLOR_GREEN, "You stacked the item(s)");
        printf("[AddItemToInv] %d Item(s) (%s (%d)) added into slot %d from %s (%d)",amount, GetItemName(modelid),modelid,slot,Player[playerid][Name],playerid);
	}
	else
	{
		Loop(MAX_INV_ITEMS)
		{
		    if(PlayerInv[playerid][i][Item] != -1) continue;
			PlayerInv[playerid][i][Item] = modelid;
			PlayerInv[playerid][i][Name] = GetItemName(modelid);
			PlayerInv[playerid][i][Amount] = amount;
			SendClientMessage(playerid,COLOR_GREEN,"You picked up an item.");
			printf("[AddItemToInv] Item %s (%d) added into slot %d from %s (%d)", GetItemName(modelid),modelid,i,Player[playerid][Name],playerid);
			break;
		}
	}
}

stock IsItemInInventory(playerid,modelid,amount = 1)
{
	Loop(MAX_INV_ITEMS)
	{
        if(PlayerInv[playerid][i][Item] == -1) continue;
        if(PlayerInv[playerid][i][Item] == modelid && PlayerInv[playerid][i][Amount] >= amount) return true;
	}
	return false;
}

stock GetItemInInventory(playerid,modelid)
{
	Loop(MAX_INV_ITEMS)
	{
        if(PlayerInv[playerid][i][Item] == -1) continue;
        if(PlayerInv[playerid][i][Item] == modelid) return i;
	}
	return -1;
}

stock SetPlayerBackpack(playerid)
{
	switch(Player[playerid][InvSize])
	{
		case 5:	SetPlayerAttachedObject(playerid, 9, 363,1, -0.074000, -0.155000, 0.050000, 0.000000, 85.199981, 14.900001, 1.000000, 1.000000, 1.000000, 0, 0);
		case 10: SetPlayerAttachedObject(playerid, 9, 3026, 1, -0.122999, -0.059000, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000, 0, 0);
		case 20: SetPlayerAttachedObject(playerid, 9, 371, 1, 0.102999, -0.137999, 0.000000, 0.000000, 87.400016, 0.000000, 1.000000, 1.000000, 1.000000, 0, 0);
		case 30: SetPlayerAttachedObject(playerid, 9, 2663, 1, 0.059999, -0.102999, -0.016000, 0.000000, 88.199966, -179.500030, 1.000000, 1.166999, 1.084000, 0, 0);
		case 40: SetPlayerAttachedObject(playerid, 9, 2060, 1, 0.000000, -0.164000, 0.000000, 84.100006, 0.000000, 0.000000, 0.616999, 0.782999, 1.258000, 0, 0);
		case 50: SetPlayerAttachedObject(playerid, 9, 1310, 1, -0.091999, -0.201999, 0.000000, -3.599999, 88.500000, 0.000000, 0.936000, 1.000000, 1.000000, 0, 0);
	}
}

stock SavePlayerInventory(playerid)
{
	mysql_format(g_SQL, m_string,sizeof(m_string),"DELETE FROM inv_data WHERE Name = '%e'",Player[playerid][Name]);
	mysql_tquery(g_SQL, m_string);
	if(CountInventoryItems(playerid) != 0)
	{
		Loop(MAX_INV_ITEMS)
		{
		   	if(PlayerInv[playerid][i][Item] == -1 || PlayerInv[playerid][i][Item] == 0) continue;
			mysql_format(g_SQL, m_string,sizeof(m_string),"INSERT INTO inv_data (Name, ItemModel, ItemAmount) VALUES ('%e', %i, %i)",Player[playerid][Name],PlayerInv[playerid][i][Item],PlayerInv[playerid][i][Amount]);
			mysql_tquery(g_SQL, m_string);
		}
	}
	
	printf("[INV] Inventory saved for %s (%d)",Player[playerid][Name],playerid);
}
// ===================================== MYSQL =================================
public OnPlayerLogin(playerid)
{
    if(cache_num_rows() > 0)
    {
		SetPlayerScore(playerid,cache_get_field_content_int(0,"Score",g_SQL));
		Player[playerid][Adminlevel] = cache_get_field_content_int(0,"AdminLevel",g_SQL);
		Player[playerid][SpawnPos][0] = cache_get_field_content_float(0,"Pos_X",g_SQL);
		Player[playerid][SpawnPos][1] = cache_get_field_content_float(0,"Pos_Y",g_SQL);
		Player[playerid][SpawnPos][2] = cache_get_field_content_float(0,"Pos_Z",g_SQL);
		Player[playerid][Hunger] = cache_get_field_content_float(0,"Hunger",g_SQL);
		Player[playerid][Thirst] = cache_get_field_content_float(0,"Thirst",g_SQL);
		Player[playerid][InvSize] = cache_get_field_content_int(0,"InvSize",g_SQL);
        Player[playerid][Sleep] = cache_get_field_content_float(0,"Sleep",g_SQL);
        Player[playerid][Experience] = cache_get_field_content_float(0, "Exp", g_SQL);
        Player[playerid][Level] = cache_get_field_content_int(0, "Level", g_SQL);
        Player[playerid][Kills][0] = cache_get_field_content_int(0, "hKills", g_SQL);
        Player[playerid][Kills][1] = cache_get_field_content_int(0, "zKills", g_SQL);
        Player[playerid][Kills][2] = cache_get_field_content_int(0, "dKills", g_SQL);
        Player[playerid][Count][0] = cache_get_field_content_int(0, "cItems", g_SQL);
        Player[playerid][Count][1] = cache_get_field_content_int(0, "cCraft", g_SQL);
        Player[playerid][Count][2] = cache_get_field_content_int(0, "cTrees", g_SQL);
		
        SetPlayerProgressBarMaxValue(playerid, Player[playerid][ExpBar], 10 + (Player[playerid][Level] * 10));

		SendClientMessage(playerid,COLOR_GREEN,"You have been logged in !");
		
		Player[playerid][Logged] = true;
		SpawnPlayer(playerid);
		
		mysql_format(g_SQL, m_string, sizeof(m_string),"SELECT ItemModel, ItemAmount FROM inv_data WHERE Name = '%e'",Player[playerid][Name]);
		mysql_tquery(g_SQL, m_string, "OnPlayerInventoryLoad","d",playerid);
		
		printf("[LOGIN] %s (%d) has been logged in.",Player[playerid][Name],playerid);
	}
	else ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login","Wrong password. Please try again:","Login","");
}

public OnPlayerRegister(playerid)
{
	format(m_string,sizeof(m_string),"Your account has been registered ! Account ID: %d",cache_insert_id());
	SendClientMessage(playerid,COLOR_GREEN,m_string);
	
	SetPlayerProgressBarMaxValue(playerid, Player[playerid][ExpBar], 10.0);

	SpawnPlayer(playerid);
	
	printf("[REGISTER] %s (%d) has been registered.",Player[playerid][Name],playerid);
}

public OnPlayerAccountCheck(playerid)
{
    if(cache_num_rows() > 0)
    {

		new tmp[16];
		cache_get_field_content(0,"Last_IP",tmp,g_SQL);

		if(!strcmp(tmp,Player[playerid][IP]))
		{
			mysql_format(g_SQL, m_string, sizeof(m_string), "SELECT * FROM user_data WHERE Last_IP = '%s' LIMIT 1",tmp,Player[playerid][IP]);
			mysql_tquery(g_SQL, m_string, "OnPlayerLogin", "d", playerid);
		}
		else
		{
	        format(m_string, sizeof(m_string), CHAT_WHITE "This account "CHAT_YELLOW"(%s)"CHAT_WHITE" is registered.\nPlease login by entering your password in the field below:", Player[playerid][Name]);
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", m_string, "Login", "");
		}
	}
	else
	{
		format(m_string, sizeof(m_string), CHAT_WHITE"Welcome "CHAT_YELLOW"(%s)"CHAT_WHITE", you can register by entering your password in the field below:", Player[playerid][Name]);
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", m_string, "Register", "");

	}
}

public OnVehiclesLoaded()
{
	Loop(MAX_VEHICLES) Vehicles[i][Veh] = INVALID_VEHICLE_ID;

	new rows = cache_get_row_count();
	if(rows != 0)
	{
		Loop(rows)
		{
            CreateCar(cache_get_row_int(i,1,g_SQL),cache_get_row_float(i,2,g_SQL),cache_get_row_float(i,3,g_SQL),cache_get_row_float(i,4,g_SQL),cache_get_row_float(i,5,g_SQL));
		}
	}
	Server_Data[cVehicles] = rows;
	printf("[VEH] Loaded %d vehicles.",rows);
}

public OnTreesLoaded()
{
	new rows = cache_get_row_count();
	if(rows != 0)
	{
		Loop(rows)
		{
			CreateTree(cache_get_row_int(i,1,g_SQL),cache_get_row_float(i,3,g_SQL),cache_get_row_float(i,4,g_SQL),cache_get_row_float(i,5,g_SQL));
		}
	}
	Server_Data[cTrees] = rows;
	printf("[TREES] Loaded %d trees.",rows);
}


public RegrowTree(treeid)
{
	DestroyObject(Trees[treeid][TreeObject]);
	Delete3DTextLabel(Trees[treeid][TreeText]);
    Trees[treeid][TreeObject] = CreateObject(Trees[treeid][TreeModel], Trees[treeid][SpawnPos][0], Trees[treeid][SpawnPos][1], Trees[treeid][SpawnPos][2], 0.0, 0.0, 0.0);
	Trees[treeid][TreeText] = Create3DTextLabel("_", 0x008080FF, Trees[treeid][SpawnPos][0], Trees[treeid][SpawnPos][1], Trees[treeid][SpawnPos][2]-1, 40.0, 0, 0);
    Trees[treeid][Health] = 100;

   	UpdateTree(treeid);
    printf("[TREE] tID %d has regrown and set to 100.0 health.", treeid);
}

public OnPlayerInventoryLoad(playerid)
{
	new rows = cache_get_row_count();

	Loop(rows)
	{
		PlayerInv[playerid][i][Item] = cache_get_row_int(i,0,g_SQL);
		PlayerInv[playerid][i][Name] = GetItemName(PlayerInv[playerid][i][Item]);
		PlayerInv[playerid][i][Amount] = cache_get_row_int(i,1,g_SQL);
		//printf("Saved item in slot %d (%d - %d)",i,PlayerInv[playerid][i][Item],PlayerInv[playerid][i][Amount]);
	}

	printf("[INV] Loaded %d items for %s (%d)",rows,Player[playerid][Name],playerid);
}

public MoveDeer(deerid)
{
    new Float:pos[3];
	GetObjectPos(Deers[deerid],pos[0],pos[1],pos[2]);

	pos[0] += frandom(2.0, -2.0);
	pos[1] += frandom(2.0, -2.0);
	MapAndreas_FindZ_For2DCoord(pos[0],pos[1],pos[2]);
	MoveObject(Deers[deerid],pos[0],pos[1],pos[2],2);
}

public RespawnDeer(deerid)
{
	new Random = random(sizeof(DeerSpawn));
	DestroyObject(Deers[deerid]);
	Deers[deerid] = CreateObject(19315,DeerSpawn[Random][0],DeerSpawn[Random][1],DeerSpawn[Random][2],0,0,0);
}

public Cook(campfireid, playerid, item)
{
	CampFire[campfireid][Occupied] = false;
	SendClientMessage(playerid, COLOR_GREEN, "Your meat has been cooked.");
	switch(item)
	{
		case ModelMeatUC: CreateItem(ModelMeatC, 1, CampFire[campfireid][SpawnPos][0]+frandom(2.5), CampFire[campfireid][SpawnPos][1]+frandom(2.5),CampFire[campfireid][SpawnPos][2], 0.0, 0.0, 0.0);
		case ModelFishUC: CreateItem(ModelFishC, 1, CampFire[campfireid][SpawnPos][0]+frandom(2.5), CampFire[campfireid][SpawnPos][1]+frandom(2.5),CampFire[campfireid][SpawnPos][2], 0.0, 0.0, 0.0);
	}
}

// ===================================== FCNPC =================================
public FCNPC_Moving(npcid)
{
	new Float:p[3];
	pLoop()
	{
	    if(IsPlayerNPC(i)) continue;
		GetPlayerPos(i,p[0],p[1],p[2]);
		if(IsPlayerInRangeOfPoint(npcid,50,p[0],p[1],p[2]))
		{
		 	if(IsPlayerInRangeOfPoint(npcid,1,p[0],p[1],p[2]))
			{
				FCNPC_Punch(npcid,p[0],p[1],p[2],50);
			}
			else FCNPC_GoTo(npcid,p[0],p[1],p[2],MOVE_TYPE_RUN,10,1);
		}
	}
}

public FCNPC_OnTakeDamage(npcid, damagerid, weaponid, bodypart)
{
	return 1;
}

public FCNPC_OnDeath(npcid, killerid, weaponid)
{
	format(m_string,sizeof(m_string),"[KILL] %s (%d) has killed a zombie. (%s (%d) [%d])",Player[killerid][Name],killerid,GetWeaponNameEx(weaponid),weaponid,npcid);
	SendClientMessageToAll(COLOR_RED,m_string);
	GivePlayerScore(killerid,1);
	GivePlayerExperience(killerid,2);
	Player[killerid][Kills][1]++;
	if(random(100) < 35) 
	{
		new Float:pos[3];
		FCNPC_GetPosition(npcid, pos[0],pos[1],pos[2]);
		CreateItem(ModelRope, 1, pos[0],pos[1],pos[2], 0.0, 0.0, 0.0);
	}
	SetTimerEx("FCNPC_DoRespawn",6000,false,"i",npcid);
	return 1;
}

public FCNPC_OnRespawn(npcid)
{
    new Float:pos[3];
    GetRandomPosInArea(-2743.408447, -2880.190673, -263.408447, -728.190673, pos[0], pos[1], pos[2]);
    FCNPC_SetSkin(npcid,162);
    FCNPC_SetPosition(npcid,pos[0], pos[1], pos[2]);
	return 1;
}

public FCNPC_ResetKeys(npcid) { FCNPC_SetKeys(npcid, 0); }
public FCNPC_DoRespawn(npcid) { FCNPC_Respawn(npcid); }

public Update(playerid)
{
    SetPlayerBackpack(playerid);
    SetPlayerProgressBarValue(playerid, Player[playerid][SleepBar], Player[playerid][Sleep]);
    SetPlayerProgressBarValue(playerid, Player[playerid][ThirstBar], Player[playerid][Thirst]);
    SetPlayerProgressBarValue(playerid, Player[playerid][HungerBar], Player[playerid][Hunger]);
    SetPlayerProgressBarValue(playerid, Player[playerid][ExpBar], Player[playerid][Experience]);
}

public UpdateFuel(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
        new Float:fuel = floatdiv(GetPlayerSpeed(playerid),100.0), Float:health;
        if(fuel != 0) fuel -= frandom(fuel/2.0);

		if(Vehicles[GetPlayerVehicleID(playerid)-1][Fuel] <= 0.0)
		{
		    fuel = 0.0;
			SendClientMessage(playerid, COLOR_RED, "This vehicle has ran out of fuel");
			ToggleVehicleEngine(GetPlayerVehicleID(playerid));
			KillTimer(Player[playerid][Timer][3]);
		}
		else
			Vehicles[GetPlayerVehicleID(playerid)-1][Fuel] -= fuel;
			
		format(s_string,sizeof(s_string),"~w~Speed:~y~ %d~n~~w~Fuel: ~y~%0.2f",GetPlayerSpeed(playerid),Vehicles[GetPlayerVehicleID(playerid)-1][Fuel]);
		PlayerTextDrawSetString(playerid,FuelText,s_string);
		PlayerTextDrawShow(playerid,FuelText);

		GetVehicleHealth(GetPlayerVehicleID(playerid),health);
		if(health <= 300)
		{
		    if(health <= 250) SetVehicleHealth(GetPlayerVehicleID(playerid),275);
            Vehicles[GetPlayerVehicleID(playerid)-1][Engine] = false;
            SendClientMessage(playerid,COLOR_RED,"Engine broken !");
            ToggleVehicleEngine(GetPlayerVehicleID(playerid));
            RemovePlayerFromVehicle(playerid);
		}
	}
}

public UpdateSleep(playerid)
{
    Player[playerid][Sleep] -= frandom(1.5,1.0);
    if(Player[playerid][Sleep] <= 0)
    {
        ClearAnimations(playerid);
        ApplyAnimation(playerid,"CRACK","crckidle2",4.1,0,0,0,0,60000,true);
		SendClientMessage(playerid,COLOR_RED,"You collapsed due too less sleep !");
		Player[playerid][Sleep] = 25.0;
	}

}

public UpdateHT(playerid)
{
	if(Player[playerid][Hunger] <= 0 || Player[playerid][Thirst] <= 0)
	{
		SetPlayerHealth(playerid,0.0);
		SetPlayerHunger(playerid,100);
		SetPlayerThirst(playerid,100);
	}
	else
	{
		Player[playerid][Thirst] -= frandom(2.0,1.0);
		Player[playerid][Hunger] -= frandom(1.1,0.5);
	}
}
