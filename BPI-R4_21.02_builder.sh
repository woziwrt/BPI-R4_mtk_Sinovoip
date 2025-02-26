#!/bin/bash
#**************************************
#  THIS IS EXTREMELY IMPORTANT !!!!!!
#**************************************

# Build environment for ubuntu 18.04 Only on this enwironment is possible to build mtk conglomerate !!!

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

git clone --branch openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git mac80211_package || true 
#cd mac80211_package; git checkout 92e020b50f04535009c91aa708bdb7598f1d9d4a; cd -;	#Fix patch fail due to mt76 update.
#cd mac80211_package; git checkout f719c8552723f0525ce76ba44a75e45ecbe2e7a9; cd -;	#MAC80211 v6.12 ok, ok 2	
cd mac80211_package; git checkout 28bde50c1d5236ad890ef2fe3a0e89f731ee4421; cd -;	#MP 4.0 release


git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
#cd mtk-openwrt-feeds; git checkout 3fd918c2bab95a98cc3458f60ba7e295bc9b6f58; cd -;	#Fix patch fail due to mt76 update.
#cd mtk-openwrt-feeds; git checkout 5c7af0e6030cb6d32ea99b6970f5ec0768599ac8; cd -;	#ok 2
#cd mtk-openwrt-feeds; git checkout b046effcce3869ab95bd23fb674cfedaf626d3f5; cd -;	#ok
cd mtk-openwrt-feeds; git checkout be639389a047a00cca671bf1a06b5848d054adbd; cd -;	#MP 4.0 release

\cp -rf mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release openwrt
cd openwrt; mv autobuild_5.4_mac80211_release autobuild

echo "src-git mtk_openwrt_feed https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds" >> feeds.conf.default

\cp -r my_files/feeds.conf.default-21.02 openwrt/autobuild/feeds.conf.default-21.02

bash autobuild/mt7988_wifi7_mac80211_mlo/lede-branch-build-sanity.sh mt7996

# Further Build (After 1st full build
# cd openwrt
# export GIT_SSL_NO_VERIFY=1
sed -i 's/src-git mtk_openwrt_feed https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds/src-git mtk_openwrt_feed https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds^be63938/' openwrt/feeds.conf.default

# ./scripts/feeds update -a
# make V=s PKG_HASH=skip PKG_MIRROR_HASH=skip