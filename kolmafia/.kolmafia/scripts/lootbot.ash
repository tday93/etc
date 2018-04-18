// LootBot: A dungeon loot sellbot, by Guyy.
//
// Use "lootbot" in the drop-down at the top-right of the relay browser to set things up,
// then type "lootbot on" in the CLI to turn it on. Make sure you have Mafia chat running
// so it can detect Kmails.
//
// You'll need to run this from an account with whitelist/dungeon-admin priveliges, and 
// in a clan with appropriate ranks for adventurers in each dungeon. (Slime Tube can use 
// the basic "Normal Member" rank, since no special permissions are needed to fight copies.)
//
// Other CLI commands:
//
// "lootbot loot" shows the price list produced by kmailing "#loot".
//
// "lootbot orders" lists all incomplete orders.
//
// "lootbot send [dungeon]" sends out all ordered loot. Do this after pre-ordered loot drops.
// For players with dropped loot who aren't in the logs, it will send reminders.
// Auto-cancels any orders that cannot be fulfilled.
//
// "lootbot empty [dungeon]" attempts to get rid of all the loot by sending it to any eligible
// orderers (even if there are ineligible ones ahead of them). The rest is sent to
// your own account, if possible.
//
// "lootbot consume" sends you all the consumable (tradeable) drops.
//
// "lootbot cancel [itemname, itemname...]" erases orders and sends the Meat back. 
// If there's no item list, it cancels all orders.
//
// "lootbot blacklist [username]" blocks untrustworthy users from buying loot.
//
// "lootbot unlock" overrides the "script is already running" overlap prevention.
// Use carefully, or weird things may happen. Restarting Mafia first is a good idea.


// <option value=-1>[sell item]</option

script "lootbot.ash";
notify guyy;

import <zlib.ash>

record dung_loot
{
	string item_name;
	string sub_items;
	boolean selling;
	boolean preorder;
	int price;
	int limit;
	int discount;
};
dung_loot[int] dat_loot;
int[string] loot_dropped;
int[string] loot_taken;
string[string] loot_drop_name;
string[string] loot_drop_name_shrt;
int[string] loot_drop_ID;

record dung_ord
{
	string player_name;
	string player_ID;
	string item_name;
	int price;
	boolean completed;
	string order_time;
};
dung_ord[int] dem_orders;
dung_ord[int] all_orders;

int slime_end = 4;
int hobo_end = 35;
int dread_end = 60;

string mah_username;
string mah_clan;
boolean preorder_thing;
boolean slime_not_pre;

record lb_vars
{
	string var_name;
	string var_value;
};
lb_vars[int] dem_vars;
boolean Loaded_Vars;

matcher stuffmatch;
int[int] ordered_items;
boolean[int] pre_ordah;
int[int] item_prices;
int totes_price;

string[string] ordered_junk;
string[string] ordered_instruct;
string[string] ordered_ID;
boolean[int] send_me;

int MasterRank;
int SlimeRank;
int HoboRank;
int DreadRank;
boolean UnWhiteList;

boolean in_combat()
{
	return !contains_text(visit_url("messages.php"),"[write a message]");
}

void lootbot_lock()
{
	while(get_property("_lootbotLocked").to_boolean())
	{
		print("A lootbot script is already running. Waiting... (use \"abort\", followed by \"lootbot unlock\", to reset)", "red");
		waitq(30);
	}
	set_property("_lootbotLocked","true");
}

void lootbot_unlock()
{
	set_property("_lootbotLocked","false");
}

void combat_wait()
{
	while (in_combat())
	{
		print("In combat. Retrying in 30 seconds...","red");
		waitq(30);
	}
}

void lb_kmail(string player, string mess, int bux)
{
	combat_wait();
	if (bux > 0)
		refresh_status();
	
	combat_wait();
	if (my_meat() < bux)
		print("WARNING: Unable to send "+bux+" Meat to "+player+". Message: "+mess,"red");
	if (!kmail(player, mess, bux))
	{
		if (bux > 0 && kmail(player, mess+"\nThere was supposed to be "+bux+" Meat attached, but something went wrong. Send an irritated message, and hopefully the human running this account will do something about this.", 0)) {}
		abort("Failed to send kmail!");
	}
}

string trim(string trimmy)
{
	trimmy = replace_string(trimmy, "\n", "");
	trimmy = replace_string(trimmy, "\r", "");
	trimmy = replace_string(trimmy, "\t", "");
	trimmy = replace_string(trimmy, "\\", "");
	trimmy = replace_string(trimmy, "\"", "");
	trimmy = replace_string(trimmy, "[", "");
	trimmy = replace_string(trimmy, "]", "");
	trimmy = replace_string(trimmy, ".", "");
	
	matcher haz = create_matcher("#\\s*",trimmy);
	if (find(haz))
		trimmy = replace_string(trimmy, group(haz,0), "#");
	
	matcher tim = create_matcher("^\\s*(.*?)\\s*$",trimmy);
	
	if (find(tim))
		return group(tim,1);
	else
		return trimmy;
}

string get_command(string texty)
{	
	string dat_command;

	matcher dat_matcher = create_matcher("(^#?lootbot|#loot)\\s*(.*)$",texty.to_lower_case().trim());
	
	if (!find(dat_matcher))
		dat_command = "";
	else
	{
		dat_command = group(dat_matcher,2).replace_string("#","");
		if (dat_command == "")
			dat_command = "loot";
	}
	
	return dat_command;
}

string get_actual_name()
{
	if (get_property("_capitalizedUserName") == "")
	{
		matcher namatch = create_matcher("blue><b>([^<]*)",visit_url("charsheet.php"));
		if (find(namatch))
			set_property("_capitalizedUserName",group(namatch,1));
		else
			set_property("_capitalizedUserName",my_name());
	}
	
	return get_property("_capitalizedUserName");
}

string get_clan()
{
	if (mah_clan == "")
	{
		matcher m = create_matcher( "whichclan=[0-9]*\">(.*?)<" , visit_url( "showplayer.php?who=" + my_id().to_string() ) );
		if( m.find() )
			mah_clan = group(m,1);
		else
			mah_clan = "NONE";
	}
	
	return mah_clan;
}

string usr_nayme()
{
	return replace_string(my_name().to_lower_case()," ","_");
}

string file_label()
{
	return replace_string(get_clan()," ","_");
}

void load_lb_var()
{
	if (!Loaded_Vars)
	{
		file_to_map("lootbot_vars_"+file_label()+".txt",dem_vars);
		Loaded_Vars = true;
	}
}

string lb_var(string varname)
{
	load_lb_var();
	
	foreach v in dem_vars
		if (dem_vars[v].var_name == varname)
			return dem_vars[v].var_value;
			
	return "";
}

void set_lb_var(string varname, string value)
{
	load_lb_var();
	
	int toat = 0;
	boolean found = false;
	foreach v in dem_vars
	{
		toat += 1;
		if (dem_vars[v].var_name == varname)
		{
			dem_vars[v].var_value = value;
			found = true;
			break;
		}
	}
	
	if (!found)
	{
		dem_vars[toat+1].var_name = varname;
		dem_vars[toat+1].var_value = value;
	}
	map_to_file(dem_vars,"lootbot_vars_"+file_label()+".txt");
}

string rank_get(boolean slim, boolean hobo, boolean drea)
{
	if ((slim && hobo) || (slim && drea) || (drea && hobo))
		return lb_var("MasterRank");
	else if (slim)
		return lb_var("SlimeRank");
	else if (hobo)
		return lb_var("HoboRank");
	else if (drea)
		return lb_var("DreadRank");
	return "NORANK";
}

int player_rank(string membahs, string listy, string playernum)
{
	int cur_rank = -1;
	matcher rank_match;
	if (playernum > 0)
	{
		rank_match = create_matcher("level"+playernum+".*?option value=([0-9]*) selected>", membahs);
		if (find(rank_match))
			cur_rank = group(rank_match,1).to_int();
		else
		{
			rank_match = create_matcher("level"+playernum+".*?option value=([0-9]*) selected>", listy);
			if (find(rank_match))
				cur_rank = group(rank_match,1).to_int();
		}
	}
	
	return cur_rank;
}

boolean witlist(string dudebro, string playernum, boolean adam, string ranko)
{
	string listy = visit_url("clan_whitelist.php");
	
	if (contains_text(listy,"#"+playernum) && !adam)
	{
		if (visit_url("clan_whitelist.php?action=update&pwd="+my_hash()+"&player"+playernum+"="+playernum+"&drop"+playernum+"=true").contains_text("Whitelist updated."))
		{
			print("Removed "+dudebro+" from whitelist.","blue");
			return true;
		}
		else
			print("Failed to remove "+dudebro+" from whitelist.","red");
	}
	else if (adam)
	{
		string membahs = visit_url("clan_members.php");
		int cur_rank = player_rank(membahs, listy, playernum);
		int new_rank;
		matcher rank_match = create_matcher("option value=([0-9]*)[^>]*?>"+ranko, listy);
		if (find(rank_match))
			new_rank = group(rank_match,1).to_int();
		else
		{
			print("Rank "+ranko+" not recognized!","red");
			return false;
		}
		if (cur_rank == new_rank)
		{
			print(dudebro+" is already whitelisted and/or in the clan with the correct rank.","blue");
			return true;
		}
		
		string mah_title;
		string titlesearch = "title"+playernum+"[^>]*?value=\"(.*?)\"";
		matcher title_match = create_matcher(titlesearch,membahs);
		if (find(title_match))
			mah_title = group(title_match,1);
		else
		{
			title_match = create_matcher(titlesearch,listy);
			if (find(title_match))
				mah_title = group(title_match,1);
		}
		
		int clanny_point = index_of(listy,"Choose a clan member:");
		int player_point = index_of(listy,"#"+playernum);
		boolean is_on_whitelist = (player_point > 0 && player_point < clanny_point);
		boolean is_in_clan = contains_text(membahs,"#"+playernum);
		
		if (is_in_clan && contains_text(visit_url("clan_members.php?action=modify&pwd="+my_hash()+"&pids[]="+playernum+"&level"+playernum+"="+new_rank+"&title"+playernum+"="+mah_title).to_lower_case(),"modified level for "+dudebro.to_lower_case()))
			print("Updated rank of "+dudebro+".","blue");
		if (!is_on_whitelist && !contains_text(visit_url("clan_whitelist.php?action=add&pwd="+my_hash()+"&addwho="+dudebro+"&level="+new_rank+"&title="+mah_title),"Invalid player."))
			print("Added "+dudebro+" to whitelist.","blue");
		else if (is_on_whitelist && !is_in_clan && !contains_text(visit_url("clan_whitelist.php?action=update&pwd="+my_hash()+"&player"+playernum+"="+playernum+"&level"+playernum+"="+new_rank+"&title="+mah_title),"Invalid player."))
			print("Adjusted rank of "+dudebro+".","blue");
		
		return true;
	}
	
	return false;
}

void blaklist(string jerkwad)
{
	string[int] derp;
	file_to_map("lootbot_blacklist.txt",derp);
	int listers = derp[0].to_int();
	
	for i from 1 to listers
	{
		if (to_lower_case(derp[i]) == to_lower_case(jerkwad))
		{
			print(jerkwad+" is already blacklisted.");
			return;
		}
	}
	
	listers += 1;
	derp[listers] = jerkwad;
	derp[0] = listers.to_string();
	map_to_file(derp,"lootbot_blacklist.txt");
	print(jerkwad+" is now blacklisted from your LootBot.");
}

void num_drops(string payj, string nayme, string genericname)
{
	int groupz = 0;
	int num = 0;
	int staht = 0;
	int ehnd = 0;
	string[int] subnames;
	
	if (contains_text(nayme,"|"))
	{
		string matchyapp = "\\s*([^\\|]+)\\|+";
		stuffmatch = create_matcher(matchyapp, nayme+"|");
		while (find(stuffmatch))
		{
			groupz += 1;
			subnames[groupz] = group(stuffmatch,1);
		}
	}
	else
	{
		subnames[1] = nayme;
		groupz = 1;
	}
	
	for i from 1 upto groupz
	{
		staht = 0;
		if (subnames[i] != "" && contains_text(payj.to_lower_case(), subnames[i].to_lower_case()))
		{
			loot_drop_name[genericname] = subnames[i];
			if (groupz > 1)
			{
				int samey = 0;
				boolean all_same;
				for j from 1 to subnames[i].length()
				{
					all_same = true;
					for k from 1 upto groupz - 1
						if (subnames[k].length() <= samey || subnames[k+1].length() <= samey || subnames[k].substring(samey,samey+1) != subnames[k+1].substring(samey,samey+1))
							all_same = false;
					if (!all_same)
						break;
					samey += 1;
				}
				loot_drop_name_shrt[genericname] = subnames[i].substring(samey,length(subnames[i]));
			}
			while (index_of(payj.to_lower_case(), subnames[i].to_lower_case(), staht) > 0)
			{
				num += 1;
				staht = index_of(payj.to_lower_case(), subnames[i].to_lower_case(), staht) + 11;
			}
		}
	}
	
	loot_dropped[genericname] = num;
}

int can_order(int i)
{
	if (!dat_loot[i].selling)
		return -1;

	if ((loot_dropped[dat_loot[i].item_name] - loot_taken[dat_loot[i].item_name] > 0 || 
	(dat_loot[i].preorder && loot_dropped[dat_loot[i].item_name] + dat_loot[i].limit - loot_taken[dat_loot[i].item_name] > 0)) &&
	((i <= slime_end && lb_var("SlimeActive").to_boolean()) ||
	(i > slime_end && i <= hobo_end && lb_var("HoboActive").to_boolean()) ||
	(i > hobo_end && lb_var("DreadActive").to_boolean())))
	{
		if (loot_dropped[dat_loot[i].item_name] - loot_taken[dat_loot[i].item_name] > 0)
			return 1;
		else
			return 2;
	}
	
	return 0;
}

void unlist_check(string buyer, string eyedee)
{
	if (buyer == "" || buyer == "!SEND!" || buyer == "!EMPTY!")
		return;
	foreach ord in dem_orders
		if (dem_orders[ord].player_name.to_lower_case() == buyer.to_lower_case() && !dem_orders[ord].completed)
			return;
	witlist(buyer, eyedee, false, 0);
}

boolean can_transfer(int i)
{
	matcher matchy;
	string paj = to_lower_case(visit_url("clan_raidlogs.php"));
	
	string matchfindy = "<!--[^!]*?\\(#"+my_id()+"\\) +(?!was defeated)[^!]*?<b>loot";

	if (loot_drop_ID[dem_orders[i].item_name] <= slime_end)
		matchy = create_matcher("the slime tube:"+matchfindy,paj);
	else if (loot_drop_ID[dem_orders[i].item_name] <= hobo_end)
		matchy = create_matcher("hobopolis:"+matchfindy,paj);
	else
		matchy = create_matcher("dreadsylvania:"+matchfindy,paj);
		
	if (find(matchy))
		return false;
		
	return true;
}

void dist_loot(int order_index, string gen_item_name, string buyer, string buyer_id)
{
	string dungy = visit_url("clan_basement.php");
	
	string loot_name = loot_drop_name[gen_item_name];
	if (loot_name == "")
		loot_name = gen_item_name;
	if (loot_name == "")
		abort("No item name found!");
	matcher lootmatch = create_matcher(loot_name+".*?whichloot value=([0-9]*)",dungy);
	
	string pagey;
	if (find(lootmatch))
		pagey = visit_url("clan_basement.php?whichloot="+group(lootmatch,1)+"&recipient="+buyer_id);
	else
	{
		// shouldn't actually do this...
		lb_kmail(buyer, "There doesn't seem to be a "+loot_name+" available, so here's your Meat back.", dem_orders[order_index].price);
		print("Couldn't send "+buyer+"'s "+loot_name+" because we don't have any of those.","red");
		return;
	}
	
	print("");
	if (order_index > 0 && buyer.to_lower_case() != my_name().to_lower_case() && buyer.to_lower_case() != lb_var("MainUser").to_lower_case())
	{
		string rad_logs = visit_url("clan_raidlogs.php").to_lower_case();
		dem_orders[order_index].completed = true;
		
		if (pagey.contains_text("That player did not participate in that dungeon."))
		{
			string maily;
			if (contains_text(loot_name,"Hodgman's"))
			{
				lb_kmail(buyer, "You didn't get through the sewer before Hodgman was killed, so I can't send you a "+loot_name+". Refunded.", dem_orders[order_index].price);
				print("Couldn't send "+buyer+"'s "+loot_name+" because they didn't pass the sewers before Hodgman got pwned. Refund sent.","red");
			}
			else
			{
				if (loot_drop_ID[dem_orders[order_index].item_name] <= slime_end && !ordered_instruct[buyer].contains_text("copied slime"))
					ordered_instruct[buyer] += "\nFight a copied slime. (FaxBot can give you one, or you can copy a slime from another clan.)";
				else if (loot_drop_ID[dem_orders[order_index].item_name] > slime_end && loot_drop_ID[dem_orders[order_index].item_name] <= hobo_end && !ordered_instruct[buyer].contains_text("Hobopolis sewers"))
					ordered_instruct[buyer] += "\nGet through the Hobopolis sewers.";
				else if (loot_drop_ID[dem_orders[order_index].item_name] > hobo_end && !ordered_instruct[buyer].contains_text("turn in Dread"))
					ordered_instruct[buyer] += "\nSpend a turn in Dread, preferably a pencilled noncombat.";
				
				if (ordered_junk[buyer] != "")
					ordered_junk[buyer] += ", ";
				ordered_junk[buyer] += loot_name;
				ordered_ID[buyer] = buyer_id;
				dem_orders[order_index].completed = false;
			}
		}
		else if (pagey.contains_text("That player already has one of those."))
		{
			lb_kmail(buyer, "Can't send you a(n) "+loot_name+" because you have one already! Refunding your Meat.", dem_orders[order_index].price);
			print(buyer+" already has a "+loot_name+", and it's one-per-player. Sent refund.","red");
		}
		else if (!rad_logs.contains_text("distributed <b>"+loot_name.to_lower_case()+"</b> to "+buyer.to_lower_case()+" (#"+buyer_id+")"))
		{
			lb_kmail(buyer, "Loot distribution failed for unknown reason. Sending refund.", dem_orders[order_index].price);
			print("Couldn't send "+buyer+"'s "+loot_name+" for unknown reason. Refund sent.","red");
		}
		else
			print("Sent "+loot_name+" to "+buyer+".","blue");
		
		if (dem_orders[order_index].completed && lb_var("MainUser") != "" && lb_var("MainUser").to_lower_case() != my_name().to_lower_case())
		{
			if (can_transfer(order_index))
			{
				string dungname;
				if (loot_drop_ID[dem_orders[order_index].item_name] <= slime_end)
					dungname = "slime tube";
				else if (loot_drop_ID[dem_orders[order_index].item_name] > slime_end && loot_drop_ID[dem_orders[order_index].item_name] <= hobo_end)
					dungname = "hobopolis";
				else
					dungname = "dreadsylvania";
				matcher dungnum = create_matcher(dungname+":<[^>]*id:([0-9]*)",rad_logs);
				if (find(dungnum))
					dungname = " (" + dungname + " #" + group(dungnum,1) + ")";
				else
					dungname = "";
			
				lb_kmail(lb_var("MainUser"),"Payment for "+loot_name+dungname,dem_orders[order_index].price);
				print("Sent "+dem_orders[order_index].price+" Meat to "+lb_var("MainUser")+".","blue");
			}
			else
				print("Cannot send meat to "+lb_var("MainUser")+" because this account, "+get_actual_name()+", spent turns in the relevant dungeon.","red");
		}
		
		if (dem_orders[order_index].completed && lb_var("UnWhitelist").to_boolean())
			unlist_check(buyer,buyer_id);
	}
	else if (pagey.contains_text("That player did not participate in that dungeon."))
		print(buyer+" isn't in the dungeon logs; can't send "+loot_name+".","red");
	else if (pagey.contains_text("That player already has one of those."))
		print(buyer+" already has a "+loot_name+".","red");
	else
		print("Sent "+loot_name+" to "+buyer+".","blue");
}

void check_orders(string buyer)
{
	dung_ord[int] dem_scanned_orders;

	file_to_map("lootbot_orders_"+file_label()+".txt",dem_orders);
	foreach stoing in loot_taken
		loot_taken[stoing] = 0;
	
	string kmailstring;
	foreach ord in dem_orders
	{
		if ((send_me[loot_drop_ID[dem_orders[ord].item_name]] && (buyer == "!SEND!" || buyer == "!EMPTY!")) || 
		(buyer != "" && dem_orders[ord].player_name.to_lower_case() == buyer.to_lower_case()))
		{
			if (loot_dropped[dem_orders[ord].item_name] - loot_taken[dem_orders[ord].item_name] > 0)
				dist_loot(ord, dem_orders[ord].item_name, dem_orders[ord].player_name, dem_orders[ord].player_ID);
			else if (!buyer.contains_text("!"))
			{
				if (loot_dropped[dem_orders[ord].item_name] > 0)
					kmailstring += dem_orders[ord].item_name+" has dropped, but another player already bought it.\n";
				else
					kmailstring += dem_orders[ord].item_name+" has not dropped yet.\n";
			}
		}
		if (buyer != "!EMPTY!" || dem_orders[ord].completed)
			loot_taken[dem_orders[ord].item_name] += 1;
	}
	
	if (buyer == "!EMPTY!")
	{
		string to_who = lb_var("MainUser");
		string to_whid;
		if (to_who == "")
			to_who = my_name();
		
		matcher findid = create_matcher("option value=([0-9]*)>"+to_who.to_lower_case(),visit_url("clan_basement.php").to_lower_case());
		if (find(findid))
		{
			to_whid = group(findid,1);
			
			foreach it in dat_loot
			{
				if (send_me[it] && loot_dropped[dat_loot[it].item_name] - loot_taken[dat_loot[it].item_name] > 0)
					dist_loot(0, dat_loot[it].item_name, to_who, to_whid);
				loot_taken[dat_loot[it].item_name] += 1;
			}
		}
		else
			print("Couldn't find ID for "+to_who+". This player may not have participated in the dungeon.","red");
	}
	else
	{
		if (kmailstring != "")
			lb_kmail(buyer, kmailstring+"\nKmail #LOOT CANCEL to cancel these orders.",0);
			
		foreach sting in ordered_junk
		{
			string updated_rank = rank_get(ordered_instruct[sting].contains_text("slime"),ordered_instruct[sting].contains_text("Hobopolis"),ordered_instruct[sting].contains_text("Dread"));
			witlist(sting,ordered_ID[sting],true,updated_rank);
			lb_kmail(sting, "To get your loot item(s) -- "+ordered_junk[sting]+" -- you need to do the following thing(s) in the clan "+get_clan()+":\n"+ordered_instruct[sting]+"\n\nAfter that, Kmail #LOOT GET to get your stuff. (It may not be sent immediately, if the bot account isn't logged in.)", 0);
			print("Reminded "+sting+" to get in the logs for "+ordered_junk[sting]+".","blue");
		}
	}
	
	int scan_ord = 0;
	foreach ord in dem_orders
	{
		if (!dem_orders[ord].completed)
		{
			scan_ord += 1;
			dem_scanned_orders[scan_ord] = dem_orders[ord];
		}
		else
			loot_dropped[dem_orders[ord].item_name] -= 1;
	}
	
	map_to_file(dem_scanned_orders,"lootbot_orders_"+file_label()+".txt");
	file_to_map("lootbot_orders_"+file_label()+".txt",dem_orders);
}

void load_loot(boolean check_dung, string buyer)
{
	file_to_map("lootbot_set_"+file_label()+".txt",dat_loot);
	if (dat_loot[1].item_name == "")
	{
		file_to_map("lootbot_set_default.txt",dat_loot);
		map_to_file(dat_loot,"lootbot_set_"+file_label()+".txt");
	}
	for i from 1 to dread_end
		loot_drop_ID[dat_loot[i].item_name] = i;
	
	if (check_dung)
	{
		string dungy = to_lower_case(visit_url("clan_basement.php"));
		for i from 1 to dread_end
			num_drops(dungy, dat_loot[i].sub_items, dat_loot[i].item_name);
		check_orders(buyer);
	}
}

int matched_words(string s1, string s2, int aye)
{
	int cownte;
	int match_points;
	string[int] words1;
	string[int] words2;
	
	matcher wordy = create_matcher("([^\\s\\|]+)",s1);
	while (find(wordy))
	{
		cownte += 1;
		words1[cownte] = wordy.group(1);
	}
	wordy = create_matcher("([^\\s\\|]+)",s2);
	while (find(wordy))
	{
		cownte += 1;
		words2[cownte] = wordy.group(1);
	}
	
	foreach tint1 in words1
	{
		foreach tint2 in words2
		{
			if (words1[tint1].to_lower_case() == words2[tint2].to_lower_case())
				match_points += 10;
			else if (words1[tint1].to_lower_case().contains_text(words2[tint2].to_lower_case()))
				match_points += 1;
		}
	}
	
	int multi_match = 1;
	wordy = create_matcher("(\\|+)",s1);
	while (find(wordy))
		multi_match += 1;
	
	return (match_points / multi_match);
}
	

int identify_item(string gibberish, int list_ind, boolean ordering)
{
	int match_max = 0;
	int denty = 0;
	int cann;
	
	int[int] match_scores;
	
	if (length(gibberish) < 2)
		return 0;
		
	if (gibberish.contains_text("outfit"))
		gibberish = gibberish.replace_string("'s "," ");
		

	for i from 1 to dread_end
	{
		cann = can_order(i);
		if (cann >= 0)
			match_scores[i] = max(matched_words(dat_loot[i].item_name, gibberish, i),matched_words(dat_loot[i].sub_items, gibberish, i));
		if (cann >= 0 && match_scores[i] > 0 && match_scores[i] >= match_max)
		{
			if (cann == 0)
			{
				if (denty == 0 || match_max < match_scores[i])
					denty = -10 - i;  // out of stock
				else if (denty <= -10 && match_max == match_scores[i])
					denty = -1;  // duplicate, and no valid orderables yet
			}
			else
			{
				if (denty <= 0 || match_max < match_scores[i])
					denty = i;  // hooray, can haz item!
				else if (match_max == match_scores[i])
					denty = -1;  // duplicate
			}
			match_max = match_scores[i];
		}
	}
	
	if (denty > 0)
	{
		if (ordering)
			loot_taken[dat_loot[denty].item_name] += 1;
		if (cann == 2)
		{
			item_prices[list_ind] = dat_loot[denty].price - dat_loot[denty].discount;
			preorder_thing = true;
			pre_ordah[list_ind] = true;
		}
		else
		{
			item_prices[list_ind] = dat_loot[denty].price;
			pre_ordah[list_ind] = false;
			if (list_ind <= slime_end)
				slime_not_pre = true;
		}
	}
	
	return denty;
}

void print_orders()
{
	int i = 1, total_meet = 0;
	int[string] print_loot_taken;
	file_to_map("lootbot_orders_"+file_label()+".txt",dem_orders);
	string paj = visit_url("clan_raidlogs.php").to_lower_case();
	string printy;
	matcher matchy;
	
	load_loot(true,"");
	
	if (dem_orders[1].player_name == "")
		print("Nothing is currently ordered!","blue");
	else
	{
		print("Current loot orders:","blue");
		print("");
		foreach i in dem_orders
		{
			printy = i+". "+dem_orders[i].player_name+" (#"+dem_orders[i].player_ID+"), "+dem_orders[i].order_time+"<br>--- Item: "+dem_orders[i].item_name+" for "+dem_orders[i].price+" Meat<br>--- Status: ";
			if (loot_drop_ID[dem_orders[i].item_name] <= slime_end)
				matchy = create_matcher("the slime tube:<!--[^!]*?\\(#"+dem_orders[i].player_ID+"\\)",paj);
			else if (loot_drop_ID[dem_orders[i].item_name] <= hobo_end)
				matchy = create_matcher("hobopolis:<!--[^!]*?\\(#"+dem_orders[i].player_ID+"\\) made it through the sewer",paj);
			else
				matchy = create_matcher("dreadsylvania:<!--[^!]*?\\(#"+dem_orders[i].player_ID+"\\)",paj);
			if (find(matchy))
			{
				if (loot_dropped[dem_orders[i].item_name] - print_loot_taken[dem_orders[i].item_name] > 0)
					printy += "<span style='color:green;'>Ready to distribute! Use LOOTBOT SEND to send it.";
				else
					printy += "<span style='color:purple;'>Loot hasn't dropped, or is reserved. Player is in the logs.";
			}
			else
			{
				if (loot_dropped[dem_orders[i].item_name] - print_loot_taken[dem_orders[i].item_name] > 0)
					printy += "<span style='color:orange;'>Dropped, but player isn't in logs. LOOTBOT SEND will remind them.";
				else
					printy += "<span style='color:red;'>Loot hasn't dropped, or is reserved. Player is NOT in the logs.";
			}
			print_loot_taken[dem_orders[i].item_name] += 1;
				
			print_html(printy+"</span><br>");
			total_meet += dem_orders[i].price;
			i += 1;
		}
		refresh_status();
		if (my_meat() >= total_meet)
			print("Total meat: "+total_meet+" (keep at least this much in inventory!)","blue");
		else
			print("Total meat: "+total_meet+" WARNING: You don't have enough to pay all these back if they cancel!","red");
	}
}

void lootbot_send(boolean empty, string commando)
{
	for i from 1 to dread_end
		send_me[i] = (commando.replace_string("send","").replace_string("empty","").length() == 0);
	if (commando.contains_text("slime"))
		for i from 1 to slime_end
			send_me[i] = true;
	if (commando.contains_text("hobo"))
		for i from slime_end+1 to hobo_end
			send_me[i] = true;
	if (commando.contains_text("dread"))
		for i from hobo_end+1 to dread_end
			send_me[i] = true;
	
	if (empty)
		load_loot(true, "!EMPTY!");
	else
		load_loot(true, "!SEND!");
}

boolean check_witlist()
{
	if (!can_interact())
	{
		print("In Ronin/Hardcore. Can't receive Meat.","red");
		return false;
	}

	if (get_clan() == "NONE")
	{
		print("You're not in a clan!","red");
		return false;
	}
	
	string dat_witlist = visit_url("clan_whitelist.php");

	if (!contains_text(dat_witlist,"Add a player to your Clan Whitelist"))
	{
		print("You don't have whitelist permissions for this clan!","red");
		return false;
	}
	
	boolean chek_rank(string rankname)
	{
		return (lb_var(rankname) == "" || contains_text(dat_witlist,lb_var(rankname)+" (&deg;"));
	}

	if (!chek_rank("MasterRank") || !chek_rank("SlimeRank") || !chek_rank("HoboRank") || !chek_rank("DreadRank"))
	{
		print("Your dungeon rank settings are missing, invalid, or not grantable with this account. Use the settings script in the relay browser to set them.","red");
		return false;
	}
	
	return true;
}

string shorten_num(int num)
{
	if (num >= 1000000)
	{
		if ((num.to_float() / 1000000.0) == (num.to_float() / 1000000.0).to_int())
			return (num.to_float() / 1000000.0).to_int().to_string()+"M";
		else
			return (num.to_float() / 1000000.0).to_string()+"M";
	}
	else if (num >= 1000)
	{
		if ((num.to_float() / 1000.0) == (num.to_float() / 1000.0).to_int())
			return (num.to_float() / 1000.0).to_int().to_string()+"k";
		else
			return (num.to_float() / 1000.0).to_string()+"k";
	}
	else
		return num.to_string();
}

int lengthen_num(string num)
{
	if (length(num) > 1 && contains_text(to_lower_case(num), "m"))
		return (num.substring(0,(length(num)-1)).to_float() * 1000000).to_int();
	else if (length(num) > 1 && contains_text(to_lower_case(num), "k"))
		return (num.substring(0,(length(num)-1)).to_float() * 1000).to_int();
	else
		return num.to_int();
}

string loot_line(int i)
{
	int cann = can_order(i);
	
	string shrtname;
	if (loot_drop_name_shrt[dat_loot[i].item_name] != "")
		shrtname = " (" + loot_drop_name_shrt[dat_loot[i].item_name] + ") ";

	if (cann == 0 && lb_var("ShowStockless").to_boolean())
		return dat_loot[i].item_name + " (none available)";
	if (cann == 1)
		return ((loot_dropped[dat_loot[i].item_name] - loot_taken[dat_loot[i].item_name]) + " " + dat_loot[i].item_name + shrtname + " -- " + dat_loot[i].price.shorten_num() + " Meat" + ((loot_dropped[dat_loot[i].item_name] - loot_taken[dat_loot[i].item_name]>1)?" each":""));
	if (cann == 2)
	{
		preorder_thing = true;
		return dat_loot[i].limit + " [pre-order] " + ((dat_loot[i].discount > 0)?" "+dat_loot[i].discount.shorten_num()+" discount)":"") + dat_loot[i].item_name + shrtname + " -- " + (dat_loot[i].price-dat_loot[i].discount).shorten_num() + " Meat" + ((dat_loot[i].limit>1)?" each":"");
	}
	
	return "";
}

void brag_phat_loot(string buyer, boolean mailz)
{
	int maxdex = 1;
	string[int] kmailstring;

	load_loot(true, "");
	
	kmailstring[1] = "Reply with #LOOT HELP for extra explanations.\n\n--- Loot For Sale ---\n\n";
	
	void addline(string line)
	{
		if (line == "")
			return;
		if (mailz)
		{
			if (length(kmailstring[maxdex]) + length(line) >= 2000)
				maxdex += 1;
			if (length(line) > 0)
				kmailstring[maxdex] += line + "\n";
		}
		else
			print(line);
	}
	
	if (!mailz)
		addline("------------------------------");
	
	for i from 1 to slime_end
	{
		if (can_order(i) > 0)
		{
			addline("Slime Tube:");
			for j from 1 to slime_end
				addline(loot_line(j));
			if (mailz)
				kmailstring[maxdex] += "\n";
			else
				print("");
			break;
		}
	}
	
	for i from slime_end+1 to hobo_end
	{
		if (can_order(i) > 0)
		{
			addline("Hobopolis:");
			for j from slime_end+1 to hobo_end
				addline(loot_line(j));
			if (mailz)
				kmailstring[maxdex] += "\n";
			else
				print("");
			break;
		}
	}
	
	for i from hobo_end+1 to dread_end
	{
		if (can_order(i) > 0)
		{
			addline("Dreadsylvania:");
			for j from hobo_end+1 to dread_end
				addline(loot_line(j));
			if (mailz)
				kmailstring[maxdex] += "\n";
			else
				print("");
			break;
		}
	}
	
	if (mailz && buyer != "")
	{
		if (kmailstring[1].contains_text("Slime Tube") || kmailstring[1].contains_text("Hobopolis") || kmailstring[1].contains_text("Dreadsylvania"))
			addline("--- Kmail Commands ---\n#LOOT ITEM, ITEM, ... (plus meat) buys things. Can use partial item names, such as \"nodule\".\n#LOOT GET gives your ordered stuff.\n#LOOT CANCEL cancels orders.");
		else
			addline("Sorry, no loot drops are currently for sale.");
			
		for i from maxdex downto 1
			lb_kmail(buyer, kmailstring[i], 0);
	}
}

void loot_help(string buyer)
{
	string kmailstring;
	
	kmailstring += "This account is running LootBot, an automatic dungeon loot distributor.\n\n";
	
	kmailstring += "First, Kmail (message) #LOOT to "+get_actual_name()+" for a list of available items.\n\n";

	kmailstring += "To buy things, send a Kmail to "+get_actual_name()+" STARTING WITH #LOOT followed by the items you want, separated by commas. And the right amount of Meat, of course.\n\n";
	
	kmailstring += "Example: #LOOT NODULE, NODULE, SLIMELING buys 2 nodules and a slimeling (allcaps is not necessary).\n\n";
	
	kmailstring += "You'll get whitelisted into the clan so you can get yourself in the dungeon logs. Afterward, send #LOOT GET to get your loot.\n\n";
	
	kmailstring += "PRE-ORDER items have not actually dropped yet. If you buy one, you'll get it when it drops. If it doesn't drop, cancel the order (see below). This is a necessity for Hodgman's items, because you can't get in the logs after he has been killed.\n\n";
	
	kmailstring += "To cancel all orders and get your Meat back, send #LOOT CANCEL in a Kmail. You can add a list of items after #LOOT CANCEL to only cancel those items.";
	
	lb_kmail(buyer, kmailstring, 0);
}

string[int] order_list;
int parse_order_list(string commando, boolean ordering)
{
	int groupz = 0;
	
	string matchyapp = "\\s*([^,]+),+";
	
	stuffmatch = create_matcher(matchyapp, commando+",");
	while (find(stuffmatch))
	{
		groupz += 1;
		ordered_items[groupz] = identify_item(trim(group(stuffmatch,1)),groupz,ordering);
		order_list[groupz] = trim(group(stuffmatch,1));
	}
	
	return groupz;
}

boolean lootbot_order(kmessage k)
{
	boolean haz_slime;
	boolean haz_dread;
	boolean haz_hobo;
	
	load_loot(true, "");
	
	string commando = get_command(k.message);
	
	int groupz = parse_order_list(commando, true);
	int bux = k.meat;
	
	if (groupz == 0)
	{
		lb_kmail(k.fromname,"Couldn't find an item list in your message.",bux);
		print(k.fromname+" sent an apparently blank item list.","red");
		return false;
	}
	
	for i from 1 to groupz
	{
		if (ordered_items[i] == 0)
		{
			lb_kmail(k.fromname,"Couldn't find any items matching \""+order_list[i]+"\". The item you want may be not be for sale, or you might have tried to buy too many.",bux);
			print(k.fromname+" tried to order \""+order_list[i]+"\", but I don't know what that means.","red");
			return false;
		}
		else if (ordered_items[i] == -1)
		{
			lb_kmail(k.fromname,"Found multiple matches for \""+order_list[i]+"\". Need a longer description so I don't give you the wrong item!",bux);
			print(k.fromname+" tried to order \""+order_list[i]+"\", found multiple matches.","red");
			return false;
		}
		else if (ordered_items[i] < -10)
		{
			int loot_num = (-ordered_items[i]) - 10;
			lb_kmail(k.fromname,"Currently out of stock and/or pre-order slots for "+dat_loot[loot_num].item_name+".",bux);
			print(k.fromname+" tried to order "+dat_loot[loot_num].item_name+", but we're out of those.","red");
			return false;
		}
	}
	
	int need_meet = 0;
	string item_lizt;
	for i from 1 to groupz
	{
		need_meet += item_prices[i];
		item_lizt += dat_loot[ordered_items[i]].item_name + ((pre_ordah[i])?" (pre-order)":"") + ", ";
		if (ordered_items[i] <= slime_end)
			haz_slime = true;
		else if (ordered_items[i] <= hobo_end)
			haz_hobo = true;
		else
			haz_dread = true;
	}
	item_lizt = substring(item_lizt, 0, length(item_lizt)-2);
	
	if (need_meet > bux)
	{
		lb_kmail(k.fromname,"Total price of "+item_lizt+" is "+need_meet+" Meat.",bux);
		return false;
	}
	
	int base_i;
	int add_order = 1;
	file_to_map("lootbot_all_orders_"+file_label()+".txt",all_orders);
	int total_orders = all_orders[0].price;
	while (dem_orders[add_order].player_name != "")
		add_order += 1;
	for i from add_order to (add_order + groupz - 1)
	{
		base_i = ordered_items[1+i-add_order];
		dem_orders[i].price = item_prices[1+i-add_order];
		dem_orders[i].player_name = k.fromname;
		dem_orders[i].player_ID = k.fromid;
		dem_orders[i].item_name = dat_loot[base_i].item_name;
		dem_orders[i].completed = false;
		dem_orders[i].order_time = k.localtime;
		total_orders += 1;
		all_orders[total_orders] = dem_orders[i];
	}
	map_to_file(dem_orders,"lootbot_orders_"+file_label()+".txt");
	all_orders[0].price = total_orders;
	map_to_file(all_orders,"lootbot_all_orders_"+file_label()+".txt");
	
	foreach ord in dem_orders
	{
		if (dem_orders[ord].player_ID.to_int() == k.fromid)
		{
			if (loot_drop_ID[dem_orders[ord].item_name] <= slime_end)
				haz_slime = true;
			else if (loot_drop_ID[dem_orders[ord].item_name] <= hobo_end)
				haz_hobo = true;
			else if (loot_drop_ID[dem_orders[ord].item_name] <= dread_end)
				haz_dread = true;
		}
	}
	string lebul = rank_get(haz_slime, haz_hobo, haz_dread);
	witlist(k.fromname, k.fromid, true, lebul);
	string confirmy = "Order for " + item_lizt + " confirmeded!\n\nYou've been whitelisted into the clan "+get_clan()+". Make sure you have a whitelist to your current clan, if you have one, then use the chat command \"/whitelist "+get_clan()+"\" to visit the loot-selling clan. To get loot, you have to do a thing to get in the clan's dungeon logs.\n";
	if (haz_slime)
	{
		if (preorder_thing)
			confirmy += "\nFor pre-ordered Slime loot, you don't need to do anything until the stuff you bought actually drops. #LOOT GET will tell you what has dropped, if anything.";
		if (slime_not_pre)
			confirmy += "\nFor dropped Slime loot, fight a copied slime while in that clan. (FaxBot can give you one, or you can copy a slime from another clan.)";
	}
	if (haz_hobo)
		confirmy += "\nFor Hobo loot, get through the Hobopolis sewers.";
	if (haz_dread)
		confirmy += "\nFor Dread loot, spend a turn in Dread, preferably a pencilled noncombat.";
		
	
		
	confirmy += "\n\nAfter that, Kmail #LOOT GET to...get loot. To cancel, send #LOOT CANCEL.";
	
	int bakmeat;
	if (need_meet < bux)
	{
		bakmeat = (bux - need_meet);
		confirmy += "\n\nBy the way, you sent too much Meat! Here's some disgusting, fleshy change.";
	}
	
	lb_kmail(k.fromname,confirmy,bakmeat);
	print(k.fromname+" ordered "+item_lizt+" ("+need_meet+" Meat).","blue");
	return true;
}

void lootbot_consume()
{
	load_loot(false, "");
	
	string to_who = lb_var("MainUser");
	string to_whid;
	if (to_who == "")
		to_who = my_name();
	
	matcher findid = create_matcher("option value=([0-9]*)>"+to_who.to_lower_case(),visit_url("clan_basement.php").to_lower_case());
	if (find(findid))
	{
		to_whid = group(findid,1);
		
		matcher con_match = create_matcher("<b>([^<]*)<.*?whichloot value=([0-9]*)",visit_url("clan_basement.php"));
		
		while(find(con_match))
		{
			item dist_this = group(con_match,1).to_item();
			if (dist_this != $item[none] && dist_this.is_tradeable())
				dist_loot(0, group(con_match,1), to_who, to_whid);
		}
	}
	else
		print("Couldn't find ID for "+to_who+". This player may not have participated in the dungeon.","red");
}

void lootbot_cancel(string buyer, string commando)
{
	load_loot(false, "");

	dung_ord[int] dem_scanned_orders;
	file_to_map("lootbot_orders_"+file_label()+".txt",dem_orders);
	
	commando = commando.to_lower_case().replace_string("cancel","").trim();
	int groupz = parse_order_list(commando, false);
	boolean cancelme(string ahtem)
	{
		for i from 1 to groupz
		{
			if (dat_loot[ordered_items[i]].item_name.to_lower_case() == ahtem.to_lower_case())
			{
				ordered_items[i] = 0;
				return true;
			}
		}
		return false;
	}
	
	int scan_ord = 0;
	foreach ord in dem_orders
	{
		if ((buyer == "" || dem_orders[ord].player_name.to_lower_case() == buyer.to_lower_case()) &&
		(commando == "" || commando == "all" || cancelme(dem_orders[ord].item_name)))
		{
			dem_orders[ord].completed = true;
			lb_kmail(dem_orders[ord].player_name,"Your order for "+dem_orders[ord].item_name+" has been cancelled"+((buyer=="")?" by the seller. That item may not have dropped this time.":"."),dem_orders[ord].price);
			print(dem_orders[ord].item_name+" order cancelled and refunded.", "blue");
			if (lb_var("UnWhitelist").to_boolean())
				unlist_check(dem_orders[ord].player_name,dem_orders[ord].player_ID);
		}
		else
		{
			scan_ord += 1;
			dem_scanned_orders[scan_ord] = dem_orders[ord];
		}
	}
	
	map_to_file(dem_scanned_orders,"lootbot_orders_"+file_label()+".txt");
	file_to_map("lootbot_orders_"+file_label()+".txt",dem_orders);
}

boolean is_blakd(kmessage k)
{
	string[int] blak;
	file_to_map("lootbot_blacklist.txt",blak);
	for i from 1 to blak[0].to_int()
	{
		if (k.fromname.to_lower_case() == blak[i].to_lower_case())
		{
			lb_kmail(k.fromname, "You're blacklisted from this player's LootBot.", k.meat);
			return true;
		}
	}
	return false;
}

boolean starts_with(string lookin, string findin)
{
	return (length(findin) > 0 && length(lookin) >= length(findin) && substring(lookin,0,length(findin)) == findin);
}

string meatless_messages;
boolean lootbot_mail(kmessage k)
{
	string mess = trim(to_lower_case(k.message));
	
	string nao = k.localtime + " -- ";

	if (starts_with(mess,"#loot") || starts_with(mess,"lootbot") || 
	(k.fromname.to_lower_case() != my_name().to_lower_case() && contains_text(mess,"#loot") && 
	!contains_text(mess,"reply with #loot help") && !contains_text(mess,"this account is running lootbot") && !contains_text(mess,"after that, kmail #loot get")))  // try to prevent infinite kmail loops between bots
	{
		print(nao+"Loot Kmail from "+k.fromname+": "+k.message+" [Meat: "+k.meat+"]","green");
	
		foreach thing in k.items
		{
			print("Returned the message because it had items in it.","blue");
			kmail(k.fromname, "Your puny, insignificant tradeable items are of no use to LootBot.", k.meat, k.items);
			if (k.meat > 0)
				refresh_status();
			return true;
		}
		
		// prevent responding to multiple #loots, helps, etc. from the same person in one go
		if (k.meat == 0)
		{
			string meat_mess = (k.fromname + mess + "|||||");
			if (meatless_messages.contains_text(meat_mess))
				return true;
			meatless_messages += meat_mess;
		}
		
		if (!get_property("lootBotEnabled_"+usr_nayme()).to_boolean() || !check_witlist())
			lb_kmail(k.fromname, "This player's LootBot isn't running right now.", k.meat);
		else
		{
			if (is_blakd(k))
				return true;
				
			//player_rank(to_lower_case(visit_url("clan_members.php")), to_lower_case(visit_url("clan_whitelist.php")), playernum);
			
			string mando = get_command(mess);
			
			if (k.meat > 0)
				lootbot_order(k);
			else if (mando == "loot")
				brag_phat_loot(k.fromname, true);
			else if (mando.starts_with("help"))
				loot_help(k.fromname);
			else if (mando.starts_with("get"))
				load_loot(true, k.fromname);
			else if (length(mando) >= 6 && substring(mando,0,6) == "cancel")
				lootbot_cancel(k.fromname,mando);
			else
				lootbot_order(k);
		}
		return true;
	}
	
	return false;
}

void main(string commando)
{
	commando = commando.to_lower_case();
	
	if (commando == "unlock")
	{
		lootbot_unlock();
		return;
	}
		
	if (in_combat())
		abort("Can't do loot stuff while in combat!");
	
	if (!check_witlist() || commando == "off" || commando == "disable")
	{
		set_property("lootBotEnabled_"+usr_nayme(),"false");
		abort("LootBot is now OFF.");
	}
	
	if (!get_property("lootBotEnabled_"+usr_nayme()).to_boolean() || get_property("chatbotScript") != "scripts\\lootbot\\lootbot_chat.ash")
	{
		set_property("chatbotScript","scripts\\lootbot\\lootbot_chat.ash");
		set_property("lootBotEnabled_"+usr_nayme(),"true");
		print("LootBot is now ON.","blue");
	}
	
	lootbot_lock();
	
	process_kmail("lootbot_mail");
		
	if (commando != "on" && commando != "enable")
	{
		if (commando.starts_with("blacklist"))
			blaklist(trim(replace_string(commando, "blacklist", "")));
		else if (commando.starts_with("orders"))
			print_orders();
		else if (commando.starts_with("send"))
			lootbot_send(false,commando);
		else if (commando.starts_with("empty"))
			lootbot_send(true,commando);
		else if (commando.starts_with("consume"))
			lootbot_consume();
		else if (commando.starts_with("cancel"))
			lootbot_cancel("","#loot "+commando);
		else if (commando.starts_with("loot") || commando == "")
			brag_phat_loot("",false);
		else
			print("Unrecognized command.","red");
	}
	
	lootbot_unlock();
}