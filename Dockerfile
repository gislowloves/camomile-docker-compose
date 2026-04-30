FROM gcc:13 AS builder

RUN apt-get update && apt-get install -y \
    cmake git libhiredis-dev

WORKDIR /build

RUN git clone https://github.com/sewenew/redis-plus-plus.git && \
    cd redis-plus-plus && mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install

COPY romashkovaya_valley.cpp .

RUN g++ -std=c++17 -o daisy romashkovaya_valley.cpp -lredis++ -lhiredis -pthread


FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libhiredis-dev

WORKDIR /camomile

COPY --from=builder /build/daisy .
COPY --from=builder /usr/local/lib/libredis* /usr/local/lib/
RUN ldconfig

CMD ["./daisy"]