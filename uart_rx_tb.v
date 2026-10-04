module uart_rx_tb;
reg clk, reset, rx;
reg [7:0] value; // expected value
wire busy, done, baud_tick;
wire [7:0] data_out;

// instantiating the baud rate for rx block
baud_rate_gen #(.divisor(4)) baud_rate_instance(.clk(clk), .rst(reset), .baud_tick(baud_tick)); // 1 clock -> 16 ticks for rx, 64/16=4

// instantiating receiver block
receiver uut(.clk(clk), .reset(reset), .rx(rx), .baud_tick(baud_tick), .data_out(data_out), .busy(busy), .done(done));

initial clk = 0;
always #5 clk = ~clk;
integer done_counter = 0;
always @(posedge clk)begin
    if(done)begin
        done_counter = done_counter+1;
    end

end
    
integer i=0;
// checking for the data
task sending_byte(input [7:0] data_in); // declaring input data of 8 bits
begin
    value = data_in; // assigning data to value locally
    rx = 0; // first arrives start bit
    repeat (64) @(posedge clk);
    for(i =0; i<8; i=i+1)begin
        rx = data_in[i]; // for 8 bits of data, using for loop
        repeat (64) @(posedge clk);
    end
    rx = 1; // stop bit
    repeat (64) @(posedge clk); 
end
endtask

// test case for glitch
task glitch_test;
    integer before;
    begin
        before = done_counter;
        rx = 0;
        repeat (16) @(posedge clk);
        rx=1;
        repeat(800) @(posedge clk);
        if(before == done_counter && uut.state==0)begin
            $display("PASS, gltich rejected !");
        end
        else begin
            $display("FAIL, gltich accepted as start bit !");
        end
    end
endtask

initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, uart_rx_tb);
    rx = 1; reset = 1;
    repeat(5) @(posedge clk); // wait for 5 clk cycles
    reset = 0;
    repeat (10) @(posedge clk); // wait for 10 clk cycles

    sending_byte(8'hEA);
    sending_byte(8'h6F);
    glitch_test; // calling glitch test
    sending_byte(8'h9A);

    repeat(100) @(posedge clk);
    $finish;
end

always@(posedge clk)begin
    if(done)begin
        if(data_out==value)begin
            $display("PASS , value matches !");
        end
        else begin
            $display("FAIL, value doesn't match !");
        end
    end
end
endmodule