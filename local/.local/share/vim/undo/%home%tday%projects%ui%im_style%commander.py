VimUnDoĺ q|ó*ęÓľ_ę$N=c7}Ţ=ăq¨gś@ÔM   Á                 <       <   <   <    YAh    _Đ                    Ą       ˙˙˙˙                                                                                                                                                                                                                                                                                                                            6                      V        YA~     ő       ˘   ß                  except Exception,e:5_Đ                    Ň        ˙˙˙˙                                                                                                                                                                                                                                                                                                                            Ň           ×           V        YA~Ń     ő   Ń   Ň          =    #Test asynch output -  e.g. comming from different thread       import time       def run():           while True:               time.sleep(1)   %            c.output('Tick', 'green')5_Đ      	              É        ˙˙˙˙                                                                                                                                                                                                                                                                                                                            É          Î          V       YA~ă     ő   Č   É              class TestCmd(Command):   !        def do_echo(self, *args):   1            '''echo - Just echos all arguments'''   !            return ' '.join(args)   "        def do_raise(self, *args):   )            raise Exception('Some Error')5_Đ      
           	   Ę   (    ˙˙˙˙                                                                                                                                                                                                                                                                                                                            É          É          V       YA~ć     ő   É   Ë   Ó      )    c=Commander('Test', cmd_cb=TestCmd())5_Đ   	              
   Ę       ˙˙˙˙                                                                                                                                                                                                                                                                                                                            É          É          V       YA~é    ő   É   Ë   Ó          c=Commander('Test')5_Đ   
                 Š   )    ˙˙˙˙                                                                                                                                                                                                                                                                                                                            É          É          V       YA    ő   ¨   Ş   Ó      +            if line in ('q','quit','exit'):5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                                      Ź   !       V   !    YA2     ő                        if self._cmd:               try:   %                res = self._cmd(line)   "            except Exception as e:   3                self.output('Error: %s'%e, 'error')                   return   #            if res==Commander.Exit:   *                raise urwid.ExitMainLoop()               elif res:   %                self.output(str(res))           else:   $            if line in ('q','quit'):   *                raise urwid.ExitMainLoop()               else:   !                self.output(line)5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                                         !       V   !    YA4     ő         Ä      #    def on_line_entered(self,line):    ő         Ä          5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAQ    ő         Ĺ              ő         Ä    5_Đ                       0    ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA^     ő         Ć      1        """ what do do when a line is entered """    ő          Ć              ő          Ĺ    5_Đ                       0    ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAc   	 ő          Ć              ő          Ĺ    5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAm   
 ő         Ć      #    def on_line_entered(self,line):5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAq     ő                        5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAs    ő         Ć              ő         Ĺ    5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć      	         5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć              5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć             5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć            5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć           5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć          5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć         5_Đ                           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć        5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć       5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć       5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć       5_Đ                             ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx     ő         Ć       5_Đ      !                       ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAx    ő         Ć       5_Đ       "           !           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA     ő         Ć              5_Đ   !   #           "      "    ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA     ő         Ć      #        urwid.Frame.__init__(self, 5_Đ   "   $           #           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA     ő         Ć          5_Đ   #   %           $           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA    ő         Ć          5_Đ   $   &           %   }        ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA    ő   |   ~   Ć          5_Đ   %   '           &   ~       ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA     ő   }      Ć      9    PALLETE=[('reversed', urwid.BLACK, urwid.LIGHT_GRAY),5_Đ   &   (           '   ~       ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA    ő   }      Ć      :    PALLETE =[('reversed', urwid.BLACK, urwid.LIGHT_GRAY),5_Đ   '   )           (          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAĄ     ő   ~      Ć      8              ('normal', urwid.LIGHT_GRAY, urwid.BLACK),5_Đ   (   *           )          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA¤     ő         Ć      6              ('error', urwid.LIGHT_RED, urwid.BLACK),5_Đ   )   +           *          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA¨     ő         Ć      7              ('green', urwid.DARK_GREEN, urwid.BLACK),5_Đ   *   ,           +          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAŠ     ő         Ć      6              ('blue', urwid.LIGHT_BLUE, urwid.BLACK),5_Đ   +   -           ,          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAŞ    ő         Ć      =              ('magenta', urwid.DARK_MAGENTA, urwid.BLACK), ]5_Đ   ,   .           -          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA°    ő   ~      Ć      :                ('normal', urwid.LIGHT_GRAY, urwid.BLACK),5_Đ   -   /           .          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAľ    ő   }      Ć      ;    PALLETE = [('reversed', urwid.BLACK, urwid.LIGHT_GRAY),   *('normal', urwid.LIGHT_GRAY, urwid.BLACK),ő   ~      Ć      :                ('normal', urwid.LIGHT_GRAY, urwid.BLACK),5_Đ   .   0           /          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAş    ő   ~      Ć      9               ('normal', urwid.LIGHT_GRAY, urwid.BLACK),   (('error', urwid.LIGHT_RED, urwid.BLACK),ő         Ć      8                ('error', urwid.LIGHT_RED, urwid.BLACK),5_Đ   /   1           0          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAĂ     ő         Ć      9                ('green', urwid.DARK_GREEN, urwid.BLACK),5_Đ   0   2           1          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAÄ     ő         Ć      5            ('green', urwid.DARK_GREEN, urwid.BLACK),5_Đ   1   3           2          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAĆ     ő         Ć      7               ('error', urwid.LIGHT_RED, urwid.BLACK),   )('green', urwid.DARK_GREEN, urwid.BLACK),ő         Ć      9                ('green', urwid.DARK_GREEN, urwid.BLACK),5_Đ   2   4           3          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAĚ    ő         Ć      8               ('green', urwid.DARK_GREEN, urwid.BLACK),   (('blue', urwid.LIGHT_BLUE, urwid.BLACK),ő         Ć      8                ('blue', urwid.LIGHT_BLUE, urwid.BLACK),5_Đ   3   5           4          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAŇ    ő         Ć      7               ('blue', urwid.LIGHT_BLUE, urwid.BLACK),   /('magenta', urwid.DARK_MAGENTA, urwid.BLACK), ]ő         Ć      ?                ('magenta', urwid.DARK_MAGENTA, urwid.BLACK), ]5_Đ   4   6           5           ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAÚ    ő                 5_Đ   5   7           6   y   #    ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAá    ő   x   {   Ĺ      PYou can also asynchronously output messages with Commander.output('message') """5_Đ   6   8           7   q        ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAć    ő   p   q                  5_Đ   7   9           8   t   .    ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAî    ő   s   v   Ĺ      T    """ Simple terminal UI with command input on bottom line and display frame above5_Đ   8   :           9          ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YA˙     ő          Ć      1        """ what do do when a line is entered """   	     passő          Ć              pass5_Đ   9   <           :          ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             YA    ő          Ć              pass5_Đ   :       ;       <   ž        ˙˙˙˙                                                                                                                                                                                                                                                                                                                            ž          Â          V       YAg    ő   ˝   ž                     t=Thread(target=run)       t.daemon=True       t.start()       5_Đ   :           <   ;   ž       ˙˙˙˙                                                                                                                                                                                                                                                                                                                               7          D       V   !    YAc     ő   ˝   Ŕ        5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                                       ˘           V        YA}     ő   
   7        5_Đ                            ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                  V        YA}     ő      Ł        5_Đ                       (    ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                  V        YA}     ő         ­          c=Commander('Test')5_Đ                    Z       ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             YA}ł    ő   Y   [   ­          def __init__(self, title, command_caption='Command:  (Tab to switch focus to upper frame, where you can scroll text)', max_size=1000):5_Đ                     u       ˙˙˙˙                                                                                                                                                                                                                                                                                                                                                             YA}Î    ő   t   v   ­      "            except Exception as e:5çŞ