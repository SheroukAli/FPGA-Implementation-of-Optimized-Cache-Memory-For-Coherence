// cache of p1 reading from cache of p2 after cache of p2 writing data in this place



//***Performing R1, W1, R2, W2, R1 operations***//
`timescale 1ns/1ns

module Cache_TB ();
parameter byte_size = 8;
parameter Addr = 37 ;
parameter Size = 8;
parameter num_of_columns=64;
parameter num_of_rows=64;
parameter result = "test.log" ;

reg                        CLK;
reg                       RST;
reg                      operation;

reg     [byte_size-1 : 0 ]          cache_1_write_data_tb;
reg     [byte_size-1 : 0 ]          cache_2_write_data_tb ;

wire    [Size-1 : 0 ]          p1_write_data_tb ;
wire    [Size-1 : 0 ]          p2_write_data_tb ;
 
wire  [18:0]    read_count_1_tb;
wire  [18:0]    write_count_1_tb;
wire  [18:0]    read_hit_cycle_1_tb;
wire  [18:0]    write_hit_cycle_1_tb;
wire  [15:0]    num_of_read_hit_1_tb;
wire  [15:0]    num_of_read_miss_1_tb;
wire  [15:0]    num_of_write_hit_1_tb;
wire  [15:0]    num_of_write_miss_1_tb;

wire  [18:0]    read_count_2_tb;
wire  [18:0]    write_count_2_tb;
wire  [18:0]    read_hit_cycle_2_tb;
wire  [18:0]    write_hit_cycle_2_tb;
wire  [15:0]    num_of_read_hit_2_tb;
wire  [15:0]    num_of_read_miss_2_tb;
wire  [15:0]    num_of_write_hit_2_tb;
wire  [15:0]    num_of_write_miss_2_tb;

wire                      Matrix_A_Write_done_tb;
wire                      Matrix_B_Write_done_tb;
wire                      Matrix_A_read_done_tb;
wire                      Matrix_B_read_done_tb;
wire                      Multiplication_done_tb;
wire   [num_of_columns*num_of_rows-1:0]         signal_3_tb;
wire   [num_of_columns*num_of_rows-1:0]         signal_4_tb;
wire                      run_signal_tb;
wire     [Size-1:0]       output_data_to_processor_1_tb;
wire      [Size-1:0]      output_data_to_processor_2_tb;



parameter   CLK_period = 10 ;

integer fd;
initial fd = $fopen(result,"w");




always@ (*)
begin
//if (signal_3_tb==4096 && signal_4_tb<1 &&run_signal_tb==1)
//$fwrite(fd,"%D",p1_write_data_tb," ");
if (signal_3_tb==4096 && signal_4_tb<num_of_rows*num_of_columns&&run_signal_tb==1)
begin
if ((signal_4_tb+1)%(num_of_columns) ==0 &&signal_4_tb!=0 )
$fwrite(fd,"%D",p1_write_data_tb,"\n");
else
$fwrite(fd,"%D",p1_write_data_tb," ");
end
end

always@ (posedge CLK)
begin
if(Multiplication_done_tb==1)
  begin
  $fwrite(fd,"\n\n\n");
  $fwrite(fd,"num_of_read_hit_1_tb = " ,"%D",num_of_read_hit_1_tb,"\n");
  $fwrite(fd,"read_hit_cycle_1_tb = " , read_hit_cycle_1_tb,"\n"); 
  $fwrite(fd,"num_of_read_miss_1_tb = ",num_of_read_miss_1_tb,"\n"); 
  $fwrite(fd,"\n");   
  $fwrite(fd,"num_of_write_hit_1_tb = ",num_of_write_hit_1_tb,"\n"); 
  $fwrite(fd,"write_hit_cycle_1_tb = ",write_hit_cycle_1_tb,"\n"); 
  $fwrite(fd,"num_of_write_miss_1_tb = ",num_of_write_miss_1_tb,"\n");  
  $finish ;
  end
end

initial 
begin
    $dumpfile("cache_top.vcd");
    $dumpvars;

   RST=0;
    CLK='b0;  
#10	
   RST=1;

  operation=1;

end


always  #(CLK_period/2)   CLK = ~CLK  ;  





cache_top DUT (
.CLK(CLK),
.RST(RST),
.operation(operation),
.p1_write_data(p1_write_data_tb),
.p2_write_data(p2_write_data_tb),
.Matrix_A_Write_done(Matrix_A_Write_done_tb),
.Matrix_B_Write_done(Matrix_B_Write_done_tb),
.Matrix_A_read_done(Matrix_A_read_done_tb),
.Matrix_B_read_done(Matrix_B_read_done_tb),
.Multiplication_done(Multiplication_done_tb),
.read_count_1(read_count_1_tb),
.write_count_1(write_count_1_tb),
.read_hit_cycle_1(read_hit_cycle_1_tb),
.write_hit_cycle_1(write_hit_cycle_1_tb),
.num_of_read_hit_1(num_of_read_hit_1_tb),
.num_of_read_miss_1(num_of_read_miss_1_tb),
.num_of_write_hit_1(num_of_write_hit_1_tb),
.num_of_write_miss_1(num_of_write_miss_1_tb),
.read_count_2(read_count_2_tb),
.write_count_2(write_count_2_tb),
.read_hit_cycle_2(read_hit_cycle_2_tb),
.write_hit_cycle_2(write_hit_cycle_2_tb),
.num_of_read_hit_2(num_of_read_hit_2_tb),
.num_of_read_miss_2(num_of_read_miss_2_tb),
.num_of_write_hit_2(num_of_write_hit_2_tb),
.num_of_write_miss_2(num_of_write_miss_2_tb),
.signal_3(signal_3_tb),
.signal_4(signal_4_tb),
.run_signal(run_signal_tb),
.cache_1_write_data(cache_1_write_data_tb),
.cache_2_write_data(cache_2_write_data_tb),
.output_data_to_processor_1(output_data_to_processor_1_tb),
.output_data_to_processor_2(output_data_to_processor_2_tb)
);

endmodule


