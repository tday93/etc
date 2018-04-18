string stringAddSpacersEvery(string s, int distance)
{
	buffer out;
	//easiest no-effort implementation, which isn't particularly efficient:
	for i from 0 to s.length() - 1
	{
		if ((i + 1) % distance == 0)
			out.append("\n");
		out.append(s.char_at(i));
	}
	
	return out.to_string();
}

void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

string listJoinComponents(string [int] list, string joining_string, string and_string)
{
	buffer result;
	boolean first = true;
	int number_seen = 0;
	foreach i, value in list
	{
		if (first)
		{
			result.append(value);
			first = false;
		}
		else
		{
			if (!(list.count() == 2 && and_string != ""))
				result.append(joining_string);
			if (and_string != "" && number_seen == list.count() - 1)
			{
				result.append(" ");
				result.append(and_string);
				result.append(" ");
			}
			result.append(value);
		}
		number_seen = number_seen + 1;
	}
	return result.to_string();
}

int to_int_silent(string value)
{
	if (is_integer(value))
        return to_int(value);
	return 0;
}