module uart_topblock(clk, reset, tx_start, tx_data, rx_data, tx_done, rx_done);
parameter clk_bits = 64; // for transmitter using 64 , for receiver using 4
input clk, reset, tx_start; // tx start because to start the transmitter on low signal
input [7:0] tx_data; // data on transmitter side
output tx_done, rx_done; // telling us when data transmition and receiving is done
output [7:0] rx_data;
wire tx_tick, rx_tick, serial_line;

// instantiating for transmitter baud rate
baud_rate_gen #(.divisor(clk_bits)) tx_baud(.clk(clk), .rst(reset), .baud_tick(tx_tick));

// instantiating for receiver baud rate
baud_rate_gen #(.divisor(clk_bits/16)) rx_baud(.clk(clk), .rst(reset), .baud_tick(rx_tick));

// instantiating transmitter
transmitter tx_inst(.clk(clk), .reset(reset), .tx_start(tx_start), .data(tx_data), .baud_tick(tx_tick), .done(tx_done), .tx_serial_out(serial_line));

// instantiating receiver
receiver rx_inst(.clk(clk), .reset(reset), .data_out(rx_data), .done(rx_done), .baud_tick(rx_tick), .rx(serial_line));
endmodule