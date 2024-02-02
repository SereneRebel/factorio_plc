note: Not really maintained feel free to fork/update/edit.
2nd Feb 2024: Updated and rewritten for Factorio 1.1

# plc
Hoorah PLC is back!!!

This is still very much a WIP and more stuff is getting added as i get time, next item will be adding copy/paste of code from one PLC to another

Signal Controller (aka Programmable Logic Controller) takes circuit network inputs and uses them in a small program then outputs them to another circuit network.


The left hand circuit terminal is used for the PLC's input signals, these are then filtered on the "Inputs" tab to convert the selected signal into a variable to use within the program.

The right hand circuit terminal is for the output signals selected on the "Outputs" tab

The program is constructed on the "Program" tab using the dropdown selectors on each line (x100) the tooltip will attempt to explain what each command does but most are simple enough. The boxes to the right are used for the command as parameters (variable names / numbers). Once you are happy with the program clicking the run button (on the program tab) and provided it has enough power it will execute the program each tick

During each tick the PLC will do the following
1- Read signal inputs from the left hand terminal and transfer the selected ones to the variables specified, overwriting anything previously set
2- The PLC will execute all the lines of the program (with exception of any if-then-else that shouldn't execute)
3- Then output the selected variables as the signals specified to the right hand terminal

Hopefully this is clear enough if not please complain so i can fix it

