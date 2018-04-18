script "bumcheekascend.ash";
notify bumcheekcity;
since r17203; // Version around when hippy junk junk quest detection was fixed

string bcasc_version = "0.56";
string bcasc_doWarAs = get_property("bcasc_doWarAs"), bcasc_100familiar = get_property("bcasc_100familiar"), bcasc_warOutfit;
boolean bcasc_bartender = get_property("bcasc_bartender").to_boolean(), bcasc_bedroom = get_property("bcasc_bedroom").to_boolean(), 
		bcasc_chef = get_property("bcasc_chef").to_boolean(), bcasc_cloverless = get_property("bcasc_cloverless").to_boolean(), 
		bcasc_doSideQuestArena = get_property("bcasc_doSideQuestArena").to_boolean(), bcasc_doSideQuestJunkyard = get_property("bcasc_doSideQuestJunkyard").to_boolean(),
		bcasc_doSideQuestBeach = get_property("bcasc_doSideQuestBeach").to_boolean(), bcasc_doSideQuestOrchard = get_property("bcasc_doSideQuestOrchard").to_boolean(), 
		bcasc_doSideQuestNuns = get_property("bcasc_doSideQuestNuns").to_boolean(), bcasc_doSideQuestDooks = get_property("bcasc_doSideQuestDooks").to_boolean(), 
		bcasc_fightNS = get_property("bcasc_fightNS").to_boolean(), bcasc_MineUnaccOnly = get_property("bcasc_MineUnaccOnly").to_boolean(), 
		bcasc_AllowML = get_property("bcasc_AllowML").to_boolean(), bcasc_ignoreSafeMoxInHardcore = get_property("bcasc_ignoreSafeMoxInHardcore").to_boolean(),
		bcasc_getLEW = get_property("bcasc_getLEW").to_boolean(), bcasc_RunSCasHC = get_property("bcasc_RunSCasHC").to_boolean(),
		bcasc_unlockHiddenTavern = get_property("bcasc_unlockHiddenTavern").to_boolean(), bcasc_castEmpathy = get_property("bcasc_castEmpathy").to_boolean(),
		bcasc_cellarWineBomb = get_property("bcasc_cellarWineBomb").to_boolean(), bcasc_getWand = get_property("bcasc_getWand").to_boolean(),
		bcasc_hippyJunk = get_property("bcasc_hippyJunk").to_boolean();
float bcasc_diceMultiplier = get_property("bcasc_diceMultiplier").to_float();

/***************************************
* DO NOT EDIT ANYTHING BELOW THIS LINE *
***************************************/

string [int] avatarTree;
if(my_path() == "Avatar of Boris") {
	avatarTree[0] = "Study";
	avatarTree[1] = "Study Fighting";
	avatarTree[2] = "Study Shouting";
	avatarTree[3] = "Study Feasting";
} else if (my_path() == "Avatar of Jarlsberg") {
	avatarTree[0] = "Study";
	avatarTree[1] = "The Path of Breakfast";
	avatarTree[2] = "The Path of Lunch";
	avatarTree[3] = "The Path of Dinner";
	avatarTree[4] = "The Path of Dessert";
}

string bcParseOptions(string inputString, string validOptions) {
	boolean [string] optionUsed;
	string outputString, char;
			
	inputString = to_lower_case(inputString);	
	inputString = replace_string(inputString," ","");

// alias human readable fight(ing) shout(ing) feast(ing) auto man(ual) lute crum(horn) to 1 2 3 321 0 L C
// passing this lot in to this function via options seems far too much like hard work, so leave
// as a hard coded list for now. (it does the right thing when abused for Clancy option parsing)
	inputString = replace_string(inputString,"fight","1");
	inputString = replace_string(inputString,"shout","2");
	inputString = replace_string(inputString,"feast","3");
	inputString = replace_string(inputString,"auto","321");
	inputString = replace_string(inputString,"man","0");
	inputString = replace_string(inputString,"lute","L");
	inputString = replace_string(inputString,"crum","C");
  	
// now filter out characters not in validOptions, and duplicates
	if (inputString != "") {
		for c from 0 to length(inputString) - 1 {
			char = char_at(inputString, c);
			if (contains_text(validOptions, char) && !optionUsed[char]) {
				optionUsed[char] = true;
				outputString += char;
			}
		}
	}

	return outputString;
}

string avatarOptions  = bcParseOptions(get_property("bcasc_borisSkills"),"0123");	
if (avatarOptions != "") avatarOptions += "0"; // if we run out of options, default to manual stop 

string clancyOptions = bcParseOptions(get_property("bcasc_trainClancy"),"01LC");	

if (bcasc_doWarAs == "frat") {
	bcasc_warOutfit = "frat warrior";
} else if (bcasc_doWarAs == "hippy") {
	bcasc_warOutfit = "war hippy";
} else if (bcasc_doWarAs == "abort") {
	bcasc_warOutfit = "abort";
} else {
	//abort("BCC: Please specify whether you would like to do the war as a frat or hippy by downloading the relay script at http://kolmafia.us/showthread.php?t=5470 and setting the settings for the script.");
	bcasc_doWarAs = "frat";
	bcasc_warOutfit = "frat warrior";
	bcasc_doSideQuestArena = true;
	bcasc_doSideQuestJunkyard = true;
	bcasc_doSideQuestBeach = true;
	print("BCC: IMPORTANT - You have not specified whether you would like to do the war as a frat or a hippy. As a result, the script is assuming you will be doing it as a frat, doing the Arena, Junkyard and Beach. Visit the following page to download a script to help you change these settings. http://kolmafia.us/showthread.php?t=5470");
	wait(5);
}

record lairItem {
	string gatename;
	string effectname;
	string a; //Item name 1
	string b;
	string c;
	string d;
	string e;
};
record alias {
	string cliref;
	string functionname;
};
lairItem [int] lairitems;
int max_bees = 0;
if (get_property("bcasc_maxBees").to_int() > 0) max_bees = get_property("bcasc_maxBees").to_int();

boolean load_current_map(string fname, lairItem[int] map) {
#	print("BCC: Trying to check " + fname + " on the Bumcheekcity servers.", "purple");
#	string domain = "http://kolmafia.co.uk/";
#	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);

	if (count(map) == 0) return false;
	
	//If the map is empty or the file doesn't need updating
#	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
#	{
#		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
#		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
#		{
#			return false;
#		}
		
#		map_to_file(map, fname+".txt");
#		set_property(fname+".txt", curr);
#		print("..."+fname+".txt updated.");
#	}
	
	return true;
}

boolean load_current_map(string fname, alias[int] map) {
#	print("BCC: Trying to check " + fname + " on the Bumcheekcity servers.", "purple");
#	string domain = "http://kolmafia.co.uk/";
#	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);
	
	if (count(map) == 0) return false;
	
	//If the map is empty or the file doesn't need updating
#	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
#	{
#		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
#		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
#		{
#			return false;
#		}
		
#		map_to_file(map, fname+".txt");
#		set_property(fname+".txt", curr);
#		print("..."+fname+".txt updated.");
#	}
	
	return true;
}

boolean load_current_map(string fname, string[int] map) {
#	print("BCC: Trying to check " + fname + " on the Bumcheekcity servers.", "purple");
#	string domain = "http://kolmafia.co.uk/";
#	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);
	
	if (count(map) == 0) return false;
	
	//If the map is empty or the file doesn't need updating
#	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
#	{
#		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
#		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
#		{
#			return false;
#		}
		
#		map_to_file(map, fname+".txt");
#		set_property(fname+".txt", curr);
#		print("..."+fname+".txt updated.");
#	}
	
	return true;
}

/******************
* BEGIN FUNCTIONS *
******************/

void ascendLog(string finished) {
	string [int] settingsMap;
	string settings = "{";
	string stages;
	string turns = my_turncount().to_string();
	string days = my_daycount().to_string();
	string ascnum = my_ascensions().to_string();
	string url = "http://bumcheekcity.com/kol/asclog.php?username="+my_name()+"&mafiaversion="+get_version()+"&mafiarevision="+get_revision();
		url += "&scriptversion="+bcasc_version+"&finished="+finished+"&scriptname="+__FILE__+"&days="+days+"&turns="+turns+"&ascnum="+ascnum;
	
	load_current_map("bcsrelay_settings", settingsMap);
	foreach x in settingsMap {
		settings += "\""+settingsMap[x]+"\":"+url_encode(get_property(settingsMap[x]))+",";
	}
	url += "&settings="+settings+"}";
	
	string api = visit_url("api.php?what=status&for=bumcheekascend v"+bcasc_version);
	
	api = replace_all(create_matcher("\"pwd\":\"[a-z0-9]+\",", api), "");
	
	url += "&api="+api;
	
    string response;
    try { response = visit_url(url); }
	finally { response = "a"; }
}

boolean have_path_familiar(familiar fam) {
	if(my_path() == "Trendy")
		return have_familiar(fam) && is_trendy(fam);
	else if(my_path() == "Bees Hate You")
		return have_familiar(fam) && !contains_text(to_lower_case(to_string(fam)), "b");
	else if(my_path() == "Avatar of Boris")
		return false;
	else if(my_path() == "Avatar of Sneaky Pete")
		return false;
	else
		return have_familiar(fam);
}

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + (get_property("autoSatisfyWithCloset") == "true" ? closet_amount(i) : 0) + equipped_amount(i);
	
	//Make a check for familiar equipment NOT equipped on the current familiar. 
	foreach fam in $familiars[] {
		if (have_path_familiar(fam) && fam != my_familiar()) {
			if (name == to_string(familiar_equipped_equipment(fam)) && name != "none") {
				a = a + 1;
			}
		}
	}
	
	//print("Checking for item "+name+", which it turns out I have "+a+" of.", "fuchsia");
	return a;
}

boolean hasShield() {
	foreach it, i in get_inventory() {
		if (item_type(it) == "shield" && can_equip(it))
			return true;
	}
	if (item_type(equipped_item($slot[off-hand])) == "shield")
		return true;
	return false;
}

boolean isExpectedMonster(string opp) {
	location loc = my_location();

	boolean haveOutfitEquipped(string outfit) {
		boolean anyEquipped = false;
		boolean allEquipped = true;
		foreach key, thing in outfit_pieces(outfit) {
			if (have_equipped(thing)) {
				anyEquipped = true;
			} else {
				allEquipped = false;
				break;
			}
		}

		return anyEquipped && allEquipped;
	}

	//Fix up location appropriately. :(
	if (loc == $location[wartime frat house]) {
		if (haveOutfitEquipped("hippy disguise") || haveOutfitEquipped("war hippy fatigues"))
			loc = $location[wartime frat house (hippy disguise)];
	} else if (loc == $location[wartime hippy camp]) {
		if (haveOutfitEquipped("frat boy ensemble") || haveOutfitEquipped("frat warrior fatigues"))
		loc = $location[wartime hippy camp (frat disguise)];
	}

	monster mon = opp.to_monster();
	boolean expected = appearance_rates(loc) contains mon;
	return expected;
}

//Checks to see if we need to hunt for a certain key in KOLHS
boolean need_key(location loc) {
	if (my_path() == "Actually Ed the Undying") return false;
	switch(loc) {
		case $location[8-bit Realm]:
			if(i_a("universal key") > 0 || i_a("digital key") > 0) return false;
			break;
		case $location[The Hole in the Sky]:
			if(i_a("richard's star key") > 0 || (i_a("richard's star key") == 0 && i_a("universal key") > 0 && i_a("digital key") > 0) || (i_a("richard's star key") == 0 && i_a("universal key") > 1 && i_a("digital key") == 0)) return false;
			break;
//		case $location[Daily Dungeon]:
	}
	return true;
}

//Returns the string which we'll use for the maximiser, or nothing if this would be inappropriate. 
string prepSNS() {
	void fold() {
		visit_url("bedazzle.php?action=fold&pwd=");
	}
	
	//If we don't have a sticker tome, abort.
	if (!can_interact() && !contains_text(visit_url("campground.php?action=bookshelf"), "Sticker")) {
		return "";
	} else {
		item i = $item[scratch 'n' sniff UPC sticker];
		foreach s in $slots[sticker1, sticker2, sticker3] {
			if (equipped_item(s) != i && item_amount(i) > 0) {
				equip(s, i);
			}
		}
	}

	if (my_primestat() == $stat[Moxie] && in_hardcore()) {
		if (i_a("scratch n sniff sword") > 0) fold();
		if (i_a("scratch n sniff crossbow") > 0) return "+equip scratch n sniff crossbow";
		return "";
	} else {
		if (i_a("scratch n sniff crossbow") > 0) fold();
		if (i_a("scratch n sniff sword") > 0) return "+equip scratch n sniff sword";
		return "";
	}
	return "";
}

string safe_visit_url(string url) {
    string response;
    try { response = visit_url( url ); }
    finally { return response; }
    return response;
}

//Thanks to Bale and slyz here!
effect [item] allBangPotions() {
	effect [item] potion;
	for id from 819 to 827 {
		switch( get_property("lastBangPotion"+id) ) {
			case "sleepiness": potion[id.to_item()] = $effect[ Sleepy ]; break;
			case "confusion": potion[id.to_item()] = $effect[ Confused ]; break;
			case "inebriety": potion[id.to_item()] = $effect[ Antihangover ]; break;
			case "ettin strength": potion[id.to_item()] = $effect[ Strength of Ten Ettins ]; break;
			case "blessing": potion[id.to_item()] = $effect[ Izchak's Blessing ]; break;
			case "healing": break;
			default: potion[id.to_item()] = get_property("lastBangPotion"+id).to_effect();
		}
	}
	return potion;
}

//Returns true if we have a shield and Hero of the Halfshell.
boolean anHero() {
	if (!have_skill($skill[Hero of the Half-Shell])) return false;
	if (my_path() == "Way of the Surprising Fist" || my_path() == "Zombie Slayer") return false;  
	if (!(my_primestat() == $stat[Muscle])) return false;
	if (get_property("bcasc_lastShieldCheck") == today_to_string()) return true;
	
	if(hasShield()) {
		cli_execute("set bcasc_lastShieldCheck = "+today_to_string());
		print("BCC: You appear to have a shield. If you autosell your last shield, this script is going to behave very strangely and you're an idiot.", "purple");
		return true;
	}
	
	print("BCC: You don't have a shield. It might be better to get one. ", "purple");
	return false;
}

void bcAutoAvatar(string avatar) {
	int i, avatarOption, avatarLength;
	string avatarResult;
	string gate = (my_path() == "Avatar of Boris" ? "gate1" : (my_path() == "Avatar of Jarlsberg" ? "gate2" : "gate3"));

	if (avatar == "Jarlsberg") {
		print("BCC: You have free Jarlsberg-points, but the script cannot yet do anything with them.", "purple");
	} else if (avatarOptions != "") {
		avatarLength = length(avatarOptions);
		for i from 0 to avatarlength - 1 {
			avatarOption = char_at(avatarOptions,i).to_int();
			avatarResult = visit_url("da.php?place=" + gate);
			while (contains_text(avatarResult, "hungering for knowledge") && contains_text(avatarResult, avatarTree[avatarOption])) {
				if (avatarOption == 0) abort("BCC: stopping so you can worship in the glory of " + avatar + "."); 
				print("BCC: "+avatarTree[avatarOption], "purple");
				avatarResult = visit_url("da.php?whichtree="+avatarOption+"&action=" + avatar + "skill");
			}
		}
	} else {
		print("BCC: Not worshipping in glory of " + avatar + ".","purple");
	}
}

void setMood(string combat); //Predeclare to make clancy work
string bumRunCombat();
boolean bumAdv(location loc);

void bcAutoClancy() {
// convert options to mode string, manual overrides auto, handle options being in any order
	string clancyMode = "";
	if (contains_text(clancyOptions,"0")) {
		clancyMode = "0";
	} else {
		if (contains_text(clancyOptions,"1")) {
			clancyMode = "1";
		}
	}
	 
	boolean luteOnly = contains_text(clancyOptions,"L");
	if (((minstrel_instrument() == $item[Clancy's lute]) || (i_a("Clancy's lute") > 0)) && luteOnly) clancyMode = "L";

	if (clancyMode == "")  print("BCC: Ignoring Clancy", "purple");
	if (clancyMode == "L") print("BCC: Ignoring Clancy as we have a Lute", "purple");
	 			
	if ((clancyMode == "0") || (clancyMode == "1")) {
		string charpane = visit_url("charpane.php");
		if (contains_text(charpane, "_att.gif")) {
			print("BCC: paying attention to Clancy.", "purple"); 
			string clancyHtml = visit_url("main.php?action=clancy");
			matcher clancyMatch = create_matcher("<b>Your Minstrel ([a-zA-Z]+)</b>", clancyHtml);
			if (clancyMatch.find()) {
				string minstrel = clancyMatch.group(1);

				if(clancyMode == "1") {
					setMood("-");
					cli_execute("condition add 1 autostop");
				}
				switch (minstrel) {
					case "Vamps":
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=571&option=1");
						if (clancyMode == "1")
							bumAdv($location[a barroom brawl]);
						else
							abort("BCC: Clancy would like you to take him to the Barroom brawl in the Tavern.");
						break;

					case "Clamps":
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=572&option=1");
						abort("BCC: Clancy would like you to take him to the Knob Shaft in Cobbs Knob." + (item_amount($item[Cobb's Knob lab key]) > 0 ? "" : " You need to get the lab key first."));
						break;
						//cobbsknob.php?action=tolabs	Encounter: A Miner Variation

					case "Stamps":
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=573&option=1");
						if (clancyMode == "1") {
							visit_url("plains.php?action=lutergrave");
							bumRunCombat();
						} else
							abort("BCC: Clancy would like you to take him to the Luter's Grave in the Nearby Plains.");
						break;

					case "Camps":
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=576&option=1");
						if (clancyMode == "1")
							bumAdv($location[The Icy Peak]);
						else
							abort("BCC: Clancy would like you to take him to the Icy Peaks.");
						break;

					case "Scamp":
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=577&option=1");
						if (clancyMode == "1")
							bumAdv($location[the middle chamber]);
						else
							abort("BCC: Clancy would like you to take him to the Middle Chamber in the Pyramid.");
						break;

					default: 
						abort("BCC: ERROR - bcAutoClancy() - Unexpected minstrel status: "+minstrel);
				}
			} else {
				abort("BCC: ERROR - bcAutoClancy() - Failed to find a match when paying attention to Clancy.");
			}
		} else {
			print ("BCC: Clancy not in need of attention.", "purple");
		}
	}
}

void bcCrumHorn() {
	if ((my_path() == "Avatar of Boris") && ((minstrel_instrument() != $item[clancy's crumhorn]) && (i_a("clancy's crumhorn") == 0)) && (contains_text(clancyOptions,"C"))) {
		if (my_meat() > 3000) {
			print("BCC: buying the Crumhorm from uncle P's", "purple");
			buy(1 , $item[clancy's crumhorn]);
		} else {
			print("BCC: not enough meat yet for a Crumhorn", "purple");
		}	
	}
}

void bcascBugbearHunt(); //Pre-declare so that the next function won't crash

void bcCouncil() {
	int lastVisit = get_property("bcasc_lastCouncilVisit").to_int();
	int thisVisit = 1000 * my_ascensions()+my_level();
	if (lastVisit < thisVisit || lastVisit / 1000 != my_ascensions() || lastVisit % 1000 <= my_level()) {
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());

		string visitString = thisVisit.to_string();
		set_property("bcasc_lastCouncilVisit", visitString);
		if (my_path() == "Avatar of Boris") {
			bcAutoAvatar(substring(my_path(), 10));
			bcAutoClancy();
		}
	}
	//We want to run this everytime so that it gets called when needed
	if (my_path() == "Bugbear Invasion") {
		if (i_a("BURT") >= 5 && i_a("key-o-tron") == 0)
			retrieve_item(1, $item[key-o-tron]);
		if (i_a("key-o-tron") > 0 && inebriety_limit() > 15)
			bcascBugbearHunt();
	}
}

//Thanks, Rinn!
string beerPong(string page) {
	record r {
		string insult;
		string retort;
	};

	r [int] insults;
	insults[1].insult="Arrr, the power of me serve'll flay the skin from yer bones!";
	insults[1].retort="Obviously neither your tongue nor your wit is sharp enough for the job.";
	insults[2].insult="Do ye hear that, ye craven blackguard?  It be the sound of yer doom!";
	insults[2].retort="It can't be any worse than the smell of your breath!";
	insults[3].insult="Suck on <i>this</i>, ye miserable, pestilent wretch!";
	insults[3].retort="That reminds me, tell your wife and sister I had a lovely time last night.";
	insults[4].insult="The streets will run red with yer blood when I'm through with ye!";
	insults[4].retort="I'd've thought yellow would be more your color.";
	insults[5].insult="Yer face is as foul as that of a drowned goat!";
	insults[5].retort="I'm not really comfortable being compared to your girlfriend that way.";
	insults[6].insult="When I'm through with ye, ye'll be crying like a little girl!";
	insults[6].retort="It's an honor to learn from such an expert in the field.";
	insults[7].insult="In all my years I've not seen a more loathsome worm than yerself!";
	insults[7].retort="Amazing!  How do you manage to shave without using a mirror?";
	insults[8].insult="Not a single man has faced me and lived to tell the tale!";
	insults[8].retort="It only seems that way because you haven't learned to count to one.";

	while (!page.contains_text("victory laps"))
	{
		string old_page = page;

		if (!page.contains_text("Insult Beer Pong")) abort("BCC: You don't seem to be playing Insult Beer Pong.");

		if (page.contains_text("Phooey")) {
			print("Looks like something went wrong and you lost.", "lime");
			return page;
		}
	
		foreach i in insults {
			if (page.contains_text(insults[i].insult)) {
				if (page.contains_text(insults[i].retort)) {
					print("Found appropriate retort for insult.", "lime");
					print("Insult: " + insults[i].insult, "lime");
					print("Retort: " + insults[i].retort, "lime");
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;			
				} else {
					print("Looks like you needed a retort you haven't learned.", "red");
					print("Insult: " + insults[i].insult, "lime");
					print("Retort: " + insults[i].retort, "lime");
	
					// Give a bad retort
					page = visit_url("beerpong.php?value=Retort!&response=9");
					return page;
				}
			}
		}

		if (page == old_page) abort("BCC: String not found. There may be an error with one of the insult or retort strings."); 
	}

	print("You won a thrilling game of Insult Beer Pong!", "lime");
	return page;
}

void betweenBattle() {
	cli_execute("mood execute; uneffect beaten up;");
	if (to_float(my_hp()) / my_maxhp() < to_float(get_property("hpAutoRecovery"))) restore_hp(0);
	if (my_path() != "Zombie Slayer" && to_float(my_mp()) / my_maxmp() < to_float(get_property("mpAutoRecovery"))) restore_mp(0);

	if (have_effect($effect[Beaten Up]) > 0) abort("BCC: Script could not remove Beaten Up.");
	if (my_adventures() == 0) abort("BCC: No adventures left :(");
	//if (get_counters("fortune cookie", 0, 0) == "Fortune Cookie" && get_property("counterScript") != "") cli_execute("call " + get_property("counterScript Fortune Cookie"));
}

void bprint(string message) {
	print("BCC: We have completed the stage " + message, "purple");
}

void tripleMaximize(string maximization, float neededTurns) {
	if (get_property("bcasc_dontTouchStuff") == "true") {
		print("BCC: Not changing outfit as bcasc_dontTouchStuff is true", "purple");
		return;
	}
	if (neededTurns < 0) neededTurns = my_adventures();
	maximize(maximization, false);
	foreach it,entry in maximize(maximization, 0, 0, true, false) if (entry.score > 0 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(neededTurns / turns_per_cast(entry.skill))), entry.skill);
	foreach it,entry in maximize(maximization, 0, 0, true, false) if (entry.score > 0 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
	return;
}


boolean buMax(string maxme, int maxMainstat) {
	if (get_property("bcasc_dontTouchStuff") == "true") {
		print("BCC: Not changing outfit as bcasc_dontTouchStuff is true", "purple");
		return true;
	}
	print("BCC: Maximizing '"+maxme+"'", "blue");
	
	if (my_path() == "Way of the Suprising Fist") maxme += " -weapon -offhand";
	if (my_path() == "Avatar of Boris" && !contains_text(maxme, "outfit")) {
		if (i_a("Boris's Helm") > 0) maxme += " +equip Boris's Helm";
		else if (i_a("Boris's Helm (askew)") > 0) maxme += " +equip Boris's Helm (askew)";
	}
	if(my_path() == "Avatar of Sneaky Pete" && !contains_text(maxme, "outfit")) {
		if (i_a("Sneaky Pete's leather jacket") > 0) maxme += " +equip Sneaky Pete's leather jacket";
		else if (i_a("Sneaky Pete's leather jacket (collar popped)") >0) maxme += " +equip Sneaky Pete's leather jacket (collar popped)";
	}

	if (!in_hardcore() && !bcasc_RunSCasHC) {
		if (cli_execute("outfit bumcheekascend")) {}
		if (contains_text(maxme, "+outfit") && contains_text(maxme, "+equip")) {
			string [int] strs = split_string(maxme, "\\+");
			foreach i in strs {
				if (strs[i] != "") {
					//print(strs[i], "green");
					cli_execute(strs[i]);
				}
			}
			return true;
		}
		if (contains_text(maxme, "+outfit")) {
			cli_execute("outfit "+maxme.replace_string("+outfit ", ""));
			return true;
		}
		if (contains_text(maxme, "pirate fledges")) {
			cli_execute("equip acc3 pirate fledges");
			return true;
		}
		if (contains_text(maxme, "mega gem")) {
			cli_execute("equip acc3 mega gem");
			cli_execute("equip acc2 talisman o' namsilat");
			return true;
		}
		if (contains_text(maxme, "talisman")) {
			cli_execute("equip acc3 talisman o' namsilat");
			return true;
		}
		if (contains_text(maxme, "nuns")) {
			cli_execute("outfit "+bcasc_warOutfit);
			return true;
		}
		return true;
	}

	//We should sell these to avoid hassle with muscle classes.
	foreach i in $items[antique helmet, antique shield, antique greaves, antique spear] {
		autosell(item_amount(i), i);
	}

	//Just a quick check for this.
	if (contains_text(maxme, "continuum transfunctioner") && my_primestat() == $stat[Muscle]) {
		cli_execute("maximize "+max_bees+" beeosity, mainstat "+(my_path() == "Way of the Surprising Fist" ? "" : " +effective -ml, "+maxme)); 
		return true;
	}
	if (contains_text(maxme, "knob goblin elite") && !(my_path() == "Way of the Surprising Fist")) {
		if (my_basestat($stat[Muscle]) < 15) abort("BCC: You need 15 base muscle to equip the KGE outfit.");
		if (my_basestat($stat[Moxie]) < 15) abort("BCC: You need 15 base moxie to equip the KGE outfit.");
		cli_execute("maximize "+max_bees+" beeosity, mainstat, -ml, "+maxme); 
		return true;
	}
	if (maxme.contains_text("item") && have_path_familiar($familiar[Mad Hatrack])) {
		maxme += " -equip spangly sombrero";
	} else if (maxme.contains_text("item") && have_path_familiar($familiar[Fancypants Scarecrow])) {
		maxme += " -equip spangly mariachi pants";
	}
	
	//The hilarious comedy prop is basically never the good choice.
	if (i_a($item[hilarious comedy prop]) > 0 && !contains_text(maxme, "hp regen")) {
		maxme = maxme + " -equip hilarious comedy prop";
	}
	
	//KoL lies about the actual reality goggles, so we need to force an override here.
	if (available_amount($item[actual reality goggles]) > 0) {
		maxme = maxme + " -equip actual reality goggles";
	}

	//Monster Modifiers are just fun. But since not everyone can easily handle them, let users set if they want them.
	maxme = maxme + " "+bcasc_diceMultiplier+" random monster modifiers";

	//Manual override for the nuns.
	if (contains_text(maxme, "nuns")) {
		cli_execute("maximize mainstat " + ((bcasc_AllowML) ? "" : "-10 ml") + " +outfit "+bcasc_warOutfit);
		switch (my_primestat()) {
			case $stat[Muscle] : 		cli_execute("maximize "+max_bees+" beeosity" + (my_path() == "Zombie Slayer" ? "" : ", 0.5 mp regen max") + ", mainstat " + ((bcasc_AllowML) ? "" : "-10 ml") + (my_path() == "Way of the Surprising Fist" ? " " : " +effective ")+((anHero()) ? "+shield" : "")+" +current +outfit "+bcasc_warOutfit); break;
			case $stat[Mysticality] : 	cli_execute("maximize "+max_bees+" beeosity, 0.5 mp regen max, mainstat +init " + ((bcasc_AllowML) ? "" : "-10 ml") + " +current +outfit "+bcasc_warOutfit); break;
			case $stat[Moxie] : 		cli_execute("maximize "+max_bees+" beeosity, 0.5 mp regen max, mainstat " + ((bcasc_AllowML) ? "" : "-10 ml") + (my_path() == "Way of the Surprising Fist" ? " " : " +effective +current +outfit ")+bcasc_warOutfit); break;
		}
		string sns = prepSNS();
		if (sns != "") {
			equip(to_item(sns.replace_string("+equip ", "")));
		}
		return true;
	}

	if (my_path() == "Nuclear Autumn" && i_a("lead umbrella") > 0) {
		maxme += " +equip lead umbrella";
	}

	//Basically, we ALWAYS want and -ml, for ALL classes. Otherwise we let an override happen. 
	switch (my_primestat()) {
		case $stat[Muscle] : 		cli_execute("maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, .25 item power, weapon damage, "+(my_path() == "Way of the Surprising Fist" ? " " : " +effective ")+((anHero() && !contains_text(maxme, "UV-re")) ? "+shield" : "") + ((bcasc_AllowML) ? "" : " -10 ml") + " +muscle experience " + (my_path() == "Zombie Slayer" ? "" : "+0.5 mp regen min +0.5 mp regen max, .5 hp, ")+maxme); break;
		case $stat[Mysticality] : 	cli_execute("maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, .25 item power, weapon damage, +10 spell damage, +mysticality experience +5 mp regen min +5 mp regen max, .5 hp, " + ((bcasc_AllowML) ? "" : "-10 ml, ")+maxme); break;
		case $stat[Moxie] : 		cli_execute("maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, .25 item power, weapon damage, ranged damage, "+(my_path() == "Way of the Surprising Fist" ? " " : " +effective ") + ((bcasc_AllowML) ? "" : "-10 ml") + " +moxie experience +0.5 mp regen min +0.5 mp regen max, .5 hp, "+maxme); break;
	}
	return true;
}
boolean buMax(string maxme) { return buMax(maxme, 999999999); }
boolean buMax() { return buMax(""); }

//This is just a glorified wrapper for adventure()
boolean bumMiniAdv2(int adventures, location loc, string override) {
	betweenBattle();
	if (override != "") {
		try {
			adventure(adventures, loc, override);
			boolean success = true;
		} finally {
			return success;
		}
	} else if (my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) {
		try {
			adventure(adventures, loc, "consultMyst");
			boolean success = true;
		} finally {
			return success;
		}
	} else {
		try {
			adventure(adventures, loc);
			boolean success = true;
		} finally {
			return success;
		}
	}
}

boolean bumMiniAdvNoAbort(int adventures, location loc, string override) {
	if(!bumMiniAdv2(adventures, loc, override)) {
		//abort("BCC: You aborted, so so am I. This abort may have been caused by a rogue condition not being met. If this is unexpected, please paste the CLI output, as well as the results of typing 'condition check' without the quotes, into the mafia CLI window now.");
	}
	return true;
}
boolean bumMiniAdvNoAbort(int adventures, location loc) { return bumMiniAdvNoAbort(adventures, loc, ""); }

boolean bumMiniAdv(int adventures, location loc, string override) {
	if(!bumMiniAdv2(adventures, loc, override)) {
		abort("BCC: You aborted, so so am I. This abort may have been caused by a rogue condition not being met. If this is unexpected, please paste the CLI output, as well as the results of typing 'condition check' without the quotes, into the mafia CLI window now.");
	}
	return true;
}
boolean bumMiniAdv(int adventures, location loc) { return bumMiniAdv(adventures, loc, ""); }

string bumRunCombat(string consult) {
	//If we're not in a combat, we don't need to run this
	if (!contains_text(visit_url("fight.php"), "Combat")) {
		print("BCC: You aren't in a combat (or something to do with Ed which I can't work out), so bumRunCombat() doesn't need to do anything.", "purple");
		return to_string(run_combat());
	}
	
	if (consult != "") {
		print("BCC: Run_Combat() is using Consult Script = "+consult+".", "purple");
		return to_string(run_combat(consult));
	}
	else if (my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) {
		print("BCC: Run_Combat() is using consultMyst.", "purple");
		return to_string(run_combat("consultMyst"));
	}
	else if (can_interact()) {
		print("BCC: Run_Combat() is using consultCasual.", "purple");
		return to_string(run_combat("consultCasual"));
	}
	print("BCC: Run_Combat() being used normally.", "purple");
	return to_string(run_combat());
}
string bumRunCombat() { return bumRunCombat(""); }

boolean canMCD() {
	if (knoll_available() && item_amount($item[detuned radio]) == 0 && my_meat() < 300) return false;
	return ((knoll_available() || canadia_available()) || (gnomads_available() && (item_amount($item[bitchin' meatcar]) + item_amount($item[bus pass]) + item_amount($item[pumpkin carriage])) > 0));
}

boolean canZap() {
	int wandnum = 0;
	if (item_amount($item[dead mimic]) > 0) use(1, $item[dead mimic]);
	for wand from  1268 to 1272 {
		if (item_amount(to_item(wand)) > 0) {
			wandnum = wand;
		}
	}
	if (wandnum == 0) { return false; }
	return (!(contains_text(visit_url("wand.php?whichwand="+wandnum), "feels warm") || contains_text(visit_url("wand.php?whichwand="+wandnum), "careful")));
}

//Returns true if we've completed this stage of the script. 
boolean checkStage(string what, boolean setAsWell) {
	if (setAsWell) {
		print("BCC: We have completed the stage ["+what+"] and need to set it as so.", "navy");
		set_property("bcasc_stage_"+what, my_ascensions());
	}
	if (get_property("bcasc_stage_"+what) == my_ascensions()) {
		print("BCC: We have completed the stage ["+what+"].", "navy");
		return true;
	}
	print("BCC: We have not completed the stage ["+what+"].", "navy");
	return false;
}
boolean checkStage(string what) { return checkStage(what, false); }

int cloversAvailable(boolean makeOneTenLeafClover) {
	if (bcasc_cloverless) {
		if (item_amount($item[ten-leaf clover]) > 0 && my_path() != "Bees Hate You")
			use(item_amount($item[ten-leaf clover]), $item[ten-leaf clover]);
		else if(item_amount($item[ten-leaf clover]) > 0)
			put_closet(item_amount($item[ten-leaf clover]), $item[ten-leaf clover]);
		print("BCC: You have the option for a cloverless ascention turned on, so we won't be using them.", "purple");
		return 0;
	}
	
	if (get_property("bcasc_lastHermitCloverGet") != today_to_string()) {
		print("BCC: Getting Clovers", "purple");
		if (my_path() != "Zombie Slayer")
			if (cli_execute("hermit * clover")) {}
		else
			if (hermit(1, $item[Ten-leaf clover])) {}
		set_property("bcasc_lastHermitCloverGet", today_to_string());
	} else {
		print("BCC: We've already got Clovers Today", "purple");
	}
	
	if (my_path() != "Bees Hate You") {
		if (makeOneTenLeafClover && (item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover])) > 0) {
			print("BCC: We're going to end up with one and exactly one ten leaf clover", "purple");
			if (item_amount($item[ten-leaf clover]) > 0) {
				cli_execute("use * ten-leaf clover; use 1 disassembled clover;");
			} else {
				cli_execute("use 1 disassembled clover;");
			}
		}
	} else {
		if (makeOneTenLeafClover && (item_amount($item[ten-leaf clover]) + closet_amount($item[ten-leaf clover])) > 0) {
			print("BCC: We're going to end up with one and exactly one ten leaf clover", "purple");
			if (item_amount($item[ten-leaf clover]) > 0) {
				put_closet(item_amount($item[ten-leaf clover]) - 1, $item[ten-leaf clover]);
			} else {
				take_closet(1,$item[ten-leaf clover]);
			}
		}		
	}
	
	return (my_path() == "Bees Hate You") ? item_amount($item[ten-leaf clover]) + closet_amount($item[ten-leaf clover]) : item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]);
}
int cloversAvailable() { return cloversAvailable(false); }

//Checks for saucepans and turtle totems and summons if not found and asked to
boolean have_castitems(class who, boolean get_them) {
	switch(who) {
		case $class[sauceror]:
			if (i_a("saucepan") + i_a("5-Alarm Saucepan") + i_a("17-alarm Saucepan") + i_a("Windsor Pan of the Source") > 0)
				return true;
			else if(get_them)
				while (i_a("saucepan") == 0) {
					use(1, $item[chewing gum on a string]);
					if (i_a("saucepan") > 0)
						return true;
				}
			return false;
		case $class[turtle tamer]:
			if (i_a("Turtle totem") + i_a("Mace of the Tortoise") + i_a("Chelonian Morningstar") + i_a("Flail of the Seven Aspects") > 0)
				return true;
			else if(get_them)
				while (i_a("Turtle totem") == 0) {
					use(1, $item[chewing gum on a string]);
					if (i_a("Turtle totem") > 0)
						return true;
				}
			return false;
	}
	return false;
}

//Do we have enough elemntal resistance available?
boolean get_res(element ele, int target, boolean do_stuff) {
	float sum;
	string[int] perform;
	int j;
	foreach i, rec in maximize(to_string(ele) + " resistance" + (bcasc_100familiar == "" ? ", switch exotic parrot" : "") + (get_path() == "Nuclear Autumn" && i_a("lead umbrella") > 0 ? ", +equip lead umbrella" : ""), 0, (can_interact() ? 1 : 0), true, true) {
		if(rec.score > 0) {
			perform[j] = rec.command;
			sum = sum + rec.score;
			j += 1;
		}
	}

	if(sum + elemental_resistance(ele) / 10 >= target) {
		if(do_stuff) {
			for j from 0 to count(perform) - 1 {
				cli_execute(perform[j]);
				if(elemental_resistance(ele) / 10 >= target)
					return true;
			}
		} else {
			return true;			
		}
	}
	return false;
}

string consultJarl(int round, string opp, string text) {
	if (get_property("bcasc_doJarlAsCCS") == "true") return get_ccs_action(round);
	
	if (opp == "rampaging adding machine") {
		print("The script will not, at the moment, automatically fight rampagaing adding machines. Please fight manually.");
		return "abort";
	}	

	boolean [skill] allMySkills() {
		boolean [skill] allmyskills;
		
		foreach s in $skills[Curdle, Boil, Fry, Slice, Chop, Bake, Grill, Freeze, Blend] {
			if (have_skill(s)) { allmyskills[s] = true; }
		}
		return allmyskills;
	}
	
	//Checks if the monster we're fighting is weak against element e. Returns the multiplier for our spell.
	int isWeak(element e) {
		boolean [element] weakElements;
 
		switch (monster_element()) {
		   case $element[cold]:   weakElements = $elements[spooky, hot];    break;
		   case $element[spooky]: weakElements = $elements[hot, stench];    break;
		   case $element[hot]:    weakElements = $elements[stench, sleaze]; break;
		   case $element[stench]: weakElements = $elements[sleaze, cold];   break;
		   case $element[sleaze]: weakElements = $elements[cold, spooky];   break;
		   default: return 1;
		}
		
		if (weakElements contains e) {
			print("BCC: Weak Element to our pasta tuning.", "olive");
			return 2;
		} else if (monster_element() == e) {
			print("BCC: Strong Element to our pasta tuning.", "olive");
			return 0.01;
		} else {
			print("BCC: Neutral Element to our pasta tuning.", "olive");
			return 1;
		}
		return 1;
	}
	
	//This should return the MP used to cast the spell. Basically give it the MP and it checks the modifiers you have on.
	int mpCost(int baseMP) {
		return baseMP;
	}
	
	float wtfpwnageExpected(skill s) {
		float bAbs = numeric_modifier("Spell Damage");
		float bPer = numeric_modifier("Spell Damage Percent")/100 + 1;
		//Should multiply the bonuses below by bonus spell damage. 
		float bCol = numeric_modifier("Cold Spell Damage");
		float bHot = numeric_modifier("Hot Spell Damage");
		float bSte = numeric_modifier("Stench Spell Damage");
		float bSle = numeric_modifier("Sleaze Spell Damage");
		float bSpo = numeric_modifier("Spooky Spell Damage");
		float bElm = bCol+bHot+bSte+bSle+bSpo;
		float myst = my_buffedstat($stat[Mysticality]);
		print("BCC: These are the figures for "+to_string(s)+": Bonus: "+bAbs+" and "+bPer+"%//"+bCol+"/"+bHot+"/"+bSte+"/"+bSle+"/"+bSPo+"/El: "+bElm+"/Myst: "+myst, "purple");
		
		//Uses the above three functions to estimate the wtfpwnage from a given skill. 
		switch (s) {
			case $skill[Curdle] :
				return 0 * isWeak($element[stench]);
			case $skill[Boil] :
				return max(10 * mpCost(5), (12.5*bPer + .4*my_buffedstat($stat[mysticality]) + bAbs))*isWeak($element[hot]);
			case $skill[Fry] :
				return 0 * isWeak($element[sleaze]);
			case $skill[Slice] :
				return 0 * isWeak($element[none]);
			case $skill[Chop] :
				return max(100 * mpCost(20), (25*bPer + .5*my_buffedstat($stat[mysticality]) + bAbs));
			case $skill[Bake] :
				return 0;
			case $skill[Grill] :
				return 0;
			case $skill[Freeze] :
				return max(10 * mpCost(5), (12.5*bPer + .4*my_buffedstat($stat[mysticality]) + bAbs))*isWeak($element[cold]);
			default:
				return 0;
		}
		return -1;
	}
	
	int hp = monster_hp();
	print("BCC: Monster HP is "+hp, "purple");
	int wtfpwn;
	int mostDamage;
	skill bestSkill;
	boolean [skill] oneShot;
	boolean [skill] twoShot;
	boolean [skill] threeShot;
	boolean [skill] fourShot;
	boolean oneShotHim = true;
	string cast;
	
	foreach s in allMySkills() {
		wtfpwn = wtfpwnageExpected(s);
		
		if (wtfpwn > mostDamage) {
			bestSkill = s;
		}
		
		print("BCC: I expect "+wtfpwn+" damage from "+to_string(s), "purple");
		if (wtfpwn > hp) {
			//Then we can one-shot the monster with this skill.
			oneShot[s] = true;
		} else if (wtfpwn > hp/2) {
			twoShot[s] = true;
		} else if (wtfpwn > hp/3) {
			threeShot[s] = true;
		}else if (wtfpwn > hp/5) {
			fourShot[s] = true;
		}
	}
	
	//If we're fighting the NS, then it's best skill, ALL THE TIME.
	if (contains_text(text, "Naughty Sorceress")) {
		print("BCC: This is the Naughty Sorceress you're fighting here. SPELL ALL THE THINGS!", "purple");
		if (contains_text(text, ">Entangling Noodles (")) {
			return "skill Entangling Noodles";
		}
		return "skill "+to_string(bestSkill);
	}
	
	//Returns which skill has the lowest MP in a given range of skills. 
	skill lowestMP(boolean [skill] ss) {
		int lowestMPCostSoFar = 999999;
		skill skillToReturn = $skill[none];
		
		foreach s in ss {
			if (mp_cost(s) < lowestMPCostSoFar) {
				lowestMPCostSoFar = mp_cost(s);
				skillToReturn = s;
			}
		}
		return skillToReturn;
	}	
	
	//If we can one-shot AND noodles/twoshot isn't cheaper, do that. 
	if (count(oneShot) > 0) {
		if (have_skill($skill[Blend])) {
			if (count(twoShot) > 0) {
				int mpOneShot = mp_cost(lowestMP(oneShot));
				int mpTwoShot = mp_cost(lowestMP(twoShot));
				if (mpOneShot > 7+2*mpTwoShot) {
					print("BCC: We're actually NOT going to one-shot because Blend and then two shotting would be cheaper.", "purple");
					oneShotHim = false;
				}
			}
		}
	}
	
	if (oneShotHim && count(oneShot) > 0) {
		cast = to_string(lowestMP(oneShot));
		print("BCC: We are going to one-shot with "+cast, "purple");
		return "skill "+cast;
	} else {
		//Basically, we should cast noodles if we haven't already done this, and we're not going to one-shot the monster. 
		if (contains_text(text, ">Blend (")) {
			return "skill Blend";
		}
		if (count(twoShot) > 0) {
			cast = to_string(lowestMP(twoShot));
			print("BCC: We are going to two-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(threeShot) > 0) {
			cast = to_string(lowestMP(threeShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(fourShot) > 0) {
			cast = to_string(lowestMP(fourShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
	}
	print("Please fight the remainder of the fight yourself. You will be seeing this because you do not as Jarlsberg have a spell powerful enough to even four-shot the monster. If you wish to use a CCS or a combat script like WHAM to handle fights, set bcasc_doJarlAsCCS to true in the settings manager.", "red");
	return "abort";
}

//Has to be before the other consult functions, as they call it some of the time. 
string consultMyst(int round, string opp, string text) {
	if (my_path() == "Avatar of Jarlsberg") return consultJarl(round, opp, text);
	if (get_property("bcasc_doMystAsCCS").to_boolean()) return get_ccs_action(round);
	
	if (opp == "rampaging adding machine") {
		print("The script will not, at the moment, automatically fight rampagaing adding machines. Please fight manually.");
		return "abort";
	}
	
	//Override for olfaction. 
	if (contains_text(get_ccs_action(round), "olfact")) {
		if (contains_text(text, ">Transcendent Olfaction (")) {
			return "skill Transcendent Olfaction";
		}
	}

	boolean [skill] allMySkills() {
		boolean [skill] allmyskills;
		
		foreach s in $skills[Spaghetti Spear, Ravioli Shurikens, Cannelloni Cannon, Stuffed Mortar Shell, Weapon of the Pastalord, Fearful Fettucini,
			Salsaball, Stream of Sauce, Saucestorm, Wave of Sauce, Saucegeyser, K&auml;seso&szlig;esturm, Surge of Icing] {
			if (have_skill(s)) { allmyskills[s] = true; }
		}
		return allmyskills;
	}
	
	//Returns the element of the cookbook we have on, if we have one. 
	element cookbook(boolean isPasta) {
		//These two work for all classes spells.
		if (equipped_amount($item[Gazpacho's Glacial Grimoire]) > 0) return $element[cold];
		if (equipped_amount($item[Codex of Capsaicin Conjuration]) > 0) return $element[hot];
		if (!isPasta) return $element[none];
		//Else the following three work for only pasta spells.
		if (equipped_amount($item[Cookbook of the Damned]) > 0) return $element[stench];
		if (equipped_amount($item[Necrotelicomnicon]) > 0) return $element[spooky];
		if (equipped_amount($item[Sinful Desires]) > 0) return $element[sleaze];
		return $element[none];
	}
	
	element elOfSpirit(effect e) {
		switch (e) {
			case $effect[Spirit of Cayenne]: return $element[hot];
			case $effect[Spirit of Peppermint]: return $element[cold];
			case $effect[Spirit of Garlic]: return $element[stench];
			case $effect[Spirit of Wormwood]: return $element[spooky];
			case $effect[Spirit of Bacon Grease]: return $element[sleaze];
		}
		return $element[none];
	}
	
	//This estimates monster HP if necessary.
	int monsterHP() {
		if (monster_hp(to_monster(opp)) > 0) {
			return monster_hp();
		}
		
		print("BCC: This script is estimating this ("+to_string(opp)+") monster's HP as "+monster_attack()+" "+monster_hp()+".", "purple");
		
		return monster_attack() - monster_hp();
	}
	
	//Checks if the monster we're fighting is weak against element e. For sauce spells, if called directly. 
	int isWeak(element e) {
		boolean [element] weakElements;
 
		switch (monster_element()) {
		   case $element[cold]:   weakElements = $elements[spooky, hot];    break;
		   case $element[spooky]: weakElements = $elements[hot, stench];    break;
		   case $element[hot]:    weakElements = $elements[stench, sleaze]; break;
		   case $element[stench]: weakElements = $elements[sleaze, cold];   break;
		   case $element[sleaze]: weakElements = $elements[cold, spooky];   break;
		   default: return 1;
		}
		
		if (weakElements contains e) {
			print("BCC: Weak Element to our pasta tuning.", "olive");
			return 2;
		} else if (monster_element() == e) {
			print("BCC: Strong Element to our pasta tuning.", "olive");
			return 0.01;
		} else {
			print("BCC: Neutral Element to our pasta tuning.", "olive");
			return 1;
		}
		return 1;
	}
	//Checks if the monster we're fighting is weak against the Flavor of Magic element. For pasta spells. 
	int isWeak() {
		foreach e in $effects[Spirit of Cayenne, Spirit of Peppermint, Spirit of Garlic, Spirit of Wormwood, Spirit of Bacon Grease] {
			if (have_effect(e) > 0) {
				print("BCC: We are under the effect of "+to_string(e), "olive");
				return isWeak(elOfSpirit(e));
			}
		}
		return 1;
	}
	//Checks if the monster is weak against whatever Sauce element would be appropriate. The actual string is ignored.
	int isWeak(string ignored) {
		return isWeak($element[none]);
	}
	
	//Returns which skill has the lowest MP in a given range of skills. 
	skill lowestMP(boolean [skill] ss) {
		int lowestMPCostSoFar = 999999;
		skill skillToReturn = $skill[none];
		
		foreach s in ss {
			if (mp_cost(s) < lowestMPCostSoFar) {
				lowestMPCostSoFar = mp_cost(s);
				skillToReturn = s;
			}
		}
		return skillToReturn;
	}
	
	float wtfpwnageExpected(skill s) {
		float bAbs = numeric_modifier("Spell Damage");
		float bPer = numeric_modifier("Spell Damage Percent")/100 + 1;
		//Should multiply the bonuses below by bonus spell damage. 
		float bCol = numeric_modifier("Cold Spell Damage");
		float bHot = numeric_modifier("Hot Spell Damage");
		float bSte = numeric_modifier("Stench Spell Damage");
		float bSle = numeric_modifier("Sleaze Spell Damage");
		float bSpo = numeric_modifier("Spooky Spell Damage");
		float bElm = bCol+bHot+bSte+bSle+bSpo;
		float myst = my_buffedstat($stat[Mysticality]);
		print("BCC: These are the figures for "+to_string(s)+": Bonus: "+bAbs+" and "+bPer+"%//"+bCol+"/"+bHot+"/"+bSte+"/"+bSle+"/"+bSPo+"/El: "+bElm+"/Myst: "+myst, "purple");
		
		//Uses the above three functions to estimate the wtfpwnage from a given skill. 
		switch (s) {
			case $skill[Spaghetti Spear] :
				return (2.5*bPer + min(5, bAbs))*isWeak();
			case $skill[Ravioli Shurikens] :
				return (5.5*bPer + 0.07*myst*bPer + min(25, bAbs) + bElm)*isWeak();
			case $skill[Cannelloni Cannon] :
				return (12*bPer + 0.15*myst*bPer + min(40, bAbs) + bElm)*isWeak();
			case $skill[Stuffed Mortar Shell] :
				return (40*bPer + 0.35*myst*bPer + min(55, bAbs) + bElm)*isWeak();
			case $skill[Weapon of the Pastalord] :
				float weak = isWeak();
				if (weak == 2) weak = 1.5;
				return (48*bPer + 0.35*myst*bPer + bAbs + bElm)*weak;
			case $skill[Fearful Fettucini] :
				return (48*bPer + 0.35*myst*bPer + bAbs + bElm)*isWeak($element[spooky]);
			case $skill[Salsaball] :
				return (2.5*bPer + min(5, bAbs))*isWeak($element[hot]);
			case $skill[Stream of Sauce] :
				return (3.5*bPer + 0.10*myst*bPer + min(10, bAbs) + bElm)*isWeak("");
			case $skill[Saucestorm] :
				return (16*bPer + 0.20*myst*bPer + min(15, bAbs) + bElm)*isWeak("");
			case $skill[Wave of Sauce] :
				return (22*bPer + 0.30*myst*bPer + min(25, bAbs) + bElm)*isWeak("");
			case $skill[Saucegeyser] :
				return (40*bPer + 0.35*myst*bPer + min(10, bAbs) + bElm)*isWeak("");
			case $skill[K&auml;seso&szlig;esturm] :
				return (16*bPer + 0.20*myst*bPer + min(15, bAbs) + bElm)*isWeak($element[stench]);
			case $skill[Surge of Icing] :
				//Sugar Rush has an effect on this skill. 
				return (16*bPer + 0.20*myst*bPer + min(15, bAbs) + bElm);
			default:
				return 0;
		}
		return -1;
	}

	int hp = monsterHP();
	print("BCC: Monster HP is "+hp, "purple");
	int isWeak = isWeak();
	int wtfpwn;
	int mostDamage;
	skill bestSkill;
	boolean [skill] oneShot;
	boolean [skill] twoShot;
	boolean [skill] threeShot;
	boolean [skill] fourShot;
	boolean oneShotHim = true;
	string cast;
	
	foreach s in allMySkills() {
		wtfpwn = wtfpwnageExpected(s);
		
		if (wtfpwn > mostDamage) {
			bestSkill = s;
		}
		
		print("BCC: I expect "+wtfpwn+" damage from "+to_string(s), "purple");
		if (wtfpwn > hp) {
			//Then we can one-shot the monster with this skill.
			oneShot[s] = true;
		} else if (wtfpwn > hp/2) {
			twoShot[s] = true;
		} else if (wtfpwn > hp/3) {
			threeShot[s] = true;
		}else if (wtfpwn > hp/5) {
			fourShot[s] = true;
		}
	}
	
	//If we're fighting the NS, then it's best skill, ALL THE TIME.
	if (contains_text(text, "Naughty Sorceress")) {
		print("BCC: This is the Naughty Sorceress you're fighting here. SPELL ALL THE THINGS!", "purple");
		if (contains_text(text, ">Entangling Noodles (")) {
			return "skill Entangling Noodles";
		}
		return "skill "+to_string(bestSkill);
	}
	
	//If we can one-shot AND noodles/twoshot isn't cheaper, do that. 
	if (count(oneShot) > 0) {
		if (have_skill($skill[Entangling Noodles])) {
			if (count(twoShot) > 0) {
				int mpOneShot = mp_cost(lowestMP(oneShot));
				int mpTwoShot = mp_cost(lowestMP(twoShot));
				if (mpOneShot > 3+2*mpTwoShot) {
					print("BCC: We're actually NOT going to one-shot because noodles and then two shotting would be cheaper.", "purple");
					oneShotHim = false;
				}
			}
		}
	}
	
	if (oneShotHim && count(oneShot) > 0) {
		cast = to_string(lowestMP(oneShot));
		print("BCC: We are going to one-shot with "+cast, "purple");
		return "skill "+cast;
	} else {
		//Basically, we should cast noodles if we haven't already done this, and we're not going to one-shot the monster. 
		if (contains_text(text, ">Entangling Noodles (")) {
			return "skill Entangling Noodles";
		}
		if (count(twoShot) > 0) {
			cast = to_string(lowestMP(twoShot));
			print("BCC: We are going to two-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(threeShot) > 0) {
			cast = to_string(lowestMP(threeShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(fourShot) > 0) {
			cast = to_string(lowestMP(fourShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
	}
	print("Please fight the remainder of the fight yourself. You will be seeing this because you do not have a spell powerful enough to even four-shot the monster.", "red");
	return "abort";
}

string consultBarrr(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (round == 0 || round == 1) {
		if (my_path() == "Bees Hate You") return "item Massive Manual of Marauder Mockery";
		return "item the big book of pirate insults";
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultBugbear(int round, string opp, string text) {
	switch (my_location()) {
		case $location[Engineering]:	if (opp == "liquid metal bugbear" && i_a("drone self-destruct chip") > 0) {
											print("BCC: Using a drone self-destruct chip to kill this liquid metal bugbear.", "purple");
											return "item drone self-destruct chip";
										}
										else
											return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
		case $location[Science Lab]:	if (opp == "bugbear scientist" && i_a("quantum nanopolymer spider web") > 0) {
											print("BCC: Using a quantum nanopolymer spider web to silence the scientist.", "purple");
											return "item quantum nanopolymer spider web";
										}
										else
											return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
}		

string consultCasual(int round, string opp, string text) {
	print("BCC: Round: "+round+" Opp: "+opp, "purple");

	if (get_property("bcasc_doCasualAsHC") != "false") {
		print("BCC: You have selected to do casual runs like hardcore (using your CCS). Feel free to change this setting in the relay browser if you want a one-day-casual set of runaways..", "purple");
		return get_ccs_action(round);
	} else {
		print("BCC: You do not have the option set to do casual runs as Hardcore. This means the script will attempt to use the default action specified in your bcasc_defaultCasualAction setting. The current setting is designed for a one-day casual. To make this all go away, set bcasc_doCasualAsHC to true in the relay script.", "purple");
	}
	
	boolean bookThisMonster() {
		return $strings[tetchy pirate, toothy pirate, tipsy pirate] contains opp;
	}

	boolean fightThisMonster() {
		if (opp == "cleanly pirate" && item_amount($item[rigging shampoo]) == 0) return true;
		if (opp == "creamy pirate" && item_amount($item[ball polish]) == 0) return true;
		if (opp == "curmudgeonly pirate" && item_amount($item[mizzenmast mop]) == 0) return true;
	
		return $strings[Ed the Undying, ancient protector spirit, protector spirit, gaudy pirate, modern zmobie, conjoined zmombie, gargantulihc, huge ghuol, giant skeelton, 
			dirty old lihc, swarm of ghuol whelps, big swarm of ghuol whelps, giant swarm of ghuol whelps, The Bonerdagon, The Boss Bat, booty crab,
			black panther, black adder, Dr. Awkward, Lord Spookyraven, Protector Spectre, lobsterfrogman, The Knob Goblin King] contains opp;
	}
	
	boolean olfactThisMonster() {
		if (opp == "cleanly pirate" && item_amount($item[ball polish]) == 1 && item_amount($item[mizzenmast mop]) == 1) return true;
		if (opp == "creamy pirate" && item_amount($item[mizzenmast mop]) == 1 && item_amount($item[rigging shampoo]) == 1) return true;
		if (opp == "curmudgeonly pirate" && item_amount($item[ball polish]) == 1 && item_amount($item[rigging shampoo]) == 1) return true;
		
		return $strings[dirty old lihc] contains opp;
	}
	
	boolean pickpocketThisMonster() {
		return $strings[spiny skelelton, toothy sklelton] contains opp;
	}	

	//Pickpocket a certain whitelist of monsters, else those monsters with no item drops cause issues.
	if (contains_text(text, "type=submit value=\"Pick") && pickpocketThisMonster()) {
		print("BCC: Yoink!", "purple");
		return "pickpocket";
	}
		
	//If we have RBF, we may as well use them. 
	if (item_amount($item[rock band flyers]) > 0) {
		if (contains_text(text, ">Entangling Noodles (")) {
			print("BCC: Noodle pre-flyer", "purple");
			return "skill Entangling Noodles";
		}
		print("BCC: Use Flyers", "purple");
		return "item rock band flyers";
	}
		
	//If we have JBF, we may as well use them. 
	if (item_amount($item[jam band flyers]) > 0) {
		if (contains_text(text, ">Entangling Noodles (")) {
			print("BCC: Noodle pre-flyer", "purple");
			return "skill Entangling Noodles";
		}
		print("BCC: Use Flyers", "purple");
		return "item jam band flyers";
	}
		
	//If we have BPI, we may as well use it. 
	if (item_amount($item[The Big Book of Pirate Insults]) > 0 && bookThisMonster() && (round == 0 || round == 1)) {
		print("BCC: Use the Big Book of Pirate Insults", "purple");
		return "item Big Book of Pirate Insults";
	}
		
	//Monsters to simply attack
	//print(opp);
	if (fightThisMonster()) {
		print("BCC: One of the few monsters we're going to attack.", "purple");
		if (round == 2) {
			print("BCC: Special Action", "purple");
			return "special action";
		}
		
		if (olfactThisMonster()) {
			if (have_effect($effect[on the trail]) == 0 && my_mp() >= 40 && contains_text(text, "Olfaction (")) {
				print("BCC: And olfact. Gotta get me some of that sweet monster smell...", "purple");
				return "skill olfaction";
			}
		}
		
		print("BCC: Attack", "purple");
		return "attack with weapon";
	}
	
	//Special Case 
	if ($strings[rampaging adding machine] contains opp) {
		if (have_skill($skill[Ambidextrous Funkslinging])) {
			if (item_amount($item[64735 scroll]) == 0) {
				if (item_amount($item[64067 scroll]) > 0 && item_amount($item[668 scroll]) > 0) {
					return "item 64067 scroll, 668 scroll";
				}
				
				if (item_amount($item[64067 scroll]) == 0) {
					return "item 30669 scroll, 33398 scroll";
				}
				
				if (item_amount($item[668 scroll]) == 0) {
					return "item 334 scroll, 334 scroll";
				}
			}
		} else {
			print("BCC: Fight this one yourself.", "purple");
			return "abort";
		}
	}
	
	get_ccs_action(round);
	if (get_property("bcasc_defaultCasualAction") != "") return get_property("bcasc_defaultCasualAction");
	
	print("BCC: Attacking is the default action for casual runs. Change bcasc_defaultCasualAction in the relay script if you want something else.", "purple");
	return "attack";
}

string consultCyrus(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (round == 1) {
		if (bcasc_doWarAs == "frat") {
			return "item rock band flyers";
		} else {
			return "item jam band flyers";
		}
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

//This consult script is just to be used to sling !potions against 
string consultDoD(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	foreach pot, eff in allBangPotions() {
		if (item_amount(pot) > 0) {
			if (eff == $effect[none]) return "item "+pot;
			print("BCC: We've identified "+pot+" already.", "purple");
		}
	}
	print("BCC: We've identified all the bang potions we have to hand.", "purple");
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultGMOB(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (contains_text(text, "Guy Made Of Bees")) {
		print("BCC: We are fighting the GMOB!", "purple");
		if (bcasc_doWarAs == "frat") {
			if(item_amount(to_item("antique hand mirror")) == 0 || !have_skill($skill[ambidextrous funkslinging]))
				return "item rock band flyers";
			else
				return "item rock band flyers,antique hand mirror";
		} else {
			if(item_amount(to_item("antique hand mirror")) == 0 || !have_skill($skill[ambidextrous funkslinging]))
				return "item jam band flyers";
			else
				return "item jam band flyers,antique hand mirror";
		}
	}
	print("BCC: We are not fighting the GMOB!", "purple");
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

item thingToGet = $item[none];
string consultHeBo(int round, string opp, string text) {
	if (my_location() != $location[itznotyerzitz mine]) {if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));}
	//If we're under the effect "Everything Looks Yellow", then ignore everything and attack.
	if (have_effect($effect[Everything Looks Yellow]) > 0) {
		print("BCC: We would LIKE to use a Yellow Ray somewhere in this zone, but we can't because Everything Looks Yellow.", "purple");
		return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	}

	//Let's check that the monster IS the correct one
	if (contains_text(text, "hippy jewelry maker") || contains_text(text, "Dwarf Foreman") || contains_text(text, "Racecar")
			|| contains_text(text, "War Hippy") || contains_text(text, "Frat Warrior") || contains_text(text, "War Pledge")
			|| (thingToGet == $item[metallic A] && contains_text(text, "MagiMechTech MechaMech"))) {
		if (my_path() == "Bees Hate You") {
			print("BCC: We are trying to use the HeBoulder, but you can't use it (nor a pumpkin bomb or a light) due to bees hating you, so I'm attacking.", "purple");
			return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
		}
		
		if (my_familiar() == $familiar[He-Boulder]) {
			print("BCC: We are using the hebo against the right monster.", "purple");
			if (contains_text(text, "yellow eye")) {
				return "skill point at your opponent";
			} else {
				switch (my_class()) {
					case $class[turtle tamer] : return "skill toss";
					case $class[seal clubber] : return "skill clobber";
					case $class[pastamancer] : return "skill Spaghetti Spear";
					case $class[sauceror] : return "skill salsaball";
					case $class[Disco Bandit] : return "skill suckerpunch";
					case $class[Accordion Thief] : return "skill sing";
					default: abort("BCC: unsupported class");
				}
			}
		} else if (my_familiar() == $familiar[Crimbo Shrub] && contains_text(text, "Open a Big Yellow Present")) {
			print("BCC: We are using the Crimbo Shrub against the right monster.", "purple");
			return "skill open a big yellow present";
		} else if (my_familiar() == $familiar[Nanorhino] && (get_property("_nanorhinoCharge").to_int() == 100 || have_effect($effect[Nanoballsy]) > 39)) {
			print("BCC: We are using the Nanorhino against the right monster.", "purple");
			if (have_effect($effect[Nanoballsy]) > 39) return "skill unleash nanites";
			if (have_skill($skill[suckerpunch])) return "skill suckerpunch";
			else if (have_skill($skill[sing])) return "skill sing";
			print("BCC: We are trying to use the Nanorhino, but you don't have access to easy Moxie skills, so I'm attacking.", "purple");
			return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
		} else if (item_amount($item[unbearable light]) > 0) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm using an unbearable light.", "purple");
			return "item unbearable light";
		} else if (item_amount($item[pumpkin bomb]) > 0) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm using a pumpkin bomb.", "purple");
			return "item pumpkin bomb";
		} else if (my_path() == "Avatar of Sneaky Pete" && have_skill($skill[flash headlight]) && get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb") {
			print("BCC: We are trying to use the HeBoulder, but you are in an AoSP run, so I'm using Flash Headlight.", "purple");
			return "skill flash headlight";
		} else {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run without pumpkins or clipart), so I'm attacking.", "purple");
			return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
		}
	}
	print("BCC: We are trying to use the HeBoulder, but this is not the right monster, so I'm attacking.", "purple");
	
	if (my_familiar() == $familiar[He-Boulder] && have_effect($effect[Everything Looks Red]) == 0 && contains_text(text, "red eye"))
		return "skill point at your opponent";
	
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultJunkyard(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	boolean isRightMonster = false;
	
	//AMC Gremlins are useless. 
	if (opp == $monster[a.m.c. gremlin]) {
		if (item_amount($item[divine champagne popper]) > 0) return "item divine champagne popper";
		return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	} else {
		//Check to see if the monster CAN carry the item we want. This comes straight from Zarqon's SmartStasis.ash. 
		if (my_location() == to_location(get_property("currentJunkyardLocation"))) {
			print("BCC: Right location.", "purple");
			isRightMonster = (item_drops() contains to_item(get_property("currentJunkyardTool")));
		} else {
			print("BCC: Wrong location.", "purple");
			isRightMonster = (!(item_drops() contains to_item(get_property("currentJunkyardTool"))));
		}
	}
	
	if (isRightMonster) {
		print("BCC: We have found the correct monster, so will stasis until the item drop occurrs.", "purple");
		if (contains_text(text, "It whips out a hammer") || contains_text(text, "He whips out a crescent") || contains_text(text, "It whips out a pair") || contains_text(text, "It whips out a screwdriver")) {
			print("BCC: The script is trying to use the moly magnet. This may be the cause of the NULL errors here.", "purple");
			return "item molybdenum magnet";
		} else {
			if (my_hp() < 50 || round > 15) {
				//print("BCC: Let's cast bandages to heal you.", "purple");
				return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
				//For some reason, this doesn't work at all and I can't work out why. 
				return "skill lasagna bandages";
			} else {
				switch (my_class()) {
					case $class[turtle tamer] : return "skill toss";
					case $class[seal clubber] : return "skill clobber";
					case $class[Pastamancer] : return "skill Spaghetti Spear";
					case $class[Sauceror] : return "skill Salsaball";
					case $class[Disco Bandit] : return "skill suckerpunch";
					case $class[Accordion Thief] : return "skill sing";
				}
				if (i_a("seal tooth") > 0) return "item seal tooth";
				if (i_a("facsimile dictionary") > 0) return "item facsimile dictionary";
				if (i_a("spectre scepter") > 0) return "item spectre scepter";
			}
		}
	} else {
		print("BCC: This is the wrong monster.", "purple");
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultObtuse(int round, string opp, string text) {
	print("BCC: Consulting for anything we want to fire a romantic arrow at.", "purple");
	if (my_familiar() == $familiar[Obtuse Angel]) {
		print("BCC: Obtuse Angel detected.", "purple");
		if (contains_text(text, "romantic arrow (")) {
			print("BCC: Romantic Arrow Detected.", "purple");
			return "skill fire a badly romantic arrow";
		}
		return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultRunaway(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (round == 1 && have_skill($skill[Entangling Noodles])) { return "skill entangling noodles"; }
	return "try to run away";
}

void defaultMood(boolean castMojo) {
	//Save time in casual runs. 
	if (can_interact() && !bcasc_RunSCasHC) return;
	//if (my_path() == "Way of the Surprising Fist") return;
	cli_execute("mood bumcheekascend");
	cli_execute("mood clear");
	cli_execute("trigger gain_effect, just the best anapests, uneffect just the best anapests");
	switch (my_primestat()) {
		case $stat[Muscle] :
			if(my_path() != "way of the surprising fist") {
				if (my_level() > 5 && my_path() != "Bees Hate You" && my_path() != "BIG!" && npc_price($item[ben-gal&trade; balm]) > 0) { cli_execute("trigger lose_effect, Tiger!, use 5 Ben-Gal Balm"); }
				if (my_level() < 7) {
					if (castMojo && have_skill($skill[The Magical Mojomuscular Melody])) cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
					if (anHero()) {
						if (have_skill($skill[The Power Ballad of the Arrowsmith])) cli_execute("trigger lose_effect, Power Ballad of the Arrowsmith, cast 1 The Power Ballad of the Arrowsmith");
					} else {
						if (have_skill($skill[The Moxious Madrigal]) && my_path() != "BIG!") cli_execute("trigger lose_effect, The Moxious Madrigal, cast 1 The Moxious Madrigal");
					}
				}
				if (have_skill($skill[Patience of the Tortoise]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Patience of the Tortoise, cast 1 Patience of the Tortoise");
				if (have_skill($skill[Seal Clubbing Frenzy]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Seal Clubbing Frenzy, cast 1 Seal Clubbing Frenzy");
				if (my_level() > 9 && have_skill($skill[Rage of the Reindeer])) cli_execute("trigger lose_effect, Rage of the Reindeer, cast 1 Rage of the Reindeer");
				if (my_path() == "Zombie Slayer") cli_execute("trigger unconditional, ,ashq if(item_amount($item[hunter brain]) > 0 && my_fullness() < fullness_limit() && !(have_skill($skill[Ravenous Pounce]) && have_skill($skill[Howl of the Alpha])  && have_skill($skill[Zombie Maestro]))) {abort(\"You have acquired a hunter brain. Eat it and feel smarter.\");}");
 			} else {
				if (my_level() < 7 && castMojo && have_skill($skill[The Magical Mojomuscular Melody])) cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
				if (have_skill($skill[Patience of the Tortoise])) cli_execute("trigger lose_effect, Patience of the Tortoise, cast 1 Patience of the Tortoise");
				if (have_skill($skill[Seal Clubbing Frenzy])) cli_execute("trigger lose_effect, Seal Clubbing Frenzy, cast 1 Seal Clubbing Frenzy");
				if (my_level() > 9 && have_skill($skill[Rage of the Reindeer])) cli_execute("trigger lose_effect, Rage of the Reindeer, cast 1 Rage of the Reindeer");				
				if (have_skill($skill[Miyagi Massage])) cli_execute("trigger lose_effect, Retrograde Relaxation, cast 1 Miyagi Massage");
				if (have_skill($skill[Salamander Kata])) cli_execute("trigger lose_effect, Salamanderenity, cast 1 Salamander Kata");
			}			
		break;
		
		case $stat[Mysticality] :
			if (my_path() == "Avatar of Jarlsberg" || my_path() == "Actually Ed the Undying") {
				if (my_level() > 5 && my_meat() > 2000 && npc_price($item[hair spray]) > 0) { cli_execute("trigger lose_effect, Butt-Rock Hair, use 5 hair spray"); }
				if (my_level() > 5 && my_meat() > 2000 && npc_price($item[glittery mascara]) > 0) { cli_execute("trigger lose_effect, Glittering Eyelashes, use 5 glittery mascara"); }
			} else {
				if (my_level() > 5 && my_meat() > 2000 && my_path() != "BIG!" && npc_price($item[hair spray]) > 0) { cli_execute("trigger lose_effect, Butt-Rock Hair, use 5 hair spray"); }
				//if (my_level() > 5 && my_meat() > 2000) { cli_execute("trigger lose_effect, Glittering Eyelashes, use 5 glittery mascara"); }
				if (my_level() < 7) {
					if ((castMojo && have_skill($skill[The Moxious Madrigal])) && my_path() != "BIG!") cli_execute("trigger lose_effect, The Moxious Madrigal, cast 1 The Moxious Madrigal");
					if (have_skill($skill[Springy Fusilli])) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
				}
				if (have_skill($skill[The Magical Mojomuscular Melody]) && my_maxmp() < 200) cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
				if (have_skill($skill[Manicotti Meditation]) && my_level() < 5) cli_execute("trigger lose_effect, Pasta Oneness, cast 1 Manicotti Meditation");
				if (have_skill($skill[Sauce Contemplation]) && my_level() < 5) cli_execute("trigger lose_effect, Saucemastery, cast 1 Sauce Contemplation");
				if (have_skill($skill[Moxie of the Mariachi]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Mariachi Mood, cast 1 Moxie of the Mariachi");
				if (have_skill($skill[Disco Aerobics]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Disco State of Mind, cast 1 Disco Aerobics");
				if ((i_a("5-alarm saucepan") + i_a("17-alarm saucepan") > 0) && have_skill($skill[Jalape&ntilde;o Saucesphere]) && my_class() == $class[sauceror]) cli_execute("trigger lose_effect, Jalape&ntilde;o Saucesphere, cast 1 Jalape&ntilde;o Saucesphere");
				if (have_skill($skill[Flavour of magic]) && have_effect($effect[Spirit of Peppermint]) == 0) use_skill(1,$skill[Spirit of Peppermint]);
				if (have_skill($skill[Springy Fusilli]) && my_class() == $class[Pastamancer]) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
			}
		break;
		
		case $stat[Moxie] :
			if (my_level() < 7) {
				if (have_skill($skill[The Moxious Madrigal]) && my_path() != "BIG!") cli_execute("trigger lose_effect, The Moxious Madrigal, cast 1 The Moxious Madrigal");
				if (castMojo && have_skill($skill[The Magical Mojomuscular Melody])) cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
			}
			if (have_skill($skill[Moxie of the Mariachi]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Mariachi Mood, cast 1 Moxie of the Mariachi");
			if (have_skill($skill[Disco Aerobics]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Disco State of Mind, cast 1 Disco Aerobics");
			if(my_path() != "way of the surprising fist") {
				if (my_level() > 5 && my_meat() > 2000 && npc_price($item[hair spray]) > 0) { cli_execute("trigger lose_effect, Butt-Rock Hair, use 5 hair spray"); }
			} else {
				if (have_skill($skill[Miyagi Massage])) cli_execute("trigger lose_effect, Retrograde Relaxation, cast 1 Miyagi Massage");
				if (have_skill($skill[Salamander Kata])) cli_execute("trigger lose_effect, Salamanderenity, cast 1 Salamander Kata");
			}
		break;
	}
}
void defaultMood() { defaultMood(true); }

//Returns true if we have the elite guard outfit. 
boolean haveElite() {
	if (get_property("lastDispensaryOpen") != my_ascensions()) return false;
	int a,b,c;
	if (i_a("Knob Goblin elite helm") > 0) { a = 1; }
	if (i_a("Knob Goblin elite polearm") > 0) { b = 1; }
	if (i_a("Knob Goblin elite pants") > 0) { c = 1; }
	return (a+b+c==3)&&(i_a("Cobb's Knob lab key")>0);
}

//identifyBangPotions will be true if we've identified them all out of {blessing, detection, acuity, strength, teleport}, false if there are still some left to identify. 
boolean identifyBangPotions() {
	//Returns the number of the 5 important potions we've found. 
	int numPotionsFound() {
		int i = 0;
		foreach pot, eff in allBangPotions() {
			switch (eff) {
				case $effect[Izchak's Blessing] :
				case $effect[Object Detection] :
				case $effect[Strange Mental Acuity] :
				case $effect[Strength of Ten Ettins] :
				case $effect[Teleportitis] :
					i = i + 1;
				break;
			}
		}
		return i;
	}
	
	//Returns true if there are some unknown potions that we should find out about by throwing them against monsters. (i.e. we HAVE them)
	boolean somePotionsUnknown() {
		foreach pot, eff in allBangPotions() {
			if (eff == $effect[none] && item_amount(pot) > 0) return true;
		}
		return false;
	}
	
	boolean usedPotion = false;
	while (numPotionsFound() < 5 && somePotionsUnknown()) {
		if (!in_hardcore() && my_inebriety() <= inebriety_limit() - 3) {
			usedPotion = false;
			foreach pot, eff in allBangPotions() {
				if (item_amount(pot) > 0) {
					if (eff == $effect[none] && !usedPotion) {
						use(1, pot);
						usedPotion = true;
					}
				}
			}
		} else {
			bumMiniAdv(1, $location[The Smut Orc Logging Camp], "consultDoD");
		}
	}
	
	print("BCC: We have found "+numPotionsFound()+"/5 important DoD potions", "purple");
	return (numPotionsFound() >= 5);
}

// arg = "stepNx" will return N * 10 + <letters a-i transmogrified into digits 1-9>
int numerify(string arg)
{
    int max_steps = 12;
    matcher m_step = create_matcher("^step(\\d+)([a-i]?)$", arg);
    switch {
    case arg == "unstarted": return -1;
    case arg == "started": return 0;
    case arg == "finished": return max_steps * 10 + 10;
    case arg == "step0": break;
    case find(m_step): //for i from 0 to 2 print("group " + i + " = \"" + group(m_step, i) + "\"");
        string d = group(m_step, 1);
        string s = group(m_step, 2);
        // if d <= max_steps && there's no extra "0"s return maths
        if (length(d) <= (d.to_int() > max_steps ? 0 : (d.to_int() > 9 ? 2 : 1))) return d.to_int() * 10 + (s == "" ? 0 : index_of("_abcdefghi", s));
    }
    return -11;
}

boolean is_at_least(string a_string, string b_string) {
    return (numerify(a_string) >= numerify(b_string));
}

boolean is_past(string a_string, string b_string) {
    return (numerify(a_string) > numerify(b_string));
}

boolean is_not_yet(string a_string, string b_string) {
	return (numerify(a_string) < numerify(b_string));
}

boolean is_equal_to(string a_string, string b_string) {
	return (numerify(a_string) == numerify(b_string));
}

int numPirateInsults() {
	int t = 0, i = 1;
	while (i <= 8) {
		if (get_property("lastPirateInsult"+i) == "true") {
			t = t + 1;
		}
		i = i + 1;
	}
	return t;
}

int numOfWand() {
	if (item_amount($item[dead mimic]) > 0) use(1, $item[dead mimic]);
	for wandcount from  1268 to 1272 {
		if (item_amount(to_item(wandcount)) > 0) {
			return wandcount;
		}
	}
	return 0;
}

int numUniqueKeys() {
	int keyb, keyj, keys;
	if (i_a("boris's key") > 0) { keyb = 1; }
	if (i_a("jarlsberg's key") > 0) { keyj = 1; }
	if (i_a("sneaky pete's key") > 0) { keys = 1; }
	return keyb+keyj+keys;
}

//Creates cocktails and reagent pasta.
boolean omNomNom() {
	int howManyDoWeHave(string type) {
		int numberOfItems;
		
		switch (type) {
			case "acc" :
				foreach i in $items[tropical swill, pink pony, slip 'n' slide, fuzzbump, ocean motion, fruity girl swill, ducha de oro, horizontal tango, 
					roll in the hay, a little sump'm sump'm, blended frozen swill, slap and tickle, rockin' wagon, perpendicular hula, calle de miel] {
					numberOfItems += item_amount(i);
				}
			break;
			
			case "reagentpasta" :
				foreach i in $items[fettucini inconnu, gnocchetti di Nietzsche, hell ramen, spaghetti with Skullheads, spaghetti con calaveras] {
					numberOfItems += item_amount(i);
				}
			break;
			
			case "scc" :
				foreach i in $items[Neuromancer, vodka stratocaster, Mon Tiki, teqiwila slammer, Divine, Gordon Bennett, gimlet, yellow brick road, 
					mandarina colada, tangarita, Mae West, prussian cathouse] {
					numberOfItems += item_amount(i);
				}
			break;
		}
		
		return numberOfItems;
	}
	
	int needBooze() {
		return to_int((inebriety_limit() - my_inebriety())/4);
	}
	
	int needFood() {
		return to_int((fullness_limit() - my_fullness())/6);
	}
	
	if (get_property("bcasc_prepareFoodAndDrink") != "true") return false;
	//Only do this if we're rich enough or something. Might want this to not be exactly the same as willMood(), so copying rather than using the function. 
	if (!(haveElite() || my_meat() > 5000 || my_mp() > 100 || my_level() > 9)) return false;
	if (!in_hardcore()) return false;
	
	if (have_skill($skill[Pastamastery]) && have_skill($skill[Advanced Saucecrafting])) {
		print("BCC: Preparing Food (Have "+howManyDoWeHave("reagentpasta")+" Reagent Pastas)", "purple");
		
		foreach i in $items[fettucini inconnu, gnocchetti di Nietzsche, hell ramen, spaghetti with Skullheads, spaghetti con calaveras] {
			if (item_amount($item[dry noodles]) == 0) cli_execute("cast pastamastery");
			if (item_amount($item[scrumptious reagent]) == 0) cli_execute("cast advanced sauce");
			if (creatable_amount(i) > 0 && howManyDoWeHave("reagentpasta") < needFood()) {
				cli_execute("make 1 "+to_string(i));
			}
		}
	}
	
	if (have_skill($skill[Advanced Cocktailcrafting])) {
		print("BCC: Preparing Booze (Have "+howManyDoWeHave("scc")+" SCC and "+howManyDoWeHave("acc")+" ACC)", "purple");
		
		if (have_skill($skill[Superhuman Cocktailcrafting])) {
			foreach i in $items[Neuromancer, vodka stratocaster, Mon Tiki, teqiwila slammer, Divine, Gordon Bennett, gimlet, yellow brick road, 
						mandarina colada, tangarita, Mae West, prussian cathouse] {
				if (get_property("cocktailSummons") < 3 + to_int(have_skill($skill[Superhuman Cocktailcrafting]))*2) cli_execute("cast 5 cocktail");
				if (creatable_amount(i) > 0 && howManyDoWeHave("acc") + howManyDoWeHave("scc") < needBooze()) {
					cli_execute("make 1 "+to_string(i));
				}
			}
		}
			
		foreach i in $items[tropical swill, pink pony, slip 'n' slide, fuzzbump, ocean motion, fruity girl swill, ducha de oro, horizontal tango, 
					roll in the hay, a little sump'm sump'm, blended frozen swill, slap and tickle, rockin' wagon, perpendicular hula, calle de miel] {
			if (get_property("cocktailSummons") < 3 + to_int(have_skill($skill[Superhuman Cocktailcrafting]))*2) cli_execute("cast 5 cocktail");
			if (creatable_amount(i) > 0 && howManyDoWeHave("acc") + howManyDoWeHave("scc") < needBooze()) {
				cli_execute("make 1 "+to_string(i));
			}
		}
	}
	return true;
}

string runChoice(string page_text) {
	while( contains_text( page_text , "choice.php" ) ) {
		## Get choice adventure number
		int begin_choice_adv_num = ( index_of( page_text , "whichchoice value=" ) + 18 );
		int end_choice_adv_num = index_of( page_text , "><input" , begin_choice_adv_num );
		string choice_adv_num = substring( page_text , begin_choice_adv_num , end_choice_adv_num );
		
		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = get_property( choice_adv_prop );
		
		if( choice_num == "" ) abort( "Unsupported Choice Adventure!" );
		
		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url( url );
	}
	return page_text;
}

void sellJunk() {	
	if (my_path() == "Way of the Surprising Fist") return;
	foreach i in $items[meat stack, dense meat stack, meat paste, magicalness-in-a-can, moxie weed, strongness elixir] {
		if (item_amount(i) > 0) autosell(item_amount(i), i);
	}
	foreach i in $items[Old coin purse, old leather wallet, black pension check, warm subject gift certificate, Penultimate Fantasy chest] {
		if (item_amount(i) > 0) use(item_amount(i), i);
	}
}

//Returns the safe Moxie for given location, by going through all the monsters in it.
int safeMox(location loc) {
	if (get_property("bcasc_dontTouchStuff") == "true") {
		print("BCC: Safe Moxie for "+to_string(loc)+" ignored as bcasc_dontTouchStuff is true", "purple");
		return 0;
	}
	//Softcore is deemed to be able to take care of virtually any ML. 
	if (loc == $location[The Primordial Soup] || !in_hardcore()) return 0;
	
	//Scaling monsters play havoc with this. The actual number used isn't really important as we'll only hit this after Level 11 anyway. 
	// Actually, we'll tell zones with scaling monsters that we only care about them if they're within 20 of our moxie, which should skip bears and crazy monsters
	// if (loc == $location[The Hidden Temple]) return 60;
	
	int ret = 0;
	
	//Find the hardest monster. 
	foreach mob, freq in appearance_rates(loc) {
		if (mob.attributes.contains_text("Scale")) {
			if (mob.base_attack < my_buffedstat($stat[Moxie]) - 5) ret = max(ret, monster_attack(mob));
			continue;
		}
		if (freq >= 0 && !($monsters[Guy Made of Bees, Baron von Ratsworth, Ghost of Elizabeth Spookyraven] contains mob)) ret = max(ret, monster_attack(mob));
	}
	//Note that monster_attack() takes into account ML. So just add something to account for this.
	return ret + 4;
}

//Function to tell if we can adventure at a specific location
boolean can_adv(location where) {
	// load permanently unlocked zones
	string theprop = get_property("unlockedLocations");
	if (theprop == "" || index_of(theprop,"--") < 0 || substring(theprop,0,index_of(theprop,"--")) != to_string(my_ascensions()))
		theprop = my_ascensions()+"--";
	if (contains_text(theprop,where)) return true;

	boolean primecheck(int req) {
		if (my_buffedstat(my_primestat()) < req)
			return false;
		return true;
	}
	boolean levelcheck(int req) {
		if (my_level() < req) return false;
		return true;
	}
	boolean itemcheck(item req) {
		if (available_amount(req) == 0)
			return false;
		return true;
	}
	boolean equipcheck(item req) {
		if (!can_equip(req)) return false;
		return (item_amount(req) > 0 || have_equipped(req));
	}
	boolean outfitcheck(string req) {
		if (!have_outfit(req)) return false;
		return true;
	}
	boolean perm_urlcheck(string url, string needle) {
		if (contains_text(visit_url(url),needle)) {
			set_property("unlockedLocations",theprop+" "+where);
			return true;
		}
		return false;
	}
	boolean pirate_check(string url) {
		if (!(equipcheck($item[pirate fledges]) || outfitcheck("swashbuckling getup"))) return false;
		return perm_urlcheck("place.php?whichplace=cove",url);
	}

	// begin location checking
	switch (where) {
	// always open
	case $location[The Sleazy Back Alley]:
	case $location[The Haunted Pantry]:
	case $location[The Outskirts of Cobb's Knob]: return true;
	// level-opened
	case $location[The Spooky Forest]: return (levelcheck(2));
	case $location[A Barroom Brawl]: return (my_path() != "Zombie Slayer" && levelcheck(3));
	case $location[8-Bit Realm]: return (primecheck(20));
	case $location[The Bat Hole Entrance]: return (levelcheck(4) && primecheck(13));
	case $location[Guano Junction]: return (levelcheck(4) && primecheck(13) && numeric_modifier("Stench Resistance") > 0);
	case $location[The Batrat and Ratbat Burrow]:
	case $location[The Beanbat Chamber]: if (!primecheck(13)) return false;
									if (!levelcheck(4)) return false;
									string bathole = visit_url("place.php?whichplace=bathole");
									int sonarsneeded = to_int(!contains_text(bathole,"batratroom.gif")) +
										to_int(!contains_text(bathole,"batbeanroom.gif"));
									if (sonarsneeded > 0) {
										return (item_amount($item[sonar-in-a-biscuit]) >= sonarsneeded);
									}
									return (perm_urlcheck("place.php?whichplace=bathole",to_url(where)));
	case $location[Cobb's Knob Kitchens]: if (!primecheck(20)) return false;
	case $location[Cobb's Knob Barracks]:
	case $location[Cobb's Knob Treasury]:
	case $location[Cobb's Knob Harem]: if ((!levelcheck(5) || contains_text(visit_url("place.php?whichplace=plains"), "knob1.gif")) || (have_equipped($item[Knob Goblin elite helm]) && have_equipped($item[Knob Goblin elite polearm]) && have_equipped($item[Knob Goblin elite pants]))) return false; return true;
	case $location[The Enormous Greater-Than Sign]: return (primecheck(44) && contains_text(visit_url("da.php"),to_url(where)));
	case $location[The Dungeons of Doom]: return (primecheck(44) && perm_urlcheck("da.php",to_url(where)));
	case $location[Itznotyerzitz Mine]: return (levelcheck(8) && primecheck(53));
	case $location[The Black Forest]: return (levelcheck(11) && primecheck(104));
	// key opened
	case $location[Cobb's Knob Laboratory]: return (primecheck(30) && itemcheck($item[Cobb's Knob lab key]));
	case $location[Cobb's Knob Menagerie\, Level 1]: return (primecheck(35) && itemcheck($item[Cobb's Knob Menagerie key]));
	case $location[Cobb's Knob Menagerie\, Level 2]: return (primecheck(40) && itemcheck($item[Cobb's Knob Menagerie key]));
	case $location[Cobb's Knob Menagerie\, Level 3]: return (primecheck(45) && itemcheck($item[Cobb's Knob Menagerie key]));
	case $location[Hippy Camp]: return (get_property("lastIslandUnlock").to_int() == my_ascensions() && get_property("warProgress") != "started" && get_property("sideDefeated") != "hippies" && get_property("sideDefeated") != "both" && primecheck(30));
	case $location[Frat House]: return (get_property("lastIslandUnlock").to_int() == my_ascensions() && get_property("warProgress") != "started" && get_property("sideDefeated") != "fratboys" && get_property("sideDefeated") != "both" && primecheck(30));
	case $location[The Obligatory Pirate's Cove]: return (itemcheck($item[dingy dinghy]) && !is_wearing_outfit("swashbuckling getup") && !have_equipped($item[pirate fledges]) && get_property("warProgress") != "started" && primecheck(45));
	case $location[The Castle in the Clouds in the Sky (Basement)]: return (primecheck(95) && item_amount($item[S.O.C.K.]) + item_amount($item[intragalactic rowboat]) > 0);
	case $location[The Hole in the Sky]: return (primecheck(100) && itemcheck($item[intragalactic rowboat]));
	case $location[The Haunted Library]: return (primecheck(40) && itemcheck($item[Spookyraven library key]));
	case $location[The Haunted Gallery]: return (get_property("questM21Dance") != "unstarted");
	case $location[The Haunted Ballroom]: return (get_property("questM21Dance") == "finished");
	case $location[Inside the Palindome]: return (primecheck(65) && equipcheck($item[Talisman o' Namsilat]));
	case $location[Tower Ruins]: return (primecheck(18) && itemcheck($item[Fernswarthy's letter]));
	case $location[The Oasis]: return ((itemcheck($item[your father's macguffin diary]) || itemcheck($item[copy of a jerk adventurer's father's diary])) && perm_urlcheck("place.php?whichplace=desertbeach",to_url(where)));
	case $location[The Upper Chamber]:
	case $location[The Middle Chamber]: return (itemcheck(to_item("2325"))); // Item 2325 is the Staff of Ed
	// signs
	case $location[Thugnderdome]: return (my_path() != "Zombie Slayer" && gnomads_available() && primecheck(25));
	case $location[Outskirts of Camp Logging Camp]: return (my_path() != "Zombie Slayer" && canadia_available());
	case $location[Camp Logging Camp]: return (my_path() != "Zombie Slayer" && canadia_available() && primecheck(30));
	case $location[Post-Quest Bugbear Pens]: return (my_path() != "Zombie Slayer" && knoll_available() && primecheck(13) && contains_text(visit_url("questlog.php?which=2"),"You've helped Mayor Zapruder") && perm_urlcheck("place.php?whichplace=woods",to_url(where)));
	case $location[The Bugbear Pen]: return (my_path() != "Zombie Slayer" && knoll_available() && primecheck(13) && !contains_text(visit_url("questlog.php?which=2"),"You've helped Mayor Zapruder") && perm_urlcheck("place.php?whichplace=woods",to_url(where)));
	// misc
	case $location[The Degrassi Knoll Garage]: return (!knoll_available() && primecheck(10) && guild_store_available( ) && perm_urlcheck("place.php?whichplace=plains","knoll1.gif"));
	case $location[The "Fun" House]: return (guild_store_available( ) && primecheck(15) && perm_urlcheck("place.php?whichplace=plains",to_url(where)));
	case $location[The Unquiet Garves]: return (primecheck(11) && guild_store_available( ) && !visit_url("questlog.php?which=2").contains_text("defeated the Bonerdagon"));
	case $location[The VERY Unquiet Garves]: return (primecheck(40) && perm_urlcheck("questlog.php?which=2","defeated the Bonerdagon"));
	case $location[The Goatlet]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("place.php?whichplace=mclargehuge",to_url(where)));
	case $location[Lair of the Ninja Snowmen]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("place.php?whichplace=mclargehuge",to_url(where)));
	case $location[The eXtreme Slope]: return (levelcheck(8) && perm_urlcheck("place.php?whichplace=mclargehuge",to_url(where)));
	case $location[Whitey's Grove]: return (levelcheck(7) && primecheck(34) && guild_store_available( ) && perm_urlcheck("place.php?whichplace=woods",to_url(where)));
	case $location[The Laugh Floor]:
	case $location[Infernal Rackets Backstage]:
	case $location[Pandamonium Slums]: return (primecheck(29) && (have_skill($skill[liver of steel]) || have_skill($skill[spleen of steel]) ||
										 have_skill($skill[stomach of steel]) || perm_urlcheck("questlog.php?which=2","cleansed the taint")));
	case $location[The Valley of Rof L'm Fao]: return (levelcheck(9) && perm_urlcheck("place.php?whichplace=mountains",to_url(where)));
	case $location[The Penultimate Fantasy Airship]: return (levelcheck(10) && primecheck(90) && (perm_urlcheck("place.php?whichplace=plains","beanstalk.gif") || use(1,$item[enchanted bean])));
	case $location[The Road to the White Citadel]: return (!white_citadel_available() && guild_store_available( ) && visit_url("place.php?whichplace=woods").contains_text(to_url(where)));
	case $location[The Haunted Kitchen]: return (primecheck(5) && (itemcheck($item[Spookyraven library key]) || perm_urlcheck("place.php?whichplace=manor1",to_url(where))));
	case $location[The Haunted Conservatory]: return (primecheck(6) && perm_urlcheck("place.php?whichplace=manor1",to_url(where)));
	case $location[The Haunted Billiards Room]: return (primecheck(10) && perm_urlcheck("place.php?whichplace=manor1","manor1_billiards"));
	case $location[The Haunted Bathroom]: return (primecheck(68) && get_property("questM21Dance") != "unstarted");
	case $location[The Haunted Bedroom]: return (primecheck(85) && get_property("questM21Dance") != "unstarted");
	case $location[The Haunted Wine Cellar]: return (levelcheck(11) && (itemcheck($item[your father's macguffin diary]) || itemcheck($item[copy of a jerk adventurer's father's diary])) && perm_urlcheck("place.php?whichplace=manor1","place.php?whichplace=manor4"));
	case $location[The Icy Peak]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("questlog.php?which=2","L337 Tr4pz0r") && numeric_modifier("Cold Resistance") > 0);
	//case $location[Barrrney's Barrr]: return (get_property("lastIslandUnlock").to_int() == my_ascensions() && (equipcheck($item[pirate fledges]) || outfitcheck("swashbuckling getup"))); - problematic
	case $location[The F'c'le]:
	case $location[The Poop Deck]:
	case $location[Belowdecks]: return (pirate_check(to_url(where)));
	//case $location[Hidden City (encounter)]: return (levelcheck(11) && (itemcheck($item[your father's macguffin diary]) || itemcheck($item[copy of a jerk adventurer's father's diary])) && perm_urlcheck("place.php?whichplace=woods","place.php?whichplace=hiddencity"));
	//TODO: FIX THE ABOVE ONCE NEW HIDDEN CITY SPADED
	default: return false;
	}
}

//Changes the familiar based on a string representation of what we want. 
boolean setFamiliar(string famtype) {
	item bootsSpleenThing() {
		for i from 5198 to 5219 {
			if (item_amount(to_item(i)) > 0) return to_item(i);
		}
		return $item[none];
	}

	//The very first thing is to check 100% familiars
	if(bcasc_100familiar != "" && my_path() != "Avatar of Boris" && my_path() != "Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete" && my_path() != "Actually Ed the Undying") {
		print("BCC: Your familiar is set to a 100% "+bcasc_100familiar, "purple");
		cli_execute("familiar "+bcasc_100familiar);
		return true;
	}
	
	if (famtype == "nothing") {
		use_familiar($familiar[none]);
		return true;
	}

	if (famtype == "blackforest" && i_a("reassembled blackbird") == 0 && i_a("reconstituted crow") == 0) {
		if (have_path_familiar($familiar[Reassembled Blackbird])) {
			use_familiar($familiar[Reassembled Blackbird]);
			return true;
		} else if (have_path_familiar($familiar[Reconstituted Crow])) {
			use_familiar($familiar[Reconstituted Crow]);
			return true;
		}
	}
	
	//Then a quick check for if we have Everything Looks Yellow
	if ((have_effect($effect[Everything Looks Yellow]) > 0 || (my_path() == "Bees Hate You") || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete" && my_path() != "Actually Ed the Undying") && famtype == "hebo") { famtype = "items"; }
	
	//THEN a quick check for a spanglerack
	if (i_a("spangly sombrero") > 0 && have_path_familiar($familiar[Mad Hatrack]) && (contains_text(famtype, "item") || contains_text(famtype, "equipment"))) {
		print("BCC: We are going to be using a spanglerack for items. Yay Items!", "purple");
		use_familiar($familiar[Mad Hatrack]);
		if (equipped_item($slot[familiar]) != $item[spangly sombrero]) equip($slot[familiar], $item[spangly sombrero]);
		if (equipped_item($slot[familiar]) == $item[spangly sombrero]) return true;
		print("BCC: There seemed to be a problem and you don't have a spangly sombrero equipped. I'll use a 'normal' item drop familiar.", "purple");
	} else if(i_a("spangly mariachi pants") > 0 && have_path_familiar($familiar[fancypants scarecrow]) && (contains_text(famtype, "item") || contains_text(famtype, "equipment"))) {
		print("BCC: We are going to be using the spanglepants for items. Yay Items!", "purple");
		use_familiar($familiar[Fancypants Scarecrow]);
		if (equipped_item($slot[familiar]) != $item[spangly mariachi pants]) equip($slot[familiar], $item[spangly mariachi pants]);
		if (equipped_item($slot[familiar]) == $item[spangly mariachi pants]) return true;
		print("BCC: There seemed to be a problem and you don't have the spangly mariachi pants equipped. I'll use a 'normal' item drop familiar.", "purple");
	}
	
	if (my_path() == "Avatar of Boris") {	//Lute = +item, Crumhorn = +stats, Sackbut = +HP/MP
		string charpane = visit_url("charpane.php");
		if((famtype == "items" || famtype == "itemsnc" || famtype == "equipmentnc")) {
			if(minstrel_instrument() == $item[Clancy's lute])
				return true;
			else if(i_a("Clancy's lute") > 0) {
				use(1, $item[Clancy's lute]);
				return true;
			}
		}
		if(i_a("Clancy's crumhorn") > 0) {
			use(1, $item[Clancy's crumhorn]);
			return true;
		} else if(minstrel_instrument() == $item[Clancy's crumhorn]) {
			return true;
		} else if(i_a("Clancy's sackbut") > 0){
			use(1, $item[Clancy's sackbut]);
			return true;
		} else {
			return true;
		}
	} else if (my_path() == "Avatar of Jarlsberg" && get_property("bcasc_SwapFood") == "true") {
		if(have_skill($skill[egg man]) && (famtype == "items" || famtype == "equipmentnc" || famtype == "itemsnc" || famtype == "obtuseangel") && i_a("cosmic egg") > 0) {
			use_skill(1, $skill[egg man]);
			return true;
		} else if(have_skill($skill[Radish Horse]) && famtype == "init" && i_A("cosmic vegetable") > 0) {
			use_skill(1, $skill[Radish Horse]);
			return true;
		} else if(have_skill($skill[Cream Puff]) && famtype == "ml" && i_a("cosmic cream") > 0) {
			use_skill(1, $skill[Cream Puff]);
			return true;
		} else if(have_skill($skill[Hippotatomous]) && i_a("cosmic potato") > 0) {
			use_skill(1, $skill[Hippotatomous]);
			return true;
		}
		return false; 
		
	}
	
	//Finally, actually start getting familiars.
	if (famtype != "") {
		string [int] famlist;
		load_current_map("bcs_fam_"+famtype, famlist);
		foreach x in famlist {
			print("Checking for familiar '"+famlist[x]+"' where x="+x, "purple");
			if (have_path_familiar(famlist[x].to_familiar())) {
				use_familiar(famlist[x].to_familiar());
				return true;
			}
		}
	}

	print("BCC: Switching Familiar for General Use", "aqua");
	int maxspleen = 15;
	if (have_skill($skill[Spleen of Steel])) maxspleen = 20;
	
	if (have_path_familiar($familiar[Rogue Program]) || have_path_familiar($familiar[Baby Sandworm]) || have_path_familiar($familiar[Bloovian Groose]) || have_path_familiar($familiar[Unconscious Collective]) || have_path_familiar($familiar[Grim Brother]) || have_path_familiar($familiar[Golden Monkey])) {
		//Before we do anything, let's check if there's any spleen to do. May as well do this as we go along.

		if (my_spleen_use() < maxspleen-3 && get_property("bcasc_doNotUseSpleen") != "true" && !can_interact()) {
			print("BCC: Going to try to use some spleen items if you have them.", "purple");

			while (my_spleen_use() < maxspleen-3 && item_amount($item[groose grease]) > 0) {
				chew(1, $item[groose grease]);
				cli_execute("uneffect just the best anapests");
			}
			while (my_spleen_use() < maxspleen-3 && item_amount($item[unconscious collective dream jar]) > 0) {
				chew(1, $item[unconscious collective dream jar]);
			}			
			while (my_spleen_use() < maxspleen-3 && item_amount($item[grim fairy tale]) > 0) {
				chew(1, $item[grim fairy tale]);
			}
			while (my_spleen_use() < maxspleen-3 && item_amount($item[powdered gold]) > 0) {
				chew(1, $item[powdered gold]);
			}
		}

		if (my_spleen_use() <= maxspleen-4 && my_level() >= 4 && get_property("bcasc_doNotUseSpleen") != "true" && !can_interact()) {
			print("BCC: Going to try to use some spleen items if you have them.", "purple");
			
			while (my_spleen_use() < maxspleen-3 && item_amount($item[agua de vida]) > 0) {
				chew(1, $item[agua de vida]);
			}
			
			while (bootsSpleenThing() != $item[none] && my_spleen_use() < maxspleen-3) {
				chew(1, bootsSpleenThing());
			}
			
			visit_url("place.php?whichplace=town_wrong");
			while (my_spleen_use() < maxspleen-3 && (available_amount($item[coffee pixie stick]) > 0 || item_amount($item[Game Grid token]) > 0)) {
				if (available_amount($item[coffee pixie stick]) == 0) {
					cli_execute("skeeball");
				}
				chew(1, $item[coffee pixie stick]);
			}
		}
		
		//If they have these, then check for spleen items that we have. 
		if (my_spleen_use() + (i_a("agua de vida") + i_a("coffee pixie stick") + i_a("Game Grid token") + i_a("Game Grid ticket")/10 + i_a("groose grease") + i_a("unconscious collective dream jar") + i_a("grim fairy tale") + i_a("powdered gold")) * 4 < maxspleen + 4) {
			print("Spleen: "+my_spleen_use()+" Agua: "+i_a("agua de vida")+" Stick: "+i_a("coffee pixie stick")+" Token: "+i_a("Game Grid token") + " Grease: " + i_a("groose grease") + " Dream Jar: " + i_a("unconscious collective dream jar") + " Fairy Tale: " + i_a("grim fairy tale") + " Powdered Gold: " + i_a("powdered gold"), "purple");
			print("Total Spleen: "+(my_spleen_use() + (i_a("agua de vida") + i_a("coffee pixie stick") + i_a("Game Grid token") + i_a("groose grease") + i_a("unconscious collective dream jar") + i_a("grim fairy tale") + i_a("powdered gold")) * 4), "purple");
			
			//Then we have space for some spleen items.
			//Manual checks. Rogue drops coinmaster tokens. Boots enable a combat skill which drops paste. Neither one directly drops spleen.
			foreach it in $familiars[Rogue Program, Pair of Stomping Boots] {
				if (have_path_familiar(it) && it.drops_today < it.drops_limit) return use_familiar(it);
			}

			//Future-proof spleen check.
			familiar spleener = $familiar[none];
			foreach it in $familiars[] {
				if (have_path_familiar(it) && it.drop_item.spleen > 0 && it.drops_today < it.drops_limit) spleener = it;
			}
			if (spleener != $familiar[none]) return use_familiar(spleener);
		}
	}
	
	//If we set a familiar as default, use it. 
	if (get_property("bcasc_defaultFamiliar") != "") {
		print("BCC: Setting the default familiar to your choice of '"+get_property("bcasc_defaultFamiliar")+"'.", "purple");
		return use_familiar(to_familiar(get_property("bcasc_defaultFamiliar")));
	}
	
	print("BCC: Using a default stat familiar.", "purple");
	//Now either we have neither of the above, or we have enough spleen today.
	foreach it in $familiars[Frumious Bandersnatch, Li'l Xenomorph, Smiling Rat, Blood-Faced Volleyball] {
		if (have_path_familiar(it)) return use_familiar(it);
	}
	return false;
}

boolean setMCD(int moxie, int sMox) {
	if (get_property("bcasc_disableMCD") == "true") return false;
	
	if (canMCD()) {
		print("BCC: We CAN set the MCD.", "purple");
		
		//We do. Check maxMCD value
		int maxmcd = 10;
		int mcdval = my_buffedstat(my_primestat()) - sMox;
		
		if (mcdval > maxmcd || !in_hardcore() || (bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) {
			mcdval = maxmcd;
		}
		cli_execute("mcd "+mcdval);
		return true;
	}
	return false;
}

//Thanks Rinn and Theraze!
boolean traverse_temple()
{
	betweenBattle();
	
	while(i_a("stone wool") != 0)
	{
		if (have_effect($effect[Stone-Faced]) == 0)
			use(1, $item[stone wool]);
		
		string page = visit_url("adventure.php?snarfblat=280");			
		if (!checkStage("nostril"))
		{
			if(i_a("nostril of the serpent") == 0)
			{
				set_property("choiceAdventure582", "1");
				runChoice(page);
				set_property("choiceAdventure579", "2");
				runChoice(page);
			}
			else
			{
				run_choice(2); // visit_url("choice.php?whichchoice=582&option=2&pwd");
				run_choice(2); // visit_url("choice.php?whichchoice=580&option=2&pwd");
				run_choice(4); // visit_url("choice.php?whichchoice=584&option=4&pwd");
				run_choice(1); // visit_url("choice.php?whichchoice=580&option=1&pwd");
				run_choice(2); // visit_url("choice.php?whichchoice=123&option=2&pwd");
				visit_url("choice.php");
				cli_execute("dvorak");
				run_choice(3); // visit_url("choice.php?whichchoice=125&option=3&pwd");
				checkStage("nostril", true);
				return true;
			}
		}
	}

	string page = visit_url("adventure.php?snarfblat=280");
	
	if (contains_text(page, "Combat"))
	{
		run_combat();
	}
	else if (contains_text(page, "Hidden Heart of the Hidden Temple"))
	{
		if(i_a("nostril of the serpent") < 1 || my_adventures() < 3)
		{
			set_property("choiceAdventure580", "1");
			runChoice(page);
		}
		else
		{
			run_choice(2); // visit_url("choice.php?whichchoice=580&option=2&pwd");
			run_choice(4); // visit_url("choice.php?whichchoice=584&option=4&pwd");
			run_choice(1); // visit_url("choice.php?whichchoice=580&option=1&pwd");
			run_choice(2); // visit_url("choice.php?whichchoice=123&option=2&pwd");
			visit_url("choice.php");
			cli_execute("dvorak");
			run_choice(3); // visit_url("choice.php?whichchoice=125&option=3&pwd");
			return true;
		}
	}
	else if (contains_text(page, "Such Great Heights"))
	{
		if(get_property("choiceAdventure579") != "2" && item_amount($item[the Nostril of the Serpent]) < 1)
		{
			set_property("choiceAdventure579", "2");
		}
		runChoice(page);
	}
	else if (contains_text(page, "Such Great Depths"))
	{
		if(get_property("choiceAdventure581") == "0")
		{
			set_property("choiceAdventure581", "2");
		}
		runChoice(page);
	}
	else
	{
		runChoice(page);
	}

	return false;
}

//Thanks, Rinn!
string tryBeerPong() {
	string page = visit_url("adventure.php?snarfblat=157");
	
	if (contains_text(page, "Combat")) {
		//The way I use this, we shouldn't ever have a combat with this script, but there's no harm in a check for a combat. 
		if ((numPirateInsults() < 8) && (contains_text(page, "Pirate"))) throw_item($item[The Big Book of Pirate Insults]);
		while(!page.contains_text("You win the fight!")) page = bumRunCombat();
	} else if (contains_text(page, "Arrr You Man Enough?")) {
		int totalInsults = numPirateInsults();
		if (totalInsults > 6) {
			print("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue");
			page = beerPong( visit_url( "choice.php?pwd&whichchoice=187&option=1" ) );
		} else {
			print("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue");
			print("Arrr You Man Enough?", "red");
			page = visit_url( "choice.php?pwd&whichchoice=187&option=2" );
		}
	} else if (contains_text(page, "Arrr You Man Enough?")) {
		//Doesn't this do just the same as above? Rinn has it like this, so I'll leave it like this for the moment. 
		page = beerPong(page);
	} else {
		page = runChoice(page);
	}

	return page;
}

monster whatShouldIFax() {
	if (my_adventures() == 0) return $monster[none]; // don't try and fax a monster if you have no adventures left to fight it
	if (get_property("bcasc_lastFax") == today_to_string() || get_property("_photocopyUsed") != "false") return $monster[none];
	if (get_property("bcasc_doNotFax") == true) return $monster[none];
	if (can_interact() && !bcasc_RunSCasHC) return $monster[none];
	if (my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Actually Ed the Undying") return $monster[none];
	if (item_amount($item[Clan VIP Lounge key]) == 0) return $monster[none];
	if (!contains_text(visit_url("clan_viplounge.php"), "faxmachine.gif")) return $monster[none];
	
	//Set p to be primestat as a shortcut.
	int p = my_buffedstat(my_primestat());
	if (my_primestat() == $stat[Mysticality]) p = p + 30;
	
	if (my_path() != "Bees Hate You" && my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris" && (i_a("Knob Goblin elite helm") == 0 || i_a("Knob Goblin elite polearm") == 0 || i_a("Knob Goblin elite pants") == 0)) {
		if (p > monster_attack($monster[Knob Goblin Elite Guard Captain])) return $monster[Knob Goblin Elite Guard Captain];
	}
	
	if (p > monster_attack($monster[lobsterfrogman])) {
		if (bcasc_doSideQuestBeach && i_a("barrel of gunpowder") < 5 && (get_property("sidequestLighthouseCompleted") == "none")) {
			return $monster[lobsterfrogman];
		}
	}
	return $monster[none];
}

boolean willMood() {
	return (!in_hardcore() || haveElite() || my_meat() > 5000 || my_mp() > 100 || my_path() == "Avatar of Jarlsberg");
}

void zapKeys() {
	if (item_amount($item[fat loot token]) > 0) {
		foreach i in $items[boris's key, jarlsberg's key, sneaky pete's key] {
			if (item_amount(i) == 0) {
				//buy($coinmaster[Vending Machine], 1, i);
				if(i == $item[boris's key])
					visit_url("shop.php?pwd&whichshop=damachine&action=buyitem&whichrow=93&bigform=Buy+Item&quantity=1");
				if(i == $item[jarlsberg's key])
					visit_url("shop.php?pwd&whichshop=damachine&action=buyitem&whichrow=94&bigform=Buy+Item&quantity=1");
				if(i == $item[sneaky pete's key])
					visit_url("shop.php?pwd&whichshop=damachine&action=buyitem&whichrow=95&bigform=Buy+Item&quantity=1");					
				return;
			}
		}
	}
	
	if (canZap()) {
		if (i_a("boris's ring") + i_a("jarlsberg's earring") + i_a("sneaky pete's breath spray") > 0 ) {
			print("BCC: Your wand is safe, so I'm going to try to zap something");
			if (i_a("boris's ring") > 0) { cli_execute("zap boris's ring"); 
			} else if (i_a("jarlsberg's earring") > 0) { cli_execute("zap jarlsberg's earring"); 
			} else if (i_a("sneaky pete's breath spray") > 0) { cli_execute("zap sneaky pete's breath spray"); 
			} else if (i_a("jarlsberg's key") > 1) { cli_execute("zap jarlsberg's key");  
			} else if (i_a("sneaky pete's key") > 1) { cli_execute("zap sneaky pete's key"); 
			} else if (i_a("boris's key") > 1) { cli_execute("zap boris's key");  
			}
		}
	} else {
		print("BCC: You don't have a wand, or it's not safe to use one. No Zapping for you.", "purple");
	}
}

/***********************************************
* BEGIN FUNCTIONS THAT RELY ON OTHER FUNCTIONS *
***********************************************/

void setMood(string combat) {
	if (get_property("bcasc_disableMoods") == "true") {
		cli_execute("mood apathetic");
		return;
	}

	cli_execute("mood bumcheekascend");
	defaultMood(combat == "");
	if (my_path() != "Avatar of Boris" && my_path() != "Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete" && my_path() != "Actually Ed the Undying") {
		if (contains_text(combat,"+")) {
			if (willMood()) {
				print("BCC: Need moar combat! WAAARGH!", "purple");
				if (have_skill($skill[Musk of the Moose]) && my_maxmp() > mp_cost($skill[Musk of the Moose]) * 2) cli_execute("trigger lose_effect, Musk of the Moose, cast 1 Musk of the Moose");
				if (have_skill($skill[Carlweather's Cantata of Confrontation]) && my_maxmp() > mp_cost($skill[Carlweather's Cantata of Confrontation]) * 2) cli_execute("trigger lose_effect, Carlweather's Cantata of Confrontation, cast 1 Carlweather's Cantata of Confrontation");
				if (have_skill($skill[Summon Horde]) && my_maxmp() > mp_cost($skill[Summon Horde]) * 2) cli_execute("trigger lose_effect, Waking the Dead, cast 1 Summon Minion");
				cli_execute("trigger gain_effect, The Sonata of Sneakiness, uneffect sonata of sneakiness");
			}
		} 
		if (contains_text(combat,"-")) {
			if (willMood()) {
				print("BCC: Need less combat, brave Sir Robin!", "purple");
				if (have_skill($skill[Smooth Movement]) && my_maxmp() > mp_cost($skill[Smooth Movement]) * 2) cli_execute("trigger lose_effect, Smooth Movements, cast 1 smooth movement");
				if (have_skill($skill[The Sonata of Sneakiness]) && my_maxmp() > mp_cost($skill[The Sonata of Sneakiness]) * 2) cli_execute("trigger lose_effect, The Sonata of Sneakiness, cast 1 sonata of sneakiness");
				if (have_skill($skill[Disquiet Riot]) && my_maxmp() > mp_cost($skill[Disquiet Riot]) * 2) cli_execute("trigger lose_effect, Disquiet Riot, cast 1 Disquiet Riot");
				cli_execute("trigger gain_effect, Carlweather's Cantata of Confrontation, uneffect Carlweather's Cantata of Confrontation");
			}
		}
		if (contains_text(combat,"i")) {
			if (willMood()) {
				print("BCC: Need items!", "purple");
				if (have_skill($skill[Fat Leon's Phat Loot Lyric]) && my_maxmp() > mp_cost($skill[Fat Leon's Phat Loot Lyric]) * 2) cli_execute("trigger lose_effect, Fat Leon's Phat Loot Lyric, cast 1 Fat Leon's Phat Loot Lyric");
				if (have_skill($skill[The Ballad of Richie Thingfinder]) && my_maxmp() > mp_cost($skill[The Ballad of Richie Thingfinder]) * 2) cli_execute("trigger lose_effect, The Ballad of Richie Thingfinder, cast 1 The Ballad of Richie Thingfinder");
				if (have_skill($skill[Leash of Linguini]) && my_maxmp() > mp_cost($skill[Leash of Linguini]) * 2) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
				if (bcasc_castEmpathy && have_skill($skill[Empathy of the Newt]) && my_maxmp() > mp_cost($skill[Empathy of the Newt]) * 2 && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
				if (have_skill($skill[Singer's Faithful Ocelot]) && my_maxmp() > mp_cost($skill[Singer's Faithful Ocelot]) * 2) cli_execute("trigger lose_effect, Singer's Faithful Ocelot, cast 1 Singer's Faithful Ocelot");
				if (have_skill($skill[Zombie Chow]) && have_path_familiar($familiar[Reagnimated Gnome]) && my_maxmp() > mp_cost($skill[Zombie Chow]) * 2) cli_execute("trigger lose_effect, Chow Downed, cast 1 Zombie Chow");
				if (have_skill($skill[Scavenge]) && my_maxmp() > mp_cost($skill[Scavenge]) * 2) cli_execute("trigger lose_effect, Scavengers Scavenging, cast 1 Scavenge");
				if (haveElite() && my_meat() > 3000) cli_execute("trigger lose_effect, Peeled Eyeballs, use 1 Knob Goblin eyedrops");
			}
		}
		if (contains_text(combat, "orchard")) {
			if (i_a("lavender candy hear") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[lavender candy heart]) > 0 && have_effect($effect[Heart of Lavender]) <= 1) {use(1, $item[lavender candy heart]);}");
			if (i_a("resolution: be happier") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[resolution: be happier]) > 0 && have_effect($effect[Joyful Resolve]) <= 1) {use(1, $item[resolution: be happier]);}");
			if (i_a("blue snowcone") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[blue snowcone]) > 0 && have_effect($effect[blue tongue]) <= 1 && have_effect($effect[red tongue]) == 0) {use(1, $item[blue snowcone]);}");
			if (have_skill($skill[Empathy of the Newt]) && my_maxmp() > mp_cost($skill[Empathy of the Newt]) * 2 && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
			if (i_a("green candy hear") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[green candy heart]) > 0 && have_effect($effect[Heart of Green]) <= 1) {use(1, $item[green candy heart]);}");
		}
		if (contains_text(combat,"n")) {
			if (willMood()) {
				print("BCC: Need initiative!", "purple");
				if (have_skill($skill[Springy Fusilli]) && my_maxmp() > mp_cost($skill[Springy Fusilli]) * 2) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
				if (have_skill($skill[Cletus's Canticle of Celerity]) && my_maxmp() > mp_cost($skill[Cletus's Canticle of Celerity]) * 2) cli_execute("trigger lose_effect, Cletus's Canticle of Celerity, cast 1 Cletus's Canticle of Celerity");
				if (have_skill($skill[Walberg's Dim Bulb]) && my_maxmp() > mp_cost($skill[Walberg's Dim Bulb]) * 2) cli_execute("trigger lose_effect, Walberg's Dim Bulb, cast 1 Walberg's Dim Bulb");
			}
		}
		if (contains_text(combat,"m")) {
			print("BCC: Need meat (this will always trigger)!", "purple");
			if (have_skill($skill[The Polka of Plenty]) && my_maxmp() > mp_cost($skill[The Polka of Plenty]) * 2) cli_execute("trigger lose_effect, Polka of Plenty, cast 1 The Polka of Plenty");
			if (have_skill($skill[The Ballad of Richie Thingfinder]) && my_maxmp() > mp_cost($skill[The Ballad of Richie Thingfinder]) * 2) cli_execute("trigger lose_effect, The Ballad of Richie Thingfinder, cast 1 The Ballad of Richie Thingfinder");
			if (have_skill($skill[Leash of Linguini]) && my_maxmp() > mp_cost($skill[Leash of Linguini]) * 2) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
			if (bcasc_castEmpathy && have_skill($skill[Empathy of the Newt]) && my_maxmp() > mp_cost($skill[Empathy of the Newt]) * 2 && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
		}
		if (contains_text(combat,"l")) {
			if (willMood()) {
				print("BCC: Need bigger monsters!", "purple");
				if (have_skill($skill[Ur-Kel's Aria of Annoyance]) && my_maxmp() > mp_cost($skill[Ur-Kel's Aria of Annoyance]) * 2) cli_execute("trigger lose_effect, Ur-Kel's Aria of Annoyance, cast 1 Ur-Kel's Aria of Annoyance");
				if (have_skill($skill[Drescher's Annoying Noise]) && my_maxmp() > mp_cost($skill[Drescher's Annoying Noise]) * 2) cli_execute("trigger lose_effect, Drescher's Annoying Noise, cast 1 Drescher's Annoying Noise");
			}
		} 
	} else if (my_path() == "Avatar of Boris") {
		// Since we can only have one song, checking in the order of best priority.
		// Assume non-combats will always save the most turns, followed by items, then combats
		// Trigger Accompaniment if no other song is required to get some benefit.
		// No check is currently made for ML song, as this could significantly increase combat difficulty.
		// Return once a song has been cast to prevent overwriting.
		if (contains_text(combat,"-")) {
			print("BCC: Need less combat, brave Sir Clancy!", "purple");
			if (have_skill($skill[Song of Solitude])) cli_execute("trigger lose_effect, Song of Solitude, cast 1 Song of Solitude");
		} else if (contains_text(combat,"i")) {
			print("BCC: Need items!", "purple");
			if (have_skill($skill[Song of Fortune])) cli_execute("trigger lose_effect, Song of Fortune, cast 1 Song of Fortune");
		} else if (contains_text(combat, "m")) {
			print("BCC: Need meat!", "purple");
			if (have_skill($skill[Song of Fortune])) cli_execute("trigger lose_effect, Song of Fortune, cast 1 Song of Fortune");			
		} else if (contains_text(combat,"+")) {
			print("BCC: Need moar combat! BATTLE!", "purple");
			if (have_skill($skill[Song of Battle])) cli_execute("trigger lose_effect, Song of Battle, cast 1 Song of Battle");
		// No other song was found, run song of Accompaniment to get some benefit from the song slot.
		} else if (have_skill($skill[Song of Accompaniment ])) {
			print("BCC: Need to run a song! Accompaniment chosen by default", "purple");
			cli_execute("trigger lose_effect, Song of Accompaniment , cast 1 Song of Accompaniment");
		}
	} else if (my_path() == "Avatar of Jarlsberg") {
		if (contains_text(combat,"-")) {
			print("BCC: Need less combat, hide behind chocolate!", "purple");
			if (have_skill($skill[Chocolatesphere])) cli_execute("trigger lose_effect, Chocolatesphere, cast 1 Chocolatesphere");
		} else if (contains_text(combat,"i")) {
			//Nothing for items?
		} else if (contains_text(combat, "m")) {
			//Nothing for meat?		
		} else if (contains_text(combat,"+")) {
			print("BCC: Need moar combat! Coffee it is!", "purple");
			if (have_skill($skill[Coffeesphere])) cli_execute("trigger lose_effect, Coffeesphere, cast 1 Coffeesphere");
		} else if (contains_text(combat, "l")) {
			print("BCC: These monsters are WEAK! Let's gristle them up!", "purple");
			if (have_skill($skill[Gristlesphere])) cli_execute("trigger lose_effect, Gristlesphere, cast 1 Gristlesphere");
		}
	} else if (my_path() == "Avatar of Sneaky Pete") {
		if (contains_text(combat, "-")) {
			print("BCC: Need less combat, let's rev our engine!", "purple");
			if (have_skill($skill[rev engine]) && get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler") cli_execute("trigger lose_effect, Muffled, cast 1 Rev Engine");
			print("BCC: Need less combat, Let's get Broody!", "purple");
			if (have_skill($skill[Brood])) cli_execute("trigger lose_effect, Brooding, cast 1 Brood");
			if (i_a($item[pile of ashes]) > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[pile of ashes]) > 0 && have_effect($effect[ashen]) == 0) {use(1, $item[pile of ashes]);}");
		}
		if (contains_text(combat, "+")) {
			print("BCC: Need more combat, let's rev our engine", "purple");
			if (have_skill($skill[rev engine]) && get_property("peteMotorbikeMuffler") == "Extra-Loud Muffler") cli_execute("trigger lose_effect, Unmuffled, cast 1 Rev Engine");
		}
		if (contains_text(combat, "i")) {
			print("BCC: Need more items!", "purple");
			if (have_skill($skill[Check Hair]) && my_maxmp() > mp_cost($skill[Check Hair]) * 2) cli_execute("trigger lose_effect, Of course it looks great, cast 1 Check Hair");
		}
		if (contains_text(combat, "m")) {
			print("BCC: Need more meat. Spending a turn to change intrinsic (currently not implemented).", "purple");
			//if (have_skill($skill[Check Mirror]) && my_audience() >= 20) use_skill(1, $skill[Check Mirror]);
		}
		if (contains_text(combat, "n")) {
			print("BCC: Need more initative!", "purple");
			if (have_skill($skill[Live Fast])) cli_execute("trigger lose_effect, Living Fast, cast 1 Live Fast");
		}
		if (contains_text(combat, "l")) {
			print("BCC: Need tougher monsters. These are too weak!", "purple");
			if (have_skill($skill[Biker Swagger])) cli_execute("trigger lose_effect, Biker Swagger, cast 1 Biker Swagger");
		}
	}
}

//Where is it best to level?
location level_location(int value) {
	location best = $location[The Haunted Pantry];
	int one;
	int two = safeMox(best);
	location preferred;
	switch(my_primestat()) {
		case $stat[Muscle]: preferred = $location[The Haunted Gallery];
		case $stat[Mysticality]: preferred = $location[The Haunted Bathroom];
		case $stat[Moxie]: preferred = $location[The Haunted Ballroom];
	}
	//my_buffedstat(my_primestat())
	if (value < 120 || !can_adv(preferred)) {
		foreach loc in $locations[The Sleazy Back Alley, The Haunted Pantry, The Outskirts of Cobb's Knob, The Spooky Forest, A Barroom Brawl, 8-Bit Realm, 
			The Bat Hole Entrance, Guano Junction, The Batrat and Ratbat Burrow, The Beanbat Chamber, Cobb's Knob Kitchens, Cobb's Knob Barracks, Cobb's Knob Treasury, 
			Cobb's Knob Harem, The Enormous Greater-Than Sign, The Dungeons of Doom, Itznotyerzitz Mine, The Black Forest, The Knob Shaft, Cobb's Knob Laboratory, Cobb's Knob Menagerie\, Level 1, 
			Cobb's Knob Menagerie\, Level 2, Cobb's Knob Menagerie\, Level 3, Hippy Camp, Frat House, The Obligatory Pirate's Cove, The Castle in the Clouds in the Sky (Basement), The Hole in the Sky, The Haunted Library, The Haunted Gallery, 
			The Haunted Ballroom, Inside the Palindome, Tower Ruins, The Oasis, The Upper Chamber, The Middle Chamber, Thugnderdome, 
			Outskirts of Camp Logging Camp, Camp Logging Camp, Post-Quest Bugbear Pens, The Bugbear Pen, The Degrassi Knoll Garage, The "Fun" House, 
			The Unquiet Garves, The VERY Unquiet Garves, The Goatlet, Lair of the Ninja Snowmen, The eXtreme Slope, Whitey's Grove, The Laugh Floor, 
			Infernal Rackets Backstage, Pandamonium Slums, The Valley of Rof L'm Fao, The Penultimate Fantasy Airship, The Road to the White Citadel, The Haunted Kitchen, The Haunted Conservatory, 
			The Haunted Billiards Room, The Haunted Bathroom, The Haunted Bedroom, The Icy Peak, Barrrney's Barrr, The F'c'le, The Poop Deck, Belowdecks]
		{
			if (can_adv(loc)) {
				one = safeMox(loc);
				if (one == 0 || (one < value && one > two)) {
					best = loc;
					two = safeMox(best);
				}
			}
		}
	} else {
		return preferred;
	}
	return best;
}

boolean levelMe(int sMox, boolean needBaseStat) {
	boolean canBallroom() {
		return (get_property("questM21Dance") == "finished");
	}

	boolean canBarr() {
		if (i_a("pirate fledges") > 0) return true;
		if (i_a("eyepatch") > 0 && i_a("swashbuckling pants") > 0 && i_a("stuffed shoulder parrot") > 0) return true;
		return false;
	}
	
	print("BCC: levelMe("+sMox+", "+to_string(needBaseStat)+") called.", "fuchsia");
	if (bcasc_ignoreSafeMoxInHardcore && needBaseStat == false) {
#		buMax();	// Don't maximize and waste server hits for no good reason.
		print("BCC: But we don't care about safe moxie so we won't bother.", "purple");
		return true;
	}		
	
	//In softcore/casual we'll always assume we're strong enough to wtfpwn everything. 
	if (!needBaseStat && !in_hardcore()) return true; 
	
	if (have_effect($effect[Beaten Up]) > 0) {
		cli_execute("uneffect beaten up");
	}
	if (have_effect($effect[Beaten Up]) > 0) { abort("BCC: Please cure beaten up"); }

	//Uneffect poisoning since it screws with the calculation of how many buffed stats I need to level
	if (have_effect(to_effect(436)) > 0 || have_effect(to_effect(284)) > 0 || have_effect(to_effect(283)) > 0 || 
			have_effect(to_effect(282)) > 0 || have_effect(to_effect(264)) > 0 || have_effect(to_effect(8)) > 0) {
		use(1, $item[anti-anti-antidote]);
	}
	if (have_effect(to_effect(436)) > 0 || have_effect(to_effect(284)) > 0 || have_effect(to_effect(283)) > 0 || 
			have_effect(to_effect(282)) > 0 || have_effect(to_effect(264)) > 0 || have_effect(to_effect(8)) > 0) {
		abort("BCC: Please cure your poisoning");
	}
	
	if (needBaseStat) {
		if (my_basestat(my_primestat()) >= sMox) return true;
		print("Need to Level up a bit to get at least "+sMox+" base Primestat", "fuchsia");
		buMax();
	} else {		
		//buMax();
		setMood("");
		cli_execute("mood execute");

		int extraMoxieNeeded = sMox - my_buffedstat(my_primestat());
		if (extraMoxieNeeded <= 0) return true;
		print("Need to Level up a bit to get at least "+sMox+" buffed Primestat. This means getting "+extraMoxieNeeded+" Primestat.", "fuchsia");
		sMox = my_basestat(my_primestat()) + extraMoxieNeeded;
		
		if (my_primestat() == $stat[Mysticality]) {
			//Don't level for buffed stat AT ALL above level 10
			if (my_level() >= 10) {
				print("BCC: But, we're a myst class and at or over level 10, so we won't bother with buffed stats.", "fuchsia");
				return true;
			}
			
			//Because of the lack of need of +mainstat, we'll only care if we need 20 or more. 
			extraMoxieNeeded = extraMoxieNeeded - 20;
			print("BCC: But, we're a myst class, so we don't really mind about safe moxie that much. We'll only try to get "+sMox+" instead.", "fuchsia");
			if (extraMoxieNeeded <= 0) return true;
		}
		
		if (my_path() == "Way of the Surprising Fist") {
			//Because of the lack of need of +mainstat, we'll only care if we need 20 or more. 
			extraMoxieNeeded = extraMoxieNeeded - 20 - (my_level() * 3);
			print("BCC: But, we're in a fist run, so we don't really mind about safe moxie that much. We'll only try to get "+sMox+" instead.", "fuchsia");
			if (extraMoxieNeeded <= 0) return true;
		}
	}
	cli_execute("goal clear; goal set "+sMox+" "+to_string(my_primestat()));
	
	location levelHere = level_location(my_buffedstat(my_primestat()));
	switch (my_primestat()) {
		case $stat[Muscle] :
			if (my_buffedstat($stat[Muscle]) < 120 || !can_adv($location[The Haunted Gallery])) {
				print("I need "+sMox+" base muscle (going levelling at "+levelHere+")", "fuchsia");
				if(to_boolean(get_property("bcasc_dontLevelInTemple")))
					abort("BCC: You want to handle levelling yourself.");
				else {
					setMood("");
					setFamiliar("");
					return bumMiniAdv(my_adventures(), levelHere);
				}
			} else {
				setMood("-");
				setFamiliar("");
				print("I need "+sMox+" base muscle (going to Gallery)", "fuchsia");
				set_property("choiceAdventure89","6"); // ignore maidens
				
				//Get as many clovers as possible. The !capture is so that it doesn't abort on failure. 
				print("BCC: Attempting to get clovers to level with. (Don't worry - if don't want to use them to level, we won't).", "purple");
				cloversAvailable();
				
				if (cloversAvailable() > 1 && get_property("bcasc_doNotCloversToLevel") != "true") {
					print("BCC: Going to use clovers to level.", "purple");
					//First, just quickly use all ten-leaf clovers we have. 
					if(my_path() != "Bees Hate you") {
						//First, just quickly use all ten-leaf clovers we have. 
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("use * ten-leaf clover");
						}
					
						while (my_basestat($stat[Muscle]) < sMox && item_amount($item[disassembled clover]) > 1) {
							if (my_adventures() == 0) abort("BCC: No Adventures to level. :(");
							print("BCC: We have "+item_amount($item[disassembled clover])+" clovers and are using one to level.", "purple");
							use(1, $item[disassembled clover]);
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=394");
						}
					} else {
						//Bees hate broken clovers so use the closet instead
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("closet put * ten-leaf clover");
						}
					
						while (my_basestat($stat[Muscle]) < sMox && closet_amount($item[ten-leaf clover]) > 1) {
							if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
							print("BCC: We have "+closet_amount($item[ten-leaf clover])+" clovers and are using one to level.", "purple");
							take_closet(1, $item[ten-leaf clover]);
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=394");
						}
					}	
				}
				if(my_basestat(my_primestat()) < sMox)
					return bumMiniAdv(my_adventures(), $location[The Haunted Gallery]);
			}
		break;
		
		case $stat[Mysticality] :
			if (my_buffedstat($stat[Mysticality]) < 80 || !can_adv($location[The Haunted Bathroom])) {
				print("I need "+sMox+" base Mysticality (going levelling at "+levelHere+")", "fuchsia");
				if(to_boolean(get_property("bcasc_dontLevelInTemple")))
					abort("BCC: You want to handle levelling yourself.");
				else {
					setMood("");
					setFamiliar("");
					return bumMiniAdv(my_adventures(), levelHere);
				}
			} else {
				setMood("-");
				setFamiliar("");
				print("I need "+sMox+" base Mysticality (going to Bathroom)", "fuchsia");
				
				//Get as many clovers as possible. The !capture is so that it doesn't abort on failure. 
				print("BCC: Attempting to get clovers to level with. (Don't worry - if don't want to use them to level, we won't).", "purple");
				cloversAvailable();
				
				set_property("choiceAdventure105","1");
				set_property("choiceAdventure402","2");
				if (cloversAvailable() > 1 && get_property("bcasc_doNotCloversToLevel") != "true") {
					print("BCC: Going to use clovers to level.", "purple");
					//First, just quickly use all ten-leaf clovers we have. 
					if(my_path() != "Bees Hate you") {
						//First, just quickly use all ten-leaf clovers we have. 
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("use * ten-leaf clover");
						}
					
						while (my_basestat($stat[Mysticality]) < sMox && item_amount($item[disassembled clover]) > 1) {
							if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
							print("BCC: We have "+item_amount($item[disassembled clover])+" clovers and are using one to level.", "purple");
							use(1, $item[disassembled clover]);
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=392");
						}
					}
					else {
						//Bees hate broken clovers so use the closet instead
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("closet put * ten-leaf clover");
						}
					
						while (my_basestat($stat[Mysticality]) < sMox && closet_amount($item[ten-leaf clover]) > 1) {
							if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
							print("BCC: We have "+closet_amount($item[ten-leaf clover])+" clovers and are using one to level.", "purple");
							take_closet(1, $item[ten-leaf clover]);
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=392");
						}
					}						
				}
				if(to_int(get_property("choiceAdventure105")) != 1)
					set_property("choiceAdventure105",1);
				if(my_basestat(my_primestat()) < sMox)
					return bumMiniAdv(my_adventures(), $location[The Haunted Bathroom]);
			}
		break;
		
		case $stat[Moxie] :
			if (my_buffedstat($stat[Moxie]) < 90 || my_basestat($stat[mysticality]) < 25 || (!canBarr() && !canBallroom())) {
				print("I need "+sMox+" base Moxie (going levelling at "+levelHere+")", "fuchsia");
				if(to_boolean(get_property("bcasc_dontLevelInTemple")))
					abort("BCC: You want to handle levelling yourself.");
				else {
					setMood("");
					setFamiliar("");
					return bumMiniAdv(my_adventures(), levelHere);
				}
			} else if (my_path() != "way of the surprising fist" && my_buffedstat($stat[Moxie]) < 120 && canBarr()) {
				setMood("-i");
				setFamiliar("");
				//There's pretty much zero chance we'll get here without the swashbuckling kit, so we'll be OK.
				if(i_a("pirate fledges") == 0 || my_basestat($stat[mysticality]) < 60)
					buMax("+outfit swashbuckling getup");
				else
					buMax("+equip pirate fledges");
				return bumMiniAdv(my_adventures(), $location[Barrrney's Barrr]);
			} else {
				setMood("-i");
				setFamiliar("itemsnc");
				print("I need "+sMox+" base moxie", "fuchsia");
				
				//Get as many clovers as possible. The !capture is so that it doesn't abort on failure. 
				print("BCC: Attempting to get clovers to level with. (Don't worry - if don't want to use them to level, we won't).", "purple");
				cloversAvailable();
				
				if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
				if (cloversAvailable() > 1 && get_property("bcasc_doNotCloversToLevel") != "true") {
					print("BCC: Going to use clovers to level.", "purple");
					if(my_path() != "Bees Hate you")
					{
						//First, just quickly use all ten-leaf clovers we have. 
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("use * ten-leaf clover");
						}
						while (my_basestat($stat[Moxie]) < sMox && item_amount($item[disassembled clover]) > 1) {
							if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
							print("BCC: We have "+item_amount($item[disassembled clover])+" clovers and are using one to level.", "purple");
							use(1, $item[disassembled clover]);
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=395");
						}
					}
					else
					{
						//Bees hate broken clovers so use the closet instead
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("closet put * ten-leaf clover");
						}
						while (my_basestat($stat[Moxie]) < sMox && closet_amount($item[ten-leaf clover]) > 1) {
							if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
							print("BCC: We have "+closet_amount($item[ten-leaf clover])+" clovers and are using one to level.", "purple");
							take_closet(1, $item[ten-leaf clover]);
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=395");
						}
					}
				}
			
				cli_execute("goal clear");
				setFamiliar("itemsnc");
				while (my_basestat($stat[Moxie]) < sMox) {
					if (my_adventures() == 0) abort("BCC: No Adventures to level :(");
					if ((my_buffedstat($stat[Moxie]) < 130) && canMCD() && !(bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) cli_execute("mcd 0");
					if (item_amount($item[dance card]) > 0) {
						use(1, $item[dance card]);
						bumMiniAdv(4, $location[The Haunted Ballroom]);
					} else {
						bumMiniAdv(1, $location[The Haunted Ballroom]);
					}
				}
				if(my_basestat($stat[Moxie]) < sMox) return true;
			}
		break;
	}
	return false;
}
boolean levelMe(int sMox) { return levelMe(sMox, false); }

boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat, string consultScript, int maxAdvs) {
	//Prepare food if appropriate. 
	omNomNom();
	
	int sMox = safeMox(loc);
	buMax(maxme, sMox);
	
	sellJunk();
	setFamiliar(famtype);
	//Make sure we use free runaways for the Stomping Boots if we are to try and run away, but not if we are trying for a 100% run
	if (consultScript == "consultRunaway" && bcasc_100familiar == "") {
		if (have_path_familiar($familiar[Pair of Stomping Boots]))
			use_familiar($familiar[Pair of Stomping Boots]);
		else if (have_path_familiar($familiar[Frumious Bandersnatch]))
			use_familiar($familiar[Frumious Bandersnatch]);
	}
	
	//First, we'll check the faxes. 
	monster f = whatShouldIFax();
	if (f != $monster[none]) {
		familiar old = my_familiar();
		print("BCC: We are going to fax a "+to_string(f), "purple");
		
		if (faxbot(f)) {
			set_property("bcasc_lastFax", today_to_string());
			if (f == $monster[rampaging adding machine]) abort("BCC: Can't fight the adding machine. Do this manually.");
			if (f == $monster[lobsterfrogman]) {setFamiliar("obtuseangel"); }
			//Have to do this rather than use() because otherwise, mafia fights immediately.
			visit_url("inv_use.php?pwd=&which=3&whichitem=4873");
			bumRunCombat((f == $monster[lobsterfrogman]) ? "consultObtuse" : "");
		} else {
			print("BCC: The monster faxing failed for some reason. Let's continue as normal though.", "purple");
		}
		use_familiar(old);
	} else {
		print("BCC: Nothing to fax according to whatShouldIFax", "purple");
	}
	
	//Do we have a HeBo, and are we blocked from using it by a 100% run? Have to do this first, because we re-set the goals below.
	if ((my_path() != "Bees Hate You") && (consultScript == "consultHeBo") && (my_familiar() != $familiar[He-Boulder]) && have_effect($effect[Everything Looks Yellow]) == 0) {
		if (contains_text(visit_url("campground.php?action=bookshelf"), "Summon Clip Art")) {
			if(i_a("unbearable light") == 0)
			{
				print("BCC: We are getting an unbearable light, which the script prefers to pumpkin bombs where possible.", "purple");
				cli_execute("make 1 unbearable light");
			}
		} else {
			print("BCC: We don't have the HeBo equipped, so we're either on a 100% run or you just don't have one. Trying a pumpkin bomb. If you have one, we'll use it.", "purple");
			if (get_campground()[$item[pumpkin]] > 0) {
				//Hit the pumpkin patch, but only pick pumpkins if we have pumpkins to pick
				visit_url("campground.php?action=garden&pwd="+my_hash());
			}
			
			//Have a quick check for a KGF first. 
			if (i_a("pumpkin bomb") == 0 && i_a("pumpkin") > 0 && i_a("knob goblin firecracker") == 0) {
				cli_execute("conditions clear; conditions set 1 knob goblin firecracker");
				adventure(my_adventures(), $location[The Outskirts of Cobb's Knob]);
			}
			
			if (((i_a("pumpkin") > 0 && i_a("knob goblin firecracker") > 0)) || i_a("pumpkin bomb") > 0) {
				if (i_a("pumpkin bomb") == 0) { cli_execute("make pumpkin bomb"); }
			}
			//That's it. It's just about getting a pumpkin bomb in your inventory. Nothing else.
		}
	}

	//We initially set the MCD to 0 just in case we had it turned on before. 
	if (my_adventures() == 0) { abort("BCC: No Adventures. How Sad."); }
	if (canMCD() && !(bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) cli_execute("mcd 0");
	
	cli_execute("trigger clear");
	setMood(combat);

	cli_execute("mood execute");
	
	if (my_buffedstat(my_primestat()) < sMox && !bcasc_ignoreSafeMoxInHardcore && loc != $location[The Haunted Bedroom])	{
		//Do something to get more moxie.
		print("Need to Level up a bit to get "+sMox+" Mainstat", "fuschia");
		levelMe(sMox);
		//In case levelMe changed our outfit and we really need something.
		if (maxme != "")
			buMax(maxme, sMox);
	}
	cli_execute("mood execute");

	if (length(printme) > 0) {
		print("BCC: "+printme, "purple");
	}
	
	//Goals must be set after trying to levelme()
	cli_execute("goal clear");
	if (length(goals) > 0) {
		print("BCC: Setting goals of '"+goals+"'...", "lime");
		string[int] split_goals = split_string(goals, ", ");
		for i from 0 to count(split_goals) - 1
		{
			if (!contains_text(split_goals[i], "+"))
				cli_execute("goal set "+split_goals[i]);
			else
				cli_execute("goal add " + split_goals[i]);
		}			
			
		split_goals = get_goals();
		if(count(split_goals) == 0) {
			print("BCC: All goals have already been met, moving on.", "lime");
			return true;
		}
		
	}
	
	//Finally, check for and use the MCD if we can. No need to do this in 
	if (my_buffedstat(my_primestat()) > sMox) {
		print("BCC: We should set the MCD if we can.", "purple");
		//Check if we have access to the MCD
		setMCD(my_buffedstat(my_primestat()), sMox);
	}
	//Force to 0 in Junkyard
	if (loc == $location[Next to that Barrel with Something Burning in it] || loc == $location[Near an Abandoned Refrigerator] || loc == $location[Over Where the Old Tires Are] || loc == $location[Out By that Rusted-Out Car]) {
		print("BCC: We're adventuring in the Junkyard. Let's turn the MCD down...", "purple");
		if (canMCD()) cli_execute("mcd 0");
	}
	//Force to correct MCD levels in Boss Bat, Knob King, and Bonerdagon
	int b, k, d;
	switch (my_primestat()) {
		case $stat[muscle]: b = 8; k = 0; d = 10; break;
		case $stat[mysticality]: b = 4; k = 3; d = 5; break;
		case $stat[moxie]: b = 4; k = 7; d = 10; break;
	}
	if (canMCD() && loc == $location[The Boss Bat's Lair]) { cli_execute("mcd "+b); }
	if (canMCD() && loc == $location[Throne Room] && k != 0) { cli_execute("mcd "+k); }
	if (canMCD() && loc == $location[Haert of the Cyrpt]) { cli_execute("mcd "+d); }
	
	int adventureThis = my_adventures();
	//If we set some given quantity of adventures, set this. 
	if (maxAdvs > 0) {
		adventureThis = maxAdvs;
	}
	
	if (can_interact()) {
		if (adventure(adventureThis, loc, "consultCasual")) {}
	} else if (consultScript != "") {
		if (adventure(adventureThis, loc, consultScript)) {}
	} else if (my_primestat() == $stat[Mysticality] && in_hardcore() && !get_property("bcasc_doMystAsCCS").to_boolean()) {
		if (adventure(adventureThis, loc, "consultMyst")) {}
	} else {
		if (adventure(adventureThis, loc)) {}
	}
	
	if(my_adventures() == 0)
		abort("BCC: No Adventures. How Sad.");
	else
		return true;
	return false; // Make the compiler happy...
}
boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat, string consultScript) { return bumAdv(loc, maxme, famtype, goals, printme, combat, consultScript, 0); }
boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat) { return bumAdv(loc, maxme, famtype, goals, printme, combat, ""); }
boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme) { return bumAdv(loc, maxme, famtype, goals, printme, ""); }
boolean bumAdv(location loc, string maxme, string famtype, string goals) { return bumAdv(loc, maxme, famtype, goals, ""); }
boolean bumAdv(location loc, string maxme, string famtype) { return bumAdv(loc, maxme, famtype, "", ""); }
boolean bumAdv(location loc, string maxme) { return bumAdv(loc, maxme, "", "", ""); }
boolean bumAdv(location loc) { return bumAdv(loc, "", "", "", ""); }

boolean bumUse(int n, item i) {
	if (n > item_amount(i)) n = item_amount(i);
	if (n > 0) return use(n, i);
	return false;
}

/**********************************
* START THE ADVENTURING FUNCTIONS *
**********************************/

boolean bcasc8Bit() {
	if (checkStage("8bit")) return true;
	if ((!in_hardcore() || can_interact()) && !bcasc_RunSCasHC) return checkStage("8bit", true);
	if (my_path() == "Bugbear Invasion") return false;
	if (!need_key($location[8-bit Realm])) { 	
		checkStage("8bit", true);
		return true;
	}

	//Guarantee that we have an equippable 1-handed ranged weapon.
	if (my_primestat() == $stat[Moxie] && npc_price($item[chewing gum on a string]) > 0) {
		while (i_a("disco ball") == 0) use(1, $item[chewing gum on a string]); 
	}
	
	//First, we have to make sure we have at least one-handed moxie weapon to do this with. 	
	if (i_a("continuum transfunctioner") == 0) {
		visit_url("place.php?whichplace=forestvillage&action=fv_mystic");
		if (my_path() != "Zombie Slayer") {
			visit_url("choice.php?pwd&whichchoice=664&option=1&choiceform1");
			visit_url("choice.php?pwd&whichchoice=664&option=1&choiceform1");
			visit_url("choice.php?pwd&whichchoice=664&option=1&choiceform1");
		}
	}
	bumAdv($location[8-bit realm], "+equip continuum transfunctioner +item drop", "items", "1 digital key", "Getting the digital key", "i");

	if (i_a("digital key") > 0) checkStage("8bit", true);
	return true;
}

boolean bcascAirship() {
	buffer page = visit_url("place.php?whichplace=plains");
	boolean planted = contains_text(page, "climb_beanstalk.gif");
	if (checkStage("airship")) return true;
	
	if (can_interact() && i_a("enchanted bean") == 0 && !planted) buy(1, $item[enchanted bean]);
	
	while (i_a("enchanted bean") == 0 && !planted)
		bumAdv($location[The Beanbat Chamber], "", "items", "1 enchanted bean", "Getting an Enchanted Bean");

	//Plant the bean ourselves in order to avoid problems with BHY runs (and potential future paths)
	if(!planted)
		page = visit_url("place.php?whichplace=plains&action=garbage_grounds");
	else if (my_path() == "Actually Ed the Undying")
		page = visit_url("place.php?whichplace=beanstalk");

	set_property("choiceAdventure182", "4");
	
	string airshipGoals = "1 metallic A, 1 S.O.C.K.";
	if (!in_hardcore() || my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Bugbear Invasion" || my_path() == "Zombie Slayer" || my_path() == "Actually Ed the Undying") airshipGoals = "1 S.O.C.K.";
	while (i_a("S.O.C.K") < 1) {
		if (have_effect($effect[temporary amnesia]) == 0) {
			bumAdv($location[The Penultimate Fantasy Airship], "", "itemsnc", airshipGoals, "Opening up the Castle by adventuring in the Airship", "-i");
		} else {
			if (my_hp() < 1) abort("BCC: You ran out of health while affected by Temporary Amnesia. Please restore some health or remember who you are before relaunching the script.");
			visit_url($location[The Penultimate Fantasy Airship].to_url()).runChoice();
			bumRunCombat();
		}
	}
	
	cli_execute("use * fantasy chest");
	if (i_a("S.O.C.K") == 1) {
		checkStage("airship", true);
		return true;
	}
	return false;
}

boolean bcascBats1() {
	string[int] clover_result;
	boolean stenchOK(){
		if (my_primestat() == $stat[mysticality]) {
			return elemental_resistance($element[stench]) > 5;
		}
		return elemental_resistance($element[stench]) > 0;
	}

	if (checkStage("bats1")) return true;
	if (use(3, $item[sonar-in-a-biscuit])) {}
	if (contains_text(visit_url("place.php?whichplace=bathole"), "bathole_4.gif")) {
		return checkStage("bats1", true);
	}
	//Guano
	if (!contains_text(visit_url("questlog.php?which=2"), "slain the Boss Bat")) {
		//There's no need to get the air freshener if you have the Stench Resist Skill
		if (!stenchOK()) {
			buMax("+1000 stench res");
			//Check it NOW (i.e. see if we have stench resistance at all, and try the exotic parrot if you don't.
			if(!stenchOK() && (bcasc_100familiar == "" || bcasc_100familiar.to_familiar() == $familiar[Exotic Parrot]) && have_path_familiar($familiar[Exotic Parrot])) {
				cli_execute("familiar parrot");
				buMax("+1000 familiar weight");
			}
			if (!stenchOK()) {
				foreach it,entry in maximize("stench res, -tie", 0, 0, true, false) {
					if (entry.score > 0 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) {
						use_skill(max(1, ceil(24 / turns_per_cast(entry.skill))), entry.skill);
						break;
					}
				}
			}
			//Check it NOW (i.e. see if we have stench resistance at all, and get an air freshener if you don't.
			if (!stenchOK()) {
				while (!have_skill($skill[Diminished Gag Reflex]) && (i_a("Pine-Fresh air freshener") == 0))
					bumAdv($location[The Bat Hole Entrance], "", "items", "1 Pine-Fresh air freshener", "Getting a pine-fresh air freshener.");
			}
			buMax("+1000 stench res");
			if (!stenchOK()) {
				print("There is some error getting stench resist - perhaps you don't have enough Myst to equip the air freshener? Please manually sort this out.", "red");
				return false;
			}
		}
		
		buMax("+1000 stench res");
		if (my_path() != "Bees Hate You") {
			while (item_amount($item[sonar-in-a-biscuit]) < 1 && !contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg4")) {
				//Let's use a clover if we can.
				if (i_a("sonar-in-a-biscuit") == 0 && cloversAvailable(true) > 0) {
					if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
					clover_result[0] = visit_url("adventure.php?snarfblat=31");
					if(!contains_text(clover_result[0], "but you see a few biscuits left over from whatever bizarre tea party")) {
						map_to_file(clover_result, "BCCDebug.txt");
						abort("BCC: There was a problem using your clover. Please try it manually.");
					}
				} else {
					bumAdv($location[Guano Junction], "+10stench res", "items", "1 sonar-in-a-biscuit", "Getting a Sonars");
				}
				if (cli_execute("use * sonar-in-a-biscuit")) {}
			}
			if (cli_execute("use * sonar-in-a-biscuit")) {}
		} else {
			//The screambat should show up every 8 turns, but make it 9 to account for potential bees
			if(contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg1")) {
				print("BCC: Hunting for the first screambat.");
				repeat {
					bumminiAdv(1, $location[Guano Junction], "");
				} until(last_monster() == $monster[screambat]);
			}
			if(contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg2")) {
				print("BCC: Hunting for a second screambat.");
				repeat {
					bumminiAdv(1, $location[The Batrat and Ratbat Burrow], "");
				} until(last_monster() == $monster[screambat]);
			}
			if(contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg3")) {
				print("BCC: Hunting for a third screambat.");
				repeat {
					bumminiAdv(1, $location[The Beanbat Chamber], "");
				} until(last_monster() == $monster[screambat]);
			}
		}
	}
		
	string bathole = visit_url("place.php?whichplace=bathole");
	if (contains_text(bathole, "bathole_bg4") || contains_text(bathole, "bathole_bg5")) {
		checkStage("bats1", true);
		return true;
	}
	return false;
}

boolean bcascBats2() {
	if (checkStage("bats2")) return true;
	if (!checkStage("bats1")) return false;
	while (index_of(visit_url("questlog.php?which=1"), "I Think I Smell a Bat") > 0) {
		if (!contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg4")) {
			cli_execute("set bcasc_stage_bats1 = 0");
			bcascBats1();
		}
		
		if (canMCD()) cli_execute("mcd 4");
		bumAdv($location[The Boss Bat's Lair], "", "meatbossbat", "1 batskin belt", "WTFPWNing the Boss Bat", "m");
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
	}
	checkStage("bats1", true);
	checkStage("bats2", true);
	return true;
}

//Declared as a global variable so it gets saved between function-calls
boolean checkme;
void bcascBugbearHunt() {
	if(!checkme) {
		use(1, $item[key-o-tron]);
		checkme = true;
	}
	print("BCC: Checking if we can hunt any new bugbears.", "purple");
	if (is_integer(get_property("statusWasteProcessing")) && my_adventures() > 0)
		bumAdv($location[The Sleazy Back Alley], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (3 - to_int(get_property("statusWasteProcessing"))) + " BURT", "BCC: Hunting for Scavenger bugbears.", "+");

	if (is_integer(get_property("statusMedbay")) && my_adventures() > 0)
		bumAdv($location[The Spooky Forest], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (3 - to_int(get_property("statusMedbay"))) + " BURT", "BCC: Hunting for Hypodermic bugbears.", "+");

	if (checkStage("bats1") && is_integer(get_property("statusSonar")) && my_adventures() > 0)
		bumAdv($location[The Beanbat Chamber], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (3 - to_int(get_property("statusSonar"))) + " BURT", "BCC: Hunting for batbugbears.", "+");

	if (checkStage("knobking") && is_integer(get_property("statusScienceLab")) && my_adventures() > 0)
		bumAdv($location[Cobb's Knob Laboratory], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (6 - to_int(get_property("statusScienceLab"))) + " BURT", "BCC: Hunting for bugbear scientists.", "+");

	if (checkStage("cyrpt") && is_integer(get_property("statusMorgue")) && my_adventures() > 0)
		bumAdv($location[The VERY Unquiet Garves], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (6 - to_int(get_property("statusMorgue"))) + " BURT", "BCC: Hunting for bugaboos.", "+");	

	if (is_equal_to(get_property("questL08Trapper"), "finished") && is_integer(get_property("statusSpecialOps")) && my_adventures() > 0)
		bumAdv($location[Lair of the Ninja Snowmen], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (6 - to_int(get_property("statusSpecialOps"))) + " BURT", "BCC: Hunting for Black Ops Bugbears.", "");

	if (checkStage("airship") && is_integer(get_property("statusEngineering")) && my_adventures() > 0)
		bumAdv($location[The Penultimate Fantasy Airship], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (9 - to_int(get_property("statusEngineering"))) + " BURT", "BCC: Hunting for Battlesuit Bugbear Types.", "");

	if (is_at_least(get_property("questM21Dance"), "step1")	&& is_integer(get_property("statusNavigation")) && my_adventures() > 0 && my_basestat(my_primestat()) > 90)
		bumAdv($location[The Haunted Gallery], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (9 - to_int(get_property("statusNavigation"))) + " BURT", "BCC: Hunting for ancient unspeakable bugbears.", "");		

	if (get_property("questL12War") == "finished" && is_integer(get_property("statusGalley")) && my_adventures() > 0) {
		if (bcasc_doWarAs == "frat")
			bumAdv($location[The Hippy Camp (Bombed Back to the Stone Age)], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (9 - to_int(get_property("statusGalley"))) + " BURT", "BCC: Hunting for trendy bugbear chefs.", "");
		else
			bumAdv($location[The Orcish Frat House (Bombed Back to the Stone Age)], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (9 - to_int(get_property("statusGalley"))) + " BURT", "BCC: Hunting for trendy bugbear chefs.", "");
	}
}

//To do: Make it check for the property lastEncounter to see if the area is done yet
void bcascBugbearShip() {
	string bugbearship = visit_url("place.php?whichplace=bugbearship");
	if (!contains_text(bugbearship, "Science Lab")) //If the Science lab is visible then the first floor is already done
	{
		//Medbay
		if(!checkStage("Medbay")) {
			buMax();
			setFamiliar("");
			print("BCC: Hunting for the robosurgeon.", "purple");
			while (to_string(last_monster()) != "bugbear robo-surgeon" && get_property("lastEncounter") != "Staph from the Staff") {
				bumminiAdv(1,$location[Medbay]);
			}
			checkStage("Medbay", true);
		}

		//Waste Processing
		if(!checkStage("WasteProcessing")) {
			buMax("items");
			while (i_a("bugbear communicator badge") == 0) {
				bumAdv($location[Waste Processing], "", "items", "1 handful of juicy garbage", "Hunting for juicy juicy garbage.", "i");
				use(item_amount($item[handful of juicy garbage]), $item[handful of juicy garbage]);
			}
			bumAdv($location[Waste Processing], "+equip bugbear communicator badge");
			if (get_property("lastEncounter") == "You're a Compactor Impacter!" || get_property("lastEncounter") == "Smell Bad!")
				checkStage("WasteProcessing", true);
		}

		//Sonar
		if (!checkStage("Sonar")) {
			string sonar_room;
			int index;
			int value1, value2, value3;
			buMax("");
			setMood("-");
			sonar_room = visit_url("adventure.php?snarfblat=283");
			while(!contains_text(sonar_room, "Sayonara, Sonar!")) {
				if(contains_text(sonar_room, "Combat"))
					run_combat();
				else if (!contains_text(sonar_room, "So Close and Yet So Nar")) {
					index = index_of(sonar_room, "name=pingvalue") + 28;
					value1 = to_int(char_at(sonar_room, index));
					index = index_of(sonar_room, "name=whurmvalue") + 29;
					value2 = to_int(char_at(sonar_room, index));
					index = index_of(sonar_room, "name=boomchuckvalue") + 33;
					value3 = to_int(char_at(sonar_room, index));
					if (value1 != 2)
						sonar_room = visit_url("choice.php?whichchoice=588&pwd&option=1&pingvalue=2&butt1=Set+Pinging+Machine");
					else if (value2 != 4)
						sonar_room = visit_url("choice.php?whichchoice=588&pwd&option=2&whurmvalue=4&butt2=Set+Whurming+Machine");
					else if (value3 != 8)
						sonar_room = visit_url("choice.php?whichchoice=588&pwd&option=3&boomchuckvalue=8&butt3=Set+Boomchucking+Machine");
					else
						checkStage("Sonar", true);
				}
				if(my_adventures() > 0) {
					betweenBattle();
					sonar_room = visit_url("adventure.php?snarfblat=283");
				} else
					abort("BCC: No adventures left to confuse the batbugbears.");
			}
			checkStage("Sonar", true);
		}
	} else {
		checkStage("Medbay", true);
		checkStage("WasteProcessing", true);
		checkStage("Sonar", true);
	}
	
	bugbearship = visit_url("place.php?whichplace=bugbearship");
	if (!contains_text(bugbearship, "Engineering")) //If Engineering is visible then the second floor is already done
	{
		//Science Lab
		if (!checkStage("ScienceLab")) {
			buMax("items");
			bumAdv($location[Science Lab], "", "items", "", "Silencing bugbear scientists.", "i", "consultBugbear");
			checkStage("ScienceLab", true);
		}

		//Morgue
		if (!checkStage("Morgue")) {
			buMax("items");
			set_property("choiceAdventure589", 6);
			bumAdv($location[Morgue], "", "items", "5 bugbear autopsy tweezers", "Gathering autopsy tweezers.", "+i");
			buMax();
			if (get_property("lastEncounter") != "Operation Successful, Patient Still Deceased") {
				for i from 1 to 5 {
					set_property("choiceAdventure589", i);
					bumAdv($location[Morgue], "", "", "1 choiceadv", "Removing limbs.", "-");
				}
			}
			while (get_property("lastEncounter") != "Operation Successful, Patient Still Deceased")
				bumMiniAdv(1, $location[Morgue]); //One last adventure to mark it as complete, account for wandering monsters
			checkStage("Morgue", true);
		}
						
		//Special Ops
		if (!checkStage("SpecialOps")) {
			string specialops;
			if (i_a("UV monocular") == 0) {
				if (i_a("BURT") >= 50)
					retrieve_item(1, $item[UV monocular]);
				else
					abort("BCC: You don't have enough BURT (Reynolds). Please farm until you have 50 and can get a UV monocular");
			}
			if (i_a("UV monocular") > 0) {
				buMax("");
				specialops = visit_url("adventure.php?snarfblat=283");
				if (i_a("flaregun") > 0 && contains_text(specialops, "Shoot a flare")) {
					set_property("choiceAdventure590", 2);
					print("BCC: Shooting a flare into the darkness.");
				} else {
					set_property("choiceAdventure590", 1);
					print("BCC: No flare available. Adventuring once before automating.");
				}
				runChoice(specialops);
				set_property("choiceAdventure590", 1);
				bumAdv($location[Special Ops], "+equip UV monocular", "", "", "BCC: Hunting for Black Ops bugbears.", "+");
			}
			checkStage("SpecialOps", true);
		}
	} else {
		checkStage("ScienceLab", true);
		checkStage("Morgue", true);
		checkStage("SpecialOps", true);
	}
	
	bugbearship = visit_url("place.php?whichplace=bugbearship");
	if (contains_text(bugbearship, "Engineering")) {
		//Engineering
		if (!checkStage("Engineering")) {
			buMax("items");
			bumAdv($location[Engineering], "", "items", "", "Destroying Liquid metal bugbears.", "i", "consultBugbear");
			checkStage("Engineering", true);
		}
		
		//Navigation
		if (!checkStage("Navigation")) {
			buMax();
			setFamiliar("");	
			while (get_property("lastEncounter") != "The Water Cooler of Madness" && get_property("lastEncounter") != "Out of N-Space") {
				while(have_effect($effect[N-Spatial vision]) == 0 && get_property("lastEncounter") != "The Water Cooler of Madness" && get_property("lastEncounter") != "Out of N-Space")
					bumMiniAdv(1, $location[Navigation]);
				if(have_effect($effect[N-Spatial vision]) > 0) {
					//if (have_skill($skill[disco power nap]))
					//	use_skill(1, $skill[disco power nap]);
					//else
					if (i_a("bugbear purification pill") > 0)
						use(1, $item[bugbear purification pill]);
					else if (i_a("soft green echo eyedrop antidote") > 0)
						use(1, $item[soft green echo eyedrop antidote]);
					else {
						checkStage("Navigation", true);
						abort("BCC: Unable to remove N-Spatial vision, please handle the Navigation room yourself. The script will continue as if you had when restarted.");
					}
				}
			}
			checkStage("Navigation", true);
		}		
		
		//Galley
		if (!checkStage("Galley")) {
			//buMax();
			//bumadv($location[Galley], "", "", "", "Fighting angry cavebugbears, this might be problematic.");
			checkStage("Galley", true);
			abort("BCC: The Galley is left as an exercise of the user due to the scaling monsters.");
		}
	} else
		abort("BCC: Something went wrong opening the third floor. Please handle the second floor manually and rerun the script.");
}

boolean bcascCastle() {
	if (checkStage("castle")) return true;

	void setCastleChoices() {
		if(i_a("drum 'n' bass 'n' drum 'n' bass record") > 0)
			set_property("choiceAdventure675", 2);
		else
			set_property("choiceAdventure675", 4);
		set_property("choiceAdventure676", 3);
		if(i_a("model airship") != 0)
			set_property("choiceAdventure677", 1);
		else
			set_property("choiceAdventure677", 2);
		set_property("choiceAdventure678", 4);
		set_property("choiceAdventure679", 1);
		set_property("choiceAdventure680", 1);
	}

	int checkFloor() {
#		string result = visit_url("adventure.php?snarfblat=324");
#		if(contains_text(result, "You have to learn to walk before you can learn to fly."))
#			return 0;
#		else if (contains_text(result, "You'll have to figure out some other way to get upstairs."))
#			return 1;
#		else {
#			setCastleChoices();
#			bumRunCombat();
#			return 2;
#		}
		if (get_property("lastCastleTopUnlock") == my_ascensions()) return 2;
		else if (get_property("lastCastleGroundUnlock") == my_ascensions()) return 1;
		else return 0;
	}
	
	int level;
	if(contains_text(visit_url("questlog.php?which=1"), "The Rain on the Plains is Mainly Garbage"))
		level = checkFloor();
	else if (in_hardcore() && my_path() != "Bugbear Invasion" && i_a("steam-powered model rocketship") == 0)
		level = 3;
	else
		level = 4;
		
	if(level == 0) {
		setMood("-");
		setFamiliar("");		
		
		if(i_a("amulet of extreme plot significance") > 0 || (i_a("titanium assault umbrella") > 0 && my_path() != "Avatar of Boris" && my_path() != "Way of the Surprising Fist" && my_path() != "Nuclear Autumn")) {
			set_property("choiceAdventure669", 1);
			set_property("choiceAdventure670", 4);
			set_property("choiceAdventure671", 4);
			
			if(i_a("amulet of extreme plot significance") > 0 && i_a("titanium assault umbrella") > 0 && my_path() != "Avatar of Boris" && my_path() != "Way of the Surprising Fist" && my_path() != "Nuclear Autumn") {
				buMax("+equip amulet of extreme plot significance, +equip titanium assault umbrella, +melee");
				print("BCC: Opening up the Ground Floor (both special items).", "purple");
				while(!contains_text(get_property("lastEncounter"), "The Fast and the Furry-ous") && !contains_text(get_property("lastEncounter"), "You Don't Mess Around with Gym") && !contains_text(get_property("lastEncounter"), "Arise!"))
					bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
				level = 1;
			} else if (i_a("titanium assault umbrella") > 0 && my_path() != "Avatar of Boris" && my_path() != "Way of the Surprising Fist" && my_path() != "Nuclear Autumn") {
				buMax("+equip titanium assault umbrella, +melee");
				print("BCC: Opening up the Ground Floor (titanium umbrella).", "purple");
				while(!contains_text(get_property("lastEncounter"), "The Fast and the Furry-ous") && !contains_text(get_property("lastEncounter"), "Arise!"))
					bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
				level = 1;					
			} else {
				buMax("+equip amulet of extreme plot significance");
				print("BCC: Opening up the Ground Floor (amulet of plot significance).", "purple");
				while(!contains_text(get_property("lastEncounter"), "You Don't Mess Around with Gym") && !contains_text(get_property("lastEncounter"), "Arise!"))
					bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
				level = 1;
			}
		} else {
			set_property("choiceAdventure669", 1);
			set_property("choiceAdventure670", 1);
			set_property("choiceAdventure671", 4);
			if(i_a("massive dumbbell") == 0)
				bumAdv($location[The Castle in the Clouds in the Sky (Basement)], "item", "itemsnc", "1 choiceadv", "Getting a Massive Dumbbell", "-i");
			
			set_property("choiceAdventure669", 1);
			set_property("choiceAdventure670", 1);
			set_property("choiceAdventure671", 1);
			while(!contains_text(get_property("lastEncounter"), "Out in the Open Source") && !contains_text(get_property("lastEncounter"), "Arise!"))
				bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
			cli_execute("refresh inv"); //Mafia does not remove the dumbbell yet
			level = 1;
		}
	}
	buMax();
	if(level == 1) {
		set_property("choiceAdventure672", 3);
		set_property("choiceAdventure673", 3);
		set_property("choiceAdventure674", 3);
		set_property("choiceAdventure1026", 2);
		print("BCC: Opening up the Top Floor (it's going to take 11 turns)", "purple");
		while(!contains_text(get_property("lastEncounter"), "Top of the Castle, Ma"))
			bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Ground Floor)]);
		level = 2;
	}
	if (level == 2) {
		while(get_property("lastEncounter") != "Are you a Man or a Mouse?" && get_property("lastEncounter") != "Keep On Turnin' the Wheel in the Sky") {
			setCastleChoices();
			bumAdv($location[The Castle in the Clouds in the Sky (Top Floor)], "", "itemsnc", "1 choiceadv", "Finishing the quest (any way we can)", "-");
		}
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());

		if(in_hardcore() && my_path() != "Bugbear Invasion" && i_a("steam-powered model rocketship") == 0)
			level = 3;
	}
	if (level == 3) {
			set_property("choiceAdventure675", 4);
			set_property("choiceAdventure676", 3);
			set_property("choiceAdventure677", 2);
			set_property("choiceAdventure678", 2);
			bumAdv($location[The Castle in the Clouds in the Sky (Top Floor)], "", "itemsnc", "steam-powered model rocketship", "Picking up a steam-powered model rocketship to open up the Hole in the Sky", "-");
	}
	
	checkStage("castle", true);
	return true;
}

boolean bcascChasm() {
	if (checkStage("chasm")) return true;
	
	int needLowercaseN() {
		int result = 1;
		for i from 2 to 7 {
			if (get_property("telescope" + i) == "see what appears to be the North Pole") {
				result = result + 1;
				break;
			}
		}
		if (!in_hardcore() || my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Bugbear Invasion" || my_path() == "Zombie Slayer" || my_path() == "Actually Ed the Undying") result = result - 1;
		if (i_a("lowercase N") >= 1) result = result - i_a("lowercase N");
		
		return result;
	}

	if (my_path() == "Actually Ed the Undying" && is_equal_to(get_property("questL09Topping"), "started")) {
		visit_url("place.php?whichplace=orc_chasm");
		visit_url("place.php?whichplace=orc_chasm&action=bridge_done");
		bumRunCombat();
	}

	buffer chasm;
	if (to_int(get_property("chasmBridgeProgress")) < 30) {
		if ((i_a("dictionary") == 0 && is_not_yet(get_property("questM15Lol"), "finished")) && checkStage("piratefledges") && index_of(visit_url("place.php?whichplace=orc_chasm"), "cross_chasm.gif") == -1) {
			cli_execute("outfit swashbuckling getup");
			cli_execute("buy 1 abridged dictionary");
			
			print("BCC: Using the dictionary.", "purple");

			if (is_not_yet(get_property("questM01Untinker"), "finished"))
				cli_execute("untinker");
			cli_execute("untinker abridged dictionary");
		}

		if(i_a("smut orc keepsake box") > 0)
			use(item_amount($item[smut orc keepsake box]), $item[smut orc keepsake box]);	
		
		//Update Mafia's internal variable for the bridge
		if (to_int(get_property("lastChasmReset")) != my_ascensions())
			chasm = visit_url("place.php?whichplace=orc_chasm");
		//Disassemble the bridge and use all parts we have
		chasm = visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		
		//Prepare for adventuring
		buMax("item");
		setFamiliar("items");
		setMood("i");
		
		//Finish buliding the bridge
		while (to_int(get_property("chasmBridgeProgress")) < 30) {
			bumMiniAdv(1, $location[The Smut Orc Logging Camp]);
			if(i_a("smut orc keepsake box") > 0)
				use(item_amount($item[smut orc keepsake box]), $item[smut orc keepsake box]);		
			chasm = visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		}
	}

	//Adventure in the different peaks
	//Update the quest status
	chasm = visit_url("place.php?whichplace=highlands&action=highlands_dude");

	//A-boo Peak - Kill ghosts until you can light the pyre
	while(!contains_text(visit_url("place.php?whichplace=highlands"), "fire1.gif")) {
		bumAdv($location[A-boo peak], "item, +10 elemental damage, -spooky damage", "items", "1 A-Boo clue", "Getting a clue", "i");
		if (get_property("lastEncounter") == "Come On Ghosty, Light My Pyre") {
			checkStage("aboopeak", true);
			break;
		}
		//TODO: Add some cheap/easily accesible +HP and +res consumables
		maximize("hp", false);
		maximize("spooky resistance, cold resistance, " + ((bcasc_100familiar == "" || bcasc_100familiar.to_familiar() == $familiar[Exotic Parrot]) && have_path_familiar($familiar[exotic parrot]) ? "switch exotic parrot" : "") + " +current -tie", false);
		if (have_effect($effect[elemental saucesphere]) == 0 && have_skill($skill[elemental saucesphere])) use_skill(1, $skill[elemental saucesphere]);
		if (have_effect($effect[astral shell]) == 0 && have_skill($skill[astral shell]) && have_castitems($class[turtle tamer], true)) use_skill(1, $skill[astral shell]);
		restore_hp(my_maxhp());
		use(1, $item[ A-Boo clue]);
		chasm = visit_url("adventure.php?snarfblat=296");
		if (contains_text(chasm, "name=whichchoice value=943")) {
			run_choice(1);
		} else if (contains_text(chasm, "Have it Gone")) {
			run_choice(1);
		} else if (contains_text(chasm, "choice.php")) {
			chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Talk+to+the+Ghosts");
			if (have_effect($effect[beaten up]) == 0)
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Try+to+Talk+Some+Sense+into+Them");
			if (have_effect($effect[beaten up]) == 0)
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Make+a+Suggestion");
			if (have_effect($effect[beaten up]) == 0)
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Take+Command");
			if (have_effect($effect[beaten up]) == 0)
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Join+the+Conversation");
		} else {
			bumRunCombat();	//In case a holiday monster or similar screws up the using of the clue
		}
	}
	//If we've arrived here we should've finished the stage
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire1.gif") && !checkStage("aboopeak"))
		checkStage("aboopeak", true);

	//The Oil Peak - Kill oil monsters to lower the preassure, raised ML makes this go faster (TODO: Possibly add way of allowing +ML here)
	if (!checkStage("oilpeak") && !contains_text(visit_url("place.php?whichplace=highlands"), "fire3.gif")) {
		bumAdv($location[oil peak], "", (bcasc_AllowML ? "ml" : ""), "", "Lowering the oil pressure", "l");
		if (get_property("lastEncounter") == "Unimpressed with Pressure")
			checkStage("oilpeak", true);
	}
	//If we've arrived here we should've finished the stage
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire3.gif") && !checkStage("oilpeak"))
		checkStage("oilpeak", true);		

	if (!checkStage("twinpeak") && !contains_text(visit_url("place.php?whichplace=highlands"), "fire2.gif")) {
		boolean loop = true;
		//Twin peak (hedge trimmers and ChoiceAdv606)
		if(my_path() != "Bees Hate You") {
			if ((get_property("twinPeakProgress").to_int() & (1 << 1)) == 0) { // Food drop - choice 2
				setFamiliar("nothing");
				buMax("item, food drop");
				setMood((my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Actually Ed the Undying" ? "i" : "-i"));
				cli_execute("mood execute");
				betweenBattle();
				string[int] perform;
				float sum;
				int j;
				int itempenalty = 0;
				if (my_path() == "Avatar of Jarlsberg" && my_companion() == "Eggman") {
					if (have_skill($skill[Working Lunch])) itempenalty = 75;
					else itempenalty = 50;
				} else if (my_path() == "Avatar of Boris" && minstrel_instrument() == $item[Clancy's lute]) {
					itempenalty = (55*5*minstrel_level())**.5+((minstrel_level()*5)-3);
				}
				if (to_int(item_drop_modifier() + numeric_modifier("food drop") - itempenalty) < 50) {
					foreach i, rec in maximize("item, food drop", 0, (can_interact() ? 1 : 0), true, true) {
						if(rec.score > 0) {
							perform[j] = rec.command;
							sum = sum + rec.score;
							j += 1;
						}
					}
					if(sum > 50.0) {
						for i from 0 to count(perform) - 1 {
							cli_execute(perform[i]);
							if(item_drop_modifier() + numeric_modifier("food drop") - itempenalty > 50.0)
								break;
						}
					}
				}
				if (to_int(item_drop_modifier() + numeric_modifier("food drop") - itempenalty) < 50) {
					abort("BCC: Unable to buff food drops to at least +50. Please do the item-choice (Search the pantry) yourself, the script will move on to the next step when you rerun it.");
				}
				setFamiliar("items");

				while(loop) {
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "name=whichchoice value=943")) {
						run_choice(1);
					} else if (contains_text(chasm, "Synecdoche")) {
						run_choice(1);
					} else if (contains_text(chasm, "name=whichchoice value=604")) {
						run_choice(1); // chasm = visit_url("choice.php?pwd&whichchoice=604&option=1&choiceform1=Continue...");
						run_choice(1); // chasm = visit_url("choice.php?pwd&whichchoice=604&option=1&choiceform1=Everything+goes+black.");
					} else if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0) {
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
				run_choice(2); // visit_url("choice.php?pwd&whichchoice=606&option=2&choiceform2=Search+the+pantry");	//Needs +50% item (no familiar)
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=608&option=1&choiceform1=Search+the+shelves");
				//The hedge trimmer is removed, but Mafia is unaware
				if (trimmers) cli_execute("refresh inv");
			}

			if ((get_property("twinPeakProgress").to_int() & (1 << 0)) == 0) { // Stench resistance - choice 1
				if (elemental_resistance($element[stench]) / 10 < 4) {
					if(!get_res($element[stench], 4, true)) {
						abort("BCC: Unable to buff stench resistance high enough. Please do the stench-choice (Room 237) yourself, the script will move on to the next step when you rerun it.");
					}
				}
				betweenBattle();
				loop = true;
				while(loop == true) {
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "name=whichchoice value=943")) {
						run_choice(1);
					} else if (contains_text(chasm, "Synecdoche")) {
						run_choice(1);
					} else if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
					if(elemental_resistance($element[stench]) / 10 < 4 && !get_res($element[stench], 4, true)) {
						abort("BCC: Your stench buffs have run out. Please do the stench part of the Twin Peaks manually and rerun the script.");
					}	
				}	
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0) {
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=606&option=1&choiceform1=Investigate+Room+237");	//Needs 4 stench res or more
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=607&option=1&choiceform1=Carefully+inspect+the+body");
				//The hedge trimmer is removed, but Mafia is unaware
				if (trimmers) cli_execute("refresh inv");
			}

			if ((get_property("twinPeakProgress").to_int() & (1 << 2)) == 0) { // Oily item - choice 3
				if(i_a("bubblin' crude") >= 12 && i_a("jar of oil") == 0)
					cli_execute("create 1 jar of oil");	
				else if(i_a("bubblin' crude") < 12 && i_a("jar of oil") == 0) {
					bumAdv($location[oil peak], "item", "items", "12 bubblin' crude", "Creating a jar of oil", "i");
					cli_execute("create 1 jar of oil");	
				}
				setMood("-i");
				cli_execute("mood execute");
				loop = true;
				while(loop == true) {
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "name=whichchoice value=943")) {
						run_choice(1);
					} else if (contains_text(chasm, "Synecdoche")) {
						run_choice(1);
					} else if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}	
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0) {
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
				run_choice(3); // visit_url("choice.php?pwd&whichchoice=606&option=3&choiceform3=Follow+the+faint+sound+of+music");
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=609&option=1&choiceform1=Examine+the+painting");
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=616&option=1&choiceform1=Mingle");
				//The hedge trimmer is removed, but Mafia is unaware
				if (trimmers) cli_execute("refresh inv");
			}

			if (get_property("twinPeakProgress").to_int() == 7) { // Initiative - choice 4
				buMax("initiative");	//Need +init to be 40% or more
				if (boolean_modifier("Four Songs") || boolean_modifier("Additional Song"))
					setMood("-in");
				else
					setMood("-n");
				cli_execute("mood execute");
				string[int] perform;
				float sum;
				int j;
				if (numeric_modifier("initiative") < 40) {
					foreach i, rec in maximize("initiative", 0, (can_interact() ? 1 : 0), true, true) {
						if(rec.score > 0) {
							perform[j] = rec.command;
							sum = sum + rec.score;
							j += 1;
						}
					}
				}
				if(sum > 40.0) {
					for i from 0 to count(perform) - 1 {
						cli_execute(perform[i]);
						if(numeric_modifier("initiative") > 40.0)
							break;
					}
				}
				if (numeric_modifier("initiative") < 40) {
					abort("BCC: Unable to buff initiative high enough. Please do the initiative-choice (should be the only available option) yourself, the script will move on to the next step when you rerun it.");
				}
				loop = true;
				while(loop == true) {
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "name=whichchoice value=943")) {
						run_choice(1);
					} else if (contains_text(chasm, "Synecdoche")) {
						run_choice(1);
					} else if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}
					//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0) {
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
				run_choice(4); // visit_url("choice.php?pwd&whichchoice=606&option=4&choiceform4=Wait+--+who%27s+that%3F");
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=610&option=1&choiceform1=Pursue+your+double");
				run_choice(1); // visit_url("choice.php?pwd&whichchoice=617&option=1&choiceform1=And+then...");
				run_choice(1);
				//The hedge trimmer is removed, but Mafia is unaware
				if (trimmers) cli_execute("refresh inv");
			}
			if(i_a("gold wedding ring") > 0)
				checkStage("twinpeak", true);
			else
				abort("BCC: Something went wrong while going through the Twin Peak. Please check for yourself.");
		} else {
			//abort("BCC: The bees make you unable to use oil thingies. Please run the peak yourself and burn the shit down.");
			set_property("choiceAdventure606", 6);
			set_property("choiceAdventure618", 2);
			bumAdv($location[twin peak], "", "", "", "We are going to burn down this beeloving mansion!", "+");
		}
	}
	//If we've arrived here we should've finished the stage
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire2.gif") && !checkStage("twinpeak"))
		checkStage("twinpeak", true);	
	//Let's get our reward
	chasm = visit_url("place.php?whichplace=highlands&action=highlands_dude");
	
	if ((get_property("bcasc_ROFL") == "true" && is_not_yet(get_property("questM15Lol"), "finished")) || needLowercaseN() > 0) {
		if (get_property("bcasc_ROFL") == "true") {
			while (contains_text(visit_url("questlog.php?which=1"), "A Quest, LOL")) {
				if (index_of(visit_url("questlog.php?which=1"), "The Highland Lord told you that the Baron Rof L'm Fao") > 0) {
					if (can_interact()) {
						buy(1, $item[668 scroll]);
						buy(1, $item[64067 scroll]);
					}
				
					cli_execute("set addingScrolls = 1");
					if (i_a("64735 scroll") == 0 || needLowercaseN() > 0) {
						bumAdv($location[The Valley of Rof L'm Fao], "", "items", "1 64735 scroll, " + needLowercaseN() + " lowercase N", "Get me the 64735 Scroll", "i");
					} else if (i_a("64735 scroll") == 0) {
						bumAdv($location[The Valley of Rof L'm Fao], "", "items", "1 64735 scroll", "Get me the 64735 Scroll", "i");
					}
					if (cli_execute("use 64735 scroll")) {}
				} else {
					abort("BCC: For some reason we haven't bridged the chasm.");
				}
			}
		}
		else {
			bumAdv($location[The Valley of Rof L'm Fao], "item", "items", needLowercaseN() + " lowercase N", "Gathering some lowercase n.", "i");
		}
	}

	if (checkStage("aboopeak") && checkStage("oilpeak") && checkStage("twinpeak") && !(get_property("bcasc_ROFL") == "true" && is_not_yet(get_property("questM15Lol"), "finished"))) {
		checkStage("chasm", true);
		return true;
	}
	return false;
}

boolean bcascCyrpt() {
	boolean stageDone(string name) {
		if (get_revision() < 9260 && get_revision() > 0) abort("BCC: You need to update your Mafia to handle the cyrpt. A revision of at least 9260 is required. This script is only ever supported for a latest daily build.");
		print("The "+name+" is at "+get_property("cyrpt"+name+"Evilness")+"/50 Evilness...", "purple");
		return (get_property("cyrpt"+name+"Evilness") < 1);
	}
	
	if (checkStage("cyrpt")) return true;
	
	if (!contains_text(visit_url("questlog.php?which=2"), "defeated the Bonerdagon")) {
		set_property("choiceAdventure523", "4");
		if(to_int(get_property("choiceAdventure155")) == 4) set_property("choiceAdventure155", 5);
		use(1, $item[evilometer]);
		
		while (!stageDone("Niche")) bumAdv($location[The Defiled Niche], "", "", "", "Un-Defiling the Niche (1/4)");
		while (!stageDone("Nook")) {
			if (item_amount($item[evil eye]) > 0) use(i_a("evil eye"), $item[evil eye]);
			bumAdv($location[The Defiled Nook], "item", "items", "1 evil eye", "Un-Defiling the Nook (2/4)", "i");
			if (item_amount($item[evil eye]) > 0) use(1, $item[evil eye]);
		}
		while (!stageDone("Alcove")) {	//Kill modern zmobies (+initiative) to decrease evil
			use(item_amount($item[Okee-Dokee soda]),$item[Okee-Dokee soda]);
			if (item_amount($item[yellow candy heart]) > 0) use(1,$item[yellow candy heart]);
			bumAdv($location[The Defiled Alcove], "init", "init", "", "Un-Defiling the Alcove (3/4)", "n-");
		}
		while (!stageDone("Cranny")) {	//Kill swarms of ghuol welps (+NC, +ML) to decrease evil
			set_property("choiceAdventure523",4);
			bumAdv($location[The Defiled Cranny], "", "ml", "", "Un-Defiling the Cranny (4/4)", "-l");
		}
		
		if (my_buffedstat(my_primestat()) > 101) {
			set_property("choiceAdventure527", "1");
			bumAdv($location[Haert of the Cyrpt], "", "meatboss");
			visit_url("council.php");
			set_property("lastCouncilVisit", my_level());

			if (item_amount($item[chest of the Bonerdagon]) > 0) {
				if (cli_execute("use chest of the Bonerdagon")) {}
				checkStage("cyrpt", true);
				return true;
			}
		}
	} else {
		checkStage("cyrpt", true);
		return true;
	}
	return false;
}

void bcascDailyDungeon() {
	if (is_past(get_property("questL13Final"), "step5") || my_adventures() < 10 || my_path() == "Bugbear Invasion" || my_path() == "Actually Ed the Undying") return;
	zapKeys();
	int targetKeys = 3;
	if (numUniqueKeys() >= targetKeys || (!in_hardcore() && !bcasc_RunSCasHC)) return;
	
	int amountKeys;
	//Make skeleton keys if we can.
	if (i_a("skeleton bone") > 1 && i_a("loose teeth") > 1) {
		if (i_a("skeleton bone") > i_a("loose teeth")) {
			amountKeys = i_a("loose teeth") - 1;
		} else {
			amountKeys = i_a("skeleton bone") - 1;
		}
		cli_execute("make "+amountKeys+" skeleton key");
	}
	while (get_property("dailyDungeonDone") != "true" && my_adventures() > 0) {
		if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) {
			cli_execute("cast 3 astral shell");
		} else if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) {
			cli_execute("cast 3 elemental saucesphere");
		}
		adventure(my_adventures(), $location[the daily dungeon]);
		if (my_adventures() == 0) abort("BCC: No adventures in the Daily Dungeon");
	}
	
	zapKeys();
}


boolean bcascDinghyHippy() {
	if (checkStage("dinghy")) return true;
	//We shore first so that we can get the hippy outfit ASAP.
	if (get_property("lastIslandUnlock").to_int() != my_ascensions()) {
		if (my_path() != "Nuclear Autumn" && !bcasc_hippyJunk) {
			if (index_of(visit_url("place.php?whichplace=desertbeach"), "can't go to Desert Beach") > 0)
				visit_url("guild.php?place=paco");

			while (item_amount($item[Shore Inc. Ship Trip Scrip]) < 3 && my_adventures() > 2 && item_amount($item[dinghy plans]) < 1) {
				switch (my_primestat()) {
					case $stat[Muscle] :
						set_property("choiceAdventure793", "1");
					break;
					case $stat[Mysticality] :
						set_property("choiceAdventure793", "2");
					break;
					case $stat[Moxie] :
						set_property("choiceAdventure793", "3");
					break;
				}
				adventure(1, $location[The Shore, Inc. Travel Agency]);
			}

			if (item_amount($item[dinghy plans]) < 1) buy($coinmaster[The Shore\, Inc. Gift Shop], 1, ($item[dinghy plans]));
			if (item_amount($item[dingy planks]) < 1) buy(1, $item[dingy planks]);
			use(1, $item[dinghy plans]);
			if (item_amount($item[dingy dinghy]) == 0) {
				abort("BCC: There was a problem creating the dinghy. Please do this manually.");
			}
		}
		else {
			if (get_property("questM19Hippy") == "unstarted") {
				visit_url("place.php?whichplace=woods&action=woods_smokesignals");
				run_choice(1);
				run_choice(2);
			}
			if (get_property("questM19Hippy") == "started" || get_property("questM19Hippy") == "step1" || get_property("questM19Hippy") == "step2") {
				while (my_adventures() > 0 && i_a("junk junk") == 0) {
					if (i_a("funky junk key") > 0) {
						visit_url($location[The Old Landfill].to_url());
						if (i_a("old claw-foot bathtub") == 0) {
							run_choice(1);
							run_choice(1);
						}
						else if (i_a("old clothesline pole") == 0) {
							run_choice(2);
							run_choice(2);
						}
						else if (i_a("antique cigar sign") == 0) {
							run_choice(3);
							run_choice(3);
						}
						else {
							run_choice(1);
							run_choice(2);
							bumRunCombat();
						}
					}
					else if (i_a("worse homes and gardens") == 0) {
						bumAdv($location[The Old Landfill], "", "items", "1 worse homes and gardens", "Getting Worse Homes and Gardens Magazine", "i", "", 1); 
					}
					else if (i_a("worse homes and gardens") + i_a("old claw-foot bathtub") + i_a("old clothesline pole") + i_a("antique cigar sign") == 4) {
						create(1, $item[junk junk]);
					}
					else {
						bumAdv($location[The Old Landfill], "", "items", "1 funky junk key", "Getting funky junk key", "i", "", 1); 
					}
				}
			}
			if (get_property("questM19Hippy") == "step3") {
				visit_url("place.php?whichplace=woods&action=woods_hippy");
			}
			if (get_property("lastIslandUnlock").to_int() != my_ascensions()) {
				abort("BCC: There was a problem creating the dinghy. Please do this manually.");
			}
		}
	}
	
	if (can_interact()) {
		buy(1, $item[filthy knitted dread sack]);
		buy(1, $item[filthy corduroys]);
		return checkStage("dinghy", true);
	}
	
	if (!in_hardcore()) return checkStage("dinghy", true);
	if (get_property("questL12War") == "finished") return checkStage("dinghy", true);
	//if (my_path() == "Avatar of Jarlsberg") return checkStage("dinghy", true);
	
	while ((i_a("filthy knitted dread sack") == 0 || i_a("filthy corduroys") == 0) && have_effect($effect[Everything Looks Yellow]) == 0)
		bumAdv($location[Hippy Camp], "", "hebo", "1 filthy knitted dread sack, 1 filthy corduroys", "Getting Hippy Kit", "i", "consultHeBo");
	
	if (i_a("filthy knitted dread sack") > 0 && i_a("filthy corduroys") > 0) {
		checkStage("dinghy", true);
		return true;
	}
	return false;
}

boolean bcascFriars() {
	boolean needRubyW() {
		if (!in_hardcore() || my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Bugbear Invasion" || my_path() == "Zombie Slayer" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Actually Ed the Undying") return false;
		return true;
	}
	
	if (checkStage("friars")) return true;
	if (visit_url("friars.php?action=ritual&pwd="+my_hash()).to_string() != "") {}
	
	if (index_of(visit_url("friars.php"), "friars.gif") > 0) {
		print("BCC: Gotta get the Friars' Items", "purple");
		while (item_amount($item[eldritch butterknife]) == 0)
			bumAdv($location[The Dark Elbow of the Woods], "", "", "1 eldritch butterknife", "Getting butterknife from the Elbow (1/3)", "-");
			
		while (item_amount($item[box of birthday candles]) == 0)
			bumAdv($location[The Dark Heart of the Woods], "", "", "1 box of birthday candles", "Getting candles from the Heart (2/3)", "-");
			
		while (item_amount($item[dodecagram]) == 0) {
			if (needRubyW()) {
				bumAdv($location[The Dark Neck of the Woods], "", "items", "1 dodecagram, 1 ruby w", "Getting dodecagram from the Neck (3/3)", "-");
			} else {
				bumAdv($location[The Dark Neck of the Woods], "", "", "1 dodecagram", "Getting dodecagram from the Neck (3/3)", "-");
			}
		}
			
		print("BCC: Yay, we have all three items. I'm off to perform the ritual!", "purple");
		if (visit_url("friars.php?action=ritual&pwd="+my_hash()).to_string() != "") {}
	}
	if (contains_text(visit_url("friars.php"), "pandamonium.php")) {
		checkStage("friars", true);
		return true;
	}
	return false;
}

boolean bcascFriarsSteel() {
	if (checkStage("friarssteel")) return true;
	if (get_property("bcasc_skipSteel") == "true") return checkStage("friarssteel", true);
	if (have_skill($skill[Liver of Steel]) || have_skill($skill[Spleen of Steel]) || have_skill($skill[Stomach of Steel])) return checkStage("friarssteel", true);
	if (my_path() == "Avatar of Boris" && (minstrel_instrument() != $item[Clancy's lute] && i_a("Clancy's lute") == 0)) return false;
	if (my_path() == "Actually Ed the Undying" || my_path() == "Nuclear Autumn") return false;

	boolean logicPuzzleDone() {
		/*    
			* Jim the sponge cake or pillow
			* Flargwurm the cherry or sponge cake
			* Blognort the marshmallow or gin-soaked paper
			* Stinkface the teddy bear or gin-soaked paper 
		*/
		if (item_amount($item[sponge cake]) + item_amount($item[comfy pillow]) + item_amount($item[gin-soaked blotter paper]) + item_amount($item[giant marshmallow]) + item_amount($item[booze-soaked cherry]) + item_amount($item[beer-scented teddy bear]) == 0) return false;
		
		int j = 0, f = 0, b = 0, s = 0, jf, bs;
		string sven = visit_url("pandamonium.php?action=sven");
		if (contains_text(sven, "<option>Bognort")) b = 1;
		if (contains_text(sven, "<option>Flargwurm")) f = 1;
		if (contains_text(sven, "<option>Jim")) j = 1;
		if (contains_text(sven, "<option>Stinkface")) s = 1;
		jf = j+f;
		bs = b+s;
		
		boolean x, y;
		x = ((item_amount($item[sponge cake]) >= jf) || (item_amount($item[sponge cake]) + item_amount($item[comfy pillow]) >= jf) || (item_amount($item[sponge cake]) + item_amount($item[booze-soaked cherry]) >= jf) || (item_amount($item[comfy pillow]) + item_amount($item[booze-soaked cherry]) >= jf));
		y = ((item_amount($item[gin-soaked blotter paper]) >= bs) || (item_amount($item[gin-soaked blotter paper]) + item_amount($item[giant marshmallow]) >= bs) || (item_amount($item[gin-soaked blotter paper]) + item_amount($item[beer-scented teddy bear]) >= bs) || (item_amount($item[beer-scented teddy bear]) + item_amount($item[giant marshmallow]) >= bs));
		print("BCC: x is "+x+" and y is "+y+". j, f, b, s are "+j+", "+f+", "+b+", "+s+".", "purple");
		return x && y;
	}
	
	if (to_string(visit_url("pandamonium.php")) != "") {}
	if (to_string(visit_url("pandamonium.php")) != "") {}
	if (checkStage("friarssteel")) return true;
	//Let's do this check now to get it out the way. 
	if (!contains_text(visit_url("questlog.php?which=1"), "this is Azazel in Hell")) {
		print("BCC: Unable to detect organ of steel quest.", "purple");
		return false;
	} else if (contains_text(visit_url("questlog.php?which=2"), "this is Azazel in Hell")) {
		checkStage("friarssteel", true);
		return true;
	}
	
	string steelName() {
		if (!can_drink() && !can_eat()) { return "steel-scented air freshener"; }
		if (!can_drink() || my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer") { return "steel lasagna"; }
		return "steel margarita";
	}
	string steelWhatToDo() {
		if (!can_drink() && !can_eat()) { return "use steel-scented air freshener"; }
		if (!can_drink() || my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer") { return "eat steel lasagna"; }
		if (my_path() != "KOLHS") { return "overdrink steel margarita"; }
		return "";
	}
	int steelLimit() {
		if (!can_drink() && !can_eat()) { return spleen_limit(); }
		if (!can_drink() || my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer") { return fullness_limit(); }
		return inebriety_limit();
	}
	
	if ((steelLimit() > 16 && my_path() != "Avatar of Boris" && my_path() != "Zombie Slayer" && my_path() != "Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete") || (my_path() == "Avatar of Boris" && steelLimit() - to_int(have_skill($skill[Legendary Appetite])) * 5 > 21) || (my_path() == "Zombie Slayer" && steelLimit() - to_int(have_skill($skill[Insatiable Hunger])) * 5 > 21) || (my_path() == "Avatar of Jarlsberg" && steelLimit() - to_int(have_skill($skill[Nightcap])) * 5 > 9)) return true;
	if (i_a(steelName()) > 0) {
		cli_execute(steelWhatToDo());
		if ((steelLimit() > 16 && my_path() != "Avatar of Jarsberg") || (steelLimit() > 9 + to_int(have_skill($skill[Nightcap])) * 5 && my_path() == "Avatar of Jarlsberg") || my_path() == "KOLHS") {
			checkStage("friarssteel", true);
			return true;
		} else if (i_a(steelName()) > 0) {
			abort("BCC: There was some problem using the steel item. Perhaps use it manually?");
		} else {
			return false;
		}
	}
	
	while (item_amount($item[Azazel's unicorn]) == 0) {
		//I'm hitting this page a couple times quietly because I'm fairly sure that the first time you visit him,
		//there's no drop-downs and this makes the script act screwy.
		visit_url("pandamonium.php?action=sven");
		visit_url("pandamonium.php?action=sven");
	
		//Solve the logic puzzle in the Hey Deze Arena to receive Azazel's unicorn
		cli_execute("mood execute");
		buMax();
		levelMe(safeMox($location[Infernal Rackets Backstage]), false);
		print("BCC: Getting Azazel's unicorn and the bus passes", "purple");
		setFamiliar("itemsnc");
		cli_execute("mood execute; conditions clear");
		bumAdv($location[Infernal Rackets Backstage], "", "itemsnc", "5 bus pass", "Let's get the bus passes first", "i");
		while (!logicPuzzleDone()) {
			bumMiniAdv(1, $location[Infernal Rackets Backstage]);
		}
		int bog = 0, sti = 0, fla = 0, jim = 0;
		if (item_amount($item[giant marshmallow]) > 0) { bog = to_int($item[giant marshmallow]); }
		if (item_amount($item[beer-scented teddy bear]) > 0) { sti = to_int($item[beer-scented teddy bear]); }
		if (item_amount($item[booze-soaked cherry]) > 0) { fla = to_int($item[booze-soaked cherry]); }
		if (item_amount($item[comfy pillow]) > 0) { jim = to_int($item[comfy pillow]); }
		if (bog == 0) bog = to_int($item[gin-soaked blotter paper]);
		if (sti == 0) sti = to_int($item[gin-soaked blotter paper]);
		if (fla == 0) fla = to_int($item[sponge cake]);
		if (jim == 0) jim = to_int($item[sponge cake]);
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Bognort")) visit_url("pandamonium.php?action=sven&bandmember=Bognort&togive="+bog+"&preaction=try");
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Stinkface")) visit_url("pandamonium.php?action=sven&bandmember=Stinkface&togive="+sti+"&preaction=try");
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Flargwurm")) visit_url("pandamonium.php?action=sven&bandmember=Flargwurm&togive="+fla+"&preaction=try");
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Jim")) visit_url("pandamonium.php?action=sven&bandmember=Jim&togive="+jim+"&preaction=try");
		if (item_amount($item[Azazel's unicorn]) == 0) abort("BCC: The script doesn't have the unicorn, but it should have. Please do this part manually.");
	}
	
	while (item_amount($item[Azazel's lollipop]) == 0) {
		levelMe(safeMox($location[The Laugh Floor]));
		void tryThis(item i, string preaction) {
			if (i_a(i) > 0) { 
				equip(i);
				visit_url("pandamonium.php?action=mourn&preaction="+preaction); 
			}
		}
	
		//Adventure in Belilafs Comedy Club until you encounter Larry of the Field of Signs. Equip the observational glasses and Talk to Mourn. 
		print("BCC: Getting Azazel's lollipop", "purple");
		while (i_a($item[observational glasses]) == 0) bumAdv($location[The Laugh Floor], "", "items", "1 observational glasses, 5 imp air", "Getting the Observational Glasses", "i");
		if (my_path() != "Avatar of Boris") cli_execute("unequip weapon");
		if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") tryThis($item[Victor, the Insult Comic Hellhound Puppet], "insult");
		tryThis($item[observational glasses], "observe");
		if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") tryThis($item[hilarious comedy prop], "prop");
	}
	
	while (item_amount($item[Azazel's tutu]) == 0) {
		//After collecting 5 cans of imp air and 5 bus passes from the comedy blub and backstage, go the Moaning Panda Square to obtain Azazel's tutu. 
		print("BCC: Getting Azazel's tutu", "purple");
		while (item_amount($item[bus pass]) < 5) bumAdv($location[Infernal Rackets Backstage], "", "items", "5 bus pass", "Getting the 5 Bus Passes", "i");
		while (item_amount($item[imp air]) < 5)  bumAdv($location[The Laugh Floor], "", "items", "5 imp air", "Getting the 5 Imp Airs", "i");
		visit_url("pandamonium.php?action=moan");
	}
	
	visit_url("pandamonium.php?action=temp");
	cli_execute(steelWhatToDo());
	if ((steelLimit() > 16 && my_path() != "Avatar of Jarsberg") || (steelLimit() > 9 + to_int(have_skill($skill[Nightcap])) * 5 && my_path() == "Avatar of Jarlsberg") || my_path() == "KOLHS") {
		checkStage("friarssteel", true);
		return true;
	} else if (i_a(steelName()) > 0) {
		abort("BCC: There was some problem using the steel item. Perhaps use it manually?");
	} else {
		return false;
	}
	abort("BCC: There was some problem using the steel item. Perhaps use it manually or something?");
	return false;
}

boolean bcascGuild() {
	if (checkStage("guild")) return true;
	if (my_class().to_int() > 6 || my_path() == "Nuclear Autumn") return false; // If we aren't in the original 6 classes, we can't unlock the guild for now, but if we drop that, then...
	if (!in_hardcore() && !bcasc_RunSCasHC) return checkStage("guild", true);
	setFamiliar("");
	location loc;
	while (!guild_store_available()) {
		switch (my_primestat()) {
			case $stat[Muscle] : loc = $location[The Outskirts of Cobb's Knob]; break;
			case $stat[Mysticality]: loc = $location[The Haunted Pantry]; break;
			case $stat[Moxie] : 
				loc = $location[The Sleazy Back Alley];
				buMax("");
				if (item_type(equipped_item($slot[pants])) != "pants") return false;
			break;
		}
		print("BCC: The script is trying to unlock the guild quest. If this adventures forever in the starting area, type 'ash set_property(\"bcasc_stage_guild\", my_ascensions())' into the CLI to stop it.", "purple");
		bumMiniAdv(1, loc);
		visit_url("guild.php?place=challenge");		
	}
	visit_url("guild.php?place=challenge");		
	
	if (guild_store_available() && my_basestat(my_primestat()) > 12) {
		checkStage("guild", true);
		return true;
	}
	return false;
}

boolean bcascHoleInTheSky() {
	if (checkStage("hits")) return true;
	if (can_interact()) {
		//Don't need to do anything here because the lair automatically gets these. 
	}
	if (!in_hardcore() || my_path() == "Bugbear Invasion") return checkStage("hits", true);

	if (item_amount($item[steam-powered model rocketship]) == 0) {
		set_property("choiceAdventure675", 4);
		set_property("choiceAdventure676", 3);
		set_property("choiceAdventure677", 2);
		set_property("choiceAdventure678", 2);
		bumAdv($location[The Castle in the Clouds in the Sky (Top Floor)], "", "itemsnc", "steam-powered model rocketship", "Picking up a steam-powered model rocketship to open up the Hole in the Sky", "-");
	}
	
	setFamiliar("items");
	setMood("i");
	buMax();
	cli_execute("conditions clear");
	levelMe(safeMox($location[The Hole in the Sky]));
	cli_execute("conditions clear");
	
	while (need_key($location[The Hole in the Sky])) {
		bumMiniAdv(1, $location[The Hole in the Sky]);
		if (item_amount($item[star chart]) > 0) {
			if (i_a("Richard's star key") == 0 && creatable_amount($item[Richard's star key]) > 0 && item_amount($item[star chart]) > 0) { if(!retrieve_item(1, $item[Richard's star key])) {} }
		}
	}
	checkStage("hits", true);
	return true;
}

boolean bcascFunHouse() {
	if (bcasc_cloverless) return false;
	if (!in_hardcore()) return false;
	if (checkStage("guild")) return false; // This should gate the various non-class options
	if (my_path() == "Way of the Surprising Fist") return false; 

	//Returns true if you lack one of the kickass astral weapons for your Mox/Mus class as appropriate.
	boolean dontHaveAstral() {
		switch (my_primestat()) {
			case $stat[Muscle] :
				return (i_a("astral mace") + i_a("astral bludgeon") == 0);
			case $stat[Moxie] :
				return (i_a("astral longbow") + i_a("astral pistol") == 0);
		}
		return false;
	}

	void makeClownosity() {
		if (!maximize("4 clownosity -familiar -tie", true)) {
			int clownosity = min(i_a($item[big red clown nose]), 3) + min(i_a($item[clown shoes]), 3) + min(i_a($item[bloody clown pants]), 1)
				+ (2 * min(i_a($item[polka-dot bow tie]), 1)) + (2 * min(i_a($item[balloon sword]), 1)) + (2 * min(i_a($item[clownskin belt]), 3));

			if (i_a($item[clown skin]) > 0) {
				if (i_a($item[clown wig]) == 0 && (i_a($item[clown skin]) >= 2 || clownosity == 2 || clownosity == 3)) {
					cli_execute("make clown wig");
				}
	
				if (i_a($item[clownskin belt]) == 0 && (i_a($item[clown skin]) >= 1 && i_a($item[big red clown nose]) >= 1 && (i_a($item[clown wig]) >= 1
						|| (clownosity == 2 && i_a($item[big red clown nose]) >= 2) || clownosity == 3))) {

					cli_execute("make clownskin belt");
				}
			}
	
			if (my_primestat() == $stat[Muscle] && i_a($item[balloon sword]) == 0 && i_a($item[long skinny balloon]) >= 3) {
				cli_execute("make balloon sword");
			}
	
			if (i_a($item[balloon helmet]) == 0 && i_a($item[clown wig]) == 0 && i_a($item[foolscap fool's cap]) == 0 && i_a($item[long skinny balloon]) >= 2 && clownosity == 3) {
				cli_execute("make balloon helmet");		
			}
		}
	}

	boolean getLegendaryEpic(string className, string epicWeapon, string theOtherThingYouNeed, string theLegendaryEpicWeaponYouWantToGet) {
		if (i_a(epicWeapon) == 0) { return false; }

		print("BCC: Getting the "+className+" Legendary Epic Weapon", "purple");

		if (i_a(theOtherThingYouNeed) == 0) {
			// Hit the guild page until we see the clown thingy.
			while (!contains_text(visit_url("place.php?whichplace=plains"), to_url($location[The "Fun" House]))) {
				print("BCC: Visiting the guild to unlock the funhouse", "purple");
				visit_url("guild.php?place=scg");
			}

			makeClownosity();

			if (!maximize("4 clownosity -familiar -tie", true)) {
				set_property("choiceAdventure151", "2"); // DON'T fight the Clownlord

				//Prepare for adventuring
				buMax("item");
				setFamiliar("items");
				setMood("i");

				print("BCC: Adventuring once at a time to get clownosity items.", "purple");

				while (!maximize("4 clownosity -familiar -tie", true)) {
					bumMiniAdv(1, $location[The "Fun" House]);
					makeClownosity();
				}
			}

			set_property("choiceAdventure151", "1"); // fight the Clownlord

			//Prepare for adventuring
			buMax("item");
			setFamiliar("items");
			setMood("");
			maximize("4 clownosity -familiar -tie", false);

			print("BCC: Getting "+theOtherThingYouNeed+".", "purple");

			cli_execute("condition add 1 " + theOtherThingYouNeed);
			bumMiniAdv(my_adventures(), $location[The "Fun" House]);
		}

		if (cli_execute("make "+theLegendaryEpicWeaponYouWantToGet)) {}
		return true;
	}

	if (my_class() == $class[Seal Clubber] && my_buffedstat(my_primestat()) > 15 && i_a("Bjorn's Hammer") == 1 && i_a("Hammer of Smiting") == 0 && i_a("Sledgehammer of the V&aelig;lkyr") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("SC", "Bjorn's Hammer", "distilled seal blood", "Hammer of Smiting");
	}

	if (my_class() == $class[Turtle Tamer] && my_buffedstat(my_primestat()) > 15 && i_a("Mace of the Tortoise") == 1 && i_a("Chelonian Morningstar") == 0 && i_a("Flail of the Seven Aspects") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("TT", "Mace of the Tortoise", "turtle chain", "Chelonian Morningstar");
	}

	if (my_class() == $class[Pastamancer] && my_buffedstat(my_primestat()) > 15 && (!have_skill($skill[springy fusilli]) || bcasc_bartender || bcasc_chef) && i_a("Pasta Spoon of Peril") == 1 && i_a("Greek Pasta Spoon of Peril") == 0 && i_a("Wrath of the Capsaician Pastalords") == 0) {
		return getLegendaryEpic("P", "Pasta Spoon of Peril", "high-octane olive oil", "Greek Pasta Spoon of Peril");
	}

	if (my_class() == $class[Sauceror] && my_buffedstat(my_primestat()) > 15 && (have_skill($skill[jalape&ntilde;o saucesphere]) || bcasc_bartender || bcasc_chef) && i_a("5-alarm Saucepan") == 1 && i_a("17-alarm Saucepan") == 0 && i_a("Windsor Pan of the Source") == 0) {
		return getLegendaryEpic("S", "5-Alarm Saucepan", "Peppercorns of Power", "17-alarm Saucepan");
	}

	if (my_class() == $class[Disco Bandit] && my_buffedstat(my_primestat()) > 15 && i_a("Disco Banjo") == 1 && i_a("Shagadelic Disco Banjo") == 0 && i_a("Seeger's Unstoppable Banjo") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("DB", "Disco Banjo", "vial of mojo", "Shagadelic Disco Banjo");
	}

	if (my_class() == $class[Accordion Thief] && my_buffedstat(my_primestat()) > 15 && i_a("Rock and Roll Legend") == 1 && i_a("Squeezebox of the Ages") == 0 && i_a("The Trickster's Trikitixa") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("AT", "Rock and Roll Legend", "golden reeds", "Squeezebox of the Ages");
	}

	return false;
}
boolean bcascInnaboxen() {
	if (bcasc_cloverless) return false;
	if (my_path() == "Bees Hate You" || !guild_store_available()) return false;
	if (checkStage("innaboxen")) return true;
	if (!in_hardcore()) return checkStage("innaboxen", true);
	boolean trouble = false;
	
	int[item] campground = get_campground();
	if((bcasc_bartender && campground contains to_item("bartender-in-the-box")) && (bcasc_chef && campground contains to_item("chef-in-the-box"))) {
		checkStage("innaboxen", true);
		return true;
	} else if((bcasc_bartender && !bcasc_chef) && campground contains to_item("bartender in-the-box")) {
		checkStage("innaboxen", true);
		return true;
	} else if((!bcasc_bartender && bcasc_chef) && campground contains to_item("chef-n-the-box")) {
		checkStage("innaboxen", true);
		return true;
	} else if(!bcasc_bartender && !bcasc_chef) {
		checkStage("innaboxen", true);
		return true;
	}
	
	//Thanks, gruddlefitt!
	item bcascWhichEpic() {
		item [class] epicMap;
		epicMap[$class[Seal Clubber]] = $item[Bjorn's Hammer];
		epicMap[$class[Turtle Tamer]] = $item[Mace of the Tortoise];
		epicMap[$class[Pastamancer]] = $item[Pasta Spoon of Peril];
		epicMap[$class[Sauceror]] = $item[5-Alarm Saucepan];
		epicMap[$class[Disco Bandit]] = $item[Disco Banjo];
		epicMap[$class[Accordion Thief]] = $item[Rock and Roll Legend];
		return epicMap[my_class()];
	}
	
	boolean getBox() {
		//I know, we should already have run this, but what's a visit to the hermit between friends?
		if (i_a("box") > 0) { return true; }
		item epicWeapon = bcascWhichEpic();
		if (item_amount(epicWeapon) == 0) { return false; }
		
		//Then hit the guild page until we see the clown thingy.
		while (!contains_text(visit_url("place.php?whichplace=plains"), to_url($location[The "Fun" House]))) {
			print("BCC: Visiting the guild to unlock the funhouse", "purple");
			visit_url("guild.php?place=scg");
		}
		
		if (cloversAvailable(true) > 0) {
			if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
			visit_url("adventure.php?snarfblat=20");
			return true;
		}
		
		return false;
	}
	
	if (index_of(visit_url("questlog.php?which=2"), "defeated the Bonerdagon") > 0) {
		//At this point, we can clover the Cemetary for innaboxen. 
		cloversAvailable();
		
		//Apart from the brain/skull, we need a box and spring and the chef's hat/beer goggles.
		if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Chef-in-the-Box") && bcasc_chef) {
			//We're not even going to bother to try if we don't have a chef's hat. 
			if (i_a("chef's hat") > 0 && (i_a("spring") > 0 || knoll_available())) {
				print("BCC: Going to try to make a chef", "purple");
				if (getBox()) {
					if (creatable_amount($item[chef-in-the-box]) == 0) {
						//Then the only thing we could need would be brain/skull, as we've checked for all the others. 
						if (cloversAvailable(true) > 0) {
							if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
							visit_url("adventure.php?snarfblat=58");
							cli_execute("use chef-in-the-box");
						} else {
							print("BCC: Uhoh, we don't have enough clovers to get the brain/skull we need.", "purple");
							trouble = true;
						}
					} else {
						cli_execute("use chef-in-the-box");
					}
				} else {
					print("BCC: There was a problem getting the box.", "purple");
					trouble = true;
				}
			}
		}
		
		if (bcasc_bartender) {
			if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Bartender-in-the-Box")) {
				if (i_a("spring") > 0 || knoll_available()) {
					print("BCC: Going to try to get a bartender.", "purple");
					if (getBox()) {
						if (creatable_amount($item[bartender-in-the-box]) == 0) {
							if (creatable_amount($item[brainy skull]) + available_amount($item[brainy skull]) == 0) {
								if (cloversAvailable(true) > 0) {
									if (my_hp() < 1 && !restore_hp(1)) abort("BCC: You can't get enough health to adventure. :(");
									visit_url("adventure.php?snarfblat=58");
								} else {
									print("BCC: Uhoh, we don't have enough clovers to get the brain/skull we need.", "purple");
									trouble = true;
								}
							}
							
							while (creatable_amount($item[beer goggles]) + available_amount($item[beer goggles]) == 0) {
								bumAdv($location[A Barroom Brawl], "", "items", "1 beer goggles", "Getting the beer goggles");
							}
							
							if (creatable_amount($item[bartender-in-the-box]) > 0) {
								cli_execute("use bartender-in-the-box");
							}
						} else {
							cli_execute("use bartender-in-the-box");
						}
					} else {
						print("BCC: There was a problem getting the box.", "purple");
						trouble = true;
					}
				}
			}
		}
		
		if (!trouble) {
			checkStage("innaboxen", true);
			return true;
		} else {
			return false;
		}
	} else {
		return false;
	}
}

boolean bcascKnob() {
	if (checkStage("knob")) return true;
	while (contains_text(visit_url("place.php?whichplace=plains"), "knob1.gif") && item_amount($item[knob goblin encryption key]) == 0) {
		bumAdv($location[The Outskirts of Cobb's Knob], "", "", "1 knob goblin encryption key", "Let's get the Encryption Key");
	}
	checkStage("knob", true);
	return true;
}

boolean bcascKnobKing() {
	if (checkStage("knobking")) return true;
	if (is_equal_to(get_property("questL05Goblin"), "finished")) return checkStage("knobking", true);
	//Before we go into the harem, we gotta use the map. 
	if (item_amount($item[Cobb's Knob map]) > 0) {
		use(1, $item[Cobb's Knob map]);
	}
	
	if (can_interact()) {
		print("BCC: You can interact, so do this the lazy way.", "purple");
		while (!is_not_yet(get_property("questL05Goblin"), "finished")) {
			cli_execute("outfit knob goblin harem girl disguise");
			cli_execute("use knob goblin perfume");
			bumAdv($location[Throne Room], "+outfit knob goblin harem girl disguise", "meatboss", "", "Killing the Knob King");
		}
		if (is_equal_to(get_property("questL05Goblin"), "finished")) return checkStage("knobking", true);
	}
	
	if (is_not_yet(get_property("questL05Goblin"), "finished")) {
		if (my_path() != "Bees Hate You" && my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris" && my_primestat() != $stat[Moxie]) {
			//First we need the KGE outfit. 
			while (i_a($item[Knob Goblin elite pants]) == 0 || i_a($item[Knob Goblin elite polearm]) == 0 || i_a($item[Knob Goblin elite helm]) == 0) {
				bumAdv($location[Cobb's Knob Barracks], "", "items", "1 Knob Goblin elite pants, 1 Knob Goblin elite polearm, 1 Knob Goblin elite helm", "Getting the KGE Outfit");
			}

			//Then we need the cake. 
			if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Dramatic")) {
				if (!use(1, to_item("Dramatic range")))
				if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Dramatic")) abort("BCC: You need a dramatic oven for this to work.");
			}

			if (my_basestat($stat[muscle]) >= 15 && my_basestat($stat[moxie]) >= 15) {
				while (available_amount($item[Knob cake]) + creatable_amount($item[Knob cake]) == 0) {
					while (item_amount($item[Knob frosting]) == 0) {
						bumAdv($location[Cobb's Knob Kitchens], "+outfit knob goblin elite guard uniform", "", "1 knob frosting", "Getting the Knob Frosting");
					}
					
					while (available_amount($item[unfrosted Knob cake]) + creatable_amount($item[unfrosted Knob cake]) == 0) {
						bumAdv($location[Cobb's Knob Kitchens], "+outfit knob goblin elite guard uniform", "", "1 Knob cake pan, 1 knob batter", "Getting the Knob Pan and Batter");
					}
				}
				if (item_amount($item[Knob cake]) == 0) {
					if(to_boolean(get_property("requireBoxServants"))) {
						if(user_confirm("BCC: You have requireBoxServants set to true. The script want to create a Knob Cake, do you wish to continue?")) {
							set_property("requireBoxServants", false);
							if (cli_execute("make knob cake")) {}
							set_property("requireBoxServants", true);
						}
					}
					else 
					{
						if (cli_execute("make knob cake")) {}
					}
				}
			
				//Now the Knob Goblin King has 55 Attack, and we'll be fighting him with the MCD set to 7. So that's 55+7+7=69 Moxie we need. 
				//Arbitrarily using 75 because will need the harem outfit equipped. 
				if (item_amount($item[Knob cake]) > 0) {
					buMax();
					if (my_buffedstat(my_primestat()) >= 75) {
						bumAdv($location[Throne Room], "+outfit knob goblin elite guard uniform", "meatboss", "", "Killing the Knob King");
						if (is_equal_to(get_property("questL05Goblin"), "finished")) return checkStage("knobking", true);
						return true;
					}
				}

				if (contains_text(visit_url("questlog.php?which=2"), "slain the Goblin King") && !dispensary_available() && my_path() != "Bees Hate You") {
					//Just get the password.
					cli_execute("outfit knob goblin elite guard uniform");
					while (!dispensary_available() && my_path() != "Bees Hate You" ) {
						print("BCC: Adventuring once to learn it's FARQUAR. Surely you'd remember this when you reincarnate?", "purple");
						adventure(1, $location[Cobb's Knob Barracks]);
					}
				}
			}
		} else {
			//Bees hate harem girl outfits slightly less, and moxie classes need a ranged weapon.
			while (i_a($item[Knob Goblin harem pants]) == 0 || i_a($item[Knob Goblin harem veil]) == 0) {
				bumAdv($location[Cobb's Knob Harem], "", "items", "1 Knob Goblin harem pants, 1 Knob Goblin harem veil", "Getting the Harem Outfit", "i");
			}
			
			//Then we need to be perfumed up, but not before we're powerful enough to beat Mr King
			//Now the Knob Goblin King has 55 Attack, and we'll be fighting him with the MCD set to 7. So that's 55+7+7=69 Moxie we need. 
			//Arbitrarily using 75 because will need the harem outfit equipped. 
			buMax();
			if (my_buffedstat(my_primestat()) >= 75) {
				if(my_path() == "Bees Hate You" || (my_path() != "Bees Hate You" && i_a($item[Knob Goblin perfume]) == 0)) {
					print("BCC: Getting perfumed up for the King");
					cli_execute("outfit Knob Goblin Harem Girl Disguise");
					while(have_effect($effect[Knob Goblin Perfume]) == 0) bumminiAdv(1, $location[Cobb's Knob Harem]);
				}
				else
					use(1, $item[Knob Goblin perfume]);

				bumAdv($location[Throne Room], "+outfit Knob Goblin Harem Girl Disguise", "meatboss", "", "Killing the Knob King");
				if (is_equal_to(get_property("questL05Goblin"), "finished")) return checkStage("knobking", true);
				return true;
			}
		}
	} else {
		checkStage("knobking", true);
		return true;
	}
	return false;
}

boolean bcascKnobPassword() {
	if (!in_hardcore()) return false;
	if (item_amount($item[Cobb's Knob lab key]) == 0) return false;
	if (my_path() == "Bees Hate You" || my_path() == "Way of the Surprising Fist" || my_path() == "Avatar of Boris") return false;
	while (!dispensary_available() && my_path() != "Bees Hate You") {
		while (i_a($item[Knob Goblin elite pants]) == 0 || i_a($item[Knob Goblin elite polearm]) == 0 || i_a($item[Knob Goblin elite helm]) == 0) {
			bumAdv($location[Cobb's Knob Barracks], "", "items", "1 Knob Goblin elite pants, 1 Knob Goblin elite polearm, 1 Knob Goblin elite helm", "Getting the KGE Outfit");
		}
		cli_execute("outfit knob goblin elite guard uniform");
		
		if (my_adventures() == 0) abort("BCC: No adventures trying to learn FARQUAR.");
		print("BCC: Adventuring once to learn it's FARQUAR. Surely you'd remember this when you reincarnate.", "purple");
		adventure(1, $location[Cobb's Knob Barracks]);
	}
	if (dispensary_available())
		return true;
	else
		return false;
}

void bcascLairEd() {
	if (my_level() > 12 && is_not_yet(get_property("questL13Final"), "started")) council();
	if (is_equal_to(get_property("questL13Final"), "started")) visit_url("place.php?whichplace=nstower");
	if (is_equal_to(get_property("questL13Final"), "step11")) {
		print("BCC: Fighting the stupid adventurer who stole your stuff...", "purple");
		adventure(1, $location[The Naughty Sorceress' Chamber]);
	}
	if (is_equal_to(get_property("questL13Final"), "finished") && is_equal_to(get_property("questL13Warehouse"), "unstarted")) council();
	if (is_equal_to(get_property("questL13Warehouse"), "started") && item_amount($item[7965]) < 1) {
		print("BCC: Looting the worthless council's secrets...", "purple");
		if (get_goals().count() > 0) cli_execute("goals clear");
		add_item_condition(1, $item[7965]);
		adventure(my_adventures(),$location[The Secret Council Warehouse]);
	}
	if (item_amount($item[7965]) > 0) {
#		ascendLog("yes");
		if (!contains_text(visit_url("trophy.php"), "not currently entitled to")) abort("BCC: You're entitled to some trophies!");
		print("BCC: Hi-keeba!", "purple");
		cli_execute("mood apathetic");
		visit_url("place.php?whichplace=edbase&action=edbase_altar");
		run_choice(1);
	}
	else abort("BCC: Something is wrong with your Ed. Perhaps you need an Ed-doctor.");
}

void bcascLairFightNS() {
	if (is_not_yet(get_property("questL13Final"), "step11")) {
		abort("BCC: You don't seem to be quite ready to fight Her Naughtiness yet...");
	}
	if (my_path() != "Bugbear Invasion") {
		print("BCC: Fighting the NS", "purple");
		if (canMCD()) cli_execute("mcd 0");
		buMax();
		cli_execute("uneffect beaten up; restore hp; restore mp");
		
		if (my_path() != "Avatar of Boris" && my_path() != "Avatar of Sneaky Pete" && my_path() != "Avatar of Jarlsberg" && my_path() != "Zombie Slayer" && my_path() != "KOLHS" && my_path() != "Actually Ed the Undying") {
			if (item_amount($item[wang]) > 0) cli_execute("untinker wang");
			if (item_amount($item[ng]) > 0) cli_execute("untinker ng");
			if (item_amount($item[wand of nagamar]) == 0) {
				if (!retrieve_item(1, $item[wand of nagamar])) {
					if (!take_storage(1, $item[wand of nagamar])) {
						if (i_a($item[ruby W]) == 0) {thingToGet = $item[ruby W]; bumAdv($location[Pandamonium Slums], "item", "hebo", "1 ruby W", "Getting a ruby W", "i", "consultHeBo");}
						if (i_a($item[metallic A]) == 0) {thingToGet = $item[metallic A]; bumAdv($location[The Penultimate Fantasy Airship], "item", "hebo", "1 metallic A", "Getting a metallic A", "i", "consultHeBo");}
						if (i_a($item[lowercase N]) == 0) {thingToGet = $item[lowercase n]; bumAdv($location[The Valley of Rof L'm Fao], "item", "hebo", "1 lowercase N", "Getting a lowercase N", "i", "consultHeBo");}
						if (i_a($item[original G]) == 0) {thingToGet = $item[original G]; bumAdv($location[The Castle in the Clouds in the Sky (Basement)], "item", "hebo", "1 original G", "Getting an original G", "i", "consultHeBo");}
						cli_execute("make wand of nagamar");
					}
				}
			}
			if (item_amount($item[wand of nagamar]) == 0) abort("BCC: Failed to get the wand!");
		}
		
		if (my_primestat() == $stat[Mysticality]) {
			buMax("DA, DR");
		}
	}
	
	setFamiliar("");
	if (bcasc_fightNS && my_path() != "Bugbear Invasion") {
		adventure(1, $location[The Naughty Sorceress' Chamber]);
		for i from 1 to 2 {
			if (!contains_text(bumRunCombat(), "You win the fight!")) {
				abort("BCC: Maybe you should fight Her Naughtiness yourself...");
			}
		}
#		ascendLog("yes");
		if (!contains_text(visit_url("trophy.php"), "not currently entitled to")) abort("BCC: You're entitled to some trophies!");
		print("BCC: Hi-keeba!", "purple");
		cli_execute("mood apathetic");
		visit_url("place.php?whichplace=nstower&action=ns_11_prism");
		if (get_property("bcasc_getItemsFromStorage") == "true") {
			print("BCC: Getting all your items out of Storage. Not all bankers are evil, eh?", "purple");
			visit_url("storage.php?action=pullall&pwd=");
		}
		abort("BCC: Tada! Thank you for using bumcheekascend.ash.");
	} else if (my_path() == "Bugbear Invasion") {
		abort("BCC: The path to the bridge of the bugbear mother ship is open for you. Go forth and be victorious!");
	} else {
		abort("BCC: Bring it on.");
	}
}

boolean bcascMacguffinFinal() {
	if (checkStage("macguffinfinal")) return true;

	if (item_amount(to_item("2325")) == 0) { // Since mafia is no longer automatically creating the Staff of Ed, do it ourselves
		retrieve_item(2, $item[meat paste]);
		if (item_amount(to_item("2180"))+item_amount(to_item("2268"))+item_amount(to_item("2286")) == 3) {
			if (random(2) == 0) craft("combine", 1, to_item("2180"), to_item("2268"));
			else craft("combine", 1, to_item("2180"), to_item("2286"));
		}
		if (item_amount(to_item("2323"))+item_amount(to_item("2268")) == 2) craft("combine", 1, to_item("2323"), to_item("2268"));
		else if (item_amount(to_item("2324"))+item_amount(to_item("2286")) == 2) craft("combine", 1, to_item("2324"), to_item("2286"));
	}
	
	if (!contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme") && !contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme")) {
		buffer visitpage;
		if (!contains_text(visit_url("place.php?whichplace=desertbeach"),"place.php?whichplace=pyramid")) visitpage = visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
		if (!contains_text(visitpage,"place.php?whichplace=pyramid")) visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
	}

	if (contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme")) {
		if (!get_property("middleChamberUnlock").to_boolean()) {
			bumAdv($location[The Upper Chamber], "", "", "choiceadv", "Getting the initial choice adventure", "-");
		}

		while (!get_property("lowerChamberUnlock").to_boolean() || !get_property("controlRoomUnlock").to_boolean()) {
			bumAdv($location[The Middle Chamber], "", "", "choiceadv", "Getting the initial choice adventure", "-");
		}

		int turnsNeeded;
		if (contains_text(visit_url("place.php?whichplace=pyramid"),"action=pyramid_state1a")) {
			turnsNeeded = 0;
		} else if (i_a("ancient bomb") > 0) {
			turnsNeeded = 3;
		} else if (i_a("ancient bronze token") > 0) {
			turnsNeeded = 7;
		} else {
			turnsNeeded = 10;
		}

		if (can_interact()) {
			retrieve_item(turnsNeeded - i_a("crumbling wooden wheel"), $item[tomb ratchet]);
		}

		if (i_a("crumbling wooden wheel") + i_a("tomb ratchet") < turnsNeeded) {
			bumAdv($location[The Upper Chamber], "", "", (turnsNeeded - i_a("tomb ratchet"))+" crumbling wooden wheel", "Getting the wheels needed to finish this", "-");
		}

		if (!contains_text(visit_url("place.php?whichplace=pyramid"),"action=pyramid_state1a") && my_adventures() > turnsNeeded / 3) {
			int turnsUsed = 0;
			if (item_amount($item[ancient bronze token]) == 0 && item_amount($item[ancient bomb]) == 0) {
				print("BCC: Getting the token.", "purple");
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
				turnsUsed = 0;
				while (turnsUsed < 3) {
					turnsUsed += 1;
					if (i_a("crumbling wooden wheel") > 0) {
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
					} else {
						run_choice(2); // visit_url("choice.php?whichchoice=929&option=2&pwd="+my_hash());
					}
				}
				run_choice(5); // visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}

			if (item_amount($item[ancient bronze token]) > 0 && item_amount($item[ancient bomb]) == 0) {
				print("BCC: Exchanging the token for bomb.", "purple");
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
				turnsUsed = 0;
				while (turnsUsed < 4) {
					turnsUsed += 1;
					if (i_a("crumbling wooden wheel") > 0) {
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
					} else {
						run_choice(2); // visit_url("choice.php?whichchoice=929&option=2&pwd="+my_hash());
					}
				}
				run_choice(5); // visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}
			
			if (item_amount($item[ancient bomb]) > 0) {
				print("BCC: Using the bomb to open the chamber.", "purple");
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
				turnsUsed = 0;
				while (turnsUsed < 3) {
					turnsUsed += 1;
					if (i_a("crumbling wooden wheel") > 0) {
						run_choice(1); // visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
					} else {
						run_choice(2); // visit_url("choice.php?whichchoice=929&option=2&pwd="+my_hash());
					}
				}
				run_choice(5); // visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}
		}
		
		//Fight Ed
		if (my_adventures() < 7) { abort("BCC: You don't have enough adventures to fight Ed."); }
		print("BCC: Fighting Ed", "purple");
		restore_hp(0);
		restore_mp(0);
		if (get_goals().count() > 0) cli_execute("goal clear");
		visit_url("place.php?whichplace=pyramid&action=pyramid_state1a");
		if (my_path() == "Heavy Rains") run_choice(1); // visit_url("choice.php?whichchoice=976&pwd&option=1"); // Start combat with Ed the Undrowning
		int fight_check = my_adventures();
		bumRunCombat();
		while (fight_check != my_adventures())
		{
			fight_check = my_adventures();
			adv1($location[The Lower Chambers], 0, "");
		}
		if (item_amount(to_item("2334")) != 0) { // Item 2334 is the Holy MacGuffin
			visit_url("council.php");
			set_property("lastCouncilVisit", my_level());
		}

	}
	if (contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme")) {
		checkStage("macguffinfinal", true);
		return true;
	}
	return false;
}

boolean bcascMacguffinHiddenCity() {
	boolean tryPull(item it) {
		
		if(pulls_remaining() > 0)
			if (take_storage(1, it))
				return true;
		return false;
	}

	void openStage(int shrineSnarfblat, string locationName) {
		if (contains_text(visit_url("place.php?whichplace=hiddencity"), locationName)) {
			return;
		}

		if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") equip($slot[weapon], $item[antique machete]);
		bumAdv(to_location(shrineSnarfblat), (my_path() == "Way of the Surprising Fist" || my_path() == "Avatar of Boris") ? "" : "-weapon, ", "", "1 choiceadv", "Opening "+locationName, "-");
	}

	if (checkStage("macguffinhiddencity")) return true;
	if (item_amount(to_item("2180")) > 0 || item_amount($item[Headpiece of the Staff of Ed]) > 0 || item_amount($item[Staff of Ed, almost]) > 0 || item_amount(to_item("2325")) > 0) { // Item 2180 is the Ancient Amulet and 2325 is the Staff of Ed
		checkStage("macguffinhiddencity", true);
		return true;
	}

	//1 - Get antique machete. 
	if (pulls_remaining() > 0 && available_amount($item[antique machete]) == 0) {
		tryPull($item[antique machete]);
	}

	if (available_amount($item[antique machete]) == 0) {
		set_property("choiceAdventure789", 2);
		bumAdv($location[The Hidden Park], "", "", "1 antique machete", "Getting the machete", "-");
	}

	//2 - Clear all vines and unlock hidden city area. 
	set_property("choiceAdventure781", "1");
	openStage(346, "The Hidden Apartment Building");
	set_property("choiceAdventure783", "1");
	openStage(347, "The Hidden Hospital");
	set_property("choiceAdventure785", "1");
	openStage(348, "The Hidden Office Building");
	set_property("choiceAdventure787", "1");
	openStage(349, "The Hidden Bowling Alley");
	set_property("choiceAdventure791", "1");
	set_property("choiceAdventure1002", "1");
	openStage(350, "Unlocked Ziggurat");

	//3 - Dumpster dive until 3 bowling balls or 3 outfit pieces. Then knock over dumpster.
	while (get_property("relocatePygmyJanitor") != my_ascensions()) {
		set_property("choiceAdventure789", "2");
		bumAdv($location[The Hidden Park], "", "", "1 choiceadv", "Relocating Pygmy Janitors from the buildings to the park.", "-");
	}

	//4 - Park until book of matches. (Use them)
	if (bcasc_unlockHiddenTavern && get_property("hiddenTavernUnlock").to_int() != my_ascensions()) {
		if (item_amount($item[book of matches]) == 0) {
			bumAdv($location[The Hidden Park], "", "items", "1 book of matches", "Getting the book of matches.", "i");
		}
		use(1, $item[book of matches]);
	}

	if (item_amount($item[stone triangle]) == 0) {
		//5 - Apartment: Get cursed three times. If we hit the NC without 3, get cursed, else fight spirit.
		while (item_amount($item[moss-covered stone sphere]) == 0) {
			if (my_thrall() == $thrall[Vampieroghi]) abort("BCC: Change your thrall. The Vampieroghi will keep removing the curse and wasting turns.");
			set_property("choiceAdventure780", "1");
			bumAdv($location[The Hidden Apartment Building], "5 elemental damage", "", "1 choiceadv", "Getting the moss-covered stone sphere.", "-");
		}

		//6 - Office: Get 5 McClusky files, and clip. Then fight spirit.
		while (item_amount($item[crackling stone sphere]) == 0) {
			set_property("choiceAdventure786", "1");
			bumAdv($location[The Hidden Office Building], "5 elemental damage", "", "1 choiceadv", "Getting the crackling stone sphere.", "-");
		}

		//7 - Hospital: Fight surgeons to get doctor gear, then wear it and defeat spirit.
		while (item_amount($item[dripping stone sphere]) == 0) {
			while (available_amount($item[bloodied surgical dungarees]) == 0 && available_amount($item[surgical apron]) == 0 && (available_amount($item[half-size scalpel]) == 0 || my_buffedstat($stat[muscle]) < $monster[protector spectre].base_defense) && available_amount($item[head mirror]) == 0 && available_amount($item[surgical mask]) == 0) {
				print("BCC: Adventuring one turn at a time to get surgeon's disguise.", "purple");
				bumMiniAdv(1, $location[The Hidden Hospital], "");
			}

			string equip = "5 elemental damage, ";
			if (available_amount($item[bloodied surgical dungarees]) > 0) {
				equip($slot[pants], $item[bloodied surgical dungarees]);
				equip += "-pants, ";
			}
			if (can_equip($item[surgical apron]) && available_amount($item[surgical apron]) > 0 && !contains_text(to_string(equipped_item($slot[shirt])), "Sneaky Pete")) {
				equip($slot[shirt], $item[surgical apron]);
				equip += "-shirt, ";
			}
			if (available_amount($item[half-size scalpel]) > 0 && my_buffedstat($stat[muscle]) > $monster[protector spectre].base_defense && my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") {
				equip($slot[weapon], $item[half-size scalpel]);
				equip += "-weapon, ";
			}
			if (available_amount($item[head mirror]) > 0) {
				equip($slot[acc1], $item[head mirror]);
				equip += "-acc1, ";
			}
			if (available_amount($item[surgical mask]) > 0) {
				equip($slot[acc2], $item[surgical mask]);
				equip += "-acc2, ";
			}

			set_property("choiceAdventure784", "1");
			bumAdv($location[The Hidden Hospital], equip, "", "1 choiceadv", "Getting the dripping stone sphere.", "-");
		}

		//8 - Bowling Alley: Adventure until have scorched stone sphere.
		while (item_amount($item[scorched stone sphere]) == 0) {
			set_property("choiceAdventure788", "1");
			bumAdv($location[The Hidden Bowling Alley], "+item drop, 5 elemental damage", "items", "1 scorched stone sphere", "Getting the scorched stone sphere.", "i-");
		}
	}

	//9 - Get stone triangles.
	if (item_amount($item[moss-covered stone sphere]) == 1) {
		bumMiniAdv(1, $location[An Overgrown Shrine (Northwest)], "");
	}
	if (item_amount($item[dripping stone sphere]) == 1) {
		bumMiniAdv(1, $location[An Overgrown Shrine (Southwest)], "");
	}
	if (item_amount($item[crackling stone sphere]) == 1) {
		bumMiniAdv(1, $location[An Overgrown Shrine (Northeast)], "");
	}
	if (item_amount($item[scorched stone sphere]) == 1) {
		bumMiniAdv(1, $location[An Overgrown Shrine (Southeast)], "");
	}

	//10 - Fight boss. 
	if (item_amount($item[stone triangle]) == 4) {
		if (my_path() != "Actually Ed the Undying") {
			set_property("choiceAdventure791", "1");
			print("BCC: Defeating the last Protector Spectre.", "purple");
			buMax("5 elemental damage");
			visit_url($location[A Massive Ziggurat].to_url()).runChoice();
			bumRunCombat();
} else {
			set_property("choiceAdventure1002", "1");
			bumAdv($location[A Massive Ziggurat], "", "", "1 choiceadv", "Visiting the last Protector Spectre.", "");
			checkStage("macguffinhiddencity", true);
			return true;
		}
	}

	if (item_amount(to_item("2180")) > 0) // Item 2180 is the ancient amulet
		checkStage("macguffinhiddencity", true);

	if (item_amount(to_item("2180")) > 0 || item_amount($item[Headpiece of the Staff of Ed]) > 0 || item_amount($item[Staff of Ed, almost]) > 0 || item_amount(to_item("2325")) > 0) { // Item 2180 is the ancient amulet and 2325 is the Staff of Ed
		return true;
	} else {
		print("There was a problem completing the hidden city quest. Please complete the quest manually, then run this script again to continue.", "red");
		abort();
	}
	
	return false;
}

boolean bcascOpenTemple() {
	while (item_amount($item[spooky temple map]) + item_amount($item[tree-holed coin]) == 0) {
		set_property("choiceAdventure502", "2");
		set_property("choiceAdventure505", "2");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get a Tree-Holed Coin", "-");
	}
	
	while (item_amount($item[spooky temple map]) == 0) {
		set_property("choiceAdventure502", "3");
		set_property("choiceAdventure506", "3");
		set_property("choiceAdventure507", "1");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get the map", "-");
	}
	
	while (item_amount($item[spooky-gro fertilizer]) == 0) {
		set_property("choiceAdventure502", "3");
		set_property("choiceAdventure506", "2");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get the fertilizer", "-");
	}
	
	while (item_amount($item[spooky sapling]) == 0 && my_adventures() > 0) {
		cli_execute("mood execute");
		if (contains_text(visit_url("adventure.php?snarfblat=15"), "Combat")) {
			bumRunCombat();
		} else {
			run_choice(1); // visit_url("choice.php?whichchoice=502&option=1&pwd="+my_hash());
			run_choice(3); // visit_url("choice.php?whichchoice=503&option=3&pwd="+my_hash());
			if (item_amount($item[bar skin]) > 0) run_choice(2); // visit_url("choice.php?whichchoice=504&option=2&pwd="+my_hash());
			run_choice(3); // visit_url("choice.php?whichchoice=504&option=3&pwd="+my_hash());
			run_choice(4); // visit_url("choice.php?whichchoice=504&option=4&pwd="+my_hash());
		}
	}
	
	print("Using Spooky Temple Map", "blue");
	return use(1, $item[spooky temple map]);
}

boolean bcascMacguffinPalindome() {
	if (checkStage("macguffinpalin")) return true;

	if (!contains_text(visit_url("questlog.php?which=1"), "Never Odd") && !contains_text(visit_url("questlog.php?which=2"), "Never Odd")) {
		bumAdv($location[Inside the Palindome], "+equip talisman o' namsilat", (in_hardcore()) ? "hebo" : "", "", "Adventuring once to unlock the Palindome quest", "i-", (in_hardcore()) ? "consultHeBo" : "", 1); 
	}

	while (contains_text(visit_url("questlog.php?which=1"), "Never Odd")) {
		while ((contains_text(visit_url("questlog.php?which=1"), "get into the Palindome") || contains_text(visit_url("questlog.php?which=1"), "Search for the Staff of Fats in ")) && !contains_text(visit_url("place.php?whichplace=palindome"), "drawkwardlabel.gif") && !(i_a("stunt nuts") > 0 && i_a("I Love Me Vol I") > 0 && i_a("photograph of a dog") > 0 && i_a("photograph of God") > 0 && i_a("photograph of a red nugget") > 0 && i_a("photograph of an ostrich egg") > 0)) {
			if (can_interact()) {
				retrieve_item(1, $item[stunt nuts]);
			}
			if (my_meat() < (500 * (2 - i_a("photograph of God") - i_a("photograph of a red nugget")))) abort("BCC: You're going to need more meat for this.");
			bumAdv($location[Inside the Palindome], "+equip talisman o' namsilat", (in_hardcore()) ? "hebo" : "", "1 stunt nuts, 1 I Love Me Vol I, photograph of a dog, photograph of God, photograph of a red nugget, photograph of an ostrich egg", "Getting all the quest items the Palindome has to offer", "i-", (in_hardcore()) ? "consultHeBo" : ""); 
		}
		
		//Unlock Dr. Awkward and Mr. Alarm
		buffer palindome;
		if(i_a("photograph of God") > 0) {
			if(my_path() != "Actually Ed the Undying") {
				if (equipped_amount($item[talisman o' namsilat]) == 0) equip($item[talisman o' namsilat]);
				use(1, $item[&quot;I Love Me\, Vol. I&quot;]);
				palindome = visit_url("place.php?whichplace=palindome&action=pal_drlabel");
				palindome = visit_url("choice.php?pwd&whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");
				use(1, $item[&quot;2 Love Me\, Vol. 2&quot;]);
				palindome = visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
			} else {
				if (equipped_amount($item[talisman o' namsilat]) == 0) equip($item[talisman o' namsilat]);
				use(1, $item[&quot;I Love Me\, Vol. I&quot;]);
				palindome = visit_url("place.php?whichplace=palindome&action=pal_drlabel");
				palindome = visit_url("choice.php?pwd&whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");
				checkStage("macguffinpalin", true);
				return true;
			}
		}
		
		/*if (item_amount($item[Cobb's Knob lab key]) == 0) abort("BCC: For some reason you don't have the lab key. Beat the goblin king manually and then restart the script. Sorry about that. ");
		while (my_adventures() > 0 && contains_text(visit_url("questlog.php?which=1"), "Fats, but then you lost it"))
			bumAdv($location[Cobb's Knob Laboratory], "", "", "1 choiceadv", "Meeting Mr. Alarm", "-");*/

		while(contains_text(visit_url("questlog.php?which=1"), "bowl of wet stunt nut stew")) {
			if (can_interact()) {
				retrieve_item(1, $item[wet stunt nut stew]);
			}
			while (item_amount($item[wet stunt nut stew]) < 1) {
				while (item_amount($item[wet stew]) == 0 && (item_amount($item[bird rib]) == 0 || item_amount($item[lion oil]) == 0)) {
					visit_url("guild.php?place=paco");
					run_choice(1);
					bumAdv($location[whitey's grove], "", "items", "1 lion oil, 1 bird rib", "Getting the wet stew items from Whitey's Grove", "+i"); 
				}
				
				//Note that we probably already have the stunt nuts
				while (i_a("stunt nuts") == 0)
					bumAdv($location[Inside the Palindome], "", "items", "1 stunt nuts", "Getting the stunt nuts from the the Palindome, which you should probably already have");
				create(1, $item[wet stunt nut stew]);
			}
			if (item_amount($item[wet stunt nut stew]) == 0) abort("BCC: Unable to cook up some tasty wet stunt nut stew.");
			
			//Get the Mega Gem
			if (i_a("mega gem") == 0)
			{
				if (equipped_amount($item[talisman o' namsilat]) == 0) equip($item[talisman o' namsilat]);
				palindome = visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
			}
		}
		
		if (i_a("mega gem") == 0) abort("BCC: That's weird. You don't have the Mega Gem.");
		
		//Fight Dr. Awkward
		cli_execute("restore hp; condition clear;");
		buMax("+equip Talisman o' Namsilat +equip Mega Gem");
		if (!in_hardcore()) {
			//Then we have to manually equip the talisman and mega gem because of buMax() limitations
			equip($slot[acc1], $item[Talisman o' Namsilat]);
			equip($slot[acc2], $item[Mega Gem]);
		}
		setFamiliar("meatboss");
		
		//Enter the fight
		palindome = visit_url("place.php?whichplace=palindome&action=pal_drlabel");
		palindome = visit_url("choice.php?pwd&whichchoice=131&option=1&choiceform1=War%2C+sir%2C+is+raw%21");
		bumRunCombat();
		
		if (item_amount(to_item("2268")) == 0) abort("BCC: Looks like Dr. Awkward opened a can of whoop-ass on you. Try fighting him manually."); // 2268 is non-Ed Staff of Fats
	}
	
	if (item_amount(to_item("2268")) > 0) { // 2268 is still the non-Ed Staff of Fats
		checkStage("macguffinpalin", true);
		return true;
	}

	return false;
}

boolean bcascMacguffinPrelim() {
	if (checkStage("macguffinprelim")) return true;

	while (!contains_text(visit_url("place.php?whichplace=woods"), "blackmarket.gif")) {	
		if (i_a("black map") == 0) {
			bumAdv($location[The Black Forest], "item", "itemsnc", "1 black map", "Finding the black map.", "-");
		}

		if (i_a("reassembled blackbird") == 0 && i_a("reconstituted crow") == 0) {
			if (i_a("sunken eyes") > 0 && i_a("broken wings") > 0) {
				cli_execute("make reassembled blackbird");
			} else if (i_a("bird brain") > 0 && i_a("busted wings") > 0) {
				cli_execute("make reconstituted crow");
			}
		}
		
		setFamiliar("blackforest");
		string max = "";
		if (i_a("reassembled blackbird") == 0 && i_a("reconstituted crow") == 0) {
			max = "item ";
		}
		buMax(max + "+combat");
		setMood((my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Actually Ed the Undying" ? max : max + "+"));
		cli_execute("mood execute");
		bumMiniAdv(1, $location[The Black Forest]);
	}
	
	if (item_amount($item[your father's MacGuffin diary]) + item_amount($item[copy of a jerk adventurer's father's diary]) == 0) {
		if (my_path() == "Way of the Surprising Fist" && item_amount($item[forged identification documents]) == 0) {
			abort("BCC: You need to fight Wu Tang the Betrayer to get the documents. He's really strong, so the script won't do this.");
		}
		
		print("BCC: Obtaining and Reading the Diary", "purple");
		if(!retrieve_item(1,$item[forged identification documents])) abort("BCC: You failed to acquire the forged identification documents. Do you lack the funds?");
		while (item_amount($item[your father's MacGuffin diary]) + item_amount($item[copy of a jerk adventurer's father's diary]) < 1 && my_adventures() > 2) {
			switch (my_primestat()) {
				case $stat[Muscle] :
					set_property("choiceAdventure793", "1");
				break;
				case $stat[Mysticality] :
					set_property("choiceAdventure793", "2");
				break;
				case $stat[Moxie] :
					set_property("choiceAdventure793", "3");
				break;
			}
			adventure(1, $location[The Shore, Inc. Travel Agency]);
		}
		if (item_amount($item[your father's MacGuffin diary]) > 0) use(1, $item[your father's MacGuffin diary]);
		else use(1, $item[copy of a jerk adventurer's father's diary]);
	}
	
	buMax("items");
	setFamiliar("itemsnc");
	setMood("-i");
	while (!contains_text(visit_url("place.php?whichplace=woods"),"hiddencitylink.gif") && my_adventures() > 3) {
		if (to_int(get_property("lastTempleUnlock")) != my_ascensions())
			bcascOpenTemple();
		traverse_temple();			
	}
	
	//At this point, Zarqon opens up the bedroom. But I'd like to do this earlier. 
	//Setting an abort() here to make sure we can get in. 
	if (get_property("questM21Dance") != "finished") abort("BCC: You'll need to open the Ballroom");
	while (!contains_text(visit_url("place.php?whichplace=manor1"),"place.php?whichplace=manor4")) {
		print("BCC: Opening the Spookyraven Cellar", "purple");
		set_property("choiceAdventure921", "1");
		bumMiniAdv(1, $location[The Haunted Ballroom]);
		betweenBattle();
	}
	
	if (cli_execute("make talisman o namsilat")) {}
	while (i_a("Talisman o' Namsilat") == 0) {
		//We will almost certainly have the fledges equipped due to maximizing our Moxie. We re-equip them if we don't have them. 
		string maxstring = "+equip pirate fledges";
		if (my_basestat($stat[mysticality]) < 60) maxstring = "+outfit swashbuckling getup";
		
		buMax(maxstring);
		if (!contains_text(visit_url("place.php?whichplace=cove"), to_url($location[Belowdecks]))) {
			if (get_property("choiceAdventure189") == "0") {
				set_property("choiceAdventure189", 2);
			}
			set_property("oceanAction", "continue");
			set_property("oceanDestination", my_primestat().to_string());
			bumAdv($location[The Poop Deck], maxstring, "", "", "Opening Belowdecks", "-");
		}
		bumAdv($location[Belowdecks], maxstring, "", "2 gaudy key", "Getting the Talisman");
		if (cli_execute("make talisman o namsilat")) {}
	}
	
	checkStage("macguffinprelim", true);
	return true;
}

boolean bcascMacguffinSpooky() {
	if (checkStage("macguffinspooky")) return true;
	if (contains_text(visit_url("questlog.php?which=1"),"Spooking")) {
		if (!contains_text(visit_url("questlog.php?which=1"),"secret black magic laboratory")) {
			//Get the Spectacles if you don't have them already. 
			if (i_a("Lord Spookyraven's spectacles") == 0) {
				//Correctly set Ornate Nightstand
				set_property("choiceAdventure878", 3);
				bumAdv($location[The Haunted Bedroom], "", "", "Lord Spookyraven's spectacles", "Getting the Spectacles");
			}
		}

		buffer page = visit_url("place.php?whichplace=manor4");
		if (contains_text(page, "manor4_chamberwall") && item_amount($item[recipe: mortar-dissolving solution]) == 0) {
			page = visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
			equip($item[lord spookyraven's spectacles]);
			use(1, $item[recipe: mortar-dissolving solution]);
		}

		if (contains_text(page, "manor4_chamberwall")) {
			if (bcasc_cellarWineBomb && (contains_text(visit_url("questlog.php?which=1"),"Gather the explosive ingredients") || contains_text(visit_url("questlog.php?which=1"),"Heat up the explosive mixture"))
					&& my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris" && my_path() != "Nuclear Autumn") {
				if (available_amount($item[unstable fulminate]) == 0 && item_amount($item[wine bomb]) == 0) {
					if (item_amount($item[bottle of Chateau de Vinegar]) == 0) {
						bumAdv($location[The Haunted Wine Cellar], "item", "items", "1 bottle of Chateau de Vinegar", "Collecting ingredients for a wine bomb", "i");
					}
					
					if (item_amount($item[blasting soda]) == 0) {
						bumAdv($location[The Haunted Laundry Room], "item", "items", "1 blasting soda", "Collecting ingredients for a wine bomb", "i");
					}
					
					cli_execute("make unstable fulminate");
				}
				
				if (available_amount($item[unstable fulminate]) > 0 && item_amount($item[wine bomb]) == 0) {
					bumAdv($location[The Haunted Boiler Room], "ml, -shield, +equip unstable fulminate", "ml", "1 wine bomb", "Making a wine bomb", "l");
				}
			} else {
				if (item_amount($item[loosening powder]) == 0) {
					bumAdv($location[The Haunted Kitchen], "", "", "1 loosening powder", "Collecting ingredients for mortar-dissolver", "-");
				}
				if (item_amount($item[powdered castoreum]) == 0) {
					bumAdv($location[The Haunted Conservatory], "", "", "1 powdered castoreum", "Collecting ingredients for mortar-dissolver", "-");
				}
				if (item_amount($item[drain dissolver]) == 0) {
					bumAdv($location[The Haunted Bathroom], "", "", "1 drain dissolver", "Collecting ingredients for mortar-dissolver", "-");
				}
				if (item_amount($item[triple-distilled turpentine]) == 0) {
					bumAdv($location[The Haunted Gallery], "", "", "1 triple-distilled turpentine", "Collecting ingredients for mortar-dissolver", "-");
				}
				if (item_amount($item[detartrated anhydrous sublicalc]) == 0) {
					bumAdv($location[The Haunted Laboratory], "", "", "1 detartrated anhydrous sublicalc", "Collecting ingredients for mortar-dissolver", "-");
				}
				if (item_amount($item[triatomaceous dust]) == 0) {
					bumAdv($location[The Haunted Storage Room], "", "", "1 triatomaceous dust", "Collecting ingredients for mortar-dissolver", "-");
				}
			}
			page = visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		}
		
		if (contains_text(page, "manor4_chamberboss")) {
			if (my_path() != "Actually Ed the Undying") {
				buMax();
				print("BCC: Fighting Spookyraven", "purple");
				restore_hp(my_maxhp());
				if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) {
					cli_execute("cast Elemental Saucesphere");
				} else {
					cli_execute("use can of black paint");
				}

				setFamiliar("meatboss");
				visit_url("place.php?whichplace=manor4&action=manor4_chamberboss");
				bumRunCombat();
				if (item_amount(to_item("2286")) == 0) abort("BCC: The Spooky man pwned you with his evil. Fight him yourself."); // Item 2286 is the non-Ed Eye of Ed
			} else {
				print("BCC: Visiting Spookyraven", "purple");
				visit_url("place.php?whichplace=manor4&action=manor4_chamberboss");
				checkStage("macguffinspooky", true);
				return true;
			}
		}
	}

	if (item_amount(to_item("2286")) > 0) { // Item 2286 is still the non-Ed Eye of Ed
		checkStage("macguffinspooky", true);
		return true;
	}
	
	return false;
}

boolean bcascMacguffinPyramid() {
	boolean canEquipCompass() {
		return (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris" && my_path() != "Nuclear Autumn");
	}
	
	string compassEquip() {
		if (canEquipCompass()) {
			return "+equip UV-resistant compass";
		}
		return "";
	}

	if (checkStage("macguffinpyramid")) return true;
	
	if (!contains_text(visit_url("questlog.php?which=1"),"Just Deserts") || contains_text(visit_url("questlog.php?which=1"),"found the little pyramid") || contains_text(visit_url("questlog.php?which=1"),"found the hidden buried pyramid")) {
		//We've done the pyramid
		return checkStage("macguffinpyramid", true);
	} else {
		//Get the UV Compass.
		if (canEquipCompass()) {
			if (i_a("UV-resistant compass") == 0) {
				print("BCC: You do not have a UV Compass. Let's get one.", "purple");
				if (i_a("Shore Inc. Ship Trip Scrip") == 0) {
					adventure(1, $location[The Shore\, Inc. Travel Agency]);
				}
				cli_execute("acquire UV-resistant compass");
			}
		} else {
			print("BCC: You cannot equip a UV Compass. Let's not get one.", "purple");
		}
		
		set_property("choiceAdventure805", 1);
		
		//First, we need the Oasis and Gnasir to appear. If there's no Oasis, then we should spend 10 adventures in the Desert. 
		if (!contains_text(visit_url("place.php?whichplace=desertbeach"), to_url($location[The Oasis]))) {
			print("BCC: Oasis doesn't appear - let's spend ten adventures.", "purple");
			bumAdv($location[The Arid\, Extra-Dry Desert], compassEquip(), "", "", "", "", "", 10);
		}
		
		//If there IS an oasis, then we need to spend enough adventures in the desert to get Gnasir to appear. 
		while (!contains_text(visit_url("place.php?whichplace=desertbeach"), "gnasir.gif") && my_adventures() > 0) {
			print("BCC: Getting ultrahydrated and then getting Gnasir to appear.", "purple");
			if (have_effect($effect[Ultrahydrated]) == 0) {
				bumAdv($location[The Oasis], "items", "items", "", "", "", "", 1);
			}
			if (have_effect($effect[Ultrahydrated]) > 0) {
				bumAdv($location[The Arid\, Extra-Dry Desert], compassEquip(), "", "", "", "", "", have_effect($effect[Ultrahydrated]));
			}
		}
		
		//Right, now we have gnasir. Let's check what he wants.
		print("BCC: I see that gnasir is there. Let's see what he wants.", "purple");
		visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
		run_choice(1); // visit_url("choice.php?whichchoice=805&option=1&pwd=");
		run_choice(1); // visit_url("choice.php?whichchoice=805&option=1&pwd=");
		
		int gnasir = get_property("gnasirProgress").to_int();
		if ((gnasir & 2) == 0) {
			print("BCC: Gnasir needs a can of black paint.", "purple");
			if (i_a("can of black paint") == 0 && my_meat() > 1000) {
				cli_execute("acquire can of black paint");
			}
			if (i_a("can of black paint") > 0) {
				print("BCC: And you have one! Yay!", "purple");
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
//				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				run_choice(2); // visit_url("choice.php?whichchoice=805&option=2&pwd=");
				run_choice(1); // visit_url("choice.php?whichchoice=805&option=1&pwd=");
			}
		}
		if ((gnasir & 4) == 0) {
			print("BCC: Gnasir needs a killing jar.", "purple");
			if (i_a("killing jar") > 0) {
				print("BCC: And you have one! Yay!", "purple");
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
//				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				run_choice(2); // visit_url("choice.php?whichchoice=805&option=2&pwd=");
				run_choice(1); // visit_url("choice.php?whichchoice=805&option=1&pwd=");
			}
		}
		if ((gnasir & 1) == 0) {
			print("BCC: Gnasir needs a stone rose.", "purple");
		}
		if ((gnasir & 8) == 0 || (gnasir & 16) == 0) {
			print("BCC: Gnasir needs a worm-riding manual.", "purple");
		}
		if (item_amount($item[desert sightseeing pamphlet]) > 0) {
			use(item_amount($item[desert sightseeing pamphlet]), $item[desert sightseeing pamphlet]);
		}
		
		while (my_adventures() > 0 && get_property("desertExploration").to_int() < 100)
		{
			if (item_amount($item[desert sightseeing pamphlet]) > 0) {
				use(item_amount($item[desert sightseeing pamphlet]), $item[desert sightseeing pamphlet]);
			}
			else if (i_a("stone rose") > 0) {
				print("BCC: Gnasir wants your stone rose.", "purple");
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
//				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				run_choice(2); // visit_url("choice.php?whichchoice=805&option=2&pwd=");
				run_choice(1); // visit_url("choice.php?whichchoice=805&option=1&pwd=");
			}
			else if (i_a("worm-riding manual page") > 14) {
				print("BCC: Gnasir wants to help you ride the majestic worms.", "purple");
				visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
//				visit_url("choice.php?whichchoice=805&option=1&pwd=");
				run_choice(2); // visit_url("choice.php?whichchoice=805&option=2&pwd=");
				run_choice(1); // visit_url("choice.php?whichchoice=805&option=1&pwd=");
			}
			else if (i_a("worm-riding hooks") > 0) {
				if (i_a("drum machine") > 0) {
					use(1, $item[drum machine]);
				}
				else {
					bumAdv($location[The Oasis], "items", "items", "drum machine", "Getting a drum machine", "", "");
				}
			}
			else if (have_effect($effect[Ultrahydrated]) == 0) {
				bumAdv($location[The Oasis], compassEquip(), "", "", "", "", "", ((get_property("gnasirProgress").to_int() & 1) == 0) ? 2 : 1);
			}
			else {
				bumAdv($location[The Arid\, Extra-Dry Desert], compassEquip(), "", "", "", "", "", min(have_effect($effect[Ultrahydrated]), my_adventures()));
			}
		}
		if (get_property("desertExploration").to_int() < 100)
		{
			abort("BCC: You ran out of adventures while exploring the desert. Explore some more tomorrow.");
		}
	}
	
	checkStage("macguffinpyramid", true);
	return true;
}

boolean bcascManorBathroom() {
	if (is_at_least(get_property("questM21Dance"), "step3") || i_a("Lady Spookyraven's powder puff") > 0) return true;

	string questLog = visit_url("questlog.php?which=1");
	if(contains_text(questLog, "Lady Spookyraven's Dance")) {
		if (!contains_text(questLog, "her powder puff from the Haunted Bathroom") && contains_text(questLog, "her powder puff")) {
			return true;
		}
	} else if(contains_text(questLog, "Lady Spookyraven's Babies")) {
			return true;
	} else {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		questLog = visit_url("questlog.php?which=2");
		if(contains_text(questLog, "Lady Spookyraven's Dance") || contains_text(questLog, "Lady Spookyraven's Babies") || is_at_least(get_property("questM21Dance"), "step3")) {
			return true;
		}
	}

#	if (my_buffedstat(my_primestat()) >= 85) {
		switch (my_primestat()) {
			case $stat[Muscle] :		set_property("choiceAdventure402", "1");	break;
			case $stat[Mysticality] :	set_property("choiceAdventure402", "2");	break;
			case $stat[Moxie] :			set_property("choiceAdventure402", "3");	break;
		}

		while (i_a("Lady Spookyraven's powder puff") == 0) {
			if (get_property("guyMadeOfBeesCount") < 4) {
				set_property("choiceAdventure105","3"); // say "guy made of bees"
			} else {
				set_property("choiceAdventure105","2");
				set_property("choiceAdventure107","4"); // skip adventure 
			}
		
			buMax("-combat");
			setMood((my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Actually Ed the Undying" ? "" : "-"));
			cli_execute("mood execute");
			bumMiniAdv(1, $location[The Haunted Bathroom]);
		}

		if (i_a("Lady Spookyraven's powder puff") > 0) {
			return true;
		}
#	}

	return false;
}

boolean bcascManorBedroom() {
	if (is_at_least(get_property("questM21Dance"), "step3") || i_a("Lady Spookyraven's finest gown") > 0) return true;

	string questLog = visit_url("questlog.php?which=1");
	if(contains_text(questLog, "Lady Spookyraven's Dance")) {
		if (!contains_text(questLog, "her gown from the Haunted Bedroom") && contains_text(questLog, "her gown")) {
			return true;
		}
	} else if(contains_text(questLog, "Lady Spookyraven's Babies")) {
			return true;
	} else {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		questLog = visit_url("questlog.php?which=2");
		if(contains_text(questLog, "Lady Spookyraven's Dance") || contains_text(questLog, "Lady Spookyraven's Babies") || is_at_least(get_property("questM21Dance"), "step3")) {
			return true;
		}
	}

	if (my_path() == "Way of the Suprising Fist") {
		set_property("choiceAdventure876", "2"); // White=Muscle
	} else {
		set_property("choiceAdventure876", "1"); // White=Wallet
	}
	set_property("choiceAdventure877", "1"); // Mahogany=Coin Purse (We don't want to fight or get nothing from under the nightstand)
	set_property("choiceAdventure878", "4"); // Ornate=Camera
	set_property("choiceAdventure879", "1"); // Rustic=Moxie
	set_property("choiceAdventure880", "1"); // Elegant=Gown

#	if(my_buffedstat(my_primestat()) >= 85) {
		while (i_a("disposable instant camera") == 0) {
			bumAdv($location[The Haunted Bedroom], "", "", "disposable instant camera", "Getting a disposable instant camera");
		}

		if (i_a("Lord Spookyraven's spectacles") == 0) {
			set_property("choiceAdventure878", "3"); // Ornate=Spectacles
		} else {
			set_property("choiceAdventure878", "1"); // Ornate=Meat
		}
		while (i_a("Lady Spookyraven's finest gown") == 0) {
			bumAdv($location[The Haunted Bedroom], "", "", "Lady Spookyraven's finest gown", "Getting Lady Spookyraven's finest gown");
		}

		if (i_a("Lady Spookyraven's finest gown") > 0) {
			return true;
		}
#	}

	return false;
}

boolean bcascManorGallery() {
	if (is_at_least(get_property("questM21Dance"), "step3") || i_a("Lady Spookyraven's dancing shoes") > 0) return true;

	string questLog = visit_url("questlog.php?which=1");
	if(contains_text(questLog, "Lady Spookyraven's Dance")) {
		if (!contains_text(questLog, "her shoes from the Haunted Gallery") && contains_text(questLog, "her shoes")) {
			return true;
		}
	} else if(contains_text(questLog, "Lady Spookyraven's Babies")) {
			return true;
	} else {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		questLog = visit_url("questlog.php?which=2");
		if(contains_text(questLog, "Lady Spookyraven's Dance") || contains_text(questLog, "Lady Spookyraven's Babies") || is_at_least(get_property("questM21Dance"), "step3")) {
			return true;
		}
	}

#	if (my_buffedstat(my_primestat()) >= 85) {
		set_property("louvreGoal", "7");
		set_property("louvreDesiredGoal", "7");
		bumAdv($location[The Haunted Gallery], "", "", "Lady Spookyraven's dancing shoes", "Getting Lady Spookyraven's dancing shoes", "-");

		if (i_a("Lady Spookyraven's dancing shoes") > 0) {
			set_property("louvreGoal", "4");
			set_property("louvreDesiredGoal", "4");
			return true;
		}
#	}

	return false;
}

boolean bcascManorBallroom() {
	if (is_equal_to(get_property("questM21Dance"), "finished") || is_past(get_property("questM17Babies"), "unstarted")) return true;

	if (i_a("Lady Spookyraven's powder puff") + i_a("Lady Spookyraven's finest gown") + i_a("Lady Spookyraven's dancing shoes") >= 3) {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
	}

	if (is_not_yet(get_property("questM21Dance"), "finished")) {
		bumMiniAdv(1, $location[The Haunted Ballroom]);
# Actually, don't unlock the third floor because it isn't needed or useful. We can adventure there anyways, and we don't use the quest log for status anymore.		
#		visit_url("place.php?whichplace=manor3"); // Due to the KoL bug where we don't actually need to unlock the third floor to adventure there, we should skip the unlock to not accidentally trigger the kids
#		visit_url("place.php?whichplace=manor3&action=manor3_ladys"); // But due to KoL not tracking any Lady quests if you finish the second and don't do the third, we'll start the third quest anyways
#		return true;
	}

	if (get_property("questM21Dance") == "finished" || contains_text(visit_url("place.php?whichplace=manor2"), "snarfblat=395")) {
		return true;
	}

	return false;
}

boolean bcascManorBilliards() {
	if (is_at_least(get_property("questM20Necklace"), "step3")) return true;

	//Kitchen
	if (item_amount($item[Spookyraven billiards room key]) == 0) {
		print("BCC: Getting the Billiards Key", "purple");
		buMax("+1000 stench res");
		while (item_amount($item[Spookyraven billiards room key]) == 0) {
			if (have_effect($effect[elemental saucesphere]) == 0 && have_skill($skill[elemental saucesphere])) use_skill(1, $skill[elemental saucesphere]);
			if (have_effect($effect[astral shell]) == 0 && have_skill($skill[astral shell]) && have_castitems($class[turtle tamer], true)) use_skill(1, $skill[astral shell]);
			bumMiniAdv(1, $location[The Haunted Kitchen]);
		}
	}

	//Billiards Room
	while (item_amount($item[Spookyraven library key]) == 0) {
		while (i_a("pool cue") == 0) {
			bumAdv($location[The Haunted Billiards Room], (my_primestat() == $stat[mysticality]) ? "" : "+100000 elemental dmg", "", "1 pool cue", "Getting the Pool Cue", "-i");
		}

		print("BCC: Getting the Library Key", "purple");
		while (item_amount($item[Spookyraven library key]) == 0) {
			if (i_a("handful of hand chalk") > 0 || have_effect($effect[Chalky Hand]) > 0) {
				if (my_adventures() == 0) abort("BCC: No adventures."); 
				print("BCC: We have either a hand chalk or Chalky Hands already, so we'll use the hand chalk (if necessary) and play some pool!", "purple");
				if (i_a("handful of hand chalk") > 0 && have_effect($effect[Chalky Hand]) == 0) {
					use(1, $item[handful of hand chalk]);
				}
				cli_execute("goal clear");
				cli_execute("goal set 1 Spookyraven library key");
				if (can_equip($item[pool cue])) equip($slot[weapon], $item[pool cue]);
				buMax((my_primestat() == $stat[mysticality] ? "" : "+100000 elemental dmg, ")+(can_equip($item[pool cue]) ? "-weapon, -offhand, -shield " : ""));
				if (bumMiniAdvNoAbort(have_effect($effect[Chalky Hand]), $location[The Haunted Billiards Room])) {}
			} else {
				bumMiniAdv(1, $location[The Haunted Billiards Room]);
			}
		}
	}
	if (item_amount($item[Spookyraven library key]) > 0) {
		return true;
	}
	return false;
}

boolean bcascManorLibrary() {
	if (is_equal_to(get_property("questM20Necklace"), "finished")) return true;
	
	//Open up the second floor of the manor. 
	if (is_equal_to(get_property("questM20Necklace"), "step3")) {
		bumAdv($location[The Haunted Library], "", "", "1 lady spookyraven's necklace", "Opening Second floor of the Manor", "+");
	}
	if (item_amount($item[lady spookyraven's necklace]) > 0 && is_equal_to(get_property("questM20Necklace"), "step4")) {
		visit_url("place.php?whichplace=manor1&action=manor1_ladys");
	}
	if (is_equal_to(get_property("questM20Necklace"), "finished")) {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		return true;
	}
	return false;
}

boolean bcascMeatcar() {
	if (checkStage("meatcar")) return true;
	
	if (contains_text(visit_url("place.php?whichplace=desertbeach"), "db_shore")) return checkStage("meatcar", true);
	if (my_path() == "Nuclear Autumn") return false;
	
	if (my_path() != "Bees Hate You" || knoll_available()) {
		if (item_amount($item[bitchin' meatcar]) + item_amount($item[pumpkin carriage]) + item_amount($item[desert bus pass]) == 0) {
			print("BCC: Getting the Meatcar", "purple");
			//Gotta hit up paco.
			visit_url("guild.php?place=paco");
			if (item_amount($item[sweet rims]) + item_amount($item[dope wheels]) == 0)
				cli_execute("buy 1 sweet rims");
			
			if (!knoll_available()) {
				print("BCC: Making the meatcar, getting the stuff from the Gnolls. Damned Gnolls...", "purple");
				visit_url("place.php?whichplace=forestvillage&action=fv_untinker_quest");
				visit_url("place.php?whichplace=forestvillage&preaction=screwquest&action=fv_untinker_quest");
				buMax();
				use(item_amount($item[gnollish toolbox]), $item[gnollish toolbox]);
				while (creatable_amount($item[bitchin' meatcar]) == 0) {
					use(item_amount($item[gnollish toolbox]), $item[gnollish toolbox]);
					if (my_adventures() == 0) abort("BCC: No Adventures");
					bumMiniAdv(1, $location[The Degrassi Knoll Garage]);
				}
			}
			cli_execute("make bitchin' meatcar");
			visit_url("guild.php?place=paco");
		}
	} else if(i_a("pumpkin") > 0) {
		if (item_amount($item[pumpkin carriage]) + item_amount($item[desert bus pass]) == 0) {
			print("BCC: Bees hate You: Getting a Pumpkin Carriage", "purple");
			//Gotta hit up paco.
			visit_url("guild.php?place=paco");
			if (item_amount($item[sweet rims]) + item_amount($item[dope wheels]) == 0)
				cli_execute("buy 1 sweet rims");
				
			print("BCC: Making the dope wheels, getting the stuff from the Gnolls. Damned Gnolls...", "purple");
			visit_url("forestvillage.php?action=screwquest&submit=&quot;Sure Thing.&quot;");			
			buMax();
			while (creatable_amount($item[dope wheels]) == 0) {
				if (my_adventures() == 0) abort("BCC: No Adventures");
				bumMiniAdv(1, $location[The Degrassi Knoll Garage]);
			}
			cli_execute("make pumpkin carriage");
			visit_url("guild.php?place=paco");
		}
	} else {
		if(my_meat() > 5000)
			cli_execute("buy 1 desert bus pas");
		else
			abort("BCC: Bees Hate You. You have no pumpkins. You have no meat. Go fix!");
	}
	checkStage("meatcar", true);
	return true;
}

//Thanks, picklish!
boolean bcascMining() {
	if (checkStage("mining")) return true;

	string trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	if (my_level() >= 8 && !contains_text(trapper, "ore")) {
		print("Looks like we're done.", "purple");
		checkStage("mining", true);
		return true;
	}

	string quest = visit_url("questlog.php?which=2");
	if (my_level() >= 8 && contains_text(quest, "helped the Trapper")) {
		print("Looks like we're done with the whole quest.", "purple");
		checkStage("mining", true);
		return true;
	}

	string goalString = get_property("trapperOre");
	item goal = to_item(goalString);

	if (goal != $item[asbestos ore] && goal != $item[chrome ore] && goal != $item[linoleum ore])
		abort("BCC: Can't figure out which ore to look for.");

	// Seed ore locations with what mafia knows about.
	int[int] oreLocations;
	string mineLayout = get_property("mineLayout1");
	int start = 0;
	while (true) {
		int num_start = index_of(mineLayout, '#', start);
		if (num_start == -1) break;
		int num_end = index_of(mineLayout, '<', num_start);
		if (num_end == -1) break;
		int end = index_of(mineLayout, '>', num_end);
		if (end == -1) break;

		if (contains_text(substring(mineLayout, num_end, end), goalString)) {
			int spot = to_int(substring(mineLayout, num_start + 1, num_end));
			oreLocations[count(oreLocations)] = spot;
		}
		start = end;
	}

	boolean rowContainsEmpty(string mine, int y) {
		for x from 1 to 6 {
			if (contains_text(mine, "Open Cavern (" + x + "," + y + ")"))
				return true;
		}

		return false;
	}

	boolean canMine(string mine, int x, int y, boolean onlySparkly) {
		if (x < 0 || x > 7 || y < 0 || y > 7) return false;
		int index = x + y * 8; 
		boolean clickable = (index_of(mine, "mining.php?mine=1&which=" + index + "&") != -1);

		if (!clickable || !onlySparkly) return clickable;

		return contains_text(mine, "Promising Chunk of Wall (" + x + "," + y + ")");
	}

	int adjacentSparkly(string mine, int index) {
		int x = index % 8;
		int y = index / 8;

		if (canMine(mine, x, y - 1, true)) return index - 8;
		if (canMine(mine, x - 1, y, true)) return index - 1;
		if (canMine(mine, x + 1, y, true)) return index + 1;
		if (canMine(mine, x, y + 1, true)) return index + 8;
		return - 1;
	}

	int findSpot(string mine, boolean[int] rows, boolean[int] cols) {
		foreach sparkly in $booleans[true, false] {
			foreach y in cols {
				foreach x in rows {
					if (canMine(mine, x, y, sparkly))
						return x + y * 8;
				}
			}
		}
		return -1;
	}
	if(my_path() != "Avatar of Boris") {
		if (my_path() != "Way of the Surprising Fist") {
			cli_execute("outfit mining gear");
		} else {
			if (!have_skill($skill[Worldpunch])) abort("BCC: You need the skill Worldpunch, grasshopper.");
		}
	}

	while (item_amount(goal) < 3) {
		if(my_path() != "Avatar of Boris") {
			if (my_hp() == 0) cli_execute("restore hp");
			if ((my_path() == "Way of the Surprising Fist") && (have_effect($effect[Earthen Fist]) == 0)) {
				if (my_mp() < mp_cost($skill[Worldpunch])) restore_mp(mp_cost($skill[Worldpunch]));
				cli_execute("cast Worldpunch");
			}
				
			string mine = visit_url("mining.php?intro=1&mine=1");
			if (contains_text(mine, "You can't mine without the proper equipment.")) abort("BCC: Couldn't equip mining gear.");

			boolean willCostAdventure = contains_text(mine, "takes one Adventure.");
			if (have_skill($skill[Unaccompanied Miner]) && willCostAdventure && have_effect($effect[Teleportitis]) == 0 && my_level() < 12) {
				if (bcasc_MineUnaccOnly) {
					print("BCC: No more mining today. I'll come back later.", "purple");
					return false;
				}
			}
			if (my_adventures() == 0 && willCostAdventure) abort("BCC: No Adventures");
			int choice = -1;
			string why = "Mining around found ore";
			// Ore is always coincident, so look nearby if we've aleady found some.
			if (count(oreLocations) > 0) {
				foreach key in oreLocations {
					choice = adjacentSparkly(mine, oreLocations[key]);
					if (choice != -1)
						break;
				}
			}


			// Prefer mining the middle first.  It leaves more options.
			boolean[int] rows = $ints[3, 4, 2, 5, 1, 6];
			// First, try to mine up to the top four rows if we haven't yet.
			if (choice == -1 && !rowContainsEmpty(mine, 6)) {
				choice = findSpot(mine, rows, $ints[6]);
				why = "Mining upwards";
			} 
			if (choice == -1 && !rowContainsEmpty(mine, 5)) {
				choice = findSpot(mine, rows, $ints[5]);
				why = "Mining upwards";
			}
					
			// Top three rows contain most ore.  Fourth row may contain ore.
			// Prefer second row and digging towards the middle because it
			// opens up the most potential options.  This could be more
			// optimal, but it's not a bad heuristic.
			if (choice == -1) {
				choice = findSpot(mine, rows, $ints[2, 3, 1, 4]);
				why = "Mining top four rows";
			}
			// There's only four pieces of the same ore in each mine.
			// Maybe you accidentally auto-sold them or something?
			if (choice == -1 || count(oreLocations) == 4) {
				print("BCC: Resetting mine!", "purple");
				visit_url("mining.php?mine=1&reset=1&pwd");
				oreLocations.clear();
				continue;
			}
			print(why + ": " + (choice % 8) + ", " + (choice / 8) + ".", "purple");
			string result = visit_url("mining.php?mine=1&which=" + choice + "&pwd");
			if (index_of(result, goalString) != -1) {
				oreLocations[count(oreLocations)] = choice;
			}
		}
		else {
			bumAdv($location[Itznotyerzitz Mine], "", "items", "3 " + goal, "Adventuring for the ore of the mountain man.", "i");
		}
	}

	if (have_effect($effect[Beaten Up]) > 0) cli_execute("uneffect beaten up");
	visit_url("place.php?whichplace=mclargehuge&action=trappercabin");

	checkStage("mining", true);
	return true;
}

boolean bcascMirror() {
	if(my_path() != "Bees Hate You") return false;
	if(checkStage("mirror")) return true;

	set_property("choiceAdventure85", 3);
	while(i_a("antique hand mirror") == 0) {
		bumAdv($location[The Haunted Bedroom], "", "itemsnc", "antique hand mirror", "Getting an anqique hand mirror to tackle the end boss.", "-i");
	}
	
	checkStage("mirror", true);
	return true;
}

void bcascNaughtySorceress() {
	if (my_path() == "Actually Ed the Undying") {
		bcascLairEd();
		return;
	}
	else if (my_path() == "Bugbear Invasion") {
		bcascLairFightNS();
		return;
	}
	if (is_not_yet(get_property("questL13Final"), "started")) {
		abort("BCC: You need to actually START the quest before you can solve it. Y'know.");
	}
	if (is_not_yet(get_property("questL13Final"), "step2")) {
		if (get_property("nsContestants1").to_int() < 0) {
			tripleMaximize("init, -tie", 1.0);
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			run_choice(1);
			run_choice(6);
		}
		if (get_property("nsContestants2").to_int() < 0) {
			tripleMaximize(get_property("nsChallenge1")+", -tie", 1.0);
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			run_choice(2);
			run_choice(6);
		}
		if (get_property("nsContestants3").to_int() < 0) {
			tripleMaximize(get_property("nsChallenge2")+" damage, "+get_property("nsChallenge2")+" spell damage, -tie", 1.0);
			visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
			run_choice(3);
			run_choice(6);
		}
		buMax();
		if (get_property("nsContestants1").to_int() > 0) if (!adventure(get_property("nsContestants1").to_int(), $location[Fastest Adventurer Contest])) abort("BCC: Didn't manage to complete the Fast test.");
		if (get_property("nsContestants2").to_int() > 0) if (!adventure(get_property("nsContestants2").to_int(), $location[A Crowd of (Stat) Adventurers])) abort("BCC: Didn't manage to complete the Stat test.");
		if (get_property("nsContestants3").to_int() > 0) if (!adventure(get_property("nsContestants3").to_int(), $location[A Crowd of (Element) Adventurers])) abort("BCC: Didn't manage to complete the Elemental test.");
		if (get_property("nsContestants1").to_int()+get_property("nsContestants2").to_int()+get_property("nsContestants3").to_int() != 0) abort("BCC: You seem to still have some adventurers remaining, which your automated combat failed to finish. You can either relaunch the script and hope it works this time, or run it manually.");
	}
	if (is_equal_to(get_property("questL13Final"), "step2")) {
		visit_url("place.php?whichplace=nstower&action=ns_01_contestbooth");
		run_choice(4);
	}
	if (is_equal_to(get_property("questL13Final"), "step3")) {
		visit_url("place.php?whichplace=nstower&action=ns_02_coronation");
		run_choice(1);
		run_choice(1);
		run_choice(1);
	}
	if (is_equal_to(get_property("questL13Final"), "step4")) {
		buMax();
		if (!hedge_maze(get_property("bcasc_mazePath") != "" ? get_property("bcasc_mazePath") : "nugglets")) abort("BCC: Something stopped us from getting through the maze");
	}
	if (is_equal_to(get_property("questL13Final"), "step5")) {
		if (!tower_door()) abort("BCC: We apparently still need some keys.");
	}
	if (is_equal_to(get_property("questL13Final"), "step6")) {
		if (item_amount($item[beehive]) < 1) { if (get_goals().count() > 0) cli_execute("goals clear"); add_item_condition(1, $item[beehive]); adventure(my_adventures(),$location[The Black Forest]); }
		if (item_amount($item[beehive]) < 1) abort("BCC: We still need to get the beehive.");
		visit_url("place.php?whichplace=nstower&action=ns_05_monster1");
		visit_url("fight.php?action=macro&macrotext=use " + to_int($item[beehive]));
	}
	if (is_equal_to(get_property("questL13Final"), "step7")) {
		setFamiliar("meatnuns");
		tripleMaximize("meat, -tie", 5.0);
		buMax("5 meat");
		while (my_adventures() > 0 && get_property("questL13Final") == "step7") if (!adventure(1, $location[Tower Level 2]) || !run_combat().contains_text("WINWINWIN")) abort("BCC: We can't beat the meat.");
	}
	if (is_equal_to(get_property("questL13Final"), "step8")) {
		setFamiliar("");
		if (item_amount($item[electric boning knife]) < 1) { if (get_goals().count() > 0) cli_execute("goals clear"); add_item_condition(1, $item[electric boning knife]); adventure(my_adventures(),$location[The Castle in the Clouds in the Sky (Ground Floor)]); }
		if (item_amount($item[electric boning knife]) < 1) abort("BCC: We still need to get the knife.");
		visit_url("place.php?whichplace=nstower&action=ns_07_monster3");
		visit_url("fight.php?action=macro&macrotext=use " + to_int($item[electric boning knife]));
	}
	if (is_equal_to(get_property("questL13Final"), "step9")) {
		if (get_property("bcasc_stage_wand") != my_ascensions() && !retrieve_item(1, $item[wand of nagamar])) {
			if (retrieve_item(1, $item[ten-leaf clover])) visit_url($location[The Castle in the Clouds in the Sky (Basement)].to_url());
			if (!retrieve_item(1, $item[wand of nagamar])) abort("BCC: You don't have a Wand. If you actually don't need one, please set bcasc_stage_wand to your current ascension count.");
			else set_property("bcasc_stage_wand", my_ascensions());
		}
		else set_property("bcasc_stage_wand", my_ascensions());
		int needed_healing_items = 5;
		if (item_amount($item[filthy poultice]) + item_amount($item[gauze garter]) < needed_healing_items) {
			if (item_amount($item[filthy poultice]) + item_amount($item[gauze garter]) == 0) needed_healing_items = 4;
			if (!retrieve_item(needed_healing_items-item_amount($item[filthy poultice])-item_amount($item[gauze garter]), $item[red pixel potion])) { if (get_goals().count() > 0) cli_execute("goals clear"); add_item_condition(needed_healing_items-item_amount($item[filthy poultice])-item_amount($item[gauze garter])-item_amount($item[red pixel potion]), $item[red pixel potion]); adventure(my_adventures(),$location[8-Bit Realm]); }
		}
		if (needed_healing_items-item_amount($item[filthy poultice])-item_amount($item[gauze garter])-item_amount($item[red pixel potion]) > 0) abort("BCC: We need more healing items. Or just do the Shadow yourself.");
		buMax("hp, 150 max, 500 init");
		restore_hp(0);
		visit_url("place.php?whichplace=nstower&action=ns_08_monster4");
		run_choice(1);
	}
	if (is_equal_to(get_property("questL13Final"), "step10")) {
		buMax("hp, 150 max, 500 init");
		restore_hp(0);
		int beforefight = my_adventures();
		visit_url("place.php?whichplace=nstower&action=ns_09_monster5");
		while (my_adventures() == beforefight) {
			if (have_skill($skill[ambidextrous funkslinging])) {
				if (item_amount($item[filthy poultice]) > 1) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[filthy poultice]) + "," + to_int($item[filthy poultice]));
				else if (item_amount($item[gauze garter]) > 1) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[gauze garter]) + "," + to_int($item[gauze garter]));
				else if (item_amount($item[red pixel potion]) > 1) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[red pixel potion]) + "," + to_int($item[red pixel potion]));
				else if (item_amount($item[filthy poultice]) > 0) {
					if (item_amount($item[gauze garter]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[filthy poultice]) + "," + to_int($item[gauze garter]));
					else if (item_amount($item[red pixel potion]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[filthy poultice]) + "," + to_int($item[red pixel potion]));
					else visit_url("fight.php?action=macro&macrotext=use " + to_int($item[filthy poultice]));
				}
				else if (item_amount($item[gauze garter]) > 0) {
					if (item_amount($item[red pixel potion]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[gauze garter]) + "," + to_int($item[red pixel potion]));
					else visit_url("fight.php?action=macro&macrotext=use " + to_int($item[gauze garter]));
				}
				else if (item_amount($item[red pixel potion]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[red pixel potion]));
				else abort ("Something went terribly wrong and you need to handle the shadow yourself.");
			}
			else {
				if (item_amount($item[filthy poultice]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[filthy poultice]));
				else if (item_amount($item[gauze garter]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[gauze garter]));
				else if (item_amount($item[red pixel potion]) > 0) visit_url("fight.php?action=macro&macrotext=use " + to_int($item[red pixel potion]));
				else abort ("Something went terribly wrong and you need to handle the shadow yourself.");
			}
		}
	}
	if (is_at_least(get_property("questL13Final"), "step11")) {
		bcascLairFightNS();
	} else {
		abort("BCC: There is some error and you don't appear to be able to access the lair...");
	}
}

boolean bcascPantry() {
	if (to_int(get_property("lastManorUnlock")) == my_ascensions()) return checkStage("pantry", true);
	if (item_amount($item[telegram from lady spookyraven]) > 0) visit_url("inv_use.php?which=3&whichitem=7304&pwd&ajax=1");
	return true;
}

boolean bcascPirateFledges() {
	boolean hitTheBarrr = false;
	if (checkStage("piratefledges")) return true;
	if (!checkStage("dinghy")) return false;
	
	while ((i_a("eyepatch") == 0 || i_a("swashbuckling pants") == 0 || i_a("stuffed shoulder parrot") == 0) && i_a("pirate fledges") == 0) {
		bumAdv($location[The Obligatory Pirate's Cove], "", "equipmentnc", "1 eyepatch, 1 swashbuckling pants, 1 stuffed shoulder parrot", "Getting the Swashbuckling Kit", "-i");
	}
	while (i_a("pirate fledges") == 0) {
		buMax("+outfit swashbuckling getup");
		
		//The Embarassed problem is only an issue if you're a moxie class. Otherwise, ignore it.
		if (my_primestat() == $stat[Moxie]) {
			cli_execute("speculate up Embarrassed; quiet");
			int safeBarrMoxie = 93;
			int specMoxie = 0;
			while (!hitTheBarrr && in_hardcore()) {
				specMoxie = numeric_modifier("Generated:_spec", "Buffed Moxie");
				if (specMoxie > safeBarrMoxie || bcasc_ignoreSafeMoxInHardcore) { hitTheBarrr = true; }
				if (!hitTheBarrr) { levelMe(my_basestat($stat[Moxie])+3, true); }
			}
			
			setMCD(specMoxie, safeBarrMoxie);
		} else {
			cli_execute("mcd 0");
			levelMe(safeMox($location[Barrrney's Barrr]));
		}
		
		buMax("+outfit swashbuckling getup");

		//Check if we've unlocked the f'c'le at all.
		if (index_of(visit_url("place.php?whichplace=cove"), "cove3_3x1b.gif") == -1) {
			if(my_path() != "Avatar of Boris")
				buMax("+outfit swashbuckling getup");
			else {
				outfit("swashbuckling getup");
				equip($item[Trusty]);
			}
			setFamiliar("");
			setMood("i");
			
			if (my_path() != "Bees Hate You") {
				if (i_a("the big book of pirate insults") == 0) {
					buy(1, $item[the big book of pirate insults]);
				}
			} else {
				if (i_a("Massive Manual of Marauder Mockery") == 0) {
					buy(1, $item[Massive Manual of Marauder Mockery]);
				}
			}
			
			cli_execute("condition clear");
			//Have we been given the quest at all?
			while (!contains_text(visit_url("questlog.php?which=1"), "I Rate, You Rate")) {
				print("BCC: Adventuring once at a time to meet the Cap'm for the first time.", "purple");
				if (can_interact()) {
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultCasual");
				} else {
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultBarrr");
				}
			}
			
			//Check whether we've completed the beer pong quest.
			if (index_of(visit_url("questlog.php?which=1"), "Caronch has offered to let you join his crew") > 0) {
				print("BCC: Getting and dealing with the Cap'm's Map.", "purple");
				
				if (i_a("Cap'm Caronch's Map") == 0)
					bumAdv($location[Barrrney's Barrr], "+outfit swashbuckling getup", "", "1 Cap'm Caronch's Map", "", "Getting the Cap'm's Map", "consultBarrr");
				
				//Use the map and fight the giant crab.
				if (i_a("Cap'm Caronch's Map") > 0 && my_adventures() > 0) {
					print("BCC: Using the Cap'm's Map and fighting the Giant Crab", "purple");
					use(1, $item[Cap'm Caronch's Map]);
					bumRunCombat();
					if (have_effect($effect[Beaten Up]) > 0 || i_a("Cap'm Caronch's nasty booty")== 0) abort("BCC: Uhoh. Please use the map and fight the crab manually.");
				} else {
					abort("BCC: For some reason we don't have the map even though we should have.");
				}
			}
			
			//If we have the booty, we'll need to get the map.
			if (i_a("Cap'm Caronch's nasty booty") > 0)
				bumAdv($location[Barrrney's Barrr], "+outfit swashbuckling getup", "", "1 Orcish Frat House blueprints", "Getting the Blueprints", "", "consultBarrr");
			
			//Now, we'll have the blueprints, so we'll need to make sure we have 8 insults before using them. 
			while (numPirateInsults() < 7) {
				print("BCC: Adventuring one turn at a time to get 7 insults. Currently, we have "+numPirateInsults()+" insults.", "purple");
				if (my_adventures() == 0) { abort("BCC: You're out of adventures."); }
				if (can_interact()) {
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultCasual");
				} else {
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultBarrr");
				}
			}
			
			print("BCC: Currently, we have "+numPirateInsults()+" insults. This is enough to continue with beer pong.", "purple");
			
			//Need to use the blueprints.
			if (index_of(visit_url("questlog.php?which=1"), "Caronch has given you a set of blueprints") > 0) {
				if ((knoll_available() || i_a("frilly skirt") > 0) && i_a("hot wing") >= 3) {
					print("BCC: Using the skirt and hot wings to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("equip frilly skirt");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					run_choice(3); // visit_url("choice.php?whichchoice=188&option=3&choiceform3=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else if(i_a("Orcish baseball cap") > 0 && i_a("homoerotic frat-paddle") > 0 && i_a("Orcish cargo shorts") > 0) {
					print("BCC: Using the Frat Outfit to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("outfit frat boy ensemble");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					run_choice(1); // visit_url("choice.php?whichchoice=188&option=1&choiceform1=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else if(i_a("mullet wig") > 0 && i_a("briefcase") > 0) {
					print("BCC: Using the mullet wig and briefcase to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("equip mullet wig");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					run_choice(2); // visit_url("choice.php?whichchoice=188&option=2&choiceform2=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else if(my_adventures() > 0) {
					bumAdv($location[Frat House], "", "items", "1 Orcish baseball cap, 1 homoerotic frat-paddle, 1 Orcish cargo shorts", "Getting the Frat Outfit to burgle the Frat House...", "-i");
					if(my_adventures() == 0) {
						abort("BCC: Please use the blueprints. I was not able to use them automatically, unfortunately :(");
					}
					print("BCC: Using the Frat Outfit to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("outfit frat boy ensemble");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					run_choice(1); // visit_url("choice.php?whichchoice=188&option=1&choiceform1=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else {
					abort("BCC: Please use the blueprints. I was not able to use them automatically, unfortunately :(");
				}
			}
			
			if (i_a("Cap'm Caronch's dentures") > 0) {
				buMax("+outfit swashbuckling getup");
				print("BCC: Giving the dentures back to the Cap'm.", "purple");
				while (available_amount($item[Cap'm Caronch's dentures]) > 0) bumMiniAdv(1, $location[Barrrney's Barrr]);
			}
			
			print("BCC: Now going to do the beer pong adventure.", "purple");
			
			while (my_adventures() > 0) {
				if (tryBeerPong().contains_text("victory laps")) {
					break;					
				}
			}
		}
		
		
		//When we get to here, we've unlocked the f'c'le. We must assume the user hasn't used the mop, polish or shampoo.
		bumAdv($location[The F'c'le], "+outfit swashbuckling getup", "items", "1 pirate fledges", "Getting the Pirate Fledges, finally!", "+i");
	}
	checkStage("piratefledges", true);
	return true;
}

boolean bcascSpookyForest() {
	if (to_int(get_property("lastTempleUnlock")) == my_ascensions()) {bprint("spookyforest"); return true;}
	while (is_not_yet(get_property("questL02Larva"),"finished") && my_adventures() > 0) {
		set_property("choiceAdventure502", "2");
		set_property("choiceAdventure505", "1");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get the mosquito");
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());

	}
	
	if (to_int(get_property("lastTempleUnlock")) != my_ascensions() && get_property("bcasc_openTempleLater") == "false") {
		bcascOpenTemple();
	}
	bprint("spookyforest");
	return true;
}

//Thanks, picklish!
boolean bcascTavern() {
	if (is_equal_to(get_property("questL03Rat"), "finished")) {bprint("tavern"); return true;}

	setFamiliar("");
	cli_execute("mood execute");
	levelMe(safeMox($location[The Typical Tavern Cellar]));
	if (canMCD() && !(bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) cli_execute("mcd 0");
	visit_url("council.php");
	set_property("lastCouncilVisit", my_level());

	visit_url("tavern.php?place=barkeep");
	setMood("");
	buMax();
	
	//Re-get the current tavern layout.
	visit_url("cellar.php");

	
	while (!get_property("tavernLayout").contains_text("3")) {
		if (my_adventures() == 0) abort("BCC: No adventures.");
		print("BCC: We are adventuring at the tavern", "purple");
		tavern();
	}

	bprint("tavern");
	return is_equal_to(get_property("questL03Rat"), "finished"); 
}

boolean bcascTeleportitisBurn() {
	if (have_effect($effect[Teleportitis]) == 0) return true;
	print("BCC: Burning off teleportitis", "purple");
	// We used to be able to burn this off at the shore, but can't now.
	
	if (have_effect($effect[Teleportitis]) == 0) return true;
	bcascMining();
	if (have_effect($effect[Teleportitis]) == 0) return true;
	bcascDailyDungeon();
	if (have_effect($effect[Teleportitis]) == 0) return true;
	bumMiniAdv(have_effect($effect[Teleportitis]), $location[The Haunted Kitchen]);
	return true;
}

boolean bcascTrapper() {
	if (is_equal_to(get_property("questL08Trapper"), "finished")) {bprint("Trapper"); return true;}

	string trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	while (i_a(get_property("trapperOre")) < 3 && !checkStage("mining")) {
		if ((my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") && ((i_a("miner's helmet") == 0 || i_a("7-Foot Dwarven mattock") == 0 || i_a("miner's pants") == 0))) {
			set_property("choiceAdventure556", 1);
			bumAdv($location[Itznotyerzitz Mine], "", "items", "1 miner's helmet, 1 7-Foot Dwarven mattock, 1 miner's pants", "Getting the Mining Outfit", "i-");
			set_property("choiceAdventure556", 2);
			trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		}
		if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") cli_execute("outfit mining gear");
		if (!bcascMining()) {
			print("BCC: The script has stopped mining for ore, probably because you ran out of unaccomapnied miner adventures. We'll try again tomorrow.", "purple");
			return false;
		}
	}
	//Set the mining part to complete if we have three ore at this point to avoid hunting potential softcore problems
	if (i_a(get_property("trapperOre")) == 3 && !checkStage("mining"))
		checkStage("mining", true);
		
	while (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "cheese") && !is_past(get_property("questL08Trapper"),"step1")) {
		if (can_interact()) {
			cli_execute("acquire 3 goat cheese");
		} else {
			string old = get_property("choiceAdventure162");
			set_property("choiceAdventure162", 3); //Boris hates rocks
			bumAdv($location[The Goatlet], "", "items", "3 goat cheese", "Getting Goat Cheese", "i");
			set_property("choiceAdventure162", old); //Reset in order to not screw anyone up in a future ascencion
		}
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	}

	if ((have_skill($skill[Musk of the Moose]) || have_skill($skill[Carlweather's Cantata of Confrontation]) || (my_path() == "Avatar of Sneaky Pete" && (get_property("peteMotorbikeTires") == "Snow Tires" || get_property("peteMotorbikeMuffler") == "Extra-Loud Muffler"))) && willMood() && get_res($element[cold], 5, false)) {
		if (is_not_yet(get_property("questL08Trapper"),"finished")) {
			if (i_a("ninja carabiner") == 0 && !(my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires")) {
				print("BCC: Getting some climbing gear.", "purple");

				setMood("+n");
				if(my_class() == $class[Pastamancer] && have_skill($skill[flavour of magic])) use_skill(1, $skill[spirit of cayenne]);
				if ((i_a("saucepan") + i_a("5-alarm saucepan") + i_a("17-alarm saucepan") > 0) && have_skill($skill[Jalape&ntilde;o Saucesphere]) && my_class() == $class[sauceror]) cli_execute("trigger lose_effect, Jalape&ntilde;o Saucesphere, cast 1 Jalape&ntilde;o Saucesphere");

				//Bonus cold resistance - as much as we can easily get for 25 turns adventuring
				tripleMaximize("cold res, -tie", 25.0);

				buMax("initiative");

				if (canMCD()) {
					cli_execute("mcd 0;");
				}
				int adventurecount = 0;
				while (i_a("ninja carabiner") == 0 && adventurecount < 20) {
					bumminiAdv(1, $location[Lair of the Ninja Snowmen]);
					adventurecount += 1;
				}
				if (i_a("ninja carabiner") == 0) {
					abort("BCC: You appear unable to succeed in beating the assassins. Buff thyself.");
				}
			}
		
			//Make sure we actually still have the cold resistance in case we restart the script
			get_res($element[cold], 5, true);
			
			trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			betweenBattle();
			//Adventure once at the Icy Peak to move the quest forwar
			trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			cli_execute("condition add Groar's fur");
			bumminiAdv(10, $location[Mist-Shrouded Peak]);
		}
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	} else {
		if (is_not_yet(get_property("questL08Trapper"),"finished")) {
			if (!have_outfit("eXtreme Cold-Weather Gear")) {
				set_property("choiceAdventure575", 1);
				bumadv($location[The eXtreme Slope], "", "items", "eXtreme scarf, snowboarder pants, eXtreme mittens", "Getting the eXtreme outfit", "i");
				set_property("choiceAdventure575", 2);
			}
			
			buMax(" +outfit eXtreme Cold-Weather Gear ");
			if (is_not_yet(get_property("questL08Trapper"), "step3") && !(my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires")) {
				while (get_property("lastEncounter") != "3 eXXXtreme 4ever 6pack") {
					bumMiniAdv(1, $location[The eXtreme Slope]);
				}
				trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
				//Adventure once at the Icy Peak to move the quest forward				
				trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			}

			
			//Hunt for Groar!
			if (my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires") {
				trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
				trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
				adventure(1, $location[Mist-Shrouded Peak]);
			} else
				bumAdv($location[Mist-Shrouded Peak], "+outfit eXtreme Cold-Weather Gear", "", "Groar's fur", "Finding and fighting Groar!");
		}
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	}

	if (is_equal_to(get_property("questL08Trapper"), "finished")) {
		bprint("Trapper");
		return true;
	}
	return false;
}

boolean bcascToot() {
    if (checkStage("toot")) { return true;}
    visit_url("tutorial.php?action=toot");
    if (item_amount($item[letter from King Ralph XI]) > 0) use(1, $item[letter from King Ralph XI]);
	
	if (get_property("bcasc_sellgems") == "true") {
		if (item_amount($item[pork elf goodies sack]) > 0 && my_path() != "Way of the Surprising Fist") use(1, $item[pork elf goodies sack]);
		if (my_path() != "Way of the Surprising Fist") foreach stone in $items[hamethyst, baconstone, porquoise] autosell(item_amount(stone), stone);
	}
	if (my_class() == $class[Accordion Thief] && i_a("stolen accordion") == 0 && i_a("Rock and Roll Legend") == 0 && i_a("Squeezebox of the Ages") == 0 && i_a("The Trickster's Trikitixa") == 0) {
		print("BCC: Getting an Accordion before we start.", "purple");
		while (i_a("stolen accordion") == 0) use(1, $item[chewing gum on a string]);
	}
	
	//KoLMafia doesn't clear these on ascension.
	set_property("mineLayout1", "");
	set_property("trapperOre", "");
	set_property("bcasc_lastFax", "");
	set_property("bcasc_lastHermitCloverGet", "");
	set_property("bcasc_lastShieldCheck", "");
	set_property("chasmBridgeProgress", 0);
	set_property("lastChasmReset", my_ascensions());

    checkStage("toot", true);
	return true;
}

boolean bcascWand() {
	if (checkStage("wand")) return true;
	if (!in_hardcore() || my_path() == "Bugbear Invasion") return false;
	
	//Before we do the next thing, let's just check for and use the dead mimic.
	if (i_a("dead mimic") > 0) {
		cli_execute("use dead mimic");
		if (my_path() != "Bees Hate You") cli_execute("use * small box; use * large box");
	}
	
	
	//Check for a wand. Any wand will do. 
	if (i_a("aluminum wand") + i_a("ebony wand") + i_a("hexagonal wand") + i_a("marble wand") + i_a("pine wand") == 0) {
		//Use the plus sign if we have it. Just in case someone's found the oracle but forgotten to use the plus sign.
		if (i_a("plus sign") > 0) { if (cli_execute("use plus sign")) {} }

		//Need at least 1000 meat for the oracle adventure.  Let's be safe and say 2000.
		if (my_meat() < 2000) {
			print("BCC: Waiting on the oracle until you have more meat.", "purple");
			return false;
		}
		
		//Check for the DoD image. 
		while (index_of(visit_url("da.php"), "greater.gif") > 0) {
			//Then we need to check for the plus sign. 
			if (i_a("plus sign") == 0) {
				set_property("choiceAdventure451","3");
				bumAdv($location[The Enormous Greater-Than Sign], "", "itemsnc", "1 plus sign", "Getting the Plus Sign", "-");
			}
			while (have_effect($effect[Teleportitis]) == 0) {
				set_property("choiceAdventure451","5");
				bumAdv($location[The Enormous Greater-Than Sign], "", "itemsnc", "1 choiceadv", "Getting Teleportitis", "-");
			}
			set_property("choiceAdventure451","3");
			bumMiniAdv(1, $location[The Enormous Greater-Than Sign]);
			if (i_a("plus sign") > 0) { if (cli_execute("use plus sign")) {} }
		}
		
		if (have_effect($effect[Teleportitis]) > 0) bcascTeleportitisBurn();

		//Then we have to get the wand itself. Must have at least 5000 meat for this, so use 6000 for safety. 
		if (!get_property("bcasc_3KeysNoWand").to_boolean() && my_meat() > 6000) {
			set_property("choiceAdventure25","2");
			bumAdv($location[The Dungeons of Doom], "", "itemsnc", "1 dead mimic", "Getting a Dead Mimic", "-");
		} else {
			return false;
		}
	}
	if (i_a("dead mimic") > 0) cli_execute("use dead mimic");
	if (numOfWand() > 0) {
		checkStage("wand", true);
		return true;
	}
	return false;
}

/********************************************************
* START THE FUNCTIONS CALLING THE ADVENTURING FUNCTIONS *
********************************************************/

void bcs1() {
    bcascToot();
	bcascGuild();
	bcCouncil();
	bcascKnob();
	bcascPantry();
	levelMe(5, true);
}

void bcs2() {
	bcCouncil();
	bcascSpookyForest();
	levelMe(8, true);
}

void bcs3() {
	bcCouncil();
	bcascTavern();
	if(bcasc_getLEW) bcascFunHouse();
	levelMe(13, true);
}

void bcs4() {
	bcCouncil();
	bcascBats1();	//questL04Bats
	bcascMeatcar();
	bcascBats2();	//questL04Bats
	if (my_buffedstat(my_primestat()) > 35 && my_path() != "One Crazy Random Summer") bcasc8Bit();
	levelMe(20, true);
}

void bcs5() {
	bcCouncil();
	
	bcascKnobKing();	//questL05Knob
	bcascDinghyHippy();	//lastIslandUnlock?
	bcCrumHorn();
	if (my_inebriety() < 15) bcascManorBilliards();//lastLibraryUnlock?
	
	levelMe(29, true);
}

void bcs6() {
	bcCouncil();
	
	bcascFriars();		//questL06Friars
	//Setting a second call to this as we want the equipment before the steel definitely. 
	bcascKnobKing();	//questL05Knob
	bcascKnobPassword();//dispensary_available()
	bcascFriarsSteel();
	
	//Get the Swashbuckling Kit if we're not a moxie class. The extra moxie boost will be incredibly helpful for the Cyrpt.
	if (my_class() != $class[Disco Bandit] && my_class() != $class[Accordion Thief]) {
		if(my_path() != "Bugbear Invasion") {
			while ((i_a("eyepatch") == 0 || i_a("swashbuckling pants") == 0 || i_a("stuffed shoulder parrot") == 0) && i_a("pirate fledges") == 0) {
				bumAdv($location[The Obligatory Pirate's Cove], "", "equipmentnc", "1 eyepatch, 1 swashbuckling pants, 1 stuffed shoulder parrot", "Getting the Swashbuckling Kit", "-i");
			}
		} else {
			while ((i_a("eyepatch") == 0 || i_a("swashbuckling pants") == 0 || i_a("stuffed shoulder parrot") == 0 || i_a("flaregun") == 0) && i_a("pirate fledges") == 0) {
				bumAdv($location[The Obligatory Pirate's Cove], "", "equipmentnc", "1 eyepatch, 1 swashbuckling pants, 1 stuffed shoulder parrot, 1 flaregun", "Getting the Swashbuckling Kit (and a flaregun)", "-i");
			}
		}
	}
	
	if (is_at_least(get_property("questM20Necklace"), "step3") && is_not_yet(get_property("questM20Necklace"), "finished")) bcascManorLibrary();
	levelMe(40, true);
}

void bcs7() {
	bcCouncil();
	
	bcascFriarsSteel();
	bcascCyrpt();
	bcascInnaboxen();
	if(bcasc_bedroom) {
		bcascManorBilliards();
		bcascManorLibrary();
		bcascManorBathroom();
		bcascManorBedroom();
		bcascManorGallery();
		bcascManorBallroom();
	}
	
	levelMe(53, true);
}

void bcs8() {
	bcCouncil();
	bcascTrapper();
	if (bcasc_getWand) bcascWand();
	bcascPirateFledges();
	bcascMirror();
	
	levelMe(68, true);
}

void bcs9() {
	bcCouncil();
	bcascDailyDungeon();
	
	//Yes, this check isn't perfect, but if we have the giant pinky ring, we've definitely completed the quest.
	if (my_path() != "Actually Ed the Undying" && i_a("giant pinky ring") == 0 && get_dwelling() != $item[Frobozz Real-Estate Company Instant House (TM)]) { 
		cli_execute("leaflet");
		if (my_path() != "Bees Hate You") { if (cli_execute("use 1 instant house")) {} }
	}
	
	bcascChasm();
	
	levelMe(85, true);
}

void bcs10() {
	bcCouncil();
	
	bcascAirship();
	bcascCastle();
	
	levelMe(104, true);
}

void bcs11() {
	bcCouncil();
	
	bcascMacguffinPrelim();
	bcascMacguffinPalindome();
	bcascHoleInTheSky();
	if(!bcasc_bedroom) {
		bcascManorBilliards();
		bcascManorLibrary();
		bcascManorBathroom();
		bcascManorBedroom();
		bcascManorGallery();
		bcascManorBallroom();
	}
	bcascMacguffinSpooky();
	bcascMacguffinPyramid();
	bcascMacguffinHiddenCity();
	bcascMacguffinFinal();
	
	levelMe(125, true);
}

void bcs12() {
	boolean doSideQuest(string name) {
		if (checkStage("warstage_"+name)) return true;
		print("BCC: Starting SideQuest '"+name+"'", "purple");
		
		//We have to have these functions outside the switch. 
		int estimated_advs() { return ceil((100000 - to_float(get_property("currentNunneryMeat"))) / (1000 + (10*meat_drop_modifier()))); }
		
		int numMolyItems() { return item_amount($item[molybdenum hammer]) + item_amount($item[molybdenum crescent wrench]) + item_amount($item[molybdenum pliers]) + item_amount($item[molybdenum screwdriver]); }
		
		string visit_yossarian() {
			print("BCC: Visiting Yossarian...", "purple");
			if (cli_execute("outfit "+bcasc_warOutfit)) {}
			return visit_url("bigisland.php?action=junkman&pwd=");
		}
		
		switch (name) {
			case "arena" :
				if (get_property("sidequestArenaCompleted") != "none") return true;
				print("BCC: doSideQuest(Arena)", "purple");
				
				//First, either get the flyers or turn in the 10000ML if needed, then check if it's complete. 
				cli_execute("outfit "+bcasc_warOutfit);
				if (get_property("flyeredML").to_int() > 9999 || item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) == 0) visit_url("bigisland.php?place=concert&pwd=");
				cli_execute("outfit "+bcasc_warOutfit);
				if (get_property("sidequestArenaCompleted") != "none") return true;
				if (item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) == 0) abort("BCC: There was a problem acquiring the flyers for the Arena quest.");
				
/*				if (can_interact()) { // We no longer have free noodling. As such, we can't depend on consultCasual actually completing the quest safely.
					//Needs to check that the side-qeusts are actually available
					//The consultCasual script will automatically handle noodling and flyering, so all we have to do is do the side-quests.
					if (bcasc_doSideQuestOrchard) doSideQuest("orchard");
					if (bcasc_doSideQuestNuns) doSideQuest("nuns");
					if (bcasc_doSideQuestJunkyard) doSideQuest("junkyard");
				} else {*/
					print("BCC: Finding the GMoB to flyer him...", "purple");
					set_property("choiceAdventure105","3");     // say "guy made of bees"
					switch (my_primestat()) {
						case $stat[Muscle] :		set_property("choiceAdventure402", "1");	break;
						case $stat[Mysticality] :	set_property("choiceAdventure402", "2");	break;
						case $stat[Moxie] :			set_property("choiceAdventure402", "3");	break;
					}
					while (to_int(get_property("guyMadeOfBeesCount")) < 5 && get_property("flyeredML").to_int() < 10000) {
						bumAdv($location[The Haunted Bathroom], "", "", "1 choiceadv", "You need to say 'Guy made of bees' "+(5-to_int(get_property("guyMadeOfBeesCount")))+" more times.", "-", "consultGMOB");
					}
//				}
				
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=concert&pwd=");
				visit_url("bigisland.php?place=concert&pwd=");
				return checkStage("warstage_"+name, true);
			
			case "beach" :
				if (get_property("sidequestLighthouseCompleted") != "none") return true;
				print("BCC: doSideQuest(Beach)", "purple");
				bumUse(4, $item[reodorant]);
				while (i_a("barrel of gunpowder") < 5) {
					if (i_a("Rain-Doh black box") + i_a("spooky putty mitre") + i_a("spooky putty leotard") + i_a("spooky putty ball") + i_a("spooky putty sheet") + i_a("spooky putty snake") > 0) {
						abort("BCC: You have some putty method, but the script doesn't support puttying at the beach, so we aborted to save you a bunch of turns. Do the beach manually.");
					}
					bumAdv($location[Sonofa Beach], "", "10 combat", "5 barrel of gunpowder", "Getting the Barrels of Gunpowder", "+");
				}
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
				visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
				if (get_property("sidequestLighthouseCompleted") != "none")
					return checkStage("warstage_"+name, true);
				else
					return false;
			
			case "dooks" :
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				if (get_property("sidequestFarmCompleted") != "none") return true;
				print("BCC: doSideQuest(Dooks)", "purple");
				cli_execute("outfit "+bcasc_warOutfit);
				set_property("choiceAdventure147","3");
				set_property("choiceAdventure148","1");
				set_property("choiceAdventure149","2");
				
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				
				//Use a chaos butterfly against a generic duck
				while (!contains_text(visit_url("bigisland.php?place=farm"), "snarfblat=143")) {
					if (i_a("chaos butterfly") > 0 && my_path() != "Bees hate You") {
						string url;
						boolean altered = false;
						repeat {
							url = visit_url("adventure.php?snarfblat=137");
							if (contains_text(url, "Combat")) {
								throw_item($item[chaos butterfly]);
								altered = true;
								bumRunCombat();
							} else  {
								bumMiniAdv(1,$location[McMillicancuddy's Barn]);
							}
						} until (altered || contains_text(url,"no more ducks here."));
						
						if (altered) bumAdv($location[McMillicancuddy's Barn]);
					} else {
						bumAdv($location[McMillicancuddy's Barn]);
					}
				}
				if(my_class() == $class[Pastamancer] && have_skill($skill[flavour of magic])) use_skill(1, $skill[spirit of wormwood]);
				bumAdv($location[McMillicancuddy's Pond]);
				bumAdv($location[McMillicancuddy's Back 40]);
				bumAdv($location[McMillicancuddy's Other Back 40]);
				
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				
				if (get_property("sidequestFarmCompleted") != "none")
					return checkStage("warstage_"+name, true);
				else
					return false;
			
			case "junkyard" :
				if (get_property("sidequestJunkyardCompleted") != "none") return true;
				print("BCC: doSideQuest(Junkyard)", "purple");
				
				visit_yossarian();
				visit_yossarian();

				while (get_property("currentJunkyardTool") != "") {
					bumAdv(to_location(get_property("currentJunkyardLocation")), "mox +DA +10DR " +(my_path() == "Way of the Surprising Fist" ? " " : " +effective "), "nothing", "1 "+get_property("currentJunkyardTool"), "Getting "+get_property("currentJunkyardTool")+"...", "", "consultJunkyard");
					visit_yossarian();
				}
				if (get_property("sidequestJunkyardCompleted") != "none")
					return checkStage("warstage_"+name, true);
				else
					return false;
			
			case "nuns" :
				if (get_property("sidequestNunsCompleted") != "none") return true;
				print("BCC: doSideQuest(Nuns)", "purple");
				setFamiliar("meatnuns");
				
				//Set up buffs and use items as necessary.
				cli_execute("trigger clear");
				if (have_effect($effect[sinuses for miles]) == 0) bumUse(3, $item[mick's icyvapohotness inhaler]);
				if (have_effect($effect[red tongue]) == 0) bumUse(3, $item[red snowcone]);
				if (get_property("sidequestArenaCompleted") == "fratboy" && cli_execute("concert 2")) {}
				if (get_property("demonName2") != "" && cli_execute("summon 2")) {}
				if (i_a("filthy knitted dread sack") > 0 && i_a("\"DRINK ME\" potion") > 0 && cli_execute("hatter filthy knitted dread sack")) {}
				if (my_path() != "Bees Hate You") bumUse(ceil((estimated_advs()-have_effect($effect[wasabi sinuses]))/10), $item[Knob Goblin nasal spray]);
				bumUse(ceil((estimated_advs()-have_effect($effect[your cupcake senses are tingling]))/20), $item[pink-frosted astral cupcake]);
				bumUse(ceil((estimated_advs()-have_effect($effect[heart of pink]))/10), $item[pink candy heart]);
				bumUse(ceil((estimated_advs()-have_effect($effect[heart of green]))/10), $item[green candy heart]);
				bumUse(ceil((estimated_advs()-have_effect($effect[Greedy Resolve]))/20), $item[resolution: be wealthier]);
				if (have_skill($skill[The Polka of Plenty])) cli_execute("trigger lose_effect, Polka of Plenty, cast 1 The Polka of Plenty");
				if (have_skill($skill[The Ballad of Richie Thingfinder]) && my_maxmp() > mp_cost($skill[The Ballad of Richie Thingfinder]) * 2) cli_execute("trigger lose_effect, The Ballad of Richie Thingfinder, cast 1 The Ballad of Richie Thingfinder");
				if (have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
				if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
				if (dispensary_available()) cli_execute("trigger lose_effect, Wasabi Sinuses, use 1 Knob Goblin nasal spray");
				if (dispensary_available()) cli_execute("trigger lose_effect, Heavy Petting, use 1 Knob Goblin pet-buffing spray");
				
				//Put on the outfit and adventure, printing debug information each time. 
				buMax("nuns");
				cli_execute("condition clear");
				while (my_adventures() > 0 && prepSNS() != "whatever" && bumMiniAdv(1, $location[The Themthar Hills]) && get_property("currentNunneryMeat").to_int() < 100000) {
					print("BCC: Nunmeat retrieved: "+get_property("currentNunneryMeat")+" Estimated adventures remaining: "+estimated_advs(), "green");
				}
				
				if(get_property("sidequestNunsCompleted") != "none") return checkStage("warstage_"+name, true);
				visit_url("bigisland.php?place=nunnery");
			
			case "orchard" :
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=orchard&action=stand&pwd=");
				visit_url("bigisland.php?place=orchard&action=stand&pwd=");
				if (get_property("sidequestOrchardCompleted") != "none") return true;
				print("BCC: doSideQuest(Orchard)", "purple");

				while (item_amount($item[heart of the filthworm queen]) == 0) {
					while (have_effect($effect[Filthworm Guard Stench]) == 0) {
						while (have_effect($effect[Filthworm Drone Stench]) == 0) {
							while (have_effect($effect[Filthworm Larva Stench]) == 0) {
								bumAdv($location[The Hatching Chamber], "item", "items", "1 filthworm hatchling scent gland", "Getting the Hatchling Gland (1/3)", "iorchard");
								use(1, $item[filthworm hatchling scent gland]);
							}
							bumAdv($location[The Feeding Chamber], "item", "items", "1 filthworm drone scent gland", "Getting the Drone Gland (2/3)", "iorchard");
							use(1, $item[filthworm drone scent gland]);
						}
						bumAdv($location[The Royal Guard Chamber], "item", "items", "1 filthworm royal guard scent gland", "Getting the Royal Guard Gland (3/3)", "iorchard");
						use(1, $item[filthworm royal guard scent gland]);
					}
					bumAdv($location[The Filthworm Queen's Chamber], "", "", "1 heart of the filthworm queen", "Fighting the Queen");
				}
				
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=orchard&action=stand&pwd=");
				visit_url("bigisland.php?place=orchard&action=stand&pwd=");
				return checkStage("warstage_"+name, true);
		}
		return false;
	}
	
	void item_turnin(item i) {
		sell(i.buyer, item_amount(i), i);
	}
	
	boolean killSide(int numDeadNeeded) {
		setFamiliar("");
		setMood("i");

		if (my_adventures() == 0) abort("BCC: You don't have any adventures :(");
		cli_execute("condition clear");
		
		int numKilled;
		if (bcasc_doWarAs == "abort") {
			abort("BCC: You have told us not to automate the battlefield. Please complete it yourself or change your settings. ");
		} else if (bcasc_doWarAs == "frat") {
			numKilled = to_int(get_property("hippiesDefeated"));
			buMax("+outfit frat warrior fatigues");
		} else if (bcasc_doWarAs == "hippy") {
			numKilled = to_int(get_property("fratboysDefeated"));
			buMax("+outfit war hippy fatigues");
		} else {
			abort("BCC: There has been an error trying to defeat the enemies on the battlefield. Please report this. ");
		}
		print("BCC: Attempting to kill up to "+numDeadNeeded+" enemies in the war. You have "+numKilled+" dead already, attempting to do the war as a "+bcasc_doWarAs+".", "purple");
		
		while (numKilled < numDeadNeeded) {
			if (my_adventures() == 0) abort("BCC: No adventures in the Battlefield.");
			
			if (bcasc_doWarAs == "frat") {
				bumMiniAdv(1, $location[The Battlefield (Frat Uniform)]);
				numKilled = to_int(get_property("hippiesDefeated"));
			} else if (bcasc_doWarAs == "hippy") {
				bumMiniAdv(1, $location[The Battlefield (Hippy Uniform)]);
				numKilled = to_int(get_property("fratboysDefeated"));
			} else {
				abort("BCC: You have specified a wrong type of side to do the war as. Please change that (the setting is called bcasc_doWarAs");
			}	
		}
		
		return (numKilled >= numDeadNeeded);
	}

	bcCouncil();
	if (index_of(visit_url("questlog.php?which=1"), "Make War, Not... Oh, Wait") > 0) {
		//First, get the outfit as necessary. 
		if (bcasc_doWarAs == "abort") {
			abort("BCC: You have told us that you would like to complete the war yourself. Please do so or change your settings.");
		} else if (bcasc_doWarAs == "hippy") {
			while (i_a("reinforced beaded headband") == 0 || i_a("bullet-proof corduroys") == 0 || i_a("round purple sunglasses") == 0) 
				bumAdv($location[Wartime Hippy Camp], "+outfit filthy hippy disguise", "", "1 reinforced beaded headband, 1 bullet-proof corduroys, 1 round purple sunglasses", "Getting the War Hippy Outfit");
		} else if (bcasc_doWarAs == "frat") {
			while (i_a("beer helmet") == 0 || i_a("distressed denim pants") == 0 || i_a("bejeweled pledge pin") == 0) 
				bumAdv($location[Wartime Frat House], "+outfit filthy hippy disguise", "hebo", "1 beer helmet, 1 distressed denim pants, 1 bejeweled pledge pin", "Getting the Frat Warrior Outfit", "i", "consultHeBo");
		} else {
			abort("BCC: Please specify if you want the war done as a Hippy or a Fratboy.");
		}
		
		while (my_basestat($stat[mysticality]) < 70) {
			set_property("choiceAdventure105","1");
			set_property("choiceAdventure402","2");
			bumAdv($location[The Haunted Bathroom], "", "", "70 mysticality", "Getting 70 myst to equip the " + bcasc_warOutfit + " outfit", "-");
		} 
		
		//So now we have the outfit. Let's check if the war has kicked off yet. 
		if (!contains_text(visit_url("questlog.php?which=1"), "war between the hippies and frat boys started")) {
			if (bcasc_doWarAs == "abort") {
				abort("BCC: You have told us that you would like to complete the war yourself. Please do so or change your settings.");
			} else if (bcasc_doWarAs == "hippy") {
				bumAdv($location[Wartime Frat House (Hippy Disguise)], "+outfit war hippy fatigues", "", "", "Starting the war by irritating the Frat Boys", "-");
			} else if (bcasc_doWarAs == "frat") {
				//I can't quite work out which choiceAdv number I need. Check it later. Plus, it should be "start the war" anyway. 
				//cli_execute("set choiceAdventure142");
				bumAdv($location[Wartime Hippy Camp (Frat Disguise)], "+outfit frat warrior fatigues", "", "", "Starting the war by irritating the Hippies", "-");
			}
		}
		
		//At this point the war should be started. 
		if (bcasc_doWarAs == "abort") {
			abort("BCC: You have told us that you would like to complete the war yourself. Please do so or change your settings.");
		} else if (bcasc_doWarAs == "hippy") {
			if (i_a("reinforced beaded headband") == 0 || i_a("bullet-proof corduroys") == 0 || i_a("round purple sunglasses") == 0) {
				abort("BCC: What the heck did you do - where's your War Hippy outfit gone!?");
			}
			if (bcasc_doSideQuestOrchard) doSideQuest("orchard");
			if (bcasc_doSideQuestDooks) doSideQuest("dooks");
			if (bcasc_doSideQuestNuns) doSideQuest("nuns");
			killSide(64);
			if (bcasc_doSideQuestBeach || i_a("barrel of gunpowder") >= 5) doSideQuest("beach");
			killSide(192);
			if (bcasc_doSideQuestJunkyard) doSideQuest("junkyard");
			killSide(458);
			if (bcasc_doSideQuestArena) doSideQuest("arena");
			killSide(1000);
		} else if (bcasc_doWarAs == "frat") {
			if (i_a("beer helmet") == 0 || i_a("distressed denim pants") == 0 || i_a("bejeweled pledge pin") == 0) {
				abort("BCC: What the heck did you do - where's your Frat Warrior outfit gone!?");
			}
			if (bcasc_doSideQuestArena) doSideQuest("arena");
			if (bcasc_doSideQuestJunkyard) doSideQuest("junkyard");
			if (bcasc_doSideQuestBeach || i_a("barrel of gunpowder") >= 5) doSideQuest("beach");
			killSide(64);
			if (bcasc_doSideQuestOrchard) doSideQuest("orchard");
			killSide(192);
			if (bcasc_doSideQuestNuns) doSideQuest("nuns");
			killSide(458);
			if (bcasc_doSideQuestDooks) doSideQuest("dooks");
			killSide(1000);
		}
		
		if (get_property("bcasc_sellWarItems") == "true") {
			//Sell all stuff.
			if (bcasc_doWarAs == "hippy") {
				item_turnin($item[red class ring]);
				item_turnin($item[blue class ring]);
				item_turnin($item[white class ring]);
				item_turnin($item[beer helmet]);
				item_turnin($item[distressed denim pants]);
				item_turnin($item[bejeweled pledge pin]);
				item_turnin($item[PADL Phone]);
				item_turnin($item[kick-ass kicks]);
				item_turnin($item[perforated battle paddle]);
				item_turnin($item[bottle opener belt buckle]);
				item_turnin($item[keg shield]);
				item_turnin($item[giant foam finger]);
				item_turnin($item[war tongs]);
				item_turnin($item[energy drink IV]);
				item_turnin($item[Elmley shades]);
				item_turnin($item[beer bong]);
				buy($coinmaster[Dimemaster], $coinmaster[dimemaster].available_tokens/2, $item[filthy poultice]);
			} else if (bcasc_doWarAs == "frat") {
				item_turnin($item[pink clay bead]);
				item_turnin($item[purple clay bead]);
				item_turnin($item[green clay bead]);
				item_turnin($item[bullet-proof corduroys]);
				item_turnin($item[round purple sunglasses]);
				item_turnin($item[reinforced beaded headband]);
				item_turnin($item[hippy protest button]);
				item_turnin(to_item("Lockenstock"));
				item_turnin($item[didgeridooka]);
				item_turnin($item[wicker shield]);
				item_turnin($item[oversized pipe]);
				item_turnin($item[fire poi]);
				item_turnin($item[communications windchimes]);
				item_turnin($item[Gaia beads]);
				item_turnin($item[hippy medical kit]);
				item_turnin($item[flowing hippy skirt]);
				item_turnin($item[round green sunglasses]);
				buy($coinmaster[Quartersmaster], $coinmaster[Quartersmaster].available_tokens/2, $item[gauze garter]);
			}
		} else {
			if (!checkStage("prewarboss")) {
				checkStage("prewarboss", true);
				abort("BCC: Stopping to let you sell war items.  Run script again to continue. Note that the script will not fight the boss as Muscle or Myst, so do that manually to if appropriate.");
			}
		}
		
		// Kill the boss.
		int bossMoxie = 250;
		buMax("+outfit "+bcasc_warOutfit);
		setMood("");
		cli_execute("mood execute");
		
		//Now deal with getting the moxie we need.
		switch (my_primestat()) {
			case $stat[Moxie] :
				if (get_property("telescopeUpgrades") > 0 && !in_bad_moon()) if (cli_execute("telescope look high")) {}
				if (my_buffedstat($stat[Moxie]) < bossMoxie && have_skill($skill[Advanced Saucecrafting])) cli_execute("cast * advanced saucecraft");
				if (my_buffedstat($stat[Moxie]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0) cli_execute("use 1 serum of sarcasm");
				if (my_buffedstat($stat[Moxie]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0) cli_execute("use 1 tomato juice of power");
				if (my_buffedstat($stat[Moxie]) < bossMoxie&& my_primestat() == $stat[moxie]) abort("BCC: Can't get to " + bossMoxie + " moxie for the boss fight.  You're on your own.");
			break;

			case $stat[Muscle] :
				if (my_buffedstat($stat[Muscle]) < bossMoxie && have_skill($skill[Advanced Saucecrafting])) cli_execute("cast * advanced saucecraft");
				if (my_buffedstat($stat[Muscle]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0) cli_execute("use 1 philter of phorce");
				if (my_buffedstat($stat[Muscle]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0) cli_execute("use 1 tomato juice of power");
				if (my_buffedstat($stat[Muscle]) < bossMoxie&& my_primestat() == $stat[muscle]) abort("BCC: Can't get to " + bossMoxie + " muscle for the boss fight.  You're on your own.");
			break;

			case $stat[Mysticality] :
				if (my_path() != "Avatar of Jarlsberg" && get_property("bcasc_doMystAsCCS").to_boolean()) break;
				if (my_path() == "Avatar of Jarlsberg" && get_property("bcasc_doJarlAsCCS").to_boolean()) break;
			default :
				abort("BCC: Not yet doing the boss as Muscle or Mysticality.");
			break;
		}
		
		cli_execute("restore hp;restore mp");
		visit_url("bigisland.php?place=camp&whichcamp=1");
		visit_url("bigisland.php?place=camp&whichcamp=2");
		visit_url("bigisland.php?action=bossfight&pwd");
		if (index_of(bumRunCombat(), "WINWINWIN") == -1) abort("BCC: Failed to kill the boss!\n");
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());

	}
	
	bcasc8Bit();
	levelMe(148, true);
}

void bcs13() {
	bcCouncil();
	
	load_current_map("bumrats_lairitems", lairitems);
	if (my_path() == "Bugbear Invasion") {
		bcascBugbearHunt();
		bcascBugbearShip();
	}
	bcascNaughtySorceress();
}


void bumcheekcend() {
#	ascendLog("");
	
	print("Level 1 Starting", "green");
	bcs1();
	print("Level 2 Starting", "green");
	bcs2();
	print("Level 3 Starting", "green");
	bcs3();
	print("Level 4 Starting", "green");
	bcs4();
	print("Level 5 Starting", "green");
	bcs5();
	print("Level 6 Starting", "green");
	bcs6();
	print("Level 7 Starting", "green");
	bcs7();
	print("Level 8 Starting", "green");
	bcs8();
	print("Level 9 Starting", "green");
	bcs9();
	print("Level 10 Starting", "green");
	bcs10();
	print("Level 11 Starting", "green");
	bcs11();
	print("Level 12 Starting", "green");
	bcs12();
	print("Level 13 Starting", "green");
	bcs13();
}

void mainWrapper() {
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("Thankyou for using bumcheekcity's ascension script. Please report all bugs on the KoLMafia thread with a copy+paste from the CLI of the problematic points, and your username. Also ask on the thread on the kolmafia.us forum for help and assistance with the script, particularly first time problems, and issues setting it up. ", "purple");
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("");
	print("");
	print("");

	//Attempt to disable warnings for not enough stats at this location. 
	print("BCC: Ensuring that warnings that you don't have enough stats are disabled.", "purple");
	visit_url("account.php?am=1&pwd=&action=flag_ignorezonewarnings&value=1&ajax=1");
	
	alias [int] aliaslist;
	if (load_current_map("bcs_aliases", aliaslist) && get_property("bcasc_lastAliasVersion") != bcasc_version) {
		print("BCC: Registering aliases for script use. Check the forum thread - http://kolmafia.us/showthread.php?t=4963 - for more information", "purple");


		cli_execute("alias bcasc => ash import <" + __FILE__ + ">; mainWrapper();");
		foreach x in aliaslist {
			print("Setting alias '"+aliaslist[x].cliref+"' for function '"+aliaslist[x].functionname+"'.", "purple");
			cli_execute("alias bcasc_"+aliaslist[x].cliref+" => ash import <" + __FILE__ + ">; bcasc"+aliaslist[x].functionname+"();");
		}
		set_property("bcasc_lastAliasVersion", bcasc_version);
	}
	
	if (my_inebriety() > inebriety_limit()) abort("BCC: You're drunk. Don't run this script when drunk, fool.");
	
	if (get_property("autoSatisfyWithNPCs") != "true") {
		set_property("autoSatisfyWithNPCs", "true");
	}
	
	if (get_property("autoSatisfyWithCoinmasters") != "true") {
		set_property("autoSatisfyWithCoinmasters", "true");
	}
	
	if (get_property("bcasc_shutUpAboutOtherScripts") != "true") {
		if (get_property("recoveryScript") == "") {
			print("You do not have a recoveryScript set. I highly recommend Bale's 'Universal Recovery' - http://kolmafia.us/showthread.php?t=1780 - You may find this script runs into problems with meat without it.", "red");
			print("To not be reminded about supplementry scripts, please set the appropriate option in the relay script (which you can find on the kolmafia.us forum thread for this script).", "red");
			wait(1);
		}
		
		if (get_property("counterScript") == "") {
			print("You do not have a counterScript set. I highly recommend Bale's 'CounterChecker' http://kolmafia.us/showthread.php?t=2519 - This script, in combination with bumcheekascend, will allow you to get semi rares if you eat fortune cookies.", "red");
			print("To not be reminded about supplementry scripts, please set the appropriate option in the relay script (which you can find on the kolmafia.us forum thread for this script).", "red");
			wait(1);
		}
	}
	
	if (!in_hardcore() && get_property("bcasc_doNotRemindAboutSoftcore") != "true") {
		print("You are in softcore. The script behaves differently for softcore and requires you to follow the small number of instructions in the following page - http://kolmafia.us/showthread.php?t=4963", "red");
		//abort("BCC: To remove this notice and be able to use the script, please set the appropriate option in the relay script (which you can find on the kolmafia.us forum thread for this script).");
	}
	
	if (have_effect($effect[Teleportitis]) > 0 && my_level() < 13) {
		if (!contains_text("da.php", "greater.gif") && my_level() >= 8)
			bcascWand();
		} else {
			bcascTeleportitisBurn();
	}

	print("******************", "green");
	print("Ascending Starting", "green");
	print("******************", "green");
	
	//Let's clear out goals at the start of the script to avoid problems.
	cli_execute("goals clear");
	
	//Before we start, we'll need an accordion. Let's get one. 
	if (my_class() != $class[Accordion Thief] && my_path() != "Avatar of Boris" && my_path() != "Zombie Slayer" && (i_a("toy accordion") + i_a("antique accordion")) == 0 && (checkStage("toot")) && npc_price($item[toy accordion]) > 0 && my_meat() > 500) {
		print("BCC: Getting an Accordion before we start. By the way, you might want to tell the script to sell your pork gems using the relay script if this fails due to lack of meat.", "purple");
		buy(1, $item[toy accordion]);
	}
	sellJunk();
	
	//Do a quick check to see if the person has set the script to adventure at the daily dungeon every day.
	if (my_level() > 6 && get_property("bcasc_dailyDungeonEveryday").to_boolean() && !get_property("dailyDungeonDone").to_boolean()) {
		cli_execute("adv * daily dungeon");
	}
	
	bumcheekcend();
	
	print("******************", "green");
	print("Ascending Finished", "green");
	print("******************", "green");
}

void main() {
	mainWrapper();
}
