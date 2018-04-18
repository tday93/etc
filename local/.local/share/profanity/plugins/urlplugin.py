import prof
from pyshorteners import Shortener
import re

api_key ='AIzaSyCjapLgodt16qylqSLCZZgg1MTFnfOERkY'
shortener = Shortener('Google', api_key=api_key)
_links = {}

def _cmd_test(arg1 = None, arg2 = None):
    prof.cons_show(arg1)
    prof.cons_show("does this work")
    prof.chat_show("eduplant@tyrr.net", "does this work")


def _process_message(barejid, current_jid, message):
    links = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', message)
    if( len(links) > 0):
        for link in links:
            shorturl = shortener.short(link)
            new_mess ="(Shortened Link) " + shorturl 
            prof.chat_show(barejid, new_mess)



def prof_post_chat_message_display(barejid, nick, message):
    current_jid = prof.get_current_recipient()
    _process_message(barejid, current_jid, message)
   



def prof_init(version, status, account_name, fulljid):
    prof.cons_show("loaded a-hole");
    synopsis = [ "/urlshort test", "wat"]
    args = [["test", "Wat"]]
    description = "Shorten URls, ideally"
    examples = []
    prof.register_command("/urls", 0, 2, synopsis, description, args, examples, _cmd_test)
    prof.cons_show("should be registered")
