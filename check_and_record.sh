TIME=$(date -Is)
SLEEP_MONITOR_RAW="/tmp/sleep-monitor_$TIME.flac"
SLEEP_MONITOR_MP3="/tmp/sleep-monitor_$TIME.mp3"
arecord -f S24_3LE -D "sysdefault:CARD=Nano" -c 2 -r 48000 $SLEEP_MONITOR_RAW &
# XDG_RUNTIME_DIR=/run/user/1000 parecord \
# 	-d alsa_input.usb-Blue_Microphones_Yeti_Nano_2109SG0014M8_888-000445040606-00.analog-stereo \
# 	$SLEEP_MONITOR_RAW &
# rec -c2 $SLEEP_MONITOR &
echo "$TIME sleeping for 60 ..." >> /tmp/sleep.log
sleep 60
pkill arecord
ffmpeg -y -i $SLEEP_MONITOR_RAW $SLEEP_MONITOR_MP3 >> /tmp/sleep.log
rm $SLEEP_MONITOR_RAW
MAX_AMP=$(sox $SLEEP_MONITOR_MP3 -n stat 2>&1 | grep "Maximum amplitude" | awk '{print $3}')
echo "$TIME Max Amplitude= $MAX_AMP" >> /tmp/sleep.log

AMP_THRESHOLD=0.009
if (( $(echo "$MAX_AMP > $AMP_THRESHOLD" |bc -l) )); then
  echo "$TIME Over amplitude threshold of $AMP_THRESHOLD" >> /tmp/sleep.log
fi


SLEEP_SPECTOGRAM="/tmp/sleep-spectogram_$TIME.png"
sox $SLEEP_MONITOR_MP3 -n spectrogram -z100 -o $SLEEP_SPECTOGRAM
# 
# TIME=$(date -Is)
# SLEEP_REC="/tmp/sleep-$TIME.mp3"
# rec -c2 $SLEEP_REC &
# sleep 240
# pkill rec
