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

.canvas {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 10;
}
</style>
<script>
let translations = {
186: [
{ name: "PO80",  x: 10, y: 10, w: 100, h: 100 } ,
{ name: "PO81",  x: 10, y: 300, w: 100, h: 100 }
] ,
191: [
{ name: "PO90",  x: 100, y: 10, w: 100, h: 100 } ,
{ name: "PO91",  x: 100, y: 300, w: 100, h: 100 }
]
}

function show_details(o) {
  if (o.nextSibling.style.display == "inline") {
    o.nextSibling.style.display = "none";
  } else {
    o.nextSibling.style.display = "inline";
  }
}
function draw_canvas(element)
{
  cv = element.nextSibling;
  var ctx = cv.getContext("2d");
  ctx.clearRect(0, 0, cv.width, cv.height);
  ctx.beginPath();
  t = Math.floor(element.currentTime)
  for (i in translations[t]) {
    item = translations[t][i];
    ctx.lineWidth = "2";
    ctx.strokeStyle = "red";
    size = item.h;
    ctx.rect(item.x, item.y, item.w, item.h);
    ctx.font = item.h + "px Verdana";
    ctx.textBaseline = "bottom";
    ctx.fillText(item.name,item.x,item.y + item.h);
  }
    ctx.stroke();
}
function resize_canvas(element)
{
  var w = element.offsetWidth;
  var h = element.offsetHeight;
  cv = element.nextSibling;
  cv.width = element.offsetWidth;
  cv.height = element.offsetHeight - 50;
  cv.style.top = element.offsetTop;
  cv.style.left = element.offsetLeft;
}
</script>

</head>
<body>
<div class="pofile">
EOF

video=$(ls xfce-test_video*)
start_time=$(echo $video|grep -Po "(?<=_video_)[0-9]+(?=_)")

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

pic_time=$(echo $p|grep -Po "(?<=_)[0-9]{4,}(?=_)")
stop_pic=$(( $pic_time - $start_time ))
start_pic=$(( $stop_pic - 5 ))
cat - <<EOF >> $F
<video id="video_po$p" my_stop_time="$stop_pic" my_po="PO80" src="$video#t=$start_pic,$stop_pic" ontimeupdate="draw_canvas(this)" onplay="resize_canvas(this)" controls ></video><canvas class="canvas" id="canvas_po$p"></canvas>
<div onclick='document.getElementById("video_po$p").pause();document.getElementById("video_po$p").currentTime=$stop_pic;'>$p</div>:<br/><img src="$p"/><br/>
EOF
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
