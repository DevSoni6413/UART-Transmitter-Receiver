module uart_final_tb;
reg clk, reset, tx_start;
reg [7:0] tx_data;
wire tx_done, rx_done;
wire [7:0] rx_data;

integer pass = 0;
integer fail = 0;
integer i=0;

initial clk = 0;
initial begin
    forever begin
    #5 clk = ~clk;
end
end

// dut for uart final block
uart_topblock uut(.clk(clk),
.reset(reset), 
.tx_data(tx_data), 
.rx_data(rx_data),
.tx_done(tx_done),
.rx_done(rx_done), .tx_start(tx_start));

// sending byte in transmitte
task sending_byte(input [7:0] byte);
begin
    tx_data = byte; // assigning the input to tx data
    repeat(1) @(posedge clk);
    tx_start=1;
    repeat(1) @(posedge clk);
    tx_start=0;
    wait (rx_done==1) // until this is 1 transmition happens
    repeat(5) @(posedge clk);
end
endtask

// checking if rx data is equal to tx data
always@(posedge clk)begin
    if(rx_done)begin
        if(rx_data == tx_data)begin
            pass+=1;
            $display("PASS !!!");
        end
        else begin
            fail+=1;
            $display("FAIL !!!");
            $display("FAIL : got : %h, expected : %h at time : %0t", rx_data, tx_data, $time);
        end
    end

end

initial begin
    $dumpfile("uart_final_tb.vcd");
    $dumpvars(0, uart_final_tb);

    tx_start = 0; tx_data = 0;
    reset=1;
    repeat(5) @(posedge clk);
    reset = 0;

    repeat(100) @(posedge clk);

    for(i=0; i<256; i=i+1)begin
        sending_byte(i);
    end

    $display("PASS values : %d", pass);
    $display("FAIL values : %d", fail);
    $finish;
end

endmodule