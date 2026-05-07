`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module test_top(
    input [15:0] slide,
    output [15:0] led);
    
    assign led = slide;
    
endmodule

module FND_top(
    input clk, reset_p,
    input [15:0] hex_value,
    output [7:0] seg,
    output [3:0] com);

    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(hex_value), .seg(seg), .com(com));

endmodule

module watch_top(
    input clk, reset_p,
    input [3:0] button,
    output [7:0] seg,
    output [3:0] com);
    
    
    wire [2:0] btn_pedge, btn_nedge;
    button_cntr btncntr0(.clk(clk), .reset_p(reset_p), 
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_cntr btncntr1(.clk(clk), .reset_p(reset_p), 
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_cntr btncntr2(.clk(clk), .reset_p(reset_p), 
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    
    wire [7:0] sec, min;
    watch watch0(.clk(clk), .reset_p(reset_p), 
                 .btn(btn_pedge), .sec(sec), .min(min));
    
    wire [7:0] sec_bcd, min_bcd;
    bin_to_dec btd_sec(.bin(sec), .bcd(sec_bcd));
    bin_to_dec btd_min(.bin(min), .bcd(min_bcd));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value({min_bcd, sec_bcd}), .seg(seg), .com(com));
    
endmodule

module cook_timer_top(
    input clk, reset_p,
    input [3:0] button,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led);
    
    wire [3:0] btn_pedge, btn_nedge;
    button_cntr btncntr0(.clk(clk), .reset_p(reset_p), 
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_cntr btncntr1(.clk(clk), .reset_p(reset_p), 
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_cntr btncntr2(.clk(clk), .reset_p(reset_p), 
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    button_cntr btncntr3(.clk(clk), .reset_p(reset_p), 
        .btn(button[3]), .btn_pedge(btn_pedge[3]), .btn_nedge(btn_nedge[3]));

    wire [7:0] sec, min;
    wire alarm;
    cook_timer ctimer(.clk(clk), .reset_p(reset_p),
                      .btn_start(btn_pedge[0]), .inc_sec(btn_pedge[1]), 
                      .inc_min(btn_pedge[2]), .alarm_off(btn_pedge[3]),
                      .sec(sec), .min(min), .alarm(alarm));
                      
    wire [7:0] sec_bcd, min_bcd;
    bin_to_dec btd_sec(.bin(sec), .bcd(sec_bcd));
    bin_to_dec btd_min(.bin(min), .bcd(min_bcd));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value({min_bcd, sec_bcd}), .seg(seg), .com(com));
                
    assign led[0] = alarm;

endmodule

module stop_watch_top(
    input clk, reset_p,
    input [2:0] button,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led);

    wire [2:0] btn_pedge, btn_nedge;
    button_cntr btncntr0(.clk(clk), .reset_p(reset_p), 
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_cntr btncntr1(.clk(clk), .reset_p(reset_p), 
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_cntr btncntr2(.clk(clk), .reset_p(reset_p), 
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    wire [7:0] fnd_sec, fnd_csec;    
    wire start_stop, lap;
    assign led[0] = start_stop;
    assign led[5] = lap;
    stop_watch sw0(.clk(clk), .reset_p(reset_p),
                   .btn_start(btn_pedge[0]), .btn_lap(btn_pedge[1]), 
                   .btn_clear(btn_pedge[2]),
                   .fnd_sec(fnd_sec), .fnd_csec(fnd_csec),
                   .start_stop(start_stop), .lap(lap));
                   
    wire [7:0] sec_bcd, csec_bcd;
    bin_to_dec btd_sec(.bin(fnd_sec), .bcd(sec_bcd));
    bin_to_dec btd_min(.bin(fnd_csec), .bcd(csec_bcd));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value({sec_bcd, csec_bcd}), .seg(seg), .com(com));

endmodule

module multifunction_watch_top(
    input clk, reset_p,
    input [3:0] button,
    input [15:0] slide,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led,
    output buz);
    
    localparam WATCH = 3'b001;
    localparam COOK_TIMER = 3'b010;
    localparam STOPWATCH = 3'b100;
    
    wire [3:0] btn_pedge, btn_nedge;
    button_cntr btncntr0(.clk(clk), .reset_p(reset_p), 
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_cntr btncntr1(.clk(clk), .reset_p(reset_p), 
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_cntr btncntr2(.clk(clk), .reset_p(reset_p), 
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    button_cntr btncntr3(.clk(clk), .reset_p(reset_p), 
        .btn(button[3]), .btn_pedge(btn_pedge[3]), .btn_nedge(btn_nedge[3]));
        
    reg [2:0] mode, next_mode;
    assign led[7:5] = mode;
    always @(*)begin
        if(reset_p)next_mode = WATCH;
        else if(btn_pedge[3])begin
            if(mode == WATCH)next_mode = COOK_TIMER;
            else if(mode == COOK_TIMER && next_mode == COOK_TIMER)next_mode = STOPWATCH;
            else if(mode == STOPWATCH)next_mode = WATCH;
        end
        else if(mode == COOK_TIMER && (btn_pedge[0] || btn_pedge[1] || btn_pedge[1]))next_mode = WATCH;
        else next_mode = WATCH;
    end
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)mode = WATCH;
        else if(btn_pedge[3])begin
            mode = next_mode;
        end
    end
    reg [2:0] watch_btn, cook_btn, stopwatch_btn;
    always @(*)begin
        case(mode)
            WATCH: begin
                watch_btn = btn_pedge[2:0];
                cook_btn = 0;
                stopwatch_btn = 0;
            end
            COOK_TIMER: begin
                watch_btn = 0;
                cook_btn = btn_pedge[2:0];
                stopwatch_btn = 0;
            end
            STOPWATCH: begin
                watch_btn = 0;
                cook_btn = 0;
                stopwatch_btn = btn_pedge[2:0];
            end
        endcase
    end
        
    wire [7:0] watch_sec, watch_min;
    watch watch0(.clk(clk), .reset_p(reset_p), 
                 .btn(watch_btn), .sec(watch_sec), .min(watch_min));
                 
    wire [7:0] cook_sec, cook_min;
    wire alarm;
    cook_timer ctimer(.clk(clk), .reset_p(reset_p),
                      .btn_start(cook_btn[0]), .inc_sec(cook_btn[1]), 
                      .inc_min(cook_btn[2]), .alarm_off(slide[0]),
                      .sec(cook_sec), .min(cook_min), .alarm(alarm));
                      
    wire [7:0] stopwatch_sec, stopwatch_csec;    
    wire start_stop, lap;
    assign led[0] = start_stop;
    assign led[1] = lap;
    stop_watch sw0(.clk(clk), .reset_p(reset_p),
                   .btn_start(stopwatch_btn[0]), .btn_lap(stopwatch_btn[1]), 
                   .btn_clear(stopwatch_btn[2]),
                   .fnd_sec(stopwatch_sec), .fnd_csec(stopwatch_csec),
                   .start_stop(start_stop), .lap(lap)); 
                   
    wire [7:0] bcd_low, bcd_high, bin_low, bin_high;
    
    assign bin_low = mode == COOK_TIMER ? cook_sec :
                     mode == STOPWATCH ? stopwatch_csec : watch_sec;
                     
    assign bin_high = mode == COOK_TIMER ? cook_min :
                      mode == STOPWATCH ? stopwatch_sec : watch_min;                 
    
    bin_to_dec btd_sec(.bin(bin_low), .bcd(bcd_low));
    bin_to_dec btd_min(.bin(bin_high), .bcd(bcd_high));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value({bcd_high, bcd_low}), .seg(seg), .com(com)); 
                
    assign buz = alarm;
    assign led[15] = alarm;            
 
endmodule

module play_buzz_top(
    input clk, reset_p,
    output trans_cp);

    freq_generator #(.FREQ(15_000)) fg (
        .clk(clk), .reset_p(reset_p), .trans_cp(trans_cp));

endmodule

module led_pwm_top(
    input clk, reset_p,
    output led_r, led_g, led_b,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] com);

    integer cnt;
    always @(posedge clk)cnt = cnt + 1;
    
    reg [7:0] cnt_200;
    reg flag;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            cnt_200 = 0;
            flag = 0;
        end
        else if(cnt[23] && flag == 0)begin
            flag = 1;
            if(cnt_200 >= 199)cnt_200 = 0;
            else cnt_200 = cnt_200 + 1;
        end
        else if(cnt[23] == 0)flag = 0;
        
    end
    
    pwm_Nfreq_Nstep led_pwm(.clk(clk), .reset_p(reset_p), .duty(cnt_200), .pwm(led[0]));
    
    pwm_Nfreq_Nstep red_pwm(.clk(clk), .reset_p(reset_p), .duty(cnt[27:20]), .pwm(led_r));
    pwm_Nfreq_Nstep green_pwm(.clk(clk), .reset_p(reset_p), .duty(cnt[28:21]), .pwm(led_g));
    pwm_Nfreq_Nstep blue_pwm(.clk(clk), .reset_p(reset_p), .duty(cnt[29:22]), .pwm(led_b));
    
    wire [15:0] bcd_duty;
    bin_to_dec btd_duty(.bin(cnt_200), .bcd(bcd_duty));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(bcd_duty), .seg(seg), .com(com)); 

endmodule

module fade_in_fade_out(
    input clk, reset_p,
    input speed_cp,
    output reg [6:0] duty);

    reg edge_flag;
    reg up_down;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            duty = 0;
            edge_flag = 0;
            up_down = 0;
        end
        else if(speed_cp && edge_flag == 0)begin
            edge_flag = 1;
            if(duty == 127)up_down = 0;
            else if(duty == 0)up_down = 1;
            
            if(up_down)duty = duty + 1;
            else duty = duty - 1;
        end
        else if(speed_cp == 0)edge_flag = 0;
    end
endmodule

module fade_in_fade_out_8(
    input clk, reset_p,
    input speed_cp,
    output reg [7:0] duty);

    reg edge_flag;
    reg up_down;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            duty = 0;
            edge_flag = 0;
            up_down = 0;
        end
        else if(speed_cp && edge_flag == 0)begin
            edge_flag = 1;
            if(up_down)duty = duty + 1;
            else duty = duty - 1;
        end
        else if(speed_cp == 0)begin
            edge_flag = 0;
            if(duty == 191)up_down = 0;
            else if(duty == 0)up_down = 1;
        end
    end
endmodule

module x_mas_tree_top(
    input clk, reset_p,
    input [3:0] button,
    output [3:0] blinky,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] com);
    
    wire [3:0] btn_pedge, btn_nedge;
    button_cntr btncntr0(.clk(clk), .reset_p(reset_p), 
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_cntr btncntr1(.clk(clk), .reset_p(reset_p), 
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_cntr btncntr2(.clk(clk), .reset_p(reset_p), 
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    button_cntr btncntr3(.clk(clk), .reset_p(reset_p), 
        .btn(button[3]), .btn_pedge(btn_pedge[3]), .btn_nedge(btn_nedge[3]));
    

    integer cnt;
    always @(posedge clk)cnt = cnt + 1;
    
    localparam COMBINATION  = 8'b0000_0001;
    localparam IN_WAVE      = 8'b0000_0010;
    localparam SEQUENTIAL   = 8'b0000_0100;
    localparam SLO_GLO      = 8'b0000_1000;
    localparam CHASING      = 8'b0001_0000;
    localparam SLOW_FADE    = 8'b0010_0000;
    localparam TWINCLE      = 8'b0100_0000;
    localparam STEADY_ON    = 8'b1000_0000;
    
    reg [7:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = COMBINATION;
        else state = next_state;
    end
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)next_state = COMBINATION;
        else if(btn_pedge[0])begin
            case(state)
                COMBINATION : next_state = IN_WAVE;
                IN_WAVE     : next_state = SEQUENTIAL;
                SEQUENTIAL  : next_state = SLO_GLO;
                SLO_GLO     : next_state = CHASING;
                CHASING     : next_state = SLOW_FADE;
                SLOW_FADE   : next_state = TWINCLE;
                TWINCLE     : next_state = STEADY_ON;
                default     : next_state = COMBINATION;
            endcase
        end
    end
    assign led[7:0] = state;
    wire [6:0] fade_duty01, fade_duty03, fade_duty04;
    wire [7:0] fade_duty02;
    reg [3:0] speed_cp;
    reg duty_reset_p;
    fade_in_fade_out   blinky01(clk, reset_p, speed_cp[0], fade_duty01);
    fade_in_fade_out_8 blinky02(clk, reset_p, speed_cp[1], fade_duty02);
    fade_in_fade_out blinky03(clk, reset_p, speed_cp[2], fade_duty03);
    fade_in_fade_out blinky04(clk, reset_p, speed_cp[3], fade_duty04);
    
    reg [6:0] duty [0:4];
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            duty[0] = 0;
            duty[1] = 0;
            duty[2] = 0;
            duty[3] = 0;
            speed_cp = 0;
            duty_reset_p = 0;
        end
        else begin
            case(state)
                COMBINATION :begin
                    duty[0] = 0;
                    duty[1] = 0;
                    duty[2] = 0;
                    duty[3] = 0;
                    speed_cp = 0;
                end
                IN_WAVE     :begin
                    if(cnt[29])begin
                        speed_cp[0] = cnt[16];
                    end
                    else begin
                        speed_cp[0] = cnt[19];
                    end
                    duty[0] = fade_duty01;
                    duty[1] = 127 - fade_duty01;
                    duty[2] = fade_duty01;
                    duty[3] = 127 - fade_duty01;
                end
                SEQUENTIAL  :begin
                    if(cnt[29])begin
                        if(cnt[28])begin
                            duty[0] = {7{cnt[23]}};
                            duty[1] = ~{7{cnt[23]}};
                            duty[2] = {7{cnt[23]}};
                            duty[3] = ~{7{cnt[23]}};
                        end
                        else begin
                            duty[0] = {7{cnt[24]}};
                            duty[1] = ~{7{cnt[24]}};
                            duty[2] = {7{cnt[24]}};
                            duty[3] = ~{7{cnt[24]}};
                        end
                    end
                    else begin
                        if(cnt[28])begin
                            duty[0] = {7{cnt[25]}};
                            duty[1] = ~{7{cnt[25]}};
                            duty[2] = {7{cnt[25]}};
                            duty[3] = ~{7{cnt[25]}};
                        end
                        else begin
                            duty[0] = {7{cnt[26]}};
                            duty[1] = ~{7{cnt[26]}};
                            duty[2] = {7{cnt[26]}};
                            duty[3] = ~{7{cnt[26]}};
                        end
                    end
                end
                SLO_GLO     :begin
                    speed_cp[1] = cnt[21];
                    if(fade_duty02 <= 127)duty[0] = fade_duty02;
                    else duty[0] = 127;
                    
                    if(fade_duty02 <= 31)duty[1] = 0;
                    else if(fade_duty02 <= 159)duty[1] = fade_duty02 - 32;
                    else duty[1] = 127;
                    
                    if(fade_duty02 <= 63)duty[2] = 0;
                    else if(fade_duty02 <= 191)duty[2] = fade_duty02 - 64;
                    else duty[2] = 127;
                    
                    if(fade_duty02 <= 95)duty[3] = 0;
                    else if(fade_duty02 <= 223)duty[3] = fade_duty02 - 96;
                    else duty[3] = 127;
                end
                CHASING     :begin
                    if(cnt[27])begin
                        duty[0] = {7{cnt[24]}};
                        duty[1] = ~{7{cnt[24]}};
                        duty[2] = {7{cnt[24]}};
                        duty[3] = ~{7{cnt[24]}};
                    end
                    else begin
                        duty[0] = {7{cnt[23]}};
                        duty[1] = ~{7{cnt[23]}};
                        duty[2] = {7{cnt[23]}};
                        duty[3] = ~{7{cnt[23]}};
                    end
                end
                SLOW_FADE   :begin
                    speed_cp[0] = cnt[21];
                    duty[0] = fade_duty01;
                    duty[1] = fade_duty01;
                    duty[2] = fade_duty01;
                    duty[3] = fade_duty01;
                end
                TWINCLE     :begin
                    if(cnt[28])begin
                        duty[0] = {7{cnt[24]}};
                        duty[1] = 0;
                        duty[2] = {7{cnt[24]}};
                        duty[3] = 0;
                    end
                    else begin
                        duty[0] = 0;
                        duty[1] = {7{cnt[24]}};
                        duty[2] = 0;
                        duty[3] = {7{cnt[24]}};
                    end
                end
                STEADY_ON   :begin
                    duty[0] = 127; 
                    duty[1] = 127; 
                    duty[2] = 127; 
                    duty[3] = 127; 
                end
            endcase
        end
    end
    
    
    
    pwm_Nfreq_Nstep #(.DUTY_STEP(128)) blinky_pwm01(.clk(clk), .reset_p(reset_p), .duty(duty[0]), .pwm(blinky[0]));
    pwm_Nfreq_Nstep #(.DUTY_STEP(128)) blinky_pwm02(.clk(clk), .reset_p(reset_p), .duty(duty[1]), .pwm(blinky[1]));
    pwm_Nfreq_Nstep #(.DUTY_STEP(128)) blinky_pwm03(.clk(clk), .reset_p(reset_p), .duty(duty[2]), .pwm(blinky[2]));
    pwm_Nfreq_Nstep #(.DUTY_STEP(128)) blinky_pwm04(.clk(clk), .reset_p(reset_p), .duty(duty[3]), .pwm(blinky[3]));
    
    wire [15:0] bcd_duty;
    bin_to_dec btd_duty(.bin(fade_duty02), .bcd(bcd_duty));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(bcd_duty), .seg(seg), .com(com)); 

endmodule

module sg_90_top(
    input clk, reset_p,
    input [3:0] button, 
    output sg90_pwm,
    output [7:0] seg,
    output [3:0] com);
    
    wire [3:0] btn_pedge, btn_nedge;
    button_cntr btncntr0(.clk(clk), .reset_p(reset_p), 
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_cntr btncntr1(.clk(clk), .reset_p(reset_p), 
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_cntr btncntr2(.clk(clk), .reset_p(reset_p), 
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    button_cntr btncntr3(.clk(clk), .reset_p(reset_p), 
        .btn(button[3]), .btn_pedge(btn_pedge[3]), .btn_nedge(btn_nedge[3]));
    
    reg [7:0] duty;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)duty = 12;
        else begin
            if(btn_pedge[1] && duty > 3)duty = duty - 1;
            if(btn_pedge[2] && duty < 21)duty = duty + 1;
        end
    end
    
    pwm_Nfreq_Nstep #(.PWM_FREQ(50), .DUTY_STEP(180)) sg_pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm(sg90_pwm));

    wire [15:0] bcd_duty;
    bin_to_dec btd_duty(.bin(duty-3), .bcd(bcd_duty));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p), 
            .fnd_value({4'd0, bcd_duty[7:0], 4'd0}), .seg(seg), .com(com)); 
endmodule

module adc_ch6_top(
    input clk, reset_p,
    input vauxp6, vauxn6,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led);
    
    wire [4:0] channel_out;
    wire eoc_out;
    wire [15:0] do_out;
    xadc_wiz_0 adc_ch6(
          .daddr_in({2'b00, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out));
     
     wire eoc_out_pedge;
     edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                        .cp(eoc_out), .p_edge(eoc_out_pedge));     
     reg [11:0] adc_value;
     always @(posedge clk, posedge reset_p)begin
        if(reset_p)adc_value = 0;
        else if(eoc_out_pedge)adc_value = do_out[15:4];
     end
     
    wire [15:0] bcd_adc_value;
    bin_to_dec btd(.bin(adc_value), .bcd(bcd_adc_value));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p), 
            .fnd_value(bcd_adc_value), .seg(seg), .com(com)); 
            
    assign led[0] = adc_value[11:8] >= 1;
    assign led[1] = adc_value[11:8] >= 2;
    assign led[2] = adc_value[11:8] >= 3;
    assign led[3] = adc_value[11:8] >= 4;
    assign led[4] = adc_value[11:8] >= 5;
    assign led[5] = adc_value[11:8] >= 6;
    assign led[6] = adc_value[11:8] >= 7;
    assign led[7] = adc_value[11:8] >= 8;
    assign led[8] = adc_value[11:8] >= 9;
    assign led[9] = adc_value[11:8] >= 10;
    assign led[10] = adc_value[11:8] >= 11;
    assign led[11] = adc_value[11:8] >= 12;
    assign led[12] = adc_value[11:8] >= 13;
    assign led[13] = adc_value[11:8] >= 14;
    assign led[14] = adc_value[11:8] >= 15;

endmodule

module adc_sequence_top(
    input clk, reset_p,
    input vauxp6, vauxn6, vauxp15, vauxn15,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led);
    
    wire [4:0] channel_out;
    wire eoc_out;
    wire [15:0] do_out;
    adc_2ch_sequence joystick(
          .daddr_in({2'b00, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
          .vauxp15(vauxp15),             // Auxiliary channel 15
          .vauxn15(vauxn15),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out));
          
    reg [11:0] adc_value_x, adc_value_y;
    wire eoc_out_pedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                        .cp(eoc_out), .p_edge(eoc_out_pedge));
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            adc_value_x = 0;
            adc_value_y = 0;
        end
        else if(eoc_out_pedge)begin
            case(channel_out[3:0])
                6: adc_value_x = do_out[15:4];
                15:adc_value_y = do_out[15:4];
            endcase
        end
    end
    
    wire [7:0] x_bcd, y_bcd;
    bin_to_dec btd_x(.bin(adc_value_x[11:6]), .bcd(x_bcd));
    bin_to_dec btd_y(.bin(adc_value_y[11:6]), .bcd(y_bcd));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p), 
            .fnd_value({x_bcd, y_bcd}), .seg(seg), .com(com));
            
            
    assign led[0] = adc_value_x[11:9] >= 8;
    assign led[1] = adc_value_x[11:9] >= 7;
    assign led[2] = adc_value_x[11:9] >= 6;
    assign led[3] = adc_value_x[11:9] >= 5;
    assign led[4] = adc_value_x[11:9] >= 4;
    assign led[5] = adc_value_x[11:9] >= 3;
    assign led[6] = adc_value_x[11:9] >= 2;
    assign led[7] = adc_value_x[11:9] >= 1;
    assign led[8] = adc_value_y[11:9] >= 1;
    assign led[9] = adc_value_y[11:9] >= 2;
    assign led[10] = adc_value_y[11:9] >= 3;
    assign led[11] = adc_value_y[11:9] >= 4;
    assign led[12] = adc_value_y[11:9] >= 5;
    assign led[13] = adc_value_y[11:9] >= 6;
    assign led[14] = adc_value_y[11:9] >= 7;        
    assign led[15] = adc_value_y[11:9] >= 8;        
            
endmodule

module ultra_sonic_top(
    input clk, reset_p,    
    input mode_sw,  // 10진수 16진수 변환 스위치
    input echo,
    output trig,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led);

    wire [8:0] distance_cm;
    hc_sr04_cntr ultra(
        .clk(clk), .reset_p(reset_p),
        .echo(echo), .trig(trig),
        .distance_cm(distance_cm));
    // wire [15:0] distance_bcd;
    // bin_to_dec btd_x(.bin(distance_cm), .bcd(distance_bcd));
    
    
    // FND_cntr fnd(
    //     .clk(clk), 
    //     .reset_p(reset_p), 
    //     .fnd_value(distance_bcd), 
    //     .seg(seg), 
    //     .com(com));

    FND_cntr fnd(
        .clk(clk), 
        .reset_p(reset_p), 
        // .fnd_value(distance_bcd),
        .hex_value({7'b0, distance_cm}), 
        .hex_bcd(mode_sw),
        .seg(seg), 
        .com(com));


endmodule

module dht11_top(
    input clk, reset_p,
    inout dht11_data,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led);
    
    wire [7:0] humidity, temperature;
    dht11_cntr dht(clk, reset_p, dht11_data, humidity, temperature, led);
    
    wire [7:0] humidity_bcd, temperature_bcd;
    bin_to_dec btd_humi(.bin(humidity), .bcd(humidity_bcd));
    bin_to_dec btd_tmpr(.bin(temperature), .bcd(temperature_bcd));
    
    FND_cntr fnd(.clk(clk), 
                 .reset_p(reset_p), 
                 .hex_value({humidity_bcd, temperature_bcd}), 
                 .hex_bcd(1), 
                 .seg(seg), 
                 .com(com));

endmodule

module i2c_master_top(
    input clk, reset_p,
    input slide,
    input comm_start,
    output scl, sda,
    output [15:0] led
);
    localparam light_on  = 8'b0000_1000;
    localparam light_off = 8'b0000_0000;
    
    wire [7:0] data;
    wire busy;
    assign data = slide ? light_on : light_off;
    I2C_master i2c(clk, reset_p, 7'h27, data, 1'b0, comm_start, scl, sda, busy, led);

endmodule

module i2c_txtlcd_top(
    input clk, reset_p,
    input [3:0] button,
    output scl, sda,
    output [15:0] led);

    wire [3:0] btn_pedge;
    button_cntr btncntr0(clk, reset_p, button[0], btn_pedge[0]);
    button_cntr btncntr1(clk, reset_p, button[1], btn_pedge[1]);
    button_cntr btncntr2(clk, reset_p, button[2], btn_pedge[2]);
    button_cntr btncntr3(clk, reset_p, button[3], btn_pedge[3]);
    
    integer cnt_sysclk;
    reg count_clk_e;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)cnt_sysclk = 0;
        else if(count_clk_e)cnt_sysclk = cnt_sysclk + 1;
        else cnt_sysclk = 0;
    end
    
    reg [7:0] send_buffer;
    reg send, rs;
    wire busy;
    i2c_lcd_send_byte send_byte(
        clk, reset_p, 7'h27, send_buffer,
        send, rs, scl, sda, busy, led);
    
    localparam IDLE                 = 6'b00_0001;
    localparam INIT                 = 6'b00_0010;
    localparam SEND_CHARACTER       = 6'b00_0100;
    localparam SHIFT_RIGHT_DISPLAY  = 6'b00_1000;
    localparam SHIFT_LEFT_DISPLAY   = 6'b01_0000;
    localparam SEND_ENGLISH         = 6'b10_0000;

    
    reg [5:0] state, next_state;
    always @(negedge clk, posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    reg init_flag;
    reg [10:0] cnt_data;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            init_flag = 0;
            cnt_data  = 0;
            count_clk_e = 0;
            send = 0;
            send_buffer = 0;
            rs = 0;
        end
        else begin
            case(state)
                IDLE               :begin
                    if(init_flag)begin
                        if(btn_pedge[0])next_state = SEND_CHARACTER;
                        if(btn_pedge[1])next_state = SHIFT_LEFT_DISPLAY;
                        if(btn_pedge[2])next_state = SHIFT_RIGHT_DISPLAY;
                        if(btn_pedge[3])next_state = SEND_ENGLISH;
                    end
                    else begin
                        if(cnt_sysclk <= 80_000_00)begin
                            count_clk_e = 1;
                        end
                        else begin
                            count_clk_e = 0;
                            next_state = INIT;
                        end
                    end
                end
                INIT               :begin
                    if(busy)begin
                        send = 0;
                        if(cnt_data >= 6)begin
                            cnt_data = 0;
                            next_state = IDLE;
                            init_flag = 1;
                        end
                    end
                    else if(!send)begin
                        case(cnt_data)
                            0: send_buffer = 8'h33;
                            1: send_buffer = 8'h32;
                            2: send_buffer = 8'h28;
                            3: send_buffer = 8'h0f;
                            4: send_buffer = 8'h01;
                            5: send_buffer = 8'h06;
                        endcase
                        send = 1;
                        cnt_data = cnt_data + 1;
                    end
                end
                SEND_CHARACTER     :begin
                    if(busy)begin
                        if(cnt_data > 9)cnt_data = 0;
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send)begin
                        rs =1;
                        send_buffer = "0" + cnt_data;
                        send = 1;
                        cnt_data = cnt_data + 1;
                    end
                end
                SHIFT_RIGHT_DISPLAY:begin
                    if(busy)begin
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send)begin
                        rs = 0;
                        send_buffer = 8'h1c;
                        send = 1;
                    end
                end
                SHIFT_LEFT_DISPLAY :begin
                    if(busy)begin
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send)begin
                        rs = 0;
                        send_buffer = 8'h18;
                        send = 1;
                    end
                end
                SEND_ENGLISH     :begin
                    if(busy)begin
                        if(cnt_data > 25)cnt_data = 0;
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send)begin
                        rs =1;
                        send_buffer = "A" + cnt_data;
                        send = 1;
                        cnt_data = cnt_data + 1;
                    end
                end
            
            endcase
        end
    end
endmodule

module tft_lcd_top(
    input clk, reset_p,
	input tft_sdo, 
	output tft_sck, 
    output tft_sdi, 
    output tft_dc, 
    output tft_reset, 
    output tft_cs,
    
    input PenIrq_n,
    output DCLK,
    output DIN,
    output CS_N,
    input  DOUT,
    output [3:0] com,
    output [7:0] seg);
    
    reg [16:0] wr_addr, rd_addr;
    reg [7:0] data_to_ram;
    wire [7:0] data_from_ram;
    wire framebufferClk;
    
    reg [9:0] cnt_x, cnt_y;

    always @(posedge framebufferClk, posedge reset_p)begin
        if(reset_p)begin
            rd_addr = 0;
            cnt_x = 0;
            cnt_y = 0;
        end
        else begin
            rd_addr = (cnt_y[9:1]) * 120 + (cnt_x[9:1]); 
            if(cnt_x >= 239) begin
                cnt_x = 0;
                if(cnt_y >= 319) cnt_y = 0;
                else cnt_y = cnt_y + 1;
            end
            else cnt_x = cnt_x + 1;
        end
    end
    
    lcd_bram #(.DEPTH(160*120))lcd_mem (
        .wclk(clk),
        .wr_en(~PenIrq_n),
        .wr_addr(wr_addr),
        
        .rclk(clk),
        .rd_en(1),
        .rd_addr(rd_addr),
        
        .bram_en(1),
        .data_to_ram(data_to_ram),
        .data_from_ram(data_from_ram));
    
    reg Clk50M;
    always @(posedge clk)Clk50M = Clk50M + 1;
    wire Rst_n = ~reset_p;
    
    wire [11:0]X_Value;
    wire [11:0]Y_Value;
    
    wire Get_Flag;
    wire [15:0] penx, peny;
    
    assign peny = (3900 - (Y_Value - 128)) * 5;
    assign penx = X_Value * 15;
    xpt2046 touch_pad(
        Clk50M, Rst_n, 1, 
        X_Value, Y_Value, Get_Flag,
        PenIrq_n, DCLK, DIN, DOUT, CS_N);
        
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            wr_addr = 0;
        end
        else begin
            if(penx[15:9] >= 3 && penx[15:9] <= 246)begin
                wr_addr = peny[15:7] * 120 + penx[15:9];
                data_to_ram = 8'hff;
            end
        end
    end
    
    wire [15:0] framebufferData = {8'b0, data_from_ram};
    wire [17:0] framebufferIndex; 
    wire [9:0] x;
    tft_sv lcd(clk, reset_p,
        tft_sdo, tft_sck, tft_sdi, tft_dc, tft_reset, tft_cs,
        framebufferData, framebufferClk, framebufferIndex, x);
    
    wire [15:0] bcd_value;    
    bin_to_dec btd(.bin(X_Value), .bcd(bcd_value));
        
    FND_cntr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(bcd_value), .seg(seg), .com(com));
    

endmodule

module tft_lcd_top_HY(
    input clk, reset_p,
    input tft_sdo, 
    output tft_sck, 
    output tft_sdi, 
    output tft_dc, 
    output tft_reset, 
    output tft_cs,
    
    input PenIrq_n,
    output DCLK,
    output DIN,
    output CS_N,
    input  DOUT,
    
    output [3:0] com,
    output [7:0] seg
);
    
    // =========================================================
    // 1. 디스플레이 Y좌표 동기화 복원 (tft_sv 수정 없이 x로 유추)
    // =========================================================
    wire [9:0] x;
    reg [8:0] y; 
    reg [9:0] prev_x;     

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            y <= 0;
            prev_x <= 0;
        end else begin
            prev_x <= x; 
            // x가 479 끝까지 갔다가 0으로 떨어질 때 y를 1 증가
            if (prev_x == 479 && x == 0) begin
                if (y >= 319) y <= 0;
                else y <= y + 1;
            end
        end
    end

    // =========================================================
    // 2. 28x28 중앙 박스 출력 설정 (LCD 매핑)
    // =========================================================
    // 28 * 8(확대) = 224 크기. 화면(240x320) 중앙에 배치하기 위한 여백(Offset) 계산:
    // 가로 시작점: (240 - 224) / 2 = 8
    // 세로 시작점: (320 - 224) / 2 = 48
    wire [7:0] lcd_px = x[9:1]; // 0 ~ 239 물리 픽셀
    wire [8:0] lcd_py = y;      // 0 ~ 319 물리 픽셀

    // 현재 스캔하는 곳이 224x224 중앙 박스 내부인지 확인
    wire in_box_lcd = (lcd_px >= 8 && lcd_px < 232 && lcd_py >= 48 && lcd_py < 272);
    
    // 픽셀을 28x28 인덱스로 변환 (여백을 빼고 8로 나눔: >> 3)
    wire [4:0] grid_x_lcd = (lcd_px - 8) >> 3; 
    wire [4:0] grid_y_lcd = (lcd_py - 48) >> 3;

    reg [9:0] rd_addr; // BRAM 최대 784이므로 10비트
    always @(*) begin
        if (in_box_lcd) rd_addr = (grid_y_lcd * 28) + grid_x_lcd;
        else rd_addr = 0; 
    end

    // =========================================================
    // 3. 초소형 BRAM (28 * 28 = 784)
    // =========================================================
    reg [9:0] wr_addr;
    reg [7:0] data_to_ram;
    wire [7:0] data_from_ram;
    reg wr_en_reg; // 터치 입력 제한을 위해 내부 레지스터 사용

    lcd_bram #(.DEPTH(28*28)) lcd_mem(
        .wclk(clk),
        .wr_en(wr_en_reg), // 조건에 맞을 때만 1이 됨
        .wr_addr(wr_addr),
        
        .rclk(clk),
        .rd_en(1'b1),
        .rd_addr(rd_addr),
        
        .bram_en(1'b1),
        .data_to_ram(data_to_ram),
        .data_from_ram(data_from_ram)
    );

    // =========================================================
    // 4. 터치패드 제어 및 캘리브레이션
    // =========================================================
    reg Clk50M = 0;
    always @(posedge clk) Clk50M <= ~Clk50M; // 클럭 토글 방식으로 안정화
    wire Rst_n = ~reset_p;
    
    wire [11:0] X_Value, Y_Value;
    wire Get_Flag;
    
    xpt2046 touch_pad(Clk50M, Rst_n, 1'b1, X_Value, Y_Value, Get_Flag, PenIrq_n, DCLK, DIN, DOUT, CS_N);

    // 노이즈 제거
    wire [11:0] x_tmp = (X_Value > 12'd300) ? (X_Value - 12'd300) : 12'd0;
    wire [11:0] y_tmp = (Y_Value > 12'd300) ? (Y_Value - 12'd300) : 12'd0;

    // 터치 좌표를 240x320 해상도로 변환 (오버플로우 방지를 위해 32비트 연산 사용)
    wire [15:0] touch_x_raw = ((x_tmp * 32'd70) >> 10) + 16'd0; // X축 영점 조절
    wire [15:0] touch_y_320 = ((y_tmp * 32'd94) >> 10);
    wire [15:0] touch_y_raw = ((16'd319 > touch_y_320) ? (16'd319 - touch_y_320) : 16'd0) + 16'd0; // Y축 영점 조절

    // 화면 이탈 방지
    wire [15:0] t_x = (touch_x_raw > 239) ? 239 : touch_x_raw;
    wire [15:0] t_y = (touch_y_raw > 319) ? 319 : touch_y_raw;

    // =========================================================
    // 5. 입력 제한 (Bounding Box 내부만 터치 허용)
    // =========================================================
    // 터치한 곳이 224x224 중앙 박스 내부인지 확인
    wire in_box_touch = (t_x >= 8 && t_x < 232 && t_y >= 48 && t_y < 272);
    
    // 터치 좌표를 28x28 그리드 인덱스로 변환
    wire [4:0] grid_x_touch = (t_x - 8) >> 3;
    wire [4:0] grid_y_touch = (t_y - 48) >> 3;

    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            wr_addr <= 0;
            data_to_ram <= 0;
            wr_en_reg <= 0;
        end
        else begin
            // 터치펜이 눌려있고(~PenIrq_n), 동시에 박스 안(in_box_touch)일 때만 쓰기 활성화
            if (~PenIrq_n && in_box_touch) begin
                wr_addr <= (grid_y_touch * 28) + grid_x_touch;
                data_to_ram <= 8'hFF; // 흰색
                wr_en_reg <= 1'b1;    // BRAM에 쓰기 허용
            end else begin
                wr_en_reg <= 1'b0;    // 박스 밖이면 무시 (입력 제한)
            end
        end
    end

    // =========================================================
    // 6. TFT LCD 디스플레이 출력
    // =========================================================
    // 박스 내부는 BRAM(그림), 박스 외부는 어두운 회색(8'h20)으로 테두리 표시
    wire [7:0] display_data = in_box_lcd ? data_from_ram : 8'h20; 
    wire framebufferClk;
    wire [17:0] framebufferIndex;

    tft_sv lcd(
        .clk(clk), 
        .reset_p(reset_p), 
        .tft_sdo(tft_sdo), 
        .tft_sck(tft_sck), 
        .tft_sdi(tft_sdi), 
        .tft_dc(tft_dc), 
        .tft_reset(tft_reset), 
        .tft_cs(tft_cs),
        .framebufferData({8'b0, display_data}), 
        .framebufferClk(framebufferClk), 
        .framebufferIndex(framebufferIndex), 
        .x(x)
    );
    
    // =========================================================
    // 7. FND 출력 (기존 오류 수정)
    // =========================================================
    wire [15:0] bcd_value;
    wire [15:0] sec_bcd = 16'h0000; // 원본에서 누락된 sec_bcd 임시 생성
    bin_to_dec btd_x(.bin(X_Value), .bcd(bcd_value));
    
    FND_cntr fnd(.clk(clk), .reset_p(reset_p), .fnd_value({bcd_value, sec_bcd}), .seg(seg), .com(com));
    
endmodule

























