#! /bin/sh

print_usage() {
    echo "Usage: ${CMD_NAME} -?|[-a|-d] pkgname [-c] filename [filename ...]"
    echo "Options: "
    echo "  -?: Show this message."
    echo "  -a pkgname: Add \"pkgname\" package to list."
    echo "  -d pkgname: Delete \"pkgname\" package from list."
    echo "  -c: Add package as comment (for later enablement)."
    echo "  filename: Filename for the list of pakcages."
}

ADD_PKG=0
DELETE_PKG=0
COMMENTED=0

CMD_NAME=$(basename "$0")

while getopts ?a:d:c OPT; do
    case ${OPT} in
    "?")
        print_usage ;;
    "a")
        ADD_PKG=1
        PKG_NAME=${OPTARG} ;;
    "d")
        DELETE_PKG=1
        PKG_NAME=${OPTARG} ;;
    "c")
        COMMENTED=1 ;;
    esac
done

shift $(($OPTIND - 1))
TARGET_FILES=$*

for i in ${TARGET_FILES}; do
    tmplist=$(mktemp "${TMPDIR}/managepkglist.XXXXXX")
    # remove package name if already there (commented or not)
    sort "${i}" | uniq | \
        grep -v -E -e "^(# )*${PKG_NAME}$" > "${tmplist}"
    # re-add package name
    if [ ${ADD_PKG} -eq 1 ]; then
        if [ ${COMMENTED} -eq 1 ]; then
            echo -n "# " >> "${tmplist}"
        fi
        echo "${PKG_NAME}" >> "${tmplist}"
        sort "${tmplist}" | uniq > "${i}"
    else # if [ ${DELETE_PKG} -eq 1 ]; then
        mv -f "${tmplist}" "${i}"
    fi
    rm -f "${tmplist}"
done

exit 0
