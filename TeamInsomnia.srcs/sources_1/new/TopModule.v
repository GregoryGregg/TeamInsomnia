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
    wire st_in;
    reg st_obst;
    reg st_go;
    reg st_done;
    reg st_dirf;
    reg[2:0] st_dir;
    reg st_brk;
    reg st_brc;
    wire [5:0] DEBUG;
    
    wire us_trig;
    wire us_echo;
    wire[15:0] ss_msg; //wire for the message for the seven seg
    wire[15:0] us_dist; //distance from proximity sensor
    wire[4:0] us_hist;
    reg us_obst;
    reg us_go;
    reg us_done;
    reg us_brk;
    reg[2:0] us_dir;
    reg us_dirf;
    reg us_brc;
    wire us_in; //is there an obstacle detected by the us
    
    wire[2:0] bd_dir;
    wire MICCHECK;
    
    assign ss_msg = us_dist;
//    assign led = us_hist;

    assign led[0] = ea;
    assign led[1] = eb;
    assign led[3] = MICCHECK;
    
    reg [2:0]direction;
    wire is_in;
    reg electroMag;
    reg is_obst;
    reg is_go;
    reg is_done;
    reg is_brk;
    
    reg rev_cnt;
    reg rev_dn;
    reg[26:0] rev_con = 27'b101111101011110000100000000; //time to reverse
    
    assign is_in = ~JA1;
    assign JA3 = us_trig;
    assign us_echo = JA4;
    assign JA2 = electroMag;
    
     seven_seg Useven_seg( //instantiate the seven seg display
        .clk (clk),
        .msg (ss_msg),
        .an  (an),
        .seg (seg)
     );
     
     ultrasonic_proximity Uultrasonic_proximity( //instantiate the ultrasonic sensor
        .clk     (clk),
        .echo    (us_echo),
        .trigger (us_trig),
        .dist    (us_dist),
        .obst    (us_in),
        .us_hist (us_hist)
      );
      
     Beacon_Module Directions(
        .clk(clk),
        .micLeft(JC2),
        .micRight(JC1),
        .direction(bd_dir),
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
     
     
     
       always @(posedge clk) //state machine
       begin
       
       if(is_in && is_done) //if inductance sensor found something and the submodule isn't running
       begin
       
       is_obst <= 1'b1; //set inductance obstacle flag
       is_go <= 1'b1; //trigger inductance submodule
       end
       
       else if (us_in && us_done) //if ultrasonic sensor found something and the submodule isn't running
       begin
       
       us_obst <= 1'b1; //set ultrasonic obstacle flag
       us_go <= 1'b1; //triggers inductance submodule
       
       end
       
       else if (st_in && st_done) //if the stall detect is triggered and the submodule isn't running
       begin
       
       st_obst <= 1'b1; //set stall flag
       st_go <= 1'b1; //triggers stall submodule
       
       end
       
       //everything below here happens one clktick after everything above it, this creates a 1 tick go pulse
       
       else if(is_go) //if inductnace submodule has been triggered
       begin
       
       is_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end
       
       else if(us_go) //if ultrasonic submodule has been triggered
       begin
       
       us_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end
       
       else if(st_go) //if stall submodule has been triggered
       begin
       
       st_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end
       
       //again everything below here happens one clktick after the above block, now the machine waits for the done signal from the submodules
       
       else if(is_done) //if inductance submodule is done
       begin
       
       is_obst <= 1'b0; //clear inductance obstacle flag
       
       end
       
       else if(us_done) //if ultrasonic submodule is done
       begin
       
       us_obst <= 1'b0; //clear ultrasonic obstacle flag
       
       end
       
       else if(st_done) //if stall submodule is done
       begin
       
       st_obst <= 1'b0; //clear stall flag
       
       end
       
       end
       
       always @(posedge clk) //direction submodule
       begin
       
       if(us_dirf) //if ultrasonic submodule is overriding direction
       begin
       
       direction <= us_dir; //set rover direciton to ultrasonic direction
       
       end
       
       else if(st_dirf) //if stall submodule is overriding direction
       begin
       
       direction <= st_dir; //set rover direction to stall direction
       
       end
       
       else //if no submodule is overriding direction
       begin
       
       direction <= bd_dir; //set rover direction to beacon direction
       
       end
       
       end 
       
       always @(posedge clk) //brake submodule
       begin
       
       if(is_brk || us_brk || st_brk) //if any submodule sets the brake
       begin
       
       brake <= 1'b1; //set the brake
       
       end
       
       else //if nothing is setting the brake
       begin
       
       brake <= 1'b0; //turn off the brake
       
       end
       
       end
       
       always @(posedge clk) //reverse submodule
       begin
       
       if(us_brc || st_brc) //if told to count by either submodule
       begin
         
       if(rev_dn)
       begin
       rev_dn <= 1'b0; //restart counter
       rev_cnt <= rev_con; //load constant into counter
       end
       
       rev_cnt <= rev_cnt - 1'b1;
       
       if(rev_cnt == 0)
       rev_dn <= 1'b1;
       end
       
       end
       
       
//      always @(posedge clk) //inductance submodule
//      begin
      
//      if(is_go) //if the module is supposed to be running
//      begin
      
//      is_done <= 1'b0; //set done to 0 and run the module
      
//      end
      
//      if(is_go || ~is_done)
//      begin
      
//      is_brk <= 1'b1;
      
      always @(posedge clk) //ultrasonic submodule
      begin
      
      if(us_go) //if the module is supposed to be running
      begin
      
      us_done <= 1'b0; //set done to 0 and run the module
      
      end
      
      if(us_go || ~us_done) //run the module
      begin
      
      us_brk <= 1'b1; //turn on the brake
      us_brc <= 1'b1;
      
      
       
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
