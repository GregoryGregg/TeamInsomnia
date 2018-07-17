`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Name: Justin Schwausch
// Class: ECE 3331
// Project: Ultrasonic Sensor
// Target: Basys 3 Board
// Last Modified: 7/15/2018
//
// This program takes makes use of the HC-SR04 to detect proximity.
//
// The relative distance is displayed on the four seven segment displays on the Basys board
//  and on the 16 LEDs on the board.
//
// The 5v vcc power for the sensor is grabbed from the 5v line on the usb port on the basys board.
//
// The echo pin is brought down from 5v using a voltage divider. In this case R1 is 57 ohms and R2 is 
//////////////////////////////////////////////////////////////////////////////////



module ultrasonic_proximity(

input clk, //main clock
input echo, // echo pin
output trigger, //trigger pin
output dist, //distance from object
output outup //output update flag
    );
    
    reg counten; //count enable reg
    reg countint; //internal reg to represent input
    reg outen; //out enable reg
    reg outupreg;
    reg[21:0] count; //count reg
    reg[15:0] countf; //stores the 16 most significant bits of count
    reg[9:0] outcnt; //counts out trigger pulse
    reg[25:0] delcnt = 24'b0; //counts delay between measurements
    wire outtogg;

    assign trigger = outen; //assign trigger output
    assign dist = countf; //assign output distance
    assign outtogg = (delcnt == 24'b0) ?1'b1:1'b0; //begin trigger pulse
    assign ouup = outupreg;
    
    
    always @(posedge clk)
    begin
    
    if(outcnt != 10'b0000000000) //if already counting
    begin
    outcnt = outcnt + 1'b1; //continue counting
    end
    
    else if(outtogg == 1'b1) //if supposed to be counting
    begin
    outcnt = 1'b1; //start counting
    outen = 1'b1; //trigger posedge
    end
    
    if(outcnt == 10'b1111101000) //if trigger on for 10 microseconds
    begin
    outcnt = 10'b0000000000; //reset count
    outen = 1'b0; //trigger negedge
    end
    
    delcnt <= delcnt + 1'b1; //up delay count
    
    end
    
    
    always @(posedge clk) //take in value of JA1 to mitigate metastability
    begin
    countint <= echo;
    end

    always @(posedge clk)
    begin
    
    if (outupreg == 1'b1)
    begin
        outupreg <= 1'b0; //reset output update flag
    end
    
    if (countint) //if echo detected
    begin
        count <= count + 1; //count echo pulse width
    end
    
    else if(count != 22'b0) //if count isn't 0
    begin
    
        countf <= count[21:6]; //load 16 most sig bits into countf
        outupreg <= 1'b1; //set output update flag
        count <= 22'b0; //reset count
    end

  end
        
endmodule
