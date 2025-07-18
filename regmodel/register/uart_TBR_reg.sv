class uart_TBR_reg extends uvm_reg;
	`uvm_object_utils(uart_TBR_reg);

	uvm_reg_field			 RSVD;
	rand uvm_reg_field TX_DATA;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_TBR_reg");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//------------------------------------
	// Function: build
	//------------------------------------
	virtual function void build();
		RSVD    = uvm_reg_field::type_id::create("RSVD");
		TX_DATA = uvm_reg_field::type_id::create("TX_DATA");

		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access
		RSVD.configure	 (this,24,8,"RO",0,0,1,1,1);
		TX_DATA.configure(this,8 ,0,"WO",1,0,1,1,1);
	endfunction

endclass
