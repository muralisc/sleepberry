

PREV_HOUR=$(dateutils.dadd --zone "Europe/London" now -1h -f '%Y-%m-%dT%H')

LOG_FILE="/tmp/sleepberry.log"

echo "Consolidating $PREV_HOUR ..." >> $LOG_FILE

PREV_HOUR_FILE_LIST="/tmp/sleep_prev_hour_file_list.txt"
find /tmp -maxdepth 1 -ipath "*sleep-monitor_${PREV_HOUR}*mp3" |\
	sed -E "s/(.*)/file \'\1\'/" > $PREV_HOUR_FILE_LIST

CONSOLIDATED_HOURLY="/tmp/sleep-consolidated_${PREV_HOUR}.mp3"
echo "Consolidating into $CONSOLIDATED_HOURLY ..." >> $LOG_FILE
if [[ $(wc -l $PREV_HOUR_FILE_LIST | awk '{print $1}') -eq 0 ]]; then
	echo "No files to process, exiting"
	exit
fi
ffmpeg \
	-f concat \
	-safe 0 \
	-i $PREV_HOUR_FILE_LIST \
	-c copy $CONSOLIDATED_HOURLY 2>&1 > /tmp/sleep_consolidate_ffmpeg.log
echo "Created $CONSOLIDATED_HOURLY" >> $LOG_FILE

echo "Delting previous hour files starting with $PREV_HOUR" >> $LOG_FILE
find /tmp -maxdepth 1 -ipath "*sleep-monitor_${PREV_HOUR}*mp3" -delete

SLEEP_SPECTOGRAM="/tmp/sleep-spectogram_$PREV_HOUR.png"
sox $CONSOLIDATED_HOURLY -n spectrogram -z100 -o $SLEEP_SPECTOGRAM -t $PREV_HOUR

mv $SLEEP_SPECTOGRAM ~/shared_folders/transfer/
mv $CONSOLIDATED_HOURLY ~/shared_folders/transfer/
