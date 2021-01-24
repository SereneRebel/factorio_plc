note: Not really maintained feel free to fork/update/edit.

# plc
Factorio mod Programmable Logic Controller

Programmable Logic Controller takes circuit network inputs and uses them in a small program then outputs them to another circuit network. 

To open the PLC's GUI check you have the keybind set to what you would like (I personally set it to left click)

The left hand circuit terminal is used for the PLC's input signals, these are then filtered on the "Inputs" tab to convert the selected signal into a variable to use within the program. 

The right hand circuit terminal is for the output signals selected on the "Outputs" tab

The program is constructed on the "Program" tab using the dropdown selectors on each line (x100) the tooltip will attempt to explain what each command does but most are simple enough. The boxes to the right are used for the command as parameters (variable names / numbers). Once you are happy with the program clicking the run button (on the program tab) and provided it has enough power it will execute the program each tick

During each tick the PLC will do the following
1- Read signal inputs from the left hand terminal and transfer the selected ones to the variables specified, overwriting anything previously set
2- The PLC will execute all the lines of the program (with exception of any if-then-else that shouldn't execute)
3- Then output the selected variables as the signals specified to the right hand terminal

Clicking the "Close" tab will close the gui

Hopefully this is clear enough if not please complain so i can fix it

ps. i have used some borrowed bits of code and techniques from numerous places, most notably Helfima(helmod for gui layout techniques) and Earendel(AAI scanners for circuit network handling) if you find some of your own code in there please let me know and i will credit where credit is due
