Vim�UnDo� �ħ��R�Y��H�ǂ���|5�9�+T�6�   "   !    with open("test.json") as fn:                                 Yg�    _�                             ����                                                                                                                                                                                                                                                                                                                                                             Yg�     �                   5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Yg��     �                   5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Yg�p    �                  5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Yg��     �                           �             5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg��     �                "    def generate(self, rule_name):           genned_text = []   *        for item in self.rules[rule_name]:   '            if item is instanceof(str):   (                genned_text.append(item)5�_�                            ����                                                                                                                                                                                                                                                                                                                                                V       Yg�      �                5�_�                       #    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�G     �               #        if item is instanceof(str):5�_�      	                     ����                                                                                                                                                                                                                                                                                                                                                V       Yg�     �                       �                   def flatten(self, item):    �               !        if isinstance(item, str):    �                           return item    �               "        if isinstance(item, list):    �                           return 5�_�      
           	          ����                                                                                                                                                                                                                                                                                                                                                V       Yg��     �   
                 �                    5�_�   	              
           ����                                                                                                                                                                                                                                                                                                                                                V       Yg��     �                5�_�   
                        ����                                                                                                                                                                                                                                                                                                                                                V       Yg��     �                   def flatten(self, rule):5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg��     �                       �             5�_�                       
    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�6     �                       for5�_�                       (    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�Q     �               (        for k,v in self.rules[rule_name]5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg�     �                               �             5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg�     �                 �              5�_�                       #    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�    �               #                genned_text.append(5�_�                       !    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�    �                 !    print(g.generate("full_name")5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg�     �                 "    print(g.generate("full_name"))5�_�                       #    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�)    �               $                for item in pattern:5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg�/    �               1        for k,v in self.rules[rule_name].items():5�_�                            ����                                                                                                                                                                                                                                                                                                                                                V       Yg�3    �                 5�_�                            ����                                                                                                                                                                                                                                                                                                                                                V       Yg�6    �      
       5�_�                            ����                                                                                                                                                                                                                                                                                                                                                V       Yg�;   	 �                 5�_�                           ����                                                                                                                                                                                                                                                                                                                                                V       Yg�T     �                       return genned_text5�_�                       #    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�]   
 �               #        return " ".join(genned_text5�_�                       #    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�)     �                               �             5�_�                       -    ����                                                                                                                                                                                                                                                                                                                                                V       Yg�9    �               -                genned_text.append(choice(v))5�_�                       *    ����                                                                                                                                                                                                                                                                                                                               *          0       V   0    Yg��     �         "      +                if selection in self.rules:5�_�                       =    ����                                                                                                                                                                                                                                                                                                                               *          0       V   0    Yg��    �         "      ?                    genned_text.append(self.flatten(selection))5�_�                            ����                                                                                                                                                                                                                                                                                                                               *          0       V   0    Yg��    �         "      ?                genned_text.append(self.flatten(selection[1:]))5�_�                             ����                                                                                                                                                                                                                                                                                                                               *          0       V   0    Yg�    �          "      !    with open("test.json") as fn:5��