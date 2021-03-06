#!/usr/bin/env bash
#
# Copyright 2016 - The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TOOLS_DIR=$(realpath $(dirname $0))
LTP_ANDROID_DIR=$(realpath $TOOLS_DIR/..)
LTP_ROOT=$(realpath $LTP_ANDROID_DIR/..)
CUSTOM_CFLAGS_PATH=$TOOLS_DIR/custom_cflags.json
OUTPUT_MK=$LTP_ANDROID_DIR/Android.ltp.mk
OUTPUT_PLIST=$LTP_ANDROID_DIR/ltp_package_list.mk
OUTPUT_BP=$LTP_ROOT/gen.bp

if ! [ -f $LTP_ROOT/include/config.h ]; then
  echo "LTP has not been configured."
  echo "Executing \"cd $LTP_ROOT; make autotools; ./configure\""
  cd $LTP_ROOT
  make autotools
  $LTP_ROOT/configure
fi

cd $TOOLS_DIR

case $1 in
  -u|--update)
    echo "Update option enabled. Regenerating..."
    rm -rf *.dump
    ./dump_make_dryrun.sh
    ;;
  -h|--help)
    echo "Generate Android.ltp.mk / gen.bp."
    echo "Please use \"--update\" option to update and regenerate Android.ltp.mk / gen.bp."
    exit 0
    ;;
esac

if ! [ -f $TOOLS_DIR/make_dry_run.dump ]; then
  echo "LTP make dry_run not dumped. Dumping..."
  ./dump_make_dryrun.sh
fi

cat $LTP_ANDROID_DIR/AOSP_license_text.txt > $OUTPUT_MK
echo "" >> $OUTPUT_MK
echo "# This file is autogenerated by $(basename $0)" >> $OUTPUT_MK
echo "" >> $OUTPUT_MK

cat $LTP_ANDROID_DIR/AOSP_license_text.txt > $OUTPUT_PLIST
echo "" >> $OUTPUT_PLIST
echo "# This file is autogenerated by $(basename $0)" >> $OUTPUT_PLIST
echo "" >> $OUTPUT_PLIST

sed "s%#%//%" $LTP_ANDROID_DIR/AOSP_license_text.txt > $OUTPUT_BP
echo "" >> $OUTPUT_BP
echo "// This file is autogenerated by $(basename $0)" >> $OUTPUT_BP
echo "" >> $OUTPUT_BP

python android_build_generator.py --ltp_root $LTP_ROOT --output_mk_path $OUTPUT_MK \
    --output_bp_path $OUTPUT_BP --output_plist_path $OUTPUT_PLIST \
    --custom_cflags_file $CUSTOM_CFLAGS_PATH
