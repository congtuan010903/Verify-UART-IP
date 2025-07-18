class sample_13x_9600_test extends uart_base_test;
	`uvm_component_utils(sample_13x_9600_test)
	
	uvm_status_e       status;
	uart_configuration new_config;
	vip_tx_sequence    seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "sample_13x_9600_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0]  transmit_data;
		bit[31:0] rdata;
		phase.raise_objection(this);
	
		wait(ahb_vif.HRESETn === 1);

		// config VIP
		new_config             = uart_configuration::type_id::create("new_config");
		new_config.baud_rate   = 9600;
		new_config.data_width  = 8;
		new_config.parity_mode = uart_configuration::PARITY_NONE;
		new_config.stop_bits   = 2;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(new_config);
		// config DUT
		regmodel.MDR.write(status,32'h01); #50ns;
		regmodel.DLL.write(status,32'h21); #50ns;
		regmodel.DLH.write(status,32'h03); #50ns;
		regmodel.LCR.write(status,32'h37); #50ns;
	
		// Write 5 data to DUT transmit 5 frame
		repeat(5) begin
			transmit_data = $urandom();
			regmodel.TBR.write(status,transmit_data);
		end
		
		// start sequence to VIP send data
		repeat(5) begin
			seq = vip_tx_sequence::type_id::create("seq");
			seq.start(env.uart_agt.uart_seqcer);
		end

		// check data receive
		repeat(5) begin
			regmodel.RBR.read(status,rdata);
			env.uart_sb.update_rbr_data(rdata);
		end

		phase.drop_objection(this);
	endtask

endclass
