class uart_RBR_reg extends uvm_reg;
	`uvm_object_utils(uart_RBR_reg);

	uvm_reg_field			 RSVD;
	rand uvm_reg_field RX_DATA;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_RBR_reg");
		super.new(name,32,UVM_NO_COVERAGE);
	endfunction

	//------------------------------------
	// Function: build
	//------------------------------------
	virtual function void build();
		RSVD    = uvm_reg_field::type_id::create("RSVD");
		RX_DATA = uvm_reg_field::type_id::create("RX_DATA");

		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access
		RSVD.configure	 (this,24,8,"RO",0,0    ,1,1,1);
		RX_DATA.configure(this,8 ,0,"RO",1,8'hxx,1,1,1);
	endfunction

endclass
