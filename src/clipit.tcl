##############
# clipit.tcl #
##############
# planmac at gmail dot com
# February 2015
# Version 0.42

# TODO
# Make colors cross-platform
# Allow to Alt-Tab to ClipiT (on all platforms)
# Add proper message to the About splash
# Cascade hover to label and its frame (tidy up for shorter text)

package require Tk
package require Ttk

#Use custom quit, no window decporations, pin to top left of screen
wm protocol . WM_DELETE_WINDOW quit
wm overrideredirect . 1
#wm title . "ClipiT 0.42"
wm geometry . +0+0
wm resizable . 0 0

#The active top line of the window
pack [frame .top ] -side top -fill x -expand 1
pack [button .about -text i -font {size 8} \
        -command about] -in .top -side left
pack [button .quit -text x -font {-size 8} -background plum \
        -command quit] -in .top -side right

#Left-click on title to add current clipboard contents,
#right-click on title to quit (in case the button is not available).
pack [label .lab -text "ClipiT 0.42"] -in .top \
  -side left -fill x -expand 1
bind .lab <Enter> {.lab configure -foreground white -background lightBlue}
bind .lab <Leave> {.lab configure -foreground SystemButtonText -background SystemButtonFace}
bind .lab <ButtonPress-1> clip
bind .lab <ButtonPress-3> quit

#An about splash
proc about {} {
  tk_messageBox -type ok -message "ClipiT 0.42" \
    -detail \
"Copy text to the system clipboard from any application\n\
then click on the ClipiT label to add a new entry.\n\n\
Click on the text of an entry to yank it back to the system clipboard\n\
then paste it into any application as normal.\n\n\
Right click on the text of an entry to show/edit the full text\n\
and click Save to add the modified text as a new entry.\n\n\
Click on the x to delete an entry or the top-right x to quit,\n\
or right click on the ClipiT label to quit.\n\n\
planmac at gmail dot com\n\
February 2015"
}

proc clip {} {
  if { [set txt [gettext]] != "" } {newitem $txt}
}

#Get text from the system clipboard, return empty string if none
proc gettext {} {
  if {[catch {clipboard get} txt]} {
    tk_messageBox -message "Clipboard empty!" \
      -type ok -icon warning
    return ""
  } else {
    return $txt
  }
}

#Add text as new entry, return the widget path
proc newitem {txt} {
  #Keep a global count of number of entries
  global i
  set f .i[incr i]

  #Limit length of displayed string to 20ish characters, 
  #and keep the full string in an un-packed label $f.t
  if {[set len [string length $txt]] > 20} {
    set vis "[string range $txt 0 17]..<[expr $len-19]>"
  } else {
    set vis $txt
  }

  #New entry with possibly truncated text, 
  #store full text in an un-rendered widget
  pack [frame $f] -side top -fill x
  pack [label $f.l -text $vis] -side left -fill x
  label $f.t -text $txt

  #Button to delete the entry
  pack [button $f.b -text x -font {-size 8} \
        -command "destroy $f" \
        -activebackground lightBlue] \
    -side right

  #Change background colors when pointer hovers,
  #Left-click to yank it to the system clipboard, 
  #Right-click to show the full text.
  bind $f.l <Enter> "$f.l configure -foreground white -background lightBlue"
  bind $f.l <Leave> "$f.l configure -foreground SystemButtonText -background SystemButtonFace"
  bind $f.l <ButtonPress-1> "yank $f"
  bind $f.l <ButtonPress-3> "show $f"
  
  return $f
}

#Yank full text of clicked entry back to the system clipboard
proc yank {f} {
  set txt [$f.t cget -text]
  clipboard clear
  clipboard append $txt
  $f.b flash
}

#Show full text of clicked entry, and offer to edit
proc show {f} {

  #New toplevel
  toplevel .e
  wm title .e "ClipiT 0.42"

  #Frame with vertical scrollbar and text edit widget
  pack [frame .e.f] -side top -fill both -expand 1
  pack [ttk::scrollbar .e.f.scroll -orient vertical \
        -command {.e.f.txt yview}] \
    -side right -fill y
  pack [text .e.f.txt -yscrollcommand {.e.f.scroll set}] \
    -side top -fill both -expand 1

  #Get txt from un-packed widget and put into text widget
  .e.f.txt replace 0.0 end [$f.t cget -text]

  #Make the button frame
  pack [frame .e.b ] -side bottom -fill x 
  pack [label .e.b.spacer -width 2] -side right 
  
  #Cancel: just destroys this toplevel
  pack [ttk::button .e.b.can -text Cancel -command {destroy .e}] \
    -side right -padx 4 -pady 12

  #Save: gets possibly changed text from the text edit widget, 
  #(skipping last lineend char), create a new entry in ClipiT,
  # and destroy this toplevel.
  pack [ttk::button .e.b.sav -text Save \
        -command { \
          newitem [.e.f.txt get 0.0 {end - 1 chars}]; \
          destroy .e }] \
    -side right -padx 4 -pady 12

  #?How to make Save button the default
}

#Really quit?
proc quit {} {
  switch -- [tk_messageBox \
               -message "Do you really want to quit ClipiT?" \
               -icon question -type yesno] \
    {
      yes exit
      no  {}
    }
}
