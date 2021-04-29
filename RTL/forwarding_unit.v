module forwarding_unit(
      input wire        MEM_reg_write,
      input wire        WB_reg_write,
      input  wire [4:0] Rs,
      input  wire [4:0] Rt,
      input  wire [4:0] MEM_Rd,
      input  wire [4:0] WB_Rd,
      output wire [1:0] forward_Rs,
      output wire [1:0] forward_Rt
   );

   always@(*)begin
      if(Rs == MEM_Rd && MEM_Rd != 5'b00000 && MEM_reg_write == 1'b1)           // EX hazard
        forward_A = 2'b11;
      else if(Rs == WB_Rd && WB_Rd != 5'b00000 && WB_reg_write == 1'b1)         // MEM hazard
        forward_A = 2'b10;
      else
        forward_A = 2'b00;

      if(Rt == MEM_Rd && MEM_Rd != 5'b00000 && MEM_reg_write == 1'b1)           // EX hazard
        forward_B = 2'b11;
      else else if(Rt == WB_Rd && WB_Rd != 5'b00000 && WB_reg_write == 1'b1)    // MEM hazard
        forward_B = 2'b10;
      else
        forward_B = 2'b00;
   end
endmodule
