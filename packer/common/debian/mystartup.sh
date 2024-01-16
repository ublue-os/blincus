#!/bin/sh
uid=$(id -u)
run_dir=/run/user/$uid
mkdir -p $run_dir && chmod 700 $run_dir && chown $uid:$uid $run_dir
mkdir -p $run_dir/pulse && chmod 700 $run_dir/pulse && chown $uid:$uid $run_dir/pulse
ln -sf /mnt/.container_pulseaudio_socket $run_dir/pulse/native
tmp_dir=/tmp/.X11-unix
mkdir -p $tmp_dir
ln -sf /mnt/.container_x11_socket $tmp_dir/X0
