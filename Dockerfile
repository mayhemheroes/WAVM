FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake automake autotools-dev libtool zlib1g zlib1g-dev
ADD . /WAVM
WORKDIR /WAVM
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN make install
WORKDIR ./Examples/
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/simple.wasm
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/simple-name-section.wasm
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/table.wasm

FROM fuzzers/afl:2.52
COPY --from=builder /WAVM/bin/fuzz-disassemble /
COPY --from=builder /WAVM/Examples/*.wasm /testsuite/
COPY --from=builder /usr/local/lib/* /usr/local/lib/
# Find shared objects
ENV LD_LIBRARY_PATH /usr/local/lib/

ENTRYPOINT  ["afl-fuzz", "-m", "2048", "-i", "/testsuite", "-o", "/wavmOut"]
CMD ["/fuzz-disassemble", "@@"]
