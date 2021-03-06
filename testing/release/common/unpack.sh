#!/bin/bash
unpack_build () {
    unpack_platform="$1"
    dir_name="$2"
    pkg_file="$3"
    locale=$4

    mkdir -p $dir_name
    pushd $dir_name > /dev/null
    case $unpack_platform in
        mac|mac-ppc|Darwin_ppc-gcc|Darwin_Universal-gcc3)
            cd ../
            mkdir -p mnt
            echo "mounting $pkg_file"
            echo "y" | PAGER="/bin/cat"  hdiutil attach -quiet -puppetstrings -noautoopen -mountpoint ./mnt "$pkg_file" > /dev/null
            rsync -a ./mnt/* $dir_name/ 
            hdiutil detach mnt > /dev/null
            cd $dir_name
            ;;
        win32|WINNT_x86-msvc)
            7z x ../"$pkg_file" > /dev/null
            if [ -d localized ]
            then
              mkdir bin/
              cp -rp nonlocalized/* bin/
              cp -rp localized/*    bin/
              if [ $(find optional/ | wc -l) -gt 1 ]
              then 
                cp -rp optional/*     bin/
              fi
            else
              for file in *.xpi
              do
                unzip -o $file > /dev/null
              done
              unzip -o ${locale}.xpi > /dev/null
            fi
            ;;
        linux-i686|linux|Linux_x86-gcc|Linux_x86-gcc3)
            if `echo $pkg_file | grep -q "tar.gz"`
            then
                tar xfz ../"$pkg_file" > /dev/null
            elif `echo $pkg_file | grep -q "tar.bz2"`
            then
                tar xfj ../"$pkg_file" > /dev/null
            else
                echo "Unknown package type for file: $pkg_file"
                exit 1
            fi
            ;;
    esac

    popd > /dev/null

}
