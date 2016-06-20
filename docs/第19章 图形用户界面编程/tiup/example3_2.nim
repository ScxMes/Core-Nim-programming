import iup

proc exit_cb(void): cint {.cdecl.} =
  return IUP_CLOSE

var dlg,Nmultitext,Nvbox: PIhandle
var file_menu,item_exit,item_open,item_saveas: PIhandle
var sub1_menu,Nmenu: PIhandle

discard iup.open(nil,nil)

Nmultitext = text(nil)
setAttribute(Nmultitext,"MULTILINE","YES")
setAttribute(Nmultitext,"EXPAND","YES")

item_open = item("Open",nil)
item_saveas = item("Save As",nil)
item_exit = item("Exit",nil)
setCallback(item_exit,"ACTION",Icallback(exit_cb))

file_menu = menu(item_open,item_saveas,separator(),item_exit,nil)

sub1_menu = submenu("File",file_menu)

Nmenu = menu(sub1_menu,nil)

Nvbox = vbox(Nmultitext,nil)

dlg = dialog(Nvbox)

setAttributeHandle(dlg,"MENU",Nmenu)
setAttribute(dlg,"TITLE","Simple Notepad")
setAttribute(dlg,"SIZE","QUARTERxQUARTER")

showXY(dlg,IUP_CENTER,IUP_CENTER)
setAttribute(dlg,"USERSIZE",nil)

mainLoop()
close()



discard """
#include <stdlib.h>
#include <iup.h>

int exit_cb(void)
{
  return IUP_CLOSE;
}

int main(int argc, char **argv)
{
  Ihandle *dlg, *multitext, *vbox;
  Ihandle *file_menu, *item_exit, *item_open, *item_saveas;
  Ihandle *sub1_menu, *menu;

  IupOpen(&argc, &argv);

  multitext = IupText(NULL);
  IupSetAttribute(multitext, "MULTILINE", "YES");
  IupSetAttribute(multitext, "EXPAND", "YES");

  item_open = IupItem("Open", NULL);
  item_saveas = IupItem("Save As", NULL);
  item_exit = IupItem("Exit", NULL);
  IupSetCallback(item_exit, "ACTION", (Icallback)exit_cb);

  file_menu = IupMenu(
    item_open,
    item_saveas,
    IupSeparator(),
    item_exit,
    NULL);

  sub1_menu = IupSubmenu("File", file_menu);

  menu = IupMenu(sub1_menu, NULL);

  vbox = IupVbox(
    multitext,
    NULL);

  dlg = IupDialog(vbox);
  IupSetAttributeHandle(dlg, "MENU", menu);
  IupSetAttribute(dlg, "TITLE", "Simple Notepad");
  IupSetAttribute(dlg, "SIZE", "QUARTERxQUARTER");

  IupShowXY(dlg, IUP_CENTER, IUP_CENTER);
  IupSetAttribute(dlg, "USERSIZE", NULL);

  IupMainLoop();

  IupClose();
  return EXIT_SUCCESS;
}
"""