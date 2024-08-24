----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:23:22 11/22/2023 
-- Design Name: 
-- Module Name:    Game - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Game is
Port ( clk : in STD_LOGIC;
	H : out STD_LOGIC;
	V : out STD_LOGIC;
	DAC_CLK : out STD_LOGIC;
	Bout : out STD_LOGIC_VECTOR (7 downto 0);
	Gout : out STD_LOGIC_VECTOR (7 downto 0);
	Rout : out STD_LOGIC_VECTOR (7 downto 0);
	SW0		: in STD_LOGIC;		--red enable
	SW1		: in STD_LOGIC;		--red move
	SW2		: in STD_LOGIC;		--blue enable
	SW3		: in STD_LOGIC);		--blue move
end Game;

architecture Behavioral of Game is
--H-sync counter
signal hcounter : integer range 0 to 799;

--V-sync counter
signal vcounter : integer range 0 to 524;

--Pixel Clock Counter
signal pixel_clk : std_logic;

--Refresh Rate Counter
signal refresh_clk : std_logic;
signal refresh_cntr: integer := 0;

--Colour Vectors
signal R : std_logic_vector(7 downto 0);
signal G : std_logic_vector(7 downto 0);
signal B : std_logic_vector(7 downto 0);

--Vertical bar 1
signal top_border_x1: integer := 10;
signal top_border_x2: integer := 20;
signal top_border_y1: integer := 10;
signal top_border_y2: integer := 160;

--Horizontal bar 1
signal top_border_x3: integer := 10;
signal top_border_x4: integer := 630;
signal top_border_y3: integer := 10;
signal top_border_y4: integer := 20;

--Vertical bar 2
signal top_border_x5: integer := 620;
signal top_border_x6: integer := 630;
signal top_border_y5: integer := 10;
signal top_border_y6: integer := 160;

--Vertical bar 3
signal b_border_x1 : integer := 10;
signal b_border_x2 : integer := 20;
signal b_border_y1 : integer := 300;
signal b_border_y2 : integer := 470;

--Horizontal bar 2
signal b_border_x3 : integer := 10;
signal b_border_x4 : integer := 630;
signal b_border_y3 : integer := 460;
signal b_border_y4 : integer := 470;

--Vertical bar 4
signal b_border_x5 : integer := 620;
signal b_border_x6 : integer := 630;
signal b_border_y5 : integer := 300;
signal b_border_y6 : integer := 470;

--Mid-field line
signal m_line_x1 : integer := 318;
signal m_line_x2 : integer := 322;
signal m_line_y1 : integer := 30;
signal m_line_y2 : integer := 450;

--Center field white
signal c_border_x1: integer := 300;
signal c_border_x2: integer := 340;
signal c_border_y1: integer := 220;
signal c_border_y2: integer := 260;

--Center field green
signal cc_border_x1: integer := 305;
signal cc_border_x2: integer := 335;
signal cc_border_y1: integer := 225;
signal cc_border_y2: integer := 255;

--Paddle dimensions for the red paddle
signal r_paddle_x1 : integer := 600;
signal r_paddle_x2 : integer := 615;	--608
signal r_paddle_y1 : integer := 200;
signal r_paddle_y2 : integer := 275;
signal r_paddle_x_inc: integer := 0;
signal r_paddle_y_inc: integer := 0;

--Paddle dimensions for the blue paddle
signal b_paddle_x1 : integer := 25;		--40
signal b_paddle_x2 : integer := 40;		--48
signal b_paddle_y1 : integer := 200;
signal b_paddle_y2 : integer := 275;
signal b_paddle_x_inc: integer := 0;
signal b_paddle_y_inc: integer := 0;

--Dimensions for the ball
signal ball_x1 : integer := 310;
signal ball_x2 : integer := 325;
signal ball_y1 : integer := 230;
signal ball_y2 : integer := 245;

--Goal lines for the red and blue sides
signal r_goal_x : integer := 625;
signal b_goal_x : integer := 15;

--Flags for score detection and reset
signal score : std_logic;
signal reset : std_logic;

--These Are to tell the ball to move left or right, depending if a boudnary is reached.
signal ball_x_inc : std_logic;
signal ball_y_inc : std_logic;

begin
--Generate a 25Mhz clock using the 50 MHz system clock
process (clk)
	begin
	if clk'event and clk='1' then
		pixel_clk <= NOT(pixel_clk);		--pixel clk (25mhz) is every other rising edge of refresh clk (50mhz)
	end if;
end process;

--Mapping the pixel clock to the DAC_CLK output
DAC_CLK <= pixel_clk;

--H-sync and V-sync counter setup
process (pixel_clk, hcounter, vcounter)
	begin
		if pixel_clk'event and pixel_clk = '1' then
		
		-- horizontal counts from 0 to 799
			hcounter <= hcounter+1;
			if (hcounter = 799) then
				vcounter <= vcounter+1;
				hcounter <= 0;
			end if;
			
		-- vertical counts from 0 to 524
			if (vcounter = 524) then
				vcounter <= 0;
			end if;
		end if;
	end process;
	
--H-sync and V-sync are low during the sync pulse
--Otherwise, they are set to high

H <= '0' when hcounter <= 96
	else '1';
V <= '0' when vcounter <= 2
	else '1';

-- Only output colours when in the active region
process
begin

	if(hcounter >= 143 and hcounter <= 783 and vcounter >= 34 and vcounter <= 514) then
		Rout <= R;
		Gout <= G;
		Bout <= B;
	else
		Rout <= (others => '0');
		Gout <= (others => '0');
		Bout <= (others => '0');
	end if;
end process;

process(pixel_clk)
	begin
		if pixel_clk'event and pixel_clk='1' then
			if (refresh_cntr >= 416667) then
				refresh_clk <= not(refresh_clk);
				refresh_cntr <= 0;
			else
		refresh_cntr <= refresh_cntr + 1;
		end if;
	end if;
end process;

--Ball movement and collision detection
process(refresh_clk)
begin
if refresh_clk'event and refresh_clk = '1' then

--Wall collision detection
--Ball has hit object on the left, send ball to positive x direction

if (ball_x1 <= top_border_x2 +7 and (ball_y1 >= top_border_y4 and

ball_y2<= top_border_y6+2)) then
--Ball hits top-left boundary

ball_x_inc <= '1';

elsif(ball_x1 <= b_border_x2 +7 and (ball_y1 >= b_border_y5-2 and ball_y2<= b_border_y6)) then
--Ball hits bottom-left boundary

ball_x_inc <= '1';


--Ball has hit object on the right, send ball to negative x direction
elsif (ball_x2 >= top_border_x5 -7 and (ball_y2 >= top_border_y4 and ball_y1<= top_border_y6)) then
--Ball hits top-right boundary

ball_x_inc <= '0';

elsif (ball_x2 >= b_border_x5 -7 and (ball_y2 >= b_border_y1 and ball_y1<= b_border_y6)) then
--Ball hits bottom-right boundary

ball_x_inc <= '0';

end if;

--Ball and paddle collision detection
if (ball_x1 <= b_paddle_x2  and (ball_y1 >= b_paddle_y1 and ball_y2 <= b_paddle_y2)) then
--Ball has collided with blue paddle (left); send ball in the positive x direction
ball_x_inc <= '1';

--elsif (ball_x2 >= r_paddle_x1  and (ball_y1 >=  and ball_y2 <= r_paddle_y2)) then
----Ball has collided with red paddle (right); send ball in the positive x direction
--ball_x_inc <= '0';
end if;

--Ball and paddle collision detection
if (ball_x2 <= b_paddle_x1 +7 and (ball_y2 >= b_paddle_y2-7 and ball_y1 <= b_paddle_y1+7)) then
--Ball has collided with blue paddle (left); send ball in the positive x direction
ball_x_inc <= '0';

elsif (ball_x1 >= r_paddle_x2 -7 and (ball_y2 >= -7 and ball_y1 <= r_paddle_y1+7)) then
--Ball has collided with red paddle (right); send ball in the positive x direction
ball_x_inc <= '1';		-- 1 is right, 0 is left
end if;


if (ball_y1 <= top_border_y4+7) then
--Ball has hit top boundary; send ball in negative y direction
ball_y_inc <= '0';
elsif (ball_y2 >= b_border_y3-7) then
--Ball has hit bottom boundary; send ball in positive y direction

ball_y_inc <= '1';
end if;
--Goal collision detection

if (ball_x1 < b_goal_x) then
--Ball reaches left goal line; red paddle scores
score <= '1';
elsif (ball_x2 > r_goal_x) then
--Ball reaches right goal line; blue paddle scores
score <= '1';
else

--Otherwise, if none of the conditions have been met, there is no scoring

score <= '0';
end if;
if (ball_x1 <= 5) then
--Ball has reached end of screen (left); reset ball location
ball_x1 <= 310;
ball_x2 <= 325;
ball_y1 <= 230;
ball_y2 <= 245;
ball_x_inc <= '1';
ball_y_inc <= '1';
elsif (ball_x2 >= 635) then
--Ball has reached end of screen (right); reset ball location
ball_x1 <= 310;
ball_x2 <= 325;
ball_y1 <= 230;
ball_y2 <= 245;
ball_x_inc <= '0';
ball_y_inc <= '1';
else

--Ball movement

if (ball_x_inc = '1') then

	--Move ball in positive x direction

	ball_x1 <= ball_x1 + 6;
	ball_x2 <= ball_x2 + 6;
else
	--Move ball in negative x direction

	ball_x1 <= ball_x1 - 6;
	ball_x2 <= ball_x2 - 6;
end if;
if ( ball_y_inc = '1') then

	--Move ball in positive y direction

	ball_y1 <= ball_y1 - 6;
	ball_y2 <= ball_y2 - 6;
else
--Move ball in negative y direction

ball_y1 <= ball_y1 + 6;
ball_y2 <= ball_y2 + 6;
end if;
end if;
end if;
end process;
--Paddle movement and collision detection
process(refresh_clk)
	begin
	if refresh_clk'event and refresh_clk = '1' then

		if (SW2 = '1') then

		--Move red paddle up

			if (r_paddle_y1 > top_border_y4) then
				r_paddle_y1 <= r_paddle_y1 - 10;
				r_paddle_y2 <= r_paddle_y2 - 10;
			end if;
		end if;
		if(SW2 = '0') then

		--Move red paddle down

			if (r_paddle_y2 < b_border_y3) then
				r_paddle_y1 <= r_paddle_y1 + 10;
				r_paddle_y2 <= r_paddle_y2 + 10;
			end if;
		end if;
		if (SW0 = '1') then

		--Move blue paddle up

			if (b_paddle_y1 > top_border_y4) then
				b_paddle_y1 <= b_paddle_y1 - 10;
				b_paddle_y2 <= b_paddle_y2 - 10;
			end if;
		end if;
		if(SW0 = '0') then

		--Move blue paddle down

			if (b_paddle_y2 < b_border_y3) then


				b_paddle_y1 <= b_paddle_y1 + 10;
				b_paddle_y2 <= b_paddle_y2 + 10;
			end if;
		end if;
	end if;
end process;

--Display VGA Controller
process(hcounter, vcounter)
variable x: integer range 0 to 639;
variable y: integer range 0 to 479;
begin
x := hcounter - 143;
y := vcounter - 34;
--Every pixel that isn't an object on the screen is set to display green
R <= "00000000";
G <= "11111111";
B <= "00000000";
--Displaying the ball
if (x > ball_x1 and x < ball_x2 and y > ball_y1 and y < ball_y2) then

--Changing the ball colour to red when either side has scored
if (score = '1') then
R <= "11111111";
G <= "00000000";
B <= "00000000";
else
R <= "11111111";
G <= "11111111";
B <= "00000000";
end if;

--Displaying the boundaries of the field
-- Top Boundary
elsif (x > top_border_x1 and x < top_border_x2 and y > top_border_y1 and y <
top_border_y2) then

R <= "00000000";
G <= "00000000";
B <= "00000000";
elsif (x > top_border_x3 and x < top_border_x4 and y > top_border_y3 and y <
top_border_y4) then

R <= "00000000";
G <= "00000000";
B <= "00000000";
elsif (x > top_border_x5 and x < top_border_x6 and y > top_border_y5 and y <
top_border_y6) then

R <= "00000000";
G <= "00000000";
B <= "00000000";

--Bottom Boundaries

elsif (x > b_border_x1 and x < b_border_x2 and y > b_border_y1 and y < b_border_y2) then
R <= "00000000";
G <= "00000000";
B <= "00000000";
elsif (x > b_border_x3 and x < b_border_x4 and y > b_border_y3 and y < b_border_y4) then
R <= "00000000";
G <= "00000000";
B <= "00000000";
elsif (x > b_border_x5 and x < b_border_x6 and y > b_border_y5 and y < b_border_y6) then
R <= "00000000";
G <= "00000000";
B <= "00000000";
--Displaying the middle of the field
elsif (x > cc_border_x1 and x < cc_border_x2 and y > cc_border_y1 and y < cc_border_y2)
then

R <= "00000000";
G <= "11111111";
B <= "00000000";
elsif (x > m_line_x1 and x < m_line_x2 and y > m_line_y1 and y < m_line_y2) then
R <= "11111111";
G <= "11111111";
B <= "11111111";
elsif (x > c_border_x1 and x < c_border_x2 and y > c_border_y1 and y < c_border_y2) then
R <= "11111111";
G <= "11111111";
B <= "11111111";
--Displaying the paddles
--Red paddle
elsif (x > r_paddle_x1 and x < r_paddle_x2 and y > r_paddle_y1 and y < r_paddle_y2) then
R <= "11111111";
G <= "00000000";
B <= "00000000";

--Blue paddle
elsif (x > b_paddle_x1 and x <b_paddle_x2 and y > b_paddle_y1 and y < b_paddle_y2) then
R <= "00000000";
G <= "00000000";
B <= "11111111";
end if;
end process;
end behavioral;