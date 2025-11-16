`timescale 1ns/1ps
module A_bram #(parameter N=2, W=16) (
    input clk, input reset,
    input [N*N-1:0] read_addr,
    input read_en,
    output reg signed [W-1:0] dout
);
    reg signed [W-1:0] mem [0:N*N-1];
    wire [N*N-1:0] safe_addr = (read_addr < N*N) ? read_addr : 0; 
    initial begin
        integer i;
        for (i=0; i<N*N; i=i+1) mem[i]=0;
    end 
    always @(posedge clk) begin
        if (reset) dout<=0;
        else if (read_en) dout<=mem[safe_addr];
        else dout<=0;
    end 
    reg write_en_i;
    reg [31:0] write_addr_i;
    reg signed [W-1:0] write_data_i;
    
    always @(posedge clk) begin
        if (write_en_i && write_addr_i < N*N)
            mem[write_addr_i] <= write_data_i;
    end 
    task write_mem(input integer addr, input signed [W-1:0] data);
        begin
            write_addr_i = addr;
            write_data_i = data;
            write_en_i = 1;
            @(posedge clk);
            write_en_i = 0;
        end
    endtask
endmodule
module B_bram #(parameter N=2, W=16) (
    input clk, input reset,
    input [N*N-1:0] read_addr,
    input read_en,
    output reg signed [W-1:0] dout
);
    reg signed [W-1:0] mem [0:N*N-1];
    wire [N*N-1:0] safe_addr = (read_addr < N*N) ? read_addr : 0; 
    initial begin
        integer i;
        for (i=0; i<N*N; i=i+1) mem[i]=0;
    end 
    always @(posedge clk) begin
        if (reset) dout<=0;
        else if (read_en) dout<=mem[safe_addr];
        else dout<=0;
    end 
    reg write_en_i;
    reg [N*N-1:0] write_addr_i;
    reg signed [W-1:0] write_data_i; 
    always @(posedge clk) begin
        if (write_en_i && write_addr_i < N*N)
            mem[write_addr_i] <= write_data_i;
    end 
    task write_mem(input integer addr, input signed [W-1:0] data);
        begin
            write_addr_i = addr;
            write_data_i = data;
            write_en_i = 1;
            @(posedge clk);
            write_en_i = 0;
        end
    endtask
endmodule
module C_bram #(parameter N=2, W=16) (
    input clk, input reset,
    input [N*N-1:0] write_addr,
    input write_en,
    input signed [2*W-1:0] din
);
    reg signed [2*W-1:0] mem [0:N*N-1];
    wire [N*N-11:0] safe_addr = (write_addr < N*N) ? write_addr : 0; 
    initial begin
        integer i;
        for (i=0; i<N*N; i=i+1) mem[i]=0;
    end 
    always @(posedge clk) begin
        if (write_en)
            mem[safe_addr] <= din;
    end 
    task read_mem(input integer addr, output signed [2*W-1:0] data_out);
        begin
            if (addr < N*N) data_out = mem[addr];
            else data_out = 0;
        end
    endtask
endmodule

module tile_sparsity #(parameter N=2, W=16)(
    input clk, input reset,
    input detect_start,
    input detect_valid,
    input signed [W-1:0] detect_din,
    output reg detect_done,
    output reg [1:0] sparsity_level,
    output reg [N*N:0] nonzero_count
);
    reg [N*N:0] zero_count;
    reg [N*N:0] elem_count;
    reg active; 
    wire [N*N:0] current_zero_count = (active && detect_valid && detect_din == 0) ? 
                                      (zero_count + 1) : zero_count; 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            zero_count <= 0;
            elem_count <= 0;
            sparsity_level <= 2'b00;
            nonzero_count <= 0;
            detect_done <= 0;
            active <= 0;
        end else begin
            detect_done <= 0;
            if (detect_start) begin
                zero_count <= 0;
                elem_count <= 0;
                active <= 1;
            end
            if (active && detect_valid) begin
                if (detect_din == 0)
                    zero_count <= zero_count + 1;
                if (elem_count == N-1) begin
                    active <= 0;
                    detect_done <= 1;
                    nonzero_count <= N - current_zero_count;  
                    if ((N - current_zero_count)*100 < 30*N)
                        sparsity_level <= 2'b00;  // SPARSE
                    else if ((N - current_zero_count)*100 >= 70*N)
                        sparsity_level <= 2'b10;  // DENSE
                    else
                        sparsity_level <= 2'b01;  // BALANCED
                    elem_count <= 0;
                end else begin
                    elem_count <= elem_count + 1;
                end
            end
        end
    end
endmodule
module precision_reg (
    input clk, input reset,
    input [1:0] host_precision,
    output reg [1:0] precision_mode
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            precision_mode <= 2'b00;
        else
            precision_mode <= host_precision;
    end
endmodule
module multiplier_selector_fsm(
    input clk, input reset,
    input start_select,
    input [1:0] sparsity_level,
    input [1:0] precision_mode,
    output reg [1:0] sel
);
    reg [1:0] prev_sel;
 always @(posedge clk or posedge reset) begin
        if (reset) begin
            sel <= 2'b00;
            prev_sel <= 2'b00;
        end else if (start_select) begin
            $display("[%t] MultiplierSelectorFSM: sparsity=%b, precision=%b",
                     $time, sparsity_level, precision_mode); 
            if ((sparsity_level == 2'b10) && (precision_mode == 2'b10))
                sel <= 2'b00;  // DENSE + 32-bit -> DSP
            else if ((sparsity_level == 2'b00) && (precision_mode == 2'b00))
                sel <= 2'b10;  // SPARSE + 8-bit -> Bit-serial
            else if ((sparsity_level == 2'b01) && (precision_mode == 2'b01))
                sel <= 2'b01;  // BALANCED + 16-bit -> Booth
            else
                sel <= 2'b00;  // ANY CONFLICT -> DSP (default) 
            $display("[%t] MultiplierSelectorFSM: selected multiplier=%b",
                     $time, sel);
            prev_sel <= sel;
        end
    end
endmodule
module dsp_wrapper_if #(parameter W=16) (
    input clk, input reset,
    input start_dsp,
    input signed [W-1:0] A,
    input signed [W-1:0] B,
    output reg signed [2*W-1:0] P_dsp,
    output reg done_dsp
);
    reg active;
    reg signed [2*W-1:0] result_reg; 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            P_dsp <= 0;
            done_dsp<= 0;
            active <= 0;
        end else begin
            done_dsp <= 0;
            if (start_dsp && !active) begin
                result_reg <= A * B;
                active <= 1;
            end else if (active) begin
                P_dsp <= result_reg;
                done_dsp <= 1;
                active <= 0;
            end
        end
    end
endmodule
module booth_multiplier_seq #(parameter W = 16) (
    input clk,
    input reset,
    input start_booth,
    input signed [W-1:0] A,
    input signed [W-1:0] B,
    output reg signed [2*W-1:0] P_booth,
    output reg done_booth
);
    reg signed [2*W-1:0] AQ; reg Q_neg; reg signed [W-1:0] M;
    reg [5:0] count;
    reg busy;
    reg signed [2*W-1:0] AQ_temp; 
    always @(posedge clk) begin
        if (reset) begin
            AQ         <= 0;
            Q_neg      <= 0;
            M          <= 0;
            P_booth    <= 0;
            done_booth <= 0;
            count      <= 0;
            busy       <= 0;
        end else begin
            done_booth <= 0; 
            if (start_booth && !busy) begin
                M      <= A;
                AQ     <= {16'b0, B};       
                Q_neg  <= 1'b0;
                count  <= 0;
                busy   <= 1;
            end else if (busy) begin
                case ({AQ[0], Q_neg})
                    2'b01: AQ_temp = {AQ[2*W-1:W] + {{1{M[W-1]}}, M}, AQ[W-1:0]};
                    2'b10: AQ_temp = {AQ[2*W-1:W] - {{1{M[W-1]}}, M}, AQ[W-1:0]};
                    default: AQ_temp = AQ;
                endcase 
                Q_neg  <= AQ_temp[0];
                AQ     <= {AQ_temp[2*W-1], AQ_temp[2*W-1:1]}; 
                count <= count + 1; 
                if (count == W-1) begin
                    P_booth    <= {AQ_temp[2*W-1:W], AQ_temp[W-1:1]};
                    done_booth <= 1;
                    busy       <= 0;
                end
            end
        end
    end
endmodule
module bitserial_multiplier #(parameter W=16) (
    input clk, input reset,
    input start_bit,
    input signed [W-1:0] A,
    input signed [W-1:0] B,
    output reg signed [2*W-1:0] P_bit,
    output reg done_bit
);
    reg [5:0] count;
    reg signed [2*W-1:0] sum;
    reg signed [W+W-1:0] a_ext, b_ext;
    reg busy; 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            P_bit <= 0;
            done_bit <= 0;
            sum <= 0;
            a_ext <= 0;
            b_ext <= 0;
            busy <= 0;
        end else begin
            done_bit <= 0;
            if (start_bit && !busy) begin
                a_ext <= {{(W){A[W-1]}}, A};
                b_ext <= {{(W){B[W-1]}}, B};
                sum <= 0;
                count <= 0;
                busy <= 1;
            end else if (busy) begin
                if (b_ext[0]) sum <= sum + (a_ext << count);
                b_ext <= b_ext >> 1;
                count <= count + 1;
                if (count == W) begin
                    P_bit <= sum;
                    done_bit <= 1;
                    busy <= 0;
                end
            end
        end
    end
endmodule
module product_mux #(parameter W=16) (
    input [1:0] sel,
    input signed [2*W-1:0] P_dsp,
    input signed [2*W-1:0] P_booth,
    input signed [2*W-1:0] P_bit,
    output signed [2*W-1:0] P_selected
);
    assign P_selected = (sel==2'b00) ? P_dsp :
                        (sel==2'b01) ? P_booth : P_bit;
endmodule
module top_control_fsm #(parameter N=2, W=16) (
    input clk,
    input reset,
    input start_all,
    output reg done_all,
    output reg [N*N:0] read_addr_A,
    output reg read_en_A,
    input signed [W-1:0] A_out,
    output reg [N*N:0] read_addr_B,
    output reg read_en_B,
    input signed [W-1:0] B_out,
    output reg [N*N:0] write_addr_C,
    output reg write_en_C,
    output reg signed [2*W-1:0] C_in,
    output reg detect_start,
    output reg detect_valid,
    output reg signed [W-1:0] detect_din,
    input detect_done,
    input [1:0] sparsity_level,
    input [1:0] precision_mode,
    output reg start_select,
    input [1:0] sel,
    output reg start_dsp,
    input done_dsp,
    input signed [2*W-1:0] P_dsp,
    output reg start_booth,
    input done_booth,
    input signed [2*W-1:0] P_booth,
    output reg start_bit,
    input done_bit,
    input signed [2*W-1:0] P_bit,
    output reg signed [W-1:0] mult_operand_A,
    output reg signed [W-1:0] mult_operand_B,
    output reg [31:0] cycle_count,
    output reg [31:0] mac_executed,
    output reg [31:0] mac_skipped,
    output reg [31:0] switch_count
);
    typedef enum logic [4:0] {
        IDLE = 0,
        DETECT_START = 1,
        WAIT_DETECT_START = 2,
        DETECT_STREAM = 3,
        SELECT = 4,
        WAIT_SELECT = 5,        
        LOAD_AB = 6,
        WAIT_DATA = 7,
        WAIT_OPERANDS = 8,
        CHECK_ZERO = 9,
        WAIT_MULT = 10,
        WAIT_MULT_STABLE = 11,
        WRITEBACK = 12,
        NEXT_ELEMENT = 13,
        DONE = 14
    } state_t;
    state_t state;
    reg [31:0] r, c, j, j_det;
    reg signed [2*W-1:0] acc;
    reg [1:0] sel_reg, prev_sel;
    wire signed [2*W-1:0] P_selected;
    product_mux #(.W(W)) mux_sel (
        .sel(sel_reg),
        .P_dsp(P_dsp),
        .P_booth(P_booth),
        .P_bit(P_bit),
        .P_selected(P_selected)
    );
    reg signed [W-1:0] operand_A_latched, operand_B_latched;
    reg start_mult;
    always @(*) begin
        mult_operand_A = operand_A_latched;
        mult_operand_B = operand_B_latched;
    end
    always @(*) begin
        start_dsp = 0;
        start_booth = 0;
        start_bit = 0;
        if (start_mult) begin
            case(sel_reg)
                2'b00: start_dsp = 1;
                2'b01: start_booth = 1;
                2'b10: start_bit = 1;
                default: ;
            endcase
        end
    end
    wire done_mult = (sel_reg == 2'b00) ? done_dsp :
                    (sel_reg == 2'b01) ? done_booth : done_bit;
always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done_all <= 0;
            cycle_count <= 0;
            mac_executed <= 0;
            mac_skipped <= 0;
            switch_count <= 0;
            r <= 0; c <= 0; j <= 0; j_det <= 0;
            acc <= 0;
            sel_reg <= 0;
            prev_sel <= 0;
            start_mult <= 0;
            write_en_C <= 0;
            write_addr_C <= 0;
            C_in <= 0;
            operand_A_latched <= 0;
            operand_B_latched <= 0;
            read_en_A <= 0;
            read_en_B <= 0;
            detect_start <= 0;
            detect_valid <= 0;
            detect_din <= 0;
            start_select <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
            done_all <= 0;
            read_en_A <= 0; read_en_B <= 0;
            start_select <= 0;
            start_mult <= 0;
            write_en_C <= 0;
            write_addr_C <= 0;
            C_in <= 0;
            detect_din <= 0;
            case(state)
                IDLE: begin
                    acc <= 0;
                    if (start_all) begin
                        r <= 0; c <= 0; j <= 0; j_det <= 0;
                        mac_executed <= 0;
                        mac_skipped <= 0;
                        switch_count <= 0;
                        sel_reg <= 0;
                        prev_sel <= 0;
                        $display("[%t] FSM: IDLE -> DETECT_START", $time);
                        state <= DETECT_START;
                    end
                end
                DETECT_START: begin
                    detect_start <= 1;
                    detect_valid <= 0;
                    j_det <= 0;
                    read_addr_A <= r*N + 0;
                    read_en_A <= 1;
                    detect_din <= 0;
                    state <= WAIT_DETECT_START;
                    $display("[%t] FSM: DETECT_START row %0d", $time, r);
                end
                WAIT_DETECT_START: begin
                    detect_start <= 0;
                    detect_valid <= 1;
                    detect_din <= A_out;
                    state <= DETECT_STREAM;
                end
                DETECT_STREAM: begin
                    detect_valid <= 1;
                    detect_din <= A_out;
                    if (j_det < N-1) begin
                        j_det <= j_det + 1;
                        read_addr_A <= r*N + j_det + 1;
                        read_en_A <= 1;
                        $display("[%t] FSM: DETECT_STREAM reading A[%0d]", $time, r*N + j_det + 1);
                    end else begin
                        read_en_A <= 0;
                        read_addr_A <= 0;
                        if (detect_done) begin
                            detect_valid <= 0;
                            start_select <= 1;
                            state <= SELECT;
                        end else begin
                            $display("[%t] FSM: DETECT_STREAM waiting for detect_done", $time);
                        end
                    end
                end
                SELECT: begin
                    start_select <= 1;
                    $display("[%t] FSM: SELECT requesting multiplier selection sparsity=%b precision=%b", 
                             $time, sparsity_level, precision_mode);
                    state <= WAIT_SELECT;  
                end
                WAIT_SELECT: begin
                    start_select <= 0;
                    sel_reg <= sel;  
                    if ((sel != prev_sel) && (prev_sel != 2'b11)) begin
                        switch_count <= switch_count + 1;
                        $display("[%t] FSM: SELECT multiplier switched from %b to %b", 
                                 $time, prev_sel, sel);
                    end
                    prev_sel <= sel;
                    c <= 0;
                    j <= 0;
                    acc <= 0;
                    $display("[%t] FSM: SELECT multiplier selected %b", $time, sel);
                    state <= LOAD_AB;
                end
                LOAD_AB: begin
                    read_addr_A <= r*N + j;
                    read_addr_B <= j*N + c;
                    read_en_A <= 1;
                    read_en_B <= 1;
                    $display("[%t] FSM: LOAD_AB reading A[%0d], B[%0d]", $time, r*N + j, j*N + c);
                    state <= WAIT_DATA;
                end
                WAIT_DATA: begin
                    $display("[%t] FSM: WAIT_DATA waiting for memory data to stabilize", $time);
                    state <= WAIT_OPERANDS;
                end
                WAIT_OPERANDS: begin
                    operand_A_latched <= A_out;
                    operand_B_latched <= B_out;
                    $display("[%t] FSM: WAIT_OPERANDS latched operands A=%0d B=%0d", $time, A_out, B_out);
                    state <= CHECK_ZERO;
                end
                CHECK_ZERO: begin
                    $display("[%t] FSM: CHECK_ZERO A_out=%0d B_out=%0d", $time, operand_A_latched, operand_B_latched);
                    if ((operand_A_latched == 0) || (operand_B_latched == 0)) begin
                        mac_skipped <= mac_skipped + 1;
                        $display("[%t] FSM: CHECK_ZERO skipping MAC", $time);
                        if (j < N-1) begin
                            j <= j + 1;
                            state <= LOAD_AB;
                        end else begin
                            state <= WRITEBACK;
                        end
                    end else begin
                        mac_executed <= mac_executed + 1;
                        start_mult <= 1;
                        $display("[%t] FSM: CHECK_ZERO starting multiply sel=%b A=%0d B=%0d", $time, sel_reg, operand_A_latched, operand_B_latched);
                        state <= WAIT_MULT;
                    end
                end
                WAIT_MULT: begin
                    if (done_mult) begin
                        state <= WAIT_MULT_STABLE;
                        $display("[%t] FSM: WAIT_MULT done, waiting for stability", $time);
                    end else begin
                        $display("[%t] FSM: WAIT_MULT waiting multiplier done", $time);
                    end
                end
                WAIT_MULT_STABLE: begin
                    acc <= acc + P_selected;
                    $display("[%t] FSM: WAIT_MULT_STABLE updated acc = %0d (prev=%0d + result=%0d)", $time, acc + P_selected, acc, P_selected);
                    if (j < N-1) begin
                        j <= j + 1;
                        state <= LOAD_AB;
                    end else begin
                        state <= WRITEBACK;
                    end
                end
                WRITEBACK: begin
                    write_addr_C <= r*N + c;
                    write_en_C <= 1;
                    C_in <= acc;
                    $display("[%t] FSM: WRITEBACK writing %0d to C[%0d]", $time, acc, r*N + c);
                    state <= NEXT_ELEMENT;
                end
                NEXT_ELEMENT: begin
                    write_en_C <= 0;
                    acc <= 0;
                    if (c < N-1) begin
                        c <= c + 1;
                        j <= 0;
                        $display("[%t] FSM: NEXT_ELEMENT next column %0d", $time, c + 1);
                        state <= LOAD_AB;
                    end else if (r < N-1) begin
                        r <= r + 1;
                        c <= 0; j <= 0;
                        $display("[%t] FSM: NEXT_ELEMENT next row %0d", $time, r + 1);
                        state <= DETECT_START;
                    end else begin
                        $display("[%t] FSM: NEXT_ELEMENT multiply done", $time);
                        state <= DONE;
                    end
                end
                DONE: begin
                    done_all <= 1;
                    $display("[%t] FSM: DONE done", $time);
                end
                default: begin
                    $display("[%t] FSM: Default reset to IDLE", $time);
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule  
