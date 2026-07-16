# PX4 NuttX firmware build/flash toolchain.
# Upstream PX4 focal dev image + fastcrc (needed by the firmware build).
FROM px4io/px4-dev-nuttx-focal:2022-08-12
RUN pip install fastcrc
