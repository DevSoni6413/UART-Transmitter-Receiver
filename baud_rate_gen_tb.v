module baud_rate_gen_tb;
parameter divisor =4;
reg clk, rst;
wire baud_tick;

baud_rate_gen #(.divisor(divisor)) uut(.clk(clk), .rst(rst), .baud_tick(baud_tick));

initial clk = 0; // clk starts at 0
always #5 clk = ~clk;
initial begin
        $monitor($time, "   clk = %d, rst = %d, baud_tick = %d", clk, rst, baud_tick);
end
initial begin
    rst = 1;
    #10;
    rst = 0;
   #190;
   $finish;
end
endmodule 