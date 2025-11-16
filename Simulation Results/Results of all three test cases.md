# Test_bench1 (no switching) :
Console ouput:
[               35000] FSM: IDLE -> DETECT_START
[               45000] Testbench: Setting precision for row 0 to 10
[               45000] FSM: DETECT_START row 0
[               65000] FSM: DETECT_STREAM reading A[1]
[               75000] FSM: DETECT_STREAM waiting for detect_done
[               95000] FSM: SELECT requesting multiplier selection sparsity=10 precision=10
[               95000] MultiplierSelectorFSM: sparsity=10, precision=10
[               95000] MultiplierSelectorFSM: selected multiplier=00
[              105000] MultiplierSelectorFSM: sparsity=10, precision=10
[              105000] MultiplierSelectorFSM: selected multiplier=00
[              105000] FSM: SELECT multiplier selected 00
[              115000] FSM: LOAD_AB reading A[0], B[0]
[              125000] FSM: WAIT_DATA waiting for memory data to stabilize
[              135000] FSM: WAIT_OPERANDS latched operands A=2 B=1
[              145000] FSM: CHECK_ZERO A_out=2 B_out=1
[              145000] FSM: CHECK_ZERO starting multiply sel=00 A=2 B=1
[              155000] FSM: WAIT_MULT waiting multiplier done
[              165000] FSM: WAIT_MULT waiting multiplier done
[              175000] FSM: WAIT_MULT done, waiting for stability
[              185000] FSM: WAIT_MULT_STABLE updated acc = 2 (prev=0 + result=2)
[              195000] FSM: LOAD_AB reading A[1], B[2]
[              205000] FSM: WAIT_DATA waiting for memory data to stabilize
[              215000] FSM: WAIT_OPERANDS latched operands A=3 B=5
[              225000] FSM: CHECK_ZERO A_out=3 B_out=5
[              225000] FSM: CHECK_ZERO starting multiply sel=00 A=3 B=5
[              235000] FSM: WAIT_MULT waiting multiplier done
[              245000] FSM: WAIT_MULT waiting multiplier done
[              255000] FSM: WAIT_MULT done, waiting for stability
[              265000] FSM: WAIT_MULT_STABLE updated acc = 17 (prev=2 + result=15)
[              275000] FSM: WRITEBACK writing 17 to C[0]
Testbench: Writing C_mem[0] = 17
[              285000] FSM: NEXT_ELEMENT next column 1
[              295000] FSM: LOAD_AB reading A[0], B[1]
[              305000] FSM: WAIT_DATA waiting for memory data to stabilize
[              315000] FSM: WAIT_OPERANDS latched operands A=2 B=4
[              325000] FSM: CHECK_ZERO A_out=2 B_out=4
[              325000] FSM: CHECK_ZERO starting multiply sel=00 A=2 B=4
[              335000] FSM: WAIT_MULT waiting multiplier done
[              345000] FSM: WAIT_MULT waiting multiplier done
[              355000] FSM: WAIT_MULT done, waiting for stability
[              365000] FSM: WAIT_MULT_STABLE updated acc = 8 (prev=0 + result=8)
[              375000] FSM: LOAD_AB reading A[1], B[3]
[              385000] FSM: WAIT_DATA waiting for memory data to stabilize
[              395000] FSM: WAIT_OPERANDS latched operands A=3 B=2
[              405000] FSM: CHECK_ZERO A_out=3 B_out=2
[              405000] FSM: CHECK_ZERO starting multiply sel=00 A=3 B=2
[              415000] FSM: WAIT_MULT waiting multiplier done
[              425000] FSM: WAIT_MULT waiting multiplier done
[              435000] FSM: WAIT_MULT done, waiting for stability
[              445000] FSM: WAIT_MULT_STABLE updated acc = 14 (prev=8 + result=6)
[              455000] FSM: WRITEBACK writing 14 to C[1]
Testbench: Writing C_mem[1] = 14
[              465000] FSM: NEXT_ELEMENT next row 1
[              475000] Testbench: Setting precision for row 1 to 00
[              475000] FSM: DETECT_START row 1
[              495000] FSM: DETECT_STREAM reading A[3]
[              505000] FSM: DETECT_STREAM waiting for detect_done
[              525000] FSM: SELECT requesting multiplier selection sparsity=01 precision=00
[              535000] FSM: SELECT multiplier selected 00
[              535000] MultiplierSelectorFSM: sparsity=01, precision=00
[              535000] MultiplierSelectorFSM: selected multiplier=00
[              545000] FSM: LOAD_AB reading A[2], B[0]
[              555000] FSM: WAIT_DATA waiting for memory data to stabilize
[              565000] FSM: WAIT_OPERANDS latched operands A=0 B=1
[              575000] FSM: CHECK_ZERO A_out=0 B_out=1
[              575000] FSM: CHECK_ZERO skipping MAC
[              585000] FSM: LOAD_AB reading A[3], B[2]
[              595000] FSM: WAIT_DATA waiting for memory data to stabilize
[              605000] FSM: WAIT_OPERANDS latched operands A=4 B=5
[              615000] FSM: CHECK_ZERO A_out=4 B_out=5
[              615000] FSM: CHECK_ZERO starting multiply sel=00 A=4 B=5
[              625000] FSM: WAIT_MULT waiting multiplier done
[              635000] FSM: WAIT_MULT waiting multiplier done
[              645000] FSM: WAIT_MULT done, waiting for stability
[              655000] FSM: WAIT_MULT_STABLE updated acc = 20 (prev=0 + result=20)
[              665000] FSM: WRITEBACK writing 20 to C[2]
Testbench: Writing C_mem[2] = 20
[              675000] FSM: NEXT_ELEMENT next column 1
[              685000] FSM: LOAD_AB reading A[2], B[1]
[              695000] FSM: WAIT_DATA waiting for memory data to stabilize
[              705000] FSM: WAIT_OPERANDS latched operands A=0 B=4
[              715000] FSM: CHECK_ZERO A_out=0 B_out=4
[              715000] FSM: CHECK_ZERO skipping MAC
[              725000] FSM: LOAD_AB reading A[3], B[3]
[              735000] FSM: WAIT_DATA waiting for memory data to stabilize
[              745000] FSM: WAIT_OPERANDS latched operands A=4 B=2
[              755000] FSM: CHECK_ZERO A_out=4 B_out=2
[              755000] FSM: CHECK_ZERO starting multiply sel=00 A=4 B=2
[              765000] FSM: WAIT_MULT waiting multiplier done
[              775000] FSM: WAIT_MULT waiting multiplier done
[              785000] FSM: WAIT_MULT done, waiting for stability
[              795000] FSM: WAIT_MULT_STABLE updated acc = 8 (prev=0 + result=8)
[              805000] FSM: WRITEBACK writing 8 to C[3]
Testbench: Writing C_mem[3] = 8
[              815000] FSM: NEXT_ELEMENT multiply done
[              825000] FSM: DONE done
Input Matrix A:
[ 2 3 ]
[ 0 4 ]
Input Matrix B:
[ 1 4 ]
[ 5 2 ]
Expected Matrix C (Reference):
[ 17 14 ]
[ 20 8 ]
Actual Matrix C (Accelerator Output):
[ 17 14 ]
[ 20 8 ]

============================================================
Performance Statistics:
============================================================
Cycle Count:         81
MAC executed:          6
MAC skipped:          2
Switch count:          0
============================================================
SUCCESS: All outputs match reference multiplication.
============================================================
testbench.sv:308: $finish called at 835000 (1ps)
[              835000] FSM: DONE done
Done

# Test_bench2 (switching):
Console Output:
[               35000] FSM: IDLE -> DETECT_START
[               45000] Testbench: Setting precision for row 0 to 10
[               45000] FSM: DETECT_START row 0
[               65000] FSM: DETECT_STREAM reading A[1]
[               75000] FSM: DETECT_STREAM waiting for detect_done
[               95000] FSM: SELECT requesting multiplier selection sparsity=10 precision=10
[               95000] MultiplierSelectorFSM: sparsity=10, precision=10
[               95000] MultiplierSelectorFSM: selected multiplier=00
[              105000] MultiplierSelectorFSM: sparsity=10, precision=10
[              105000] MultiplierSelectorFSM: selected multiplier=00
[              105000] FSM: SELECT multiplier selected 00
[              115000] FSM: LOAD_AB reading A[0], B[0]
[              125000] FSM: WAIT_DATA waiting for memory data to stabilize
[              135000] FSM: WAIT_OPERANDS latched operands A=7 B=3
[              145000] FSM: CHECK_ZERO A_out=7 B_out=3
[              145000] FSM: CHECK_ZERO starting multiply sel=00 A=7 B=3
[              155000] FSM: WAIT_MULT waiting multiplier done
[              165000] FSM: WAIT_MULT waiting multiplier done
[              175000] FSM: WAIT_MULT done, waiting for stability
[              185000] FSM: WAIT_MULT_STABLE updated acc = 21 (prev=0 + result=21)
[              195000] FSM: LOAD_AB reading A[1], B[2]
[              205000] FSM: WAIT_DATA waiting for memory data to stabilize
[              215000] FSM: WAIT_OPERANDS latched operands A=8 B=4
[              225000] FSM: CHECK_ZERO A_out=8 B_out=4
[              225000] FSM: CHECK_ZERO starting multiply sel=00 A=8 B=4
[              235000] FSM: WAIT_MULT waiting multiplier done
[              245000] FSM: WAIT_MULT waiting multiplier done
[              255000] FSM: WAIT_MULT done, waiting for stability
[              265000] FSM: WAIT_MULT_STABLE updated acc = 53 (prev=21 + result=32)
[              275000] FSM: WRITEBACK writing 53 to C[0]
Testbench: Writing C_mem[0] = 53
[              285000] FSM: NEXT_ELEMENT next column 1
[              295000] FSM: LOAD_AB reading A[0], B[1]
[              305000] FSM: WAIT_DATA waiting for memory data to stabilize
[              315000] FSM: WAIT_OPERANDS latched operands A=7 B=5
[              325000] FSM: CHECK_ZERO A_out=7 B_out=5
[              325000] FSM: CHECK_ZERO starting multiply sel=00 A=7 B=5
[              335000] FSM: WAIT_MULT waiting multiplier done
[              345000] FSM: WAIT_MULT waiting multiplier done
[              355000] FSM: WAIT_MULT done, waiting for stability
[              365000] FSM: WAIT_MULT_STABLE updated acc = 35 (prev=0 + result=35)
[              375000] FSM: LOAD_AB reading A[1], B[3]
[              385000] FSM: WAIT_DATA waiting for memory data to stabilize
[              395000] FSM: WAIT_OPERANDS latched operands A=8 B=2
[              405000] FSM: CHECK_ZERO A_out=8 B_out=2
[              405000] FSM: CHECK_ZERO starting multiply sel=00 A=8 B=2
[              415000] FSM: WAIT_MULT waiting multiplier done
[              425000] FSM: WAIT_MULT waiting multiplier done
[              435000] FSM: WAIT_MULT done, waiting for stability
[              445000] FSM: WAIT_MULT_STABLE updated acc = 51 (prev=35 + result=16)
[              455000] FSM: WRITEBACK writing 51 to C[1]
Testbench: Writing C_mem[1] = 51
[              465000] FSM: NEXT_ELEMENT next row 1
[              475000] Testbench: Setting precision for row 1 to 01
[              475000] FSM: DETECT_START row 1
[              495000] FSM: DETECT_STREAM reading A[3]
[              505000] FSM: DETECT_STREAM waiting for detect_done
[              535000] MultiplierSelectorFSM: sparsity=01, precision=01
[              535000] MultiplierSelectorFSM: selected multiplier=01
[              545000] FSM: LOAD_AB reading A[2], B[0]
[              555000] FSM: WAIT_DATA waiting for memory data to stabilize
[              565000] FSM: WAIT_OPERANDS latched operands A=0 B=3
[              575000] FSM: CHECK_ZERO A_out=0 B_out=3
[              575000] FSM: CHECK_ZERO skipping MAC
[              585000] FSM: LOAD_AB reading A[3], B[2]
[              595000] FSM: WAIT_DATA waiting for memory data to stabilize
[              605000] FSM: WAIT_OPERANDS latched operands A=9 B=4
[              615000] FSM: CHECK_ZERO A_out=9 B_out=4
[              615000] FSM: CHECK_ZERO starting multiply sel=01 A=9 B=4
[              625000] FSM: WAIT_MULT waiting multiplier done
[              635000] FSM: WAIT_MULT waiting multiplier done
[              645000] FSM: WAIT_MULT waiting multiplier done
[              655000] FSM: WAIT_MULT waiting multiplier done
[              665000] FSM: WAIT_MULT waiting multiplier done
[              675000] FSM: WAIT_MULT waiting multiplier done
[              685000] FSM: WAIT_MULT waiting multiplier done
[              695000] FSM: WAIT_MULT waiting multiplier done
[              705000] FSM: WAIT_MULT waiting multiplier done
[              715000] FSM: WAIT_MULT done, waiting for stability
[              725000] FSM: WAIT_MULT_STABLE updated acc = 36 (prev=0 + result=36)
[              735000] FSM: WRITEBACK writing 36 to C[2]
Testbench: Writing C_mem[2] = 36
[              745000] FSM: NEXT_ELEMENT next column 1
[              755000] FSM: LOAD_AB reading A[2], B[1]
[              765000] FSM: WAIT_DATA waiting for memory data to stabilize
[              775000] FSM: WAIT_OPERANDS latched operands A=0 B=5
[              785000] FSM: CHECK_ZERO A_out=0 B_out=5
[              785000] FSM: CHECK_ZERO skipping MAC
[              795000] FSM: LOAD_AB reading A[3], B[3]
[              805000] FSM: WAIT_DATA waiting for memory data to stabilize
[              815000] FSM: WAIT_OPERANDS latched operands A=9 B=2
[              825000] FSM: CHECK_ZERO A_out=9 B_out=2
[              825000] FSM: CHECK_ZERO starting multiply sel=01 A=9 B=2
[              835000] FSM: WAIT_MULT waiting multiplier done
[              845000] FSM: WAIT_MULT waiting multiplier done
[              855000] FSM: WAIT_MULT waiting multiplier done
[              865000] FSM: WAIT_MULT waiting multiplier done
[              875000] FSM: WAIT_MULT waiting multiplier done
[              885000] FSM: WAIT_MULT waiting multiplier done
[              895000] FSM: WAIT_MULT waiting multiplier done
[              905000] FSM: WAIT_MULT waiting multiplier done
[              915000] FSM: WAIT_MULT waiting multiplier done
[              925000] FSM: WAIT_MULT done, waiting for stability
[              935000] FSM: WAIT_MULT_STABLE updated acc = 18 (prev=0 + result=18)
[              945000] FSM: WRITEBACK writing 18 to C[3]
Testbench: Writing C_mem[3] = 18
[              955000] FSM: NEXT_ELEMENT multiply done
[              965000] FSM: DONE done
Input Matrix A:
[ 7 8 ]
[ 0 9 ]
Input Matrix B:
[ 3 5 ]
[ 4 2 ]
Expected Matrix C (Reference):
[ 53 51 ]
[ 36 18 ]
Actual Matrix C (Accelerator Output):
[ 53 51 ]
[ 36 18 ]

============================================================
Performance Statistics:
============================================================
Cycle Count:         95
MAC executed:          6
MAC skipped:          2
Switch count:          1
============================================================
SUCCESS: All outputs match reference multiplication.
============================================================
testbench.sv:248: $finish called at 975000 (1ps)
[              975000] FSM: DONE done
Done
 
 # Test_bench3 (switching and matrix size 3)
CONSOLE OUTPUT:
[               35000] FSM: IDLE -> DETECT_START
[               45000] Testbench: Setting precision for row 0 to 10 (Multiplier:       DSP)
[               45000] FSM: DETECT_START row 0
[               65000] FSM: DETECT_STREAM reading A[1]
[               75000] FSM: DETECT_STREAM reading A[2]
[               85000] FSM: DETECT_STREAM waiting for detect_done
[              105000] MultiplierSelectorFSM: sparsity=10, precision=10
[              105000] MultiplierSelectorFSM: selected multiplier=00
[              105000] FSM: SELECT requesting multiplier selection sparsity=10 precision=10
[              115000] FSM: SELECT multiplier selected 00
[              115000] MultiplierSelectorFSM: sparsity=10, precision=10
[              115000] MultiplierSelectorFSM: selected multiplier=00
[              125000] FSM: LOAD_AB reading A[0], B[0]
[              135000] FSM: WAIT_DATA waiting for memory data to stabilize
[              145000] FSM: WAIT_OPERANDS latched operands A=7 B=3
[              155000] FSM: CHECK_ZERO A_out=7 B_out=3
[              155000] FSM: CHECK_ZERO starting multiply sel=00 A=7 B=3
[              165000] FSM: WAIT_MULT waiting multiplier done
[              175000] FSM: WAIT_MULT waiting multiplier done
[              185000] FSM: WAIT_MULT done, waiting for stability
[              195000] FSM: WAIT_MULT_STABLE updated acc = 21 (prev=0 + result=21)
[              205000] FSM: LOAD_AB reading A[1], B[3]
[              215000] FSM: WAIT_DATA waiting for memory data to stabilize
[              225000] FSM: WAIT_OPERANDS latched operands A=8 B=4
[              235000] FSM: CHECK_ZERO A_out=8 B_out=4
[              235000] FSM: CHECK_ZERO starting multiply sel=00 A=8 B=4
[              245000] FSM: WAIT_MULT waiting multiplier done
[              255000] FSM: WAIT_MULT waiting multiplier done
[              265000] FSM: WAIT_MULT done, waiting for stability
[              275000] FSM: WAIT_MULT_STABLE updated acc = 53 (prev=21 + result=32)
[              285000] FSM: LOAD_AB reading A[2], B[6]
[              295000] FSM: WAIT_DATA waiting for memory data to stabilize
[              305000] FSM: WAIT_OPERANDS latched operands A=9 B=6
[              315000] FSM: CHECK_ZERO A_out=9 B_out=6
[              315000] FSM: CHECK_ZERO starting multiply sel=00 A=9 B=6
[              325000] FSM: WAIT_MULT waiting multiplier done
[              335000] FSM: WAIT_MULT waiting multiplier done
[              345000] FSM: WAIT_MULT done, waiting for stability
[              355000] FSM: WAIT_MULT_STABLE updated acc = 107 (prev=53 + result=54)
[              365000] FSM: WRITEBACK writing 107 to C[0]
Testbench: Writing C_mem[0] = 107
[              375000] FSM: NEXT_ELEMENT next column 1
[              385000] FSM: LOAD_AB reading A[0], B[1]
[              395000] FSM: WAIT_DATA waiting for memory data to stabilize
[              405000] FSM: WAIT_OPERANDS latched operands A=7 B=5
[              415000] FSM: CHECK_ZERO A_out=7 B_out=5
[              415000] FSM: CHECK_ZERO starting multiply sel=00 A=7 B=5
[              425000] FSM: WAIT_MULT waiting multiplier done
[              435000] FSM: WAIT_MULT waiting multiplier done
[              445000] FSM: WAIT_MULT done, waiting for stability
[              455000] FSM: WAIT_MULT_STABLE updated acc = 35 (prev=0 + result=35)
[              465000] FSM: LOAD_AB reading A[1], B[4]
[              475000] FSM: WAIT_DATA waiting for memory data to stabilize
[              485000] FSM: WAIT_OPERANDS latched operands A=8 B=2
[              495000] FSM: CHECK_ZERO A_out=8 B_out=2
[              495000] FSM: CHECK_ZERO starting multiply sel=00 A=8 B=2
[              505000] FSM: WAIT_MULT waiting multiplier done
[              515000] FSM: WAIT_MULT waiting multiplier done
[              525000] FSM: WAIT_MULT done, waiting for stability
[              535000] FSM: WAIT_MULT_STABLE updated acc = 51 (prev=35 + result=16)
[              545000] FSM: LOAD_AB reading A[2], B[7]
[              555000] FSM: WAIT_DATA waiting for memory data to stabilize
[              565000] FSM: WAIT_OPERANDS latched operands A=9 B=0
[              575000] FSM: CHECK_ZERO A_out=9 B_out=0
[              575000] FSM: CHECK_ZERO skipping MAC
[              585000] FSM: WRITEBACK writing 51 to C[1]
Testbench: Writing C_mem[1] = 51
[              595000] FSM: NEXT_ELEMENT next column 2
[              605000] FSM: LOAD_AB reading A[0], B[2]
[              615000] FSM: WAIT_DATA waiting for memory data to stabilize
[              625000] FSM: WAIT_OPERANDS latched operands A=7 B=1
[              635000] FSM: CHECK_ZERO A_out=7 B_out=1
[              635000] FSM: CHECK_ZERO starting multiply sel=00 A=7 B=1
[              645000] FSM: WAIT_MULT waiting multiplier done
[              655000] FSM: WAIT_MULT waiting multiplier done
[              665000] FSM: WAIT_MULT done, waiting for stability
[              675000] FSM: WAIT_MULT_STABLE updated acc = 7 (prev=0 + result=7)
[              685000] FSM: LOAD_AB reading A[1], B[5]
[              695000] FSM: WAIT_DATA waiting for memory data to stabilize
[              705000] FSM: WAIT_OPERANDS latched operands A=8 B=7
[              715000] FSM: CHECK_ZERO A_out=8 B_out=7
[              715000] FSM: CHECK_ZERO starting multiply sel=00 A=8 B=7
[              725000] FSM: WAIT_MULT waiting multiplier done
[              735000] FSM: WAIT_MULT waiting multiplier done
[              745000] FSM: WAIT_MULT done, waiting for stability
[              755000] FSM: WAIT_MULT_STABLE updated acc = 63 (prev=7 + result=56)
[              765000] FSM: LOAD_AB reading A[2], B[8]
[              775000] FSM: WAIT_DATA waiting for memory data to stabilize
[              785000] FSM: WAIT_OPERANDS latched operands A=9 B=8
[              795000] FSM: CHECK_ZERO A_out=9 B_out=8
[              795000] FSM: CHECK_ZERO starting multiply sel=00 A=9 B=8
[              805000] FSM: WAIT_MULT waiting multiplier done
[              815000] FSM: WAIT_MULT waiting multiplier done
[              825000] FSM: WAIT_MULT done, waiting for stability
[              835000] FSM: WAIT_MULT_STABLE updated acc = 135 (prev=63 + result=72)
[              845000] FSM: WRITEBACK writing 135 to C[2]
Testbench: Writing C_mem[2] = 135
[              855000] FSM: NEXT_ELEMENT next row 1
[              865000] Testbench: Setting precision for row 1 to 01 (Multiplier:     Booth)
[              865000] FSM: DETECT_START row 1
[              885000] FSM: DETECT_STREAM reading A[4]
[              895000] FSM: DETECT_STREAM reading A[5]
[              905000] FSM: DETECT_STREAM waiting for detect_done
[              925000] FSM: SELECT requesting multiplier selection sparsity=01 precision=01
[              935000] FSM: SELECT multiplier switched from 00 to 01
[              935000] FSM: SELECT multiplier selected 01
[              945000] FSM: LOAD_AB reading A[3], B[0]
[              955000] FSM: WAIT_DATA waiting for memory data to stabilize
[              965000] FSM: WAIT_OPERANDS latched operands A=0 B=3
[              975000] FSM: CHECK_ZERO A_out=0 B_out=3
[              975000] FSM: CHECK_ZERO skipping MAC
[              985000] FSM: LOAD_AB reading A[4], B[3]
[              995000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1005000] FSM: WAIT_OPERANDS latched operands A=6 B=4
[             1015000] FSM: CHECK_ZERO A_out=6 B_out=4
[             1015000] FSM: CHECK_ZERO starting multiply sel=01 A=6 B=4
[             1025000] FSM: WAIT_MULT waiting multiplier done
[             1035000] FSM: WAIT_MULT waiting multiplier done
[             1045000] FSM: WAIT_MULT waiting multiplier done
[             1055000] FSM: WAIT_MULT waiting multiplier done
[             1065000] FSM: WAIT_MULT waiting multiplier done
[             1075000] FSM: WAIT_MULT waiting multiplier done
[             1085000] FSM: WAIT_MULT waiting multiplier done
[             1095000] FSM: WAIT_MULT waiting multiplier done
[             1105000] FSM: WAIT_MULT waiting multiplier done
[             1115000] FSM: WAIT_MULT done, waiting for stability
[             1125000] FSM: WAIT_MULT_STABLE updated acc = 24 (prev=0 + result=24)
[             1135000] FSM: LOAD_AB reading A[5], B[6]
[             1145000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1155000] FSM: WAIT_OPERANDS latched operands A=5 B=6
[             1165000] FSM: CHECK_ZERO A_out=5 B_out=6
[             1165000] FSM: CHECK_ZERO starting multiply sel=01 A=5 B=6
[             1175000] FSM: WAIT_MULT waiting multiplier done
[             1185000] FSM: WAIT_MULT waiting multiplier done
[             1195000] FSM: WAIT_MULT waiting multiplier done
[             1205000] FSM: WAIT_MULT waiting multiplier done
[             1215000] FSM: WAIT_MULT waiting multiplier done
[             1225000] FSM: WAIT_MULT waiting multiplier done
[             1235000] FSM: WAIT_MULT waiting multiplier done
[             1245000] FSM: WAIT_MULT waiting multiplier done
[             1255000] FSM: WAIT_MULT waiting multiplier done
[             1265000] FSM: WAIT_MULT done, waiting for stability
[             1275000] FSM: WAIT_MULT_STABLE updated acc = 54 (prev=24 + result=30)
[             1285000] FSM: WRITEBACK writing 54 to C[3]
Testbench: Writing C_mem[3] = 54
[             1295000] FSM: NEXT_ELEMENT next column 1
[             1305000] FSM: LOAD_AB reading A[3], B[1]
[             1315000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1325000] FSM: WAIT_OPERANDS latched operands A=0 B=5
[             1335000] FSM: CHECK_ZERO A_out=0 B_out=5
[             1335000] FSM: CHECK_ZERO skipping MAC
[             1345000] FSM: LOAD_AB reading A[4], B[4]
[             1355000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1365000] FSM: WAIT_OPERANDS latched operands A=6 B=2
[             1375000] FSM: CHECK_ZERO A_out=6 B_out=2
[             1375000] FSM: CHECK_ZERO starting multiply sel=01 A=6 B=2
[             1385000] FSM: WAIT_MULT waiting multiplier done
[             1395000] FSM: WAIT_MULT waiting multiplier done
[             1405000] FSM: WAIT_MULT waiting multiplier done
[             1415000] FSM: WAIT_MULT waiting multiplier done
[             1425000] FSM: WAIT_MULT waiting multiplier done
[             1435000] FSM: WAIT_MULT waiting multiplier done
[             1445000] FSM: WAIT_MULT waiting multiplier done
[             1455000] FSM: WAIT_MULT waiting multiplier done
[             1465000] FSM: WAIT_MULT waiting multiplier done
[             1475000] FSM: WAIT_MULT done, waiting for stability
[             1485000] FSM: WAIT_MULT_STABLE updated acc = 12 (prev=0 + result=12)
[             1495000] FSM: LOAD_AB reading A[5], B[7]
[             1505000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1515000] FSM: WAIT_OPERANDS latched operands A=5 B=0
[             1525000] FSM: CHECK_ZERO A_out=5 B_out=0
[             1525000] FSM: CHECK_ZERO skipping MAC
[             1535000] FSM: WRITEBACK writing 12 to C[4]
Testbench: Writing C_mem[4] = 12
[             1545000] FSM: NEXT_ELEMENT next column 2
[             1555000] FSM: LOAD_AB reading A[3], B[2]
[             1565000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1575000] FSM: WAIT_OPERANDS latched operands A=0 B=1
[             1585000] FSM: CHECK_ZERO A_out=0 B_out=1
[             1585000] FSM: CHECK_ZERO skipping MAC
[             1595000] FSM: LOAD_AB reading A[4], B[5]
[             1605000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1615000] FSM: WAIT_OPERANDS latched operands A=6 B=7
[             1625000] FSM: CHECK_ZERO A_out=6 B_out=7
[             1625000] FSM: CHECK_ZERO starting multiply sel=01 A=6 B=7
[             1635000] FSM: WAIT_MULT waiting multiplier done
[             1645000] FSM: WAIT_MULT waiting multiplier done
[             1655000] FSM: WAIT_MULT waiting multiplier done
[             1665000] FSM: WAIT_MULT waiting multiplier done
[             1675000] FSM: WAIT_MULT waiting multiplier done
[             1685000] FSM: WAIT_MULT waiting multiplier done
[             1695000] FSM: WAIT_MULT waiting multiplier done
[             1705000] FSM: WAIT_MULT waiting multiplier done
[             1715000] FSM: WAIT_MULT waiting multiplier done
[             1725000] FSM: WAIT_MULT done, waiting for stability
[             1735000] FSM: WAIT_MULT_STABLE updated acc = 42 (prev=0 + result=42)
[             1745000] FSM: LOAD_AB reading A[5], B[8]
[             1755000] FSM: WAIT_DATA waiting for memory data to stabilize
[             1765000] FSM: WAIT_OPERANDS latched operands A=5 B=8
[             1775000] FSM: CHECK_ZERO A_out=5 B_out=8
[             1775000] FSM: CHECK_ZERO starting multiply sel=01 A=5 B=8
[             1785000] FSM: WAIT_MULT waiting multiplier done
[             1795000] FSM: WAIT_MULT waiting multiplier done
[             1805000] FSM: WAIT_MULT waiting multiplier done
[             1815000] FSM: WAIT_MULT waiting multiplier done
[             1825000] FSM: WAIT_MULT waiting multiplier done
[             1835000] FSM: WAIT_MULT waiting multiplier done
[             1845000] FSM: WAIT_MULT waiting multiplier done
[             1855000] FSM: WAIT_MULT waiting multiplier done
[             1865000] FSM: WAIT_MULT waiting multiplier done
[             1875000] FSM: WAIT_MULT done, waiting for stability
[             1885000] FSM: WAIT_MULT_STABLE updated acc = 82 (prev=42 + result=40)
[             1895000] FSM: WRITEBACK writing 82 to C[5]
Testbench: Writing C_mem[5] = 82
[             1905000] FSM: NEXT_ELEMENT next row 2
[             1915000] Testbench: Setting precision for row 2 to 10 (Multiplier:       DSP)
[             1915000] FSM: DETECT_START row 2
[             1935000] FSM: DETECT_STREAM reading A[7]
[             1945000] FSM: DETECT_STREAM reading A[8]
[             1955000] FSM: DETECT_STREAM waiting for detect_done
[             1975000] FSM: SELECT requesting multiplier selection sparsity=01 precision=10
[             1985000] MultiplierSelectorFSM: sparsity=01, precision=10
[             1985000] MultiplierSelectorFSM: selected multiplier=00
[             1985000] FSM: SELECT multiplier switched from 01 to 00
[             1985000] FSM: SELECT multiplier selected 00
[             1995000] FSM: LOAD_AB reading A[6], B[0]
[             2005000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2015000] FSM: WAIT_OPERANDS latched operands A=2 B=3
[             2025000] FSM: CHECK_ZERO A_out=2 B_out=3
[             2025000] FSM: CHECK_ZERO starting multiply sel=00 A=2 B=3
[             2035000] FSM: WAIT_MULT waiting multiplier done
[             2045000] FSM: WAIT_MULT waiting multiplier done
[             2055000] FSM: WAIT_MULT done, waiting for stability
[             2065000] FSM: WAIT_MULT_STABLE updated acc = 6 (prev=0 + result=6)
[             2075000] FSM: LOAD_AB reading A[7], B[3]
[             2085000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2095000] FSM: WAIT_OPERANDS latched operands A=0 B=4
[             2105000] FSM: CHECK_ZERO A_out=0 B_out=4
[             2105000] FSM: CHECK_ZERO skipping MAC
[             2115000] FSM: LOAD_AB reading A[8], B[6]
[             2125000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2135000] FSM: WAIT_OPERANDS latched operands A=4 B=6
[             2145000] FSM: CHECK_ZERO A_out=4 B_out=6
[             2145000] FSM: CHECK_ZERO starting multiply sel=00 A=4 B=6
[             2155000] FSM: WAIT_MULT waiting multiplier done
[             2165000] FSM: WAIT_MULT waiting multiplier done
[             2175000] FSM: WAIT_MULT done, waiting for stability
[             2185000] FSM: WAIT_MULT_STABLE updated acc = 30 (prev=6 + result=24)
[             2195000] FSM: WRITEBACK writing 30 to C[6]
Testbench: Writing C_mem[6] = 30
[             2205000] FSM: NEXT_ELEMENT next column 1
[             2215000] FSM: LOAD_AB reading A[6], B[1]
[             2225000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2235000] FSM: WAIT_OPERANDS latched operands A=2 B=5
[             2245000] FSM: CHECK_ZERO A_out=2 B_out=5
[             2245000] FSM: CHECK_ZERO starting multiply sel=00 A=2 B=5
[             2255000] FSM: WAIT_MULT waiting multiplier done
[             2265000] FSM: WAIT_MULT waiting multiplier done
[             2275000] FSM: WAIT_MULT done, waiting for stability
[             2285000] FSM: WAIT_MULT_STABLE updated acc = 10 (prev=0 + result=10)
[             2295000] FSM: LOAD_AB reading A[7], B[4]
[             2305000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2315000] FSM: WAIT_OPERANDS latched operands A=0 B=2
[             2325000] FSM: CHECK_ZERO A_out=0 B_out=2
[             2325000] FSM: CHECK_ZERO skipping MAC
[             2335000] FSM: LOAD_AB reading A[8], B[7]
[             2345000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2355000] FSM: WAIT_OPERANDS latched operands A=4 B=0
[             2365000] FSM: CHECK_ZERO A_out=4 B_out=0
[             2365000] FSM: CHECK_ZERO skipping MAC
[             2375000] FSM: WRITEBACK writing 10 to C[7]
Testbench: Writing C_mem[7] = 10
[             2385000] FSM: NEXT_ELEMENT next column 2
[             2395000] FSM: LOAD_AB reading A[6], B[2]
[             2405000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2415000] FSM: WAIT_OPERANDS latched operands A=2 B=1
[             2425000] FSM: CHECK_ZERO A_out=2 B_out=1
[             2425000] FSM: CHECK_ZERO starting multiply sel=00 A=2 B=1
[             2435000] FSM: WAIT_MULT waiting multiplier done
[             2445000] FSM: WAIT_MULT waiting multiplier done
[             2455000] FSM: WAIT_MULT done, waiting for stability
[             2465000] FSM: WAIT_MULT_STABLE updated acc = 2 (prev=0 + result=2)
[             2475000] FSM: LOAD_AB reading A[7], B[5]
[             2485000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2495000] FSM: WAIT_OPERANDS latched operands A=0 B=7
[             2505000] FSM: CHECK_ZERO A_out=0 B_out=7
[             2505000] FSM: CHECK_ZERO skipping MAC
[             2515000] FSM: LOAD_AB reading A[8], B[8]
[             2525000] FSM: WAIT_DATA waiting for memory data to stabilize
[             2535000] FSM: WAIT_OPERANDS latched operands A=4 B=8
[             2545000] FSM: CHECK_ZERO A_out=4 B_out=8
[             2545000] FSM: CHECK_ZERO starting multiply sel=00 A=4 B=8
[             2555000] FSM: WAIT_MULT waiting multiplier done
[             2565000] FSM: WAIT_MULT waiting multiplier done
[             2575000] FSM: WAIT_MULT done, waiting for stability
[             2585000] FSM: WAIT_MULT_STABLE updated acc = 34 (prev=2 + result=32)
[             2595000] FSM: WRITEBACK writing 34 to C[8]
Testbench: Writing C_mem[8] = 34
[             2605000] FSM: NEXT_ELEMENT multiply done
[             2615000] FSM: DONE done

============================================================
Input Matrix A [3x3]:
============================================================
[   7   8   9 ]
[   0   6   5 ]
[   2   0   4 ]

Input Matrix B [3x3]:
============================================================
[   3   5   1 ]
[   4   2   7 ]
[   6   0   8 ]

Expected Matrix C (Reference) [3x3]:
============================================================
[   107    51   135 ]
[    54    12    82 ]
[    30    10    34 ]

Actual Matrix C (Accelerator Output) [3x3]:
============================================================
[   107    51   135 ]
[    54    12    82 ]
[    30    10    34 ]

============================================================
Performance Statistics:
============================================================
Total Cycle Count:     260
MAC Operations:        18 (Executed)
MAC Operations:        9 (Skipped)
Multiplier Switches:   2
============================================================

Multiplier Configuration per Row:
  Row 0: DSP Multiplier    (precision: 2'b10)
  Row 1: Booth Multiplier  (precision: 2'b01)
  Row 2: DSP Multiplier    (precision: 2'b10)
============================================================

Verification:
============================================================
SUCCESS: All 9 outputs match reference multiplication.
============================================================

testbench.sv:312: $finish called at 2625000 (1ps)
[             2625000] FSM: DONE done
Done
 
 
