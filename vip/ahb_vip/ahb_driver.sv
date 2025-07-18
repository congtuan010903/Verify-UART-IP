class ahb_driver extends uvm_driver #(ahb_transaction);
  `uvm_component_utils(ahb_driver)

  virtual ahb_if ahb_vif;

  function new(string name="ahb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    /** Applying the virtual interface received through the config db - learn detail in next session*/
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get from uvm_config_db. Please check!"))
  endfunction: build_phase

  /** User can use ahb_vif to control real interface like systemverilog part*/
  virtual task run_phase(uvm_phase phase);
		forever begin
			rsp = ahb_transaction::type_id::create("rsp");
		
		  seq_item_port.get(req);
			$cast(rsp, req.clone());
			rsp.set_id_info(req);
			wait(ahb_vif.HRESETn == 1); 

			case(req.xact_type)
				ahb_transaction::WRITE: // write
				begin
				  // Address phase
					@(posedge ahb_vif.HCLK)
					ahb_vif.HADDR 		= req.addr;
					ahb_vif.HBURST		= req.burst_type;
					ahb_vif.HPROT 		= req.prot;
					ahb_vif.HSIZE 		= req.xfer_size;
					ahb_vif.HTRANS 		= 2'h2;
					ahb_vif.HWRITE 		= 1'b1;
					ahb_vif.HREADYOUT = 1'b1;
					ahb_vif.HRESP 		= 1'b0;
					// Data phase
					@(posedge ahb_vif.HCLK)
					ahb_vif.HADDR 		= 10'h000;
					ahb_vif.HBURST		= 3'h0;
					ahb_vif.HPROT 		= 4'h0;
					ahb_vif.HSIZE 		= 3'h0;
					ahb_vif.HTRANS 		= 2'h0;
					ahb_vif.HWDATA		= req.data;
					ahb_vif.HWRITE 		= 1'b0;
					ahb_vif.HREADYOUT = 1'b0;
					ahb_vif.HRESP 		= 1'b0;
					repeat(2) @(posedge ahb_vif.HCLK)
					ahb_vif.HREADYOUT = 1'b1;	
				end

			  ahb_transaction::READ: // read
				begin
				  // Address phase
					@(posedge ahb_vif.HCLK)
					ahb_vif.HADDR 		= req.addr;
					ahb_vif.HBURST		= req.burst_type;
					ahb_vif.HPROT 		= req.prot;
					ahb_vif.HSIZE 		= req.xfer_size;
					ahb_vif.HTRANS 		= 2'h2;
					ahb_vif.HWRITE 		= 1'b0;
					ahb_vif.HREADYOUT = 1'b1;
					ahb_vif.HRESP 		= 1'b0;
					// Data phase
					@(posedge ahb_vif.HCLK)
					ahb_vif.HADDR 		= 10'h000;
					ahb_vif.HBURST		= 3'h0;
					ahb_vif.HPROT 		= 4'h0;
					ahb_vif.HSIZE 		= 3'h0;
					ahb_vif.HTRANS 		= 2'h0;
					ahb_vif.HWRITE 		= 1'b0;
					ahb_vif.HREADYOUT = 1'b0;
					ahb_vif.HRESP 		= 1'b0;
					repeat(2) @(posedge ahb_vif.HCLK)
					#1;
					ahb_vif.HREADYOUT = 1'b1;
					@(posedge ahb_vif.HCLK);
					rsp.data 					= ahb_vif.HRDATA;
				end

			endcase
			
			seq_item_port.put(rsp);
		end
  endtask: run_phase

endclass: ahb_driver

