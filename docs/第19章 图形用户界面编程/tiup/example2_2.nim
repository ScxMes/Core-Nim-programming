import iup,encodings

discard iup.open(nil, nil)
var dlg,label1:PIhandle
var title:string

label1 = label("Hello world from IUP.")
dlg = dialog(vbox(label1,nil))

var Thistype = getCurrentEncoding()
title = "你好"
title = convert(open(Thistype,"UTF-8"),title)

setAttribute(dlg,"TITLE",title)
showXY(dlg,IUP_CENTER,IUP_CENTER)
mainLoop()






discard """
Ihandle *dlg, *label;

  IupOpen(&argc, &argv);

  label =  IupLabel("Hello world from IUP.");
  dlg = IupDialog(IupVbox(label, NULL));
  IupSetAttribute(dlg, "TITLE", "Hello World 2");

  IupShowXY(dlg, IUP_CENTER, IUP_CENTER);

  IupMainLoop();
"""