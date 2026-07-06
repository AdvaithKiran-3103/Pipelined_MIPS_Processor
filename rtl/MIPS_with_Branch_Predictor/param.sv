`ifndef PARAM
`define PARAM

`define WIDTH            16       // datawidth
`define ADDRWIDTH        16       // address width of the Instruction & Data Memory
`define NUM_OF_REGISTERS  8
`define RF_INDEX_WIDTH   ($clog2(`NUM_OF_REGISTERS))  


// Branch_Predictor_sizing specifications
`define BP_INDEX_WIDTH  5
`define BP_TAG_WIDTH   (`ADDRWIDTH - `BP_INDEX_WIDTH)
`endif