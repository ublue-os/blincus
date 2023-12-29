prefix() {
    # find the path where `blincus` is located and use that as the prefix
    # default to /usr/local if not found
    local prefix
    prefix=$(dirname "$(dirname "$(command -v blincus)")")
    [ -z "${prefix}" ] && prefix="/usr/local"
    echo "${prefix}"
}