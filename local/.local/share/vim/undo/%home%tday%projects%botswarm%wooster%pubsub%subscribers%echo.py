Vim�UnDo� M�z�����_Y�N�0����%��?�ྣG      (from pubsub.subscriber import Subscriber                             Z��j    _�                            ����                                                                                                                                                                                                                                                                                                                                                             Z�G�     �         	      class Debug(Subscriber):5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             Z�H     �         	              super().__init__(name):5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             Z�H     �      
   
              �      
   	    5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             Z�H�     �         
          def __init__(self, name):5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             Z�H�    �         
              super().__init__(name)5�_�                    	       ����                                                                                                                                                                                                                                                                                                                                                             Z�H�     �      
   
              �   	   
   
    5�_�                    	   	    ����                                                                                                                                                                                                                                                                                                                                                             Z�H�     �      
   
          def update(self, message):    �      
   
      	         5�_�      	              	       ����                                                                                                                                                                                                                                                                                                                                                             Z�H�     �         
              pass5�_�      
           	   
       ����                                                                                                                                                                                                                                                                                                                                                             Z�H�     �   	                    self.owner.5�_�   	              
          ����                                                                                                                                                                                                                                                                                                                                                             Z�H�     �      	             def update(self, message):5�_�   
                 
   +    ����                                                                                                                                                                                                                                                                                                                                                             Z�I
     �   	            +        self.owner.client.safe_send_message5�_�                    
   ,    ����                                                                                                                                                                                                                                                                                                                                                             Z�I     �   	            ,        self.owner.client.safe_send_messageg5�_�                    
       ����                                                                                                                                                                                                                                                                                                                                                             Z�I"    �   	            A        self.owner.client.safe_send_message(message.channel, msg)5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Z�I&    �   
              5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Z�I*    �         
    5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Z��S    �                         �               5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Z��     �                         �               5�_�                       *    ����                                                                                                                                                                                                                                                                                                                                                             Z���   	 �               +        if "simon says" in message.content:5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             Z��B   
 �                           return 55�_�                           ����                                                                                                                                                                                                                                                                                                                                                             Z��E    �                (from pubsub.subscriber import Subscriber5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             Z��i    �                from pubsub import Subscriber5��