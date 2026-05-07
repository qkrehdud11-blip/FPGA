`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module watch(
    input clk, reset_p,
    input [2:0] btn,
    output reg [7:0] sec, min);
    
    reg set_watch;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)set_watch = 0;
        else if(btn[0])set_watch = ~set_watch;
    end
    
    integer cnt_sysclk;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            cnt_sysclk = 0;
            sec = 0;
            min = 0;
        end
        else begin
            if(set_watch)begin
                if(btn[1])begin
                    if(sec >= 59)sec = 0;
                    else sec = sec + 1;
                end
                if(btn[2])begin
                    if(min >= 59)min = 0;
                    else min = min + 1;
                end
            end
            else begin
                if(cnt_sysclk >= 27'd99_999_999)begin
                    cnt_sysclk = 0;
                    if(sec >= 59)begin
                        sec = 0;
                        if(min >= 59)min = 0;
                        else min = min + 1;
                    end
                    else sec = sec + 1;
                end
                else cnt_sysclk = cnt_sysclk + 1;
            end
        end
    end
endmodule

module cook_timer(
    input clk, reset_p,
    input btn_start, inc_sec, inc_min, alarm_off,
    output reg [7:0] sec, min,
    output reg alarm);
    
    reg [7:0] set_sec, set_min;

    reg dcnt_set;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            dcnt_set = 0;
            alarm = 0;
            set_sec = 0;
            set_min = 0;
        end
        else begin
            if(btn_start && !(sec==0 && min==0))begin
                dcnt_set = ~dcnt_set;
                set_sec = sec;
                set_min = min;
            end
            if(sec == 0 && min == 0 && dcnt_set)begin
                dcnt_set = 0;
                alarm = 1;
            end
            if(alarm_off || inc_sec || inc_min)alarm = 0;
        end
    end
    integer cnt_sysclk;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            cnt_sysclk = 0;
            sec = 0;
            min = 0;
        end
        else begin
            if(dcnt_set)begin
                if(cnt_sysclk >= 99_999_999)begin
                    cnt_sysclk = 0;
                    if(sec == 0 && min)begin
                        sec = 59;
                        min = min - 1;
                    end
                    else sec = sec - 1;
                end
                else cnt_sysclk = cnt_sysclk + 1;
            end
            else if(alarm && (alarm_off || inc_sec || inc_min))begin
                sec = set_sec;
                min = set_min;
            end
            else begin
                if(inc_sec)begin
                    if(sec >=59)sec = 0;
                    else sec = sec + 1;
                end
                if(inc_min)begin
                    if(min >=59)min = 0;
                    else min = min + 1;
                end
            end
        end
    end

endmodule

module stop_watch(
    input clk, reset_p,
    input btn_start, btn_lap, btn_clear,
    output reg [7:0] fnd_sec, fnd_csec,
    output reg start_stop, lap);
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            start_stop = 0;
        end
        else begin
            if(btn_start)start_stop = ~start_stop;
            else if(btn_clear)start_stop = 0;
        end
    end
    
    reg [7:0] sec, csec, lap_sec, lap_csec;
    integer cnt_sysclk;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            cnt_sysclk = 0;
            sec = 0;
            csec = 0;
        end
        else begin
            if(start_stop)begin
                if(cnt_sysclk >= 999_999)begin
                    cnt_sysclk = 0;
                    if(csec >= 99)begin
                        csec = 0;
                        if(sec >= 59)begin
                            sec = 0;
                        end
                        else sec = sec + 1;
                    end
                    else csec = csec + 1;
                end
                else cnt_sysclk = cnt_sysclk + 1;
            end
            if(btn_clear)begin
                sec = 0;
                csec = 0;
                cnt_sysclk = 0;
            end
        end
    end
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            lap_sec = 0;
            lap_csec = 0;
            lap = 0;
        end
        else begin
            if(btn_lap)begin
                if(start_stop)lap = ~lap;
                lap_sec = sec;
                lap_csec = csec;
            end
            if(btn_clear)begin
                lap = 0;
                lap_sec = 0;
                lap_csec = 0;
            end
        end
    end
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            fnd_sec = 0;
            fnd_csec = 0;
        end
        else begin
            if(lap)begin
                fnd_sec = lap_sec;
                fnd_csec = lap_csec;
            end
            else begin
                fnd_sec = sec;
                fnd_csec = csec;
            end
        end
    end
    

endmodule





























