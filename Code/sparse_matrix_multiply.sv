`timescale 1ns/1ps
module switch_input_controller #(parameter N=2, W=8) (
    input wire clk,
    input wire reset,
    input wire [7:0] sw,
    input wire btn_store,
    input wire btn_toggle_mode,
    input wire btn_store_precision,
    output reg [W-1:0] load_data,
    output reg [31:0] load_addr,
    output reg load_en,
    output reg matrix_sel,
    output reg [1:0] precision_reg [0:N-1],
    output reg [1:0] current_row_sel,
    output reg loading_complete 
);
    reg [1:0] mode_a_b;
    reg [2:0] prev_btn_store, prev_btn_toggle, prev_btn_prec;
    wire btn_store_edge, btn_toggle_edge, btn_prec_edge;
    reg [4:0] load_count;  
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            prev_btn_store <= 3'b000;
            prev_btn_toggle <= 3'b000;
            prev_btn_prec <= 3'b000;
        end else begin
            prev_btn_store <= {prev_btn_store[1:0], btn_store};
            prev_btn_toggle <= {prev_btn_toggle[1:0], btn_toggle_mode};
            prev_btn_prec <= {prev_btn_prec[1:0], btn_store_precision};
        end
    end
    assign btn_store_edge = (prev_btn_store[2:1] == 2'b01);
    assign btn_toggle_edge = (prev_btn_toggle[2:1] == 2'b01);
    assign btn_prec_edge = (prev_btn_prec[2:1] == 2'b01);
    always @(posedge clk) begin
        if (reset) begin
            mode_a_b <= 2'b00;
            current_row_sel <= 2'b00;
            load_data <= 8'b0;
            load_addr <= 32'b0;
            load_en <= 1'b0;
            load_count <= 5'b00000;           
            loading_complete <= 1'b0;  
            matrix_sel <= 1'b0;
            for (i = 0; i < N; i = i + 1)
                precision_reg[i] <= 2'b01;
        end else begin
            load_en <= 1'b0;     
            if (btn_toggle_edge) begin
                mode_a_b <= ~mode_a_b;
            end            
            if (btn_store_edge) begin
                load_data <= {4'b0000, sw[3:0]};
                load_addr <= {30'b0, sw[5:4]};
                matrix_sel <= mode_a_b;
                load_en <= 1'b1;               
                load_count <= load_count + 1;
                if (load_count >= (2*N*N))  
                    loading_complete <= 1'b1;
            end  
            if (btn_prec_edge) begin
                precision_reg[current_row_sel] <= sw[7:6];
                if (current_row_sel < N-1)
                    current_row_sel <= current_row_sel + 1;
                else
                    current_row_sel <= 2'b00;
            end
        end
    end
endmodule
module result_display_cycler #(parameter N=2, W=8) (
    input wire clk,
    input wire reset,
    input wire btn_next,
    input wire [15:0] current_result,  
    output reg [W-1:0] display_data,
    output reg [1:0] result_idx
);
    reg [2:0] prev_btn_next;
    wire btn_next_edge;
    always @(posedge clk) begin
        if (reset) prev_btn_next <= 3'b000;
        else prev_btn_next <= {prev_btn_next[1:0], btn_next};
    end
    assign btn_next_edge = (prev_btn_next[2:1] == 2'b01);
    always @(posedge clk) begin
        if (reset) result_idx <= 2'b00;
        else if (btn_next_edge) begin
            if (result_idx < (N*N - 1))
                result_idx <= result_idx + 1;
            else
                result_idx <= 2'b00;
        end
    end
    always @(*) begin
        display_data = current_result[7:0];
    end
endmodule
module sparse_matrix_multiply (
    input wire CLK100MHZ,
    input wire [4:0] btn,
    input wire [7:0] sw,
    output wire [7:0] led
);
    parameter N = 2;
    parameter W = 8;
    wire clk, reset, start_core, done_core;
    wire [31:0] current_row;
    reg [1:0] precision_per_row [0:N-1];
    reg [1:0] current_precision;
    integer i;
    assign clk = CLK100MHZ;
    assign reset = btn[0];
    reg prev_done_core;
    always @(posedge clk) begin
        if (reset) prev_done_core <= 1'b0;
        else prev_done_core <= done_core;
    end
    wire done_core_edge = (~prev_done_core) & done_core;
    wire signed [15:0] ext_result_data_16bit;
    wire [31:0] ext_result_addr;
    wire [1:0] result_idx;
    wire [31:0] ext_result_data = {{16{ext_result_data_16bit[15]}}, ext_result_data_16bit};
    assign ext_result_addr = {30'b0, result_idx};
    wire [7:0] display_result;
    result_display_cycler #(.N(N), .W(8)) result_cycler (
        .clk(clk),
        .reset(reset),
        .btn_next(btn[4]),
        .current_result(ext_result_data_16bit),
        .display_data(display_result),
        .result_idx(result_idx)
    );
    assign led = display_result;
    reg [2:0] btn_sync [0:4];
    wire [4:0] btn_edge;
    genvar g;
    generate
        for (g = 0; g < 5; g = g + 1) begin : btn_debounce
            always @(posedge clk or posedge reset) begin
                if (reset) btn_sync[g] <= 3'b000;
                else btn_sync[g] <= {btn_sync[g][1:0], btn[g]};
            end
            assign btn_edge[g] = (btn_sync[g][2:1] == 2'b01);
        end
    endgenerate
    wire [7:0] load_data_sw;
    wire [31:0] load_addr_sw;
    wire load_en_sw, matrix_sel_sw;
    wire [1:0] prec_reg_sw [0:N-1];
    wire [1:0] current_row_sel_sw;
    wire loading_complete;  
    switch_input_controller #(.N(N), .W(W)) sw_loader (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .btn_store(btn[1]),
        .btn_toggle_mode(btn[2]),
        .btn_store_precision(btn[3]),
        .load_data(load_data_sw),
        .load_addr(load_addr_sw),
        .load_en(load_en_sw),
        .matrix_sel(matrix_sel_sw),
        .precision_reg(prec_reg_sw),
        .current_row_sel(current_row_sel_sw),
        .loading_complete(loading_complete)
    );
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < N; i = i + 1)
                precision_per_row[i] <= 2'b01;
            current_precision <= 2'b01;
        end else begin
            for (i = 0; i < N; i = i + 1)
                precision_per_row[i] <= prec_reg_sw[i];
            if (current_row < N)
                current_precision <= prec_reg_sw[current_row[1:0]];
        end
    end
    reg start_pulse;
    always @(posedge clk) begin
        if (reset) start_pulse <= 1'b0;
        else start_pulse <= btn_edge[1] & loading_complete;
    end
    assign start_core = start_pulse;
    sparse_matrix_core_with_io #(.N(N), .W(W)) core (
        .clk(clk),
        .reset(reset),
        .start(start_core),
        .done(done_core),
        .ext_load_data(load_data_sw),
        .ext_load_addr(load_addr_sw),
        .ext_load_en(load_en_sw),
        .ext_matrix_sel(matrix_sel_sw),
        .ext_precision(current_precision),
        .current_row_out(current_row),
        .ext_result_addr(ext_result_addr),
        .ext_result_data(ext_result_data_16bit)  
    );
endmodule
module sparse_matrix_core_with_io #(parameter N=2, W=8) (
    input wire clk, reset, start,
    output wire done,
    input wire [W-1:0] ext_load_data,
    input wire [31:0] ext_load_addr,
    input wire ext_load_en,
    input wire ext_matrix_sel,
    input wire [1:0] ext_precision,
    output wire [31:0] current_row_out,
    input wire [31:0] ext_result_addr,
    output wire signed [15:0] ext_result_data
);
    wire [31:0] read_addr_A, read_addr_B, write_addr_C;
    wire read_en_A, read_en_B, write_en_C;
    wire signed [W-1:0] A_out, B_out;
    wire signed [2*W-1:0] C_in;
    wire [1:0] precision_mode;
    A_bram_ext #(.N(N), .W(W)) A_mem (
        .clk(clk), .reset(reset),
        .read_addr(read_addr_A), .read_en(read_en_A), .dout(A_out),
        .ext_addr(ext_load_addr), .ext_din(ext_load_data),
        .ext_wen(ext_load_en & ~ext_matrix_sel)
    );
    B_bram_ext #(.N(N), .W(W)) B_mem (
        .clk(clk), .reset(reset),
        .read_addr(read_addr_B), .read_en(read_en_B), .dout(B_out),
        .ext_addr(ext_load_addr), .ext_din(ext_load_data),
        .ext_wen(ext_load_en & ext_matrix_sel)
    );
    C_bram_ext #(.N(N), .W(W)) C_mem (
        .clk(clk), .reset(reset),
        .write_addr(write_addr_C), .write_en(write_en_C), .din(C_in),
        .ext_read_addr(ext_result_addr), .ext_dout(ext_result_data)
    );
    precision_reg_ext prec_ctrl (
        .clk(clk), .reset(reset),
        .ext_precision(ext_precision),
        .precision_mode(precision_mode)
    );
    original_sparse_matrix_core #(.N(N), .W(W)) original_core (
        .clk(clk), .reset(reset), .start(start), .done(done),
        .read_addr_A(read_addr_A), .read_en_A(read_en_A), .A_out(A_out),
        .read_addr_B(read_addr_B), .read_en_B(read_en_B), .B_out(B_out),
        .write_addr_C(write_addr_C), .write_en_C(write_en_C), .C_in(C_in),
        .precision_mode(precision_mode),
        .current_row(current_row_out)
    );
endmodule
module A_bram_ext #(parameter N=2, W=8) (
    input wire clk, reset,
    input wire [31:0] read_addr, input wire read_en,
    output reg signed [W-1:0] dout,
    input wire [31:0] ext_addr, input wire signed [W-1:0] ext_din,
    input wire ext_wen
);
    reg signed [W-1:0] mem [0:N*N-1];
    integer i;
    initial for (i=0; i<N*N; i=i+1) mem[i] = {W{1'b0}};
    always @(posedge clk) begin
        if (reset) dout <= {W{1'b0}};
        else if (read_en && read_addr < N*N) dout <= mem[read_addr];
        else dout <= {W{1'b0}};
        if (ext_wen && ext_addr < N*N) mem[ext_addr] <= ext_din;
    end
endmodule
module B_bram_ext #(parameter N=2, W=8) (
    input wire clk, reset,
    input wire [31:0] read_addr, input wire read_en,
    output reg signed [W-1:0] dout,
    input wire [31:0] ext_addr, input wire signed [W-1:0] ext_din,
    input wire ext_wen
);
    reg signed [W-1:0] mem [0:N*N-1];
    integer i;
    initial for (i=0; i<N*N; i=i+1) mem[i] = {W{1'b0}};
    always @(posedge clk) begin
        if (reset) dout <= {W{1'b0}};
        else if (read_en && read_addr < N*N) dout <= mem[read_addr];
        else dout <= {W{1'b0}};
        if (ext_wen && ext_addr < N*N) mem[ext_addr] <= ext_din;
    end
endmodule
module C_bram_ext #(parameter N=2, W=8) (
    input wire clk, reset,
    input wire [31:0] write_addr, input wire write_en,
    input wire signed [2*W-1:0] din,
    input wire [31:0] ext_read_addr,
    output reg signed [2*W-1:0] ext_dout
);
    reg signed [2*W-1:0] mem [0:N*N-1];
    integer i;
    initial for (i=0; i<N*N; i=i+1) mem[i] = {2*W{1'b0}};
    always @(posedge clk) begin
        if (reset) for (i=0; i<N*N; i=i+1) mem[i] <= {2*W{1'b0}};
        else if (write_en && write_addr < N*N) mem[write_addr] <= din;
    end
    always @(posedge clk) begin
        if (reset) ext_dout <= {2*W{1'b0}};
        else if (ext_read_addr < N*N) ext_dout <= mem[ext_read_addr];
        else ext_dout <= {2*W{1'b0}};
    end
endmodule
module precision_reg_ext (
    input wire clk, reset,
    input wire [1:0] ext_precision,
    output reg [1:0] precision_mode
);
    always @(posedge clk) begin
        if (reset) precision_mode <= 2'b01;
        else precision_mode <= ext_precision;
    end
endmodule
module original_sparse_matrix_core #(parameter N=2, W=8) (
    input wire clk, reset, start,
    output wire done,
    output wire [31:0] read_addr_A,
    output wire read_en_A,
    input wire signed [W-1:0] A_out,
    output wire [31:0] read_addr_B,
    output wire read_en_B,
    input wire signed [W-1:0] B_out,
    output wire [31:0] write_addr_C,
    output wire write_en_C,
    output wire signed [2*W-1:0] C_in,
    input wire [1:0] precision_mode,
    output wire [31:0] current_row
);
    wire detect_start, detect_valid, detect_done;
    wire signed [W-1:0] detect_din;
    wire [1:0] sparsity_level;
    wire [15:0] nonzero_count;
    wire _sparsity_check = sparsity_level[1] | sparsity_level[0]; 
    wire start_select;
    wire [1:0] sel;
    wire start_dsp, done_dsp, start_booth, done_booth, start_bit, done_bit;
    wire signed [2*W-1:0] P_dsp, P_booth, P_bit;
    wire signed [W-1:0] mult_operand_A, mult_operand_B;
    wire [31:0] cycle_count, mac_executed, mac_skipped, switch_count; 
    tile_sparsity #(.N(N), .W(W)) sparsity_det (
        .clk(clk), .reset(reset),
        .detect_start(detect_start), .detect_valid(detect_valid),
        .detect_din(detect_din), .detect_done(detect_done),
        .sparsity_level(sparsity_level), .nonzero_count(nonzero_count)
    ); 
    multiplier_selector_fsm mult_sel (
        .clk(clk), .reset(reset),
        .start_select(start_select),
        .sparsity_level(sparsity_level),
        .precision_mode(precision_mode),
        .sel(sel)
    ); 
    dsp_multiplier #(.W(W)) dsp_mult (
        .clk(clk), .reset(reset),
        .start_dsp(start_dsp), .A(mult_operand_A), .B(mult_operand_B),
        .P_dsp(P_dsp), .done_dsp(done_dsp)
    ); 
    booth_multiplier #(.W(W)) booth_mult (
        .clk(clk), .reset(reset),
        .start_booth(start_booth), .A(mult_operand_A), .B(mult_operand_B),
        .P_booth(P_booth), .done_booth(done_booth)
    ); 
    bitserial_multiplier #(.W(W)) bit_mult (
        .clk(clk), .reset(reset),
        .start_bit(start_bit), .A(mult_operand_A), .B(mult_operand_B),
        .P_bit(P_bit), .done_bit(done_bit)
    );
    top_control_fsm #(.N(N), .W(W)) control_fsm (
        .clk(clk), .reset(reset),
        .start_all(start), .done_all(done),
        .read_addr_A(read_addr_A), .read_en_A(read_en_A), .A_out(A_out),
        .read_addr_B(read_addr_B), .read_en_B(read_en_B), .B_out(B_out),
        .write_addr_C(write_addr_C), .write_en_C(write_en_C), .C_in(C_in),
        .detect_start(detect_start), .detect_valid(detect_valid),
        .detect_din(detect_din), .detect_done(detect_done),
        .sparsity_level(sparsity_level), .precision_mode(precision_mode),
        .start_select(start_select), .sel(sel),
        .start_dsp(start_dsp), .done_dsp(done_dsp), .P_dsp(P_dsp),
        .start_booth(start_booth), .done_booth(done_booth), .P_booth(P_booth),
        .start_bit(start_bit), .done_bit(done_bit), .P_bit(P_bit),
        .mult_operand_A(mult_operand_A), .mult_operand_B(mult_operand_B),
        .cycle_count(cycle_count), .mac_executed(mac_executed),
        .mac_skipped(mac_skipped), .switch_count(switch_count),
        .current_row(current_row)
    );
endmodule
module tile_sparsity #(parameter N=2, W=8)(
    input clk, input reset,
    input detect_start, input detect_valid,
    input signed [W-1:0] detect_din,
    output reg detect_done,
    output reg [1:0] sparsity_level,
    output reg [15:0] nonzero_count
);
    reg [15:0] zero_count;
    reg [7:0] elem_count;
    reg active; 
    always @(posedge clk) begin
        if (reset) begin
            zero_count <= 16'b0; elem_count <= 8'b0;
            sparsity_level <= 2'b00; nonzero_count <= 16'b0;
            detect_done <= 1'b0; active <= 1'b0;
        end else begin
            detect_done <= 1'b0;
            if (detect_start) begin
                zero_count <= 16'b0; elem_count <= 8'b0; active <= 1'b1;
            end
            if (active && detect_valid) begin
                if (detect_din == {W{1'b0}}) zero_count <= zero_count + 1;
                if (elem_count == N-1) begin
                    active <= 1'b0; detect_done <= 1'b1;
                    nonzero_count <= N - zero_count;
                    if ((N-zero_count)*100 <= 30*N) sparsity_level <= 2'b00;
                    else if ((N-zero_count)*100 >= 70*N) sparsity_level <= 2'b10;
                    else sparsity_level <= 2'b01;
                    elem_count <= 8'b0;
                end else elem_count <= elem_count + 1;
            end
        end
    end
endmodule 
module multiplier_selector_fsm(
    input clk, input reset, input start_select,
    input [1:0] sparsity_level, input [1:0] precision_mode,
    output reg [1:0] sel
);
    always @(posedge clk) begin
        if (reset) sel <= 2'b00;
        else if (start_select) begin
            if ((sparsity_level == 2'b10) && (precision_mode == 2'b10)) sel <= 2'b00;
            else if ((sparsity_level == 2'b00) && (precision_mode == 2'b00)) sel <= 2'b10;
            else sel <= 2'b01;
        end
    end
endmodule 
module dsp_multiplier #(parameter W=8) (
    input clk, input reset, input start_dsp,
    input signed [W-1:0] A, input signed [W-1:0] B,
    output reg signed [2*W-1:0] P_dsp,
    output reg done_dsp
);
    reg active;
    reg signed [2*W-1:0] result_reg;
    (* use_dsp = "yes" *) reg signed [2*W-1:0] dsp_product; 
    always @(*) dsp_product = A * B; 
    always @(posedge clk) begin
        if (reset) begin
            P_dsp <= {2*W{1'b0}}; done_dsp <= 1'b0;
            active <= 1'b0; result_reg <= {2*W{1'b0}};
        end else begin
            done_dsp <= 1'b0;
            if (start_dsp && !active) begin
                result_reg <= dsp_product; active <= 1'b1;
            end else if (active) begin
                P_dsp <= result_reg; done_dsp <= 1'b1; active <= 1'b0;
            end
        end
    end
endmodule 
module booth_multiplier #(parameter W = 8) (
    input clk,
    input reset,
    input start_booth,
    input signed [W-1:0] A,
    input signed [W-1:0] B,
    output reg signed [2*W-1:0] P_booth,
    output reg done_booth
 );
    reg signed [2*W-1:0] AQ;
    reg Q_neg;
    reg signed [W-1:0] M;
    reg [5:0] count;
    reg busy;
    reg signed [2*W-1:0] AQ_temp;
    always @(*) begin
        case ({AQ[0], Q_neg})
            2'b01: AQ_temp = {AQ[2*W-1:W] + {{1{M[W-1]}}, M}, AQ[W-1:0]};
            2'b10: AQ_temp = {AQ[2*W-1:W] - {{1{M[W-1]}}, M}, AQ[W-1:0]};
            default: AQ_temp = AQ;
        endcase
    end
    always @(posedge clk) begin
        if (reset) begin
            AQ <= 0;
            Q_neg <= 0;
            M <= 0;
            P_booth <= 0;
            done_booth <= 0;
            count <= 0;
            busy <= 0;
        end else begin 
            done_booth <= 0; 
            if (start_booth &&!busy) begin
                M <= A;
                AQ <= {{W{1'b0}}, B};
                Q_neg <= 1'b0;
                count <= 0;
                busy <= 1;
            end else if (busy) begin
                Q_neg <= AQ_temp[0];
                AQ <= {AQ_temp[2*W-1], AQ_temp[2*W-1:1]}; 
                count <= count + 1;
                if (count == W-1) begin
                    P_booth <= {AQ_temp[2*W-1:W], AQ_temp[W-1:1]};
                    done_booth <= 1;
                    busy <= 0;
              end
            end
        end
    end
endmodule 
module bitserial_multiplier #(parameter W=8) (
    input clk, input reset, input start_bit,
    input signed [W-1:0] A, input signed [W-1:0] B,
    output reg signed [2*W-1:0] P_bit,
    output reg done_bit
);
    reg [5:0] count;
    reg signed [2*W-1:0] sum;
    reg signed [W+W-1:0] a_ext, b_ext;
    reg busy; 
    always @(posedge clk) begin
        if (reset) begin
            count <= 6'b0; P_bit <= {2*W{1'b0}}; done_bit <= 1'b0;
            sum <= {2*W{1'b0}}; a_ext <= {2*W{1'b0}}; b_ext <= {2*W{1'b0}}; busy <= 1'b0;
        end else begin
            done_bit <= 1'b0;
            if (start_bit && !busy) begin
                a_ext <= {{(W){A[W-1]}}, A}; b_ext <= {{(W){B[W-1]}}, B};
                sum <= {2*W{1'b0}}; count <= 6'b0; busy <= 1'b1;
            end else if (busy) begin
                if (b_ext[0]) sum <= sum + (a_ext << count);
                b_ext <= b_ext >> 1;
                count <= count + 1;
                if (count == W-1) begin
                    P_bit <= sum; done_bit <= 1'b1; busy <= 1'b0;
                end
            end
        end
    end
endmodule 
module product_mux_fixed #(parameter W=8) (
    input [1:0] sel,
    input signed [2*W-1:0] P_dsp, input signed [2*W-1:0] P_booth, input signed [2*W-1:0] P_bit,
    output reg signed [2*W-1:0] P_selected
);
    always @(*) begin
        case(sel)
            2'b00: P_selected = P_dsp;
            2'b01: P_selected = P_booth;
            2'b10: P_selected = P_bit;
            default: P_selected = {2*W{1'b0}};
        endcase
    end
endmodule 
(* fsm_encoding="johnson" *)  
module top_control_fsm #(parameter N=2, W=8) (
    input clk, input reset, input start_all,
    output reg done_all,
    output reg [31:0] read_addr_A, output reg read_en_A, input signed [W-1:0] A_out,
    output reg [31:0] read_addr_B, output reg read_en_B, input signed [W-1:0] B_out,
    output reg [31:0] write_addr_C, output reg write_en_C, output reg signed [2*W-1:0] C_in,
    output reg detect_start, output reg detect_valid, output reg signed [W-1:0] detect_din,
    input detect_done, input [1:0] sparsity_level, input [1:0] precision_mode,
    output reg start_select, input [1:0] sel,
    output reg start_dsp, input done_dsp, input signed [2*W-1:0] P_dsp,
    output reg start_booth, input done_booth, input signed [2*W-1:0] P_booth,
    output reg start_bit, input done_bit, input signed [2*W-1:0] P_bit,
    output reg signed [W-1:0] mult_operand_A, output reg signed [W-1:0] mult_operand_B,
    output reg [31:0] cycle_count, output reg [31:0] mac_executed,
    output reg [31:0] mac_skipped, output reg [31:0] switch_count,
    output reg [31:0] current_row
);
    typedef enum logic [4:0] {
        IDLE=4'b0000, DETECT_START=4'b0001, WAIT_DETECT_START = 4'b0010 ,DETECT_STREAM=4'b0011, SELECT=4'b0100,WAIT_SELECT = 4'b0101,
        LOAD_AB=4'b0110, WAIT_DATA=4'b0111, WAIT_OPERANDS=4'b1000, CHECK_ZERO=4'b1001,
        WAIT_MULT=4'b1010, WAIT_MULT_STABLE=4'b1011, WRITEBACK=4'b1100,
        NEXT_ELEMENT=4'b1101, DONE=4'b1110
    } state_t; 
    state_t state;
    reg [31:0] r, c, j, j_det;
    reg signed [2*W-1:0] acc;
    reg [1:0] sel_reg, prev_sel;
    wire signed [2*W-1:0] P_selected; 
    product_mux_fixed #(.W(W)) mux_sel (
        .sel(sel_reg), .P_dsp(P_dsp), .P_booth(P_booth), .P_bit(P_bit), .P_selected(P_selected)
    ); 
    reg signed [W-1:0] operand_A_latched, operand_B_latched;
    reg start_mult; 
    always @(*) begin
        mult_operand_A = operand_A_latched;
        mult_operand_B = operand_B_latched;
    end 
    always @(*) begin
        start_dsp = 1'b0; start_booth = 1'b0; start_bit = 1'b0;
        if (start_mult) begin
            case(sel_reg)
                2'b00: start_dsp = 1'b1;
                2'b01: start_booth = 1'b1;
                2'b10: start_bit = 1'b1;
                default: ;
            endcase
        end
    end 
    wire done_mult = (sel_reg == 2'b00) ? done_dsp :
                     (sel_reg == 2'b01) ? done_booth : done_bit; 
    always @(posedge clk) begin
        if(reset) begin
            state <= IDLE; done_all <= 1'b0; cycle_count <= 32'b0;
            mac_executed <= 32'b0; mac_skipped <= 32'b0; switch_count <= 32'b0;
            r <= 32'b0; c <= 32'b0; j <= 32'b0; j_det <= 32'b0;
            acc <= {(2*W){1'b0}}; sel_reg <= 2'b0; prev_sel <= 2'b0;
            start_mult <= 1'b0; write_en_C <= 1'b0; write_addr_C <= 32'b0; C_in <= {(2*W){1'b0}};
            operand_A_latched <= {W{1'b0}}; operand_B_latched <= {W{1'b0}};
            read_en_A <= 1'b0; read_en_B <= 1'b0;
            detect_start <= 1'b0; detect_valid <= 1'b0; detect_din <= {W{1'b0}};
            start_select <= 1'b0; read_addr_A <= 32'b0; read_addr_B <= 32'b0;
            current_row <= 32'b0;
        end else begin
            cycle_count <= cycle_count + 1; done_all <= 1'b0;
            read_en_A <= 1'b0; read_en_B <= 1'b0;
            detect_start <= 1'b0; detect_valid <= 1'b0; detect_din <= {W{1'b0}};
            start_select <= 1'b0; start_mult <= 1'b0;
            write_en_C <= 1'b0; write_addr_C <= 32'b0; C_in <= {(2*W){1'b0}};
            current_row <= r; 
            case(state)
                IDLE: begin
                    acc <= {(2*W){1'b0}};
                    if(start_all) begin
                        r <= 32'b0; c <= 32'b0; j <= 32'b0; j_det <= 32'b0;
                        mac_executed <= 32'b0; mac_skipped <= 32'b0; switch_count <= 32'b0;
                        sel_reg <= 2'b0; prev_sel <= 2'b0;
                        state <= DETECT_START;
                    end
                end 
                DETECT_START: begin
                    detect_start <= 1'b1; detect_valid <= 1'b1;
                    j_det <= 32'b0; read_addr_A <= r*N + 0; read_en_A <= 1'b1;
                    detect_din <= A_out; prev_sel <= 2'b11;
                    state <= WAIT_DETECT_START;
                end
                WAIT_DETECT_START: begin
                    detect_start <= 0;
                    detect_valid <= 1;
                    detect_din <= A_out;
                    state <= DETECT_STREAM;
                end 
                DETECT_STREAM: begin
                    detect_valid <= 1'b1; detect_din <= A_out;
                    if(j_det < N-1) begin
                        j_det <= j_det + 1; read_addr_A <= r*N + j_det + 1; read_en_A <= 1'b1;
                    end else begin
                        read_en_A <= 1'b0; read_addr_A <= 32'b0;
                        if(detect_done) begin
                            detect_valid <= 1'b0; start_select <= 1'b1; 
                            state <= SELECT;
                        end
                    end
                end 
                SELECT: begin
                    sel_reg <= sel;
                    if(sel != prev_sel) switch_count <= switch_count + 1;
                    prev_sel <= sel; c <= 32'b0; j <= 32'b0; acc <= {(2*W){1'b0}};
                    state <= WAIT_SELECT;
                end 
               WAIT_SELECT: begin
                    start_select <= 0;
                    sel_reg <= sel; //
                    if ((sel != prev_sel) && (prev_sel != 2'b11)) begin
                        switch_count <= switch_count + 1;
                        $display("[%t] FSM: SELECT multiplier switched from %b to %b",$time, prev_sel, sel);
                    end
                    prev_sel <= sel;
                    c <= 0;
                    j <= 0;
                    acc <= 0;
                    $display("[%t] FSM: SELECT multiplier selected %b", $time, sel);
                    state <= LOAD_AB;
                end 
                LOAD_AB: begin
                    read_addr_A <= r*N + j; read_addr_B <= j*N + c;
                    read_en_A <= 1'b1; read_en_B <= 1'b1;
                    state <= WAIT_DATA;
                end 
                WAIT_DATA: state <= WAIT_OPERANDS; 
                WAIT_OPERANDS: begin
                    operand_A_latched <= A_out; operand_B_latched <= B_out;
                    state <= CHECK_ZERO;
                end 
                CHECK_ZERO: begin
                    if ((operand_A_latched == {W{1'b0}}) || (operand_B_latched == {W{1'b0}})) begin
                        mac_skipped <= mac_skipped + 1;
                        if(j < N-1) begin j <= j + 1; state <= LOAD_AB; end
                        else state <= WRITEBACK;
                    end else begin
                        mac_executed <= mac_executed + 1; start_mult <= 1'b1; state <= WAIT_MULT;
                    end
                end 
                WAIT_MULT: if(done_mult) state <= WAIT_MULT_STABLE; 
                WAIT_MULT_STABLE: begin
                    acc <= acc + P_selected;
                    if(j < N-1) begin j <= j + 1; state <= LOAD_AB; end
                    else state <= WRITEBACK;
                end 
                WRITEBACK: begin
                    write_addr_C <= r*N + c; write_en_C <= 1'b1; C_in <= acc;
                    state <= NEXT_ELEMENT;
                end 
                NEXT_ELEMENT: begin
                    write_en_C <= 1'b0; acc <= {(2*W){1'b0}};
                    if(c < N-1) begin c <= c + 1; j <= 32'b0; state <= LOAD_AB; end
                    else if(r < N-1) begin r <= r + 1; c <= 32'b0; j <= 32'b0; state <= DETECT_START; end
                    else state <= DONE;
                end 
                DONE: done_all <= 1'b1; 
                default: state <= IDLE;
            endcase
        end
    end
endmodule
