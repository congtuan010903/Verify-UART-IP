class uart_MDR_reg extends uvm_reg;	
	`uvm_object_utils(uart_MDR_reg)

	uvm_reg_field 		 RSVD;
	rand uvm_reg_field OSM_SEL;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "uart_MDR_reg");
		 super.new(name,32,UVM_NO_COVERAGE);
	endfunction
	
	//---------------------------------------
	// Function: build
	//--------------------------------------
	virtual function void build();
		RSVD		= uvm_reg_field::type_id::create("RSVD");
		OSM_SEL = uvm_reg_field::type_id::create("OSM_SEL");
	
		//parent,size,pos,access,volatile,reset,has_reset,is_rand,indiv_access
		RSVD.configure	 (this,31,1,"RO",0,0,1,1,1);
		OSM_SEL.configure(this,1 ,0,"RW",0,0,1,1,1);
	endfunction

endclass
		
