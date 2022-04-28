TIME=$(date -Is)

SLEEP_MONITOR_JPGS="/tmp/sleep-monitor_*.jpg"

SLEEP_VID_DAILY="/tmp/sleep-vid_${TIME}.mp4"
ffmpeg -framerate 3 -pattern_type glob -i "$SLEEP_MONITOR_JPGS" -c:v libx264 -pix_fmt yuv420p $SLEEP_VID_DAILY

mv $SLEEP_VID_DAILY ~/shared_folders/transfer/
rm $SLEEP_MONITOR_JPGS
