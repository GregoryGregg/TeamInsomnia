This is an explination of the Motor control code

The outputs of the motor control code are NOT to be changed, the input
clk is the only input unchanged. sw is going to be removed later after
the encoder and speed control is set up at a later date.

The other inputs are explained as followed

Direction:
3 Bit register

Motor surface is the only module you should have to interface with
I made the directions simple, there are eight directions. 

     // Forward.........= 000
     // Forward-Right...= 001
     // Right...........= 010
     // Back-Right......= 011
     // Back............= 100
     // Back-Left.......= 101
     // Left............= 110
     // Forward-Left... = 111 

Think of the directions increasing in a clockwise motion around the car
with forward being at the 12 o'clock position

Brake:
1- Bit register

Originally I had it active low but this became very confusing so 
for now if functions  active high

    // Brake = 1; brake on
    // Brake = 0; brake off, normal operation

Coast:
1- Bit register

Rather than active breaking the rover and just slow to a stop,
to do this set Coast to 1

    Coast = 1; slow stop
    Coast = 0; normal operation