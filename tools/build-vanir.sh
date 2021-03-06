#!/bin/bash

usage()
{
	echo ""
	echo "Usage:"
	echo "  build-vanir.sh [options] device"
	echo ""
	echo "  Options:"
	echo "    -c  Clean before build"
	echo "    -d  Use dex optimizations"
	echo "    -j# Set jobs"
	echo "    -s  Sync before build"
	echo ""
	echo "  Example:"
	echo "    ./build-vanir.sh -c mako"
	echo ""
	exit 1
}

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldylw=${txtbld}$(tput setaf 3) #  yellow
bldblu=${txtbld}$(tput setaf 4) #  blue
bldppl=${txtbld}$(tput setaf 5) #  purple
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

if [ ! -d ".repo" ]; then
	echo "No .repo directory found.  Is this an Android build tree?"
	exit 1
fi
if [ ! -d "vendor/vanir" ]; then
	echo "No vendor/vanir directory found."
	exit 1
fi

# get OS (linux / Mac OS x)
IS_DARWIN=$(uname -a | grep Darwin)
if [ -n "$IS_DARWIN" ]; then
	CPUS=$(sysctl hw.ncpu | awk '{print $2}')
	DATE=gdate
else
	CPUS=$(grep "^processor" /proc/cpuinfo | wc -l)
	DATE=date
fi

export USE_CCACHE=1

opt_clean=0
opt_dex=0
opt_jobs="$CPUS"
opt_sync=0

while getopts "cdj:s" opt; do
	case "$opt" in
	c) opt_clean=1 ;;
	d) opt_dex=1 ;;
	j) opt_jobs="$OPTARG" ;;
	s) opt_sync=1 ;;
	*) usage
	esac
done
shift $((OPTIND-1))
if [ "$#" -ne 1 ]; then
	usage
fi
device="$1"

# get current version
eval $(grep "^VANIR_VERSION_" vendor/vanir/products/common.mk | sed 's/ *//g')
VERSION="$Vanir_Version"

# get time of startup
t1=$($DATE +%s)

echo -e "${cya}Building ${bldgrn}P ${bldppl}A ${bldblu}C ${bldylw}v$VERSION ${txtrst}"

# Vanir device dependencies
echo -e ""
echo -e "${bldblu}Looking for Vanir product dependencies${txtrst}${cya}"
vendor/vanir/tools/getdependencies.py "$device"
echo -e "${txtrst}"

if [ "$opt_clean" -ne 0 ]; then
	make clean >/dev/null
fi


# sync with latest sources
if [ "$opt_sync" -ne 0 ]; then
	echo -e ""
	echo -e "${bldblu}Fetching latest sources${txtrst}"
	repo sync -j"$opt_jobs"
	echo -e ""
fi

rm -f out/target/product/$device/obj/KERNEL_OBJ/.version

# setup environment
echo -e "${bldblu}Setting up environment ${txtrst}"
. build/envsetup.sh

# Remove system folder (this will create a new build.prop with updated build time and date)
rm -rf out/target/product/$device/system/

# lunch device
echo -e ""
echo -e "${bldblu}Lunching device ${txtrst}"
lunch "vanir_$device-userdebug";

echo -e ""
echo -e "${bldblu}Starting compilation ${txtrst}"

# start compilation
if [ "$opt_dex" -ne 0 ]; then
	export WITH_DEXPREOPT=true
fi
mka -j"$opt_jobs" bacon
echo -e ""

# finished? get elapsed time
t2=$($DATE +%s)

tmin=$(( (t2-t1)/60 ))
tsec=$(( (t2-t1)%60 ))

echo "${bldgrn}Total time elapsed:${txtrst} ${grn}$tmin minutes $tsec seconds${txtrst}"
