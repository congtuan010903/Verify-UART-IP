class uart_agent extends uvm_agent;
	
	`uvm_component_utils(uart_agent)

	virtual uart_if 		uart_vif;
	uart_driver					uart_drv;
	uart_monitor				uart_mon;
	uart_sequencer			uart_seqcer;
	uart_configuration	uart_config;

	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "uart_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	//-----------------------------------
	// Function: build_phase
	//-----------------------------------
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// get virtual interface
		if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif",uart_vif))
			`uvm_fatal(get_type_name(),$sformatf("Failed to get interface from uvm_config_db. Please check!"))
		// get uart_configuration
		if(!uvm_config_db #(uart_configuration)::get(this,"","uart_config",uart_config))
			`uvm_fatal(get_type_name(),$sformatf("Failed to get configuration from uvm_config_db. Please check!"))

		if(uart_config.active) begin
			`uvm_info(get_type_name(),$sformatf("ACTIVED AGENT"), UVM_LOW)
			
			uart_drv 		= uart_driver::type_id::create("uart_drv",this);
			uart_mon		= uart_monitor::type_id::create("uart_mon",this);
			uart_seqcer = uart_sequencer::type_id::create("uart_seqcer",this);

			uvm_config_db#(virtual uart_if)::set(this,"uart_drv","uart_vif",uart_vif);
			uvm_config_db#(virtual uart_if)::set(this,"uart_mon","uart_vif",uart_vif);
			uvm_config_db#(uart_configuration)::set(this,"uart_drv","uart_config",uart_config);
			uvm_config_db#(uart_configuration)::set(this,"uart_mon","uart_config",uart_config);
		end
		else begin
			`uvm_info(get_type_name(),$sformatf("PASSIVED AGENT"), UVM_LOW)
			
			uart_mon = uart_monitor::type_id::create("uart_mon",this);
			
			uvm_config_db#(virtual uart_if)::set(this,"uart_mon","uart_vif",uart_vif);
			uvm_config_db#(uart_configuration)::set(this,"uart_mon","uart_config",uart_config);
		end
	endfunction: build_phase

	//----------------------------------------
	// Function: connect_phase
	//----------------------------------------
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(uart_config.active) begin
			uart_drv.seq_item_port.connect(uart_seqcer.seq_item_export);
		end
	endfunction: connect_phase

	//--------------------------------------
	// Function: update config
	//--------------------------------------
	function void update_config(uart_configuration new_config);
		uart_config = new_config;
		if(uart_drv) uart_drv.update_config(new_config);
		if(uart_mon) uart_mon.update_config(new_config);
		`uvm_info(get_type_name(),$sformatf("UART agent config update successfully \n %s",new_config.sprint()),UVM_LOW)
	endfunction

endclass: uart_agent
