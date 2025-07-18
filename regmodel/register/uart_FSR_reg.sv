class uart_FSR_reg extends uvm_reg;
	`uvm_object_utils(uart_FSR_reg);

	uvm_reg_field      RSVD;
	rand uvm_reg_field PARITY_ERROR_STATUS;
	rand uvm_reg_field RX_EMPTY_STATUS;
	rand uvm_reg_field RX_FULL_STATUS;
	rand uvm_reg_field TX_EMPTY_STATUS;
	rand uvm_reg_field TX_FULL_STATUS;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_FSR_reg");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//------------------------------------
	// Function: build
	//------------------------------------
	virtual function void build();
		RSVD                 = uvm_reg_field::type_id::create("RSVD");
		PARITY_ERROR_STATUS  = uvm_reg_field::type_id::create("PARITY_ERROR_STATUS");
		RX_EMPTY_STATUS      = uvm_reg_field::type_id::create("RX_EMPTY_STATUS");
		RX_FULL_STATUS       = uvm_reg_field::type_id::create("RX_FULL_STATUS");
		TX_EMPTY_STATUS      = uvm_reg_field::type_id::create("TX_EMPTY_STATUS");
		TX_FULL_STATUS       = uvm_reg_field::type_id::create("TX_FULL_STATUS");

		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access
		RSVD.configure						   (this,27,5,"RO"  ,1,0   ,1,1,1);
		PARITY_ERROR_STATUS.configure(this,1 ,4,"W1C" ,1,0   ,1,1,1);
		RX_EMPTY_STATUS.configure    (this,1 ,3,"RO"  ,1,1'b1,1,1,1);
		RX_FULL_STATUS.configure     (this,1 ,2,"RO"  ,1,0   ,1,1,1);
		TX_EMPTY_STATUS.configure    (this,1 ,1,"RO"  ,1,1'b1,1,1,1);
		TX_FULL_STATUS.configure     (this,1 ,0,"RO"  ,1,0   ,1,1,1);
	endfunction

endclass
