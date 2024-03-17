# f_u_show_log "$LOG_PATH" "$message"
f_u_show_log() {
   echo "$(date)" >> "$1"
   echo -e "$2" >> "$1"
}