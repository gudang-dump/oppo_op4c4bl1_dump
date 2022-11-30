#!/system/bin/sh

#SPECIAL_ENGINEERING_RES_PATH=/oppo_engineering/splash_log
#SPECIAL_CUSTOM_RES_PATH=/oppo_custom/splash_log
#SPECIAL_VERSION_RES_PATH=/oppo_version/splash_log


SPECIAL_ENGINEERING_RES_PATH=$OPPO_ENGINEER_ROOT/splash_logo
SPECIAL_CUSTOM_RES_PATH=$OPPO_CUSTOM_ROOT/splash_logo
SPECIAL_VERSION_RES_PATH=$OPPO_VERSION_ROOT/splash_logo

CLGEN_BIN_FILE_PATH=/system/bin/CLGen
SPLASH_LOGO_BLOCK_LOCATION=/dev/block/by-name/logo

CHECKSUM_PROP=persist.sys.cust_logo_checksum
DISPLAYMETRICS_PROP=persist.sys.oppo.displaymetrics

#Zhijun.Ye@PSW.MM.Display.Logo,2020/1/4, add for custom splash logo
SPECIAL_VERSION_LOGO_PATH=/system/etc
SPECIAL_VERSION_LOGO_PROP=ro.commonsoft.logo

special_logo_file=""

function check_md5sum {
    local src_file=$1

    if [ -f $src_file ];then
      md5=$(md5sum $src_file |cut -b 1-32)

      if [ x"$(getprop $CHECKSUM_PROP)" != x"$md5" ];then
          setprop $CHECKSUM_PROP "$md5"
      else
          echo "try to override the logo with previous image, exit"
          exit 1
      fi
    else
       echo "None special logo file been found, nothing to do, exit"
       exit 1
    fi

}

function do_exec {
    local src_file=$1

    if [  ! -x ${CLGEN_BIN_FILE_PATH} ];then
       echo "GLGen can not been executed, exit!"
       exit 1
    fi

    ${CLGEN_BIN_FILE_PATH} ${src_file} ${SPLASH_LOGO_BLOCK_LOCATION}
}

function choose_special_logo_file {
    local lcm_height=`getprop ${DISPLAYMETRICS_PROP}|cut -d "," -f 2`
    echo "lcm_height: ${lcm_height}"
    #Zhijun.Ye@PSW.MM.Display.Logo,2020/1/4, add for custom splash logo
    local special_version_logo_file=`getprop ${SPECIAL_VERSION_LOGO_PROP}`
    echo "special_version_logo_file: ${special_version_logo_file}"

    if [[ x"${special_logo_file}" == x"" && -d ${SPECIAL_ENGINEERING_RES_PATH} ]];then
        if [ -d ${SPECIAL_ENGINEERING_RES_PATH}/${lcm_height} ];then
           for bmp_file in `find ${SPECIAL_ENGINEERING_RES_PATH}/${lcm_height} -name "*.bmp"`;do
               special_logo_file=${bmp_file}
               break
           done
        fi
    fi

    if [[ x"${special_logo_file}" == x"" && -d ${SPECIAL_CUSTOM_RES_PATH} ]];then
        if [ -d ${SPECIAL_CUSTOM_RES_PATH}/${lcm_height} ];then
            for bmp_file in `find ${SPECIAL_CUSTOM_RES_PATH}/${lcm_height} -name "*.bmp"`;do
                special_logo_file=${bmp_file}
                break
            done
        fi
    fi

    if [[ x"${special_logo_file}" == x"" && -d ${SPECIAL_VERSION_RES_PATH} ]];then
        if [ -d ${SPECIAL_VERSION_RES_PATH}/${lcm_height} ];then
            for bmp_file in `find ${SPECIAL_VERSION_RES_PATH}/${lcm_height} -name "*.bmp"`;do
                special_logo_file=${bmp_file}
                break
            done
        fi
    fi

    #Zhijun.Ye@PSW.MM.Display.Logo,2020/1/4, add for custom splash logo
    if [[ x"${special_logo_file}" == x"" && x"${special_version_logo_file}" != x"" ]];then
        if [ -f ${SPECIAL_VERSION_LOGO_PATH}/${special_version_logo_file} ];then
            special_logo_file=${SPECIAL_VERSION_LOGO_PATH}/${special_version_logo_file}
        fi
    fi
}

function main {
    echo "do_splash_logo start!"

    choose_special_logo_file

    echo "choose_special_logo_file end!"

    echo ${special_logo_file}

    check_md5sum ${special_logo_file}

    echo "check_md5sum end!"

    do_exec ${special_logo_file}

    echo "do_splash_logo end!"
}

main
