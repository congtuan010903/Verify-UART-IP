class uart_reserved_reg extends uvm_reg;
	`uvm_object_utils(uart_reserved_reg)

	uvm_reg_field RSVD;
	
	//-------------------------------------
	// Constructor
	//-------------------------------------
	function new(string name = "uart_reserved_reg");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//-----------------------------------
	// Function: build
	//-----------------------------------
	virtual function void build();
		RSVD = uvm_reg_field::type_id::create("RSVD");
		RSVD.configure(this,32,0,"RO",0,32'hFFFFFFFF,1,1,1);
	endfunction

endclass
