for file in "city"/*;
do
  file=$(echo $file | cut -d'/' -f 2)
  city=$(echo $file | cut -d'.' -f 1)
  source="city/"$file
  for i in {1..31};
  do
    dest="date/"$i
    t=$(sed "${i}q;d" $source)
    str=$city" "$t
    echo $str >> $dest
  done;
done;
