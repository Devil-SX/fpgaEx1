MODELSIM_DIR = $(abspath ~/intelFPGA/20.1/modelsim_ase/bin)
SRC_DIR = $(abspath ./rtl/src)
TB_DIR = $(abspath ./rtl/tb)
BUILD_DIR = $(abspath ./build) 
SCRIPT_DIR = $(abspath ./scripts)

COMPLIE = work

SRC_FILES += clk_divider.v uart_tx_op.v
TX_TB_NAME = uart_tx_op_tb
RX_TB_NAME = 
PACKAGE_TB_NAME = 

SRC_PATH = $(addprefix "$(SRC_DIR)/", $(SRC_FILES))
TB_PATH = $(addsuffix .v, \
					$(addprefix "$(TB_DIR)/",\
					$(TX_TB_NAME) $(RX_TB_NAME) $(PACKAGE_TB_NAME)))

.defalut: $(COMPLIE) 

tx_run: $(COMPLIE)
	cd $(BUILD_DIR)
	vsim $(TX_TB_NAME)
	add wave $(TX_TB_NAME)/ *
	run -all


$(COMPLIE):
	mkdir $(BUILD_DIR) -p
	cd $(BUILD_DIR)
	vlib $@
	vlog $(TB_PATH) $(SRC_PATH) 
	cd ..

clean:
	rm -rf $(BUILD_DIR)

.PHONY: tx_run
