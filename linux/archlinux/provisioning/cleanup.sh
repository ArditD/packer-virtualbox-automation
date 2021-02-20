#!/usr/bin/bash -x

# Clean the pacman cache.
/usr/bin/pacman -Scc --noconfirm
sleep 3
# Write zeros to improve virtual disk compaction.
dd if=/dev/zero of=/zerofile &
  PID=$!
  while [ -d /proc/$PID ]
    do
      printf "."
      sleep 5
    done
sync; rm /zerofile; sync
sleep 3