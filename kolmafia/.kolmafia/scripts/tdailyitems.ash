
void td_items(){
	// daily items to use 
	string [int] items;
	items[0] = "chroner cross";
	items[1] = "cheap toaster";
	items[2] = "festive warbear bank";
	items[3] = "Trivial Avocations";
	
	foreach i in items{
	string v = items[i];
	use(1, v);
	}
}


void td_skills(){
	string [int] skills;
	skills[0] = "Advanced Cocktailcrafting";
	skills[1] = "Pastamastery";
	skills[2] = "Advanced Saucecrafting";
	
	foreach s in skills{
	string v = skills[s];
	use_skill( 1, to_skill(v));
	}
}	

void main(){
	td_items();
	td_skills();
}
