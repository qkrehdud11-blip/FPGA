`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module tb_dht11_cntr();

reg clk, reset_p;                    
tri1 dht11_data;
wire [7:0] humidity, temperature;


reg dout, wr_e; // write_enable = 1 => write
assign dht11_data = wr_e ? dout : 'bz;


dht11_cntr DUT(clk, reset_p, dht11_data, humidity, temperature);


initial begin
    clk = 0;
    reset_p = 1;
    wr_e = 0;
    dout = 0;
end

always #5 clk = ~clk;   // test 시 사용 가능 # = delay(ns)


localparam [7:0] humi_value = 8'd90;
localparam [7:0] tmpr_value = 8'd45;
localparam [7:0] check_sum = humi_value + tmpr_value;
localparam [39:0] data = {humi_value, 8'd0, 
                          tmpr_value, 8'd0, 
                          check_sum};


integer i;
initial begin
    #10; reset_p = 0;
    #10; 
    wait(!dht11_data);
    wait(dht11_data);
    #20_000;
    dout = 0; wr_e = 1; #80_000;
    wr_e = 0; #80_000;
    wr_e = 1;
    for (i = 0; i < 40; i = i + 1) begin
        dout = 0; #50_000;
        dout = 1;
        if (data[39-i]) #70_000;
        else #28_000;
    end
    dout = 0; #10;
    wr_e = 0; #100_000;
    $stop;
end








endmodule
