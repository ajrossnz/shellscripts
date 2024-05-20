#!/bin/sh -l
#mailsync-run.sh 
#a script I bodged to send me an X11 notification if there is new mail
#basically a biff for X11 using notify-send, but runs mailsync to fetch the
#mail too
#
#by Alistair Ross et al. March 2024

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; export DISPLAY=:0; 
mailsync 2>&1
 # Check account for new mail. Notify if there is new content.
 syncandnotify() {
     acc="$(echo "$account" | sed "s/.*\///")"
     #mbsync -c "$HOME/.config/mbsync/mbsyncrc" "$acc"
     new=$(find "$HOME/.local/share/mail/$acc/INBOX/new/" "$HOME/.local/share/mail/$acc/Inbox/new/" "$HOME/.local/share/mail/$acc/inbox/new/" -type -newer "$HOME/.config/mutt/.mailsynclastrun" 2> /dev/null)
     newcount=$(echo "$new" | sed '/^\s*$/d' | wc -l)

     notify-send "Before" &

     if [ "$newcount" -gt "0" ]; then

         notify-send "After" &

         notify "$acc" "$newcount" &
         for file in $new; do
             # Extract subject and sender from mail.
             from=$(awk '/^From: / && ++n ==1,/^\<.*\>:/' "$file" | perl -CS -MEncode -ne 'print       decode("MIME-Header", $_)' | awk '{ $1=""; if (NF>=3)$NF=""; print $0 }' | sed 's/^[[:blank:]]      *[\"'\''\<]*//;s/[\"'\''\>]*[[:blank:]]*$//')
             subject=$(awk '/^Subject: / && ++n == 1,/^\<.*\>: / && ++i == 2' "$file" | head -n-      1 | perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | sed 's/^Subject: //' | sed 's/^{[      [:blank:]]*[\"'\''\<]*//;s/[\"'\''\>]*[[:blank:]]*$//' | tr -d '\n')
             notify-send --app-name="mutt-wizard" "📧$from:" "$subject" &
         done
     fi
 }
