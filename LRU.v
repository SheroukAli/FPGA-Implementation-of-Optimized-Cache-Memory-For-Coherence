module LRU # (parameter no_of_ways=4,
              parameter index_bits=7,
			  parameter no_of_l2_ways_bits=2,
			  parameter no_of_sets=128
			   
			  )



(
input    wire                    CLK,
input    wire                    RST,
input    wire[index_bits-1:0]     index_1,
input    wire                     hit_1,
input    wire   [1:0]         way_hit_1,
input    wire    [2:0]          tag_miss_1,
output    reg    [1:0]       LRU_block_1


);

reg [no_of_l2_ways_bits-1:0]lru_value1;
reg [no_of_l2_ways_bits-1:0]lru_value_dummy1;

reg [no_of_l2_ways_bits-1:0]lru_value2;
reg [no_of_l2_ways_bits-1:0]lru_value_dummy2 ;

	
reg [ no_of_l2_ways_bits*no_of_ways-1:0]   lru_array_1 [0:no_of_sets-1];

	
//reg [no_of_l2_ways*no_of_l2_ways_bits-1:0]lru[0:no_of_l2_blocks-1];

reg [7:0] i;
reg [7:0] j;

reg [7:0] l2_iterator;
reg [7:0] l2_mm_iterator;
//integer i,j,l2_iterator,l2_mm_iterator;
//initial 
//begin: initialization
//    for  (i=0;i<no_of_sets;i=i+1)  
//    begin
//	  for  (j=0;j<no_of_ways;j=j+1)	
//      lru_array_1 [i] [((no_of_l2_ways_bits*(j+1))-1)-:no_of_l2_ways_bits]=j;	  
//    end
//end

always@(*)
begin
if (!RST)
begin
    for  (i=0;i<no_of_sets;i=i+1)  
    begin
	  for  (j=0;j<no_of_ways;j=j+1)	
      lru_array_1 [i] [((no_of_l2_ways_bits*(j+1))-1)-:no_of_l2_ways_bits]=j;	  
    end
end
else 
   begin 
   //LRU of L1|_cache of p1
 if (hit_1==1)
             begin
             lru_value1=lru_array_1[index_1][((way_hit_1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
             for (l2_iterator=0;l2_iterator<no_of_ways;l2_iterator=l2_iterator+1)
              begin
             lru_value_dummy1=lru_array_1[index_1][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
             if (lru_value_dummy1>lru_value1)
             begin
             lru_array_1[index_1][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy1-1;
             end
             end
             lru_array_1[index_1][((way_hit_1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=no_of_ways-1;
  
     end	
	 
 else if (tag_miss_1 == 'b100 )
 begin 
 
                          for (i=0;i<no_of_ways;i=i+1)
                        begin
                            if (lru_array_1[index_1][((i+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]==0)
                            begin
                                LRU_block_1=i;
                            end
                        end
                        lru_value1=lru_array_1[index_1][((LRU_block_1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                        for (l2_mm_iterator=0;l2_mm_iterator<no_of_ways;l2_mm_iterator=l2_mm_iterator+1)
                        begin
                            lru_value_dummy1=lru_array_1[index_1][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                           if ((lru_array_1[index_1][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits])>lru_value1)
                           begin
                               lru_array_1[index_1][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy1-1;
                               lru_value_dummy1=lru_array_1[index_1][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                           end
                        end
                        lru_array_1[index_1][((LRU_block_1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=(no_of_ways-1); 	
		 
   end
 
   
   
   end
end


endmodule 			 
