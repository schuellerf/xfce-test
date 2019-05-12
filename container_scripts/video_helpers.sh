# call this script with "source" to get those helper functions
video_time() {
    VIDEO_LEN=$(( $(date +%s) - $(cat /tmp/video_start_time) ))
    VIDEO_TIME=$(date --utc --date=@${VIDEO_LEN} +%T)
    echo "${VIDEO_TIME}"
}
