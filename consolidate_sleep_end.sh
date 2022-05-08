TIME=$(date -Id)

SLEEP_ANOTATE_JPGS="/tmp/sleep-anotate_*.jpg"

SLEEP_VID_DAILY="/tmp/sleep-vid_${TIME}.mp4"
ffmpeg -framerate 3 -pattern_type glob -i "$SLEEP_ANOTATE_JPGS" -c:v libx264 -pix_fmt yuv420p $SLEEP_VID_DAILY

mkdir -p ~/shared_folders/transfer/$TIME
mv $SLEEP_VID_DAILY ~/shared_folders/transfer/$TIME
rm $SLEEP_ANOTATE_JPGS
mv /tmp/sleep-spectogram_*.png ~/shared_folders/transfer/$TIME
mv /tmp/sleep-consolidated_*.mp3 ~/shared_folders/transfer/$TIME
