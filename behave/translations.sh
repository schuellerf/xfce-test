#!/usr/bin/bash

LANG=de_DE.utf8
export TRANSLATION_LANG=${TRANSLATION_LANG:-${LANG}}
PO_FILE=${PO_FILE:-/git/xfce4-clipman-plugin/po/de.po}
BEHAVE_TEST=${BEHAVE_TEST:-translation_xfce4-clipman-plugin.feature}

F=${LANG}.html

export VIDEO_PREFIX="lang-screenshots/xfce-test_video_"

rm -rf /data/lang-screenshots
mkdir -p /data/lang-screenshots

export OVERLAY_FILE=${OVERLAY_FILE:-/tmp/video.txt}

/container_scripts/start_recording.sh

# This creates a logfile for behave (/tmp/text_all.txt)
# cuts the last 5 lines to a new file (/tmp/text_cut.txt) and has
# to _move_ the file to /tmp/video.txt for ffmpeg to properly get it displayed



# -D DEBUG_ON_ERROR

behave ${BEHAVE_TEST} | while read LINE; do
  echo "$LINE" | tee -a /tmp/text_all.txt
  tail -n5 /tmp/text_all.txt > /tmp/text_cut.txt
  mv /tmp/text_cut.txt ${OVERLAY_FILE}
done

/container_scripts/stop_recording.sh

cd /data/lang-screenshots
video=$(ls xfce-test_video*.mp4)
start_time=$(cat /tmp/video_start_time)

echo "<HTML>" > $F
cat - <<EOF >> $F
<head>
<meta charset="UTF-8">
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
  pointer-events: none;
}
</style>
<script type="text/javascript" src="${LANG}_data.json"></script>
<script>

function show_details(o) {
  if (o.nextSibling.style.display == "inline") {
    o.nextSibling.style.display = "none";
  } else {
    o.nextSibling.style.display = "inline";
  }
}
function draw_canvas(element)
{
  resize_canvas(element);
  cv = element.nextSibling;
  var ctx = cv.getContext("2d");
  ctx.clearRect(0, 0, cv.width, cv.height);
  ctx.beginPath();
  t = Math.floor(element.currentTime) + parseInt(element.getAttribute('my_start_time'));
  for (i in translations[t]) {
    item = translations[t][i];
    if (document.getElementById("po_filter").value.length > 0 && document.getElementById("po_filter").value.toUpperCase() != item.name) {
      continue
    }
    ctx.lineWidth = "2";
    ctx.strokeStyle = "red";
    size = item.h;
    ctx.rect(item.x, item.y, item.w, item.h);
    ctx.font = Math.min(item.h,12) + "px Verdana";
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
  cv.height = element.offsetHeight;
  cv.style.top = element.offsetTop;
  cv.style.left = element.offsetLeft;
}
</script>

</head>
<body>
<video id="video" my_start_time="$start_time" src="$video" ontimeupdate="draw_canvas(this)" onplay="resize_canvas(this)" controls ></video><canvas class="canvas" id="canvas"></canvas>
<form>
<button type="button" onclick="document.getElementById('video').pause();document.getElementById('video').currentTime=Math.floor(document.getElementById('video').currentTime)-1">&lt;</button>
<button type="button" onclick="document.getElementById('video').pause();document.getElementById('video').currentTime=Math.floor(document.getElementById('video').currentTime)+1">&gt;</button><br/>
PO-line highlight in video: <input type="text" id="po_filter" onkeyup="draw_canvas(document.getElementById('video'))"/><br/>
(leave blank to highlight all)
</form>
<hr/>
<h1>${PO_FILE}</h1>
<div class="pofile">
EOF


i=1
cat $PO_FILE |while read LINE; do

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
#start_pic=$(( $stop_pic - 5 ))
cat - <<EOF >> $F
<div onclick='document.getElementById("po_filter").value="PO${i}";document.getElementById("video").pause();document.getElementById("video").currentTime=$stop_pic;window.scrollTo(0,0)'>$p</div>:<br/><img src="$p" onclick='document.getElementById("po_filter").value="PO${i}";document.getElementById("video").pause();document.getElementById("video").currentTime=$stop_pic;window.scrollTo(0,0)'/><br/>
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