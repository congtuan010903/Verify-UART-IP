class uart_DLH_reg extends uvm_reg;
	`uvm_object_utils(uart_DLH_reg);

	uvm_reg_field			 RSVD;
	rand uvm_reg_field DLH;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_DLH_reg");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//------------------------------------
	// Function: build
	//------------------------------------
	virtual function void build();
		RSVD = uvm_reg_field::type_id::create("RSVD");
		DLH	 = uvm_reg_field::type_id::create("DLH");

		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access	
		RSVD.configure(this,24,8,"RO",0,0,1,1,1);
		DLH.configure	(this,8	,0,"RW",0,0,1,1,1);
	endfunction

endclass
