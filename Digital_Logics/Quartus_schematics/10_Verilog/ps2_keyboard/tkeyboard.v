`timescale 1ns / 1ns
// NC = No Change
module test_keyboard;
	reg clk, data;
	wire [7:0] seven_disp;
	wire [3:0] anode_con;
	reg [10:0] data_reg;
	reg [3:0] data_reg_index;
	ps2_keyboard dut(clk, data, seven_disp, anode_con);
	initial
	begin
		clk = 1;			// 1 beg
		data = 1;			// 1 beg
		data_reg_index = 4'b0000;
		data_reg = 11'b11110101110;
		clk = #20 clk;
		while(data_reg_index <= 4'b1011)
		begin
			if(clk == 1) 
			begin
				data = data_reg[data_reg_index];
				#10 clk = ~clk;
				data_reg_index = data_reg_index + 1;
			end
			else
				#10 clk =~clk;
			
		end
		forever #5 clk = 1;
/*		
		clk = #20 clk;		// 1 end
//		data = #20 data;
		
		data = 0;			// 2 beg
		#10 clk = 0;		// 3 beg, data = 0, NC
		
		#10 clk = 1;		// 4 beg, data = 0, NC
		data = 1;			// 4 beg
		
		#10 clk = 0;		// 5 beg, data = 1 NC
		
		#10 clk = 1; 		// 6 beg
		data = 1;
		
		#10 clk = 0;		// 7 beg, data = 0, NC
		
		#10 clk = 1;		// 8 beg
		data = 1;
		
		#10 clk = 0;		// 9 beg, data = 1, NC
		
		#10 clk = 1;		// 10 beg
		data = 0;
		
		#10 clk = 0;		// 11 beg, data = 0, NC
		
		#10 clk = 1;		// 12 beg
		data = 1;

		#10 clk = 0;		// 13 beg, data = 1, NC
		
		#10 clk = 1;		// 14 beg
		data = 0;

		#10 clk = 0;		// 15 beg, data = 0, NC
		
		#10 clk = 1;		// 16 beg
		data = 1;

		#10 clk = 0;		// 17 beg, data = 1, NC
		
		#10 clk = 1;		// 18 beg
		data = 1;

		#10 clk = 0;		// 19 beg, data = 0, NC
		
		#10 clk = 1;		// 20 beg
		data = 1;			// to make odd  parity (total 1's with parity here is 5)
		
		#10 clk = 0;		// 21 beg, data = 1, NC (this one is the parity one)
		
		#10 clk = 1;		// 22 beg
		data = 1;			// stop bit
		
		#10 clk = 0;		// 23 beg, data = 1, NC (this one is the stop bit)
		
		#10 clk = 1;		// 24 beg

		forever #5 clk = 1;
*/
	end
endmodule

	


		

		
		
		
		
		
				