module SPI_slave(
  input clk, 
  input SCK, 
  input MOSI, 
  output MISO, 
  input SSEL, 
  output LED1,
  output LED2,
  output LED3,
  output LED4,
  output LED5,
);

reg [2:0] SCKr;  always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
wire SCK_risingedge = (SCKr[2:1]==2'b01);  
wire SCK_fallingedge = (SCKr[2:1]==2'b10);

reg [2:0] SSELr;  always @(posedge clk) SSELr <= {SSELr[1:0], SSEL};
wire SSEL_active = ~SSELr[1];                 
wire SSEL_startmessage = (SSELr[2:1]==2'b10);
wire SSEL_endmessage = (SSELr[2:1]==2'b01);  

reg [1:0] MOSIr;  always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
wire MOSI_data = MOSIr[1];

reg [2:0] bitcnt;

reg byte_received;   
reg [7:0] byte_data_received;

always @(posedge clk)
begin
  if(~SSEL_active)
    bitcnt <= 3'b000;
  else
  if(SCK_risingedge)
  begin
    bitcnt <= bitcnt + 3'b001;

    byte_data_received <= {byte_data_received[6:0], MOSI_data};
  end
end

always @(posedge clk) 
  byte_received <= SSEL_active && SCK_risingedge && (bitcnt==3'b111);

reg LED1, LED2, LED3, LED4, LED5;
always @(posedge clk) 
  if(byte_received) 
  begin
    LED1 <= byte_data_received[0];
    LED2 <= byte_data_received[1];
    LED3 <= byte_data_received[2];
    LED4 <= byte_data_received[3];
    LED5 <= byte_data_received[4];
  end

reg [7:0] byte_data_sent;

reg [7:0] cnt;
always @(posedge clk) 
  if(SSEL_startmessage) 
    cnt<=cnt+8'h1; 

always @(posedge clk)
if(SSEL_active)
begin
  if(SSEL_startmessage)
    byte_data_sent <= cnt; 
  else
  if(SCK_fallingedge)
  begin
    if(bitcnt==3'b000)
      byte_data_sent <= 8'h00; 
    else
      byte_data_sent <= {byte_data_sent[6:0], 1'b0};
  end
end

assign MISO = byte_data_sent[7]; 

endmodule

