Vim�UnDo� e'�d1N��8_^�<E,wj���o��od��غrx   <   <    async def response_parse(self, message, chosen_factoid):      
                       Z �a    _�                             ����                                                                                                                                                                                                                                                                                                                                                             Z �G     �                   �               5�_�                    %   
    ����                                                                                                                                                                                                                                                                                                                                                             Z �M     �   $   &   <      A    async def madlibword(self, message, stringIn, reg_match_obj):5�_�                       !    ����                                                                                                                                                                                                                                                                                                                                                             Z �S     �          <      J                new_word = await self.madlibword(message, word, match_obj)5�_�                       
    ����                                                                                                                                                                                                                                                                                                                                                             Z �Z     �         <      <    async def response_parse(self, message, chosen_factoid):5�_�                             ����                                                                                                                                                                                                                                                                                                                                      <          V       Z �`    �              ;   6    def response_parse(self, message, chosen_factoid):           """   7            takes a chosen factoid and runs through any   9            keywords in that factoid, returns the reponse   3            plaintext to the check factoid function           """           # simple functions            simple_funcs = {   7            "$digit": lambda x: random.randrange(0, 9),   9            "$nonzero": lambda x: random.randrange(1, 9),   5            "$someone": lambda x: random.choice(list(   +                x.server.members)).mention,   G            "$item": lambda x: random.choice(self.miscdata["pockets"]),   =            "$who": lambda x: x.author.nick or x.author.name,   9            "$swearjar": lambda x: self.add_to_swearjar()   	        }   4        response_txt = chosen_factoid[0]["response"]   %        match_obj = chosen_factoid[1]   (        split_txt = response_txt.split()           split_response = []           for word in split_txt:   A            # dealing with the corner case of italicized messages   %            if word.startswith("*$"):                   word = word[1:]   9                if word[-1] in ["!", ".", ",", "?", ";"]:   %                    word = word[0:-1]   $            if word in simple_funcs:   6                new_word = simple_funcs[word](message)               else:   D                new_word = self.madlibword(message, word, match_obj)   $            if new_word is not None:   /                split_response.append(new_word)       '        return " ".join(split_response)       ;    def madlibword(self, message, stringIn, reg_match_obj):               """   O        looks for madlib categories associated with the supplied word and swaps           them out as necessary           """   $        # showerthoughts from reddit   +        if stringIn.startswith("$thought"):   /            await self.silence_fillers(message)               return None   !        # wildcard group matching   %        if stringIn.startswith("$["):   *            if not stringIn.endswith("]"):   1                word_end = stringIn.split("]")[1]               else:                   word_end = ""   *            match_index = int(stringIn[2])   >            return reg_match_obj.group(match_index) + word_end           # madlib categories   (        for k, v in self.madlib.items():   &            if stringIn.startswith(k):   '                return random.choice(v)           else:               return stringIn5��