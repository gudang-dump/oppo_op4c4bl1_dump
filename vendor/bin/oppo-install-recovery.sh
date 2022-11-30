#!/system/bin/sh
if ! applypatch --check EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:6bd5981b32750696237f4f93a0c8633945eac0df; then
  applypatch  \
          --patch /vendor/recovery-from-boot.p \
          --source EMMC:/dev/block/platform/bootdevice/by-name/spmfw:49008:6071dbb2bf10dcfc3ccb11f3bd673c765c5c445c \
          --target EMMC:/dev/block/platform/bootdevice/by-name/recovery:67108864:6bd5981b32750696237f4f93a0c8633945eac0df && \
      log -t recovery "Installing new oppo recovery image: succeeded" && \
      setprop ro.recovery.updated true || \
      log -t recovery "Installing new oppo recovery image: failed" && \
      setprop ro.recovery.updated false
else
  log -t recovery "Recovery image already installed"
  setprop ro.recovery.updated true
fi
