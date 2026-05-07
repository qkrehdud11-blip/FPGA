`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module conv2d_buf(
    input clk, reset_p,
    input start,
    input [7:0] pixel,
    output reg [9:0] buf_idx,
    output reg [7:0] value_00, value_01, value_02, value_03, value_04, 
                     value_05, value_06, value_07, value_08, value_09, 
                     value_10, value_11, 
    output reg valid_buf);
    
    localparam WIDTH = 31;
    localparam HIGHT = 30;
    
    localparam IDLE             = 0;
    localparam BUFFER_LOAD      = 1;
    localparam OUT_FILTER_FRAME = 2;
    
    
    
    reg [1:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    
    reg [7:0] buffer [0:HIGHT - 1][0:WIDTH - 1];
    
    reg [4:0] w_idx, h_idx;
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            buf_idx = 0;
            w_idx = 0;
            h_idx = 0;
            next_state = IDLE;
            valid_buf = 0;
            value_00 = 0;
            value_01 = 0;
            value_02 = 0;
            value_03 = 0;
            value_04 = 0;
            value_05 = 0;
            value_06 = 0;
            value_07 = 0;
            value_08 = 0;
            value_09 = 0;
            value_10 = 0;
            value_11 = 0;
        end
        else begin
            case(state)
                IDLE:begin
                    if(start)next_state = BUFFER_LOAD;
                    else next_state = IDLE;
                end
                BUFFER_LOAD:begin
                    if(h_idx == 0 || h_idx >= 29 || w_idx == 0 || w_idx >=29)begin
                        buffer[h_idx][w_idx] = 0;
                    end
                    else begin
                        buffer[h_idx][w_idx] = pixel;
                        buf_idx = buf_idx + 1;
                    end
                    w_idx = w_idx + 1;
                    if(w_idx >= 31)begin
                        w_idx = 0;
                        h_idx = h_idx + 1;
                        if(h_idx >= 30)begin
                            h_idx = 0;
                            buf_idx = 0;
                            next_state = OUT_FILTER_FRAME;
                        end
                    end
                end     
                OUT_FILTER_FRAME:begin
                    if(w_idx >= 28)begin
                        w_idx = 0;
                        if(h_idx >= 28)begin
                            h_idx = 0;
                            next_state = IDLE;
                            valid_buf = 0;
                        end
                        else begin
                            h_idx = h_idx + 1;
                        end
                    end
                    
                    valid_buf = 1;
                    value_00 = buffer[h_idx][w_idx];
                    value_01 = buffer[h_idx][w_idx+1];
                    value_02 = buffer[h_idx][w_idx+2];
                    value_03 = buffer[h_idx][w_idx+3]; 
                    value_04 = buffer[h_idx+1][w_idx];
                    value_05 = buffer[h_idx+1][w_idx+1];
                    value_06 = buffer[h_idx+1][w_idx+2];
                    value_07 = buffer[h_idx+1][w_idx+3];
                    value_08 = buffer[h_idx+2][w_idx];
                    value_09 = buffer[h_idx+2][w_idx+1];
                    value_10 = buffer[h_idx+2][w_idx+2];
                    value_11 = buffer[h_idx+2][w_idx+3];
                    
                    w_idx = w_idx + 1;
                    
                end
            endcase
        end
    end
    
    
    
endmodule

module conv2d_calc(
    input clk, reset_p,
    input valid_buf,
    input [7:0] value_00, value_01, value_02, value_03, value_04, 
                     value_05, value_06, value_07, value_08, value_09, 
                     value_10, value_11,
    output reg signed [15:0] conv_out_0,
    output reg signed [15:0] conv_out_1,
    output reg signed [15:0] conv_out_2,
    output reg signed [15:0] conv_out_3,
    output reg signed [15:0] conv_out_4,
    output reg valid_out_calc
);
    localparam ROW = 3;
    localparam COLUMN = 4;
    reg [7:0] buffer [0:COLUMN - 1][0:ROW - 1];
    reg signed [7:0] weight_0 [0:11];
    reg signed [7:0] weight_1 [0:11];
    reg signed [7:0] weight_2 [0:11];
    reg signed [7:0] weight_3 [0:11];
    reg signed [7:0] weight_4 [0:11];
    reg signed [7:0] bias [0:4];
    
    initial begin
        $readmemh("conv2d_filter_0.txt", weight_0);
        $readmemh("conv2d_filter_1.txt", weight_1);
        $readmemh("conv2d_filter_2.txt", weight_2);
        $readmemh("conv2d_filter_3.txt", weight_3);
        $readmemh("conv2d_filter_4.txt", weight_4);
        $readmemh("conv2d_bias.txt", bias);
    end
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            conv_out_0 = 0;
            conv_out_1 = 0;
            conv_out_2 = 0;
            conv_out_3 = 0;
            conv_out_4 = 0;
            valid_out_calc = 0;
        end
        else if(valid_buf)begin
            valid_out_calc = 1;
            conv_out_0 = value_00 * weight_0[0] + 
                       value_01 * weight_0[1] + 
                       value_02 * weight_0[2] + 
                       value_03 * weight_0[3] + 
                       value_04 * weight_0[4] + 
                       value_05 * weight_0[5] + 
                       value_06 * weight_0[6] + 
                       value_07 * weight_0[7] + 
                       value_08 * weight_0[8] + 
                       value_09 * weight_0[9] + 
                       value_10 * weight_0[10] + 
                       value_11 * weight_0[11] + 
                       bias[0];
            if(conv_out_0 < 0)conv_out_0 = 0;
            conv_out_1 = value_00 * weight_1[0] + 
                       value_01 * weight_1[1] + 
                       value_02 * weight_1[2] + 
                       value_03 * weight_1[3] + 
                       value_04 * weight_1[4] + 
                       value_05 * weight_1[5] + 
                       value_06 * weight_1[6] + 
                       value_07 * weight_1[7] + 
                       value_08 * weight_1[8] + 
                       value_09 * weight_1[9] + 
                       value_10 * weight_1[10] + 
                       value_11 * weight_1[11] + 
                       bias[1];
            if(conv_out_1 < 0)conv_out_1 = 0;
            conv_out_2 = value_00 * weight_2[0] + 
                       value_01 * weight_2[1] + 
                       value_02 * weight_2[2] + 
                       value_03 * weight_2[3] + 
                       value_04 * weight_2[4] + 
                       value_05 * weight_2[5] + 
                       value_06 * weight_2[6] + 
                       value_07 * weight_2[7] + 
                       value_08 * weight_2[8] + 
                       value_09 * weight_2[9] + 
                       value_10 * weight_2[10] + 
                       value_11 * weight_2[11] + 
                       bias[2];
            if(conv_out_2 < 0)conv_out_2 = 0;
            conv_out_3 = value_00 * weight_3[0] + 
                       value_01 * weight_3[1] + 
                       value_02 * weight_3[2] + 
                       value_03 * weight_3[3] + 
                       value_04 * weight_3[4] + 
                       value_05 * weight_3[5] + 
                       value_06 * weight_3[6] + 
                       value_07 * weight_3[7] + 
                       value_08 * weight_3[8] + 
                       value_09 * weight_3[9] + 
                       value_10 * weight_3[10] + 
                       value_11 * weight_3[11] + 
                       bias[3];
            if(conv_out_3 < 0)conv_out_3 = 0;
            conv_out_4 = value_00 * weight_4[0] + 
                       value_01 * weight_4[1] + 
                       value_02 * weight_4[2] + 
                       value_03 * weight_4[3] + 
                       value_04 * weight_4[4] + 
                       value_05 * weight_4[5] + 
                       value_06 * weight_4[6] + 
                       value_07 * weight_4[7] + 
                       value_08 * weight_4[8] + 
                       value_09 * weight_4[9] + 
                       value_10 * weight_4[10] + 
                       value_11 * weight_4[11] + 
                       bias[4];
            if(conv_out_4 < 0)conv_out_4 = 0;
        end
        else valid_out_calc = 0;
    end
endmodule

module maxpool_conv2d(
    input clk, reset_p,
    input valid_calc,
    input signed [15:0] conv_out_0,
    input signed [15:0] conv_out_1,
    input signed [15:0] conv_out_2,
    input signed [15:0] conv_out_3,
    input signed [15:0] conv_out_4,
    output reg signed [15:0] max_value_0,
    output reg signed [15:0] max_value_1,
    output reg signed [15:0] max_value_2,
    output reg signed [15:0] max_value_3,
    output reg signed [15:0] max_value_4,
    output reg max_value_valid
);

    reg [15:0] buffer_0 [0:13][0:13];
    reg [15:0] buffer_1 [0:13][0:13];
    reg [15:0] buffer_2 [0:13][0:13];
    reg [15:0] buffer_3 [0:13][0:13];
    reg [15:0] buffer_4 [0:13][0:13];
    reg [4:0] cnt_pixel_x, cnt_pixel_y;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            cnt_pixel_x = 0;
            cnt_pixel_y = 0;
            max_value_valid = 0;
        end
        else begin
            if(valid_calc)begin
                if(cnt_pixel_x >= 28)begin
                    cnt_pixel_x = 0;
                    if(cnt_pixel_y >= 28)begin
                        cnt_pixel_y = 0;
                    end
                    else begin
                        cnt_pixel_y = cnt_pixel_y + 1;
                    end
                end
                
                if({cnt_pixel_x[0], cnt_pixel_y[0]} == 2'b00)begin
                    buffer_0[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_0;
                    buffer_1[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_1;
                    buffer_2[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_2;
                    buffer_3[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_3;
                    buffer_4[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_4;
                end
                else begin
                    if(conv_out_0 > buffer_0[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]])begin
                        buffer_0[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_0;
                    end
                    if(conv_out_1 > buffer_1[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]])begin
                        buffer_1[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_1;
                    end
                    if(conv_out_2 > buffer_2[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]])begin
                        buffer_2[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_2;
                    end
                    if(conv_out_3 > buffer_3[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]])begin
                        buffer_3[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_3;
                    end
                    if(conv_out_4 > buffer_4[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]])begin
                        buffer_4[cnt_pixel_x[4:1]][cnt_pixel_y[4:1]] = conv_out_4;
                    end
                end
                cnt_pixel_x = cnt_pixel_x + 1;
                
            end
            else begin
                max_value_valid = 1;
                if(cnt_pixel_x >= 14)begin
                    cnt_pixel_x = 0;
                    if(cnt_pixel_y >= 14)begin
                        cnt_pixel_y = 0;
                        max_value_valid = 0;
                    end
                    else begin
                        cnt_pixel_y = cnt_pixel_y + 1;
                    end
                end
                
                max_value_0 = buffer_0[cnt_pixel_x][cnt_pixel_y];
                max_value_1 = buffer_1[cnt_pixel_x][cnt_pixel_y];
                max_value_2 = buffer_2[cnt_pixel_x][cnt_pixel_y];
                max_value_3 = buffer_3[cnt_pixel_x][cnt_pixel_y];
                max_value_4 = buffer_4[cnt_pixel_x][cnt_pixel_y];
                cnt_pixel_x = cnt_pixel_x + 1;
                
            end
        end
    end
    
endmodule

module conv2d_1_buf_LEJ(
    input clk, reset_p,
    input max_value_valid,
    input [7:0] pixel_0, pixel_1, pixel_2, pixel_3, pixel_4,

    output reg [9:0] buf_idx,
    output reg [7:0] value_00, value_01, value_02, value_03, 
                     value_04, value_05, value_06, value_07, value_08, 
    output reg [7:0] value_10, value_11, value_12, value_13, 
                     value_14, value_15, value_16, value_17, value_18,
    output reg [7:0] value_20, value_21, value_22, value_23, 
                     value_24, value_25, value_26, value_27, value_28, 
    output reg [7:0] value_30, value_31, value_32, value_33, 
                     value_34, value_35, value_36, value_37, value_38,   
    output reg [7:0] value_40, value_41, value_42, value_43, 
                     value_44, value_45, value_46, value_47, value_48,                                                               
    output reg valid_buf);
 
    localparam WIDTH = 16;
    localparam HIGH  = 16;
    
    localparam IDLE             = 0;
    localparam BUFFER_LOAD      = 1;
    localparam OUT_FILTER_FRAME = 2;
    
    reg [1:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    reg [7:0] buffer_0 [0:HIGH - 1][0:WIDTH - 1];
    reg [7:0] buffer_1 [0:HIGH - 1][0:WIDTH - 1];
    reg [7:0] buffer_2 [0:HIGH - 1][0:WIDTH - 1];
    reg [7:0] buffer_3 [0:HIGH - 1][0:WIDTH - 1];
    reg [7:0] buffer_4 [0:HIGH - 1][0:WIDTH - 1];
    
    reg [4:0] w_idx, h_idx;
    integer i, j;
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) begin
            buf_idx = 0;
            w_idx = 1;
            h_idx = 1;
            next_state = IDLE;
            valid_buf = 0;
            for(i=0; i<16; i=i+1)
                for(j=0; j<16; j=j+1)begin
                    buffer_0[i][j] = 0;
                    buffer_1[i][j] = 0;
                    buffer_2[i][j] = 0;
                    buffer_3[i][j] = 0;
                    buffer_4[i][j] = 0;
                end
        end
        else begin
            case(state)
                IDLE: begin
                    w_idx = 1;
                    h_idx = 1;
                    if(max_value_valid)next_state = BUFFER_LOAD;
                    else next_state = IDLE;
                end
                BUFFER_LOAD: begin
                    if(w_idx >= 14)begin
                        w_idx = 1;
                        if(h_idx >= 13)begin
                            w_idx = 0;
                            h_idx = 0;
                            next_state = OUT_FILTER_FRAME;
                        end
                        else begin
                            h_idx = h_idx + 1;
                        end
                    end
                    buffer_0[h_idx][w_idx] = pixel_0;   
                    buffer_1[h_idx][w_idx] = pixel_1; 
                    buffer_2[h_idx][w_idx] = pixel_2; 
                    buffer_3[h_idx][w_idx] = pixel_3; 
                    buffer_4[h_idx][w_idx] = pixel_4;  
                    w_idx = w_idx + 1;
                end                                                      
                OUT_FILTER_FRAME: begin
                    if(w_idx >= 14)begin
                        w_idx = 0;
                        if(h_idx >= 13)begin
                            h_idx = 0;
                            next_state = IDLE;
                            valid_buf = 0;
                        end
                        else begin
                            h_idx = h_idx + 1;
                        end
                    end                 
                    valid_buf = 1; // BUFFER 출력 나간다는 표시용 플래그
                    value_00 = buffer_0[h_idx][w_idx];
                    value_01 = buffer_0[h_idx][w_idx+1];
                    value_02 = buffer_0[h_idx][w_idx+2];
                    value_03 = buffer_0[h_idx+1][w_idx]; 
                    value_04 = buffer_0[h_idx+1][w_idx+1];
                    value_05 = buffer_0[h_idx+1][w_idx+2];
                    value_06 = buffer_0[h_idx+2][w_idx];
                    value_07 = buffer_0[h_idx+2][w_idx+1];
                    value_08 = buffer_0[h_idx+2][w_idx+2];
                    value_10 = buffer_1[h_idx][w_idx];    
                    value_11 = buffer_1[h_idx][w_idx+1];  
                    value_12 = buffer_1[h_idx][w_idx+2];  
                    value_13 = buffer_1[h_idx+1][w_idx];  
                    value_14 = buffer_1[h_idx+1][w_idx+1];
                    value_15 = buffer_1[h_idx+1][w_idx+2];
                    value_16 = buffer_1[h_idx+2][w_idx];  
                    value_17 = buffer_1[h_idx+2][w_idx+1];
                    value_18 = buffer_1[h_idx+2][w_idx+2];
                    value_20 = buffer_2[h_idx][w_idx];    
                    value_21 = buffer_2[h_idx][w_idx+1];  
                    value_22 = buffer_2[h_idx][w_idx+2];  
                    value_23 = buffer_2[h_idx+1][w_idx];  
                    value_24 = buffer_2[h_idx+1][w_idx+1];
                    value_25 = buffer_2[h_idx+1][w_idx+2];
                    value_26 = buffer_2[h_idx+2][w_idx];  
                    value_27 = buffer_2[h_idx+2][w_idx+1];
                    value_28 = buffer_2[h_idx+2][w_idx+2];
                    value_30 = buffer_3[h_idx][w_idx];    
                    value_31 = buffer_3[h_idx][w_idx+1];  
                    value_32 = buffer_3[h_idx][w_idx+2];  
                    value_33 = buffer_3[h_idx+1][w_idx];  
                    value_34 = buffer_3[h_idx+1][w_idx+1];
                    value_35 = buffer_3[h_idx+1][w_idx+2];
                    value_36 = buffer_3[h_idx+2][w_idx];  
                    value_37 = buffer_3[h_idx+2][w_idx+1];
                    value_38 = buffer_3[h_idx+2][w_idx+2];
                    value_40 = buffer_4[h_idx][w_idx];    
                    value_41 = buffer_4[h_idx][w_idx+1];  
                    value_42 = buffer_4[h_idx][w_idx+2];  
                    value_43 = buffer_4[h_idx+1][w_idx];  
                    value_44 = buffer_4[h_idx+1][w_idx+1];
                    value_45 = buffer_4[h_idx+1][w_idx+2];
                    value_46 = buffer_4[h_idx+2][w_idx];  
                    value_47 = buffer_4[h_idx+2][w_idx+1];
                    value_48 = buffer_4[h_idx+2][w_idx+2];                                                                       
                    w_idx = w_idx + 1;
                end
            endcase
        end
    end
endmodule    

module conv2d_1_calc_LEJ(
    input clk, reset_p,
    input valid_buf,
    input [7:0] value_00, value_01, value_02, value_03,           
                value_04, value_05, value_06, value_07, value_08, 
    input [7:0] value_10, value_11, value_12, value_13,           
                value_14, value_15, value_16, value_17, value_18, 
    input [7:0] value_20, value_21, value_22, value_23,           
                value_24, value_25, value_26, value_27, value_28, 
    input [7:0] value_30, value_31, value_32, value_33,           
                value_34, value_35, value_36, value_37, value_38, 
    input [7:0] value_40, value_41, value_42, value_43,           
                value_44, value_45, value_46, value_47, value_48, 
    
    output reg signed [21:0] conv_out_0,
    output reg signed [21:0] conv_out_1,
    output reg signed [21:0] conv_out_2,
    output reg signed [21:0] conv_out_3,
    output reg signed [21:0] conv_out_4,
    output reg signed [21:0] conv_out_5,
    output reg valid_out_calc     
);

    reg signed [7:0] weight_00 [0:8];  reg signed [7:0] weight_01 [0:8];  reg signed [7:0] weight_02 [0:8];  reg signed [7:0] weight_03 [0:8];  reg signed [7:0] weight_04 [0:8]; 
    reg signed [7:0] weight_10 [0:8];  reg signed [7:0] weight_11 [0:8];  reg signed [7:0] weight_12 [0:8];  reg signed [7:0] weight_13 [0:8];  reg signed [7:0] weight_14 [0:8]; 
    reg signed [7:0] weight_20 [0:8];  reg signed [7:0] weight_21 [0:8];  reg signed [7:0] weight_22 [0:8];  reg signed [7:0] weight_23 [0:8];  reg signed [7:0] weight_24 [0:8]; 
    reg signed [7:0] weight_30 [0:8];  reg signed [7:0] weight_31 [0:8];  reg signed [7:0] weight_32 [0:8];  reg signed [7:0] weight_33 [0:8];  reg signed [7:0] weight_34 [0:8]; 
    reg signed [7:0] weight_40 [0:8];  reg signed [7:0] weight_41 [0:8];  reg signed [7:0] weight_42 [0:8];  reg signed [7:0] weight_43 [0:8];  reg signed [7:0] weight_44 [0:8]; 
    reg signed [7:0] weight_50 [0:8];  reg signed [7:0] weight_51 [0:8];  reg signed [7:0] weight_52 [0:8];  reg signed [7:0] weight_53 [0:8];  reg signed [7:0] weight_54 [0:8];                  
    reg signed [7:0] bias[0:5];

    initial begin
        $readmemh("conv2d_1_filter0_ch0.txt", weight_00); $readmemh("conv2d_1_filter0_ch1.txt", weight_01); $readmemh("conv2d_1_filter0_ch2.txt", weight_02); $readmemh("conv2d_1_filter0_ch3.txt", weight_03); $readmemh("conv2d_1_filter0_ch4.txt", weight_04);
        $readmemh("conv2d_1_filter1_ch0.txt", weight_10); $readmemh("conv2d_1_filter1_ch1.txt", weight_11); $readmemh("conv2d_1_filter1_ch2.txt", weight_12); $readmemh("conv2d_1_filter1_ch3.txt", weight_13); $readmemh("conv2d_1_filter1_ch4.txt", weight_14);
        $readmemh("conv2d_1_filter2_ch0.txt", weight_20); $readmemh("conv2d_1_filter2_ch1.txt", weight_21); $readmemh("conv2d_1_filter2_ch2.txt", weight_22); $readmemh("conv2d_1_filter2_ch3.txt", weight_23); $readmemh("conv2d_1_filter2_ch4.txt", weight_24);
        $readmemh("conv2d_1_filter3_ch0.txt", weight_30); $readmemh("conv2d_1_filter3_ch1.txt", weight_31); $readmemh("conv2d_1_filter3_ch2.txt", weight_32); $readmemh("conv2d_1_filter3_ch3.txt", weight_33); $readmemh("conv2d_1_filter3_ch4.txt", weight_34);
        $readmemh("conv2d_1_filter4_ch0.txt", weight_40); $readmemh("conv2d_1_filter4_ch1.txt", weight_41); $readmemh("conv2d_1_filter4_ch2.txt", weight_42); $readmemh("conv2d_1_filter4_ch3.txt", weight_43); $readmemh("conv2d_1_filter4_ch4.txt", weight_44);
        $readmemh("conv2d_1_filter5_ch0.txt", weight_50); $readmemh("conv2d_1_filter5_ch1.txt", weight_51); $readmemh("conv2d_1_filter5_ch2.txt", weight_52); $readmemh("conv2d_1_filter5_ch3.txt", weight_53); $readmemh("conv2d_1_filter5_ch4.txt", weight_54);                                    
        $readmemh("conv2d_1_bias.txt", bias);
    end

    // ==========================================
    // 2. 입력 래치 및 2중 카운터 선언
    // ==========================================
    reg [7:0] latched_in [0:4][0:8]; // [채널 0~4] [픽셀 0~8]
    reg signed [21:0] acc_0, acc_1, acc_2, acc_3, acc_4, acc_5;
    
    reg [2:0] ch_idx;  // 채널 카운터 (0 ~ 4)
    reg [3:0] p_idx;   // 픽셀 카운터 (0 ~ 8)
    reg calc_busy;     // 45클럭 곱셈/누산 진행 상태
    reg calc_finish;   // 누산 완료 후 Bias/ReLU 처리 상태
    
    // ==========================================
    // 3. MUX: 현재 채널(ch_idx)에 맞는 가중치 배열 선택
    // ==========================================
    wire signed [7:0] cur_w0, cur_w1, cur_w2, cur_w3, cur_w4, cur_w5;

    // 필터 0을 위한 가중치 선택 (ch_idx가 바뀔 때마다 자동으로 해당 배열을 쳐다봄)
    assign cur_w0 = (ch_idx == 0) ? weight_00[p_idx] :
                    (ch_idx == 1) ? weight_01[p_idx] :
                    (ch_idx == 2) ? weight_02[p_idx] :
                    (ch_idx == 3) ? weight_03[p_idx] :
                                    weight_04[p_idx];
    // 필터 1을 위한 가중치 선택
    assign cur_w1 = (ch_idx == 0) ? weight_10[p_idx] :
                    (ch_idx == 1) ? weight_11[p_idx] :
                    (ch_idx == 2) ? weight_12[p_idx] :
                    (ch_idx == 3) ? weight_13[p_idx] :
                                    weight_14[p_idx];                                 
    // 필터 2을 위한 가중치 선택
    assign cur_w2 = (ch_idx == 0) ? weight_20[p_idx] :
                    (ch_idx == 1) ? weight_21[p_idx] :
                    (ch_idx == 2) ? weight_22[p_idx] :
                    (ch_idx == 3) ? weight_23[p_idx] :
                                    weight_24[p_idx]; 
    // 필터 3을 위한 가중치 선택
    assign cur_w3 = (ch_idx == 0) ? weight_30[p_idx] :
                    (ch_idx == 1) ? weight_31[p_idx] :
                    (ch_idx == 2) ? weight_32[p_idx] :
                    (ch_idx == 3) ? weight_33[p_idx] :
                                    weight_34[p_idx];
    // 필터 4을 위한 가중치 선택
    assign cur_w4 = (ch_idx == 0) ? weight_40[p_idx] :
                    (ch_idx == 1) ? weight_41[p_idx] :
                    (ch_idx == 2) ? weight_42[p_idx] :
                    (ch_idx == 3) ? weight_43[p_idx] :
                                    weight_44[p_idx];                             
    // 필터 5을 위한 가중치 선택
    assign cur_w5 = (ch_idx == 0) ? weight_50[p_idx] :
                    (ch_idx == 1) ? weight_51[p_idx] :
                    (ch_idx == 2) ? weight_52[p_idx] :
                    (ch_idx == 3) ? weight_53[p_idx] :
                                    weight_54[p_idx];
                                    
    // ==========================================
    // 4. 메인 파이프라인 연산 로직
    // ==========================================
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            ch_idx = 0;
            p_idx  = 0;
            calc_busy = 0;
            calc_finish = 0;
            valid_out_calc = 0;
            acc_0 = 0; acc_1 = 0; acc_2 = 0; acc_3 = 0; acc_4 = 0; acc_5 = 0;
            conv_out_0 = 0; conv_out_1 = 0; conv_out_2 = 0; conv_out_3 = 0; conv_out_4 = 0; conv_out_5 = 0;
        end 
        else begin
            // [상태 1] 새로운 데이터를 받아오는 시점
            if (valid_buf && !calc_busy && !calc_finish) begin
                // 입력 포트 45개의 값을 2D 배열에 안전하게 래치
                latched_in[0][0] = value_00; latched_in[0][1] = value_01; latched_in[0][2] = value_02;
                latched_in[0][3] = value_03; latched_in[0][4] = value_04; latched_in[0][5] = value_05;
                latched_in[0][6] = value_06; latched_in[0][7] = value_07; latched_in[0][8] = value_08;

                latched_in[1][0] = value_10; latched_in[1][1] = value_11; latched_in[1][2] = value_12;
                latched_in[1][3] = value_13; latched_in[1][4] = value_14; latched_in[1][5] = value_15;
                latched_in[1][6] = value_16; latched_in[1][7] = value_17; latched_in[1][8] = value_18;

                latched_in[2][0] = value_20; latched_in[2][1] = value_21; latched_in[2][2] = value_22;
                latched_in[2][3] = value_23; latched_in[2][4] = value_24; latched_in[2][5] = value_25;
                latched_in[2][6] = value_26; latched_in[2][7] = value_27; latched_in[2][8] = value_28;
             
                latched_in[3][0] = value_30; latched_in[3][1] = value_31; latched_in[3][2] = value_32;
                latched_in[3][3] = value_33; latched_in[3][4] = value_34; latched_in[3][5] = value_35;
                latched_in[3][6] = value_36; latched_in[3][7] = value_37; latched_in[3][8] = value_38; 
             
                latched_in[4][0] = value_40; latched_in[4][1] = value_41; latched_in[4][2] = value_42;
                latched_in[4][3] = value_43; latched_in[4][4] = value_44; latched_in[4][5] = value_45;
                latched_in[4][6] = value_46; latched_in[4][7] = value_47; latched_in[4][8] = value_48;
                                                              
                calc_busy = 1;
                ch_idx = 0;
                p_idx = 0;
                valid_out_calc = 0;
                acc_0 = 0; acc_1 = 0; acc_2 = 0; acc_3 = 0; acc_4 = 0; acc_5 = 0; // 누산기 리셋
            end 
            
            // [상태 2] 45클럭 동안 DSP 누산 연산 (MAC)
            else if (calc_busy) begin
                // 매 클럭 1개의 픽셀과 1개의 가중치 곱셈/누산
                acc_0 = acc_0 + ($signed({1'b0, latched_in[ch_idx][p_idx]}) * cur_w0);
                acc_1 = acc_1 + ($signed({1'b0, latched_in[ch_idx][p_idx]}) * cur_w1);
                acc_2 = acc_2 + ($signed({1'b0, latched_in[ch_idx][p_idx]}) * cur_w2);
                acc_3 = acc_3 + ($signed({1'b0, latched_in[ch_idx][p_idx]}) * cur_w3);
                acc_4 = acc_4 + ($signed({1'b0, latched_in[ch_idx][p_idx]}) * cur_w4);
                acc_5 = acc_5 + ($signed({1'b0, latched_in[ch_idx][p_idx]}) * cur_w5);
                
                // 2중 카운터 로직
                if (p_idx >= 8) begin
                    p_idx = 0;
                    if (ch_idx >= 4) begin
                        calc_busy = 0;      // 45번 연산 끝!
                        calc_finish = 1;    // 다음 상태로 넘어감
                    end else begin
                        ch_idx = ch_idx + 1;
                    end
                end else begin
                    p_idx = p_idx + 1;
                end
            end
            
            // [상태 3] 최종 Bias 덧셈 및 ReLU 연산
            else if (calc_finish) begin
                // 음수면 0 (ReLU), 양수면 그대로 통과
                conv_out_0 = (acc_0 + bias[0] > 0) ? acc_0 + bias[0] : 0;
                conv_out_1 = (acc_1 + bias[1] > 0) ? acc_1 + bias[1] : 0;
                conv_out_2 = (acc_2 + bias[2] > 0) ? acc_2 + bias[2] : 0;
                conv_out_3 = (acc_3 + bias[3] > 0) ? acc_3 + bias[3] : 0;
                conv_out_4 = (acc_4 + bias[4] > 0) ? acc_4 + bias[4] : 0;
                conv_out_5 = (acc_5 + bias[5] > 0) ? acc_5 + bias[5] : 0;
                valid_out_calc = 1;
                calc_finish = 0;    // 다시 데이터를 받을 준비 완료
            end
            // 대기 상태
            else begin
                valid_out_calc = 0; // 출력 valid는 1클럭만 High 유지
            end
        end
    end
endmodule


module conv2d_1_calc_LJS(
    input clk, reset_p,
    input valid_buf,
    input [7:0] value_00,value_01,value_02,value_03,value_04,
                value_05,value_06,value_07,value_08,
    input [7:0] value_10, value_11, value_12, value_13, value_14, 
                value_15, value_16, value_17, value_18, 
    input [7:0] value_20, value_21, value_22, value_23, value_24, 
                value_25, value_26, value_27, value_28, 
    input [7:0] value_30, value_31, value_32, value_33, value_34, 
                value_35, value_36, value_37, value_38, 
    input [7:0] value_40, value_41, value_42, value_43, value_44, 
                value_45, value_46, value_47, value_48,                      
             
    output reg signed [22:0] conv_out_0,
    output reg signed [22:0] conv_out_1,
    output reg signed [22:0] conv_out_2,
    output reg signed [22:0] conv_out_3,
    output reg signed [22:0] conv_out_4,
    output reg signed [22:0] conv_out_5,
    output reg valid_out_calc
);
    localparam ROW =3;
    localparam COLMN = 3;
    reg [7:0] buffer_0 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_1 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_2 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_3 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_4 [0:COLMN -1][0:ROW -1];
    
    reg signed [7:0] weight_00 [0:8];
    reg signed [7:0] weight_01 [0:8];
    reg signed [7:0] weight_02 [0:8];
    reg signed [7:0] weight_03 [0:8];
    reg signed [7:0] weight_04 [0:8];
    
    reg signed [7:0] weight_10 [0:8];
    reg signed [7:0] weight_11 [0:8];
    reg signed [7:0] weight_12 [0:8];
    reg signed [7:0] weight_13 [0:8];
    reg signed [7:0] weight_14 [0:8];
    
    reg signed [7:0] weight_20 [0:8];
    reg signed [7:0] weight_21 [0:8];
    reg signed [7:0] weight_22 [0:8];
    reg signed [7:0] weight_23 [0:8];
    reg signed [7:0] weight_24 [0:8];
    
    reg signed [7:0] weight_30 [0:8];
    reg signed [7:0] weight_31 [0:8];
    reg signed [7:0] weight_32 [0:8];
    reg signed [7:0] weight_33 [0:8];
    reg signed [7:0] weight_34 [0:8];
    
    reg signed [7:0] weight_40 [0:8];
    reg signed [7:0] weight_41 [0:8];
    reg signed [7:0] weight_42 [0:8];
    reg signed [7:0] weight_43 [0:8];
    reg signed [7:0] weight_44 [0:8];
   
    reg signed [7:0] weight_50 [0:8];
    reg signed [7:0] weight_51 [0:8];
    reg signed [7:0] weight_52 [0:8];
    reg signed [7:0] weight_53 [0:8];
    reg signed [7:0] weight_54 [0:8];
    
    reg signed [7:0] bias [0:5];
    
    
    initial begin
      $readmemh("conv2d_1_weights_filter_0_channel_0.txt",weight_00);
      $readmemh("conv2d_1_weights_filter_0_channel_1.txt",weight_01);
      $readmemh("conv2d_1_weights_filter_0_channel_2.txt",weight_02);
      $readmemh("conv2d_1_weights_filter_0_channel_3.txt",weight_03);
      $readmemh("conv2d_1_weights_filter_0_channel_4.txt",weight_04);
      
      $readmemh("conv2d_1_weights_filter_1_channel_0.txt",weight_10);
      $readmemh("conv2d_1_weights_filter_1_channel_1.txt",weight_11);
      $readmemh("conv2d_1_weights_filter_1_channel_2.txt",weight_12);
      $readmemh("conv2d_1_weights_filter_1_channel_3.txt",weight_13);
      $readmemh("conv2d_1_weights_filter_1_channel_4.txt",weight_14);
      
      $readmemh("conv2d_1_weights_filter_2_channel_0.txt",weight_20);
      $readmemh("conv2d_1_weights_filter_2_channel_1.txt",weight_21);
      $readmemh("conv2d_1_weights_filter_2_channel_2.txt",weight_22);
      $readmemh("conv2d_1_weights_filter_2_channel_3.txt",weight_23);
      $readmemh("conv2d_1_weights_filter_2_channel_4.txt",weight_24);
      
      $readmemh("conv2d_1_weights_filter_3_channel_0.txt",weight_30);
      $readmemh("conv2d_1_weights_filter_3_channel_1.txt",weight_31);
      $readmemh("conv2d_1_weights_filter_3_channel_2.txt",weight_32);
      $readmemh("conv2d_1_weights_filter_3_channel_3.txt",weight_33);
      $readmemh("conv2d_1_weights_filter_3_channel_4.txt",weight_34);
      
      $readmemh("conv2d_1_weights_filter_4_channel_0.txt",weight_40);
      $readmemh("conv2d_1_weights_filter_4_channel_1.txt",weight_41);
      $readmemh("conv2d_1_weights_filter_4_channel_2.txt",weight_42);
      $readmemh("conv2d_1_weights_filter_4_channel_3.txt",weight_43);
      $readmemh("conv2d_1_weights_filter_4_channel_4.txt",weight_44);
      
      $readmemh("conv2d_1_weights_filter_5_channel_0.txt",weight_50);
      $readmemh("conv2d_1_weights_filter_5_channel_1.txt",weight_51);
      $readmemh("conv2d_1_weights_filter_5_channel_2.txt",weight_52);
      $readmemh("conv2d_1_weights_filter_5_channel_3.txt",weight_53);
      $readmemh("conv2d_1_weights_filter_5_channel_4.txt",weight_54);
     
      $readmemh("conv2d_1_bias.txt",bias);
    end

    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            conv_out_0 =0;
            conv_out_1 =0;
            conv_out_2 =0;
            conv_out_3 =0;
            conv_out_4 =0;
            conv_out_5 =0;
            valid_out_calc=0;
        end
        else if(valid_buf)begin
            valid_out_calc=1;
            conv_out_0  = value_00*weight_00[0] + 
                          value_01*weight_00[1] +
                          value_02*weight_00[2] +
                          value_03*weight_00[3] +
                          value_04*weight_00[4] +
                          value_05*weight_00[5] +
                          value_06*weight_00[6] +
                          value_07*weight_00[7] +
                          value_08*weight_00[8] +
                          value_10*weight_01[0] + 
                          value_11*weight_01[1] +
                          value_12*weight_01[2] +
                          value_13*weight_01[3] +
                          value_14*weight_01[4] +
                          value_15*weight_01[5] +
                          value_16*weight_01[6] +
                          value_17*weight_01[7] +
                          value_18*weight_01[8] +
                          value_20*weight_02[0] + 
                          value_21*weight_02[1] +
                          value_22*weight_02[2] +
                          value_23*weight_02[3] +
                          value_24*weight_02[4] +
                          value_25*weight_02[5] +
                          value_26*weight_02[6] +
                          value_27*weight_02[7] +
                          value_28*weight_02[8] +
                          value_30*weight_03[0] + 
                          value_31*weight_03[1] +
                          value_32*weight_03[2] +
                          value_33*weight_03[3] +
                          value_34*weight_03[4] +
                          value_35*weight_03[5] +
                          value_36*weight_03[6] +
                          value_37*weight_03[7] +
                          value_38*weight_03[8] +
                          value_40*weight_04[0] + 
                          value_41*weight_04[1] +
                          value_42*weight_04[2] +
                          value_43*weight_04[3] +
                          value_44*weight_04[4] +
                          value_45*weight_04[5] +
                          value_46*weight_04[6] +
                          value_47*weight_04[7] +
                          value_48*weight_04[8] +
                          bias[0] ;
            if(conv_out_0<0) conv_out_0 = 0; //relu
            conv_out_1  = value_00*weight_10[0] +  
                          value_01*weight_10[1] +  
                          value_02*weight_10[2] +  
                          value_03*weight_10[3] +  
                          value_04*weight_10[4] +  
                          value_05*weight_10[5] +  
                          value_06*weight_10[6] +  
                          value_07*weight_10[7] +  
                          value_08*weight_10[8] +  
                          value_10*weight_11[0] +  
                          value_11*weight_11[1] +  
                          value_12*weight_11[2] +  
                          value_13*weight_11[3] +  
                          value_14*weight_11[4] +  
                          value_15*weight_11[5] +  
                          value_16*weight_11[6] +  
                          value_17*weight_11[7] +  
                          value_18*weight_11[8] +  
                          value_20*weight_12[0] +  
                          value_21*weight_12[1] +  
                          value_22*weight_12[2] +  
                          value_23*weight_12[3] +  
                          value_24*weight_12[4] +  
                          value_25*weight_12[5] +  
                          value_26*weight_12[6] +  
                          value_27*weight_12[7] +  
                          value_28*weight_12[8] +  
                          value_30*weight_13[0] +  
                          value_31*weight_13[1] +  
                          value_32*weight_13[2] +  
                          value_33*weight_13[3] +  
                          value_34*weight_13[4] +  
                          value_35*weight_13[5] +  
                          value_36*weight_13[6] +                
                          value_37*weight_13[7] +              
                          value_38*weight_13[8] +             
                          value_40*weight_14[0] +             
                          value_41*weight_14[1] +             
                          value_42*weight_14[2] +             
                          value_43*weight_14[3] +             
                          value_44*weight_14[4] +             
                          value_45*weight_14[5] +             
                          value_46*weight_14[6] +             
                          value_47*weight_14[7] +             
                          value_48*weight_14[8] +             
                          bias[1] ;                           
            if(conv_out_1<0) conv_out_1= 0; //relu
            conv_out_2  = value_00*weight_20[0] +         
                          value_01*weight_20[1] +             
                          value_02*weight_20[2] +             
                          value_03*weight_20[3] +             
                          value_04*weight_20[4] +             
                          value_05*weight_20[5] +             
                          value_06*weight_20[6] +             
                          value_07*weight_20[7] +             
                          value_08*weight_20[8] +             
                          value_10*weight_21[0] +             
                          value_11*weight_21[1] +             
                          value_12*weight_21[2] +             
                          value_13*weight_21[3] +             
                          value_14*weight_21[4] +             
                          value_15*weight_21[5] +             
                          value_16*weight_21[6] +             
                          value_17*weight_21[7] +             
                          value_18*weight_21[8] +             
                          value_20*weight_22[0] +             
                          value_21*weight_22[1] +             
                          value_22*weight_22[2] +             
                          value_23*weight_22[3] +             
                          value_24*weight_22[4] +             
                          value_25*weight_22[5] +             
                          value_26*weight_22[6] +             
                          value_27*weight_22[7] +             
                          value_28*weight_22[8] +             
                          value_30*weight_23[0] +             
                          value_31*weight_23[1] +             
                          value_32*weight_23[2] +             
                          value_33*weight_23[3] +             
                          value_34*weight_23[4] +             
                          value_35*weight_23[5] +             
                          value_36*weight_23[6] +             
                          value_37*weight_23[7] +             
                          value_38*weight_23[8] +             
                          value_40*weight_24[0] +             
                          value_41*weight_24[1] +             
                          value_42*weight_24[2] +             
                          value_43*weight_24[3] +             
                          value_44*weight_24[4] +             
                          value_45*weight_24[5] +             
                          value_46*weight_24[6] +             
                          value_47*weight_24[7] +             
                          value_48*weight_24[8] +             
                          bias[2] ;                           
            if(conv_out_2<0) conv_out_2 = 0; //relu
            conv_out_3  = value_00*weight_30[0] +  
                          value_01*weight_30[1] +  
                          value_02*weight_30[2] +  
                          value_03*weight_30[3] +  
                          value_04*weight_30[4] +  
                          value_05*weight_30[5] +  
                          value_06*weight_30[6] +  
                          value_07*weight_30[7] +  
                          value_08*weight_30[8] +  
                          value_10*weight_31[0] +  
                          value_11*weight_31[1] +  
                          value_12*weight_31[2] +  
                          value_13*weight_31[3] +  
                          value_14*weight_31[4] +  
                          value_15*weight_31[5] +  
                          value_16*weight_31[6] +  
                          value_17*weight_31[7] +  
                          value_18*weight_31[8] +  
                          value_20*weight_32[0] +  
                          value_21*weight_32[1] +  
                          value_22*weight_32[2] +  
                          value_23*weight_32[3] +  
                          value_24*weight_32[4] +  
                          value_25*weight_32[5] +  
                          value_26*weight_32[6] +  
                          value_27*weight_32[7] +  
                          value_28*weight_32[8] +  
                          value_30*weight_33[0] +  
                          value_31*weight_33[1] +  
                          value_32*weight_33[2] +  
                          value_33*weight_33[3] +  
                          value_34*weight_33[4] +  
                          value_35*weight_33[5] +  
                          value_36*weight_33[6] +  
                          value_37*weight_33[7] +  
                          value_38*weight_33[8] +  
                          value_40*weight_34[0] +  
                          value_41*weight_34[1] +  
                          value_42*weight_34[2] +  
                          value_43*weight_34[3] +  
                          value_44*weight_34[4] +  
                          value_45*weight_34[5] +  
                          value_46*weight_34[6] +  
                          value_47*weight_34[7] +  
                          value_48*weight_34[8] +  
                          bias[3] ;                
            if(conv_out_3<0) conv_out_3 = 0; //relu         
            conv_out_4  = value_00*weight_40[0] +  
                          value_01*weight_40[1] +  
                          value_02*weight_40[2] +  
                          value_03*weight_40[3] +  
                          value_04*weight_40[4] +  
                          value_05*weight_40[5] +  
                          value_06*weight_40[6] +  
                          value_07*weight_40[7] +  
                          value_08*weight_40[8] +  
                          value_10*weight_41[0] +  
                          value_11*weight_41[1] +  
                          value_12*weight_41[2] +  
                          value_13*weight_41[3] +  
                          value_14*weight_41[4] +  
                          value_15*weight_41[5] +  
                          value_16*weight_41[6] +  
                          value_17*weight_41[7] +  
                          value_18*weight_41[8] +  
                          value_20*weight_42[0] +  
                          value_21*weight_42[1] +  
                          value_22*weight_42[2] +  
                          value_23*weight_42[3] +  
                          value_24*weight_42[4] +  
                          value_25*weight_42[5] +  
                          value_26*weight_42[6] +  
                          value_27*weight_42[7] +  
                          value_28*weight_42[8] +  
                          value_30*weight_43[0] +  
                          value_31*weight_43[1] +  
                          value_32*weight_43[2] +  
                          value_33*weight_43[3] +  
                          value_34*weight_43[4] +  
                          value_35*weight_43[5] +  
                          value_36*weight_43[6] +  
                          value_37*weight_43[7] +  
                          value_38*weight_43[8] +  
                          value_40*weight_44[0] +  
                          value_41*weight_44[1] +  
                          value_42*weight_44[2] +  
                          value_43*weight_44[3] +  
                          value_44*weight_44[4] +  
                          value_45*weight_44[5] +  
                          value_46*weight_44[6] +  
                          value_47*weight_44[7] +  
                          value_48*weight_44[8] +  
                          bias[4] ;                
            if(conv_out_4<0) conv_out_4 = 0; //relu         
            conv_out_5  = value_00*weight_50[0] +  
                          value_01*weight_50[1] +  
                          value_02*weight_50[2] +  
                          value_03*weight_50[3] +  
                          value_04*weight_50[4] +  
                          value_05*weight_50[5] +  
                          value_06*weight_50[6] +  
                          value_07*weight_50[7] +  
                          value_08*weight_50[8] +  
                          value_10*weight_51[0] +  
                          value_11*weight_51[1] +  
                          value_12*weight_51[2] +  
                          value_13*weight_51[3] +  
                          value_14*weight_51[4] +  
                          value_15*weight_51[5] +  
                          value_16*weight_51[6] +  
                          value_17*weight_51[7] +  
                          value_18*weight_51[8] +  
                          value_20*weight_52[0] +  
                          value_21*weight_52[1] +  
                          value_22*weight_52[2] +  
                          value_23*weight_52[3] +  
                          value_24*weight_52[4] +  
                          value_25*weight_52[5] +  
                          value_26*weight_52[6] +  
                          value_27*weight_52[7] +  
                          value_28*weight_52[8] +  
                          value_30*weight_53[0] +  
                          value_31*weight_53[1] +  
                          value_32*weight_53[2] +  
                          value_33*weight_53[3] +  
                          value_34*weight_53[4] +  
                          value_35*weight_53[5] +  
                          value_36*weight_53[6] +  
                          value_37*weight_53[7] +  
                          value_38*weight_53[8] +  
                          value_40*weight_54[0] +  
                          value_41*weight_54[1] +  
                          value_42*weight_54[2] +  
                          value_43*weight_54[3] +  
                          value_44*weight_54[4] +  
                          value_45*weight_54[5] +  
                          value_46*weight_54[6] +  
                          value_47*weight_54[7] +  
                          value_48*weight_54[8] +  
                          bias[5] ;                
            if(conv_out_5<0) conv_out_5 = 0; //relu      
        end
        else valid_out_calc=0;
    end
endmodule


module conv2d_1_calc(
    input clk,reset_p,valid_buf,
    input [7:0] value_00,value_01,value_02,value_03,value_04,value_05,
                 value_06,value_07,value_08,
    input [7:0] value_10,value_11,value_12,value_13,value_14,value_15,
                 value_16,value_17,value_18,
    input [7:0] value_20,value_21,value_22,value_23,value_24,value_25,
                 value_26,value_27,value_28,
    input [7:0] value_30,value_31,value_32,value_33,value_34,value_35,
                 value_36,value_37,value_38,
    input [7:0] value_40,value_41,value_42,value_43,value_44,value_45,
                 value_46,value_47,value_48,
    output reg signed [18:0] conv_out_0,
    output reg signed [18:0] conv_out_1,
    output reg signed [18:0] conv_out_2,
    output reg signed [18:0] conv_out_3,
    output reg signed [18:0] conv_out_4,
    output reg valid_out_calc            
);

    reg signed[7:0] weight_0 [0:45];
    reg signed[7:0] weight_1 [0:45];
    reg signed[7:0] weight_2 [0:45];
    reg signed[7:0] weight_3 [0:45];
    reg signed[7:0] weight_4 [0:45];
    wire signed[7:0] bias_0 = weight_0 [45];
    wire signed[7:0] bias_1 = weight_1 [45];
    wire signed[7:0] bias_2 = weight_2 [45];
    wire signed[7:0] bias_3 = weight_3 [45];
    wire signed[7:0] bias_4 = weight_4 [45];
    reg signed [15:0] conv_out_0_0;
    reg signed [15:0] conv_out_0_1;
    reg signed [15:0] conv_out_0_2;
    reg signed [15:0] conv_out_0_3;
    reg signed [15:0] conv_out_0_4;
    reg signed [15:0] conv_out_1_0;
    reg signed [15:0] conv_out_1_1;
    reg signed [15:0] conv_out_1_2;
    reg signed [15:0] conv_out_1_3;
    reg signed [15:0] conv_out_1_4;
    reg signed [15:0] conv_out_2_0;
    reg signed [15:0] conv_out_2_1;
    reg signed [15:0] conv_out_2_2;
    reg signed [15:0] conv_out_2_3;
    reg signed [15:0] conv_out_2_4;
    reg signed [15:0] conv_out_3_0;
    reg signed [15:0] conv_out_3_1;
    reg signed [15:0] conv_out_3_2;
    reg signed [15:0] conv_out_3_3;
    reg signed [15:0] conv_out_3_4;
    reg signed [15:0] conv_out_4_0;
    reg signed [15:0] conv_out_4_1;
    reg signed [15:0] conv_out_4_2;
    reg signed [15:0] conv_out_4_3;
    reg signed [15:0] conv_out_4_4;
    
    initial begin
        // 파일의 0번~8번 라인까지만 weight 배열에 채움
        $readmemh("conv1_node_0.txt", weight_0, 0, 45);
        $readmemh("conv1_node_1.txt", weight_1, 0, 45);
        $readmemh("conv1_node_2.txt", weight_2, 0, 45);
        $readmemh("conv1_node_3.txt", weight_3, 0, 45);
        $readmemh("conv1_node_4.txt", weight_4, 0, 45);        
    end
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            conv_out_0=0;
            conv_out_1=0;
            conv_out_2=0;
            conv_out_3=0;
            conv_out_4=0;
            conv_out_0_0=0;
            conv_out_0_1=0;
            conv_out_0_2=0;
            conv_out_0_3=0;
            conv_out_0_4=0;
            conv_out_1_0=0;
            conv_out_1_1=0;
            conv_out_1_2=0;
            conv_out_1_3=0;
            conv_out_1_4=0;
            conv_out_2_0=0;
            conv_out_2_1=0;
            conv_out_2_2=0;
            conv_out_2_3=0;
            conv_out_2_4=0;
            conv_out_3_0=0;           
            conv_out_3_1=0;
            conv_out_3_2=0;
            conv_out_3_3=0;
            conv_out_3_4=0;
            conv_out_4_0=0;
            conv_out_4_1=0;
            conv_out_4_2=0;
            conv_out_4_3=0;
            conv_out_4_4=0;
            valid_out_calc=0;
        end
        else if(valid_buf)begin
            valid_out_calc =1;
            conv_out_0_0 =  value_00 * weight_0[0] +
                            value_01 * weight_0[1] +
                            value_02 * weight_0[2] +
                            value_03 * weight_0[3] +
                            value_04 * weight_0[4] +
                            value_05 * weight_0[5] +
                            value_06 * weight_0[6] +
                            value_07 * weight_0[7] +
                            value_08 * weight_0[8];
            conv_out_0_1 =  value_00 * weight_0[9] +
                            value_01 * weight_0[10] +
                            value_02 * weight_0[11] +
                            value_03 * weight_0[12] +
                            value_04 * weight_0[13] +
                            value_05 * weight_0[14] +
                            value_06 * weight_0[15] +
                            value_07 * weight_0[16] +
                            value_08 * weight_0[17];
            conv_out_0_2 =  value_00 * weight_0[18] +
                            value_01 * weight_0[19] +
                            value_02 * weight_0[20] +
                            value_03 * weight_0[21] +
                            value_04 * weight_0[22] +
                            value_05 * weight_0[23] +
                            value_06 * weight_0[24] +
                            value_07 * weight_0[25] +
                            value_08 * weight_0[26];
            conv_out_0_3 =  value_00 * weight_0[27] +
                            value_01 * weight_0[28] +
                            value_02 * weight_0[29] +
                            value_03 * weight_0[30] +
                            value_04 * weight_0[31] +
                            value_05 * weight_0[32] +
                            value_06 * weight_0[33] +
                            value_07 * weight_0[34] +
                            value_08 * weight_0[35];
            conv_out_0_4 =  value_00 * weight_0[36] +
                            value_01 * weight_0[37] +
                            value_02 * weight_0[38] +
                            value_03 * weight_0[39] +
                            value_04 * weight_0[40] +
                            value_05 * weight_0[41] +
                            value_06 * weight_0[42] +
                            value_07 * weight_0[43] +
                            value_08 * weight_0[44];                                                            
            conv_out_0 = bias_0 + conv_out_0_0 + conv_out_0_1 +conv_out_0_2 +conv_out_0_3 +conv_out_0_4; //자리수 절삭할것
            if(conv_out_0<0) conv_out_0 =0;  //relu처리:0이하는 0으로

            conv_out_1_0 =  value_10 * weight_1[0] +
                            value_11 * weight_1[1] +
                            value_12 * weight_1[2] +
                            value_13 * weight_1[3] +
                            value_14 * weight_1[4] +
                            value_15 * weight_1[5] +
                            value_16 * weight_1[6] +
                            value_17 * weight_1[7] +
                            value_18 * weight_1[8];
            conv_out_1_1 =  value_10 * weight_1[9] +
                            value_11 * weight_1[10] +
                            value_12 * weight_1[11] +
                            value_13 * weight_1[12] +
                            value_14 * weight_1[13] +
                            value_15 * weight_1[14] +
                            value_16 * weight_1[15] +
                            value_17 * weight_1[16] +
                            value_18 * weight_1[17];
            conv_out_1_2 =  value_10 * weight_1[18] +
                            value_11 * weight_1[19] +
                            value_12 * weight_1[20] +
                            value_13 * weight_1[21] +
                            value_14 * weight_1[22] +
                            value_15 * weight_1[23] +
                            value_16 * weight_1[24] +
                            value_17 * weight_1[25] +
                            value_18 * weight_1[26];
            conv_out_1_3 =  value_10 * weight_1[27] +
                            value_11 * weight_1[28] +
                            value_12 * weight_1[29] +
                            value_13 * weight_1[30] +
                            value_14 * weight_1[31] +
                            value_15 * weight_1[32] +
                            value_16 * weight_1[33] +
                            value_17 * weight_1[34] +
                            value_18 * weight_1[35];
            conv_out_1_4 =  value_10 * weight_1[36] +
                            value_11 * weight_1[37] +
                            value_12 * weight_1[38] +
                            value_13 * weight_1[39] +
                            value_14 * weight_1[40] +
                            value_15 * weight_1[41] +
                            value_16 * weight_1[42] +
                            value_17 * weight_1[43] +
                            value_18 * weight_1[44];                                                            
            conv_out_1 = bias_1 + conv_out_1_0 + conv_out_1_1 +conv_out_1_2 +conv_out_1_3 +conv_out_1_4; //자리수 절삭할것
            if(conv_out_1<0) conv_out_1 =0;

            conv_out_2_0 =  value_20 * weight_2[0] +
                            value_21 * weight_2[1] +
                            value_22 * weight_2[2] +
                            value_23 * weight_2[3] +
                            value_24 * weight_2[4] +
                            value_25 * weight_2[5] +
                            value_26 * weight_2[6] +
                            value_27 * weight_2[7] +
                            value_28 * weight_2[8];
            conv_out_2_1 =  value_20 * weight_2[9] +
                            value_21 * weight_2[10] +
                            value_22 * weight_2[11] +
                            value_23 * weight_2[12] +
                            value_24 * weight_2[13] +
                            value_25 * weight_2[14] +
                            value_26 * weight_2[15] +
                            value_27 * weight_2[16] +
                            value_28 * weight_2[17];
            conv_out_2_2 =  value_20 * weight_2[18] +
                            value_21 * weight_2[19] +
                            value_22 * weight_2[20] +
                            value_23 * weight_2[21] +
                            value_24 * weight_2[22] +
                            value_25 * weight_2[23] +
                            value_26 * weight_2[24] +
                            value_27 * weight_2[25] +
                            value_28 * weight_2[26];
            conv_out_2_3 =  value_20 * weight_2[27] +
                            value_21 * weight_2[28] +
                            value_22 * weight_2[29] +
                            value_23 * weight_2[30] +
                            value_24 * weight_2[31] +
                            value_25 * weight_2[32] +
                            value_26 * weight_2[33] +
                            value_27 * weight_2[34] +
                            value_28 * weight_2[35];
            conv_out_2_4 =  value_20 * weight_2[36] +
                            value_21 * weight_2[37] +
                            value_22 * weight_2[38] +
                            value_23 * weight_2[39] +
                            value_24 * weight_2[40] +
                            value_25 * weight_2[41] +
                            value_26 * weight_2[42] +
                            value_27 * weight_2[43] +
                            value_28 * weight_2[44];                                                            
            conv_out_2 = bias_2 + conv_out_2_0 + conv_out_2_1 +conv_out_2_2 +conv_out_2_3 +conv_out_2_4; //자리수 절삭할것
            if(conv_out_2<0) conv_out_2 =0; 

            conv_out_3_0 =  value_30 * weight_3[0] +
                            value_31 * weight_3[1] +
                            value_32 * weight_3[2] +
                            value_33 * weight_3[3] +
                            value_34 * weight_3[4] +
                            value_35 * weight_3[5] +
                            value_36 * weight_3[6] +
                            value_37 * weight_3[7] +
                            value_38 * weight_3[8];
            conv_out_3_1 =  value_30 * weight_3[9] +
                            value_31 * weight_3[10] +
                            value_32 * weight_3[11] +
                            value_33 * weight_3[12] +
                            value_34 * weight_3[13] +
                            value_35 * weight_3[14] +
                            value_36 * weight_3[15] +
                            value_37 * weight_3[16] +
                            value_38 * weight_3[17];
            conv_out_3_2 =  value_30 * weight_3[18] +
                            value_31 * weight_3[19] +
                            value_32 * weight_3[20] +
                            value_33 * weight_3[21] +
                            value_34 * weight_3[22] +
                            value_35 * weight_3[23] +
                            value_36 * weight_3[24] +
                            value_37 * weight_3[25] +
                            value_38 * weight_3[26];
            conv_out_3_3 =  value_30 * weight_3[27] +
                            value_31 * weight_3[28] +
                            value_32 * weight_3[29] +
                            value_33 * weight_3[30] +
                            value_34 * weight_3[31] +
                            value_35 * weight_3[32] +
                            value_36 * weight_3[33] +
                            value_37 * weight_3[34] +
                            value_38 * weight_3[35];
            conv_out_3_4 =  value_30 * weight_3[36] +
                            value_31 * weight_3[37] +
                            value_32 * weight_3[38] +
                            value_33 * weight_3[39] +
                            value_34 * weight_3[40] +
                            value_35 * weight_3[41] +
                            value_36 * weight_3[42] +
                            value_37 * weight_3[43] +
                            value_38 * weight_3[44];                                                            
            conv_out_3 = bias_3 + conv_out_3_0 + conv_out_3_1 +conv_out_3_2 +conv_out_3_3 +conv_out_3_4; //자리수 절삭할것
            if(conv_out_3<0) conv_out_3 =0;

            conv_out_4_0 =  value_40 * weight_4[0] +
                            value_41 * weight_4[1] +
                            value_42 * weight_4[2] +
                            value_43 * weight_4[3] +
                            value_44 * weight_4[4] +
                            value_45 * weight_4[5] +
                            value_46 * weight_4[6] +
                            value_47 * weight_4[7] +
                            value_48 * weight_4[8];
            conv_out_4_1 =  value_40 * weight_4[9] +
                            value_41 * weight_4[10] +
                            value_42 * weight_4[11] +
                            value_43 * weight_4[12] +
                            value_44 * weight_4[13] +
                            value_45 * weight_4[14] +
                            value_46 * weight_4[15] +
                            value_47 * weight_4[16] +
                            value_48 * weight_4[17];
            conv_out_4_2 =  value_40 * weight_4[18] +
                            value_41 * weight_4[19] +
                            value_42 * weight_4[20] +
                            value_43 * weight_4[21] +
                            value_44 * weight_4[22] +
                            value_45 * weight_4[23] +
                            value_46 * weight_4[24] +
                            value_47 * weight_4[25] +
                            value_48 * weight_4[26];
            conv_out_4_3 =  value_40 * weight_4[27] +
                            value_41 * weight_4[28] +
                            value_42 * weight_4[29] +
                            value_43 * weight_4[30] +
                            value_44 * weight_4[31] +
                            value_45 * weight_4[32] +
                            value_46 * weight_4[33] +
                            value_47 * weight_4[34] +
                            value_48 * weight_4[35];
            conv_out_4_4 =  value_40 * weight_4[36] +
                            value_41 * weight_4[37] +
                            value_42 * weight_4[38] +
                            value_43 * weight_4[39] +
                            value_44 * weight_4[40] +
                            value_45 * weight_4[41] +
                            value_46 * weight_4[42] +
                            value_47 * weight_4[43] +
                            value_48 * weight_4[44];                                                            
            conv_out_4 = bias_4 + conv_out_4_0 + conv_out_4_1 +conv_out_4_2 +conv_out_4_3 +conv_out_4_4; //자리수 절삭할것
            if(conv_out_4<0) conv_out_4 =0;
        end
        else valid_out_calc =0;               
     end
endmodule

module conv2d_1_calc_YYB(
    input clk, reset_p,
    input valid_buf,
    input [7:0] value_00, value_01, value_02, value_03, value_04,
                value_05, value_06, value_07, value_08,
    input [7:0] value_10, value_11, value_12, value_13, value_14, 
                value_15, value_16, value_17, value_18, 
    input [7:0] value_20, value_21, value_22, value_23, value_24, 
                value_25, value_26, value_27, value_28, 
    input [7:0] value_30, value_31, value_32, value_33, value_34, 
                value_35, value_36, value_37, value_38, 
    input [7:0] value_40, value_41, value_42, value_43, value_44, 
                value_45, value_46, value_47, value_48,                      
             
    output reg signed [22:0] conv_out_0,
    output reg signed [22:0] conv_out_1,
    output reg signed [22:0] conv_out_2,
    output reg signed [22:0] conv_out_3,
    output reg signed [22:0] conv_out_4,
    output reg signed [22:0] conv_out_5,
    output reg valid_out_calc
);

    localparam ROW =3;
    localparam COLMN = 3;
    reg [7:0] buffer_0 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_1 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_2 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_3 [0:COLMN -1][0:ROW -1];
    reg [7:0] buffer_4 [0:COLMN -1][0:ROW -1];
    
    reg signed [7:0] weight_00 [0:8];
    reg signed [7:0] weight_01 [0:8];
    reg signed [7:0] weight_02 [0:8];
    reg signed [7:0] weight_03 [0:8];
    reg signed [7:0] weight_04 [0:8];
    
    reg signed [7:0] weight_10 [0:8];
    reg signed [7:0] weight_11 [0:8];
    reg signed [7:0] weight_12 [0:8];
    reg signed [7:0] weight_13 [0:8];
    reg signed [7:0] weight_14 [0:8];
    
    reg signed [7:0] weight_20 [0:8];
    reg signed [7:0] weight_21 [0:8];
    reg signed [7:0] weight_22 [0:8];
    reg signed [7:0] weight_23 [0:8];
    reg signed [7:0] weight_24 [0:8];
    
    reg signed [7:0] weight_30 [0:8];
    reg signed [7:0] weight_31 [0:8];
    reg signed [7:0] weight_32 [0:8];
    reg signed [7:0] weight_33 [0:8];
    reg signed [7:0] weight_34 [0:8];
    
    reg signed [7:0] weight_40 [0:8];
    reg signed [7:0] weight_41 [0:8];
    reg signed [7:0] weight_42 [0:8];
    reg signed [7:0] weight_43 [0:8];
    reg signed [7:0] weight_44 [0:8];
   
    reg signed [7:0] weight_50 [0:8];
    reg signed [7:0] weight_51 [0:8];
    reg signed [7:0] weight_52 [0:8];
    reg signed [7:0] weight_53 [0:8];
    reg signed [7:0] weight_54 [0:8];
    
    reg signed [7:0] bias [0:5];
    
    initial begin
        $readmemh("conv2d_1_filters_00.txt",weight_00);
        $readmemh("conv2d_1_filters_01.txt",weight_01);
        $readmemh("conv2d_1_filters_02.txt",weight_02);
        $readmemh("conv2d_1_filters_03.txt",weight_03);
        $readmemh("conv2d_1_filters_04.txt",weight_04);

        $readmemh("conv2d_1_filters_10.txt",weight_10);
        $readmemh("conv2d_1_filters_11.txt",weight_11);
        $readmemh("conv2d_1_filters_12.txt",weight_12);
        $readmemh("conv2d_1_filters_13.txt",weight_13);
        $readmemh("conv2d_1_filters_14.txt",weight_14);

        $readmemh("conv2d_1_filters_20.txt",weight_20);
        $readmemh("conv2d_1_filters_21.txt",weight_21);
        $readmemh("conv2d_1_filters_22.txt",weight_22);
        $readmemh("conv2d_1_filters_23.txt",weight_23);
        $readmemh("conv2d_1_filters_24.txt",weight_24);

        $readmemh("conv2d_1_filters_30.txt",weight_30);
        $readmemh("conv2d_1_filters_31.txt",weight_31);
        $readmemh("conv2d_1_filters_32.txt",weight_32);
        $readmemh("conv2d_1_filters_33.txt",weight_33);
        $readmemh("conv2d_1_filters_34.txt",weight_34);

        $readmemh("conv2d_1_filters_40.txt",weight_40);
        $readmemh("conv2d_1_filters_41.txt",weight_41);
        $readmemh("conv2d_1_filters_42.txt",weight_42);
        $readmemh("conv2d_1_filters_43.txt",weight_43);
        $readmemh("conv2d_1_filters_44.txt",weight_44);

        $readmemh("conv2d_1_filters_50.txt",weight_50);
        $readmemh("conv2d_1_filters_51.txt",weight_51);
        $readmemh("conv2d_1_filters_52.txt",weight_52);
        $readmemh("conv2d_1_filters_53.txt",weight_53);
        $readmemh("conv2d_1_filters_54.txt",weight_54);

        $readmemh("conv2d_1_bias.txt",bias);
    end

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            conv_out_0 <= 0;
            conv_out_1 <= 0;
            conv_out_2 <= 0;
            conv_out_3 <= 0;
            conv_out_4 <= 0;
            conv_out_5 <= 0;
            valid_out_calc <= 0;
        end
        else if(valid_buf) begin
            valid_out_calc <= 1;

            conv_out_0 =
                value_00 * weight_00[0] + value_01 * weight_00[1] + value_02 * weight_00[2] +
                value_03 * weight_00[3] + value_04 * weight_00[4] + value_05 * weight_00[5] +
                value_06 * weight_00[6] + value_07 * weight_00[7] + value_08 * weight_00[8] +

                value_10 * weight_01[0] + value_11 * weight_01[1] + value_12 * weight_01[2] +
                value_13 * weight_01[3] + value_14 * weight_01[4] + value_15 * weight_01[5] +
                value_16 * weight_01[6] + value_17 * weight_01[7] + value_18 * weight_01[8] +

                value_20 * weight_02[0] + value_21 * weight_02[1] + value_22 * weight_02[2] +
                value_23 * weight_02[3] + value_24 * weight_02[4] + value_25 * weight_02[5] +
                value_26 * weight_02[6] + value_27 * weight_02[7] + value_28 * weight_02[8] +

                value_30 * weight_03[0] + value_31 * weight_03[1] + value_32 * weight_03[2] +
                value_33 * weight_03[3] + value_34 * weight_03[4] + value_35 * weight_03[5] +
                value_36 * weight_03[6] + value_37 * weight_03[7] + value_38 * weight_03[8] +

                value_40 * weight_04[0] + value_41 * weight_04[1] + value_42 * weight_04[2] +
                value_43 * weight_04[3] + value_44 * weight_04[4] + value_45 * weight_04[5] +
                value_46 * weight_04[6] + value_47 * weight_04[7] + value_48 * weight_04[8] +
                bias[0];
            if(conv_out_0 < 0) conv_out_0 = 0;  // ReLU

            conv_out_1 =
                value_00 * weight_10[0] + value_01 * weight_10[1] + value_02 * weight_10[2] +
                value_03 * weight_10[3] + value_04 * weight_10[4] + value_05 * weight_10[5] +
                value_06 * weight_10[6] + value_07 * weight_10[7] + value_08 * weight_10[8] +

                value_10 * weight_11[0] + value_11 * weight_11[1] + value_12 * weight_11[2] +
                value_13 * weight_11[3] + value_14 * weight_11[4] + value_15 * weight_11[5] +
                value_16 * weight_11[6] + value_17 * weight_11[7] + value_18 * weight_11[8] +

                value_20 * weight_12[0] + value_21 * weight_12[1] + value_22 * weight_12[2] +
                value_23 * weight_12[3] + value_24 * weight_12[4] + value_25 * weight_12[5] +
                value_26 * weight_12[6] + value_27 * weight_12[7] + value_28 * weight_12[8] +

                value_30 * weight_13[0] + value_31 * weight_13[1] + value_32 * weight_13[2] +
                value_33 * weight_13[3] + value_34 * weight_13[4] + value_35 * weight_13[5] +
                value_36 * weight_13[6] + value_37 * weight_13[7] + value_38 * weight_13[8] +

                value_40 * weight_14[0] + value_41 * weight_14[1] + value_42 * weight_14[2] +
                value_43 * weight_14[3] + value_44 * weight_14[4] + value_45 * weight_14[5] +
                value_46 * weight_14[6] + value_47 * weight_14[7] + value_48 * weight_14[8] +
                bias[1];
            if(conv_out_1 < 0) conv_out_1 = 0;

            conv_out_2 =
                value_00 * weight_20[0] + value_01 * weight_20[1] + value_02 * weight_20[2] +
                value_03 * weight_20[3] + value_04 * weight_20[4] + value_05 * weight_20[5] +
                value_06 * weight_20[6] + value_07 * weight_20[7] + value_08 * weight_20[8] +

                value_10 * weight_21[0] + value_11 * weight_21[1] + value_12 * weight_21[2] +
                value_13 * weight_21[3] + value_14 * weight_21[4] + value_15 * weight_21[5] +
                value_16 * weight_21[6] + value_17 * weight_21[7] + value_18 * weight_21[8] +

                value_20 * weight_22[0] + value_21 * weight_22[1] + value_22 * weight_22[2] +
                value_23 * weight_22[3] + value_24 * weight_22[4] + value_25 * weight_22[5] +
                value_26 * weight_22[6] + value_27 * weight_22[7] + value_28 * weight_22[8] +

                value_30 * weight_23[0] + value_31 * weight_23[1] + value_32 * weight_23[2] +
                value_33 * weight_23[3] + value_34 * weight_23[4] + value_35 * weight_23[5] +
                value_36 * weight_23[6] + value_37 * weight_23[7] + value_38 * weight_23[8] +

                value_40 * weight_24[0] + value_41 * weight_24[1] + value_42 * weight_24[2] +
                value_43 * weight_24[3] + value_44 * weight_24[4] + value_45 * weight_24[5] +
                value_46 * weight_24[6] + value_47 * weight_24[7] + value_48 * weight_24[8] +
                bias[2];
            if(conv_out_2 < 0) conv_out_2 = 0;

            conv_out_3 =
                value_00 * weight_30[0] + value_01 * weight_30[1] + value_02 * weight_30[2] +
                value_03 * weight_30[3] + value_04 * weight_30[4] + value_05 * weight_30[5] +
                value_06 * weight_30[6] + value_07 * weight_30[7] + value_08 * weight_30[8] +

                value_10 * weight_31[0] + value_11 * weight_31[1] + value_12 * weight_31[2] +
                value_13 * weight_31[3] + value_14 * weight_31[4] + value_15 * weight_31[5] +
                value_16 * weight_31[6] + value_17 * weight_31[7] + value_18 * weight_31[8] +

                value_20 * weight_32[0] + value_21 * weight_32[1] + value_22 * weight_32[2] +
                value_23 * weight_32[3] + value_24 * weight_32[4] + value_25 * weight_32[5] +
                value_26 * weight_32[6] + value_27 * weight_32[7] + value_28 * weight_32[8] +

                value_30 * weight_33[0] + value_31 * weight_33[1] + value_32 * weight_33[2] +
                value_33 * weight_33[3] + value_34 * weight_33[4] + value_35 * weight_33[5] +
                value_36 * weight_33[6] + value_37 * weight_33[7] + value_38 * weight_33[8] +

                value_40 * weight_34[0] + value_41 * weight_34[1] + value_42 * weight_34[2] +
                value_43 * weight_34[3] + value_44 * weight_34[4] + value_45 * weight_34[5] +
                value_46 * weight_34[6] + value_47 * weight_34[7] + value_48 * weight_34[8] +
                bias[3];
            if(conv_out_3 < 0) conv_out_3 = 0;

            // ── 필터 4 ─────────────────────────────────────
            conv_out_4 =
                value_00 * weight_40[0] + value_01 * weight_40[1] + value_02 * weight_40[2] +
                value_03 * weight_40[3] + value_04 * weight_40[4] + value_05 * weight_40[5] +
                value_06 * weight_40[6] + value_07 * weight_40[7] + value_08 * weight_40[8] +

                value_10 * weight_41[0] + value_11 * weight_41[1] + value_12 * weight_41[2] +
                value_13 * weight_41[3] + value_14 * weight_41[4] + value_15 * weight_41[5] +
                value_16 * weight_41[6] + value_17 * weight_41[7] + value_18 * weight_41[8] +

                value_20 * weight_42[0] + value_21 * weight_42[1] + value_22 * weight_42[2] +
                value_23 * weight_42[3] + value_24 * weight_42[4] + value_25 * weight_42[5] +
                value_26 * weight_42[6] + value_27 * weight_42[7] + value_28 * weight_42[8] +

                value_30 * weight_43[0] + value_31 * weight_43[1] + value_32 * weight_43[2] +
                value_33 * weight_43[3] + value_34 * weight_43[4] + value_35 * weight_43[5] +
                value_36 * weight_43[6] + value_37 * weight_43[7] + value_38 * weight_43[8] +

                value_40 * weight_44[0] + value_41 * weight_44[1] + value_42 * weight_44[2] +
                value_43 * weight_44[3] + value_44 * weight_44[4] + value_45 * weight_44[5] +
                value_46 * weight_44[6] + value_47 * weight_44[7] + value_48 * weight_44[8] +
                bias[4];
            if(conv_out_4 < 0) conv_out_4 = 0;

            conv_out_5 =
                value_00 * weight_50[0] + value_01 * weight_50[1] + value_02 * weight_50[2] +
                value_03 * weight_50[3] + value_04 * weight_50[4] + value_05 * weight_50[5] +
                value_06 * weight_50[6] + value_07 * weight_50[7] + value_08 * weight_50[8] +

                value_10 * weight_51[0] + value_11 * weight_51[1] + value_12 * weight_51[2] +
                value_13 * weight_51[3] + value_14 * weight_51[4] + value_15 * weight_51[5] +
                value_16 * weight_51[6] + value_17 * weight_51[7] + value_18 * weight_51[8] +

                value_20 * weight_52[0] + value_21 * weight_52[1] + value_22 * weight_52[2] +
                value_23 * weight_52[3] + value_24 * weight_52[4] + value_25 * weight_52[5] +
                value_26 * weight_52[6] + value_27 * weight_52[7] + value_28 * weight_52[8] +

                value_30 * weight_53[0] + value_31 * weight_53[1] + value_32 * weight_53[2] +
                value_33 * weight_53[3] + value_34 * weight_53[4] + value_35 * weight_53[5] +
                value_36 * weight_53[6] + value_37 * weight_53[7] + value_38 * weight_53[8] +

                value_40 * weight_54[0] + value_41 * weight_54[1] + value_42 * weight_54[2] +
                value_43 * weight_54[3] + value_44 * weight_54[4] + value_45 * weight_54[5] +
                value_46 * weight_54[6] + value_47 * weight_54[7] + value_48 * weight_54[8] +
                bias[5];
            if(conv_out_5 < 0) conv_out_5 = 0;
        end
        else valid_out_calc <= 0;
    end

endmodule
























