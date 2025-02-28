#!/bin/bash
#**************************************
#  THIS IS EXTREMELY IMPORTANT !!!!!!
#**************************************

# Build environment - ubuntu 18.04 - THE ONLY ONE FUNCTIONAL ENVIRONMENT !!!

# sudo apt-get update
# sudo apt-get install -y build-essential ccache ecj fastjar file g++ gawk \
# gettext git java-propose-classpath libelf-dev libncurses5-dev \
# libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
# python3-distutils python3-setuptools python3-dev rsync subversion \
# swig time xsltproc zlib1g-dev uuid-dev gcc-aarch64-linux-gnu clang-6.0 

#=============================================================================

rm -rf openwrt
rm -rf mtk-openwrt-feeds
rm -rf mac80211_package

export GIT_SSL_NO_VERIFY=1

git clone --branch openwrt-21.02 https://git.openwrt.org/openwrt/openwrt.git || true
cd openwrt; git checkout 4a1d8ef55cbf247f06dae8e958eb8eb42f1882a5; cd -;

#git clone --branch master https://git.openwrt.org/openwrt/openwrt.git mac80211_package || true
git clone --branch openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git mac80211_package || true
#cd mac80211_package; git checkout 68bf4844a1cbc9f404f6e93b70a2657e74f1dce9; cd -;		
#cd mac80211_package; git checkout 0e672e980650d8f890e620d1c359b78ef3a524d2; cd -; 	#Add thermal throttling support
#cd mac80211_package; git checkout 92e020b50f04535009c91aa708bdb7598f1d9d4a; cd -;	#Fix patch fail due to mt76 update.
#cd mac80211_package; git checkout f719c8552723f0525ce76ba44a75e45ecbe2e7a9; cd -;	#MAC80211 v6.12 ok, ok 2	
#cd mac80211_package; git checkout 28bde50c1d5236ad890ef2fe3a0e89f731ee4421; cd -;	#MP 4.0 release
#cd mac80211_package; git checkout a9107e74a6eabf3763a81ce6dc04d54497de25eb; cd -;	#ucode
cd mac80211_package; git checkout 315facfce6dc13d6ec1993db1e16532cadcfcaaa; cd -;

git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
#cd mtk-openwrt-feeds; git checkout 42df09d4cf568c795e71427668fae0eea4f112c5; cd -;
#cd mtk-openwrt-feeds; git checkout fe2594cc96cf7e9f2d7a242a0d3a589c9d490f18; cd -;	#ucode
#cd mtk-openwrt-feeds; git checkout bc01876634c05e375d5471a7f096ab5e30a7821d; cd -;	#Add thermal throttling support
#cd mtk-openwrt-feeds; git checkout 3fd918c2bab95a98cc3458f60ba7e295bc9b6f58; cd -;	#Fix patch fail due to mt76 update.
#cd mtk-openwrt-feeds; git checkout 5c7af0e6030cb6d32ea99b6970f5ec0768599ac8; cd -;	#ok 2
#cd mtk-openwrt-feeds; git checkout b046effcce3869ab95bd23fb674cfedaf626d3f5; cd -;	#ok
#cd mtk-openwrt-feeds; git checkout be639389a047a00cca671bf1a06b5848d054adbd; cd -;	#MP 4.0 release
#cd mtk-openwrt-feeds; git checkout effe5b41b0fff8336ee6a0b10abdc1194e48b41a; cd -;	#readme old
cd mtk-openwrt-feeds; git checkout 612001dcebc0385f0cfe5cc5ccbf5dfd640dd4e1; cd -;

sed -i 's/DEPENDS:=+netifd +ucode +ucode-mod-nl80211 +ucode-mod-rtnl +ucode-mod-ubus +ucode-mod-uci +ucode-mod-digest/DEPENDS:=+netifd +ucode +ucode-mod-nl80211 +ucode-mod-rtnl +ucode-mod-ubus +ucode-mod-uci/' openwrt/package/network/config/wifi-scripts/Makefile
sed -i 's/DEPENDS:=+netifd +ucode +ucode-mod-nl80211 +ucode-mod-rtnl +ucode-mod-ubus +ucode-mod-uci +ucode-mod-digest/DEPENDS:=+netifd +ucode +ucode-mod-nl80211 +ucode-mod-rtnl +ucode-mod-ubus +ucode-mod-uci/' mac80211_package/package/network/config/wifi-scripts/Makefile


\cp -rf mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release openwrt
cd openwrt; mv autobuild_5.4_mac80211_release autobuild

echo "src-git mtk_openwrt_feed https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds" >> feeds.conf.default

\cp -r my_files/feeds.conf.default-21.02 openwrt/autobuild/feeds.conf.default-21.02

bash autobuild/mt7988_wifi7_mac80211_mlo/lede-branch-build-sanity.sh mt7996

exit 0

# My brutal modification of mtk default images building :-)

\cp -r my_files/sdcard_basic/. openwrt/staging_dir/target-aarch64_cortex-a53_musl/image/
\cp -r my_files/uboot-envtools/Makefile openwrt/package/boot/uboot-envtools/Makefile
\cp -r my_files/include/image.mk openwrt/include/image.mk
\cp -r my_files/image/Makefile openwrt/target/linux/mediatek/image/Makefile
\cp -r my_files/image/mt7988.mk openwrt/target/linux/mediatek/image/mt7988.mk
\cp -r my_files/image/make_bpi-r4_bundle_image.sh openwrt/target/linux/mediatek/image/make_bpi-r4_bundle_image.sh
\cp -r my_files/image/make_bpi-r4_bundle_nandimage.sh openwrt/target/linux/mediatek/image/make_bpi-r4_bundle_nandimage.sh

rm -rf openwrt/bin/targets/mediatek/mt7988
cd openwrt
#\cp -r ../my_files/config ./.config

export GIT_SSL_NO_VERIFY=1
sed -i 's/src-git mtk_openwrt_feed https:\/\/git01.mediatek.com\/openwrt\/feeds\/mtk-openwrt-feeds/src-git mtk_openwrt_feed https:\/\/git01.mediatek.com\/openwrt\/feeds\/mtk-openwrt-feeds^612001d/' feeds.conf.default
./scripts/feeds update -a

#make menuconfig

make V=s PKG_HASH=skip PKG_MIRROR_HASH=skip