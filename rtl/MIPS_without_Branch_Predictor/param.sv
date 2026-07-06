`ifndef PARAM
`define PARAM

`define WIDTH            16       // datawidth
`define ADDRWIDTH        16       // address width of the Instruction & Data Memory
`define NUM_OF_REGISTERS  8
`define RF_INDEX_WIDTH   ($clog2(`NUM_OF_REGISTERS))

`endif