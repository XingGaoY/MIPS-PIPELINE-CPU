---------------------------------------------------------------------------------- 
--SRAM AND UART
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.CPU_PK.ALL;
entity SRAM is
    Port ( DATAIN : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
			  MEMMUX : IN STD_LOGIC;
           PC : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
			  PCP : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
           ADDR : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
           CLK16 : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           MEMWRT : in  STD_LOGIC;
           DATAOUT : out  STD_LOGIC_VECTOR(15 DOWNTO 0);
			  STALLE : IN STD_LOGIC;
			  STALLO : OUT STD_LOGIC;
			  
			  RAM1OE : OUT STD_LOGIC;
			  RAM1EN : OUT STD_LOGIC;
			  RAM1WE : OUT STD_LOGIC;
			  WRN : OUT STD_LOGIC;
			  RDN : OUT STD_LOGIC;
			  RAM1DATA : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			  RAM1ADDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
			  PCPO : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			  DATA_READY : in  STD_LOGIC;
           TBRE : in  STD_LOGIC;
           TSRE : in  STD_LOGIC;
			  
			  DYP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			  RST : IN STD_LOGIC;
			  INSTPRE : IN STD_LOGIC
			  );
end SRAM;

architecture Behavioral of SRAM is
SIGNAL ADDRIN:STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL DATAOUTT,PCT : STD_LOGIC_VECTOR(15 DOWNTO 0);
TYPE STATE1 IS(WUART,WSRAM,RUART,RSRAM,BF01);
SIGNAL SSTATE : STATE1;
TYPE STATE2 IS(PREP,S1,S2,S3,S4,S5);
SIGNAL PSTATE : STATE2;
begin
PCT<=PC WHEN (INSTPRE='0') ELSE
	  PC-X"0001";

ADDRIN<="00"&ADDR WHEN(MEMMUX='1')ELSE
						   "00"&PC WHEN(MEMMUX='0');
SSTATE<=WUART WHEN((MEMWRT='1')AND(ADDRIN="00"&X"BF00"))ELSE
		  WSRAM WHEN((MEMWRT='1')AND(ADDRIN/="00"&X"BF00")AND(ADDRIN/="00"&X"BF01"))ELSE
		  RUART WHEN((MEMWRT='0')AND(ADDRIN="00"&X"BF00"))ELSE
		  RSRAM WHEN((MEMWRT='0')AND(ADDRIN/="00"&X"BF00")AND(ADDRIN/="00"&X"BF01"))ELSE
		  BF01;

PROCESS(CLK,CLK16)
BEGIN
IF(CLK='1')THEN
PSTATE<=PREP;RAM1WE<='1';
DYP<="01";
ELSIF(CLK16'EVENT AND CLK16='1')THEN
CASE SSTATE IS
WHEN BF01=>
	CASE PSTATE IS
	WHEN PREP=>
		RAM1OE<='1';RAM1EN<='1';RAM1WE<='1';WRN<='1';RDN<='1';
		PSTATE<=S1;
	WHEN S1=>
		DATAOUTT<=X"000"&"00"&DATA_READY&(TBRE AND TSRE);
		PSTATE<=S2;
	WHEN OTHERS=>NULL;
	END CASE;
WHEN WUART=>
	CASE PSTATE IS
	WHEN PREP=>
		DYP<="10";
		RAM1OE<='1';RAM1EN<='1';RAM1WE<='1';WRN<='1';
		PSTATE<=S1;RAM1DATA<=DATAIN;WRN<='0';
	WHEN S1=>
		DYP<="11";
		PSTATE<=S2;
		WRN<='1';
	WHEN OTHERS=>NULL;
	END CASE;
WHEN WSRAM=>
	CASE PSTATE IS
	WHEN PREP=>
			DYP<="11";
		RAM1OE<='1';RAM1EN<='0';RAM1WE<='1';WRN<='1';RDN<='1';
		PSTATE<=S1;
	WHEN S1=>
			DYP<="10";
		PSTATE<=S2;
		RAM1ADDR<=ADDRIN;
		RAM1DATA<=DATAIN;
		RAM1WE<='0';
	WHEN OTHERS=>NULL;
	END CASE;
WHEN RUART=>
	CASE PSTATE IS
	WHEN PREP=>
	RAM1OE<='1';RAM1EN<='1';RAM1WE<='0';
	PSTATE<=S1;RDN<='0';
	WHEN S1=>
	DATAOUTT<=RAM1DATA;DYP<="10";RDN<='1';PSTATE<=S2;
	WHEN OTHERS=>NULL;
	END CASE;
WHEN RSRAM=>
	CASE PSTATE IS
	WHEN PREP=>
			DYP<="11";
		RAM1DATA<=(OTHERS=>'Z');
		RAM1OE<='0';RAM1EN<='0';RAM1WE<='1';WRN<='1';RDN<='1';
		PSTATE<=S1;RAM1ADDR<=ADDRIN;
	WHEN S1=>
		DYP<="10";DATAOUTT<=RAM1DATA;	
		PSTATE<=S2;
	WHEN OTHERS=>NULL;
	END CASE;
END CASE;
		
END IF;
END PROCESS;

PROCESS(CLK,RST)
BEGIN
IF(RST='0')THEN
DATAOUT<=X"0000";
PCPO<=X"0000";
STALLO<='0';
ELSIF(CLK'EVENT AND CLK='1')THEN
DATAOUT<=DATAOUTT;
PCPO<=PCP;
STALLO<=STALLE;
END IF;
END PROCESS;
end Behavioral;
