module cache_top #(parameter Size = 8, byte_size = 8, Addr = 37, state_bits = 3, block_size=512, index_bits=7, tag_bits=24, offset_bits=6, num_of_columns=64, num_of_rows=64 )


(
input  wire                        CLK,RST,  //Clock signal
input  wire                       operation ,

input  wire     [byte_size-1 : 0 ]          cache_1_write_data , 
input  wire     [byte_size-1 : 0 ]          cache_2_write_data ,


output  wire   [Size-1 : 0 ]          p1_write_data ,
output  wire   [Size-1 : 0 ]          p2_write_data ,

output wire  [18:0]    read_count_1,
output wire  [18:0]    write_count_1,
output wire  [18:0]    read_hit_cycle_1,
output wire  [18:0]    write_hit_cycle_1,
output wire  [15:0]    num_of_read_hit_1,
output wire  [15:0]    num_of_read_miss_1,
output wire  [15:0]    num_of_write_hit_1,
output wire  [15:0]    num_of_write_miss_1,

output wire  [18:0]    read_count_2,
output wire  [18:0]    write_count_2,
output wire  [18:0]    read_hit_cycle_2,
output wire  [18:0]    write_hit_cycle_2,
output wire  [15:0]    num_of_read_hit_2,
output wire  [15:0]    num_of_read_miss_2,
output wire  [15:0]    num_of_write_hit_2,
output wire  [15:0]    num_of_write_miss_2,
output wire            run_signal,
output wire [num_of_columns*num_of_rows-1:0]         signal_3,
output wire [num_of_columns*num_of_rows-1:0]         signal_4,

output wire                       Matrix_A_Write_done,
output wire                       Matrix_B_Write_done,
output wire                       Matrix_A_read_done,
output wire                       Matrix_B_read_done,
output wire                       Multiplication_done,
output wire      [Size-1:0]         output_data_to_processor_1,
output wire      [Size-1:0]         output_data_to_processor_2
);




//  internal signal of controller
wire                                           stata_snooping_1;
wire                                           W_L1_sig_1;             
wire                                           R_L1_sig_1;            
wire        [Size-1 : 0 ]          req_write_data_bits_1 ;
wire        [block_size-1 : 0 ]         req_read_data_bits_1;
wire        [state_bits-1:0]            next_state_1;
wire        [state_bits-1:0]            next_state_1_snooping;
wire                                           stata_snooping_2;
wire                                           W_L1_sig_2;             
wire                                           R_L1_sig_2;            
wire        [Size-1 : 0 ]         req_write_data_bits_2 ;
wire        [block_size-1 : 0 ]        req_read_data_bits_2;
wire        [state_bits-1:0]           next_state_2;
wire        [state_bits-1:0]            next_state_2_snooping;


wire                       memory_write_1;
wire                       memory_write_2;
wire                       memory_read_1;
wire                       memory_read_2;



wire   [block_size-1 : 0 ]                    l2_req_write_data_bits_1;
wire   [block_size-1 : 0 ]                    l2_req_write_data_bits_2;
wire   [block_size-1 : 0 ]                    l2_req_read_data_bits_1;
wire   [block_size-1 : 0 ]                    l2_req_read_data_bits_2;
wire   [block_size-1 : 0 ]                    l2_cache_out_data_1;
wire   [block_size-1 : 0 ]                    l2_cache_out_data_2;
wire   [block_size-1:0]                       l2_cache_out_data_to_memory_1;
wire   [block_size-1:0]                       l2_cache_out_data_to_memory_2;

wire                      valid_bit_1;
wire                      valid_bit_2;
//  internal signal of cache_1
wire                        Bus_Rd_C_2 ;   
wire                        Flush_1 ;   
wire     [2:0]                      tag_miss_1;
wire                           hit_1;
wire      [1:0]                 LRU_block_1;
wire                        Bus_Upgr_1 ;
wire                        Bus_RdX_1 ;
wire                       write_miss_1;
//wire      [Size-1:0]         output_data_to_processor_1;
wire       [block_size-1:0]        out_cache_data_bits_1;   
wire       [state_bits-1:0]       current_state_1; 
wire       [state_bits-1:0]       current_state_1_snooping;  
wire       [tag_bits-1:0]           tag_1;   
wire       [index_bits-1:0]       index_1;   
wire                                  bus_cache1_read;
wire                                  bus_cache1_write;
  
wire   [1:0]    way_hit_1;
wire       [state_bits-1:0]       z;
wire      [tag_bits-1:0]          y ;  
wire       [byte_size-1:0]        w;

//  internal signal of cache_2
wire                        Bus_Rd_C_1 ;   
wire                        Flush_2 ;   
wire       [1:0]              LRU_block_2;
wire                        Bus_Upgr_2 ;
wire                        Bus_RdX_2 ;
wire                       write_miss_2;

wire       [block_size-1:0]        out_cache_data_bits_2;   
wire       [state_bits-1:0]       current_state_2;
wire       [state_bits-1:0]       current_state_2_snooping;   
wire       [tag_bits-1:0]           tag_2;   
wire       [index_bits-1:0]       index_2;   
wire                                  bus_cache2_read;
wire                                  bus_cache2_write;
//wire      [Size-1:0]         output_data_to_processor_2;
wire     [2:0]                      tag_miss_2;
wire                           hit_2;

wire   [1:0]   way_hit_2;
wire       [state_bits-1:0]       C;

wire       [byte_size-1:0]        D;
wire       [tag_bits-1:0] B  ;

wire      cache_2_invalid;
wire      cache_1_invalid;
//  internal signal of main_memory
wire    [block_size-1:0]     out_memory_data_bits_1;
wire    [block_size-1:0]     out_memory_data_bits_2;
wire                          Bus_Rd_IC_1; 
wire                         Bus_Rd_IC_2; 


// L2 CACHE 

wire        [tag_bits-1:0]                 tag_1_L2  ;
wire        [index_bits-1:0]               index_1_L2  ;
wire        [tag_bits-1:0]                 tag_2_L2 ; 
wire        [index_bits-1:0]               index_2_L2 ;




// lru of L2 Cache

wire        [3:0]   tag_miss_L2_1 ;
wire        [3:0]   tag_miss_L2_2 ;
wire        [2:0]   LRU_block_L2_1 ;
wire        [2:0]   LRU_block_L2_2 ;
wire        [2:0]        hit_way_in_L2_p1 ;
wire        [2:0]        hit_way_in_L2_p2 ;
wire                hit_L2_to_p1 ;
wire                hit_L2_to_p2 ;
wire                               Bus_Rd_IC_L2_1;
wire                               Bus_Rd_IC_L2_2;
//***********************************************
wire            [tag_bits-1:0]        tag_1_to_L2;
wire            [tag_bits-1:0]        tag_2_to_L2;
wire            [index_bits-1:0]     index_1_to_L2;
wire            [index_bits-1:0]     index_2_to_L2;


wire          bus_cache1_to_L2;
wire          bus_cache2_to_L2;


wire           write_signal_1;
wire           write_signal_2;
wire           read_signal_1;
wire           read_signal_2;

wire          read_done_1;
wire          write_done_1;
wire          read_done_2;
wire          write_done_2;

//********

wire                                         Pr_Rd_1; 
wire                                         Pr_Wr_1; 
wire   [Addr-1:0]                    Adderss_1; 
//wire   [Size-1 : 0 ]                 p1_write_data ;
wire                                         Pr_Rd_2; 
wire                                         Pr_Wr_2; 
wire   [Addr-1:0]                    Adderss_2; 
//wire   [Size-1 : 0 ]               p2_write_data ;
wire                                         matrix_store_1;
wire                                         matrix_store_2;









cache_1 U0_Cache_1 (
// input
.CLK( CLK),
.RST(RST),
.Adderss_1(Adderss_1),
.Pr_Rd_1(Pr_Rd_1),
.Pr_Wr_1(Pr_Wr_1),
.req_write_data_bits_1(req_write_data_bits_1),
.req_read_data_bits_1 (req_read_data_bits_1),

.next_state_1(next_state_1),  
.W_L1_sig_1(W_L1_sig_1),             
.R_L1_sig_1(R_L1_sig_1),             
.stata_snooping_1(stata_snooping_1),

.index_2(index_2),             
.tag_2(tag_2),     
.tag_1(tag_1), 
.index_1 (index_1), 
.Bus_Rd_C_1(Bus_Rd_C_1),   
.Bus_Rd_IC_L2_1(Bus_Rd_IC_L2_1),
.tag_1_to_L2(tag_1_to_L2),
.index_1_to_L2(index_1_to_L2),

.matrix_store_1(matrix_store_1),
.cache_1_invalid(cache_1_invalid),
.cache_2_invalid(cache_2_invalid),
.write_signal_1(write_signal_1),
.read_signal_1(read_signal_1),
  
.bus_cache1_to_L2(bus_cache1_to_L2),
.next_state_1_snooping(next_state_1_snooping),
.current_state_1_snooping(current_state_1_snooping),


.Bus_Rd_C_2(Bus_Rd_C_2) ,    
.Flush_1(Flush_1) ,    
.Bus_Upgr_1 (Bus_Upgr_1 ),
.Bus_RdX_1(Bus_RdX_1 ),
.write_miss_1(write_miss_1),
.out_cache_data_bits_1(out_cache_data_bits_1),
.current_state_1 (current_state_1),     
.bus_cache1_read(bus_cache1_read),
.bus_cache1_write(bus_cache1_write),
.bus_cache2_read(bus_cache2_read),
.bus_cache2_write(bus_cache2_write),
.read_done_1(read_done_1),
.tag_miss_1(tag_miss_1),
.hit_1(hit_1),
.LRU_block_1(LRU_block_1),
.way_hit_1(way_hit_1)  ,
.y(y),
.z(z) ,
.w(w),
.valid_bit_1(valid_bit_1),
.l2_req_write_data_bits_1(l2_req_write_data_bits_1),
.read_count_1(read_count_1),
.write_count_1(write_count_1),
.read_hit_cycle_1(read_hit_cycle_1),
.write_hit_cycle_1(write_hit_cycle_1),
.num_of_read_hit_1(num_of_read_hit_1),
.num_of_read_miss_1(num_of_read_miss_1),
.num_of_write_hit_1(num_of_write_hit_1),
.num_of_write_miss_1(num_of_write_miss_1),
.output_data_to_processor_1(output_data_to_processor_1)
);


cache_2 U0_Cache_2 (
// input
.CLK( CLK),
.RST(RST),
.Adderss_2 (Adderss_2),
.Pr_Rd_2(Pr_Rd_2),
.Pr_Wr_2(Pr_Wr_2),
.req_write_data_bits_2(req_write_data_bits_2),
.req_read_data_bits_2 (req_read_data_bits_2),
.read_done_2(read_done_2),
.next_state_2(next_state_2),  
.W_L1_sig_2(W_L1_sig_2),             
.R_L1_sig_2(R_L1_sig_2),             
.stata_snooping_2(stata_snooping_2),
.Bus_Rd_C_2(Bus_Rd_C_2) , 
.index_2(index_2),             
.tag_2(tag_2),     
.tag_1(tag_1), 
.index_1 (index_1), 
.cache_1_invalid(cache_1_invalid),
.cache_2_invalid(cache_2_invalid),
.Bus_Rd_IC_L2_2(Bus_Rd_IC_L2_2),
.write_signal_2(write_signal_2),
.read_signal_2(read_signal_2),
.matrix_store_2(matrix_store_2),
.tag_2_to_L2(tag_2_to_L2),
.index_2_to_L2(index_2_to_L2),
 
.current_state_2_snooping(current_state_2_snooping),
.next_state_2_snooping(next_state_2_snooping), 

.bus_cache2_to_L2(bus_cache2_to_L2),

.Bus_Rd_C_1(Bus_Rd_C_1) ,    
.Flush_2(Flush_2) ,    
.Bus_Upgr_2 (Bus_Upgr_2 ),
.Bus_RdX_2(Bus_RdX_2 ),
.write_miss_2(write_miss_2),
.out_cache_data_bits_2(out_cache_data_bits_2),
.current_state_2 (current_state_2),    
   
.bus_cache1_read(bus_cache1_read),
.bus_cache1_write(bus_cache1_write),
.bus_cache2_read(bus_cache2_read),
.bus_cache2_write(bus_cache2_write),

.tag_miss_2(tag_miss_2),
.hit_2(hit_2),
.LRU_block_2(LRU_block_2),
.way_hit_2(way_hit_2)  ,

.B(B) ,
.C(C) ,
.D(D),
.valid_bit_2(valid_bit_2),
.l2_req_write_data_bits_2(l2_req_write_data_bits_2),
.read_count_2(read_count_2),
.write_count_2(write_count_2),
.read_hit_cycle_2(read_hit_cycle_2),
.write_hit_cycle_2(write_hit_cycle_2),
.num_of_read_hit_2(num_of_read_hit_2),
.num_of_read_miss_2(num_of_read_miss_2),
.num_of_write_hit_2(num_of_write_hit_2),
.num_of_write_miss_2(num_of_write_miss_2),
.output_data_to_processor_2(output_data_to_processor_2)
);




L2_cache U0_L2_cache (
.CLK( CLK),
.RST(RST),   
 
.write_signal_2(write_signal_2),
.read_signal_2(read_signal_2),
.tag_1_to_L2(tag_1_to_L2),
.index_1_to_L2(index_1_to_L2),
.bus_cache1_to_L2(bus_cache1_to_L2),


.tag_2_to_L2(tag_2_to_L2),
.index_2_to_L2(index_2_to_L2),
.bus_cache2_to_L2(bus_cache2_to_L2),

 .Bus_Rd_IC_1(Bus_Rd_IC_1),
 .Bus_Rd_IC_2(Bus_Rd_IC_2),
.write_signal_1(write_signal_1),
.read_signal_1(read_signal_1),
.Bus_Rd_IC_L2_1(Bus_Rd_IC_L2_1),
.Bus_Rd_IC_L2_2(Bus_Rd_IC_L2_2),
.memory_read_1(memory_read_1),
.memory_read_2(memory_read_2),

.memory_write_1(memory_write_1),
.memory_write_2(memory_write_2),

.tag_1_L2(tag_1_L2),
.index_1_L2(index_1_L2),
.tag_2_L2(tag_2_L2),
.index_2_L2(index_2_L2),
.valid_bit_1(valid_bit_1),
.valid_bit_2(valid_bit_2),   
.l2_cache_out_data_1(l2_cache_out_data_1),
.l2_cache_out_data_2(l2_cache_out_data_2),
.l2_cache_out_data_to_memory_1(l2_cache_out_data_to_memory_1),
.l2_cache_out_data_to_memory_2(l2_cache_out_data_to_memory_2),
.tag_miss_L2_1(tag_miss_L2_1),
.hit_L2_to_p1(hit_L2_to_p1),
.LRU_block_L2_1(LRU_block_L2_1),
.hit_way_in_L2_p1(hit_way_in_L2_p1),

.tag_miss_L2_2(tag_miss_L2_2),
.hit_L2_to_p2(hit_L2_to_p2),
.LRU_block_L2_2(LRU_block_L2_2),
.hit_way_in_L2_p2(hit_way_in_L2_p2),

.l2_req_write_data_bits_1(l2_req_write_data_bits_1),
.l2_req_write_data_bits_2(l2_req_write_data_bits_2)

);








main_100 U0_main_100 (
.CLK(CLK),
.RST(RST),
.memory_read_1(memory_read_1),
.memory_read_2(memory_read_2),
.memory_write_1(memory_write_1), 
.memory_write_2(memory_write_2), 

.l2_cache_out_data_to_memory_1(l2_cache_out_data_to_memory_1),
.l2_cache_out_data_to_memory_2(l2_cache_out_data_to_memory_2),
.tag_1_L2(tag_1_L2),
.index_1_L2(index_1_L2),
.tag_2_L2(tag_2_L2), 
.index_2_L2(index_2_L2),   
.out_memory_data_bits_1(out_memory_data_bits_1),
.out_memory_data_bits_2(out_memory_data_bits_2),   
.Bus_Rd_IC_1(Bus_Rd_IC_1),
.Bus_Rd_IC_2(Bus_Rd_IC_2)

);



LRU U0_LRU(
.CLK(CLK),
.RST(RST),
.tag_miss_1(tag_miss_1),
.hit_1(hit_1),
.LRU_block_1(LRU_block_1),
.index_1(index_1),
.way_hit_1(way_hit_1)
);


LRU_2 U0_LRU_2(
.CLK(CLK),
.RST(RST),
.tag_miss_2(tag_miss_2),
.hit_2(hit_2),
.LRU_block_2(LRU_block_2),
.index_2(index_2),
.way_hit_2(way_hit_2)
);



LRU_L2 U0_LRU_L2(
.CLK(CLK),
.RST(RST),
.tag_miss_L2_1(tag_miss_L2_1),
.hit_L2_to_p1(hit_L2_to_p1),
.hit_way_in_L2_p1(hit_way_in_L2_p1),
.index_1_to_L2(index_1_to_L2), 
.LRU_block_L2_1(LRU_block_L2_1),

.tag_miss_L2_2(tag_miss_L2_2),
.hit_L2_to_p2(hit_L2_to_p2),
.hit_way_in_L2_p2(hit_way_in_L2_p2),
.index_2_to_L2(index_2_to_L2), 
.LRU_block_L2_2(LRU_block_L2_2)

);





controller U0_controller(

.CLK( CLK),
.RST(RST),
.Pr_Rd_1(Pr_Rd_1),
.Pr_Rd_2(Pr_Rd_2),
.Pr_Wr_1(Pr_Wr_1),   
.Pr_Wr_2(Pr_Wr_2),               
.current_state_1(current_state_1), 
.current_state_2(current_state_2),       
.Bus_RdX_1(Bus_RdX_1), 
.Bus_RdX_2(Bus_RdX_2),  
.Bus_Upgr_1(Bus_Upgr_1),
.Bus_Upgr_2(Bus_Upgr_2),         
.write_miss_1(write_miss_1),  
.write_miss_2(write_miss_2),           
.Bus_Rd_C_2(Bus_Rd_C_2),
.Bus_Rd_C_1(Bus_Rd_C_1),   
.Bus_Rd_IC_2(Bus_Rd_IC_2),  
.Bus_Rd_IC_1(Bus_Rd_IC_1),
.Flush_1(Flush_1),  
.Flush_2(Flush_2),    
    
.p1_write_data(p1_write_data) ,                
.p2_write_data(p2_write_data) , 

.out_memory_data_bits_1(out_memory_data_bits_1) ,
.out_memory_data_bits_2(out_memory_data_bits_2) ,         
.out_cache_data_bits_1(out_cache_data_bits_1) ,        
 .out_cache_data_bits_2(out_cache_data_bits_2) ,  
 
.stata_snooping_1(stata_snooping_1),
.stata_snooping_2(stata_snooping_2),

.next_state_1_snooping(next_state_1_snooping),
.current_state_1_snooping(current_state_1_snooping),
.current_state_2_snooping(current_state_2_snooping),
.next_state_2_snooping(next_state_2_snooping),

.W_L1_sig_1(W_L1_sig_1), 
.W_L1_sig_2(W_L1_sig_2),             
.R_L1_sig_1(R_L1_sig_1),             
.R_L1_sig_2(R_L1_sig_2), 
.read_done_1(read_done_1),
.write_done_1(write_done_1),  
.read_done_2(read_done_2),
.write_done_2(write_done_2),

.req_write_data_bits_1(req_write_data_bits_1) ,
.req_write_data_bits_2(req_write_data_bits_2) ,

.req_read_data_bits_1(req_read_data_bits_1),
.req_read_data_bits_2(req_read_data_bits_2),

  
.Bus_Rd_IC_L2_1(Bus_Rd_IC_L2_1), 
.Bus_Rd_IC_L2_2(Bus_Rd_IC_L2_2),        
.next_state_1(next_state_1),
.next_state_2(next_state_2),
.l2_cache_out_data_1(l2_cache_out_data_1),
.l2_cache_out_data_2(l2_cache_out_data_2)


);



Mutrix_mult U0_Mutrix_mult(
.CLK( CLK),
.RST(RST),
.write_done_1(write_done_1),
.read_done_1(read_done_1),
.write_done_2(write_done_2),
.read_done_2(read_done_2),
.output_data_to_processor_1(output_data_to_processor_1),
.output_data_to_processor_2(output_data_to_processor_2),
.matrix_store_1(matrix_store_1),
.matrix_store_2(matrix_store_2),
.Pr_Rd_1(Pr_Rd_1),
.Pr_Wr_1(Pr_Wr_1),
.p1_write_data(p1_write_data),

.cache_1_write_data(cache_1_write_data),
.cache_2_write_data(cache_2_write_data),

.Adderss_1(Adderss_1),
.operation(operation),
.Pr_Rd_2(Pr_Rd_2),
.Pr_Wr_2(Pr_Wr_2),
.p2_write_data(p2_write_data),
.Adderss_2(Adderss_2),
.signal_3(signal_3),
.signal_4(signal_4),
.run_signal(run_signal),
.Matrix_A_Write_done(Matrix_A_Write_done),
.Matrix_B_Write_done(Matrix_B_Write_done),
.Matrix_A_read_done(Matrix_A_read_done),
.Matrix_B_read_done(Matrix_B_read_done),
.Multiplication_done(Multiplication_done)

);

endmodule

