`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Name: Justin Schwausch
// Class: ECE 3331
// Project: Carriage control module
// Target: Basys 3 Board
// Last Modified: 8/5/2018
//
// This program controls the carriage on Team Insomnia's rover. This module make the carriage sweep side to side across the rover and changes direction when it rolls over a switch.
// When the inductance proximity sensor on the carriage detects a washer, the module sends a stop signal to the rover, picks up the washer, moves it to the side, and drops it.
//////////////////////////////////////////////////////////////////////////////////





module carriage(

input[1:0] sw,
input clk, ips, brake,
output mag, stop, 
output dirl, dirr, 
output[11:0] LED,
output[5:0] states

    );

    
    reg obst = 1'b0; //one bit used to show if there is an obstacle
    reg direction = 1'b1; //one bit direction passed to direction control
    reg done = 1'b1; //has the mine been removed
    reg[22:0] count; //delay count register
    reg[2:0] state = 3'b000;
    reg[27:0] safcnt = 28'b1000111100001101000110000000;
    reg[27:0] safreg = 28'b0;
    reg[24:0] magtime = 25'b1011111010111100001000000;
    reg[24:0] magcnt = 25'b0;
    reg[9:0] magratio = 10'b1000001000;
    reg[2:0] magstate = 3'b000;
    reg[5:0] magpwm;
    reg[5:0] magpick = 6'b111111;
    reg[5:0] maghold = 6'b001101;
    reg magdn = 1'b1;    
    reg swab; //switch a bounced signal, goes high one tick after the actual switch
    reg swbb; //switch b bounced signal\
    wire swa; //switch a
    wire swb; //switch b
    wire swac; //high when swa is high and swab is low
    wire swbc; //high when swb is high and swbb is low
    reg magnet; //wire for magnet
    
    assign stop = (obst || !(swab || swbb));
    assign swa = sw[0];
    assign swb = sw[1];
    assign LED[0] = direction; //debug leds
    assign LED[1] = dirl;
    assign LED[2] = dirr;
    assign LED[3] = brake;
    assign LED[4] = swa;
    assign LED[5] = swb;
    assign LED[6] = ips;
    assign LED[7] = mag;
    assign LED[8] = obst;
    assign LED[9] = done;
    assign LED[10] = swac;
    assign LED[11] = swbc;
    
    assign states[2:0] = state;
    assign states[5:3] = magstate;

    

    assign swac = (swa && !swab) ?1'b1:1'b0; //is high for one tick after switch goes high
    assign swbc = (swb && !swbb) ?1'b1:1'b0;

    

        Directional_Control CarriageMotor( //instantiates motor control and converts brake and one bit direction to final motor signals
        .direction(direction),
        .brake(brake),
        .INA(dirl),
        .INB(dirr)
        );
        
        PWM MagPWM( //pwm for magnet
        .clk (clk),
        .ratio(magratio),
        .brake(1'b0),
        .coast(1'b0),
        .sw(magpwm),
        .enable(mag)
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
     else
     begin
     obst <= 1'b0;
     end
     end
     
     3'b001:
     begin
     if(swa) //if carriage hits end of rail
     begin
     magnet <= 1'b0; //turn off magnet
     state <= 3'b010; //move to next state
     end
     else if(swb) //if carriage hits other end of rail
     begin
     magnet <= 1'b0; //turn off magnet
     state <= 3'b011; //move to next state
     end
     end
     
     3'b010:
     begin
     if(ips && count == 22'b0) //if ips is triggered again
     begin
     state <= 3'b000; //restart 
     end
     else if(swb) //else if carriage hits opposite end of rail
     begin
     state <= 3'b100; //move to next state
     end
     end
     
     3'b011:
     begin
     if(ips && count == 22'b0) //if ips is triggered again
     begin
     state <= 3'b000; //restart
     end
     else if(swa) //else if carriage hits opposite end of rail
     begin
     state <= 3'b100; //move to next state
     end
     end
     
     3'b100:
     begin
     obst <= 1'b0; //reset obstacle flag
     state <= 3'b000; //restart
     end
    
    endcase
    end

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
    
    always @(posedge clk) //handles pwm for magnet
    begin
    
    case(magstate)
    
    3'b000:
    begin
    if(magnet) //if magnet is supposed to be on
    begin
    magcnt <= magtime; //load value into counter
    magpwm <= magpick; //set pwm to magpick
    magstate <= 3'b001; //move to next state
    end
    end
    
    3'b001:
    begin
    if(!magnet) //if magnet is supposed to be off
    begin
    magpwm <= 6'b000000; //set pwm to 0
    magstate <= 3'b000; //back to state 0
    end
    else if (magcnt != 25'b0) //if counter isn't done
    begin
    magcnt <= magcnt - 1'b1; //decrement counter
    end
    else
    begin //if counter is 0
    magstate <= 3'b010; //move to next state
    end
    end
    
    3'b010:
    begin
    if(!magnet) //if magnet is supposed to be off
    begin
    magpwm <= 6'b000000; //set pwm to 0
    magstate <= 3'b000; //back to state 0
    end
    else
    begin
    magpwm <= maghold; //set mag pwm to maghold
    end
    end
    
    endcase
    
    end
    

endmodule
