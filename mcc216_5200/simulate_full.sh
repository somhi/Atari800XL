#!/bin/bash

echo "---------------------------------------------------------"
echo "Use 'simulate -run' to skip compilation stage."
echo "Use 'simulate -view' to show previous simulation results."
echo "---------------------------------------------------------"

name=atari800core_mcc



. /home/markw/fpga/xilinx/14.7/ISE_DS/settings64.sh

mkdir -p sim
pushd sim

# if we have a WDB file, we can view it if requested (otherwise we remove it)
if [ ! -e $name.wdb -o "$1" != "-view" ]; then

    rm -f $name.wdb

    # if we have a EXE, we can run it if requested (otherwise we remove it)
    if [ ! -e $name.exe -o "$1" != "-run" ]; then

        rm -f $name.exe

        # copy testbench files
        cp -p ../tb_full/* .

        # copy source files
	cp `find ../../common/a8core/ -iname "*.vhd"` .
	cp `find ../../common/a8core/ -iname "*.vhdl"` .
	cp `find ../../common/components/ -iname "*.vhd"` .
	cp `find ../../common/components/ -iname "*.vhdl"` .
	cp `find ../../common/zpu/ -iname "*.vhd"` .
	cp `find ../../common/zpu/ -iname "*.vhdl"` .
	cp ../atari800core_mcc.vhd .
	cp ../zpu_rom.vhdl .
	cp ../sdram_ctrl_3_ports.v .
	cp ../*pll*.vhd* .
	cp ../svideo/* .

        # set up project definition file
	ls *.v | perl -e 'while (<>){s/(.*)/verilog work $1/;print $_;}' | cat > $name.prj
	ls *.vhd* | perl -e 'while (<>){s/(.*)/vhdl work $1/;print $_;}' | cat >> $name.prj
	echo NumericStdNoWarnings = 1 >> xilinxsim.ini

        # verbose & no multthreading - fallback in case of problems
        # fuse -v 1 -mt off -incremental -prj %name%.prj -o %name%.exe -t %name%

        fuse -timeprecision_vhdl 1fs -incremental -prj $name.prj -o $name.exe -t ${name}_tb || exit 1
        # fuse --mt off -prj %name%.prj -o %name%.exe -t %name%_tb

        # Check for the EXE again, independent of the errorlevel of fuse...
        [ -e $name.exe ] || echo "No simulation executable created"


    fi

    # Open the iSIM GUI and run the simulation
    ./$name.exe -gui -f ../$name.cmd -wdb $name.wdb -log $name.log -view ../$name.wcfg || exit 1
    #strace ./$name.exe -gui -f ../$name.cmd -wdb $name.wdb -log $name.log -view ../$name.wcfg >& out
    #./$name.exe -h -log $name.log 


else

    # Only start the viewer on an existing wave configuration (from an old simulation)
    isimgui -view ../$name.wcfg || exit 1

fi

popd
