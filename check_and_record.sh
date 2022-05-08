TIME=$(date -Is)
LOG_FILE="/tmp/sleepberry.log"
SLEEP_MONITOR_RAW="/tmp/sleep-monitor_$TIME.flac"
SLEEP_MONITOR_NORM="/tmp/n_sleep-monitor_$TIME.flac"
SLEEP_MONITOR_MP3="/tmp/sleep-monitor_$TIME.mp3"
SLEEP_MONITOR_JPG="/tmp/sleep-monitor_$TIME.jpg"
SLEEP_ANOTATE_JPG="/tmp/sleep-anotate_$TIME.jpg"
libcamera-jpeg -o $SLEEP_MONITOR_JPG
arecord -f S24_3LE -D "sysdefault:CARD=Nano" -c 2 -r 48000 $SLEEP_MONITOR_RAW &
convert $SLEEP_MONITOR_JPG -pointsize 120 -fill white -undercolor '#00000080' -gravity SouthEast -annotate +0+5 "$(date)" $SLEEP_ANOTATE_JPG
rm $SLEEP_MONITOR_JPG
# XDG_RUNTIME_DIR=/run/user/1000 parecord \
# 	-d alsa_input.usb-Blue_Microphones_Yeti_Nano_2109SG0014M8_888-000445040606-00.analog-stereo \
# 	$SLEEP_MONITOR_RAW &
# rec -c2 $SLEEP_MONITOR &
echo "$TIME sleeping for 60 ..." >> $LOG_FILE
sleep 60
pkill arecord
sox $SLEEP_MONITOR_RAW $SLEEP_MONITOR_NORM norm -0.1
ffmpeg -y -i $SLEEP_MONITOR_NORM $SLEEP_MONITOR_MP3 >> $LOG_FILE
rm $SLEEP_MONITOR_RAW
rm $SLEEP_MONITOR_NORM

# Make spectrogram
SLEEP_SPECTOGRAM="/tmp/sleep-spectogram_$TIME.png"
SLEEP_WAVEFORM="/tmp/sleep-waveform_$TIME.png"
sox $SLEEP_MONITOR_MP3 -n spectrogram -z100 -x 120 -y 320 -o $SLEEP_SPECTOGRAM -t $TIME

# Make waveform
ffmpeg \
	-i $SLEEP_MONITOR_MP3  -f lavfi -i color=c=black:s=120x320 \
	-filter_complex "[0:a]showwavespic=s=120x320:colors=white[fg];[1:v][fg]overlay=format=auto" \
	-frames:v 1 $SLEEP_WAVEFORM

MAX_AMP=$(sox $SLEEP_MONITOR_MP3 -n stat 2>&1 | grep "Maximum amplitude" | awk '{print $3}')
echo "$TIME Max Amplitude= $MAX_AMP" >> $LOG_FILE

AMP_THRESHOLD=0.009
if (( $(echo "$MAX_AMP > $AMP_THRESHOLD" |bc -l) )); then
  echo "$TIME Over amplitude threshold of $AMP_THRESHOLD" >> $LOG_FILE
fi
