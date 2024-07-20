#!/usr/bin/env bash

#
# distid.sh - Identify Distro
#
# This source-code is part of Windows XP stuff for XFCE:
# <<https://www.oddmatics.uk>>
#
# Author(s): Rory Fewell <roryf@oddmatics.uk>
#

#
# MAIN SCRIPT
#

# Probe for package managers to try and determine what distro we're
# on
#
# NOTE: Since #253, Debian/dpkg is checked last, because potentially users of
#       other distros might have dpkg installed which throws off detection
#
#       I think it's unlikely the other package managers will be installed on
#       different distros... mainly just dpkg
#
# NOTE from Julia: No! That did not solve jack! I'm sitting here trying to work 
#                  around the exact opposite problem! I'm on a Debian-based distro
#                  which has also rpm installed (MX-Linux). How are you gonna detect
#                  that, genius? You and i both know that the we will have to inevitably
#                  face the neofetch source code. But until then here's my workaround.

# Added distid.txt to force a specific distro
# in case this script misidentifies the distro
# Format: DIST_ID=<distro> (e.g. DIST_ID=archpkg)
#         DIST_ID_EXT=<distro> (e.g. DIST_ID_EXT=std, optional)
if [ -f "distid.txt" ]; then

    while IFS= read -r line
    do
        case $line in
            DIST_ID=*)
                export DIST_ID="${line#*=}"
                ;;
            DIST_ID_EXT=*)
                export DIST_ID_EXT="${line#*=}"
                ;;
        esac
    done < "distid.txt"
    
    if [ -z "$DIST_ID" ]; then
        echo "Malformed distid.txt"
        return 1
    fi

    if [ -z "$DIST_ID_EXT" ]; then
        export DIST_ID_EXT="std"
    fi

    return 0
fi

# Check Arch Linux
#
which pacman >/dev/null 2>&1

if [[ $? -eq 0 ]]
then
    export DIST_ID="archpkg"
    export DIST_ID_EXT="std"
    return 0
fi

# Check Alpine Linux
#
which apk >/dev/null 2>&1

if [[ $? -eq 0 ]]
then
    export DIST_ID="apk"
    export DIST_ID_EXT="std"
    return 0
fi

# Check FreeBSD
#
which pkg >/dev/null 2>&1

if [[ $? -eq 0 ]]
then
    export DIST_ID="bsdpkg"
    export DIST_ID_EXT="std"
    return 0
fi

# Check Red Hat
#
which rpm >/dev/null 2>&1

if [[ $? -eq 0 ]]
then
    export DIST_ID="rpm"
    export DIST_ID_EXT="std"
    return 0
fi

# Check Void Linux
#
which xbps-create >/dev/null 2>&1

if [[ $? -eq 0 ]]
then
    export DIST_ID="xbps"

    # This might be a rubbish way to determine glibc vs. musl, if it does suck
    # then someone needs to whinge and then I'll have to come up with something
    # better
    #
    find /usr/lib -iname "*ld-musl*" | read

    if [[ $? -eq 0 ]]
    then
        export DIST_ID_EXT="musl"
    else
        export DIST_ID_EXT="glibc"
    fi

    return 0
fi

# Check Debian
#
which dpkg >/dev/null 2>&1

if [[ $? -eq 0 ]]
then
    export DIST_ID="deb"
    export DIST_ID_EXT="std"
    return 0
fi

# Nothing else to probe, it's over!
#
echo "Unsupported distribution."
return 1
