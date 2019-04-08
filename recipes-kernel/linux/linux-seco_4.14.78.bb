# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017 NXP
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Linux Kernel provided and supported by SECO"
DESCRIPTION = "Linux Kernel provided and supported by SECO based on NXP"


require recipes-kernel/linux/linux-imx.inc
#require recipes-kernel/linux/linux-imx-src.inc
#require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

PV = "4.14.78"

SCMVERSION = "n"
SRC_URI = "git://secogit.seco.com/imx8/linux-kernel-4-14-78-imx8mq-1-0-0.git;protocol=https;user=Mathan_Murugan:mathan123 file://defconfig" 

SRCREV = "${AUTOREV}"

KERNEL_DEVICETREE = " \
	seco/seco-imx8mq-c12.dtb \
	seco/seco-imx8mq-c20.dtb \
	seco/seco-imx8mq-c25.dtb \	
	\
	seco/overlays/seco-imx8mq-c12-dual-display.dtbo \
	seco/overlays/seco-imx8mq-c12-lcdif-sn65dsi84.dtbo \
	seco/overlays/seco-imx8mq-c12-wilink.dtbo \
	seco/overlays/seco-imx8mq-c12-dcss-sn65dsi84.dtbo \
	seco/overlays/seco-imx8mq-c12-can-rtc.dtbo \
	seco/overlays/seco-imx8mq-c25-dual-display.dtbo \
	seco/overlays/seco-imx8mq-c25-lcdif-sn65dsi84.dtbo \
	seco/overlays/seco-imx8mq-c25-dcss-sn65dsi84.dtbo \
	seco/overlays/seco-imx8mq-c25-dcss-sn65dsi86.dtbo \
	seco/overlays/seco-imx8mq-c20-wilink.dtbo \
	seco/overlays/seco-imx8mq-c20-dcss-sn65dsi84.dtbo \
"
