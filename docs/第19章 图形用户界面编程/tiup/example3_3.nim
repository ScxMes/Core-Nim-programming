import iup

var Nmultitext: PIhandle

proc read_file(filename:cstirng): cstirng = 


proc write_file (filename,str:cstirng, count:cint): void =
  
  
    FILE* file = fopen(filename, "w");
  if (!file) 
  {
    IupMessagef("Error", "Can't open file: %s", filename);
    return;
  }

  fwrite(str, 1, count, file);

  if (ferror(file))
    IupMessagef("Error", "Fail when writing to file: %s", filename);

  fclose(file);
  
  
  
  
proc open_cb(void): cint =
  var Nfiledlg = fileDlg();
  setAttribute(Nfiledlg,"DIALOGTYPE","OPEN")
  SetAttribute(filedlg, "EXTFILTER", "Text Files|*.txt|All Files|*.*|")
  
  popup(Nfiledlg, IUP_CENTER, IUP_CENTER)
  
  if getInt(Nfiledlg,"STATUS") != -1 :
    var filename = getAttribute(Nfiledlg,"VALUE")
    var str = read_file(filename)
    if str :
      setStrAttribute(Nmultitext,"VALUE",str)
      free(str)

  destroy(Nfiledlg)
  return IUP_DEFAULT

  

proc saveas_cb(void): cint = 
  var Nfiledlg = fileDlg()
  setAttribute(Nfiledlg,"DIALOGTYPE","SAVE")
  setAttribute(Nfiledlg,"EXTFILTER","Text Files|*.txt|All Files|*.*|")
  
  popup(Nfiledlg,IUP_CENTER,IUP_CENTER)
  
  if getInt(Nfiledlg,"STATUS") != -1 :
    var filename = getAttribute(Nfiledlg,"VALUE")
    var str = getAttribute(Nmultitext,"VALUE")
    var count = getInt(Nmultitext,"COUNT")
    write_file(filename,str,count)

  destroy(Nfiledlg)
  return IUP_DEFAULT



proc font_cb(void): cint = 
  var Nfontdlg = fontDlg()
  var font = getAttribute(Nmultitext,"FONT")
  setStrAttribute(Nfontdlg,"VALUE",font)
  popup(Nfontdlg,IUP_CENTER,IUP_CENTER)
  
  if getInt(Nfontdlg,"STATUS") == 1 :
    var font = getAttribute(Nfontdlg, "VALUE")
    setStrAttribute(Nmultitext,"FONT",font)
  
  destroy(Nfontdlg)
  return IUP_DEFAULT;
  
proc about_cb(void): cint =  
  IupMessage("About", "   Simple Notepad\n\nAutors:\n   Gustavo Lyrio\n   Antonio Scuri");
  return IUP_DEFAULT;

proc exit_cb(void) : cint = 
  return IUP_CLOSE;

var dlg,Nvbox: PIhandle
var file_menu,item_exit,item_open,item_saveas: PIhandle
var format_menu,item_font: PIhandle
var help_menu,item_about: PIhandle
var sub_menu_file,sub_menu_format,sub_menu_help,Nmenu: PIhandle

discard iup.open(nil,nil)

Nmultitext = text(nil)
setAttribute(Nmultitext,"MULTILINE","YES")
setAttribute(Nmultitext,"EXPAND","YES")

item_open = item("Open...", nil);
item_saveas = item("Save As...", nil);
item_exit = item("Exit", nil);
item_font = item("Font...", nil);
item_about = item("About...", nil);

setCallback(item_exit, "ACTION", Icallback(exit_cb));
setCallback(item_open, "ACTION", Icallback(open_cb));
setCallback(item_saveas, "ACTION", Icallback(saveas_cb));
setCallback(item_font, "ACTION", Icallback(font_cb));
setCallback(item_about, "ACTION", Icallback(about_cb));

file_menu = menu(item_open,item_saveas,IupSeparator(),item_exit,nil)
format_menu = menu(item_font,nil)
help_menu = menu(item_about,nil)

sub_menu_file = submenu("File",file_menu);
sub_menu_format = submenu("Format", format_menu);
sub_menu_help = submenu("Help", help_menu);

Nmenu = menu(sub_menu_file, sub_menu_format, sub_menu_help,nil)

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
#include <stdio.h>
#include <stdlib.h>
#include <iup.h>

/* global variable - to be used inside the menu callbacks */
Ihandle* multitext = NULL;

char* read_file(const char* filename)
{
  int size;
  char* str;
  FILE* file = fopen(filename, "rb");
  if (!file) 
  {
    IupMessagef("Error", "Can't open file: %s", filename);
    return NULL;
  }

  /* calculate file size */
  fseek(file, 0, SEEK_END);
  size = ftell(file);
  fseek(file, 0, SEEK_SET);

  /* allocate memory for the file contents + nul terminator */
  str = malloc(size + 1);
  /* read all data at once */
  fread(str, size, 1, file);
  /* set the nul terminator */
  str[size] = 0;

  if (ferror(file))
    IupMessagef("Error", "Fail when reading from file: %s", filename);

  fclose(file);
  return str;
}

void write_file(const char* filename, const char* str, int count)
{
  FILE* file = fopen(filename, "w");
  if (!file) 
  {
    IupMessagef("Error", "Can't open file: %s", filename);
    return;
  }

  fwrite(str, 1, count, file);

  if (ferror(file))
    IupMessagef("Error", "Fail when writing to file: %s", filename);

  fclose(file);
}

int open_cb(void)
{
  Ihandle *filedlg = IupFileDlg();
  IupSetAttribute(filedlg, "DIALOGTYPE", "OPEN");
  IupSetAttribute(filedlg, "EXTFILTER", "Text Files|*.txt|All Files|*.*|");

  IupPopup(filedlg, IUP_CENTER, IUP_CENTER);

  if (IupGetInt(filedlg, "STATUS") != -1)
  {
    char* filename = IupGetAttribute(filedlg, "VALUE");
    char* str = read_file(filename);
    if (str)
    {
      IupSetStrAttribute(multitext, "VALUE", str);
      free(str);
    }
  }

  IupDestroy(filedlg);
  return IUP_DEFAULT;
}

int saveas_cb(void)
{
  Ihandle *filedlg = IupFileDlg();
  IupSetAttribute(filedlg, "DIALOGTYPE", "SAVE");
  IupSetAttribute(filedlg, "EXTFILTER", "Text Files|*.txt|All Files|*.*|");

  IupPopup(filedlg, IUP_CENTER, IUP_CENTER);

  if (IupGetInt(filedlg, "STATUS") != -1)
  {
    char* filename = IupGetAttribute(filedlg, "VALUE");
    char* str = IupGetAttribute(multitext, "VALUE");
    int count = IupGetInt(multitext, "COUNT");
    write_file(filename, str, count);
  }

  IupDestroy(filedlg);
  return IUP_DEFAULT;
}

int font_cb(void)
{
  Ihandle* fontdlg = IupFontDlg();
  char* font = IupGetAttribute(multitext, "FONT");
  IupSetStrAttribute(fontdlg, "VALUE", font);
  IupPopup(fontdlg, IUP_CENTER, IUP_CENTER);

  if (IupGetInt(fontdlg, "STATUS") == 1)
  {
    char* font = IupGetAttribute(fontdlg, "VALUE");
    IupSetStrAttribute(multitext, "FONT", font);
  }

  IupDestroy(fontdlg);
  return IUP_DEFAULT;
}

int about_cb(void) 
{
  IupMessage("About", "   Simple Notepad\n\nAutors:\n   Gustavo Lyrio\n   Antonio Scuri");
  return IUP_DEFAULT;
}

int exit_cb(void)
{
  return IUP_CLOSE;
}

int main(int argc, char **argv)
{
  Ihandle *dlg, *vbox;
  Ihandle *file_menu, *item_exit, *item_open, *item_saveas;
  Ihandle *format_menu, *item_font;
  Ihandle *help_menu, *item_about;
  Ihandle *sub_menu_file, *sub_menu_format, *sub_menu_help, *menu;

  IupOpen(&argc, &argv);

  multitext = IupText(NULL);
  IupSetAttribute(multitext, "MULTILINE", "YES");
  IupSetAttribute(multitext, "EXPAND", "YES");

  item_open = IupItem("Open...", NULL);
  item_saveas = IupItem("Save As...", NULL);
  item_exit = IupItem("Exit", NULL);
  item_font = IupItem("Font...", NULL);
  item_about = IupItem("About...", NULL);

  IupSetCallback(item_exit, "ACTION", (Icallback)exit_cb);
  IupSetCallback(item_open, "ACTION", (Icallback)open_cb);
  IupSetCallback(item_saveas, "ACTION", (Icallback)saveas_cb);
  IupSetCallback(item_font, "ACTION", (Icallback)font_cb);
  IupSetCallback(item_about, "ACTION", (Icallback)about_cb);

  file_menu = IupMenu(
    item_open,
    item_saveas,
    IupSeparator(),
    item_exit,
    NULL);
  format_menu = IupMenu(
    item_font,
    NULL);
  help_menu = IupMenu(
    item_about,
    NULL);

  sub_menu_file = IupSubmenu("File", file_menu);
  sub_menu_format = IupSubmenu("Format", format_menu);
  sub_menu_help = IupSubmenu("Help", help_menu);

  menu = IupMenu(
    sub_menu_file, 
    sub_menu_format, 
    sub_menu_help, 
    NULL);

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
