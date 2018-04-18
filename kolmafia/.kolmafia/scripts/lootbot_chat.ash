// Chatbot script for lootbot.ash.
//
// Kmail commands:
// "#loot" to get a list of available loot.
// "#loot help" for instructions.
// "#loot [item], [item], [item],..." (plus meat) to order items. If you send this with no meat, it will tell you the total price.
// "#loot get" to receive loot, after getting in the dungeon logs.
// "#loot cancel" to cancel all orders for refunds. 
//
// "lootbot" can be substituted for "#loot", but this may cause confusion since there's an account with that name. 

import <lootbot.ash>

void main(string sender, string message, string channel)
{
	string mess = to_lower_case(message);
	
	string nao = now_to_string("MM/dd/yy KK:mm:ss a") + " -- ";
	
	if (contains_text(message,"New message received from"))
	{
		lootbot_lock();
		combat_wait();
		process_kmail("lootbot_mail");
	}
	else if (channel == "" && (mess == "#loot" || mess == "lootbot"))
	{
		lootbot_lock();
		combat_wait();
		print(nao+"Loot-list PM from "+sender,"green");
		brag_phat_loot(sender, true);
	}
	else if (channel == "" && (mess == "#loot help" || mess == "lootbot help"))
	{
		lootbot_lock();
		combat_wait();
		print(nao+"Loot-help PM from "+sender,"green");
		loot_help(sender);
	}
	else if (sender == "" && contains_text(message,"The system will go down for nightly maintenance in 1 minute."))
	{
		lootbot_lock();
		lootbot_unlock();
		string usr = my_name();
		cli_execute("logout");
		waitq(900);
		cli_execute("login "+usr);
	}
	
	lootbot_unlock();
}