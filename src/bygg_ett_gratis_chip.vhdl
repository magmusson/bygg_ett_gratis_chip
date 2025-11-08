library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_synth_magmusson is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);
        uo_out  : out std_logic_vector(7 downto 0);
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_synth_magmusson;

architecture Behavioral of tt_um_synth_magmusson is
    signal hz_count : integer;
    signal wavelength : integer;
    signal u : std_logic;
    signal u_counter : integer;
    signal seq_count : integer;
    signal bpm_plus_EP : std_logic;
    signal bpm_plus_sync1 : std_logic;
    signal bpm_plus_sync2 : std_logic;
    signal bpm_minus_EP : std_logic;
    signal bpm_minus_sync1 : std_logic;
    signal bpm_minus_sync2 : std_logic;
    signal bpm : integer;
    signal seq_index : integer;

    type int_array is array (0 to 47) of integer;

    constant hz_list : int_array := (
        8173, 10909, 13745,
        8173, 10909, 13745,
        8173, 10909, 13745,
        8173, 10909, 13745,
        7281, 10909, 13745,
        7281, 10909, 13745,
        7281, 10909, 13745,
        7281, 10909, 13745,
        6872, 10909, 13745,
        6872, 10909, 13745,
        6872, 10909, 13745,
        6872, 10909, 13745,
        7281, 10909, 13745,
        7281, 10909, 13745,
        7281, 10909, 13745,
        7281, 10909, 13745
    );
    

begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then 
            wavelength <= 8173; -- starttillstånd
            u_counter <= 0;
            hz_count <= 0;  
            seq_count <= 0;  
            bpm <= 738462;
            seq_index <= 0;
            u <= '0';

        elsif hz_count >= wavelength/2 then
            hz_count <= 0;       -- nollställ

            if u = '1' then
                u <= '0';
            else
                u <= '1';
                u_counter <= u_counter + 1; -- räkna hertz?
            end if; 
        
        elsif seq_count >= bpm then
            seq_count <= 0;
            u_counter <= 0;
            if seq_index = 47 then
                seq_index <= 0;
            else
                seq_index <= seq_index + 1;
            end if;


        elsif rising_edge(clk) then 
            wavelength <= hz_list(seq_index);
            hz_count <= hz_count + 1;
            seq_count <= seq_count + 1;

            bpm_plus_sync1 <= ui_in(0);
            bpm_plus_sync2 <= bpm_plus_sync1;

            bpm_minus_sync1 <= ui_in(1);
            bpm_minus_sync2 <= bpm_minus_sync1;

            if bpm_plus_EP = '1' then
                bpm <= bpm + 20000;
            elsif bpm_minus_EP = '1' then
                bpm <= bpm - 20000;
            end if;

        end if;
    end process;

    bpm_plus_EP <= bpm_plus_sync1 and (not bpm_plus_sync2);

    bpm_minus_EP <= bpm_minus_sync1 and (not bpm_minus_sync2);

    uo_out <= "0000000" & u;

    uio_out <= "00000000";
    uio_oe <= "00000000";

end Behavioral;