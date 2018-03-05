#!/bin/bash
#
#

# ---------------------------------------------------------------------------------------
# get cpu core number
export CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+2}')

# ---------------------------------------------------------------------------------------
# target core
export ARCH=arm

# ---------------------------------------------------------------------------------------
# get current path
export BUILD_ROOT_PATH=`pwd`

# ---------------------------------------------------------------------------------------
# path of source
export BUILD_FC_BETAFLIGHT_PATH=${BUILD_ROOT_PATH}/fc/betaflight
export BUILD_FC_CLEANFLIGHT_PATH=${BUILD_ROOT_PATH}/fc/cleanflight
export BUILD_FC_ST_PATH=${BUILD_ROOT_PATH}/fc/st_fcu_f401
export BUILD_TRANSMITTER_BT_NRF51822_PATH=${BUILD_ROOT_PATH}/transmitter/bt_nrf51822
export BUILD_TRANSMITTER_BT_NRF52832_PATH=${BUILD_ROOT_PATH}/transmitter/bt_nrf52832
export BUILD_TRANSMITTER_BT_ST_PATH=${BUILD_ROOT_PATH}/transmitter/bt_st
export BUILD_APP_NORDIC_PATH=${BUILD_ROOT_PATH}/app/nordic
export BUILD_APP_ST_PATH=${BUILD_ROOT_PATH}/app/st

# ---------------------------------------------------------------------------------------
# path of toolchain
#export BUILD_TOOLCHAIN_ROOT_PATH=""
export BUILD_TOOLCHAIN_PATH=""
export BUILD_TOOLCHAIN_PREFIX=""

# toolchain name
export TOOLCHAIN_4_9_3_PATH_NAME="gcc-arm-none-eabi-4_9-2015q3"
export TOOLCHAIN_4_9_3_PREFIX="arm-none-eabi"

export TOOLCHAIN_5_4_1_PATH_NAME="gcc-arm-none-eabi-5_4-2016q3"
export TOOLCHAIN_5_4_1_PREFIX="arm-none-eabi"

export TOOLCHAIN_6_3_1_PATH_NAME="gcc-arm-none-eabi-6-2017-q1-update"
export TOOLCHAIN_6_3_1_PREFIX="arm-none-eabi"

export TOOLCHAIN_7_2_1_PATH_NAME="gcc-arm-none-eabi-7-2017-q4-major"
export TOOLCHAIN_7_2_1_PREFIX="arm-none-eabi"

# ---------------------------------------------------------------------------------------
#
export BUILD_PLATFORM=""
export BUILD_TYPE=""
export BUILD_BOARD=""
export BUILD_TOOLCHAIN=""
export BUILD_MACHINE=""

export BUILD_CLEAN="not clean"
export BUILD_DEUGB="not debug"

# ---------------------------------------------------------------------------------------
#
function usage()
{
	echo
	echo "./script/build.sh buid=[PLATFORM] type=[TYPE] board=[BOARD] toolchain=[TOOLCHAIN_VERSION] clean=[any_value] debug=[any_value]"
	echo "  [PLATFORM]"
	echo "    fc            : flight controller"
	echo "    transmitter   : transmitter"
	echo "  [TYPE]"
	echo "    PLATFORM=fc"
	echo "      cleanflight"
	echo "      betaflight"
	echo "      st"
	echo "    PLATFORM=transmitter"
	echo "      nordic51822"
	echo "      nordic52832"
	echo "      st"
	echo "  [BOARD]"
	echo "    PLATFORM=fc"
	echo "      LUX_RACE"
	echo "      SPARKY"
	echo "      SPRACINGF3"
	echo "      STM32F3DISCOVERY"
	echo "      ST_FCU_F401"
	echo "      STM32F746DISCOVERY"
	echo "  [TOOLCHAIN_VERSION]"
	echo "    4.9.3"
	echo "    5.4.1"
	echo "    6.3.1"
	echo "    7.2.1"
	echo
}

# ---------------------------------------------------------------------------------------
# variable for build
# ---------------------------------------------------------------------------------------
export START_TIME=""
export END_TIME=""
export BUILD_OUTPUT_ROOT_PATH=""
export BUILD_SOURCE_ROOT_PATH=""

# ---------------------------------------------------------------------------------------
# build_start_time
# ---------------------------------------------------------------------------------------
function build_start_time()
{
   START_TIME=`date +%s`
}

# ---------------------------------------------------------------------------------------
# build_end_time
# ---------------------------------------------------------------------------------------
function build_end_time()
{
   END_TIME=`date +%s`

   echo "================================================================================="
   echo "Build time : $((($END_TIME-$START_TIME)/60)) minutes $((($END_TIME-$START_TIME)%60)) seconds"
   echo "================================================================================="
}

# ---------------------------------------------------------------------------------------
# set oputput directory
# ---------------------------------------------------------------------------------------
function build_output_path()
{
   BUILD_OUTPUT_ROOT_PATH=${BUILD_ROOT_PATH}/output/$1

   if [ ! -e ${BUILD_OUTPUT_ROOT_PATH} ]
   then
      echo "mkdir -p ${BUILD_OUTPUT_ROOT_PATH}"
      mkdir -p ${BUILD_OUTPUT_ROOT_PATH}
   else
      echo "rm -rf ${BUILD_OUTPUT_ROOT_PATH}/*"
      rm -rf ${BUILD_OUTPUT_ROOT_PATH}*
   fi

   mkdir -p ${BUILD_OUTPUT_ROOT_PATH}/log
   mkdir -p ${BUILD_OUTPUT_ROOT_PATH}/bin
}

# ---------------------------------------------------------------------------------------
# build
# ---------------------------------------------------------------------------------------
function build_platform()
{
	pushd .
   cd $1

   if [ "${BUILD_CLEAN}" == "clean" ]
   then
   {
      make clean TARGET=$2
   }
   fi

   make -j$CPU_JOB_NUM TARGET=$2
	popd
}

# ---------------------------------------------------------------------------------------
# copy binary
# ---------------------------------------------------------------------------------------
function build_copy_binary()
{
   find $1 -name "*.hex" -print  -exec cp {} ${BUILD_OUTPUT_ROOT_PATH}/bin/. \;
   find $1 -name "*.elf" -print  -exec cp {} ${BUILD_OUTPUT_ROOT_PATH}/bin/. \;
}

# ---------------------------------------------------------------------------------------
# copy binary
# ---------------------------------------------------------------------------------------
function build_copy_binary_nordic()
{
   find $1/bt_transmitter -name "*.hex" -print  -exec cp {} ${BUILD_OUTPUT_ROOT_PATH}/bin/. \;
   find $1/bt_transmitter -name "*.out" -print  -exec cp {} ${BUILD_OUTPUT_ROOT_PATH}/bin/. \;
   find $1 -name "s130_nrf51_2.0.0_softdevice.hex" -print  -exec cp {} ${BUILD_OUTPUT_ROOT_PATH}/bin/. \;
}


# ---------------------------------------------------------------------------------------
# build cleanflight
# ---------------------------------------------------------------------------------------
function build_cleanflight()
{
   build_output_path $1
   BUILD_SOURCE_ROOT_PATH=${BUILD_FC_CLEANFLIGHT_PATH}
   {
      build_start_time

      build_platform ${BUILD_SOURCE_ROOT_PATH} $1
      build_copy_binary ${BUILD_SOURCE_ROOT_PATH}

      build_end_time
   } 2>&1 |tee ${BUILD_OUTPUT_ROOT_PATH}/log/build.out
}

# ---------------------------------------------------------------------------------------
# build betaflight
# ---------------------------------------------------------------------------------------
function build_betaflight()
{
   build_output_path $1
   BUILD_SOURCE_ROOT_PATH=${BUILD_FC_BETAFLIGHT_PATH}
   {
      build_start_time

      build_platform ${BUILD_SOURCE_ROOT_PATH} $1
      build_copy_binary ${BUILD_SOURCE_ROOT_PATH}

      build_end_time
   } 2>&1 |tee ${BUILD_OUTPUT_ROOT_PATH}/log/build.out
}

# ---------------------------------------------------------------------------------------
# build transmitter for nrf51822
# ---------------------------------------------------------------------------------------
function build_transmitter_nrf51822()
{
   build_output_path $1

   export GNU_INSTALL_ROOT=${BUILD_TOOLCHAIN_PATH}
   export GNU_VERSION=$2
   export GNU_PREFIX=${BUILD_TOOLCHAIN_PREFIX}
   BUILD_CLEAN="clean"

   BUILD_SOURCE_ROOT_PATH=${BUILD_TRANSMITTER_BT_NRF51822_PATH}
   {
      build_start_time

      build_platform ${BUILD_SOURCE_ROOT_PATH}/bt_transmitter
      build_copy_binary_nordic ${BUILD_SOURCE_ROOT_PATH}

      build_end_time
   } 2>&1 |tee ${BUILD_OUTPUT_ROOT_PATH}/log/build.out
}

# ---------------------------------------------------------------------------------------
# build transmitter for nrf52832
# ---------------------------------------------------------------------------------------
function build_transmitter_nrf52832()
{
   build_output_path $1
   BUILD_SOURCE_ROOT_PATH=${BUILD_TRANSMITTER_BT_NRF52832_PATH}
   {
      build_start_time

      build_platform ${BUILD_SOURCE_ROOT_PATH}

      build_end_time
   } 2>&1 |tee ${BUILD_OUTPUT_ROOT_PATH}/log/build.out
}

# ---------------------------------------------------------------------------------------
# build transmitter for st
# ---------------------------------------------------------------------------------------
function build_transmitter_st()
{
   echo TARGET BOARD NAME : "$1"
   BUILD_SOURCE_ROOT_PATH=${BUILD_TRANSMITTER_BT_ST_PATH}
   {
      build_start_time

      build_platform ${BUILD_SOURCE_ROOT_PATH}

      build_end_time
   } 2>&1 |tee ${BUILD_OUTPUT_ROOT_PATH}/log/build.out
}

# ---------------------------------------------------------------------------------------
# main routine
# ---------------------------------------------------------------------------------------
{
   clear
   # ====================================================================================
   # parsing parameter
   while [ $# -ge 1 ]
   do
   {
      key="$1"
      {
         case $key in
            "build="*)
            {
               BUILD_PLATFORM=${key#build=}
            }
            ;;
            "type="*)
            {
               BUILD_TYPE=${key#type=}
            }
            ;;
            "board="*)
            {
               BUILD_BOARD=${key#board=}
            }
            ;;
            "toolchain="*)
            {
               BUILD_TOOLCHAIN=${key#toolchain=}
            }
            ;;
            "clean="*)
            {
               BUILD_CLEAN="clean"
            }
            ;;
            "debug="*)
            {
               BUILD_DEUGB="debug"
            }
            ;;
            *)
            {
               echo "Unknown Param : $key"
               usage
               exit 0
            }
            ;;
         esac
      }
      shift
   }
   done

   # ====================================================================================
   # check option for platform
   {
      case ${BUILD_PLATFORM} in
         "fc")
            {
               case ${BUILD_TYPE} in
                  "cleanflight")
                     {
                        case ${BUILD_BOARD} in
                           "LUX_RACE")
                              ;;
                           "SPARKY")
                              ;;
                           "SPRACINGF3")
                              ;;
                           "STM32F3DISCOVERY")
                              ;;
                           "ST_FCU_F401")
                              ;;
                           "STM32F746DISCOVERY")
                              ;;
                           *)
                              echo "Not supported : ${BUILD_BOARD} "
                              usage
                              exit 0
                              ;;
                        esac
                     }
                     ;;
                  "betaflight")
                     {
                        case ${BUILD_BOARD} in
                           "LUX_RACE")
                              ;;
                           "SPARKY")
                              ;;
                           "SPRACINGF3")
                              ;;
                           "STM32F3DISCOVERY")
                              ;;
                           "ST_FCU_F401")
                              echo "Not yet supported."
                              usage
                              exit 0
                              ;;
                           "STM32F745DISCOVERY")
                              echo "Not yet supported."
                              usage
                              exit 0
                              ;;
                           *)
                              echo "Not supported : ${BUILD_BOARD} "
                              usage
                              exit 0
                              ;;
                        esac
                     }
                     ;;
                  "st")
                     echo "Not yet supported for st in the gcc, should be build in the IAR"
                     usage
                     exit 0
                     ;;
                  *)
                     echo "Not supported type in flight controller : ${BUILD_TYPE}"
                     usage
                     exit 0
                     ;;
               esac
            }
            ;;
         "transmitter")
            {
               case ${BUILD_TYPE} in
                  "nordic51822")
                     ;;
                  "nordic52832")
                     echo "Not supported type for transmitter : ${BUILD_TYPE}"
                     usage
                     exit 0
                     ;;
                  "st")
                     echo "Not yet supported for st in the gcc, should be build in the IAR"
                     usage
                     exit 0
                     ;;
                  *)
                     echo "Not supported type for transmitter : ${BUILD_TYPE}"
                     usage
                     exit 0
                     ;;
               esac
            }
            ;;
         *)
            echo "Not supported platform : ${BUILD_PLATFORM}"
            usage
            exit 0
            ;;
      esac
   }

   # ====================================================================================
   # check build machine

   # for check platform, default is linux
   unamestr=`uname`
   if [[ "$unamestr" == 'Linux' ]]
   then
   {
      echo "Select Linux platform"
      BUILD_MACHINE="linux"
   }
   elif [[ "$unamestr" == 'Darwin' ]]
   then
   {
      # os x
      echo "Select Darwin platform"
      BUILD_MACHINE="mac"
   }
   else
   {
      echo "Unknown build machine : $unamestr"
      exit 0
   }
   fi

   # ====================================================================================
   # check option for toolchain
   {
      case ${BUILD_TOOLCHAIN} in
         "4.9.3")
            BUILD_TOOLCHAIN_PATH=${BUILD_ROOT_PATH}/toolchain/${BUILD_MACHINE}/${TOOLCHAIN_4_9_3_PATH_NAME}
            BUILD_TOOLCHAIN_PREFIX=${TOOLCHAIN_4_9_3_PREFIX}
            ;;
         "5.4.1")
            BUILD_TOOLCHAIN_PATH=${BUILD_ROOT_PATH}/toolchain/${BUILD_MACHINE}/${TOOLCHAIN_5_4_1_PATH_NAME}
            BUILD_TOOLCHAIN_PREFIX=${TOOLCHAIN_5_4_1_PREFIX}
            ;;
         "6.3.1")
            BUILD_TOOLCHAIN_PATH=${BUILD_ROOT_PATH}/toolchain/${BUILD_MACHINE}/${TOOLCHAIN_6_3_1_PATH_NAME}
            BUILD_TOOLCHAIN_PREFIX=${TOOLCHAIN_6_3_1_PREFIX}
            ;;
         "7.2.1")
            BUILD_TOOLCHAIN_PATH=${BUILD_ROOT_PATH}/toolchain/${BUILD_MACHINE}/${TOOLCHAIN_7_2_1_PATH_NAME}
            BUILD_TOOLCHAIN_PREFIX=${TOOLCHAIN_7_2_1_PREFIX}
            ;;
         *)
            ;;
      esac
   }

   # ====================================================================================
   # check toolchain
   export PATH=${BUILD_TOOLCHAIN_PATH}/bin:$PATH

   # check gcc compiler
   echo ---------------------------------------------------------------------------------
   ${BUILD_TOOLCHAIN_PREFIX}-gcc -v
   echo ---------------------------------------------------------------------------------

   if [ $? != 0 ]
   then
   {
      echo
      echo "Not found tool-chain for ARM Cortex-M !!!"
      echo
      exit 1
   }
   fi

   # ====================================================================================
   # build platform
   {
      case ${BUILD_PLATFORM} in
         "fc")
            {
               case ${BUILD_TYPE} in
                  "cleanflight")
                     {
                        build_cleanflight ${BUILD_BOARD}
                     }
                     ;;
                  "betaflight")
                     {
                        build_betaflight ${BUILD_BOARD}
                     }
                     ;;
                  "st")
                     {
                        echo "Not yet supported for st in the gcc, should be build in the IAR"
                     }
                     ;;
                  *)
                     echo "Not supported type in flight controller : ${BUILD_TYPE}"
                     ;;
               esac
            }
            ;;
         "transmitter")
            {
               case ${BUILD_TYPE} in
                  "nordic51822")
                     {
                        build_transmitter_nrf51822 TRANSMITTER_NORDIC51822 ${BUILD_TOOLCHAIN}
                     }
                     ;;
                  "nordic52832")
                     {
                        build_transmitter_nrf52832 TRANSMITTER_NORDIC52832
                        echo "Not supported type for transmitter : ${BUILD_TYPE}"
                     }
                     ;;
                  "st")
                     {
                        build_transmitter_st TRANSMITTER_ST
                        echo "Not yet supported for st in the gcc, should be build in the IAR"
                     }
                     ;;
                  *)
                     {
                        echo "Not supported type for transmitter : ${BUILD_TYPE}"
                     }
                     ;;
               esac
            }
            ;;
         *)
            {
               echo "Not supported platform : ${BUILD_PLATFORM}"
            }
            ;;
      esac
   }
}
# ----------------------------------------------


