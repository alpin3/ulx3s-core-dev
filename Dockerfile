FROM alpine:3.10
MAINTAINER kost - https://github.com/kost

ENV ULX3SBASEDIR=/opt

RUN apk --update add git bash wget build-base libusb-dev python3 libusb-compat-dev libftdi1-dev libtool automake autoconf make cmake pkgconf py2-pip gengetopt && \
 rm -f /var/cache/apk/* && \
 echo "Success [deps]"

COPY root /

RUN cd $ULX3SBASEDIR && \
 git clone https://github.com/emard/ulx3s-bin && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/f32c/tools f32c-tools && \
 cd f32c-tools/ujprog && \
 cp $ULX3SBASEDIR/patches/Makefile.alpine . && \
 make -f Makefile.alpine && \
 install -m 755 -s ujprog /usr/local/bin && \
 cd $ULX3SBASEDIR && \
 git clone https://git.code.sf.net/p/openocd/code openocd && \
 cd openocd && \
 ./bootstrap && \
 LDFLAGS="--static" ./configure --enable-static && \
 make -j$(nproc) && \
 make install && \
 strip /usr/local/bin/openocd && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/richardeoin/ftx-prog.git && \
 cd ftx-prog && \
 make CFLAGS="-I/usr/include/libftdi1" LDFLAGS="/usr/lib/libftdi1.a /usr/lib/libusb-1.0.a /usr/lib/libusb.a -static" && \
 install -m 755 -s ftx_prog /usr/local/bin/ && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/emard/FleaFPGA-JTAG.git && \
 cd FleaFPGA-JTAG/FleaFPGA-JTAG-linux && \
 make CFLAGS="-I/usr/include/libftdi1 /usr/lib/libftdi1.a /usr/lib/libusb-1.0.a /usr/lib/libusb.a -static" && \
 install -m 755 -s FleaFPGA-JTAG /usr/local/bin && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/emard/TinyFPGA-Bootloader.git && \
 cd TinyFPGA-Bootloader/programmer/tinyfpgasp && \
 cp $ULX3SBASEDIR/patches/Makefile.tinyfpga makefile && \
 make GCC=gcc CLIBS="/usr/lib/libusb-1.0.a -static" && \
 install -m 755 -s tinyfpgasp /usr/local/bin/ && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/micropython/micropython && \
 cd micropython/mpy-cross && \
 make LDFLAGS_EXTRA="-static" && \
 install -m 755 -s mpy-cross /usr/local/bin/ && \
 cd $ULX3SBASEDIR && \
 pip2 install esptool && \
 pip2 install pyserial && \
 pip3 install esptool && \
 pip3 install pyserial && \
 cd $ULX3SBASEDIR && \
 echo "Success [build]"

#VOLUME ["/fpga"]
#WORKDIR /fpga

