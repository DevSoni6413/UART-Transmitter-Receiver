module uart_tx_tb;
reg clk, reset, tx_start;
reg [7:0] data; 
wire busy, done, tx_serial_out;

// instantiating baud rate gen.v for baud tick and divisor value
baud_rate_gen #(.divisor(64)) baud_rate_inst(.clk(clk), .rst(reset), .baud_tick(baud_tick));

// instantiating transmitter block
transmitter uut(.clk(clk), .reset(reset), .tx_start(tx_start), .data(data), .baud_tick(baud_tick), .busy(busy), .done(done), .tx_serial_out(tx_serial_out));

initial clk = 0;
always #5 clk = ~clk;
// first reset happens then after some delay tx start is 1 for 1 period cycle = 10 then it is reset means to 0 so that line is idle and then main delay for 1 bit transferred
initial begin
    $monitor($time, " clk = %d, reset = %d, baud tick = %d, tx start = %d, tx serial out = %d, busy = %d, done = %d", clk, reset, baud_tick, tx_start, tx_serial_out, busy, done);

end
initial begin
$dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, uart_tx_tb);
    reset = 1;
    #20;
    reset = 0;
    data = 8'hAB;  // 1 1010 1011 0
    #10;
    tx_start = 1;
    #10;
    tx_start = 0;
    #7500;
    $finish;
end
endmodule