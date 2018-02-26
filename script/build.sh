#!/bin/bash
#
#

# get cpu core number
export CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+2}')

export ARCH=arm

export BUILD_TARGET=""
export TARGET_BOARD=""
export BUILD_DEBUG=0
export BUILD_TOOLCHAIN=""

# for betaflight
export MAJOR_VERSION=3
export MINOR_VERSION=1
export SUB_VERSION=0

# toolchain name
export TOOLCHAIN_4_9_3_PATH_NAME="gcc-arm-none-eabi-4_9-2015q3"
export TOOLCHAIN_4_9_3_PREFIX="arm-none-eabi"

export TOOLCHAIN_5_4_1_PATH_NAME="gcc-arm-none-eabi-5_4-2016q3"
export TOOLCHAIN_5_4_1_PREFIX="arm-none-eabi"

export TOOLCHAIN_6_3_1_PATH_NAME="gcc-arm-none-eabi-6-2017-q1-update"
export TOOLCHAIN_6_3_1_PREFIX="arm-none-eabi"

export TOOLCHAIN_FULL_PATH=""
export TOOLCHAIN_PREFIX_NAME=""

export PLATFORM=""
export BUILD_ROOT_PATH=`pwd`

# -----------------------------------------------------------------

function usage()
{
	echo
	echo "./build.sh buid=[BUILD_TARGET] target=[TARGET_BOARD] toolchain=[TOOLCHAIN_VERSION] debug "
	echo "	[BUILD_TARGET]"
	echo "		cleanflight"
	echo "			[TARGET_BOARD]"
	echo "				LUX_RACE          : "
	echo "				SPARKY            : "
	echo "				SPRACINGF3        : "
	echo "				STM32F3DISCOVERY  :"
	echo "		betaflight"
	echo "			[TARGET_BOARD]"
	echo "				LUX_RACE          : "
	echo "				SPARKY            : "
	echo "				SPRACINGF3        : "
	echo "				STM32F3DISCOVERY  :"
	echo "		nordic"
	echo "			[TARGET_BOARD]"
	echo "				s130_central      : "
	echo "				s130_peripheral   : "
	echo "				s130_all          : "
   echo "            s130_beacon       : "
	echo "	[TOOLCHAIN_VERSION]"
	echo "		4.9.3                             : "
	echo "		5.4.1                             : "
	echo "		6.3.1                             : "
	echo "	debug                                     : "
	echo
}

function build()
{
	echo "$1 $2"
	if [ ! -e "./output/$1" ]
	then
		echo "mkdir -p ./output/$1"
		mkdir -p ./output/$1/
	else
		echo "rm -rf ./output/$1/*"
		rm -rf ./output/$1/*
	fi

	pushd .
	cd $1
	{
		START_TIME=`date +%s`

		make clean TARGET=$2
		if [ ${BUILD_DEBUG} == 1 ]
		then
			echo "build : gdb mode"
			make -j$CPU_JOB_NUM TARGET=$2 DEBUG=GDB DEBUG_PORT=DEBUG_SERIAL_UART1
		else
			echo "build : none gdb mode"
			make -j$CPU_JOB_NUM TARGET=$2
		fi

		if [ $? != 0 ]
		then
			echo "Build Errror !!!"
			return 1
		fi

        for hex_file in ./obj/*.hex
        do
			echo "cp $hex_file $BUILD_ROOT_PATH/output/$1/."
			cp $hex_file $BUILD_ROOT_PATH/output/$1/.
        done

		# for cleanflight
#		if [ -e "./obj/$1_$2.hex" ]
#		then
#			echo "cp \"./obj/$1_$2.hex\" $BUILD_ROOT_PATH/output/$1/."
#			cp "./obj/$1_$2.hex" $BUILD_ROOT_PATH/output/$1/.
#		fi

		# for betaflight
#		if [ -e "./obj/$1_${MAJOR_VERSION}.${MINOR_VERSION}.${SUB_VERSION}_$2.hex" ]
#		then
#			echo "cp \"./obj/$1_${MAJOR_VERSION}.${MINOR_VERSION}.${SUB_VERSION}_$2.hex\" $BUILD_ROOT_PATH/output/$1/."
#			cp "./obj/$1_${MAJOR_VERSION}.${MINOR_VERSION}.${SUB_VERSION}_$2.hex" $BUILD_ROOT_PATH/output/$1/.
#		fi

		# for cleanflight & betaflight
		if [ -e "./obj/main/$1_$2.elf" ]
		then
			echo "cp \"./obj/main/$1_$2.elf\" $BUILD_ROOT_PATH/output/$1/."
			cp "./obj/main/$1_$2.elf" $BUILD_ROOT_PATH/output/$1/.

			echo "cp \"./obj/main/$1_$2.map\" $BUILD_ROOT_PATH/output/$1/."
			cp "./obj/main/$1_$2.map" $BUILD_ROOT_PATH/output/$1/.
		fi

		# for central of nordic
		if [ -e "./_build/nrf51_uart_central.hex" ]
		then
			echo "cp ./_build/nrf51_uart_central.hex $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/nrf51_uart_central.hex $BUILD_ROOT_PATH/output/$1/.

			echo "cp ./_build/nrf51_uart_central.map $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/nrf51_uart_central.map $BUILD_ROOT_PATH/output/$1/.

			echo "cp ./_build/nrf51_uart_central.out $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/nrf51_uart_central.out $BUILD_ROOT_PATH/output/$1/.
		fi

		# for central of nordic
		if [ -e "./_build/nrf51_uart_peripheral.hex" ]
		then
			echo "cp ./_build/nrf51_uart_peripheral.hex $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/nrf51_uart_peripheral.hex $BUILD_ROOT_PATH/output/$1/.

			echo "cp ./_build/nrf51_uart_peripheral.map $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/nrf51_uart_peripheral.map $BUILD_ROOT_PATH/output/$1/.

			echo "cp ./_build/nrf51_uart_peripheral.out $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/nrf51_uart_peripheral.out $BUILD_ROOT_PATH/output/$1/.
		fi

		# for bt_transmitter of nordic
		if [ -e "./_build/bt_transmitter.hex" ]
		then
			echo "cp ./_build/bt_transmitter.hex $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/bt_transmitter.hex $BUILD_ROOT_PATH/output/$1/.

			echo "cp ./_build/bt_transmitter.map $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/bt_transmitter.map $BUILD_ROOT_PATH/output/$1/.

			echo "cp ./_build/bt_transmitter.out $BUILD_ROOT_PATH/output/$1/."
			cp ./_build/bt_transmitter.out $BUILD_ROOT_PATH/output/$1/.
		fi

		# for nordic
		if [ -e "../components/softdevice/s130/hex/s130_nrf51_2.0.0_softdevice.hex" ]
		then
			echo "cp ../components/softdevice/s130/hex/s130_nrf51_2.0.0_softdevice.hex $BUILD_ROOT_PATH/output/$1/."
			cp ../components/softdevice/s130/hex/s130_nrf51_2.0.0_softdevice.hex $BUILD_ROOT_PATH/output/$1/.
		fi

		END_TIME=`date +%s`

		echo "============================================================================="
		echo "Build time : $((($END_TIME-$START_TIME)/60)) minutes $((($END_TIME-$START_TIME)%60)) seconds"
		echo "============================================================================="
	} 2>&1 |tee $BUILD_ROOT_PATH/output/$1/build.out
	popd
	
}

# main routine
# ----------------------------------------------
{
    clear
#    check_param

	 while [ $# -ge 1 ]
	 do
		key="$1"

		case $key in
			"build="*)
				BUILD_TARGET=${key#build=}
				;;
			"target="*)
				TARGET_BOARD=${key#target=}
				;;
			"debug"*)
				BUILD_DEBUG=1
				;;
			"toolchain="*)
				BUILD_TOOLCHAIN=${key#toolchain=}
				;;
			*)
				echo "Unknown Param : $key"
				;;
		esac

		shift
	 done

	 # check Target
	 case ${BUILD_TARGET} in
		"cleanflight")
			case ${TARGET_BOARD} in
				"LUX_RACE")
					;;
				"SPARKY")
					;;
				"SPRACINGF3")
					;;
				"STM32F3DISCOVERY")
					;;
				*)
					echo "Unknown TARGET BOARD : ${BUILD_TARGET}"
					usage
					exit 1
					;;
			esac
			;;
		"betaflight")
			case ${TARGET_BOARD} in
				"LUX_RACE")
					;;
				"SPARKY")
					;;
				"SPRACINGF3")
					;;
				"STM32F3DISCOVERY")
					;;
				*)
					echo "Unknown TARGET BOARD : ${BUILD_TARGET}"
					usage
					exit 1
					;;
			esac
			;;
		"nordic")
			case ${TARGET_BOARD} in
				"s130_central")
					;;
				"s130_peripheral")
					;;
				"transmitter")
                    ;;
				"s130_all")
					;;
				"s130_beacon")
					;;
				*)
					echo "Unknown TARGET BOARD : ${BUILD_TARGET}"
					usage
					exit 1
					;;
			esac
			;;
		*)
			echo "Unkown target : ${BUILD_TARGET}"
			usage
			exit 1
			;;
	 esac

	# for check platform, default is linux
	unamestr=`uname`
	if [[ "$unamestr" == 'Linux' ]]; then
		echo "Select Linux platform"
		PLATFORM='linux'
	elif [[ "$unamestr" == 'Darwin' ]]; then
		# os x
		PLATFORM='mac'
		echo "Select Darwin platform"

	else
		echo "Not supported platform : $unamestr"
		exit 1
	fi

	 # check toolchain
	 case ${BUILD_TOOLCHAIN} in
		"4.9.3")
			TOOLCHAIN_FULL_PATH=${BUILD_ROOT_PATH}/toolchain/${PLATFORM}/${TOOLCHAIN_4_9_3_PATH_NAME}
			TOOLCHAIN_PREFIX_NAME=${TOOLCHAIN_4_9_3_PREFIX}
			;;
		"5.4.1")
			TOOLCHAIN_FULL_PATH=${BUILD_ROOT_PATH}/toolchain/${PLATFORM}/${TOOLCHAIN_5_4_1_PATH_NAME}
			TOOLCHAIN_PREFIX_NAME=${TOOLCHAIN_5_4_1_PREFIX}
			;;
		"6.3.1")
			TOOLCHAIN_FULL_PATH=${BUILD_ROOT_PATH}/toolchain/${PLATFORM}/${TOOLCHAIN_6_3_1_PATH_NAME}
			TOOLCHAIN_PREFIX_NAME=${TOOLCHAIN_6_3_1_PREFIX}
			;;
		*)
			TOOLCHAIN_FULL_PATH=${BUILD_ROOT_PATH}/toolchain/${PLATFORM}/${TOOLCHAIN_6_3_1_PATH_NAME}
			TOOLCHAIN_PREFIX_NAME=${TOOLCHAIN_6_3_1_PREFIX}
			;;
	 esac

    # add tool-chain bin directory to PATH
	 echo $TOOLCHAIN_FULL_PATH
    export PATH=${TOOLCHAIN_FULL_PATH}/bin:$PATH

    # check gcc compiler
    ${TOOLCHAIN_PREFIX_NAME}-gcc -v

    if [ $? != 0 ]
    then
        echo
        echo "Not found tool-chain for ARM Cortex-M !!!"
        echo
        exit 1
    fi

	 # check Target
	 case ${BUILD_TARGET} in
		"cleanflight")
			build "cleanflight" ${TARGET_BOARD}
			;;
		"betaflight")
			build "betaflight" ${TARGET_BOARD}
			;;
		"nordic")
			export GNU_INSTALL_ROOT=${TOOLCHAIN_FULL_PATH}
			export GNU_VERSION=${BUILD_TOOLCHAIN}
			export GNU_PREFIX=${TOOLCHAIN_PREFIX_NAME}
			case ${TARGET_BOARD} in
				"s130_central")
					build "nRF51_SDK_v11/nrf51_uart_central"
					;;
				"s130_peripheral")
					build "nRF51_SDK_v11/nrf51_uart_peripheral"
					;;
				"transmitter")
					build "nRF51_SDK_v11/bt_transmitter"
					;;
				"s130_beacon")
					build "nRF51_SDK_v11/nrf51_beacon"
					;;
				"s130_all")
					build "nRF51_SDK_v11/nrf51_uart_central"
					build "nRF51_SDK_v11/nrf51_uart_peripheral"
					;;
			esac
	 esac
}
# ----------------------------------------------


