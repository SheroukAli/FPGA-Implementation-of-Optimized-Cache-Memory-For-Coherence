
module Mutrix_mult #(parameter byte_size = 8,parameter num_of_rows = 64,parameter num_of_columns = 64 ,parameter Addr = 37 ,parameter no_of_sets=128,parameter block_size=512,parameter index_bits=7,parameter tag_bits=24,parameter offset_bits=6)
 


(
input  wire                                CLK,RST,
input  wire                                 operation,
input  wire                                 write_done_1,
input  wire                                  read_done_1,
input  wire                                 write_done_2,
input  wire                                  read_done_2,
input   wire    [byte_size-1:0]      output_data_to_processor_1,
input   wire    [byte_size-1:0]      output_data_to_processor_2,
input  wire                                 matrix_store_1,
input  wire                                 matrix_store_2,

input  wire     [byte_size-1 : 0 ]          cache_1_write_data , 
input  wire     [byte_size-1 : 0 ]          cache_2_write_data , 

output     reg                                  Pr_Rd_1 ,Pr_Wr_1,
output     reg                                  Pr_Rd_2 ,Pr_Wr_2,
output     reg     [byte_size-1 : 0 ]          p1_write_data , 
output     reg     [byte_size-1 : 0 ]          p2_write_data , 


output     reg     [Addr-1:0]               Adderss_1, 
output     reg     [Addr-1:0]               Adderss_2,
output    reg                             Matrix_A_Write_done,
output    reg                             Matrix_B_Write_done,
output    reg                             Matrix_A_read_done, 
output    reg                             Matrix_B_read_done,
output    reg                             Multiplication_done,
output    reg  [12:0]         signal_3,
output    reg  [12:0]         signal_4,
output    reg                                    run_signal
);











reg  [offset_bits:0]           x ;         // offest of address in case of write 
reg  [index_bits-1:0]          y ;         // index of address in case of write 
reg  [tag_bits-1:0]            z ;         // tag of address in case of write


 


reg  [num_of_columns-1:0]         d ;  
reg  [num_of_rows-1:0]            w ;
reg  [byte_size-1:0] data;
reg  [byte_size-1:0] data_1;
reg  [20:0]            L ;

reg  [12:0]         signal_0;
reg  [12:0]         signal_1;
reg  [12:0]         signal_2;
reg [80:0] Result;
reg [byte_size*num_of_columns-1:0] A1 [0:num_of_rows-1];
reg [byte_size*num_of_columns-1:0] B1 [0:num_of_rows-1];
reg [byte_size*num_of_columns-1:0] Res1 [0:num_of_rows-1];
reg [byte_size-1:0] answer [0:num_of_columns*num_of_rows-1];
integer i,j,k;
 

always@ (posedge CLK)
begin
Pr_Wr_1='bx;	
Pr_Rd_1='bx ;
Adderss_1= 'bx; 
p1_write_data='bx;	
Pr_Wr_2='bx;		
Pr_Rd_2='bx;	
Adderss_2='bx;	
p2_write_data='bx;	
Matrix_A_Write_done=0;
Matrix_B_Write_done=0;
Matrix_A_read_done=0;
Matrix_B_read_done=0;
Multiplication_done=0;
x=0;
y=0;
z=0;
d=0;
w=0;
data=0;
data_1 =0;
signal_0=0;
signal_1=0;
signal_2=0;
signal_3=0;
signal_4=0;



if(operation==1)
begin

if( signal_0 <num_of_rows*num_of_columns) 
begin 
// enter the data of matrix A to cache 1
if(write_done_1==1)
begin
signal_0 = signal_0+1 ;
x=x+1;
data=data+1;      
end 
if(x==num_of_columns)                    // takr care    ( but -1)
begin
x=0;
y=y+1;
z=z+4;
end
if(z==256)
begin
z=1;
y=0;
Matrix_A_Write_done=1;
end
if( signal_0 <num_of_rows*num_of_columns)
begin 
Pr_Wr_1=1;	
Pr_Rd_1=0 ;
Adderss_1= {z,y,x[5:0]} ; 
p1_write_data=1 ;
end
end






else if( signal_1 <num_of_rows*num_of_columns) 
begin 
// enter the data of matrix B to cache 1
if(write_done_1==1)
begin
signal_1 = signal_1+1 ;
x=x+1;
data_1=data_1+1;      
end 
if(x==num_of_columns)
begin
x=0;
y=y+1;
z=z+4;
end
if(z==257)
begin
z=0;
y=0;
Matrix_B_Write_done=1;
end
if( signal_1 <num_of_rows*num_of_columns)
begin 
Pr_Wr_1=1;	
Pr_Rd_1=0 ;
Adderss_1={z,y,x[5:0]} ; 
p1_write_data=1 ;
end
end









else if (signal_2 <num_of_rows*num_of_columns)
begin 
// Reading the data of matrix A from cache 1
if(read_done_1==1 )
begin
signal_2 = signal_2+1 ;
x=x+1;  
d=d+1; 
end
if(x==num_of_columns)
begin
x=0;
y=y+1;
z=z+4;
end
if(z==256)
begin
z=1;
y=0;
Matrix_A_read_done=1;
end
if(d==num_of_rows)
begin
d=0;
w=w+1;	
end
if(matrix_store_1==1)
begin
A1[w][(((d)*byte_size)+byte_size-1)-:byte_size]=output_data_to_processor_1     ;
end 
if(w==64)
w=0;
if (signal_2 <=num_of_rows*num_of_columns-1)
begin
Pr_Wr_1=0;	
Pr_Rd_1=1 ;
Adderss_1= {z,y,x[5:0]} ;         
end
end

else if (signal_3 <num_of_rows*num_of_columns)
begin 
// Reading the data of matrix B from cache 1
if(read_done_1==1 )
begin
signal_3 = signal_3+1 ;
x=x+1;  
d=d+1; 
end
if(x==num_of_columns)
begin
x=0;
y=y+1;
z=z+4;
Matrix_B_read_done=1;
end
if(z==257)
begin
z=2;
y=0;
end
if(d==num_of_rows)
begin
d=0;
w=w+1;	
end
if(matrix_store_1==1)
begin
B1[w][(((d)*byte_size)+byte_size-1)-:byte_size]=output_data_to_processor_1     ;
end 
if (signal_3 <=num_of_rows*num_of_columns-1)
begin
Pr_Wr_1=0;	
Pr_Rd_1=1 ;
Adderss_1= {z,y,x[5:0]} ;         
end
end




if( signal_4 <num_of_rows*num_of_columns&&i==64&&j==64&&k==64) 
begin 
// enter the data of matrix C to cache 1
run_signal=1;
if(write_done_1==1)
begin
signal_4 = signal_4+1 ;
x=x+1;
data=data+1;      
end 
if(x==num_of_columns)                    // takr care    ( but -1)
begin
x=0;
y=y+1;
z=z+4;
end
if(z==258)
begin
Multiplication_done=1;
z=0;
end
if( signal_4 <num_of_rows*num_of_columns)
begin 
Pr_Wr_1=1;	
Pr_Rd_1=0 ;
Adderss_1= {z,y,x[5:0]} ; 
p1_write_data=Res1[y][((x*byte_size)+byte_size-1)-:byte_size] ;
end
end

else if(signal_3 ==num_of_rows*num_of_columns)
begin

		for(i=0;i<num_of_rows;i=i+1)
		begin
			 L=num_of_columns*i;
			for(j=0;j<num_of_columns;j=j+1)
			begin
			  Result=0;
				for(k=0;k<num_of_columns;k=k+1)
				begin
					Result=Result+ (A1[i][((k*byte_size)+byte_size-1)-:byte_size]*B1[k][((j*byte_size)+byte_size-1)-:byte_size]); 
				end
				if(Result>=255)
				Result=255;
				Res1[i][((j*byte_size)+byte_size-1)-:byte_size]=Result;
				answer[j+L][byte_size-1:0]=Result;
			end
		end
end



end
end
endmodule


