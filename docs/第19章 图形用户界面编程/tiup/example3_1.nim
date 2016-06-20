import iup

var dlg,Nmultitex,Nvbox: PIhandle

discard iup.open(nil,nil)

Nmultitex = text(nil)
Nvbox = vbox(Nmultitex,nil)

setAttribute(Nmultitex,"MULTILINE","YES")
setAttribute(Nmultitex,"EXPAND","YES")

dlg = dialog(Nvbox)

setAttribute(dlg,"TITLE","Simple Notepad")
setAttribute(dlg,"SIZE","QUARTERxQUARTER")

showXY(dlg,IUP_CENTER,IUP_CENTER)
setAttribute(dlg,"USERSIZE",nil)

mainLoop()
close()






discard """
#include <stdlib.h>
#include <iup.h>

int main(int argc, char **argv)
{
  Ihandle *dlg, *multitext, *vbox;

  IupOpen(&argc, &argv);

  multitext = IupText(NULL);
  vbox = IupVbox(
    multitext,
    NULL);
  IupSetAttribute(multitext, "MULTILINE", "YES");
  IupSetAttribute(multitext, "EXPAND", "YES");

  dlg = IupDialog(vbox);
  IupSetAttribute(dlg, "TITLE", "Simple Notepad");
  IupSetAttribute(dlg, "SIZE", "QUARTERxQUARTER");

  IupShowXY(dlg, IUP_CENTER, IUP_CENTER);
  IupSetAttribute(dlg, "USERSIZE", NULL);

  IupMainLoop();

  IupClose();
  return EXIT_SUCCESS;
}
"""