module L2_cache #(parameter no_of_l2_ways_bits= 3,parameter byte_size = 8,parameter state_bits = 1,parameter Addr = 37 , parameter data_bits=512,parameter index_bits=7,parameter tag_bits=24,parameter no_of_sets=128,parameter block_size=512,parameter offset_bits=6,parameter no_of_ways=8)


(
input  wire                                CLK,RST,
input  wire                                valid_bit_1,
input  wire                                valid_bit_2,
input  wire    [block_size-1:0]     l2_req_write_data_bits_1,
input  wire    [block_size-1:0]     l2_req_write_data_bits_2,
        
//***************************************************************

input wire    [tag_bits-1:0]          tag_1_to_L2, 
input wire    [index_bits-1:0]       index_1_to_L2,

input wire    [tag_bits-1:0]         tag_2_to_L2,
input wire    [index_bits-1:0]      index_2_to_L2, 

input wire                               Bus_Rd_IC_1,
input wire                               Bus_Rd_IC_2,
input wire                                 bus_cache1_to_L2,
input wire                                 bus_cache2_to_L2,

input wire                                 read_signal_1,
input wire                                  read_signal_2,
input wire                                  write_signal_1,
input wire                                  write_signal_2,
output  reg    [block_size-1:0]      l2_cache_out_data_1,   //in case of hit, L2cache will send the data to the controller
output  reg    [block_size-1:0]      l2_cache_out_data_2,
output  reg    [block_size-1:0]      l2_cache_out_data_to_memory_1,
output  reg    [block_size-1:0]      l2_cache_out_data_to_memory_2,

output  reg          memory_read_1,
output  reg          memory_read_2,
// SIGNAL TO LRU
input     wire        [2:0]     LRU_block_L2_1,
input     wire        [2:0]     LRU_block_L2_2,
output    reg         [3:0]     tag_miss_L2_1,
output    reg         [3:0]     tag_miss_L2_2,

output    reg         [2:0]        hit_way_in_L2_p1 ,                           // which way 
output    reg         [2:0]        hit_way_in_L2_p2 ,                           // which way       

output    reg                    hit_L2_to_p1 ,               // to LRU module
output    reg                    hit_L2_to_p2 ,              // to LRU module
//**
output    reg                   Bus_Rd_IC_L2_1 ,             // to controller that L2 cache wase invalid or not 
output    reg                   Bus_Rd_IC_L2_2 ,             

output    reg     [tag_bits-1:0]         tag_1_L2,    // to main memry in case of L2 cache was invalid
output    reg     [index_bits-1:0]      index_1_L2, 
output    reg     [tag_bits-1:0]         tag_2_L2,    // to main memry in case of L2 cache was invalid
output    reg     [index_bits-1:0]      index_2_L2,
 
output  reg               memory_write_1,                // flush the data from L2 cache to main memory 
output  reg               memory_write_2
	 
);



 

reg [state_bits-1:0]    state; 
reg [3:0] delay ;
//implementation of cache arrays
reg [block_size*no_of_ways-1:0] L2cache [0:no_of_sets-1];
reg [ tag_bits*no_of_ways-1:0]   tag_array_L2 [0:no_of_sets-1];
reg [ state_bits*no_of_ways-1:0]   state_array_L2 [0:no_of_sets-1];

reg [index_bits-1:0]  index_1_updated ;
reg [index_bits-1:0]  index_2_updated ;

reg  [byte_size-1:0]  mmm;




reg [7:0] i;
reg [7:0] j;
reg [7:0] k;
reg [7:0] l2_iterator;
reg [7:0] l2_mm_iterator;


//integer i,k,j ,l2_iterator,l2_mm_iterator;
//initial 
//begin: initialization
//    for  (i=0;i<no_of_sets;i=i+1)  
//    begin
//	  k=7*i;
//	  for  (j=0;j<no_of_ways;j=j+1)
//	  begin
//	  state_array_L2[i][((state_bits*(j+1))-1)-:state_bits]=0;	  
//      tag_array_L2[i][((tag_bits*(j+1))-1)-:tag_bits]=0;	  	  
 //     end	  
//end

//end




always@(posedge CLK  or negedge RST )
begin

 if (!RST)
begin
delay =0;
    for  (i=0;i<no_of_sets;i=i+1)  
    begin
	  k=7*i;
	  for  (j=0;j<no_of_ways;j=j+1)
	  begin
	  state_array_L2[i][((state_bits*(j+1))-1)-:state_bits]=0;	  
      tag_array_L2[i][((tag_bits*(j+1))-1)-:tag_bits]=0;	  	  
      end	  
end
end

else
begin
         Bus_Rd_IC_L2_1 = 0 ;
         Bus_Rd_IC_L2_2 = 0 ;		 
		 memory_read_1=0;
		 memory_read_2=0;		 
	     tag_miss_L2_1=0 ;
         tag_miss_L2_2=0;		 
         hit_L2_to_p1=0;
		 hit_L2_to_p2=0;	 
		 tag_1_L2='bx ;
		 tag_2_L2='bx ;
         index_1_L2='bx;
         index_2_L2='bx;		 	  
		 l2_cache_out_data_1 = 'bx ;
		 l2_cache_out_data_to_memory_1='bx;
		 l2_cache_out_data_to_memory_2='bx;
         hit_way_in_L2_p1='bx;
         hit_way_in_L2_p2='bx;		 
		 memory_write_1='bx;
		 memory_write_2='bx;


//compare the tag from processor with tags in selected set



	 index_1_updated = index_1_to_L2>>1 ;
	 index_2_updated = index_2_to_L2>>1 ;
	 
if(bus_cache1_to_L2)     // request from cache_1
begin
for  (i=0;i<no_of_ways;i=i+1)
begin 
if(tag_array_L2[index_1_updated][((tag_bits*(i+1))-1)-:tag_bits]==tag_1_to_L2)
   begin
	hit_L2_to_p1 = 1 ;
	hit_way_in_L2_p1 = i ;
	end
else
tag_miss_L2_1=tag_miss_L2_1+1'b1;	
end

if(hit_L2_to_p1)
 begin	
 if (valid_bit_1==1)      //write case                                            
  begin
   L2cache[index_1_updated][(data_bits*(hit_way_in_L2_p1+1)-1)-:data_bits]  =l2_req_write_data_bits_1 ;                  
   state_array_L2 [index_1_updated][((state_bits*(hit_way_in_L2_p1+1))-1)-:state_bits]= valid_bit_1 ;	
  end
   else  if (read_signal_1)                                                                // in case of  read
                begin	
                 state=state_array_L2[index_1_updated][((state_bits*(hit_way_in_L2_p1+1))-1)-:state_bits];		   
                     if(state=='b0 &&Bus_Rd_IC_1!=1)                                                           // invalid
             	       begin
                 	   	tag_1_L2 = tag_1_to_L2; 
                 	   	index_1_L2 = index_1_updated ;
                        memory_read_1 = 1; 						                  				
             		    end		 
                     else  
             	        begin
						  if(delay==4)
		                   begin
             		       l2_cache_out_data_1 = L2cache [index_1_updated][(data_bits*(hit_way_in_L2_p1+1)-1)-:data_bits]   ;
             			   Bus_Rd_IC_L2_1=1;
			               delay=delay+1 ;
			               end
			              else if(delay<4)
			               delay=delay+1 ;
			              else if (delay==5)
			               delay=delay+1;
                           else
                            delay=0;						   
                           end				
             	end 	
        else if (write_signal_1)                                                          
               begin                  
        		  state_array_L2 [index_1_updated][((state_bits*(hit_way_in_L2_p1+1))-1)-:state_bits]= 0;	
               end		
        end         

// tage miss
else
 begin 
    if (read_signal_1 &&Bus_Rd_IC_1!=1 )
       begin 
           	 tag_1_L2 = tag_1_to_L2 ; 
           	 index_1_L2 = index_1_updated ;
             memory_read_1 = 1; 						
	  end	  
  else
        begin   
          	if ( state_array_L2[index_1_updated][((state_bits*(LRU_block_L2_1+1))-1)-:state_bits] == 1 )
              begin
          	 tag_1_L2 =tag_array_L2[index_1_updated][((tag_bits*(LRU_block_L2_1+1))-1)-:tag_bits] ;
           	 index_1_L2 = index_1_updated ; 			
              l2_cache_out_data_to_memory_1 = L2cache [index_1_updated][(data_bits*(LRU_block_L2_1+1)-1)-:data_bits];
              memory_write_1 =1;
              end
             else	
              memory_write_1 =0;         	
              L2cache [index_1_updated][(data_bits*(LRU_block_L2_1+1)-1)-:data_bits] =l2_req_write_data_bits_1 ;         
              state_array_L2[index_1_updated][((state_bits*(LRU_block_L2_1+1))-1)-:state_bits]=valid_bit_1 ;
              tag_array_L2[index_1_updated][((tag_bits*(LRU_block_L2_1+1))-1)-:tag_bits]=tag_1_to_L2 ;			
      end                                                        
 
end

end



if(bus_cache2_to_L2)
 begin
	
for  (i=0;i<no_of_ways;i=i+1)
begin 
if(tag_array_L2[index_2_updated][((tag_bits*(i+1))-1)-:tag_bits]==tag_2_to_L2 )
   begin
	hit_L2_to_p2 = 1 ;
	hit_way_in_L2_p2 = i ;
	end
else
tag_miss_L2_2=tag_miss_L2_2+1'b1;	
end

if(hit_L2_to_p2)
 begin
        if (valid_bit_2==1)                                                  
           begin
            L2cache[index_2_updated][(data_bits*(hit_way_in_L2_p2+1)-1)-:data_bits]  =l2_req_write_data_bits_2 ;                  
            state_array_L2 [index_2_updated][((state_bits*(hit_way_in_L2_p2+1))-1)-:state_bits]= valid_bit_2 ;	
           end  
         
        else if (read_signal_2)                                                              
       	     begin		
               state=state_array_L2[index_2_updated][((state_bits*(hit_way_in_L2_p2+1))-1)-:state_bits];		 
              if(state=='b0&&Bus_Rd_IC_2!=1)                                                          
       	          begin
           	   	    tag_2_L2 = tag_2_to_L2; 
                 	index_2_L2 = index_2_updated ;			
                    memory_read_2 = 1;                   //******************************************************************************************************************************				
       		     end		 
                else 
                    begin
		              if(delay==4)
		                begin					  
       		            l2_cache_out_data_2 = L2cache[index_2_updated] [(data_bits*(hit_way_in_L2_p2+1)-1)-:data_bits]  ;
       			        Bus_Rd_IC_L2_2=1;	
			            delay=delay+1 ;
			            end
			           else if(delay<4)
			            delay=delay+1 ;
			           else if (delay==5)
			            delay=delay+1;
                        else
                         delay=0;					   
       			 end 
                 end			 
        else if (write_signal_2)                                                       
               begin
                 state_array_L2 [index_2_updated][((state_bits*(hit_way_in_L2_p2+1))-1)-:state_bits]= 0 ;  
               end		
 end

// tage miss
else
 begin 
    if (read_signal_2==1&&Bus_Rd_IC_2!=1 )
       begin 
           	 tag_2_L2 = tag_2_to_L2 ; 
           	 index_2_L2 = index_2_updated ;
             memory_read_2 = 1; 						 
	  end	  
  else
        begin   
          	if ( state_array_L2[index_2_updated][((state_bits*(LRU_block_L2_2+1))-1)-:state_bits] == 1 )
              begin
          	 tag_2_L2 =tag_array_L2[index_2_updated][((tag_bits*(LRU_block_L2_2+1))-1)-:tag_bits] ;
           	 index_2_L2 = index_2_updated ; 			
              l2_cache_out_data_to_memory_2 = L2cache [index_2_updated][(data_bits*(LRU_block_L2_2+1)-1)-:data_bits];
              memory_write_2 =1;
              end
             else	
              memory_write_2 =0;         	
              L2cache [index_2_updated][(data_bits*(LRU_block_L2_2+1)-1)-:data_bits] =l2_req_write_data_bits_2 ;         
              state_array_L2[index_2_updated][((state_bits*(LRU_block_L2_2+1))-1)-:state_bits]=valid_bit_2 ;
              tag_array_L2[index_2_updated][((tag_bits*(LRU_block_L2_2+1))-1)-:tag_bits]=tag_2_to_L2;			
      end                                                        
 
end

end
end
end

endmodule 

