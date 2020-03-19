FROM alpine:3.10
MAINTAINER kost - https://github.com/kost

ENV ULX3SBASEDIR=/opt

RUN apk --update add git bash curl wget build-base libusb-dev libusb-compat-dev libftdi1-dev python3 libtool automake autoconf make cmake pkgconf py2-pip gengetopt linux-headers eudev-dev argp-standalone && \
 rm -f /var/cache/apk/* && \
 echo "Success [deps]"

COPY root /

RUN cd $ULX3SBASEDIR && \
 git clone https://github.com/emard/ulx3s-bin && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/kost/libusb0 libusb0-git && \
 cd libusb0-git && \
 ./configure --prefix=/opt/libusb0 && \
 make && make install && \
 cd $ULX3SBASEDIR && \
 curl https://www.intra2net.com/en/developer/libftdi/download/libftdi-0.20.tar.gz | tar xvzf - && \
 cd libftdi-0.20/ && \
 CFLAGS="-I/opt/libusb0/include" LDFLAGS="-L/opt/libusb0/lib" ./configure --prefix=/opt/libftdi && \
 make && make install && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/f32c/tools f32c-tools && \
 cd f32c-tools/ujprog && \
 cp $ULX3SBASEDIR/patches/Makefile.gcc . && \
 CFLAGS="-I/opt/libusb0/include -I/opt/libftdi/include -L/opt/libusb0/lib -L/opt/libftdi/lib" make -f Makefile.gcc && \
 install -m 755 -s ujprog /usr/local/bin && \
 cd $ULX3SBASEDIR && \
 git clone https://github.com/trabucayre/openFPGALoader && \
 cd openFPGALoader && \
 mkdir build && \
 cd build && \
 cmake -DBUILD_STATIC=ON .. && \
 make install/strip && \
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
 make CFLAGS="-I/opt/libusb0/include -I/opt/libftdi/include" LDFLAGS="/opt/libftdi/lib/libftdi.a /opt/libusb0/lib/libusb.a -static" && \
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

