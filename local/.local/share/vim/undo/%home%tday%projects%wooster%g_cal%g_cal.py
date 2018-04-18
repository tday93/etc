Vim�UnDo� �Ã;6b�׈���C4ZSS���_�o��#�r   I                 *       *   *   *    Z�    _�                             ����                                                                                                                                                                                                                                                                                                                                                             Z�     �         N       5�_�                            ����                                                                                                                                                                                                                                                                                                                                      M          V       Z�      �      N   Q   3   def get_credentials():   0    """Gets valid user credentials from storage.       I    If nothing has been stored, or if the stored credentials are invalid,   ?    the OAuth2 flow is completed to obtain the new credentials.           Returns:   -        Credentials, the obtained credential.       """   &    home_dir = os.path.expanduser('~')   ;    credential_dir = os.path.join(home_dir, '.credentials')   *    if not os.path.exists(credential_dir):   #        os.makedirs(credential_dir)   2    credential_path = os.path.join(credential_dir,   E                                   'calendar-python-quickstart.json')       $    store = Storage(credential_path)       credentials = store.get()   .    if not credentials or credentials.invalid:   I        flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)   *        flow.user_agent = APPLICATION_NAME           if flags:   <            credentials = tools.run_flow(flow, store, flags)   >        else:  # Needed only for compatibility with Python 2.6   0            credentials = tools.run(flow, store)   :        print('Storing credentials to ' + credential_path)       return credentials           def main():   4    """Shows basic usage of the Google Calendar API.       O    Creates a Google Calendar API service object and outputs a list of the next   %    10 events on the user's calendar.       """   #    credentials = get_credentials()   1    http = credentials.authorize(httplib2.Http())   :    service = discovery.build('calendar', 'v3', http=http)       O    now = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' indicates UTC time   +    print('Getting the upcoming 10 events')   )    eventsResult = service.events().list(   L        calendarId='primary', timeMin=now, maxResults=10, singleEvents=True,   &        orderBy='startTime').execute()   *    events = eventsResult.get('items', [])           if not events:   *        print('No upcoming events found.')       for event in events:   J        start = event['start'].get('dateTime', event['start'].get('date'))   &        print(start, event['summary'])5�_�                            ����                                                                                                                                                                                                                                                                                                                                      M          V       Z�'    �         Q    5�_�                           ����                                                                                                                                                                                                                                                                                                                                      N          V       Z�/     �         R          def get_credentials():5�_�                    9       ����                                                                                                                                                                                                                                                                                                                                      N          V       Z�4    �   8   :   R          def main():5�_�                           ����                                                                                                                                                                                                                                                                                                                                      N          V       Z�9    �         S              �         R    5�_�                    @       ����                                                                                                                                                                                                                                                                                                                                      O          V       Z�C    �   ?   A   S      '        credentials = get_credentials()5�_�      	              9        ����                                                                                                                                                                                                                                                                                                                                      O          V       Z�J    �   8   9           5�_�      
           	   <   C    ����                                                                                                                                                                                                                                                                                                                                      N          V       Z�R    �   ;   >   R      S        Creates a Google Calendar API service object and outputs a list of the next5�_�   	              
   Q        ����                                                                                                                                                                                                                                                                                                                            Q           S          V       Z�h     �   P   Q              if __name__ == '__main__':   
    main()5�_�   
                 P        ����                                                                                                                                                                                                                                                                                                                            Q           Q          V       Z�i    �   O   P           5�_�                    9       ����                                                                                                                                                                                                                                                                                                                            P           P          V       Z�m    �   8   :   O          def main(self):5�_�                    D   ;    ����                                                                                                                                                                                                                                                                                                                            P           P          V       Z�{   	 �   C   E   O      S        now = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' indicates UTC time5�_�                    D   <    ����                                                                                                                                                                                                                                                                                                                            P           P          V       Z�     �   C   E   O      T        now = datetime.datetime.utcnow().isoformat() + 'Z'  # 'Z' indicates UTC time5�_�                    C        ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǀ     �   B   D   O       �   C   D   O    5�_�                    C        ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǂ     �   B   D   O      # 'Z' indicates UTC time5�_�                    C       ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǃ   
 �   B   D   O          # 'Z' indicates UTC time5�_�                    D   ;    ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǈ    �   C   E   O      <        now = datetime.datetime.utcnow().isoformat() + 'Z'  5�_�                    G   >    ����                                                                                                                                                                                                                                                                                                                            P           P          V       ZǍ    �   F   I   O      P            calendarId='primary', timeMin=now, maxResults=10, singleEvents=True,5�_�                    I       ����                                                                                                                                                                                                                                                                                                                            Q           Q          V       Zǐ    �   G   I   P                  singleEvents=True,   orderBy='startTime').execute()�   H   J   P      *            orderBy='startTime').execute()5�_�                    D   :    ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǖ    �   C   E   O      ;        now = datetime.datetime.utcnow().isoformat() + 'Z' 5�_�                    H       ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǜ    �   G   I   O      <            singleEvents=True,orderBy='startTime').execute()5�_�                    @       ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǣ     �   ?   @          ,        credentials = self.get_credentials()5�_�                           ����                                                                                                                                                                                                                                                                                                                            O           O          V       ZǦ     �         N    �         N    5�_�                           ����                                                                                                                                                                                                                                                                                                                            P           P          V       ZǪ     �         O      ,        credentials = self.get_credentials()5�_�                           ����                                                                                                                                                                                                                                                                                                                            P           P          V       Zǭ     �                        pass5�_�                    @        ����                                                                                                                                                                                                                                                                                                                            @   4       A   >       V   ?    Z�!     �   ?   @          5        http = credentials.authorize(httplib2.Http())   >        service = discovery.build('calendar', 'v3', http=http)5�_�                           ����                                                                                                                                                                                                                                                                                                                            @   4       @   >       V   ?    Z�$     �         L    �         L    5�_�                           ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    Z�(     �         N      5        http = credentials.authorize(httplib2.Http())5�_�                           ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    Z�+     �         N      >        service = discovery.build('calendar', 'v3', http=http)5�_�                        >    ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    Z�/     �         N      C        self.service = discovery.build('calendar', 'v3', http=http)5�_�      !               E       ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    Z�b    �   D   F   N      -        eventsResult = service.events().list(5�_�       "           !          ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    Z�o    �         N      :        self.http = credentials.authorize(httplib2.Http())5�_�   !   #           "   ;       ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    ZȠ     �   :   <   N          def list_10(self):5�_�   "   $           #   ;       ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    ZȬ    �   :   <   N          def get_events(self):5�_�   #   %           $   D       ����                                                                                                                                                                                                                                                                                                                            B   4       B   >       V   ?    Zȸ     �   C   D          /        print('Getting the upcoming 10 events')5�_�   $   &           %   G       ����                                                                                                                                                                                                                                                                                                                            I          I          V       Z��     �   G   I   N              �   G   I   M    5�_�   %   '           &   G       ����                                                                                                                                                                                                                                                                                                                            J          J          V       Z��     �   G   I   N    5�_�   &   (           '   G       ����                                                                                                                                                                                                                                                                                                                            K          K          V       Z��     �   G   I   P              �   G   I   O    5�_�   '   )           (   J        ����                                                                                                                                                                                                                                                                                                                            J           P           V        Z�     �   I   J                                 if not events:   .            print('No upcoming events found.')           for event in events:   N            start = event['start'].get('dateTime', event['start'].get('date'))   *            print(start, event['summary'])5�_�   (   *           )   H        ����                                                                                                                                                                                                                                                                                                                            J           J           V        Z�    �   H   J   J              �   H   J   I    5�_�   )               *   J        ����                                                                                                                                                                                                                                                                                                                            K           K           V        Z�    �   I   J           5��