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
// JAI[1]:  Inductance Sensor
// JAI[2]:  Carriage Switch A
// JAI[3]:  Carriage Switch B
// JAI[4]:  Ultrasonic Echo
// JAO[7]:  Electromagnet Enable
// JAO[8]:  Carriage Direction A
// JAO[9]:  Carriage Direction B
// JAO[10]: Ultrasonic Trigger
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
    input[1:4] JAI, //JA pins 1-4
    input [5:0]sw, // Speed for the motor control module set by the switches, to be removed
    input coast, // to be removed as with brake
    input ea, // input from the encoder of motor a
    input eb, // input from the encoder of motor b
    input JC1,
    input JC2,
    input signed [8:0]Adjust,
    output[10:7] JAO,
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
    reg[2:0] st_state = 3'b000;
    reg st_brk;
    reg st_brc;
    wire [5:0] DEBUG;
    
    wire[15:0] ss_msg; //wire for the message for the seven seg
    
    wire us_trig;
    wire us_echo;
    wire[15:0] us_dist; //distance from proximity sensor
    wire[4:0] us_hist;
    reg[2:0] us_state = 3'b000;
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
    
    wire is_brk;
    wire is_in;
    wire is_mag;
    reg is_st;    
    wire[1:0] is_sw;
    wire[1:0] is_dir;
    wire[11:0] is_led;

    
    reg rev_cnt; //reverse counter
    reg rev_dn; //reverse done
    reg[26:0] rev_con = 27'b101111101011110000100000000; //time to reverse
    
    reg tur_cnt; //turn counter
    reg tur_dn; //turn done
    reg[25:0] tur_con = 26'b10111110101111000010000000; //time to turn
    
    assign is_in = ~JAI[1]; //assigns JA pmod port to internal names
    assign is_sw[0] = JAI[2];
    assign is_sw[1] = JAI[3];
    assign us_echo = JAI[4];
    assign JAO[7] = is_mag;
    assign JAO[8] = is_dir[0];
    assign JAO[9] = is_dir[1];
    assign JAO[10] = us_trig;

    
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
     
     carriage Ucarriage( //instantiate the carriage module
        .clk   (clk),
        .ips   (is_in),
        .sw    (is_sw),
        .brake (is_st),
        .dir   (is_dir),
        .mag   (is_mag),
        .mine  (is_brk),
        .LED   (is_led)
        );
      
     Beacon_Module Directions( //instantiate the beacon detector module
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
       
       if(!is_brk) //if inductance sensor found something and the submodule isn't running
       begin
       
       if (st_in && st_done) //if the stall detect is triggered and the submodule isn't running
       begin
       
       st_obst <= 1'b1; //set stall flag
       st_go <= 1'b1; //triggers stall submodule
       
       end       
       
       else if (us_in && us_done) //if ultrasonic sensor found something and the submodule isn't running
       begin
       
       us_obst <= 1'b1; //set ultrasonic obstacle flag
       us_go <= 1'b1; //triggers inductance submodule
       
       end
        
       //everything below here happens one clktick after everything above it, this creates a 1 tick go pulse
      
       else if(st_go) //if stall submodule has been triggered
       begin
       
       st_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end      
       
       else if(us_go) //if ultrasonic submodule has been triggered
       begin
       
       us_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end
      
       //again everything below here happens one clktick after the above block, now the machine waits for the done signal from the submodules
       
       else if(st_done) //if stall submodule is done
       begin
       
       st_obst <= 1'b0; //clear stall flag
       
       end       
       
       else if(us_done) //if ultrasonic submodule is done
       begin
       
       us_obst <= 1'b0; //clear ultrasonic obstacle flag
       
       end
       end
       
       end
       
       always @(posedge clk) //direction submodule
       begin
       
       if(st_dirf) //if ultrasonic submodule is overriding direction
       begin
       
       direction <= st_dir; //set rover direciton to ultrasonic direction
       
       end
       
       else if(us_dirf) //if stall submodule is overriding direction
       begin
       
       direction <= us_dir; //set rover direction to stall direction
       
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
       
       is_st <= 1'b1; //stop the carriage
       brake <= 1'b1; //set the brake
       
       end
       
       else //if nothing is setting the brake
       begin
       
       is_st <= 1'b0; //start the carriage
       brake <= 1'b0; //turn off the brake
       
       end
       
       end
       
       always @(posedge clk) //reverse submodule
       begin
       
       if(us_state == 3'b001 || st_state == 3'b001) //if told to count by either submodule
       begin
         
       if(rev_dn)
       begin
       rev_dn <= 1'b0; //restart counter
       rev_cnt <= rev_con; //load constant into counter
       end
       
       rev_cnt <= rev_cnt - 1'b1; //decrement counter
       
       if(rev_cnt == 0) //if done counting
       begin
       rev_dn <= 1'b1; //set to done
       end
       end
       
       end
       
       always @(posedge clk) //turn submodule
       begin
       
       if(us_state == 3'b010 || st_state == 3'b010) //if either submodule is trying to control direction
       begin
       
       if(tur_dn)
       begin
       tur_dn <= 1'b0; //restart counter
       tur_cnt <= tur_con; //load constant into counter
       end
       
       tur_cnt <= tur_cnt - 1'b1; //decrement counter
       
       if(tur_cnt == 0) //if done counting
       begin
       tur_dn <= 1'b1; //set done flag
       end
       end
       
       end
       
      
      always @(posedge clk) //ultrasonic submodule
      begin
      
      case(us_state)
        3'b000: //not running
            begin
            if(us_go) //if told to go
            begin
            us_done <= 1'b0; //set done to false
            us_state <= 3'b001; //change to next state
            end
            end
            
        3'b001: //running, reverse
            begin
            us_dirf <= 1'b1; //assert direction control
            us_dir <= 3'b100; //set direction to reverse
            if(rev_dn) //if reverse submodule is done
            begin
            us_state <= 3'b010; //change to next state
            end
            end
            
        3'b010: //done reversing, start turning
            begin
            us_dirf <= 1'b1; //assert direction control
            us_dir <= 3'b010; //set direction to right
            if(tur_dn) //if turning is done
            begin
            us_state <= 3'b011; //change to next state
            end
            end
         
        3'b011: //stop turning be done
            begin
            us_dirf <= 1'b0; //stop direction control
            us_dir <= 3'b000; //set direction back to forward
            us_done <= 1'b1; //set done to true
            us_state <= 3'b000; //reset state
            end
            
        default: //if none of the other states are reached
            begin
            us_brk <= 1'b1; //stop the rover
            end
        
        endcase
        
        end
      
       always @(posedge clk) //stall submodule
             begin
             
             case(st_state)
               3'b000: //not running
                   begin
                   if(st_go) //if told to go
                   begin
                   st_done <= 1'b0; //set done to false
                   st_state <= 3'b001; //change to next state
                   end
                   end
                   
               3'b001: //running, reverse
                   begin
                   st_dirf <= 1'b1; //assert direction control
                   st_dir <= 3'b100; //set direction to reverse
                   if(rev_dn) //if reverse submodule is done
                   begin
                   st_state <= 3'b010; //change to next state
                   end
                   end
                   
               3'b010: //done reversing, start turning
                   begin
                   st_dirf <= 1'b1; //assert direction control
                   st_dir <= 3'b010; //set direction to right
                   if(tur_dn) //if turning is done
                   begin
                   st_state <= 3'b011; //change to next state
                   end
                   end
                
               3'b011: //stop turning be done
                   begin
                   st_dirf <= 1'b0; //stop direction control
                   st_dir <= 3'b000; //set direction back to forward
                   st_done <= 1'b1; //set done to true
                   st_state <= 3'b000; //reset state
                   end
                   
               default: //if none of the other states are reached
                   begin
                   st_brk <= 1'b1; //stop the rover
                   end
               
               endcase
               
               end
       

            
    
endmodule
