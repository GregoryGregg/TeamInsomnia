`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Name: Justin Schwausch
// Class: ECE 3331
// Project: Seven Segment Display
// Target: Basys 3 Board
// Last Modified: 6/30/2018
//
// Based on Code From: Noah Pratt
//
// This program takes is used to operate the four seven segment displays on the Basys 3 board.
// It takes in a 16-Bit binary value, converts it to hexadecimal, and displays those digits on
//  the display.
//
// clk is the main clock
// msg is the 16-Bit message
// output is the anode that selects the digit
// seg is which segments are lit on the selected digit
//
// Example Instantiation:
//
// seven_seg Useven_seg(
//  .clk (clk),
//  .msg  (countf),
//  .an  (an),
//  .seg (seg)
// );
//////////////////////////////////////////////////////////////////////////////////



module seven_seg(
    input clk,
    input [15:0] msg,
    output [3:0] an,
    output [6:0] seg
    );
    localparam N = 18;
    reg [7:0] sseg_deco; //used in decoding to hex
    reg [15:0]sseg; //the 7 bit register to hold the data to output
    reg [3:0]anint; //register for the 4 bit enable
    reg [N-1:0]count; //multiplexer reg
    reg [26:0] count1 = 27'b0;
    reg toggle = 1'b0;
    
    assign seg = sseg_deco;
    assign an = anint;
       
    always @ (posedge clk)
     begin
        begin
        count <= count + 1;
        end
     end
     
     
    always @ (*)
     begin
      case(count[N-1:N-2]) //using only the 2 MSB's of the counter 
        
       2'b00 :  //When the 2 MSB's are 00 enable the fourth display
        begin
         sseg = msg[3:0];
         anint = 4'b1110;
        end
       2'b01:  //When the 2 MSB's are 01 enable the third display
        begin
         sseg = msg[7:4];
         anint = 4'b1101;
        end
       2'b10: //enable the second display
       begin
        sseg = msg[11:8];
        anint = 4'b1011;
       end
       2'b11: //enable the first display
       begin
        sseg = msg[15:12];
        anint = 4'b0111;
       end
       endcase
     end
    
   always @ (*)
    begin
     case(sseg)
      4'b0000 : sseg_deco = 7'b1000000; //to display 0
      4'b0001 : sseg_deco = 7'b1111001; //to display 1
      4'b0010 : sseg_deco = 7'b0100100; //to display 2
      4'b0011 : sseg_deco = 7'b0110000; //to display 3
      4'b0100 : sseg_deco = 7'b0011001; //to display 4
      4'b0101 : sseg_deco = 7'b0010010; //to display 5
      4'b0110 : sseg_deco = 7'b0000010; //to display 6
      4'b0111 : sseg_deco = 7'b1111000; //to display 7
      4'b1000 : sseg_deco = 7'b0000000; //to display 8
      4'b1001 : sseg_deco = 7'b0010000; //to display 9
      4'b1010 : sseg_deco = 7'b0001000; //to display A
      4'b1011 : sseg_deco = 7'b0000011; //to display b
      4'b1100 : sseg_deco = 7'b1000110; //to display C
      4'b1101 : sseg_deco = 7'b0100001; //to display d
      4'b1110 : sseg_deco = 7'b0000110; //to display E
      4'b1111 : sseg_deco = 7'b0001110; //to display F
     endcase
    end

        
endmodule
