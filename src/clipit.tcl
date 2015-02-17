# clipit.tcl
#    planmac at gmail dot com
#    February 2015
#
# Copy any text into the system clipboard from any application,
# then click on the "ClipiT" label and it stores that text for later.
# Click on the stored text to yank that text back to the system clipboard,
# and then paste from the system clipboard into any application.
# Click on the "x" to destroy saved clips.

package require Tk

wm protocol . WM_DELETE_WINDOW quit
wm overrideredirect . 1
#wm title . "ClipiT 0.42"
wm geometry . +0+0
wm resizable . 0 0

#The active top line of the window
pack [frame .top ] -side top -fill x -expand 1
pack [button .quit -text x -font {-size 8} -background orange -command quit] -in .top -side right

#Left-click to save text, right-click to quit
pack [label .lab -text "ClipiT 0.42"] -in .top -side left -fill x -expand 1
bind .lab <Enter> {.lab configure -foreground white -background lightBlue}
bind .lab <Leave> {.lab configure -foreground SystemButtonText -background SystemButtonFace}
bind .lab <ButtonPress-1> clip
bind .lab <ButtonPress-3> quit

#Copy clipboard contents into ClipiT,
#keeping count of how many are clipped
proc clip {} {
  global i
  if {[catch {clipboard get} cont]} {
    tk_messageBox \
      -message "Clipboard empty!" \
      -type ok \
      -icon warning
  } else {
    set f .i[incr i]

    #Limit length of displayed string to 20ish characters, 
    #and keep the full string in an un-packed label 
    if {[set len [string length $cont]] > 20} {
      set disp "[string range $cont 0 17]..<[expr $len-19]>"
    } else {
      set disp $cont
    }

    pack [frame $f] -side top -fill x
    pack [label $f.l -text $disp] -side left -fill x
    label $f.t -text $cont
    pack [button $f.b -text x -font {-size 8} -command "destroy $f" -activebackground lightBlue] -side right

    bind $f.l <Enter> "$f.l configure -foreground white -background lightBlue"
    bind $f.l <Leave> "$f.l configure -foreground SystemButtonText -background SystemButtonFace"
    bind $f.l <ButtonPress-1> "yank $f"
    bind $f.l <ButtonPress-3> "show $f"
    
  }
}

#Yank clicked text back to the clipboard
proc yank {f} {
  set txt [$f.t cget -text]
  clipboard clear
  clipboard append $txt
  $f.b flash
}

#Show the full text
proc show {f} {
  set txt [$f.t cget -text]
  switch -- [tk_messageBox -message "Edit this text?" \
               -detail $txt -type yesno -icon info] \
  {
    yes "edit $f"
    no  {}
  }
}

proc edit {f} {
  toplevel .edit
  set txt [$f.t cget -text]
  pack [text .edit.txt ] -side top -fill both -expand 1
  .edit.txt replace 0.0 end $txt
  pack [frame .edit.frm ] -side bottom -fill x 
  pack [button .edit.frm.can -text Cancel -command {destroy .edit}] -side right
  pack [button .edit.frm.sav -text Save -command "save $f .edit"] -side right
}

#Save the edited text
proc save {f t} {
  set txt [$t.txt get 0.0 end]

  #Can do this more efficiently!
  clipboard clear
  clipboard append $txt
  clip

  destroy $t
}

#Really quit?
proc quit {} {
  switch -- [tk_messageBox \
               -message "Do you really want to quit ClipiT?" \
               -icon question \
               -type yesno] \
    {
      yes exit
      no  {tk_messageBox \
             -message "Cool.. thanks for keeping me alive!" \
             -type ok}
    }
}
