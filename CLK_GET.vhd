library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.cpu_pk.all;

entity CLK_GET is
PORT(
	DYPA : OUT STD_LOGIC;
	DYPB : OUT STD_LOGIC;

	CLK : IN STD_LOGIC;
	RST : IN STD_LOGIC;
	
	CLK36 : OUT STD_LOGIC;
	CLK18 : OUT STD_LOGIC
);
end CLK_GET;

architecture CLK_GET of CLK_GET is
SIGNAL CNT36,CNT18 : INTEGER;
begin
PROCESS(CLK,RST)
BEGIN
IF(RST='0')THEN
	CNT36<=0;
ELSIF(CLK'EVENT AND CLK='1')THEN
	CNT36<=CNT36+1;
	--IF CNT36=99 THEN
	IF CNT36=2 THEN
	CLK36 <= '1';
	DYPA <= '1';
	ELSIF CNT36=3 THEN
	--ELSIF CNT36=199 THEN
	CLK36 <= '0';
	CNT36 <= 0;
	DYPA <='0';
	END IF;
END IF;
END PROCESS;

PROCESS(CLK,RST)
BEGIN
IF(RST='0')THEN
	CNT18<=0;
ELSIF(CLK'EVENT AND CLK='1')THEN
	CNT18<=CNT18+1;
	IF CNT18=0 THEN
	CLK18 <= '1';
	DYPB <= '1';
	ELSIF CNT18=1 THEN
	CLK18 <= '0';
	CNT18<=0;
	DYPB <= '0';
	END IF;
END IF;
END PROCESS;
end CLK_GET;

