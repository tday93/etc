/* 
Thanks go to icon315 for making the original version of this script.
Thanks also go to Bale for helping with debugging.
*/

script "PandamoniumQuest.ash";
notify wrldwzrd89;

boolean adv(location i) {
   if(my_adventures() < 1)
   {
      print("NO MORE ADVENTURES!","red");
      abort();
   }
   return adventure(1, i);
}

record musician {
   item item1;
   item item2;
   boolean isdone;
};

musician [string] gollyMap;

gollyMap["Bognort"].item1 = $item[giant marshmallow]; 
gollyMap["Bognort"].item2 = $item[gin-soaked blotter paper]; 
gollyMap["Bognort"].isdone = false; 

gollyMap["Stinkface"].item1 = $item[gin-soaked blotter paper]; 
gollyMap["Stinkface"].item2 = $item[beer-scented teddy bear]; 
gollyMap["Stinkface"].isdone = false; 

gollyMap["Flargwurm"].item1 = $item[booze-soaked cherry]; 
gollyMap["Flargwurm"].item2 = $item[sponge cake]; 
gollyMap["Flargwurm"].isdone = false; 

gollyMap["Jim"].item1 = $item[sponge cake]; 
gollyMap["Jim"].item2 = $item[comfy pillow]; 
gollyMap["Jim"].isdone = false; 

int numItem(item it) {
   return item_amount(it) + closet_amount(it);
}

boolean haveItem(item it) {
   return numItem(it) > 0;
}

boolean gollyDone() {
   int [item] trade;
   foreach it in $items[giant marshmallow,gin-soaked blotter paper,beer-scented teddy bear,booze-soaked cherry,sponge cake,comfy pillow]
      trade[it] = numItem(it);
      
   boolean good = true;
   foreach name,mate in gollyMap{
      if(!mate.isdone) {
         if(trade[mate.item1] > 0) trade[mate.item1] -= 1;
         else if(trade[mate.item2] > 0) trade[mate.item2] -= 1;
         else good = false;
      }
   }
   return good;
}

void giveToGolly(item i, string who){
   print("Giving " + i + " to " + who, "blue");
   if(item_amount(i) > 0 || take_closet(1, i)) {
      visit_url("pandamonium.php?action=sven&bandmember=" + who + "&togive=" + to_int(i) + "&preaction=try");
      gollyMap[who].isdone = true;
   }
}

void arena() {
   // Find out what bandmembers were previously completed
   string sven = visit_url("pandamonium.php?action=sven");
   // If this was the first visit to sven, he needs to be checked again
   if(sven.contains_text("value=\"help\""))
      sven = visit_url("pandamonium.php?action=sven");
   if(!sven.contains_text("You should probably go talk to the some of the band")) {
      foreach name in gollyMap
         if(!contains_text(sven, "<option>"+name))
             gollyMap[name].isdone = true;
   }
   
   print("Trying to get stuff for musicians", "blue");
   
   // Instead of doing this, we can do better
   //cli_execute("maximize item -tie");
   //cli_execute("maximize -combat -tie");
   // Prefer noncombat over item drops, and prefer weapons that help us hit
   cli_execute("maximize -combat -tie, item effective");
   while (!gollyDone()) {
      adv($location[Infernal Rackets Backstage]);
   }
   foreach name, mate in gollyMap {
      if(!mate.isdone) {
         if(haveItem(mate.item1))
            giveToGolly(mate.item1, name);
         else if(haveItem(mate.item2))
            giveToGolly(mate.item2, name);
      }
   }
   print("Arena done", "blue");
}

if (!contains_text(visit_url("questlog.php?which=2"),", this is Azazel in Hell."))
{

	print("Starting the Quest", "blue");
	cli_execute("condition clear");
	visit_url("pandamonium.php");
	if (item_amount($item[Azazel's unicorn]) == 0)
	{
		arena();
	}
	
	if (item_amount($item[Azazel's lollipop]) == 0)
	{
		
		if (!have_equipped($item[Observational glasses]))
		{
			print("Retrieving Observational glasses", "blue");
			while(item_amount($item[Observational glasses]) == 0)
			{
				adv($location[The Laugh Floor]);
			}
			print("Glasses Retrieved", "green");
			if (item_amount($item[Observational glasses]) > 0)
			{
				cli_execute("checkpoint");
				print("Using observational humor...What's the deal with this script?", "blue");
				equip($slot[acc3], $item[Observational glasses]);
				visit_url("pandamonium.php?action=mourn&preaction=observe");
				outfit("checkpoint");
			}
		}
		else
		{
			print("Already have the glasses equipped", "green");
			print("Using observational humor...What's the deal with this script?", "blue");
			visit_url("pandamonium.php?action=mourn&preaction=observe");
		}
	}

	if(item_amount($item[Azazel's tutu]) == 0)
	{
		print("Retrieving Cans Imp Air", "blue");
		while(item_amount($item[imp air]) < 5)
		{
			adv($location[The Laugh Floor]);
		}
		print("Getting the bus passes", "blue");
		while(item_amount($item[bus pass]) < 5)
		{
			adv($location[Infernal Rackets Backstage]);
		}
		
		print("All items gathered", "green");
		while(item_amount($item[imp air]) >= 5 && item_amount($item[bus pass]) >= 5)
		{
			print("Taking items to the Moaning Panda Square", "blue");
			visit_url("pandamonium.php?action=moan");
		}
	}
	
	if( item_amount($item[Azazel's unicorn]) > 0 && item_amount($item[Azazel's lollipop]) > 0 && item_amount($item[Azazel's tutu]) > 0)
		visit_url("pandamonium.php?action=temp");
}
print("Quest done!", "green");
