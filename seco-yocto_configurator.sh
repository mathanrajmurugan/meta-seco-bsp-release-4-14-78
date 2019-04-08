#!/bin/bash

type_Smarc="SMARC-C12"
type_Sbc="SBC-C20"
type_Q7="Q7-C25"

type_cpu_qdl="i.MX8M"

CONFIG_FILE=".yocto-seco-config"

BACKTITLE='Yocto SECO config'

PATH_MACHINE="sources/meta-seco-bsp-release-imx8-3-0-0/conf/machine/"

SELECTION=""
SEL_ITEM=1
SELECTION_COMP=""
SUBSEL=""
EXIT_RESPONCE=0
EXIT=0

# Default values
BOARD=${type_Smarc}
CPU_TYPE=${type_cpu_qdl}
CLEAN="CLEAN"
COMPILER_PATH="/opt/fsl-imx-xwayland/4.14-sumo/environment-setup-aarch64-poky-linux"
UBOOT_BOARD_CONF="seco_imx8mq_c12_defconfig"
DTB_CONF="seco-imx8mq-c12.dtb"
SOC_FAMILY="mx8:mx8m:mx8mq:"

# uBoot defconfig configuration options #
PATH_UBOOT_CONFIG_PATCH="sources/meta-seco-bsp-release-imx8-3-0-0/patches/dtb-not-fetch-fix-the-bug.patch"
UBOOT_BOARD_CONF="seco_imx8mq_c12_defconfig"
CONFIG_BOARD="CONFIG_TARGET_SECO_IMX8MQ_C12=y"
CONFIG_CPU="CONFIG_SECOIMX8M=y"

# Yocto variable
# BACKEND
BACKEND_X11="fsl-imx-x11"
BACKEND_FB="fsl-imx-fb"
BACKEND_XWAYLAND="fsl-imx-xwayland"
BACKEND_WAYLAND="fsl-imx-wayland"

# COMPILATION IMAGE 
IMAGE_CORE_IMAGE_MINIMAL="core-image-minimal"
IMAGE_CORE_IMAGE_BASE="core-image-base"
IMAGE_CORE_IMAGE_SATO="core-image-sato"
IMAGE_FSL_IMAGE_MACHINE_TEST="fsl-image-machine-test"
IMAGE_FSL_IMAGE_GUI="fsl-image-gui"
IMAGE_FSL_IMAGE_QT5="fsl-image-qt5"

BUILD_DIR="build_seco"

SUFFIX=""

#################################################################
#																#
#					CONFIG FILE FUNCTION						#
#																#
#################################################################

set_ConfFile() {
	echo "BOARD_TYPE $BOARD" > $CONFIG_FILE
	echo "CPU_TYPE $CPU_TYPE" >> $CONFIG_FILE
	echo "CLEAN_OP $CLEAN" >> $CONFIG_FILE
	echo "BACKEND $BACKEND" >> $CONFIG_FILE
	echo "IMAGE_TYPE $IMAGE_TYPE" >> $CONFIG_FILE
	echo "BUILD_DIR $BUILD_DIR" >> $CONFIG_FILE
}

set_from_ConfFile() {

	if [[ -e $CONFIG_FILE ]]; then
		VAR=$(cat $CONFIG_FILE | grep "BOARD_TYPE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			BOARD=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "CPU_TYPE" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			CPU_TYPE=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "CLEAN_OP" | awk '{print $2}')
		if [[ "${VAR}" != "" ]]; then
			CLEAN=$VAR
		fi
		VAR=$(cat $CONFIG_FILE | grep "BACKEND" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        BACKEND=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "IMAGE_TYPE" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        IMAGE_TYPE=$VAR
                fi
		VAR=$(cat $CONFIG_FILE | grep "BUILD_DIR" | awk '{print $2}')
                if [[ "${VAR}" != "" ]]; then
                        BUILD_DIR=$VAR
                fi
	else
		echo "WARNING: Configuration file not found!"
		set_ConfFile
	fi
}


#################################################################
#																#
#						GRAPHIC FUNCTION						#
#																#
#################################################################


main_view() {
	# open fd
	exec 3>&1
	 
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Seco Yocto Main Menu" \
			--backtitle "$BACKTITLE" \
			--ok-label "Select" \
			--default-item $SEL_ITEM \
			--cancel-label "Exit" \
			--menu "Please choose an operation:" 25 60 10 \
			1 "Board Type -->" \
			2 "CPU type -->" \
			3 "yocto build directory -->" \
			4 "yocto backend options -->" \
			5 "yocto image type -->" \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	
	if [[ "${SELECTION}" == "" ]]; then
		EXIT=1
 	fi
	# display values just entered
#	echo "$SELECTION"
	
}

board_type_view() {
	# open fd
	exec 3>&1
	VAL=(off off off)
	case "$BOARD" in
			"$type_Smarc") VAL[0]=on;;
			"$type_Sbc") VAL[1]=on;;
			"$type_Q7") VAL[2]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "Board type" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--default-item $BOARD \
			--radiolist "Select Board type:" 20 60 10 \
			$type_Smarc "Smarc RevB board" ${VAL[0]} \
			$type_Sbc "Single board computer c20" ${VAL[1]} \
			$type_Q7 "Q7 module c25" ${VAL[2]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	 
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		BOARD=$SELECTION
	fi	
}

cpu_type_view() {
	# open fd
	exec 3>&1
	VAL=(off)
	case "$CPU_TYPE" in
			"$type_cpu_qdl") VAL[0]=on;;
	esac
	# Store data to $VALUES variable
	SELECTION=$(dialog --title "CPU type" \
			--backtitle "$BACKTITLE" \
			--ok-label "Ok" \
			--cancel-label "Exit" \
			--radiolist "Select CPU type:" 20 60 10 \
			$type_cpu_qdl "i.MX8M" ${VAL[0]} \
			2>&1 1>&3)
	 
	# close fd
	exec 3>&-
	 
	if [[ "${SELECTION}" == "" ]]; then
		echo "not select"
	else
		CPU_TYPE=$SELECTION
	fi	
}

yocto_backend_view() {
	# open fd
        exec 3>&1
        VAL=(off off off off)
        case "$BACKEND" in
                 "${BACKEND_X11}") VAL[0]=on;;
                "${BACKEND_FB}") VAL[1]=on;;
                 "${BACKEND_XWAYLAND}") VAL[2]=on;;
		"${BACKEND_WAYLAND}") VAL[3]=on;;
        esac
        # Store data to $VALUES variable
        SELECTION=$(dialog --title "Backend Yocto Support" \
                        --backtitle "$BACKTITLE" \
                        --ok-label "Ok" \
                        --cancel-label "Exit" \
                        --radiolist "Select backend for graphics:" 20 60 10 \
                        $BACKEND_X11 "Xorg X11 as backend"  ${VAL[0]} \
                        $BACKEND_FB "Framebuffer as backend"  ${VAL[1]} \
                        $BACKEND_XWAYLAND "X and Wayland as backend"  ${VAL[2]} \
			$BACKEND_WAYLAND "Wayland as backend"  ${VAL[3]} \
                        2>&1 1>&3)

        # close fd
        exec 3>&-

        if [[ "${SELECTION}" == "" ]]; then
                echo "not select"
        else
                BACKEND=$SELECTION
        fi


}

yocto_image_type_view() {
        # open fd
        exec 3>&1
        VAL=(off off off off off off)
        case "$IMAGE_TYPE" in
                 "${IMAGE_CORE_IMAGE_MINIMAL}") VAL[0]=on;;
                "${IMAGE_CORE_IMAGE_BASE}") VAL[1]=on;;
                 "${IMAGE_CORE_IMAGE_SATO}") VAL[2]=on;;
                "${IMAGE_FSL_IMAGE_MACHINE_TEST}") VAL[3]=on;;
		 "${IMAGE_FSL_IMAGE_GUI}") VAL[4]=on;;
		 "${IMAGE_FSL_IMAGE_QT5}") VAL[5]=on;;
        esac
        # Store data to $VALUES variable
        SELECTION=$(dialog --title "Backend Yocto Support" \
                        --backtitle "$BACKTITLE" \
                        --ok-label "Ok" \
                        --cancel-label "Exit" \
                        --radiolist "Select backend for graphics:" 20 100 40 \
                        $IMAGE_CORE_IMAGE_MINIMAL "only allows a device to boot."  ${VAL[0]} \
                        $IMAGE_CORE_IMAGE_BASE "A console-only image"  ${VAL[1]} \
                        $IMAGE_CORE_IMAGE_SATO "This image supports X11 with a Sato theme, Pimlico applications"  ${VAL[2]} \
			$IMAGE_FSL_IMAGE_MACHINE_TEST "An FSL Community i.MX core image with console environment, no GUI"  ${VAL[3]} \
                        $IMAGE_FSL_IMAGE_GUI "This image is for X11, DirectFB, Frame Buffer and Wayland"  ${VAL[4]} \
			$IMAGE_FSL_IMAGE_QT5 "Builds a QT5 image for X11, Frame Buffer and Wayland backends"  ${VAL[5]} \
                        2>&1 1>&3)

        # close fd
        exec 3>&-

        if [[ "${SELECTION}" == "" ]]; then
                echo "not select"
        else
                IMAGE_TYPE=$SELECTION
        fi


}

compile_view() {
	EXIT_COMP=0
		# open fd
		exec 3>&1
		
		SELECTION_BUILD_DIRECTORY=$(dialog --title "yocto build directory:" \
				--backtitle "$BACKTITLE" \
				--nocancel \
                                        --inputbox "Enter build directory name here" 8 60 "$BUILD_DIR" \
                                        2>&1 1>&3)
		if [[ "${SELECTION_BUILD_DIRECTORY}" != "" ]]; then
                	BUILD_DIR=$SELECTION_BUILD_DIRECTORY
                fi
		# close fd
		exec 3>&-	

}

function exit_view () {
	dialog --title "" \
			--backtitle "$BACKTITLE" \
			--extra-button \
			--extra-label "Yes, with Compile" \
			--cancel-label "No" \
			--yesno "Want to save before exiting?" 5 70
	EXIT_RESPONCE=$?
}

#function exit_view () {
#       dialog --title "" \
#                       --backtitle "$BACKTITLE" \
#                       --cancel-label "No" \
#                       --yesno "Want to save before exiting?" 5 70
#       EXIT_RESPONCE=$?
#clear
#}

#################################################################
#																#
#						COMPILE FUNCTION						#
#																#
#################################################################

function check_board_type () {
	echo ""
	if [ "${BOARD}" == "${type_Smarc}" ]; then
		echo "Board type selected: Smarc module"
		SUFFIX=${SUFFIX}-imx8mq-c12
		CONFIG_BOARD="CONFIG_TARGET_SECO_IMX8MQ_C12=y"
	elif [ "${BOARD}" == "${type_Sbc}" ]; then
		echo "Board type selected: Single board computer"
		SUFFIX=${SUFFIX}-imx8mq-c20
		CONFIG_BOARD="CONFIG_TARGET_SECO_IMX8MQ_C20=y"
	elif [ "${BOARD}" == "${type_Q7}" ]; then
		echo "Board type selected: Q7 Module C25"
		SUFFIX=${SUFFIX}-imx8mq-c25
		CONFIG_BOARD="CONFIG_TARGET_SECO_IMX8MQ_C25=y"
	else
		echo "ERROR: wrong board type selected"
		exit 0
	fi
}

function check_cpu_type () {
	echo ""
    if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
        #echo "make mx8mq_seco_config"
		SOC_FAMILY="mx8:mx8m:mx8mq:"
		CONFIG_CPU="CONFIG_SECOIMX8M=y"
    else
		echo "ERROR: No CPU Type selected "
    fi
}
		
function conf_cpu_type () {
	echo ""
        if [ "${BOARD}" == "${type_Smarc}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
			UBOOT_BOARD_CONF="seco_imx8mq_c12_defconfig"
	    fi
	elif [ "${BOARD}" == "${type_Sbc}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
			UBOOT_BOARD_CONF="seco_imx8mq_c20_defconfig"
	    fi
	elif [ "${BOARD}" == "${type_Q7}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
			UBOOT_BOARD_CONF="seco_imx8mq_c25_defconfig"
	    fi
        fi
}

function conf_uboot_dtb () {
	echo ""
	 if [ "${BOARD}" == "${type_Smarc}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
			UBOOT_DTB_NAME="seco-imx8mq-c12.dtb"
	    fi
	elif [ "${BOARD}" == "${type_Sbc}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
			UBOOT_DTB_NAME="seco-imx8mq-c20.dtb"
	    fi
	elif [ "${BOARD}" == "${type_Q7}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
			UBOOT_DTB_NAME="seco-imx8mq-c25.dtb"
	    fi
        fi
}

function check_dtb () {

	echo ""
        if [ "${BOARD}" == "${type_Smarc}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                  DTB_CONF="seco/seco-imx8mq-c12.dtb"
		  DTBO_CONF="seco/overlays/seco-imx8mq-c12-dual-display.dtbo seco/overlays/seco-imx8mq-c12-lcdif-sn65dsi84.dtbo seco/overlays/seco-imx8mq-c12-wilink.dtbo seco/overlays/seco-imx8mq-c12-dcss-sn65dsi84.dtbo seco/overlays/seco-imx8mq-c12-can-rtc.dtbo"
            fi
 	elif [ "${BOARD}" == "${type_Sbc}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                  DTB_CONF="seco/seco-imx8mq-c20.dtb"
		  DTBO_CONF="seco/overlays/seco-imx8mq-c20-wilink.dtbo seco/overlays/seco-imx8mq-c20-dcss-sn65dsi84.dtbo"
            fi
	elif [ "${BOARD}" == "${type_Q7}" ]; then
            if [ "${CPU_TYPE}" == "${type_cpu_qdl}" ]; then
                  DTB_CONF="seco/seco-imx8mq-c25.dtb"
		  DTBO_CONF="seco/overlays/seco-imx8mq-c25-dual-display.dtbo seco/overlays/seco-imx8mq-c25-lcdif-sn65dsi84.dtbo seco/overlays/seco-imx8mq-c25-dcss-sn65dsi84.dtbo seco/overlays/seco-imx8mq-c25-dcss-sn65dsi86.dtbo"
            fi
        fi
}

function create_machine() {

 export ARCH=arm64
        export CROSS_COMPILE=$COMPILER_PATH

        SUFFIX=""
        #N.B. don't change this calling order
        check_board_type
        check_cpu_type
	conf_cpu_type
	conf_uboot_dtb
	check_dtb

MACHINE_CONF_NAME=`echo "seco${SUFFIX}.conf" | tr '[:upper:]' '[:lower:]'`
MACHINE_NAME=`echo "seco${SUFFIX}" | tr '[:upper:]' '[:lower:]'`

mkdir -p $PATH_MACHINE
#echo $MACHINE_NAME
echo ""
echo "#@TYPE: Machine" > $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@NAME: seco${SUFFIX}" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@SOC: i.MX8MQ" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@DESCRIPTION: Machine configuration for seco${SUFFIX}"  >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "#@MAINTAINER: Mathanraj Murugan <mathan.raj@seco.com>" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "MACHINEOVERRIDES =. \"${SOC_FAMILY}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "require conf/machine/include/imx-base.inc" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "require conf/machine/include/arm/arch-arm64.inc" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "MACHINE_FEATURES += \" pci wifi bluetooth optee qca6174\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "IMAGE_BOOTFILES_DEPENDS += \" imx-m4-demos:do_deploy\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "IMAGE_BOOTFILES += \"imx8mq_m4_TCM_hello_world.bin imx8mq_m4_TCM_rpmsg_lite_pingpong_rtos_linux_remote.bin imx8mq_m4_TCM_rpmsg_lite_str_echo_rtos.bin\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/kernel ?= \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/kernel_mx8mq = \"linux-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "KERNEL_DEVICETREE ?= \"${DTB_CONF}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "KERNEL_OVERLAYDEVICETREE += \"${DTBO_CONF}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_u-boot = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_u-boot_mx8mq = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/bootloader = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PREFERRED_PROVIDER_virtual/bootloader_mx8mq = \"u-boot-seco\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_CONFIG ??= \"sd\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_CONFIG[sd] = \"${UBOOT_BOARD_CONF},sdcard\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "SPL_BINARY = \"spl/u-boot-spl.bin\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
if [ "${BOARD}" == "${type_Smarc}" ]; then
	echo "DDR_FIRMWARE_NAME = \"lpddr4_pmu_train_1d_imem.bin lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_2d_imem.bin lpddr4_pmu_train_2d_dmem.bin\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME	
	echo "UBOOT_DTB_NAME = \"${UBOOT_DTB_NAME}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "IMXBOOT_TARGETS = \"flash_evk\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "IMAGE_BOOTLOADER = \"imx-boot\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
elif [ "${BOARD}" == "${type_Sbc}" ]; then
	echo "DDR_FIRMWARE_NAME = \"ddr3_dmem_1d.bin ddr3_imem_1d.bin\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "UBOOT_DTB_NAME = \"${UBOOT_DTB_NAME}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "IMXBOOT_TARGETS = \"flash_ddr3l_val\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "IMAGE_BOOTLOADER = \"imx-boot\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
elif [ "${BOARD}" == "${type_Q7}" ]; then
	echo "DDR_FIRMWARE_NAME = \"ddr4_dmem_1d.bin ddr4_imem_1d.bin ddr4_dmem_2d.bin ddr4_imem_2d.bin\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "UBOOT_DTB_NAME = \"${UBOOT_DTB_NAME}\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "IMXBOOT_TARGETS = \"flash_ddr4_val\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
	echo "IMAGE_BOOTLOADER = \"imx-boot\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
else
	echo "Not selected machine"
	exit 0
fi
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "SERIAL_CONSOLE = \"115200 ttymxc0\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "BOOT_SPACE = \"65536\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "LOADADDR = \"\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_SUFFIX = \"bin\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "UBOOT_MAKE_TARGET = \"\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "IMX_BOOT_SEEK = \"33\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "OPTEE_BIN_EXT = \"8mq\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "PLATFORM_FLAVOR_seco${SUFFIX} = \"mx8mqevk\"" >> $PATH_MACHINE/$MACHINE_CONF_NAME
echo "" >> $PATH_MACHINE/$MACHINE_CONF_NAME

echo "To begin yocto building launch :"
echo "$ DISTRO=$BACKEND MACHINE=$MACHINE_NAME source seco-setup-release.sh -b <build dir>"
echo ""
echo ""
echo "and then launch (for example):"
echo "$ bitbake fsl-image-qt5"





}

function compile () {

	create_machine
	DISTRO=$BACKEND MACHINE=$MACHINE_NAME source seco-setup-release.sh -b $BUILD_DIR
	bitbake $IMAGE_TYPE
}

#################################################################
#																#
#																#
#################################################################

function help_view () {
	echo "SECO Yocto Configurator"
	echo "Usage: $0 [-c for configuration option]"
	echo
}

set_from_ConfFile
while getopts ":m:b:p:dch" optname; do
	case "$optname" in
		"c") while [[ $EXIT -ne 1 ]]; do
			main_view
			SEL_ITEM=$SELECTION
			case "$SELECTION" in
				"1") board_type_view;;
				"2") cpu_type_view;;
				"3") compile_view;;
				"4") yocto_backend_view;;
				"5") yocto_image_type_view;;
				  *) echo "" ;;
			esac
		done
		exit_view
		case "${EXIT_RESPONCE}" in
			  "0") set_ConfFile; clear; echo "Configuration saved!"; create_machine;;
			  "1") clear; echo "Configuration not saved!";;
			  "3") set_ConfFile; clear; echo "Configuration saved!"; compile;;
			"255") clear;  echo "Configuration not saved!";;
			*) clear;
		esac
		exit 0;;

		h) help_view
			 exit 0;;	
		*) echo "ERROR: option not valid!"
                         help_view
                         exit 1;;
	esac
done

#if no any option is present, the compilation start directly
compile
