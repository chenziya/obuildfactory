#!/bin/bash
#

export OBF_PROJECT_NAME=openjdk8-javafx
TAG_FILTER=jdk8

#
# Safe Environment
#
LC_ALL=C
LANG=C
LANGUAGE=C
export LC_ALL
export LANG
export LANGUAGE

#
# Prepare Drop DIR
#
if [ -z "$OBF_DROP_DIR" ]; then
  export OBF_DROP_DIR=`pwd`/OBF_DROP_DIR;
fi

#
# Provide Main Variables to Scripts
#
if [ -z "$OBF_BUILD_PATH" ]; then
  export OBF_BUILD_PATH=`pwd`/obuildfactory/$OBF_PROJECT_NAME/linux;
fi

echo  $OBF_BUILD_PATH;

if [ -z "$OBF_SOURCES_PATH" ]; then
  export OBF_SOURCES_PATH=`pwd`/sources/$OBF_PROJECT_NAME
  mkdir -p `pwd`/sources
fi

if [ -z "$OBF_WORKSPACE_PATH" ]; then
  export OBF_WORKSPACE_PATH=`pwd`
fi

if [ ! -d $OBF_SOURCES_PATH ]; then
  hg clone http://hg.openjdk.java.net/jdk8u/jdk8u $OBF_SOURCES_PATH
  hg clone http://hg.openjdk.java.net/openjfx/8u-dev/rt $OBF_SOURCES_PATH-openjfx
  cd $OBF_SOURCES_PATH-openjfx
  hg revert -a
  cd $DIR
fi	
	
pushd $OBF_SOURCES_PATH >>/dev/null

# 
# Updating sources for Mercurial repo
#
sh ./get_source.sh

#
# Update sources to provided tag XUSE_TAG (if defined)
#
if [ ! -z "$XUSE_TAG" ]; then
  echo "using tag $XUSE_TAG"
  sh ./make/scripts/hgforest.sh update $XUSE_TAG
fi

if [ ! -z "$XUSE_JFX_TAG" ]; then
  echo "using javafx tag $XUSE_JFX_TAG"
  DIR=`pwd`
  cd $OBF_SOURCES_PATH-openjfx
  hg checkout $XUSE_JFX_TAG
  cd $DIR
fi

popd >>/dev/null

#
# Mercurial repositories updated, call Jenkins job now
#
$OBF_BUILD_PATH/jenkins-job.sh
