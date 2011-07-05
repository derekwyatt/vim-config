# Get the list of unopened files under the given $1/$2 directory.
#   It should be possible to implement the logic by using temp files and diff,
#   but this was more challenging to me :)
# Ex:
#   unOpenedFiles=`getUnOpenedFiles "$root" "src"`
getUnOpenedFiles() {
    path=$1
    dir=$2
    p4 opened $path/$dir/... \
        | sed -e 's/.*'$dir'/'$dir'/' -e 's/#.*$//' \
        | perl -n -e '
          print;
          END
          {
              # Merge the opened list with all the files under BaseClasses.
              foreach $f (`find '$path/$dir' -type f | sed -e "s/.*'$dir'/'$dir'/"`)
              {
                  print $f;
              }
          }' \
        | sort -f \
        | uniq -c \
        | sed -n -e 's/\s*1\s*//p'
}
