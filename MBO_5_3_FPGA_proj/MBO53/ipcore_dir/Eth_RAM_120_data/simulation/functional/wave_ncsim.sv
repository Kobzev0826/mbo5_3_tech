

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /Eth_RAM_120_data_tb/status
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/CLKA
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/ADDRA
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/DINA
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/WEA
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/CLKB
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/ADDRB
      waveform add -signals /Eth_RAM_120_data_tb/Eth_RAM_120_data_synth_inst/bmg_port/DOUTB

console submit -using simulator -wait no "run"
