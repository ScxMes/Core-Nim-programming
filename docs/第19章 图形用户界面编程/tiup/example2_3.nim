import iup


proc toCB(fp: proc): ICallback =
   return cast[ICallback](fp)

proc incClick(ih:PIhandle): cint {.cdecl.} =
  message("Hello World Message","Hello world from IUP.")
  return IUP_CLOSE

discard iup.open(nil,nil)

var dlg,ebutton,evbox:PIhandle
ebutton = button("OK",nil)
evbox = vbox(ebutton,nil)
dlg = dialog(evbox)

setAttribute(dlg,"TITLE","Hello World 3");
setAttribute(dlg, "SIZE", "200x100")

#setCallback(ebutton,"ACTION",toCB(incClick))
setCallback(ebutton,"ACTION",ICallback (incClick))
showXY(dlg,IUP_CENTER,IUP_CENTER)
mainLoop()
close()





discard """
#include <stdlib.h>
#include <iup.h>

int btn_exit_cb( Ihandle *self )
{
  IupMessage("Hello World Message", "Hello world from IUP.");
  /* Exits the main loop */
  return IUP_CLOSE;
}

int main(int argc, char **argv)
{
  Ihandle *dlg, *button, *vbox;

  IupOpen(&argc, &argv);
  
  button = IupButton("OK", NULL);
  vbox = IupVbox(
    button,
    NULL);
  dlg = IupDialog(vbox);
  IupSetAttribute(dlg, "TITLE", "Hello World 3");

  /* Registers callbacks */
  IupSetCallback(button, "ACTION", (Icallback) btn_exit_cb);

  IupShowXY(dlg, IUP_CENTER, IUP_CENTER);

  IupMainLoop();

  IupClose();
  return EXIT_SUCCESS;
}
"""