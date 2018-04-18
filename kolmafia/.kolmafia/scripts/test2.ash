import <zlib.ash>;
import <misclib.ash>;
import <Detective Solver2.ash>;
import <volcano_mining2.ash>;
import <EatDrink2.ash>;
import <FarFuture2.ash>;
import <witchess_solver2.ash>;
//import <tdailyitems.ash>;



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

void maineatdrink (int foodMax, int drinkMax, int spleenMax, boolean overdrink, 
           boolean sim)
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
//void tdmain(){
//	td_items();
//	td_skills();
//}
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
void main(){
	// First checks to see if anything has been eaten or drank today, if so aborts. This is used as a flag for a manually run day
	if ( (my_fullness() != 0) | (my_inebriety() != 0) | (my_spleen_use() != 0)){
		abort("Actions already taken today, finish day manually");
		}
	// Eats and drinks and ?spleens? to fullness
	maineatdrink( fullness_limit(), inebriety_limit(), spleen_limit(), False, False);
	
	//Chateau Potions
	visit_url("place.php?whichplace=chateau&action=chateau_desk2",false);
	//April Shower 
	
	//Detective
	maindetective();
	
	//Deck of Every Card
	
	foreach card in cards{
		cli_execute(("cheat " + cards[card]));
	}
	
	//Time Spinner
	mainfarfuture("food");
	
	
	//5 Free Witchess Fights
	witchessfights();
	
	
	//Witchess Puzzles
	mainwitchess();
	
	// 10 Free Snojo Fights
	snojo();
	
	// Daily Items
	tdmain();
	
	// Daily Skills
	
	// VOLCANO MINE
	mainvolcano(my_adventures(), True, True);
	
	//MORE THINGS SHOULD GO HERE
	
	//Overdrink THIS SHOULD BE THE LAST THING DONE BEFORE EXITING
	maineatdrink( (fullness_limit() - my_fullness()), (inebriety_limit() - my_inebriety()), (spleen_limit() - my_spleen_use()), True, False);
	//
	}
	
	
	
	
	
	
	
	
	
		