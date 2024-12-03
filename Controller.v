module controller  #(parameter Size = 8,parameter byte_size = 8,parameter state_bits = 3,parameter Addr = 37 ,parameter index_bits=9,parameter tag_bits=22,parameter block_size=512,parameter offset_bits=6)

(
input  wire                        CLK,RST,  //Clock signal

//Control Signals
input  wire                                          Pr_Rd_1,     //When processor wants to read data
input  wire                                          Bus_Rd_C_1,  //When one Cache wants to read data from another cache
input  wire                                          Bus_Rd_IC_1,  //When processor reads a data that is exclusive to itself--- "E" state

input  wire            [state_bits-1:0]       current_state_1,    //cache1 will send the current state of the selected block to the protocol
input  wire            [state_bits-1:0]       current_state_1_snooping,


input  wire                                         Pr_Wr_1,    //processor wants to write something onto its' Cache
input  wire                                         Bus_RdX_1,  //When there's a write miss and processor has to fetch the cache address first before writing onto it
input  wire                                         Bus_Upgr_1,  //used to make the other Caches containing the same address "Invalid" while data is being written down by one processor onto its Cache
input  wire            [state_bits-1:0]    current_state_2,    //cache1 will send the current state of the selected block to the protocol
input  wire            [state_bits-1:0]       current_state_2_snooping,



input  wire                                          Flush_2,     //I believe Flush and Flush_Opt are the same

input  wire                                          write_miss_1,          // miss tag in cache 1 
input  wire                                           write_miss_2,         // miss tag in cache 2

input  wire                                           Pr_Rd_2,    //When processor wants to read data
input  wire                                           Bus_Rd_C_2,  //When one Cache wants to read data from aother cache
input  wire                                           Bus_Rd_IC_2,  //When processor reads a data that is exclusive to itself--- "E" state

input  wire                                           Pr_Wr_2,    //processor wants to write something onto its' Cache
input  wire                                           Bus_RdX_2,  //When there's a write miss and processor has to fetch the cache address first before writing onto it
input  wire                                           Bus_Upgr_2,  //used to make the other Caches containing the same address "Invalid" while data is being written down by one processor onto its Cache


input  wire                                           Flush_1,     


input  wire         [Size-1 : 0 ]      p1_write_data ,         // data  from cache_1 (to read )  
input  wire         [Size-1 : 0 ]      p2_write_data ,         // data  from cache_2 (to read )

input  wire         [block_size-1 : 0 ]      out_memory_data_bits_1 ,         // data  from memory (to read )  2 cache invalid
input  wire         [block_size-1 : 0 ]      out_memory_data_bits_2 , 

input  wire         [block_size-1 : 0 ]      out_cache_data_bits_1 ,        // data  that want to write  coming from processor 1
input  wire         [block_size-1 : 0 ]      out_cache_data_bits_2 ,         // data  that want to write  coming from processor 2  

input  wire         [block_size-1 : 0 ]      l2_cache_out_data_1 ,   
input  wire         [block_size-1 : 0 ]      l2_cache_out_data_2 ,   


input  wire                                          Bus_Rd_IC_L2_1,  //When processor reads a data that is exclusive to itself--- "E" state
input  wire                                          Bus_Rd_IC_L2_2,







//output  reg         [byte_size-1 : 0 ]      l2_cache_in_data ,   

output    reg                       read_done_1,
output    reg                       write_done_1,
output    reg                       read_done_2,
output    reg                       write_done_2,
output  reg                                           stata_snooping_1,
output  reg                                           stata_snooping_2,
output  reg                                           W_L1_sig_1,             //input from protocol,if =1 modify the state in the cache line
output  reg                                           R_L1_sig_1,             //input from protocol,if =1 modify the data in the cache line
output  reg                                           W_L1_sig_2,             //input from protocol,if =1 modify the state in the cache line
output  reg                                           R_L1_sig_2,             //input from protocol,if =1 modify the data in the cache line
 

output  reg        [Size-1 : 0 ]      req_write_data_bits_1 ,
output  reg        [Size-1 : 0 ]      req_write_data_bits_2 ,



output  reg        [block_size-1 : 0 ]      req_read_data_bits_1,
output  reg        [block_size-1 : 0 ]      req_read_data_bits_2,


 
output  reg        [state_bits-1:0]            next_state_1,
output  reg        [state_bits-1:0]           next_state_2 ,
output  reg        [state_bits-1:0]            next_state_1_snooping,
output  reg        [state_bits-1:0]           next_state_2_snooping     

 );


 always@(posedge CLK )
 begin

    
	 next_state_1='bx;
	 next_state_2='bx;
	 write_done_1='bx;
     read_done_1='bx;
	 write_done_2='bx;
     read_done_2='bx;
	 next_state_1_snooping='bx;
	 next_state_2_snooping='bx;
	 req_write_data_bits_1='bx;   
	 req_write_data_bits_2 ='bx;  
	 req_read_data_bits_1 ='bx; 
	 req_read_data_bits_2 ='bx; 
     stata_snooping_1='bx; 
     stata_snooping_2='bx; 
	  W_L1_sig_1 ='bx;         
	  R_L1_sig_1 ='bx;            
	  W_L1_sig_2 ='bx;          
	  R_L1_sig_2 ='bx;	  

   case(current_state_1)                       
       3'b00: begin                           //Cache is in the "I" state
                 if(Pr_Rd_1==1 && Bus_Rd_IC_1==1 )  
                    begin
                       req_read_data_bits_1=out_memory_data_bits_1;  		          
					   R_L1_sig_1 = 1 ;  
			           read_done_1=1;					   
                       next_state_1=3'b01;         					   
                    end  
                 else if(Pr_Rd_1==1 &&Bus_Rd_IC_L2_1 == 1)   
                    begin     
                       req_read_data_bits_1= l2_cache_out_data_1; 
                       next_state_1=3'b01;
			           read_done_1=1;					   
					   R_L1_sig_1 = 1 ;					   
                    end 					
                 else if(Pr_Rd_1==1 && Bus_Rd_C_1==1)   
                    begin      
                       req_read_data_bits_1= out_cache_data_bits_2; 
                       next_state_1=3'b10;	
			           read_done_1=1;						   
					   R_L1_sig_1 = 1 ;				   
                    end
					
                 else if(Pr_Wr_1==1 && Bus_RdX_1==1)     
                    begin
                       req_write_data_bits_1=p1_write_data;       
                       next_state_1=3'b11; 
                       write_done_1=1;					   
					   W_L1_sig_1=1 ;					   
                    end
                 else if(write_miss_1 == 1)
                    begin
                       req_write_data_bits_1=p1_write_data; 
                       write_done_1=1;					   
                       next_state_1=3'b11;                              
					   W_L1_sig_1=1 ;					   
                    end				     
              end 
		  
			  
       3'b01: begin                               
                 if(Pr_Rd_1==1)             
                    begin
                       next_state_1=3'b01;    
			           read_done_1=1;
                    end
                 else if(Pr_Wr_1==1)             
                    begin
                     req_write_data_bits_1=p1_write_data;
                       write_done_1=1;					 
                      next_state_1=3'b11;   
					   W_L1_sig_1= 1 ;
                    end
              end 
			  
       3'b10: begin                         
                 if(Pr_Rd_1==1)            
                    begin  
                       next_state_1=3'b10; 
			           read_done_1=1;  					   
                    end 
                 else if(Pr_Wr_1==1 && Bus_Upgr_1==1)  
                    begin
                       req_write_data_bits_1=p1_write_data; 
                       write_done_1=1;					   
                       next_state_1=3'b11;     
					   W_L1_sig_1= 1 ;					   
                    end   
              end  
			  
			  
       3'b11: begin                    
                 if(Pr_Rd_1==1)     
                    begin  
                       next_state_1=3'b11; 
			           read_done_1=1;					   
                    end
                 else if(Pr_Wr_1==1)        
                    begin
                       req_write_data_bits_1=p1_write_data;
                       write_done_1=1;					   
                       next_state_1=3'b11;      
					   W_L1_sig_1= 1 ;		

                    end   
              end                  
   endcase
   
   
   
   
   
   
   
    
    case(current_state_2_snooping)          		
       3'b001: begin             
                 if(Bus_RdX_1==1 && Flush_2==1)  
                    begin                       
                       next_state_2_snooping=3'b000;        
					   stata_snooping_2=1;
                    end 
                 else if(Bus_Rd_C_1==1 && Flush_2==1)  
                    begin  
                       next_state_2_snooping=3'b010;       
					   stata_snooping_2=1;					  
                    end   
              end
			  
       3'b010: begin                      //Cache of the other processor is in the "S" state
                 if(Bus_Rd_C_1==1 && Flush_2==1)  //Cache of working processor fetches data from the cahe of other processor
                    begin 
                       next_state_2_snooping=3'b010;     //Cache remains in the "S" state
					   stata_snooping_2=1;						   
                    end
                 else if(Bus_RdX_1==1 && Flush_2==1)  //write miss encountered by the working processor in its' own Cache
                    begin				   
                       next_state_2_snooping=3'b000;     //state changes to "I" state
					   stata_snooping_2=1;	  
                    end   
                 else if(Bus_Upgr_1==1)     //Working processor wants to write onto its' cache and wants to inavlid other Caches containing same address
                    begin					   
                       next_state_2_snooping=3'b000;   //Cache of othe rprocessor goes into the "I" state
					   stata_snooping_2=1;

                    end   
              end  







			  
       3'b011: begin                   //Cache of other processor is in the "M" state
                 if(Bus_Rd_C_1==1 && Flush_2==1)   //working processor now wants to read the data that had been written just now by other processor to its' own cache
                    begin 
                       next_state_2_snooping=3'b010;   //change of the state of the other cache to "S" cache
					   stata_snooping_2=1;						   
                    end
                 else if(Bus_RdX_1==1 && Flush_2==1)  //write miss encountered by the working processor
                    begin					   
                       next_state_2_snooping=3'b000;   //cache goes into the "I" state
					   stata_snooping_2=1;					   
                    end    
              end               
   endcase  
     
   
   
   
   
   
   
   
 
   
   
   
   
   
   
   
  
   
  case(current_state_2)                       //State Machine for current working processor (assuming working processor is Processor 1)
       3'b000: begin                           //Cache is in the "I" state
                 if(Pr_Rd_2==1 && Bus_Rd_IC_2==1  ) //all caches are invalid
                    begin
                       req_read_data_bits_2=out_memory_data_bits_2;  //Fetch data from Memory and store it in the Cache of working processor p2		   
                       next_state_2=3'b001;         //Change state from "I" to "E"
					   R_L1_sig_2=1;							   
                    end
                 else if(Pr_Rd_2==1  && Bus_Rd_IC_L2_2 == 1 )    //  L1 cache of 2 processor are invalid and L2 valid
                    begin
                      req_read_data_bits_2= l2_cache_out_data_2; //Fetch data from that Cache to the Cache of the current working processor
                      next_state_2=3'b010;         //Change state from "I" to "S
					  R_L1_sig_2=1;	
                    end 					
                 else if(Pr_Rd_2==1 && Bus_Rd_C_2==1)    //If effective address is found in the Cache of the other processor and is not in "I" state
                    begin
                      req_read_data_bits_2= out_cache_data_bits_1; //Fetch data from that Cache to the Cache of the current working processor
                      next_state_2=3'b010;         //Change state from "I" to "S
					  R_L1_sig_2=1;	
                    end 
                 else if(Pr_Wr_2==1 && Bus_RdX_2==1)     //If processor wants to write into the Cache but there's a Cache miss
                    begin
                      req_write_data_bits_2=p2_write_data;       //Store data into Cache
                       next_state_2=3'b011;              //Change state from "I" to "M"
					   W_L1_sig_2=1;
			           write_done_2=1;	
                    end
                 else if( write_miss_2 == 1)
                    begin
                       req_write_data_bits_2=p2_write_data;       //Store data into Cache
                       next_state_2=3'b011;                               //Change state from "I" to "M"
					   W_L1_sig_2= 1 ;
			           write_done_2=1;					   
                    end					
              end 
			  
					  
       3'b001: begin                                //Cache is in state "E"
                 if(Pr_Rd_2==1)             //If the current working processor just wants to read the data that is already present in its Cache 
                    begin
                       next_state_2=3'b001;    //Cache remains in the same "E" state
			           read_done_2=1;	
                    end
                 else if(Pr_Wr_2==1)             //If the current working processor wants to write something onto its' Cache 
                    begin
                       req_write_data_bits_2=p2_write_data;  //Store data from processor onto the Cache
                       next_state_2=3'b011;    //Change state from "E" to "M"
					   W_L1_sig_2=1;
			           write_done_2=1;	
                    end
              end 
			  			  
       3'b010: begin                           //Cache is in state "S"
                 if(Pr_Rd_2==1)           //If the current working processor just wants to read the data that is already present in its Cache 
                    begin
                       next_state_2=3'b010;    //Cache remains in the same "S" state
			           read_done_2=1;	
                    end 
                 else if(Pr_Wr_2==1 && Bus_Upgr_2==1)  //If the current working processor wants to write something onto its' Cache
                    begin
                       req_write_data_bits_2=p2_write_data;   //Store data from processor onto the Cache
                       next_state_2=3'b011;     //Change state from "S" to "M"
					   W_L1_sig_2=1;	
			           write_done_2=1;						   
                    end   
              end  
			  
			  			  
       3'b011: begin                       //Cache is in state "M"
                 if(Pr_Rd_2==1)             //If the current working processor just wants to read the data that has just been written onto its' Cache
                    begin
                       next_state_2=3'b011;      //Cache remains in the same "M" state
			           read_done_2=1;	
                    end
                 else if(Pr_Wr_2==1)         //If the current working processor wants to write something onto its' Cache
                    begin
                       req_write_data_bits_2=p2_write_data;    //Store data from processor onto the Cache
                       next_state_2=3'b011;       //Cache remains in the same "M" state
					   W_L1_sig_2=1;
			           write_done_2=1;						   
                    end   
              end                  
   endcase  
   
 
 
      case(current_state_1_snooping)           //State Machine for the other Processor
			  
					  
       3'b001: begin              //Cache of the other processor is in the "E"
                 if(Bus_RdX_2==1 && Flush_1==1)  //If there's a write miss for the current working processor, data of the other processor has
                    begin                       // to be written back to the Main Memory before the working processor writes new data onto its' Cache
					   
                       next_state_1_snooping=3'b000;          //And state changes from "E" to "I" as working processor is doing "Write" operation
					   stata_snooping_1=1;
                    end 
                 else if(Bus_Rd_C_2==1 && Flush_1==1)  //Cache of working processor fetches data from the cahe of other processor
                    begin
                      next_state_1_snooping=3'b010;       //Change state from "E" to "S"
					   stata_snooping_1=1;					  
                    end   
              end  
			  
			 		  
			  
       3'b10: begin                      //Cache of the other processor is in the "S" state
                 if(Bus_Rd_C_2==1 && Flush_1==1)  //Cache of working processor fetches data from the cahe of other processor
                    begin
                       next_state_1_snooping=3'b010;     //Cache remains in the "S" state
					   stata_snooping_1=1;					   
                    end
                 else if(Bus_RdX_2==1 && Flush_1==1)  //write miss encountered by the working processor in its' own Cache
                    begin						   
                       next_state_1_snooping=3'b000;     //state changes to "I" state
					   stata_snooping_1=1;
					   
                    end   
                 else if(Bus_Upgr_2==1)     //Working processor wants to write onto its' cache and wants to inavlid other Caches containing same address
                    begin						   
                       next_state_1_snooping=3'b000;   //Cache of othe rprocessor goes into the "I" state
					   stata_snooping_1=1;					   
                    end   
              end  


			  
       3'b011: begin                   //Cache of other processor is in the "M" state
                 if(Bus_Rd_C_2==1 && Flush_1==1)   //working processor now wants to read the data that had been written just now by other processor to its' own cache
                    begin
                       next_state_1_snooping=3'b010;   //change of the state of the other cache to "S" cache
					   stata_snooping_1=1;					   
                    end
                 else if(Bus_RdX_2==1 && Flush_1==1)  //write miss encountered by the working processor
                    begin						   
                       req_read_data_bits_2=out_cache_data_bits_1;			
                       R_L1_sig_2=1;					   
                      next_state_1_snooping=3'b000;   //cache goes into the "I" state
					   stata_snooping_1=1;						   
                    end    
              end               
   endcase
   
 
 
 
 end
 
 
   
   endmodule