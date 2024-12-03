// Level 1  Cache proccessor 1 (p1)

module cache_2 #(parameter Size = 8,parameter byte_size = 8,parameter state_bits = 3,parameter Addr = 37 , parameter data_bits=512,parameter index_bits=7,parameter tag_bits=24,parameter no_of_sets=128,parameter block_size=512,parameter offset_bits=6,parameter no_of_ways=4)


(
input  wire                                CLK,RST,

// ** signals from processor 2  
input  wire   [Addr-1:0]             Adderss_2,                                               // Adderss  from processor
input  wire                                Pr_Rd_2,Pr_Wr_2,                                    //enable signals from processor 
input  wire    [Size-1:0]     req_write_data_bits_2,                             //Data that  processor 2 want to write in cache

 // **   controller signal to change state of cache line
input  wire   [state_bits-1:0]     next_state_2,                                            //after the controller change the state of the block according to the operation it will send the new state to the cache to updata the state of the block  
input  wire   [state_bits-1:0]     next_state_2_snooping,                              //after the controller change the state of the block according to the operation it will send the new state to the cache to updata the state of the block  in case of snooping
input  wire                               W_L1_sig_2,                                              //input from controller,if =1 modify the state in the cache line , in case of write 
input  wire                               R_L1_sig_2,                                               //input from controller,if =1 modify the state  in the cache line , in case of write 
input  wire                               stata_snooping_2,                                      //input from controller,if =1 modify the state in the cache line ,  in case of anther cache reads my data 
input  wire    [block_size-1:0]     req_read_data_bits_2,                             //if pr1 want to read and the block was invalid ( this data come from other cache  to written in this cache )
input  wire                               read_done_2,
input  wire                         Bus_Rd_IC_L2_2,
input  wire                         Bus_Rd_C_2,
// ** signals from cache 1 that cache 1 want data 
input wire    [tag_bits-1:0]         tag_1,                                                  //input tag of cache 1 to cache 2 to in case of the data in the selected block of cache 1 is invalid so it send the tag to cache 2 to search on data 
input wire    [index_bits-1:0]      index_1,
input wire                        bus_cache1_read,                                           // bus read request from cache 1
input wire                        bus_cache1_write,                                          // bus write request from cache 1 
input wire                       cache_1_invalid,
// ** signal from LRU module
input wire        [1:0]             LRU_block_2,                                           // signal coming from LRU module contain the least recently used  way  
 // ** out signlas to  controller to determined our cache line state
 output  reg    [state_bits-1:0]     current_state_2,                              //cache_2 will send the current state of the selected block to the controller
 output  reg    [state_bits-1:0]     current_state_2_snooping,                              //cache_1 will send the current state of the selected block to the controller in case of snooping 
output  reg                                 Bus_Rd_C_1 ,                                      // signal to controller to send data to another Cache 1 
output  reg                                 Flush_2 ,                                             
output  reg                                 Bus_Upgr_2 ,                                    
output  reg                                 Bus_RdX_2 ,
output  reg                                 write_miss_2,                                   // tag miss in cache 
output  reg    [block_size-1:0]      out_cache_data_bits_2,                    //in case of hit, cache_2 will send the data_bits to the controller

 // ** out  signlas to  L2_CACHE  to get some data                    
output  reg    [block_size-1:0]     l2_req_write_data_bits_2,                 // flushing the data to level 2 cache in case of write miss 
output  reg                                  valid_bit_2,                               // change state of block in L2 to be valid 
output  reg                                  write_signal_2 ,
output  reg                                  read_signal_2,

//** in case of cache 1 want data from cache 2 and cache 2 was invalid so send tag & index to L2 to get data 
                 
output  reg                                  bus_cache2_to_L2 ,                   // to open L2 cache to search about the data
output  reg    		                    cache_2_invalid,
//** in case of tag miss send tag & index to L2 cache to store the evected data 
output  reg [tag_bits-1:0]             tag_2_to_L2,                                  
output  reg [index_bits-1:0]           index_2_to_L2,

//** output signlas to cache 1 to get some data 
output  reg    [tag_bits-1:0]        tag_2,                                            //output tag of cache 2 to cache1 to in case of the data in the selected block of cache 2 is invalid so it send the tag to cache 1 to search on data
output  reg                                 bus_cache2_read,                            // bus read request from cache 2 
output  reg                                 bus_cache2_write,                           // bus write request from cache 2  
output  reg     [index_bits-1:0]       index_2,                                       

//** out signal to LRU module to change ways priorities
output  reg      [2:0]                      tag_miss_2,                                   // to LRU module 
output  reg                                    hit_2 ,                                           // to LRU module 
output  reg      [1:0]                       way_hit_2 ,                                  // to LRU module 

//** test signal 
output    reg [tag_bits-1:0]          B ,                                                  // for test only
output    reg [state_bits-1:0]        C ,                                                 // for test only 
output    reg    [byte_size-1:0]     D,                                                 // for test only

// output data to processor 
output   reg                  matrix_store_2 ,
output   reg  [18:0]    read_count_2,
output   reg  [18:0]    write_count_2,
output   reg  [18:0]    read_hit_cycle_2,
output   reg  [18:0]    write_hit_cycle_2,
output   reg  [15:0] num_of_read_hit_2,
output   reg  [15:0] num_of_read_miss_2,
output   reg  [15:0] num_of_write_hit_2,
output   reg  [15:0] num_of_write_miss_2,
output   reg  [Size-1:0] output_data_to_processor_2               // output data to processor in case of read
 	 
);


// internal signals
reg [tag_bits-1:0]      tag;
reg [index_bits-1:0]  index;
reg [offset_bits-1:0]   offset;
reg [state_bits-1:0]    state; 
reg                    snooping_hit ;
reg     [1:0]      snooping_way_hit_1;
reg  [2:0] signal  ;
reg [2:0] delay ;
reg L2_signal ;
//implementation of cache arrays
reg [block_size*no_of_ways-1:0] cache_2 [0:no_of_sets-1];
reg [ tag_bits*no_of_ways-1:0]   tag_array_2 [0:no_of_sets-1];
reg [ state_bits*no_of_ways-1:0]   state_array_2 [0:no_of_sets-1];

reg [7:0] i;
reg [7:0] j;
reg [7:0] k;
//integer i,k,j;
//initial 
//begin: initialization
 //   for  (i=0;i<no_of_sets;i=i+1)  
 //   begin
//	  k=3*i;
//	  for  (j=0;j<no_of_ways;j=j+1)
//	  begin
//	  state_array_2[i][((state_bits*(j+1))-1)-:state_bits]=0;	  
 //     tag_array_2[i][((tag_bits*(j+1))-1)-:tag_bits]=0;	  
 //     end	  
//end
//end




always@(posedge CLK )
  
begin
 if (!RST)
begin
  signal = 0 ;
  delay= 0;
  L2_signal =0;
 // initialization o/p signals 
    for  (i=0;i<no_of_sets;i=i+1)  
    begin
	  k=3*i;
	  for  (j=0;j<no_of_ways;j=j+1)
	  begin
	  state_array_2[i][((state_bits*(j+1))-1)-:state_bits]=0;	  
      tag_array_2[i][((tag_bits*(j+1))-1)-:tag_bits]=i+j+k;	  
      end	  
end	  		 
end

else
begin

 // initialization o/p signals 
		 bus_cache2_read=0;
         bus_cache2_write=0;
		 bus_cache2_to_L2='bx;
	     tag_miss_2=0 ;	
         hit_2=0;
		 cache_2_invalid='bx;
		 state='bx;
		 snooping_hit=0;
		 tag_2='bx ;
		 read_signal_2='bx;
		 write_signal_2='bx;
         output_data_to_processor_2='bx;
	      current_state_2= 'bx ;	
		 Bus_Rd_C_1 = 'b0 ; 
		 Flush_2 = 'bx ; 
		 Bus_Upgr_2   = 'bx ; 
		 Bus_RdX_2  = 'bx ; 
		 write_miss_2  = 'bx ; 
		 current_state_2_snooping='bx;
		 out_cache_data_bits_2 = 'bx ;
         B='bx ;
         way_hit_2='bx;	 
        l2_req_write_data_bits_2	='bx;	
		 valid_bit_2=0;
         B=tag_array_2['b1111111][((tag_bits*(1+1))-1)-:tag_bits] ;
		 D='bx;
		 C='bx	;
         index_2='bx;		 


 //separate tag,index,offset from the coming address from processor		//**************************************************
	     tag=Adderss_2[Addr-1:offset_bits+index_bits];                                 //   (13:36)      24 
         index=Adderss_2[offset_bits+index_bits-1:offset_bits];                      //    (6:12)       7
		 offset =Adderss_2[offset_bits-1:0];		                                             //     (0:5)        6
		 
if(Pr_Rd_2==1 || Pr_Wr_2 ==1)
begin
// number of clock cycles taken 
if(Pr_Rd_2)
read_count_2=read_count_2+1;
else if (Pr_Wr_2)
write_count_2=write_count_2+1;
else
begin
read_count_2=0;
write_count_2=0;
end
// search about required data in my cache 
for  (i=0;i<no_of_ways;i=i+1)
begin 
if(tag_array_2[index][((tag_bits*(i+1))-1)-:tag_bits]==tag)
   begin
	hit_2 = 1 ;
	way_hit_2 = i ;
	end
else
tag_miss_2=tag_miss_2+1'b1;	
end
// if tag is founded in my cache 
 if(hit_2)
  begin
     state=state_array_2[index][((state_bits*(way_hit_2+1))-1)-:state_bits];
	  C=state;
      if (R_L1_sig_2)                                                         // write signal from proccessor to write data_bits 
            begin
            cache_2[index][(data_bits*(way_hit_2+1)-1)-:data_bits] =req_read_data_bits_2 ; 	 
			state_array_2 [index][((state_bits*(way_hit_2+1))-1)-:state_bits]= next_state_2 ;		
			output_data_to_processor_2= cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*way_hit_2)-:Size] ;
			read_hit_cycle_2=read_count_2;
			num_of_read_hit_2=num_of_read_hit_2+1;
			matrix_store_2=1;
		    signal=0;
		    D =cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*way_hit_2)-:byte_size] ;			
            C=state_array_2 [index][((state_bits*(way_hit_2+1))-1)-:state_bits];
           end
  else if (W_L1_sig_2==1)                                                         // write signal from proccessor to write data_bits 
        begin
   		  cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*way_hit_2)-:Size] =req_write_data_bits_2 ;            
          state_array_2 [index][((state_bits*(way_hit_2+1))-1)-:state_bits]= next_state_2 ;	
		  signal=0;	
		  write_hit_cycle_2=write_count_2;
		  num_of_write_hit_2=num_of_write_hit_2+1;
          C=state_array_2 [index][((state_bits*(way_hit_2+1))-1)-:state_bits];
		  D =cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*way_hit_2)-:byte_size] ; 		  
        end	
    else if (cache_1_invalid==1&&Bus_Rd_IC_L2_2!=1)
            begin 
	          bus_cache2_to_L2=1;
	          tag_2_to_L2=tag;
              index_2_to_L2= index ;
			  read_signal_2 =1;	
			  bus_cache2_read=0;	
	          bus_cache2_write=0;
            end	
	else if(read_done_2==1) 
	     begin
          state_array_2 [index][((state_bits*(way_hit_2+1))-1)-:state_bits]= next_state_2 ;
		  read_hit_cycle_2=read_count_2;
		  num_of_read_hit_2=num_of_read_hit_2+1;
		  signal=0;	
         end			
	else  if (Pr_Rd_2&&signal==0)                                                                // in case of  read
	     begin      
			signal=signal+1; 		 
           if(state==3'b0 && Bus_Rd_C_2 !=1)                                                           // invalid
	          begin
                current_state_2 = state;
    	   	    tag_2 = tag ;  
  	            index_2=index;				
			    bus_cache2_read=1;
			
		  end		 
       else  if( state!=3'b0 )                                                             // shared , modified , Exclusive , Owned   
	        begin
             current_state_2 = state;         
		     output_data_to_processor_2 = cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*way_hit_2)-:Size]  ; 
			 matrix_store_2=1;
			 end 	 			
	   end
	   
  else  if (Pr_Wr_2&&signal==0)                                                       //  in case of write 
	    begin
    	 tag_2 = tag ;
  	     index_2=index;		 
         bus_cache2_write=1;
	     signal=signal+1; 		 
          if(state==0)                                                       // invalid
            begin
		      current_state_2 = state;
              Bus_RdX_2= 1 ; 
           end		  
	      else if(state=='b010)                                                  // shared  
             begin	   
               current_state_2 = state; 
               Bus_Upgr_2=1 ;		  			  
		end	
		 else                                                             // modified , Exclusive 
		    current_state_2 = state;					
	 end
end



// if tag miss

if (tag_miss_2 == 'b100 )
  begin
    if (R_L1_sig_2)                                                         
      begin
		if(state_array_2[index][((state_bits*(LRU_block_2+1))-1)-:state_bits] !=0)
		  begin
              l2_req_write_data_bits_2 =cache_2 [index][ (data_bits*(LRU_block_2+1)-1) -: data_bits] ;
		      tag_2_to_L2 = tag_array_2[index][((tag_bits*(LRU_block_2+1))-1)-:tag_bits] ;
		      index_2_to_L2 = index ;
              bus_cache2_to_L2 =1 ;				  
              valid_bit_2=1;
			  bus_cache2_read=0;	
	          bus_cache2_write=0;
            end	
        else	
              bus_cache2_to_L2=0;		
              cache_2 [index][ (data_bits*(LRU_block_2+1)-1) -: data_bits] =req_read_data_bits_2 ;
		      tag_array_2[index][((tag_bits*(LRU_block_2+1))-1)-:tag_bits]=tag ;		  
              state_array_2 [index][((state_bits*(LRU_block_2+1))-1)-:state_bits]= next_state_2 ;			 
		     output_data_to_processor_2= cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*LRU_block_2)-:Size] ;
			 matrix_store_2=1;
			 L2_signal=0;
			 read_hit_cycle_2=read_count_2;
			num_of_read_miss_2=num_of_read_miss_2+1;
     end
 else if (W_L1_sig_2)                                                         
    begin	
		if(state_array_2[index][((state_bits*(LRU_block_2+1))-1)-:state_bits] !=0)
		   begin
		       l2_req_write_data_bits_2 =cache_2 [index][ (data_bits*(LRU_block_2+1)-1) -: data_bits] ;
	           tag_2_to_L2= tag_array_2[index][((tag_bits*(LRU_block_2+1))-1)-:tag_bits] ;
		       index_2_to_L2 = index ;
                bus_cache2_to_L2 =1 ;				   
                valid_bit_2=1;
				bus_cache2_read=0;	
	           bus_cache2_write=0;
            end
       else
             bus_cache2_to_L2=0;	   	  
                cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*LRU_block_2)-:Size] =req_write_data_bits_2 ;            
                state_array_2 [index][((state_bits*(LRU_block_2+1))-1)-:state_bits]= next_state_2 ;
	  	        tag_array_2[index][((tag_bits*(LRU_block_2+1))-1)-:tag_bits]=tag ;
		        D=cache_2 [index][((offset*byte_size)+(byte_size-1)+data_bits*LRU_block_2)-:byte_size] ;
				signal=0;
				L2_signal=0;
				write_hit_cycle_2=write_count_2;
		        num_of_write_miss_2=num_of_write_miss_2+1;	
	  	        end	
       else if (cache_2_invalid==1||L2_signal==1)
            begin 
	          bus_cache2_to_L2=1;
	          tag_2_to_L2=tag;
              index_2_to_L2= index ;
			  L2_signal=1;
			  bus_cache2_read=0;	
	           bus_cache2_write=0;			  
            end				
        if (Pr_Rd_2&&  Bus_Rd_C_2 !=1)   		
	        begin
              current_state_2 = 0;
		      tag_2 = tag ;
			  index_2=index;
			  bus_cache2_read=1;
			  read_signal_2=1;
			end
      if (Pr_Wr_2&&signal==0)                                                     	
	    begin
		  signal = signal +1 ;
		  tag_2 = tag ;
	      index_2=index;		  
		  bus_cache2_write=1;
          current_state_2 = 0;
		  write_miss_2 = 1 ;
		  write_signal_2=1;
		end
	end
end
	

// Cache 2 snoop in cache 1
	
if(bus_cache1_read || bus_cache1_write)
begin

for  (i=0;i<no_of_ways;i=i+1)
begin 
if(tag_array_2[index_1][((tag_bits*(i+1))-1)-:tag_bits]==tag_1)  
   begin
	snooping_hit = 1 ;
	snooping_way_hit_1 = i ;
	end
end

if (snooping_hit )
begin
state=state_array_2 [index_1][((state_bits*(snooping_way_hit_1+1))-1)-:state_bits];	
if (stata_snooping_2)                                                         
   begin
    state_array_2 [index_1][((state_bits*(snooping_way_hit_1+1))-1)-:state_bits]= next_state_2_snooping ;
    C=state_array_2 [index_1][((state_bits*(snooping_way_hit_1+1))-1)-:state_bits];
    end	
else if(bus_cache1_read )
	 begin
        if(state==0)                                                           
	       begin
		     cache_2_invalid=1;
           end		 
       else                                                           
	      begin
		  if(delay==1)
		   begin
            current_state_2_snooping = state;         
		    out_cache_data_bits_2 = cache_2 [index_1][(data_bits*(snooping_way_hit_1+1)-1)-:data_bits]   ;			
	        Flush_2=1 ;
			Bus_Rd_C_1=1 ;
			delay=delay+1 ;
			end
			else if(delay==0)
			delay=delay+1 ;
			else
			delay=0;
		   end						
      end			   
  else if(bus_cache1_write)
      begin    
        state_array_2 [index_1][((state_bits*(snooping_way_hit_1+1))-1)-:state_bits]= 0 ;   
       end		
 end
 else 
      begin
	  	cache_2_invalid=1; 
	  end
	end

end
	
end
endmodule 