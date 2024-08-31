library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic(
        clockFreq : integer := 50e6;  -- FREQUÊNCIA DO CLOCK (50 MHZ POR PADRÃO)
        divisor   : integer := 1  -- ADICIONA UM DIVISOR PARA AJUSTAR A VELOCIDADE
		  -- PARA DEMONSTRAÇÃO, LEMBRAR DE COLOCAR O DIVISOR DE 2600
    );
    port (
        clk                 : in  std_logic;  -- ENTRADA DE CLOCK
        nRst                : in  std_logic;  -- ENTRADA DE RESET ATIVO BAIXO
        seg_s_dezena        : out std_logic_vector(6 downto 0);  -- SAÍDA PARA DISPLAY DE DEZENA DE SEGUNDOS
        seg_s_unidade       : out std_logic_vector(6 downto 0);  -- SAÍDA PARA DISPLAY DE UNIDADE DE SEGUNDOS
        seg_m_dezena        : out std_logic_vector(6 downto 0);  -- SAÍDA PARA DISPLAY DE DEZENA DE MINUTOS
        seg_m_unidade       : out std_logic_vector(6 downto 0);  -- SAÍDA PARA DISPLAY DE UNIDADE DE MINUTOS
        seg_h_dezena        : out std_logic_vector(6 downto 0);  -- SAÍDA PARA DISPLAY DE DEZENA DE HORAS
        seg_h_unidade       : out std_logic_vector(6 downto 0)   -- SAÍDA PARA DISPLAY DE UNIDADE DE HORAS
    );
end entity timer;

architecture rtl of timer is
    signal ticks          : unsigned(25 downto 0) := (others => '0');  -- CONTADOR DE TICKS (26 BITS)
    signal s              : unsigned(5 downto 0) := (others => '0');  -- CONTADOR DE SEGUNDOS (6 BITS)
    signal m              : unsigned(5 downto 0) := (others => '0');  -- CONTADOR DE MINUTOS (6 BITS)
    signal h              : unsigned(4 downto 0) := (others => '0');  -- CONTADOR DE HORAS (5 BITS)
    signal segundos_dezena, segundos_unidade   : unsigned(3 downto 0);  -- SINAIS PARA DECODIFICAÇÃO DOS SEGUNDOS (4 BITS)
    signal minutos_dezena, minutos_unidade     : unsigned(3 downto 0);  -- SINAIS PARA DECODIFICAÇÃO DOS MINUTOS (4 BITS)
    signal horas_dezena, horas_unidade         : unsigned(3 downto 0);  -- SINAIS PARA DECODIFICAÇÃO DAS HORAS (4 BITS)

    -- FUNÇÃO PARA DECODIFICAR VALORES BINÁRIOS PARA SEGMENTOS DE 7 SEGMENTOS
    function seven_segment_decoder(bin_in: unsigned(3 downto 0)) return std_logic_vector is
    begin
        case bin_in is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2 
            when "0011" => return "0110000"; -- 3 
            when "0100" => return "0011001"; -- 4 
            when "0101" => return "0010010"; -- 5 
            when "0110" => return "0000010"; -- 6 
            when "0111" => return "1111000"; -- 7 
            when "1000" => return "0000000"; -- 8 
            when "1001" => return "0010000"; -- 9 
            when others => return "1111111"; -- ERRO
        end case;
    end function seven_segment_decoder;

begin
    -- PROCESSO PRINCIPAL PARA CONTAGEM DE TICKS, SEGUNDOS, MINUTOS E HORAS
    process(clk, nRst)
    begin
        if nRst = '0' then  -- VERIFICA SE O RESET ESTÁ ATIVADO
            ticks <= (others => '0');  -- REINICIA O CONTADOR DE TICKS
            s <= (others => '0');  -- REINICIA O CONTADOR DE SEGUNDOS
            m <= (others => '0');  -- REINICIA O CONTADOR DE MINUTOS
            h <= (others => '0');  -- REINICIA O CONTADOR DE HORAS
        elsif rising_edge(clk) then  -- VERIFICA SE HÁ UMA BORDA DE SUBIDA NO CLOCK
            if ticks = (clockFreq / divisor) - 1 then  -- VERIFICA SE O CONTADOR ATINGIU O VALOR MÁXIMO
                ticks <= (others => '0');  -- REINICIA O CONTADOR DE TICKS
                
                if s = 59 then  -- VERIFICA SE OS SEGUNDOS ATINGIRAM 59
                    s <= (others => '0');  -- REINICIA OS SEGUNDOS
                    
                    if m = 59 then  -- VERIFICA SE OS MINUTOS ATINGIRAM 59
                        m <= (others => '0');  -- REINICIA OS MINUTOS
                        
                        if h = 23 then  -- VERIFICA SE AS HORAS ATINGIRAM 23
                            h <= (others => '0');  -- REINICIA AS HORAS
                        else
                            h <= h + 1;  -- INCREMENTA AS HORAS
                        end if;
                    else
                        m <= m + 1;  -- INCREMENTA OS MINUTOS
                    end if;
                else
                    s <= s + 1;  -- INCREMENTA OS SEGUNDOS
                end if;
            else 
                ticks <= ticks + 1;  -- INCREMENTA O CONTADOR DE TICKS
            end if;
        end if;
    end process;

    -- CONVERSÃO DOS VALORES DE SEGUNDOS, MINUTOS E HORAS PARA DÍGITOS DE DEZENA E UNIDADE
    segundos_dezena  <= to_unsigned(to_integer(s) / 10, 4);  -- DIVIDE SEGUNDOS POR 10 E CONVERTE PARA UNSIGNED
    segundos_unidade <= to_unsigned(to_integer(s) mod 10, 4); -- CALCULA O MÓDULO DOS SEGUNDOS POR 10 E CONVERTE PARA UNSIGNED
    minutos_dezena   <= to_unsigned(to_integer(m) / 10, 4);  -- DIVIDE MINUTOS POR 10 E CONVERTE PARA UNSIGNED
    minutos_unidade  <= to_unsigned(to_integer(m) mod 10, 4); -- CALCULA O MÓDULO DOS MINUTOS POR 10 E CONVERTE PARA UNSIGNED
    horas_dezena     <= to_unsigned(to_integer(h) / 10, 4);  -- DIVIDE HORAS POR 10 E CONVERTE PARA UNSIGNED
    horas_unidade    <= to_unsigned(to_integer(h) mod 10, 4); -- CALCULA O MÓDULO DAS HORAS POR 10 E CONVERTE PARA UNSIGNED

    -- ATRIBUIÇÃO DOS VALORES DECODIFICADOS AOS DISPLAYS DE 7 SEGMENTOS
    seg_s_dezena  <= seven_segment_decoder(segundos_dezena);  -- DECODIFICA E EXIBE DEZENA DE SEGUNDOS
    seg_s_unidade <= seven_segment_decoder(segundos_unidade); -- DECODIFICA E EXIBE UNIDADE DE SEGUNDOS
    seg_m_dezena  <= seven_segment_decoder(minutos_dezena);  -- DECODIFICA E EXIBE DEZENA DE MINUTOS
    seg_m_unidade <= seven_segment_decoder(minutos_unidade); -- DECODIFICA E EXIBE UNIDADE DE MINUTOS
    seg_h_dezena  <= seven_segment_decoder(horas_dezena);  -- DECODIFICA E EXIBE DEZENA DE HORAS
    seg_h_unidade <= seven_segment_decoder(horas_unidade); -- DECODIFICA E EXIBE UNIDADE DE HORAS

end architecture rtl;
