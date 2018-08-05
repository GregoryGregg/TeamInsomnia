`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Name: Justin Schwausch
// Class: ECE 3331
// Project: Carriage control module
// Target: Basys 3 Board
// Last Modified: 7/30/2018
//
// This program controls the carriage on Team Insomnia's rover. This module make the carriage sweep side to side across the rover and changes direction when it rolls over a switch.
// When the inductance proximity sensor on the carriage detects a washer, the module sends a stop signal to the rover, picks up the washer, moves it to the side, and drops it.
//////////////////////////////////////////////////////////////////////////////////





module carriage(

input[1:0] sw,
input clk, ips, brake,
output mag, mine, 
output[1:0] dir, 
output[12:0] LED

    );

    
    reg obst = 1'b0; //one bit used to show if there is an obstacle
    reg direction = 1'b1; //one bit direction passed to direction control
    reg done = 1'b1; //has the mine been removed
    reg[22:0] count; //delay count register
    reg[2:0] state = 3'b000;
    reg[27:0] safcnt = 28'b1000111100001101000110000000;
    reg[27:0] safreg = 28'b0;
    reg swab; //switch a bounced signal, goes high one tick after the actual switch
    reg swbb; //switch b bounced signal
    wire swa; //switch a
    wire swb; //switch b
    wire swac; //high when swa is high and swab is low
    wire swbc; //high when swb is high and swbb is low
    reg magnet; //wire for magnet
    
    assign mine = obst;
    assign mag = magnet;
    assign swa = sw[0];
    assign swb = sw[1];
    assign LED[0] = direction; //debug leds
    assign LED[1] = dir[0];
    assign LED[2] = dir[1];
    assign LED[3] = brake;
    assign LED[4] = swa;
    assign LED[5] = swb;
    assign LED[6] = ips;
    assign LED[7] = mag;
    assign LED[8] = mine;
    assign LED[9] = done;
    assign LED[10] = swac;
    assign LED[11] = swbc;

    

    assign swac = (swa && !swab) ?1'b1:1'b0; //is high for one tick after switch goes high
    assign swbc = (swb && !swbb) ?1'b1:1'b0;

    

        Directional_Control CarriageMotor( //instantiates motor control and converts brake and one bit direction to final motor signals
        .direction(direction),
        .brake(brake),
        .INA(dir[0]),
        .INB(dir[1])
        );


      always @(posedge clk) //creates a high signal one tick after the switch actually goes high
      begin

      if(swa)
      swab <= 1'b1;
      
      else
      swab <= 1'b0;
      end

      

      always @(posedge clk) //same as above but for switch b
      begin

      if(swb)
      swbb <= 1'b1;
      
      else
      swbb <= 1'b0;
      end



        

//    always @(posedge clk) //checks for mines
//    begin

//    if(ips && count == 22'b0) //if ips detects a mine and the delay is over
//    begin
//    obst <= 1'b1;
//    end

//    else if (done) //if mine has been removed
//    begin
//    obst <= 1'b0; //reset mine flag
//    end

//    end

    always @(posedge clk) //safety stop in case switch signals aren't recieved
    begin
    
    if(swac) //switch direction based off of switches
    begin
    direction <= 1'b1;
    end

    else if (swbc) //switch direction based off of switches
    begin
    direction <= 1'b0;
    end
    
    
    if(swac || swbc) //if either switch is high
    begin
    safreg <= safcnt; //reset counter
    end
    
    else //if neither switch is high
    begin
    safreg <= safreg - 1'b1; //decrement counter
    end
    
    if(safreg == 28'b0) //if counter gets to zero
    begin
    direction <= ~direction; //reverse direction
    end
    end
    
    always @(posedge clk) //executes if there is a mine
    begin
    
     case(state)
     3'b000:
     begin
     if(ips && count == 22'b0)
     begin
     obst <= 1'b1; //set mine to high
     magnet <= 1'b1; //turn on magnet
     state <= 3'b001; //move to next state
     end
     end
     
     3'b001:
     begin
     if(swa)
     begin
     magnet <= 1'b0;
     state <= 3'b010;
     end
     else if(swb)
     begin
     magnet <= 1'b0;
     state <= 3'b011;
     end
     end
     
     3'b010:
     begin
     if(ips && count == 22'b0)
     begin
     state <= 3'b000;
     end
     else if(swb)
     begin
     state <= 3'b100;
     end
     end
     
     3'b011:
     begin
     if(ips && count == 22'b0)
     begin
     state <= 3'b000;
     end
     else if(swa)
     begin
     state <= 3'b100;
     end
     end
     
     3'b100:
     begin
     obst <= 1'b0;
     state <= 3'b000;
     end
    
    endcase
    end

    

//    always @(posedge clk) //executes if there is a mine
//    begin

//    if(obst) //if there is a mine
//    begin

//    if(done) //if the mine flag just got set to high
//    begin
//    done <= 1'b0; //set done to low
 
//    magnet <= 1'b1; //turn magnet on

//    end

    

//    if(swa || swb) //next time the carriage hits a switch
//    begin

//    magnet <= 1'b0; //turn the magnet off

//    done <= 1'b1; //set the done flag

//    end

//    end

//    end

    

    always @(posedge clk) //buffer block, stops the magnet from being triggered from a previously dropped mine
    begin

    if (magnet) //if there is a mine
    begin

    count <= 23'b11111111111111111111111; //load a value into the counter

    end

    if((count != 23'b0) && !magnet) //if there is no mine and the counter hasn't reached 0
    begin

    count <= count - 1'b1; //decrement the count

    end

    end

    

endmodule
