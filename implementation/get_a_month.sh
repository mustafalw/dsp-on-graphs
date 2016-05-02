for entry in "alltime"/*
do
  filename=$(echo $entry | cut -d'/' -f 2)
  dest="test/"$filename
  source="alltime/"$filename
  ./a.out < $source > $dest
done
