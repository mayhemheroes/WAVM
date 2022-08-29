FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev  libjpeg-dev
RUN git clone  https://github.com/WAVM/WAVM.git
WORKDIR /WAVM
RUN cmake -DCMAKE_C_COMPILER=afl-clang -DCMAKE_CXX_COMPILER=afl-clang++ .
RUN make
RUN make install
RUN mkdir /wavmCorpus
RUN cp ./Examples/*.wasm /wavmCorpus
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/simple.wasm
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/simple-name-section.wasm
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/table.wasm
#RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/table2.wasm
RUN mv *.wasm /wavmCorpus


ENTRYPOINT  ["afl-fuzz", "-m", "2048", "-i", "/wavmCorpus", "-o", "/wavmOut"]
CMD ["/WAVM/bin/fuzz-disassemble", "@@"]
