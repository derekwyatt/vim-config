XPTemplate priority=personal

XPTinclude
    \ _common/personal

let s:f = g:XPTfuncs()

XPT optparse hint=BASH\ option\ parsing
opts=$(getopt -o h`short^ --long host,`long^ -n "${0##*/}" -- "$@")
if [ $? != 0 ]; then exit 1; fi

mydir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
me=${BASH_SOURCE[0]}
me=${me##*/}

function usage
{
  cat <<EOH
usage: $me `basic^

  `detailed^
EOH
}

eval set -- "$opts"
while true
do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -`short^|--`long^)
      `cursor^
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error."
      exit 1
      ;;
  esac
done
