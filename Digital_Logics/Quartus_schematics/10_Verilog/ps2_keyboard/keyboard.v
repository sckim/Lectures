`timescale 1ns / 1ns
/***************************************
 May 31, Tuesday
 Currently it only contains code to detect a byte of data from keyboard
 
 June 5, Sunday, 2011
 data_reg holds the data sent by the keyboard
 disp_cur_key and disp_prev_key are the buffer registers for the display unit
 seven_disp contains the actual signals to be sent to the LEDs
 seven_data contains the hexit that should be displayed on a 7-segment
 anod_con determines which 7 segment is enabled
***************************************/ 

module ps2_keyboard(clk, data, seven_disp, anode_con);
input clk, data;
output [7:0] seven_disp;
output [3:0] anode_con;

wire clk, data;
reg[7:0] data_reg, disp_cur_key, disp_prev_key, seven_disp;
reg[3:0] bit_count, seven_data, anode_con;
reg[2:0] data_reg_index;
reg ps2_data_capture_completed;

initial
begin
	data_reg = 0;
	bit_count = 1;
	ps2_data_capture_completed = 1;
	data_reg_index = 3'b000;
	disp_cur_key = 8'hF0;
	disp_prev_key = 8'hF0;
end

always@(negedge clk)
begin
	if(bit_count == 1) 				// ignore the start bit (always logic low, by PS2 protocol)
	begin
		data_reg <= data_reg;
		bit_count <= bit_count + 1;
	end
	
	else if(bit_count > 1 && bit_count < 10)		// store the next 8 bits in data_reg, keyboard sends the data LSB first
	begin
//		data_reg = data_reg << 1;
		data_reg[data_reg_index] = data;
//		data_reg <= data_reg + data;
		bit_count <= bit_count + 1;
		data_reg_index <= data_reg_index + 1;
	end
	
	else if(bit_count == 10 || bit_count == 11)			// ignore the last two bits (parity (odd) and stop bit (always High)
	begin
		data_reg <= data_reg;
		bit_count <= bit_count + 1;
	end
	
	if(bit_count == 11)	ps2_data_capture_completed = 0;	// give a signal that the 8 bits of data from the total 11 sent from the keyboard have been captured
end


always @(negedge ps2_data_capture_completed)
begin
	if (data_reg == 8'hF0)
	begin
		ps2_data_capture_completed = 1;
		$exit;
	end
	else
	begin	
		disp_prev_key = disp_cur_key;
		disp_cur_key = data_reg;
		ps2_data_capture_completed = 1;
	end
end

always@(disp_prev_key or disp_cur_key)
begin
	seven_data <= disp_prev_key[7:4]; anode_con <= 4'h7;
	seven_data <= disp_prev_key[3:0]; anode_con <= 4'hb; 
	seven_data <= disp_cur_key[7:4]; anode_con <= 4'hd; 
	seven_data <= disp_cur_key[3:0]; anode_con <= 4'he; 
end
	
always @(seven_data)
	case(seven_data)
		4'h0:seven_disp <= 8'h03;
		4'h1:seven_disp <= 8'h9F;
		4'h2:seven_disp <= 8'h25;
		4'h3:seven_disp <= 8'h0D;
		4'h4:seven_disp <= 8'h99;
		4'h5:seven_disp <= 8'h49;
		4'h6:seven_disp <= 8'h41;
		4'h7:seven_disp <= 8'h1F;
		4'h8:seven_disp <= 8'h01;
		4'h9:seven_disp <= 8'h09;
		4'ha:seven_disp <= 8'h11;
		4'hb:seven_disp <= 8'hc1;
		4'hc:seven_disp <= 8'h63;
		4'hd:seven_disp <= 8'h85;
		4'he:seven_disp <= 8'h61;
		4'hf:seven_disp <= 8'h71;
endcase
	
endmodule
	
