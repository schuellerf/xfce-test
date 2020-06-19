#!/usr/bin/bash

# not yet usable...

F=de_DE.html
echo "<HTML>" > $F
cat - <<EOF >> $F
<head>
<style>
.pofile {
    font-family: monospace; 
    white-space: pre;
}
.collapsible {
    display: none;
}
.content {
    border: 1px solid black;
}
.detail {
  cursor:pointer;
  color:blue;
  text-decoration:underline;
}
</style>
<script>
function show_details(o) {
  if (o.nextSibling.style.display == "inline") {
    o.nextSibling.style.display = "none";
  } else {
    o.nextSibling.style.display = "inline";
  }
}
</script>
</head>
<body>
<div class="pofile">
EOF

i=1
cat de.po |while read LINE; do

L=$(echo $i: $LINE | sed "s/</\&lt;/g;s/>/\&gt;/g")
PICS=$(ls *_po${i}_* 2>/dev/null)
if [ -z "$PICS" ]; then
  echo $L >> $F
else
  cat - <<EOF >> $F
<div class="detail" onclick="show_details(this)">$L</div><div class="collapsible">
<div class="content">
EOF
  for p in $PICS; do
      echo "$p:<br/><img src=\"$p\"/><br/>" >> $F
  done
  echo -n "</div></div>" >> $F
fi
i=$(( $i + 1 ))
done

cat - <<EOF >> $F
</div>
</body>
EOF

echo "</HTML>" >> $F
