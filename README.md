# Sparse-and-Precision-Aware-Mtarix-Multiply-Unit-with-Runtime-Multiplier-Switching-on-FPGA

1.DESIGN AND ARCHITECTURE:
This project is a hardware matrix multiplication accelerator that computes C = A × B for N×N matrices (currently only tested for NxN matrices, however the design is parameterized and with small changes can be scaled for NxM matrices). It is a sparse and precision-aware, runtime-adaptive accelerator that detects sparsity per-row at runtime and accepts external precision settings per-row, then dynamically selects the appropriate multiplier architecture based on these characteristics.
The design instantiates three multiplier architectures: (1) DSP Multiplier for high-speed operations, (2) Booth Sequential Multiplier for medium-speed operations, (3) Bit-Serial Multiplier for low-power operations.
The accelerator employs a three-stage pipeline architecture: (1) Sparsity Detection per-row at runtime, (2) Dynamic Multiplier Selection based on sparsity and precision levels, (3) Sparse-Aware Matrix Multiplication with zero-skipping optimization
Performance Metrics:
cycle_count – Total clock cycles elapsed
mac_executed – Number of multiplication and accumulation operations performed
mac_skipped – Number of multiplications and accumulation operations skipped 
switch_count – Number of times multiplier selection changed between rows
calculated C matrix
From FPGA – Result verification using hardware.
Formula for multiplication: 
C[r][c] = Summation ( A[r][j] * B[j][c] ) for j = 0 to N-1

2.MODULE LEVEL EXPLANATION AND SIGNALS:
This design is implemented using 11 modules:
All modules receive synchronous clock (clk) and synchronous reset (reset) signals. Modules operate on rising clock edges and use handshake signals (start/done pairs) for inter-module communication.

1. 3 Memory Modules – A_bram, B_bram and C_bram:
Inputs: read_addr and read_en are used as handshakes by other modules to request data from memory by providing address for that data and an enable signal.
Output: dout is the element whose address was given.
These modules fetch data from the requested address and output it on the next clock cycle (1-cycle latency). For testbench simulation, a write_mem task initializes memory contents at simulation start.
2. tile_sparsity Module:
Input: detect_start and detect_valid are two handshake signals used by control FSM to tell sparsity module to start detecting sparsity of current row based on elements being streamed to it from memory. Current element for checking is provided by detect_din.
Output: detect_done signal used as a handshake to tell control FSM that sparsity detection is complete and sparsity_level has the value of sparsity of current row.
Sparse – 2’b00
Balanced – 2’b01
Dense – 2’b10
This module is responsible for calculating the sparsity of each row and sending the correct sparsity level to main control FSM for further processing. To calculate sparsity we count number of non-zero elements divide that with total elements and multiply that with 100. Then based on a decision policy we determine sparsity level.
3. precision_reg Module:
Here we set the precision per row externally via testbench in simulation and via switches on FPGA.
Input: host_precision this is the prescision user sets for each row
32-bit : 2’b10
16-bit: 2’b01
8-bit: 2’b00
This module stores the precision mode for each row. In simulation, precision_mode is set via testbench variables. On FPGA hardware, precision values are loaded from the 2-bit switches sw[7:6] and updated per-row.
4. multiplier_selector_fsm Module:
Input: start_select is a handshake signal from control FSM to this module to start selecting multiplier based on inputs sparsity_level and precision_mode.
Ouput: the selected multiplier as sel.
Sparsity level	Precision Mode	Multiplier
2’b10 (Dense)	2’b10 (32bit)	DSP multiplier 2b’00
2’b01 (Balanced)	2’b01 (16bit)	Booth Multiplier 2b’01
2’b00 (Sparse)	2’b00 (8bit)	Bit serial Multiplier 2b’10
Default Multiplier – dsp (2’b00)
5. 3 Different multiplier architecture Modules: dsp_wrapper, booth_multiplier_seq and bitserial multiplier
Input: element from matrix A as A and from matrix B as B.
Output: done handshake signal for control FSM and the calculated product P.
These are the main calculation houses of the design responsible for multiplying the inputs from FSM correctly
This module is responsible for selecting correct multiplier architecture based on inputs from main control FSM.
6.product_mux Module:
This multiplexer selects the output from one of three multiplier modules based on the sel[1:0] control signal and routes it to the FSM accumulator. All multipliers are instantiated but only one is active at a the mux selects which multipliers result to use.
7. top_control_fsm Module:
This is the main brain of the entire design that orchestrates the flow of operations ensuring proper selection of multipliers and proper multiplication. All other modules are instantiated inside this module.
For each output element C[r][c] ,the FSM loops j from 0 to N-1. Reads A[r][j] and B[j][c] from memory. Checks if either operand is zero to decide whether to skip the multiply. If both nonzero execute multiply with the selected multiplier and accumulates result into accumulator register. Writes accumulated result to C[r][c].
It uses a 15 state FSM:
State 0: IDLE – all signals and counters for loop like r,j,c are deasserted.
State 1: DETECT_START – here we assert a signal to sparsity module to begin calculating the sparsity level.
State 2: WAIT_DETECT_START – this state was added to account for BRAM latency.
State 3: DETECT_STREAM – In this state we pass all elements of our row to the tile sparsity module
State 4: SELECT – In this state the multiplier selector fsm selects multiplier architecture based on sparsity and precision of that row
State 5: WAIT_SELECT – additional state added to allow proper switching of multiplier
State 6: LOAD_AB – here elements to be currently multiplied all loaded from memory
State 7: WAIT_DATA - Accounts for 1-cycle BRAM read latency, operand data stabilizes during this state
State 8: WAIT_OPERANDS - Latches current A and B operands into registers to maintain stable values during the multiplier's multi-cycle execution
State 9: CHECK_ZERO – here before passing on the elements to multiplier we check if either one is zero to skip multiplication this is an optimization done to make design sparse aware and save cycles and power per MAC.
State 10: WAIT_MULT – this is added to wait for multiplication process to be completed by the respective multiplier
State 11: WAIT_MULT_STABLE – Ensures the product result is stable before accumulation 
State 12: WRITE_BACK – here we add the value to the accumulator and check if any inner loop executions are left for current element or if any other element in current row is unprocessed or if all rows are processed.
State 13: NEXT_ELEMENT – If any element is left to be processed initialize the counters and start loading the data
State 14: DONE – Once all computations are done top control fsm asserts this signal.

3.CHANGES MADE TO MAKE CODE SYNTHESIZABLE:
To enable synthesis on FPGA hardware and interface with physical I/O (buttons, switches, LEDs),  additional modules were added to bridge between the core and real hardware:
1.switch_input_controller Module:
Inputs: Wires for 8 bit switch input from FPGA, button to switch between mode A and B, Button to store precision mode.
Output: Registers for 8bit data to be loaded in memory, Address where to store, enable signal to write data, to select which matrix to load data to, precision for each row and the row whose precision must be set.
Button debouncing – Shift registers that store last 3 states of each button. They are used to detect rising edges which means user pressed the button. This is done to avoid multiple triggers due to one button press.
Bit mapping: SW[3:0] = data value (4 bits), SW[5:4] = matrix address (2 bits), SW[7:6] = precision mode (2 bits)
2. result_display_cycler Module:
This module cycles through result matrix C outputs (one element per button press on BTN4) and displays the lower 8 bits on LEDs. Upon reaching the last element (C[N×N-1]), the next button press wraps back to C. Button debouncing (3-stage shift register) detects rising edges of BTN4.
3. sparse_matrix_multiply Module:
This top-level wrapper module interfaces between FPGA I/O (buttons, switches, LEDs, clock) and the internal computation core. It instantiates button debouncing, input controller, result display controller, and the sparse matrix core with I/O handling.
4.sparse_matrix_core_with_io Module: 
This is a wrapper module that connects computation engine with I/O handling.
5. original_sparse_matrix_core Module:
This is the core computation engine with all other modules necessary for computation instantiated here.


BOARD
├── CLK100MHZ → clk (all modules)
├── btn[4:0] → sparse_matrix_multiply
│   ├── btn[0] → reset
│   ├── btn[1] → store/start (context-dependent)
│   ├── btn[2] → toggle matrix A/B
│   ├── btn[3] → store precision
│   └── btn[4] → next result
├── sw[7:0] → sparse_matrix_multiply
│   ├── sw[3:0] → data value
│   ├── sw[5:4] → address
│   └── sw[7:6] → precision mode
└── led[7:0] ← sparse_matrix_multiply
sparse_matrix_multiply
├── switch_input_controller
│   ├── Inputs: btn, sw
│   └── Outputs: load_data, load_addr, load_en, matrix_sel, precision_reg
├── result_display_cycler
│   ├── Inputs: btn[4], current_result
│   └── Outputs: display_data, result_idx
└── sparse_matrix_core_with_io ← CORE WRAPPER
    ├── A_bram_ext (stores matrix A)
    ├── B_bram_ext (stores matrix B)
    ├── C_bram_ext (stores results)
    ├── precision_reg_ext
    └── original_sparse_matrix_core ← COMPUTATION ENGINE
        ├── tile_sparsity
        ├── multiplier_selector_fsm
        ├── dsp_multiplier
        ├── booth_multiplier
        ├── bitserial_multiplier
        ├── product_mux_fixed
        └── top_control_fsm ← THE BRAIN
            ├── Controls: read_addr_A/B, write_addr_C
            ├── Triggers: detect_start, start_select, start_mult
            ├── Monitors: detect_done, done_mult
            └── Coordinates: All 15 FSM states

4.ZEDBOARD PIN MAPPINGS (USING MASTER FILE FROM DIGILENT):
SW0-3 for data of matrix
SW4-5 for address in matrix
SW6-7 precision per row
BTN0(Pin P16) – Reset
BTN1(Pin R16) – Store Data/ Start multiplication
BTN2(Pin N15) – Toggle between matrix A and B
BTN3(Pin R18) – Store Precision per row
BTN4(Pin T18) – Cycle through results
