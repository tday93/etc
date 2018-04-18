import <zlib.ash>;
import <misclib.ash>;
import <Detective Solver2.ash>;
import <volcano_mining2.ash>;
import <EatDrink2.ash>;
import <FarFuture2.ash>;
import <witchess_solver2.ash>;
import <fishbot2.ash>;
import <harvest2.ash>;
//import <bounty.ash>;



//VARIABLES YO

	//cards to pull
	string [int] cards;
	cards[0] = "island";
	cards[1] = "Ancestral Recall";
	cards[2] = "Year of Plenty";
	
void mainfarfuture(string desired_item_name)
{
    print("FarFuture.ash version " + __version);
	if (__setting_debug && __setting_run_file_test) //breaks one-at-a-time handling
	{
		testFileState();
        return;
	}
    desired_item_name = desired_item_name.to_lower_case();
    
    int medals = get_property_int("timeSpinnerMedals");
    if (medals == 0) //just assume they haven't had this property read yet, or are on an older version
        medals = 20;
    
    boolean should_mallsell_replicated_item = false;
    if (desired_item_name.contains_text("memory") || desired_item_name.contains_text("alpha") || desired_item_name.contains_text("disk"))
        __item_desired_to_replicate = $item[Memory Disk, Alpha];
    else if (desired_item_name.contains_text("tea") || desired_item_name.contains_text("food") || desired_item_name.contains_text("earl grey"))
        __item_desired_to_replicate = $item[Tea, Earl Grey, Hot];
    else if (desired_item_name.contains_text("ears") || desired_item_name.contains_text("unstable") || desired_item_name.contains_text("pointy") || desired_item_name.contains_text("spock") || desired_item_name.contains_text("vulcan"))
        __item_desired_to_replicate = $item[Unstable Pointy Ears];
    else if (desired_item_name.contains_text("kanar") || desired_item_name.contains_text("cardassian") || desired_item_name.contains_text("kardashian") || desired_item_name.contains_text("gin") || desired_item_name.contains_text("booze") || desired_item_name.contains_text("drink") || desired_item_name.contains_text("alcohol") || desired_item_name.contains_text("shot") || desired_item_name.contains_text("pvp"))
        __item_desired_to_replicate = $item[Shot of Kardashian Gin];
    else if (desired_item_name.contains_text("history") || desired_item_name.contains_text("riker") || desired_item_name.contains_text("googling") || desired_item_name.contains_text("search"))
        __item_desired_to_replicate = $item[Riker's Search History];
    else if (desired_item_name.contains_text("mall") || desired_item_name.contains_text("whatever") || desired_item_name.contains_text("idk"))
    {
        boolean [item] replicable_items;
        if (medals >= 5)
            replicable_items[$item[Shot of Kardashian Gin]] = true;
        if (medals >= 10)
            replicable_items[$item[Riker's Search History]] = true;
        if (medals >= 15)
            replicable_items[$item[Tea\, Earl Grey\, Hot]] = true;
        if (medals >= 20)
            replicable_items[$item[memory disk\, alpha]] = true;
        
        foreach it in replicable_items
        {
            if (__item_desired_to_replicate.mall_price() < it.mall_price())
                __item_desired_to_replicate = it;
        }
        should_mallsell_replicated_item = true;
    }
    if (desired_item_name.is_integer())
    {
        item converted = desired_item_name.to_int_silent().to_item();
        if ($items[memory disk\, alpha,Unstable Pointy Ears,Shot of Kardashian Gin,Riker's Search History,Tea\, Earl Grey\, Hot] contains converted)
            __item_desired_to_replicate = converted;
    }
    if ((desired_item_name == " " || desired_item_name == "" || desired_item_name == "help" || desired_item_name == "list") && !get_property_boolean("_futureReplicatorUsed"))
    {
        print_html("Are you sure you don't want to replicate anything? Options:");
        if (medals >= 5)
            print_html("<b>drink</b> - Shot of Kardashian Gin - Epic one-drunkenness drink, gives PVP fights");
        if (medals >= 15)
            print_html("<b>food</b> - Tea, Earl Grey, Hot - Epic one-fullness food");
        if (medals >= 20)
            print_html("<b>memory</b> - Memory Disk, Alpha - Sell in mall for others to play the game.");
        if (medals >= 10)
            print_html("<b>history</b> - Riker's Search History - combat item, deals ~950 sleaze damage.");
        print_html("<b>ears</b> - Unstable Pointy Ears - +3 stats/fight accessory");
        print_html("<b>mall</b> - Whatever sells for the most. (will add it to store)");
        print_html("&nbsp;");
        print_html("<b>none</b> - Yes, I'm certain I don't want to replicate anything.");
        return;
    }
    else if (desired_item_name != "" && __item_desired_to_replicate == $item[none] && desired_item_name != "none" && desired_item_name != "nothing")
    {
        print_html("Sorry, don't know how to make \"" + desired_item_name + "\".");
    }
    
    int starting_amount_of_replicated_item = __item_desired_to_replicate.item_amount();
	
	//Are we in a game?
    string page_text = visit_url("choice.php");
    if (!page_text.contains_text("Starship ") && !page_text.contains_text("blue><b>The Far Future")) //hack
    {
        boolean use_memory_disk_alpha = false;
        if ($item[time-spinner].item_amount() == 0)
        {
            print("You don't seem to have a time-spinner.");
            if ($item[Memory Disk, Alpha].available_amount() > 0)
            {
                boolean yes = user_confirm("Do you want to use a memory disk, alpha?");
                if (!yes)
                    return;
                else
                    use_memory_disk_alpha = true;
            }
            else
                return;
        }
        //Start game:
        if (use_memory_disk_alpha)
        {
            page_text = visit_url("inv_use.php?whichitem=9121");
        }
        else
        {
    
            if (my_adventures() == 0 && !use_memory_disk_alpha)
            {
                print("Can't use time spinner without adventures.");
                return;
            }
            
            page_text = visit_url("inv_use.php?whichitem=9104");
            int minutes = page_text.group_string("You have ([0-9]*) minutes left today.")[0][1].to_int_silent();
            if (minutes < 2) //no time
            {
                print("Your time-spinner is outa time. Try tomorrow?");
                return;
            }
            page_text = visit_url("choice.php?whichchoice=1195&option=4");
        }
    }
	runGame();
    if (should_mallsell_replicated_item && __item_desired_to_replicate.item_amount() > starting_amount_of_replicated_item && __item_desired_to_replicate.item_amount() > 0 && have_shop() && __item_desired_to_replicate != $item[none])
    {
        put_shop(__item_desired_to_replicate.mall_price(), 0, 1, __item_desired_to_replicate);
    }
}
void harvestmain()
	{
	announce(2, "main");
	set_default_settings();
	
	if(!COMPLETED_SETUP)
		{
		print("Script setup complete. You can now configure the script's options with the relay script", "green");
		print("Remember to click the Save button (bottom left) when you're done", "green");
		}
	else
		{
		announce(1, "Preparing to bring in the harvest", true);
		initialise();
		
		if(!finished_farming())
			{
			if(BOUNTYHUNT)
				{				
				if(!finished_bountyhunting())
					bountyhunteasy();
					bountyhunthard();
					bountyhuntspecial();
				}
			}
						

		if(!finished_farming())
			{
			if(PUTTYFARM)
				copyfarm();
				
			if(DUCKHUNT)
				duck_hunt();
			
			if(FARM)	
				farm();
			}
		
		}
	}
void mainfish(int adventures) {
	parse_fish();
	//Don't fish if we can't. parse_fish() will guarantee that we have get a fishin' pole if we can get one
	if ($item[fishin' pole].available_amount() == 0)
		abort("You can't fish without a pole, city slicker.");
	parse_holes();
	fish_equip_gear();

	//Don't adventure when we can't
	int adv = adventures;
	while (adv > 0 && my_adventures() > 0) {
		keep_up_buffs();
		location lf = least_fish();
		if (lf == $location[none]){
			abort("You can't seem to find any suitable fishing holes. Check the Floundry and see what you can unlock.");
		}
		familiar f = my_familiar();
		can_adv(lf, true);
		adventure(1, lf);
		f.use_familiar();

		//Increase the fish count, so we'll keep an even stock
		foreach fish, cnt in found_fish() {
			fish_count[fish] += cnt;
		}
		adv -= 1;
	}
}

void maindetective()
{
	if (!__disable_output)
		print_html("Detective Solver.ash version " + __version);
	if (__setting_debug)
	{
		__setting_time_limit = 7000;
		__setting_visit_url_limit = 2000;
	}
	
	if (__setting_debug && false) //do not enable unless you love sending server requests
	{
		collectTestData();
		return;
	}
	
	solveAllCases(false);
}

void maineatdrink (int foodMax, int drinkMax, int spleenMax, boolean overdrink, boolean sim)
{
  SIM_CONSUME = sim;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}


void mainvolcano(int turnsToMine, boolean lazyFarm, boolean autoDetection)
	{
	if (turnsToMine != 0)
		NUM_TURNS_TO_LEAVE = my_adventures() - turnsToMine;
	LAZY_FARM = lazyFarm;
	AUTO_UP_DETECTION = autoDetection;
	mine_volcano();
}

void snojo() 
	{
	if(to_boolean(get_property("snojoAvailable")) && get_property("_snojoFreeFights").to_int() < 10) {
		if(get_property("snojoSetting") == "NONE")
			visit_url("place.php?whichplace=snojo&action=snojo_controller");
		while(get_property("_snojoFreeFights").to_int() < 10)
			adv1($location[The X-32-F Combat Training Snowman], -1, "");
	}
}
void mainwitchess() {
	if (ws_run()) {
		print("Witchess puzzles finished.", "green");
	} else {
		ws_throwErr("Could not complete all witchess puzzles.");
	}
}
void tdmain(){
	//using try here to avoid "already casted" errors
	
	//Skills:
	use_skill(1, to_skill("pastamastery"));
	use_skill(1, to_skill("advanced cocktailcrafting"));
	use_skill(1, to_skill("advanced saucecrafting"));
	
	//items:
	cli_execute("use cheap toaster");
	cli_execute("use chroner cross");
	cli_execute("use festive warbear bank");
	cli_execute("use trivial avocations board game");
	cli_execute("use warbear breakfast machine");
	cli_execute("use warbear soda machine");
	
	// VOLCOINO
	outfit("Smooth Velvet");
	visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
	visit_url("choice.php?pwd&whichchoice=1090&option=7");
	

}
void witchessfights() {
    if(get_campground() contains $item[Witchess Set] && get_property("_witchessFights").to_int() < 5) {
        static {
            int [item] choice;
                choice[ $item[armored prawn] ] = 1935;
                choice[ $item[jumping horseradish] ] = 1936;
                choice[ $item[Sacramento wine] ] = 1942;
                choice[ $item[Greek fire] ] = 1938;
            item [int] priciest;
                foreach it in choice
                    priciest[ count(priciest) ] = it;
        }
        sort priciest by -mall_price(value);
        
        while(get_property("_witchessFights").to_int() < 5) {
            visit_url("campground.php?action=witchess");
            run_choice(1);
            visit_url("choice.php?option=1&pwd="+my_hash()+"&whichchoice=1182&piece=" + choice[ priciest[0] ], false);
            run_combat();
        }
    }
}  

/* void mainbounty(string param) {
   if (count(options) + count(current) == 0) vprint("Bounty hunt already completed today.",-3);
    else if (initiallucre != item_amount($item[filthy lucre])) vprint("You just turned in your bounty.",-3);
    else switch (param) {
      case "list": return;
      case "cancel":
      case "abort": if (count(current) > 0 && cancel_bounty()) vprint("Bounty hunt canceled.",2); return;
      case "hard":
      case "best": accept_best_bounty(false); return;
      case "smallest":
      case "small": accept_best_bounty(true); return;
#      case "optimal": accept_optimal_bounty(); return;
      case "go":
      case "*": if (hunt_bounty()) vprint("Bounty hunt successful.",3);
         else vprint("Bounty hunt failed.",-2); return;
      default: print_html("<b>Usage:</b><p>bounty.ash {go|*}<br>bounty.ash list<br>bounty.ash {best|small|hard}<br>bounty.ash {abort|cancel}");
   }
} */
void get_clovers(){
		
	int amount = item_amount($item[disassembled clover]) + item_amount($item[ten-leaf clover]);
	hermit(999, $item[ten-leaf clover]);	
}
void deckdraws(){
	item it = $item[Deck of Every Card];
	int uses = it.dailyusesleft;
	if( uses >0){
		foreach card in cards{
		cli_execute(("cheat " + cards[card]));
		}
	}
}
boolean gardenharvest() {
    foreach c,q in get_campground()
        switch(c) {
        case $item[pumpkin]:
        case $item[huge pumpkin]:        // Day 5 of Pumpkin Patch
        case $item[ginormous pumpkin]:    // Day 11 of Pumpkin Patch
        case $item[peppermint sprout]:
        case $item[giant candy cane]:    // Day 5 of Peppermint Patch
        case $item[frost flower]:        // Day 3 of Winter Garden
            return q > 0;
        case $item[skeleton]:            // Turns into a skulldozer on day 5
            if(q < 0) print("OMG! There is a Humongous Skull in the garden?! It looks DANGEROUS!", "red");
            return q > 0;
        case $item[fancy beer label]:    // total of labels and bottles. First appears on day 2.
            return q > 5;                // Full growth on day 7 with 3 labels + 3 bottles
        case $item[cornucopia]:            // Thanksgarden cornucopia growth is 1, 3, 5, 8, 11, 15
            return q > 11;
        case $item[megacopia]:            // Thanksgarden day 7 is a megacopia.
            return true;
        }
    return false;
}
void main(boolean override, boolean drinktoday, boolean turnburn, boolean resources, boolean nightcap){
	cli_execute("login tday93");
	cli_execute("conditions clear");
	// First checks to see if anything has been eaten or drank today, if so aborts. This is used as a flag for a manually run day
	if ( (my_fullness() != 0) | (my_inebriety() != 0) | (my_spleen_use() != 0)){
		if(override){
		abort("Actions already taken today, finish day manually");
		}
	}
		// GENERATE RESOURCES
	if(resources){
		// Daily Items and Skills
		tdmain();
		
		// mad buffs yo
		string buffmessage = "Ghostly Shell Reptilian Fortitude Empathy of the Newt Tenacity of the Snapper Astral Shell Jingle Bells Elemental Saucesphere Jalapeno Saucesphere Scarysauce Fat Leon Brawnee";
		kmail("Buffy", buffmessage, 0);
		
		// default floundry 
		if(item_amount($item[troutsers]) != 1){
			cli_execute("acquire troutsers");
		}

		//Chateau Potions
		visit_url("place.php?whichplace=chateau&action=chateau_desk2",false);
		//April Shower 
		cli_execute("shower hot");
		
		//Detective
		maindetective();
		
		//Deck of Every Card
		deckdraws();
				
		if(gardenharvest()) cli_execute("garden pick");  
		
		// buy clovers:
		get_clovers();
		

		//Time Spinner
			//checks to see if already been used
		if($item[Time-Spinner].dailyusesleft == 10){	
			mainfarfuture("food");
		}
		//Witchess Puzzles
		mainwitchess();
		
		//FREE FIGHTS HERE
		
		//first equip gear for fights
		string myclass = to_string(my_class());
		switch (myclass){
			case "Pastamancer":
				outfit("pastamancer combat");
				break;
			case "Sauceror":
				outfit("sauceror combat");
				break;
			case "Seal Clubber":
				outfit("seal clubber combat");
				break;
			case "Turtle Tamer":
				outfit("turtle tamer combat");
				break;
			case "Accordion Thief":
				outfit("accordion thief combat");
				break;
			case "Disco Bandit":
				outfit("disco bandit combat");
				break;
		}
			
		//5 Free Witchess Fights
		witchessfights();
		
		// 10 Free Snojo Fights	
		snojo();

		
		// free money from hippies
		visit_url("shop.php?whichshop=hippy");
	}
	
	// GENERATE ADVENTURES
	
	// Eats and drinks and ?spleens? to fullness
	if (drinktoday){
		maineatdrink( fullness_limit(), inebriety_limit(), spleen_limit(), False, False);
	}
	//USE ADVENTURES
	if(turnburn){
		// BOUNTIES
		//mainbounty("best");
		use_familiar($familiar[Nosy Nose]);
				switch (myclass){
			case "Pastamancer":
				outfit("pastamancer harvest");
				break;
			case "Sauceror":
				outfit("sauceror harvest");
				break;
			case "Seal Clubber":
				outfit("seal clubber harvest");
				break;
			case "Turtle Tamer":
				outfit("turtle tamer harvest");
				break;
			case "Accordion Thief":
				outfit("accordion thief harvest");
				break;
			case "Disco Bandit":
				outfit("disco bandit harvest");
				break;
		}
		harvestmain();
		
		//fish to replenish stocks
		mainfish(20);

		// VOLCANO MINE
		
		mainvolcano(my_adventures(), True, True);
		
		// burn free chateau rests
			int rests_used=get_property("timesRested").to_int();
		int rests_left=total_free_rests()-rests_used;
		while ( rests_left > 0){
			rests_used=get_property("timesRested").to_int();
			rests_left=total_free_rests()-rests_used;
			visit_url("place.php?whichplace=chateau&action=chateau_restbox");
		}

		//MORE THINGS SHOULD GO HERE
		
		

		
	}
			//Overdrink  and Pajamas THIS SHOULD BE THE LAST THING DONE BEFORE EXITING
	if (nightcap){
		maineatdrink(fullness_limit(), inebriety_limit(), spleen_limit(),true,false);
		outfit("Pajamas");
	}
	
}
	
	
	
	
	
	
	
	
	
		
