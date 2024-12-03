// LRU OF LEVEL_2 CAHCE
module LRU_L2 # (parameter no_of_ways=8,
              parameter index_bits=7,
			  parameter no_of_l2_ways_bits=3,
			  parameter no_of_sets=128
			   
			  )



(
input    wire                    CLK,
input    wire                    RST,

input    wire                                         hit_L2_to_p1,
input    wire    [2:0]                             hit_way_in_L2_p1,
input    wire    [index_bits-1:0]             index_1_to_L2,
input    wire    [3:0]                             tag_miss_L2_1,

input    wire                                          hit_L2_to_p2,
input    wire    [2:0]                              hit_way_in_L2_p2,
input    wire    [index_bits-1:0]              index_2_to_L2,
input    wire    [3:0]                              tag_miss_L2_2,

output    reg    [2:0]       LRU_block_L2_1,
output    reg    [2:0]       LRU_block_L2_2


);


reg [no_of_l2_ways_bits-1:0]lru_value1;
reg [no_of_l2_ways_bits-1:0]lru_value_dummy1;

reg [ no_of_l2_ways_bits*no_of_ways-1:0]   lru_array [0:no_of_sets-1];

reg [index_bits-1:0]  index_1_updated ;
reg [index_bits-1:0]  index_2_updated ;

integer i,j,l2_iterator,l2_mm_iterator;
//initial 
//begin: initialization0
//    for  (i=0;i<no_of_sets;i=i+1)  
//    begin
//	  for  (j=0;j<no_of_ways;j=j+1)	
//      lru_array [i] [((no_of_l2_ways_bits*(j+1))-1)-:no_of_l2_ways_bits]=j;	  
//    end
//end

always@(posedge CLK or negedge RST)
begin
if (!RST)
begin
   for  (i=0;i<no_of_sets;i=i+1)  
    begin
	  for  (j=0;j<no_of_ways;j=j+1)	
      lru_array [i] [((no_of_l2_ways_bits*(j+1))-1)-:no_of_l2_ways_bits]=j;	  
    end
end
end

always@(*)
begin
	 index_1_updated = index_1_to_L2>>1 ;
	 index_2_updated = index_2_to_L2>>1 ;

if (hit_L2_to_p1)
    begin 
             lru_value1=lru_array[index_1_updated][((hit_way_in_L2_p1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
             for (l2_iterator=0;l2_iterator<no_of_ways;l2_iterator=l2_iterator+1)
              begin
             lru_value_dummy1=lru_array[index_1_updated][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
             if (lru_value_dummy1>lru_value1)
             begin
             lru_array[index_1_updated][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy1-1;
             end
             end
             lru_array[index_1_updated][((hit_way_in_L2_p1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=no_of_ways-1;
	end

else if (tag_miss_L2_1 == 'b1000)
begin
             for (i=0;i<no_of_ways;i=i+1)
                begin
                 if (lru_array[index_1_updated][((no_of_l2_ways_bits*(i+1))-1)-:no_of_l2_ways_bits]==0)
                 begin
                   LRU_block_L2_1=i;
                  end
                 end
                 lru_value1=lru_array[index_1_updated][((LRU_block_L2_1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                 for (l2_mm_iterator=0;l2_mm_iterator<no_of_ways;l2_mm_iterator=l2_mm_iterator+1)
                begin
                 lru_value_dummy1=lru_array[index_1_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                 if ((lru_array[index_1_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits])>lru_value1)
                  begin
                  lru_array[index_1_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy1-1;
                  lru_value_dummy1=lru_array[index_1_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                     end
                 end
                 lru_array[index_1_updated][((LRU_block_L2_1+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=(no_of_ways-1);
				 
end


if (hit_L2_to_p2)
    begin 
             lru_value1=lru_array[index_2_updated][((hit_way_in_L2_p2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
             for (l2_iterator=0;l2_iterator<no_of_ways;l2_iterator=l2_iterator+1)
              begin
             lru_value_dummy1=lru_array[index_2_updated][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
             if (lru_value_dummy1>lru_value1)
             begin
             lru_array[index_2_updated][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy1-1;
             end
             end
             lru_array[index_2_updated][((hit_way_in_L2_p2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=no_of_ways-1;
	end

else if (tag_miss_L2_2 == 'b1000)
begin
             for (i=0;i<no_of_ways;i=i+1)
                begin
                 if (lru_array[index_2_updated][((i+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]==0)
                 begin
                   LRU_block_L2_2=i;
                  end
                 end
                 lru_value1=lru_array[index_2_updated][((LRU_block_L2_2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                 for (l2_mm_iterator=0;l2_mm_iterator<no_of_ways;l2_mm_iterator=l2_mm_iterator+1)
                begin
                 lru_value_dummy1=lru_array[index_2_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                 if ((lru_array[index_2_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits])>lru_value1)
                  begin
                  lru_array[index_2_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy1-1;
                  lru_value_dummy1=lru_array[index_2_updated][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                     end
                 end
                 lru_array[index_2_updated][((LRU_block_L2_2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=(no_of_ways-1);
				 
end

end
endmodule