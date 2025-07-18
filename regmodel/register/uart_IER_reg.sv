class uart_IER_reg extends uvm_reg;
	`uvm_object_utils(uart_IER_reg);

	uvm_reg_field			 RSVD;
	rand uvm_reg_field EN_PARITY_ERROR;
	rand uvm_reg_field EN_RX_FIFO_EMPTY;
	rand uvm_reg_field EN_RX_FIFO_FULL;
	rand uvm_reg_field EN_TX_FIFO_EMPTY;
	rand uvm_reg_field EN_TX_FIFO_FULL;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_IER_reg");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//------------------------------------
	// Function: build
	//------------------------------------
	virtual function void build();
		RSVD             = uvm_reg_field::type_id::create("RSVD");
		EN_PARITY_ERROR  = uvm_reg_field::type_id::create("EN_PARITY_ERROR");
		EN_RX_FIFO_EMPTY = uvm_reg_field::type_id::create("EN_RX_FIFO_EMPTY");
		EN_RX_FIFO_FULL  = uvm_reg_field::type_id::create("EN_RX_FIFO_FULL");
		EN_TX_FIFO_EMPTY = uvm_reg_field::type_id::create("EN_TX_FIFO_EMPTY");
		EN_TX_FIFO_FULL  = uvm_reg_field::type_id::create("EN_TX_FIFO_FULL");

		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access
		RSVD.configure						(this,27,5,"RO",0,0,1,1,1);
		EN_PARITY_ERROR.configure (this,1 ,4,"RW",0,0,1,1,1);
		EN_RX_FIFO_EMPTY.configure(this,1 ,3,"RW",0,0,1,1,1);
		EN_RX_FIFO_FULL.configure (this,1 ,2,"RW",0,0,1,1,1);
		EN_TX_FIFO_EMPTY.configure(this,1 ,1,"RW",0,0,1,1,1);
		EN_TX_FIFO_FULL.configure (this,1 ,0,"RW",0,0,1,1,1);
	endfunction

endclass
