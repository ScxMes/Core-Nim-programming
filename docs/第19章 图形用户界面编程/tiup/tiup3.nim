import
  iup, strutils, math
 
# assumes you have the iup  .dll or .so installed
 
randomize()  
discard iup.open(nil,nil)
 
 
var lbl = label("Value:")
setAttribute(lbl,"PADDING","2x2")
 
var valu = text(nil)
setAttribute(valu, "PADDING", "2x2")
setAttribute(valu, "VALUE", "0")
 
proc toCB(fp: proc): ICallback =
   return cast[ICallback](fp)
 
# Click handler for Click button
proc incClick(ih:PIhandle): cint {.cdecl.} =
    var s: string = $(getAttribute(valu,"VALUE"))
    var x: int = 0
    try:
       x = 1 + parseInt(s)
    except:
       x = 1         # default to 1 if non-numeric entry
    setAttribute(valu,"VALUE", $x)
    return IUP_DEFAULT
 
# Click handler for Random button
proc randClick(ih:PIhandle): cint {.cdecl.} =
    if iup.alarm("Random Value?", "Set value to a random numer < 100 ?","Yes","No",nil) == 1:
        setAttribute(valu,"VALUE", $random(100))
    return IUP_DEFAULT
 
# Key handler to check for Esc pressed
proc key_cb(ih:PIhandle, c: cint):cint {.cdecl.} =
  #echo c
  if (c == iup.K_esc) and (iup.alarm("Exit?", "Had enough?","Yes","Keep going",nil) == 1):
    return IUP_CLOSE    # Exit application
  return IUP_CONTINUE
 
 
var txtBox = hbox(lbl, valu, nil)
setAttribute(txtBox, "MARGIN", "10x10")
 
var incBtn = button("&Increment", "")
var randBtn = button("&Randomize", "")
var btnBox = vbox(incBtn, randBtn, nil)
setAttribute(btnBox, "MARGIN", "5x5")
 
var contents = hbox(txtBox, btnBox, nil)
setAttribute(contents, "MARGIN", "2x2")
 
discard setCallback(incBtn,"ACTION", toCB(incClick))
discard setCallback(randBtn,"ACTION", toCB(randClick))
discard setCallback(contents,"K_ANY", toCB(key_cb))       
 
var dlg = dialog(contents)
discard dlg.show()
discard mainloop()
iup.close()