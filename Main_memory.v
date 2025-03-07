module main_100 #(parameter index_bits=7,parameter tag_bits=24,parameter no_of_sets=1950,parameter block_size=512,parameter no_of_L2_ways=8)


(

input  wire                        CLK,RST,
input  wire                        memory_read_1,             // read request from cache 1 
input  wire                        memory_write_1,                // write request from cache 1 

input  wire                        memory_read_2,            // read request from cache 2 
input  wire                        memory_write_2,              // write request from cache 2


input  wire    [block_size-1:0]         l2_cache_out_data_to_memory_1,
input  wire    [block_size-1:0]         l2_cache_out_data_to_memory_2,

input  wire    [index_bits-1:0]         index_1_L2, 
input  wire    [tag_bits-1:0]            tag_1_L2,    
input  wire    [index_bits-1:0]         index_2_L2,
input wire     [tag_bits-1:0]            tag_2_L2,  

output  reg    [block_size-1:0]     out_memory_data_bits_1,
output  reg    [block_size-1:0]     out_memory_data_bits_2,  
output  reg                                invalid_Address_1, 
output  reg                                invalid_Address_2,           
output reg    Bus_Rd_IC_1 ,                                               // signal to controller to send data to cache 1                                        
output reg    Bus_Rd_IC_2                                               // signal to controller to send data to cache 2 
);




reg   hit_1 ;
reg   hit_2 ;

reg  [2:0] x ;
reg  [2:0]  y ; 
//implementation of cache arrays
reg [block_size-1:0] main_memory [0:no_of_sets-1];
reg [ tag_bits-1:0]   tag_array       [0:no_of_sets-1];

reg   [30:0]  address_1  ;
reg   [30:0]  address_2  ;

integer i,k,j;
//initial 
//begin: initialization
 //   for  (i=0;i<no_of_sets;i=i+1)  
 //   begin
 //     tag_array[i]=0 ;

//     end	 	  
//end


//assign address_1 = {tag_1_L2 ,index_1_L2 } ;
//assign address_2 = {tag_2_L2 ,index_2_L2 } ;

//separate tag,index,offset from the coming address from processor

always@(posedge CLK )
 begin
 if (!RST)
begin
    for  (i=0;i<no_of_sets;i=i+1)  
    begin
      tag_array[i]=i ;
   end
end	  		 
else
begin
	Bus_Rd_IC_1= 'bx;
	Bus_Rd_IC_2= 'bx;	
	out_memory_data_bits_1='bx;
	out_memory_data_bits_2='bx;
	x='bx;

	
address_1 = {tag_1_L2 ,index_1_L2 } ;	
address_2 = {tag_2_L2 ,index_2_L2 } ;	
	
if(memory_read_1||memory_write_1)
begin
for (i=0;i<(no_of_sets-1); i=i+1)
begin	
if(main_memory[i]==address_1)
   begin
     hit_1=1;
   end
 end
 
if( hit_1 ) 
   begin 
     if (memory_read_1)                                                                // in case of  read
	    begin
             Bus_Rd_IC_1=1 ;		
		     out_memory_data_bits_1 = main_memory [address_1]  ;			 
			 end

       else if (memory_write_1)                                                       //  in case of write 
	      begin
           main_memory [address_1][block_size-1:0] =l2_cache_out_data_to_memory_1 ;            //  write data coming form processor (write)		
	      end		  
	end
else            
invalid_Address_1=1  ;			 
end


if(memory_read_2||memory_write_2)
begin
for (i=0;i<(no_of_sets-1); i=i+1)
begin	
if(main_memory[i]==address_2)
   begin
     hit_2=1;
   end
 end
 
if( hit_2 ) 
begin 
     if (memory_read_2)                                                                // in case of  read
	    begin
             Bus_Rd_IC_2=1 ;			 
		     out_memory_data_bits_2 = main_memory [address_2]  ; 	
			 end

       else if (memory_write_2)                                                       //  in case of write 
	      begin
           main_memory [address_2][block_size-1:0] =l2_cache_out_data_to_memory_2 ;            //  write data coming form processor (write)		
	      end		  
	end
else
invalid_Address_2=1  ;			 
	end
	end
end
endmodule
