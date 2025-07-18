class read_w1c_test extends uart_base_test;
	`uvm_component_utils(read_w1c_test)
	
	uvm_status_e                 status;
	uart_configuration           uart_config2;
	vip_tx_parity_error_sequence seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "read_w1c_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0] rdata;
		phase.raise_objection(this);

		wait(ahb_vif.HRESETn === 1);

		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 9600;
		uart_config2.data_width  = 8;
		uart_config2.parity_mode = uart_configuration::PARITY_EVEN;
		uart_config2.stop_bits   = 2;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.MDR.write(status,32'h01); #50ns;
		regmodel.DLL.write(status,32'h21); #50ns;
		regmodel.DLH.write(status,32'h03); #50ns;
		regmodel.IER.write(status,32'h10); #50ns;
		regmodel.LCR.write(status,32'h1F); #50ns;
		regmodel.LCR.write(status,32'h3F); #50ns;

		// write read test
		regmodel.FSR.write(status,8'hFF);
		regmodel.FSR.read(status,rdata);
		if(rdata != 'hA)
			`uvm_error(get_type_name(),"Default value of FSR incorrect");
	
		// start sequence to VIP send data
		seq = vip_tx_parity_error_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);

		// check parity error interrupt
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"Parity error, interrupt trigger",UVM_LOW)
		else
			`uvm_error(get_type_name(),"Parity error, Interrupt must be trigger")

		// check parity error status
		regmodel.FSR.read(status,rdata);
		if(rdata[4] === 1) begin
			regmodel.FSR.write(status,8'h10); // write 1 to clear
			regmodel.FSR.read(status,rdata);
			if(rdata[4] === 0)
				`uvm_info(get_type_name(),"Write 1 to clear parity error status successfully",UVM_LOW)
			else
				`uvm_error(get_type_name(),"Write 1 to clear parity error status unsuccessfully")
		end
		else
			`uvm_error(get_type_name(),"Parity error, parity error status must trigger")

		// check data
		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);

		phase.drop_objection(this);
	endtask

endclass
