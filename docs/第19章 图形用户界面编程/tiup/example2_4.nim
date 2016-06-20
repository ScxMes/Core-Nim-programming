import iup

proc btn_exit_cb(ih:PIhandle): cint {.cdecl.} =
  return IUP_CLOSE

var dlg,Nbutton,Nlabel,Nvbox: PIhandle

discard iup.open(nil,nil)

Nbutton = button("OK",nil)
Nlabel = label("Hello world from IUP.")
Nvbox = vbox(Nlabel,Nbutton,nil)
dlg = dialog(Nvbox)

setAttribute(dlg,"TITLE","Hello World 4")
setAttribute(dlg,"SIZE","200x100")

setCallback(Nbutton,"ACTION",Icallback(btn_exit_cb))

showXY(dlg,IUP_CENTER,IUP_CENTER)
mainLoop()
close()



discard """
#include <stdlib.h>
#include <iup.h>

int btn_exit_cb( Ihandle *self )
{
  /* Exits the main loop */
  return IUP_CLOSE;
}

int main(int argc, char **argv)
{
  Ihandle *dlg, *button, *label, *vbox;

  IupOpen(&argc, &argv);
  
  label =  IupLabel("Hello world from IUP.");
  button = IupButton("OK", NULL);
  vbox = IupVbox(
    label,
    button,
    NULL);
  dlg = IupDialog(vbox);
  IupSetAttribute(dlg, "TITLE", "Hello World 4");

  /* Registers callbacks */
  IupSetCallback(button, "ACTION", (Icallback) btn_exit_cb);

  IupShowXY(dlg, IUP_CENTER, IUP_CENTER);

  IupMainLoop();

  IupClose();
  return EXIT_SUCCESS;
}
"""