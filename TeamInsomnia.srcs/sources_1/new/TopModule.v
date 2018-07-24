`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2018 01:07:31 PM
// Design Name: 
// Module Name: TopModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.03 - added ultrasonic and io (Justin)
// Additional Comments: More info in ultrasonic_proximity.v
// 
//
// PMOD Assignments:
// JA[1]:  Inductance Sensor
// JA[2]:  Electromagnet enable
// JA[3]:  Ultrasonic Trigger
// JA[4]:  Ultrasonic Echo
// JA[7]:
// JA[8]:
// JA[9]:
// JA[10]:
//
// JB[1]:  ENA
// JB[2]:  IN1
// JB[3]:  IN2
// JB[4]:  ea
// JB[7]:  ENB
// JB[8]:  IN3
// JB[9]:  IN4
// JB[10]: eb
//
// JC[1]:
// JC[2]:
// JC[3]:
// JC[4]:
// JC[7]:
// JC[8]:
// JC[9]:
// JC[10]:
//
// JXADC[1]:
// JXADC[2]:
// JXADC[3]:
// JXADC[4]:
// JXADC[7]:
// JXADC[8]:
// JXADC[9]:
// JXADC[10]:
//////////////////////////////////////////////////////////////////////////////////


module TopModule(
    input clk,
    input [5:0]sw, // Speed for the motor control module set by the switches, to be removed
    input coast, // to be removed as with brake
    input ea, // input from the encoder of motor a
    input eb, // input from the encoder of motor b
    input JC1,
    input JC2,
    input JA1, //inductance input
    input JA4, //echo from ultrasonic
    input signed [8:0]Adjust,
    output JA2, //electromagnet enable
    output JA3, //ultrasonic trigger
    output[3:0] an, //anode for seven seg
    output[6:0] seg, //segment for seven seg
    output IN1, // All that follow are motor outputs and shouldn't be moved
    output IN2, 
    output IN3,
    output IN4,
    output ENA,
    output ENB,
    output[0:9] led
);

    reg brake; //stops the rover
    wire [5:0] DEBUG;
    
    wire us_trig;
    wire us_echo;
    wire[15:0] ss_msg; //wire for the message for the seven seg
    wire[15:0] us_dist; //distance from proximity sensor
    wire[4:0] us_hist;
    wire us_obst; //is there an obstacle detected by the us
    wire MICCHECK;
    
    assign ss_msg = us_dist;
//    assign led = us_hist;

    assign led[0] = ea;
    assign led[1] = eb;
    assign led[3] = MICCHECK;
    
    wire [2:0]direction;
    wire is_in;
    reg electroMag;
    wire is_obst;
    
    assign is_obst = ~JA1;
    assign JA3 = us_trig;
    assign us_echo = JA4;
    assign JA2 = electroMag;
    
//     seven_seg Useven_seg( //instantiate the seven seg display
//        .clk (clk),
//        .msg (ss_msg),
//        .an  (an),
//        .seg (seg)
//     );
     
//     ultrasonic_proximity Uultrasonic_proximity( //instantiate the ultrasonic sensor
//        .clk     (clk),
//        .echo    (us_echo),
//        .trigger (us_trig),
//        .dist    (us_dist),
//        .obst    (us_obst),
//        .us_hist (us_hist)
//      );
      
     Beacon_Module Directions(
        .clk(clk),
        .micLeft(JC2),
        .micRight(JC1),
        .direction(direction),
        .MICCHECK(MICCHECK)
     );
      
      // Motor control instantiaiton, Keep this at the bottom
      Motor_Control Surface (
        .Direction(direction),
        .clk(clk),
        .sw(sw),    // to be removed 
        .Adjust(Adjust),
        .brake(brake),
        .coast(coast),
        .ea(ea),
        .eb(eb),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4),
        .ENA(ENA),
        .ENB(ENB),
        .DEBUG(DEBUG)
     );
     
     
//     always @(posedge clk)
//     begin
     
//     if(is_in)
//     begin
//     electroMag <= 1'b1;
//     end else if(~is_in)
//     begin
//     electroMag <= 1'b0;
//     end
     
     
//     if(us_obst || is_obst)
//     begin
//     brake <= 1'b1;
//     end
     
//     else
//     begin
//     brake <= 1'b0;
//     end
     
//     end
            
    
endmodule
