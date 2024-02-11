--
-- Multicore 2 / Multicore 2+
--
-- Copyright (c) 2017-2020 - Victor Trucco
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
		
	component sfl is
		port (
			noe_in              : in  std_logic                    := 'X';             -- noe
			dclk_in             : in  std_logic                    := 'X';             -- dclkin
			ncso_in             : in  std_logic                    := 'X';             -- scein
			data_in             : in  std_logic_vector(3 downto 0) := (others => 'X'); -- data_in
			data_oe             : in  std_logic_vector(3 downto 0) := (others => 'X'); -- data_oe
			asmi_access_granted : in  std_logic                    := 'X';             -- asmi_access_granted
			data_out            : out std_logic_vector(3 downto 0);                    -- data_out
			asmi_access_request : out std_logic                                        -- asmi_access_request
		);
	end component sfl;

	u0 : component sfl
		port map (
			noe_in              => CONNECTED_TO_noe_in,              --              noe_in.noe
			dclk_in             => CONNECTED_TO_dclk_in,             --             dclk_in.dclkin
			ncso_in             => CONNECTED_TO_ncso_in,             --             ncso_in.scein
			data_in             => CONNECTED_TO_data_in,             --             data_in.data_in
			data_oe             => CONNECTED_TO_data_oe,             --             data_oe.data_oe
			asmi_access_granted => CONNECTED_TO_asmi_access_granted, -- asmi_access_granted.asmi_access_granted
			data_out            => CONNECTED_TO_data_out,            --            data_out.data_out
			asmi_access_request => CONNECTED_TO_asmi_access_request  -- asmi_access_request.asmi_access_request
		);

