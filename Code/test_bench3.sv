`timescale 1ns/1ps
module tb_sparse_matrix_multiply();
    parameter N = 3;
    parameter W = 8;
    reg clk, reset;
    reg start_all;
    wire done_all;
    wire [31:0] read_addr_A;
    wire read_en_A;
    wire signed [W-1:0] A_out;
    wire [31:0] read_addr_B;
    wire read_en_B;
    wire signed [W-1:0] B_out;
    wire [31:0] write_addr_C;
    wire write_en_C;
    wire signed [2*W-1:0] C_in;
    reg [1:0] host_precision;
    reg [1:0] precision_per_row [0:N-1]; 
    wire [1:0] precision_mode;
    wire detect_start;
    wire detect_valid;
    wire signed [W-1:0] detect_din;
    wire detect_done;
    wire [1:0] sparsity_level;
    wire start_select;
    wire [1:0] sel;
    wire start_dsp, start_booth, start_bit;
    wire done_dsp, done_booth, done_bit;
    wire signed [2*W-1:0] P_dsp, P_booth, P_bit;
    wire signed [W-1:0] mult_operand_A, mult_operand_B;
    wire [31:0] cycle_count;
    wire [31:0] mac_executed;
    wire [31:0] mac_skipped;
    wire [31:0] switch_count;
    reg signed [W-1:0] A_mem [0:N*N-1];
    reg signed [W-1:0] B_mem [0:N*N-1];
    reg signed [2*W-1:0] C_mem [0:N*N-1];
    reg signed [2*W-1:0] C_ref [0:N*N-1];
    integer i;
    reg [31:0] A_addr_reg, B_addr_reg
    always @(posedge clk) begin
        if (reset) begin
            A_addr_reg <= 0;
            B_addr_reg <= 0;
        end else begin
            A_addr_reg <= (read_addr_A < N*N) ? read_addr_A : 0;
            B_addr_reg <= (read_addr_B < N*N) ? read_addr_B : 0;
        end
    end 
    assign A_out = A_mem[A_addr_reg];
    assign B_out = B_mem[B_addr_reg]; 
    tile_sparsity #(.N(N), .W(W)) sparsity_inst (
        .clk(clk),
        .reset(reset),
        .detect_start(detect_start),
        .detect_valid(detect_valid),
        .detect_din(detect_din),
        .detect_done(detect_done),
        .sparsity_level(sparsity_level),
        .nonzero_count()
    ); 
    precision_reg precision_inst (
        .clk(clk),
        .reset(reset),
        .host_precision(host_precision),
        .precision_mode(precision_mode)
    ); 
    multiplier_selector_fsm selector_fsm_inst(
        .clk(clk),
        .reset(reset),
        .start_select(start_select),
        .sparsity_level(sparsity_level),
        .precision_mode(precision_mode),
        .sel(sel)
    ); 
    dsp_wrapper_if #(.W(W)) dsp_inst(
        .clk(clk),
        .reset(reset),
        .start_dsp(start_dsp),
        .A(mult_operand_A),
        .B(mult_operand_B),
        .P_dsp(P_dsp),
        .done_dsp(done_dsp)
    ); 
    booth_multiplier_seq #(.W(W)) booth_inst(
        .clk(clk),
        .reset(reset),
        .start_booth(start_booth),
        .A(mult_operand_A),
        .B(mult_operand_B),
        .P_booth(P_booth),
        .done_booth(done_booth)
    ); 
    bitserial_multiplier #(.W(W)) bitserial_inst(
        .clk(clk),
        .reset(reset),
        .start_bit(start_bit),
        .A(mult_operand_A),
        .B(mult_operand_B),
        .P_bit(P_bit),
        .done_bit(done_bit)
    ); 
    top_control_fsm #(.N(N), .W(W)) dut (
        .clk(clk),
        .reset(reset),
        .start_all(start_all),
        .done_all(done_all),
        .read_addr_A(read_addr_A),
        .read_en_A(read_en_A),
        .A_out(A_out),
        .read_addr_B(read_addr_B),
        .read_en_B(read_en_B),
        .B_out(B_out),
        .write_addr_C(write_addr_C),
        .write_en_C(write_en_C),
        .C_in(C_in),
        .detect_start(detect_start),
        .detect_valid(detect_valid),
        .detect_din(detect_din),
        .detect_done(detect_done),
        .sparsity_level(sparsity_level),
        .precision_mode(precision_mode),
        .start_select(start_select),
        .sel(sel),
        .start_dsp(start_dsp),
        .done_dsp(done_dsp),
        .P_dsp(P_dsp),
        .start_booth(start_booth),
        .done_booth(done_booth),
        .P_booth(P_booth),
        .start_bit(start_bit),
        .done_bit(done_bit),
        .P_bit(P_bit),
        .mult_operand_A(mult_operand_A),
        .mult_operand_B(mult_operand_B),
        .cycle_count(cycle_count),
        .mac_executed(mac_executed),
        .mac_skipped(mac_skipped),
        .switch_count(switch_count)
    ); 
    always @(posedge clk) begin
        if (write_en_C && write_addr_C < N*N) begin
            C_mem[write_addr_C] <= C_in;
            $display("Testbench: Writing C_mem[%0d] = %0d", write_addr_C, C_in);
        end
    end 
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end 
    initial begin
        #100000;
        $display("Simulation timeout reached at time %t", $time);
        $finish;
    end 
    always @(posedge clk) begin
        if (($time % 10000) == 0) begin
            $display("Simulation time: %t", $time);
        end
    end 
    initial begin
        reset = 1; 
        start_all = 0;
        precision_per_row[0] = 2'b10;  // Row 0: DSP
        precision_per_row[1] = 2'b01;  // Row 1: Booth
        precision_per_row[2] = 2'b10;  // Row 2: DSP 
        host_precision = precision_per_row[0]; 
        A_mem[0] = 8'd7;  A_mem[1] = 8'd8;  A_mem[2] = 8'd9;
        A_mem[3] = 8'd0;  A_mem[4] = 8'd6;  A_mem[5] = 8'd5;
        A_mem[6] = 8'd2;  A_mem[7] = 8'd0;  A_mem[8] = 8'd4; 
        B_mem[0] = 8'd3;  B_mem[1] = 8'd5;  B_mem[2] = 8'd1;
        B_mem[3] = 8'd4;  B_mem[4] = 8'd2;  B_mem[5] = 8'd7;
        B_mem[6] = 8'd6;  B_mem[7] = 8'd0;  B_mem[8] = 8'd8;
        for (i = 0; i < N*N; i=i+1) begin
            C_mem[i] = 0;
            C_ref[i] = 0;
        end 
        #20 reset = 0;
        #10 start_all = 1;
        #10 start_all = 0;
    end 
    always @(posedge clk) begin
        if (dut.state == dut.DETECT_START && !reset) begin
            host_precision <= precision_per_row[dut.r];
            $display("[%t] Testbench: Setting precision for row %0d to %b (Multiplier: %s)",
                     $time, dut.r, precision_per_row[dut.r],
                     (precision_per_row[dut.r] == 2'b10) ? "DSP" :
                     (precision_per_row[dut.r] == 2'b01) ? "Booth" : "BitSerial");
        end
    end 
    reg done_flag = 0;
    integer r, c, j;
    reg signed [2*W-1:0] sum; 
    always @(posedge clk) begin
        if (done_all && !done_flag) begin
            done_flag = 1;
            for (r=0; r<N; r=r+1) begin
                for (c=0; c<N; c=c+1) begin
                    sum = 0;
                    for (j=0; j<N; j=j+1) begin
                        sum = sum + A_mem[r*N+j]*B_mem[j*N+c];
                    end
                    C_ref[r*N+c] = sum;
                end
            end
            $display("\n============================================================");
            $display("Input Matrix A [3x3]:");
            $display("============================================================");
            for (r=0; r<N; r=r+1) begin
                $write("[ ");
                for (c=0; c<N; c=c+1)
                    $write("%3d ", A_mem[r*N+c]);
                $write("]\n");
            end 
            $display("\nInput Matrix B [3x3]:");
            $display("============================================================");
            for (r=0; r<N; r=r+1) begin
                $write("[ ");
                for (c=0; c<N; c=c+1)
                    $write("%3d ", B_mem[r*N+c]);
                $write("]\n");
            end
            $display("\nExpected Matrix C (Reference) [3x3]:");
            $display("============================================================");
            for (r=0; r<N; r=r+1) begin
                $write("[ ");
                for (c=0; c<N; c=c+1)
                    $write("%5d ", C_ref[r*N+c]);
                $write("]\n");
            end
            $display("\nActual Matrix C (Accelerator Output) [3x3]:");
            $display("============================================================");
            for (r=0; r<N; r=r+1) begin
                $write("[ ");
                for (c=0; c<N; c=c+1)
                    $write("%5d ", C_mem[r*N+c]);
                $write("]\n");
            end
            $display("\n============================================================");
            $display("Performance Statistics:");
            $display("============================================================");
            $display("Total Cycle Count:     %0d", cycle_count);
            $display("MAC Operations:        %0d (Executed)", mac_executed);
            $display("MAC Operations:        %0d (Skipped)", mac_skipped);
            $display("Multiplier Switches:   %0d", switch_count);
            $display("============================================================\n"); 
            $display("Multiplier Configuration per Row:");
            $display("  Row 0: DSP Multiplier    (precision: 2'b10)");
            $display("  Row 1: Booth Multiplier  (precision: 2'b01)");
            $display("  Row 2: DSP Multiplier    (precision: 2'b10)");
            $display("============================================================\n");
            $display("Verification:");
            $display("============================================================");
            for (i=0; i<N*N; i=i+1) begin
                if (C_mem[i] !== C_ref[i]) begin
                    $display("ERROR at index %0d (Row %0d, Col %0d): Output %0d, Reference %0d", 
                             i, i/N, i%N, C_mem[i], C_ref[i]);
                    $fatal;
                end
            end 
            $display("SUCCESS: All 9 outputs match reference multiplication.");
            $display("============================================================\n");
            $finish;
        end
    end
endmodule
