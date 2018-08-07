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
// JAO[7]:  Ultrasonic Trigger
// JAO[8]:  Electromagnet Enable
// JAO[9]:  Carriage Direction A
// JAO[10]: Carriage Direction B
//
// JB[1]: Beacon Input L
// JB[2]: Beacon Input R
// JB[3]: Stall Input L
// JB[4]: Stall Input R
// JB[7]:
// JB[8]:
// JB[9]:
// JB[10]:
//
// JC[1]:  ENA
// JC[2]:  IN1
// JC[3]:  IN2
// JC[4]:  ea
// JC[7]:  ENB
// JC[8]:  IN3
// JC[9]:  IN4
// JC[10]: eb
//
// JXADC[1]:
// JXADC[2]:
// JXADC[3]:
// JXADC[4]:
// JXADC[7]:
// JXADC[8]:
// JXADC[9]:
// JXADC[10]:
//
// sw[0]: Rover Speed Control
// sw[1]: Rover Speed Control
// sw[2]: Rover Speed Control
// sw[3]: Rover Speed Control
// sw[4]: Rover Speed Control
// sw[5]: Rover Speed Control
// sw[6]: Rover Brake
// sw[7]: Carriage Brake
// sw[8]:
// sw[9]:
// sw[10]:
// sw[11]:
// sw[12]:
// sw[13]:
// sw[14]:
// sw[15]: 
//////////////////////////////////////////////////////////////////////////////////


module TopModule(
    input clk,
    input[4:1] JAI, //JA pins 1-4
    input [15:0]sw, // switches
    input ea, // input from the encoder of motor a
    input eb, // input from the encoder of motor b
    input[4:1] JB, //JC pins 1-4
    input btnC, forward, back, left, right,
    output[10:7] JAO,
    output[3:0] an, //anode for seven seg
    output[6:0] seg, //segment for seven seg
    output IN1, // All that follow are motor outputs and shouldn't be moved
    output IN2, 
    output IN3,
    output IN4,
    output ENA,
    output ENB,
    output[15:0] led
);

    wire[5:0] ro_speed; //rover speed
    wire ro_coast; //puts the rover in coast
    reg ro_brake; //stops the rover
    reg st_obst = 1'b0;
    reg st_go = 1'b0;
    reg st_done = 1'b1;
    reg st_dirf = 1'b0;
    reg[2:0] st_dir;
    reg[2:0] st_state = 3'b000;
    reg st_brk = 1'b0;
    reg st_brc = 1'b0;
    wire[1:0] st_pins;
    wire st_in;
    wire [5:0] DEBUG;
    
    wire[15:0] ss_msg; //wire for the message for the seven seg
    
    wire us_trig;
    wire us_echo;
    wire[15:0] us_dist; //distance from proximity sensor
    wire[4:0] us_hist;
    reg[2:0] us_state = 3'b000;
    reg us_obst = 1'b0;
    reg us_go = 1'b0;
    reg us_done = 1'b1;
    reg us_brk = 1'b0;
    reg[2:0] us_dir;
    reg us_dirf;
    reg us_brc;
    wire us_in; //is there an obstacle detected by the us
    
    wire[2:0] bd_dir;
    wire bd_left;
    wire bd_right;
    wire MICCHECK;
    
 //   assign ss_msg = us_dist;
//    assign led = us_hist;

//    assign led[0] = ea;
//    assign led[1] = eb;
//    assign led[3] = MICCHECK;
    
    reg [2:0]direction = 3'b000;
    
    wire is_brk;
    wire is_in;
    wire is_mag;
    wire is_brake;    
    wire[1:0] is_sw;
    wire is_dirl;
    wire is_dirr;
    wire[11:0] is_led;
    wire[5:0] is_states;
    
    reg[2:0] brk_state = 3'b000; //brake state
    reg[27:0] brk_cnt; //brake counter
    reg brk_dn = 1'b1; //brake done
    reg[27:0] brk_con = 28'b1011111010111100001000000000; //time to break
    
    reg[2:0] rev_state = 3'b000; //reverse state
    reg[27:0] rev_cnt; //reverse counter
    reg rev_dn = 1'b1; //reverse done
    reg[27:0] rev_con = 28'b10111110101111000010000000; //time to reverse
    
    reg[2:0] tur_state = 3'b000; //turn state
    reg[27:0] tur_cnt; //turn counter
    reg tur_dn = 1'b1; //turn done
    reg[27:0] tur_con = 28'b1011111010111100001000000000; //time to turn
    
    assign is_in = ~JAI[1]; //assigns JA pmod port to internal names
    assign is_sw[0] = (JAI[2]);
    assign is_sw[1] = (JAI[3]);
    assign us_echo = JAI[4];
    assign JAO[7] = us_trig;
    assign JAO[8] = is_mag;
    assign JAO[9] = is_dirl;
    assign JAO[10] = is_dirr; 
    
    assign ro_speed = sw[5:0];
    assign ro_coast = sw[6];
    assign is_brake = sw[7];
    
    assign ss_msg[3:0] = us_state;
    assign ss_msg[7:4] = st_state;
//    assign ss_msg[7:4] = rev_state;
//    assign ss_msg[11:8] = tur_state;
    assign ss_msg[15:12] = direction;
    assign ss_msg[11:8] = is_states[2:0];
//      assign ss_msg[7:4] = is_states[5:3];
    
    assign bd_right = JB[1];
    assign bd_left = JB[2];
    assign st_pins[0] = JB[3];
    assign st_pins[1] = JB[4];
    
    assign led[0] = rev_dn;
    assign led[1] = tur_dn;
    assign led[2] = st_in;
    assign led[3] = st_done;
    assign led[4] = us_in;
    assign led[5] = us_done;
    assign led[6] = rev_dn;
    assign led[7] = tur_dn;
    assign led[8] = ro_brake;
    assign led[9] = ro_coast;
    assign led[10] = is_brake;
    assign led[11] = st_pins[0];
    assign led[12] = st_pins[1];
    assign led[13] = bd_dir[2];
    assign led[14] = bd_dir[1];
    assign led[15] = bd_dir[0];
    
//      assign led[11:0] = is_led;
    
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
        .brake (is_brake),
        .dirl  (is_dirl),
        .dirr  (is_dirr),
        .mag   (is_mag),
        .mine  (is_brk),
        .LED   (is_led),
        .states(is_states)
        );
      
//     Beacon_Module Directions( //instantiate the beacon detector module
//        .clk(clk),
//        .micLeft(bd_left),
//        .micRight(bd_right),
//        .direction(bd_dir),
//        .MICCHECK(MICCHECK)
//     );
      
//       Motor control instantiaiton, Keep this at the bottom
      Motor_Control Surface (
        .Direction(direction),
        .clk(clk),
        .sw(ro_speed),    // to be removed 
        .st_pins(st_pins),
        .st_in(st_in),
        .brake(ro_brake),
        .coast(ro_coast),
        .ea(ea),
        .eb(eb),
        .IN1(IN1),
        .IN2(IN2),
        .IN3(IN3),
        .IN4(IN4),
        .ENA(ENA),
        .ENB(ENB)
//        .DEBUG(DEBUG)
     );
     
     
     //***************************************************State Machine****************************************************************//
       always @(posedge clk) 
       begin
     //***************************************************Check Conditions************************************************************//
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
     //***************************************************Check Conditions*************************************************************//
     //***************************************************Reset Go Statements**********************************************************//   
       
       //everything below here happens one clktick after everything above it, this creates a 1 tick go pulse
             
       if(st_go) //if stall submodule has been triggered
       begin
       
       st_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end      
       
       if(us_go) //if ultrasonic submodule has been triggered
       begin
       
       us_go <= 1'b0; //set to 0, this produces a 1 tick go pulse
       
       end
     //**************************************************Reset Go Statements***********************************************************//
     //**************************************************Reset Done Statements*********************************************************//
     
       //again everything below here happens one clktick after the above block, now the machine waits for the done signal from the submodules
       
       if(st_done) //if stall submodule is done
       begin
       
       st_obst <= 1'b0; //clear stall flag
       
       end       
       
       if(us_done) //if ultrasonic submodule is done
       begin
       
       us_obst <= 1'b0; //clear ultrasonic obstacle flag
       
       end
       end
      
       end
    
    //*************************************************Reset Done Statements*********************************************************//
    
    //*************************************************Direction Flags***************************************************************//   
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
    //****************************************************Direction Flags***********************************************************//
    //****************************************************Brake Controls************************************************************//   
       always @(posedge clk) //brake submodule
       begin
       
       if(us_brk || st_brk || is_brk) //if any submodule sets the brake
       begin
       
       ro_brake <= 1'b1; //set the brake
       
       end
       
       else //if nothing is setting the brake
       begin
       
       ro_brake <= 1'b0; //turn off the brake
       
       end
       
       end
     //**************************************************Brake Controls************************************************************//  
     //**************************************************Brake Delay**********************************************************//  
            
            always @(posedge clk) //reverse submodule
            begin
            
            case(brk_state)
             3'b000:
             begin
             if(us_state == 3'b001 || st_state == 3'b001) //if told to count by either submodule
             begin
             
             brk_dn <= 1'b0;
             brk_state <= 3'b001;
             
             end
             
             end
             
             3'b001:
             begin
             brk_cnt <= rev_con;
             brk_state <= 3'b010;
             end
             
             3'b010:
             begin
            
             brk_cnt <= brk_cnt - 1'b1; //decrement counter
            
             if(brk_cnt == 0) //if done counting
             begin
             brk_state <= 3'b011; //set to done
             end
             end
             
             3'b011:
             begin
             brk_dn <= 1'b1;
             brk_state <= 3'b000;
             end
            
            endcase
            end
     //***************************************************Brake Delay**********************************************************// 
     //**************************************************Reverse Delay**********************************************************//  
       
       always @(posedge clk) //reverse submodule
       begin
       
       case(rev_state)
        3'b000:
        begin
        if(us_state == 3'b001 || st_state == 3'b010) //if told to count by either submodule
        begin
        
        rev_dn <= 1'b0;
        rev_state <= 3'b001;
        
        end
        
        end
        
        3'b001:
        begin
        rev_cnt <= rev_con;
        rev_state <= 3'b010;
        end
        
        3'b010:
        begin
       
        rev_cnt <= rev_cnt - 1'b1; //decrement counter
       
        if(rev_cnt == 0) //if done counting
        begin
        rev_state <= 3'b011; //set to done
        end
        end
        
        3'b011:
        begin
        rev_dn <= 1'b1;
        rev_state <= 3'b000;
        end
       
       endcase
       end
     //**************************************************Reverse Delay**********************************************************// 
     //***************************************************Turn Delay***********************************************************//
           always @(posedge clk) //turn submodule
           begin
           
           case(tur_state)
            3'b000:
             begin
             if(us_state == 3'b010 || st_state == 3'b011) //if told to count by either submodule
             begin
           
             tur_dn <= 1'b0;
             tur_state <= 3'b001;
           
             end
             end
            
            3'b001:
            begin
            tur_cnt <= rev_con;
            tur_state <= 3'b010;
            end
            
            3'b010:
            begin
           
            tur_cnt <= tur_cnt - 1'b1; //decrement counter
           
            if(tur_cnt == 0) //if done counting
            begin
            tur_state <= 3'b011; //set to done
            end
            end
            
            3'b011:
            begin
            tur_dn <= 1'b1;
            tur_state <= 3'b000;
            end
           
           endcase
           end
     //*************************************************Turn Delay*************************************************************// 
     //*************************************************Ultrasonic Submodule*******************************************************//
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
            if(!us_dirf)
            begin
            us_dirf <= 1'b1; //assert direction control
            us_dir <= 3'b100; //set direction to reverse
            end
            else if(rev_dn) //if reverse submodule is done
            begin
            us_dirf <= 1'b0; //release direction control
            us_dir <= 3'b000; //set direction to  forward
            us_state <= 3'b010; //change to next state
            end
            end
            
        3'b010: //done reversing, start turning
            begin
            if(!us_dirf)
            begin
            us_dirf <= 1'b1; //assert direction control
            us_dir <= 3'b010; //set direction to right
            end
            else if(tur_dn) //if turning is done
            begin
            us_dirf <= 1'b0; //stop direction control
            us_dir <= 3'b000; //set direction back to forward
            us_state <= 3'b011; //change to next state
            end
            end
         
        3'b011: //stop turning be done
            begin
            us_done <= 1'b1; //set done to true
            us_state <= 3'b000; //reset state
            end
            
        default: //if none of the other states are reached
            begin
            us_brk <= 1'b0; //stop the rover
            end
        
        endcase
        
        end
        
     //*********************************************End UltraSonic Submodule**********************************************************//
     //*********************************************Start Stall Submodule*************************************************************//
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
               
               3'b001: //running, brake
                   begin
                   if(!st_brk)
                   begin
                   st_brk <= 1'b1; //set brake to high
                   end
                   else if(brk_dn) //when done braking
                   begin
                   st_brk <= 1'b0; //set brake to low
                   st_state <= 3'b010; //change to next state
                   end
                   end
                
                   
               3'b010: //reverse
                   begin
                   if(!st_dirf)
                   begin
                   st_dirf <= 1'b1; //assert direction control
                   st_dir <= 3'b100; //set direction to reverse
                   end
                   else if(rev_dn) //if reverse submodule is done
                   begin
                   st_dirf <= 1'b0; //release direction control
                   st_dir <= 3'b000; //set direction back to forward
                   st_state <= 3'b011; //change to next state
                   end
                   end
                   
               3'b011: //done reversing, start turning
                   begin
                   if(!st_dirf)
                   begin
                   st_dirf <= 1'b1; //assert direction control
                   st_dir <= 3'b010; //set direction to right
                   end
                   else if(tur_dn) //if turning is done
                   begin
                   st_dirf <= 1'b0; //release direction control
                   st_dir <= 3'b000; //set direction back to forward
                   st_state <= 3'b100; //change to next state
                   end
                   end
                
               3'b100: //stop turning be done
                   begin
                   st_done <= 1'b1; //set done to true
                   st_state <= 3'b000; //reset state
                   end
                   
               default: //if none of the other states are reached
                   begin
                   st_brk <= 1'b0; //stop the rover
                   end
               
               endcase
               
               end
      //*****************************************************End Stall Submodule******************************************//
       

            
    
endmodule
