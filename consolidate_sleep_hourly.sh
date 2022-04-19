

PREV_HOUR=$(dateutils.dadd now -1h -f '%Y-%m-%dT%H')

echo "Consolidating $PREV_HOUR ..."

ls /tmp/sleep-monitor_${PREV_HOUR}*mp3 |\
	sed -E "s/(.*)/file \'\1\'/" > sleep_hour_prev_hour.txt

CONSOLIDATED_HOURLY="sleep-consolidated_${PREV_HOUR}.mp3"
echo "Consolidating into $CONSOLIDATED_HOURLY ..."
ffmpeg \
	-f concat \
	-safe 0 \
	-i sleep_hour_prev_hour.txt \
	-c copy $CONSOLIDATED_HOURLY
echo "Created $CONSOLIDATED_HOURLY."
