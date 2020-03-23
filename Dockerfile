FROM alanfranz/fpm-within-docker:centos-7

ENV NAME "php72t-pecl-tdlib"
ENV VERSION "0.0.10"
ENV ITERATION "1.vortex.el7.centos"

RUN mkdir /pkg
WORKDIR /pkg

RUN yum install -y centos-release-scl-rh git epel-release http://vortex-rpm.org/el7/noarch/vortex-release-7-2.vortex.el7.centos.noarch.rpm
RUN yum install -y gperf openssl-devel cmake3 devtoolset-7 php72t-devel libphpcpp

ENV PATH /opt/rh/devtoolset-7/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN git clone --recurse-submodules https://github.com/yaroslavche/phptdlib.git

WORKDIR /pkg/phptdlib
RUN git checkout ${VERSION}
RUN mkdir build

WORKDIR /pkg/phptdlib/build
RUN cmake3 ..
RUN make -j $(nproc)

RUN make install

WORKDIR /pkg

RUN sh -c 'fpm -s dir -t rpm --rpm-autoreqprov --rpm-autoreq --rpm-autoprov --license "ASL 2.0" --vendor "Vortex RPM" -m "Vortex Maintainers <dev@vortex-rpm.org>" --url "http://vortex-rpm.org" -n ${NAME} -v ${VERSION} --iteration "${ITERATION}" /usr/lib64/php/modules/tdlib.so /etc/php.d/tdlib.ini'
