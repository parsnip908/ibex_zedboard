module FP_Class(
	input	logic [15:0] Num,
	output ibex_pkg::Classif_e Classif
);

import ibex_pkg::*;

always_comb begin
	casez (Num)
		16'b 0111_1111_1???_????: Classif = (Num[6:0] == 0) ? Inf : NaN;
		16'b 1111_1111_1000_0000: Classif = Neg_Inf;
		16'b ?000_0000_????_????: Classif = Sub_Norm;
		default: Classif = Normal;
	endcase
end
	
endmodule
