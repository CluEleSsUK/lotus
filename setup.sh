#!/bin/bash

export LIBRARY_PATH=/opt/homebrew/lib
export FFI_BUILD_FROM_SOURCE=1
export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"

export LOTUS_BUILTIN_ACTORS_V11=/some/path/to/bundle/here
export LOTUS_PATH=~/.lotus-local-net
export LOTUS_MINER_PATH=~/.lotus-miner-local-net
export LOTUS_SKIP_GENESIS_CHECK=_yes_
export CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__"
export CGO_CFLAGS="-D__BLST_PORTABLE__"

echo [+] clearing old state
rm -rf ~/.genesis-sectors
rm -rf ~/.lotus-local-net
rm -rf ~/.lotus-miner-local-net
rm -rf bls-*.keyinfo
rm -rf localnet.json

echo [+] building lotus 2k
make 2k

if [ "$?" -ne 0 ]; then
  echo [-] Lotus build failed
  exit 1
fi

echo [+] fetching params for sector
./lotus fetch-params 2048

echo [+] making lotus shed
make lotus-shed

echo [+] generating keys
KEY_1=$(./lotus-shed keyinfo new bls)
KEY_2=$(./lotus-shed keyinfo new bls)

echo [+] presealing sectors
./lotus-seed pre-seal --sector-size 2KiB --num-sectors 2

echo [+] creating genesis
./lotus-seed genesis new localnet.json
./lotus-seed genesis set-signers --threshold=2 --signers $KEY_1 --signers $KEY_2 localnet.json

echo [+] creating pre-miner
./lotus-seed genesis add-miner localnet.json ~/.genesis-sectors/pre-seal-t01000.json

echo [+] run the following to start the daemon:
echo export LOTUS_BUILTIN_ACTORS_V11=$LOTUS_BUILTIN_ACTORS_V11
echo export LOTUS_PATH=~/.lotus-local-net 
echo export LOTUS_MINER_PATH=~/.lotus-miner-local-net
echo export LOTUS_SKIP_GENESIS_CHECK=_yes_ 
echo export CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__" 
echo export CGO_CFLAGS="-D__BLST_PORTABLE__" 
echo "./lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false"

echo 
echo in another window run:
echo export LOTUS_BUILTIN_ACTORS_V11=$LOTUS_BUILTIN_ACTORS_V11
echo export LOTUS_PATH=~/.lotus-local-net 
echo export LOTUS_MINER_PATH=~/.lotus-miner-local-net
echo export LOTUS_SKIP_GENESIS_CHECK=_yes_ 
echo export CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__" 
echo export CGO_CFLAGS="-D__BLST_PORTABLE__" 
echo ./lotus wallet import --as-default ~/.genesis-sectors/pre-seal-t01000.key 
echo "./lotus-miner init --genesis-miner --actor=t01000 --sector-size=2KiB --pre-sealed-sectors=~/.genesis-sectors --pre-sealed-metadata=~/.genesis-sectors/pre-seal-t01000.json --nosync && ./lotus-miner run --nosync"


echo
echo in _another_ window run:
echo export LOTUS_BUILTIN_ACTORS_V11=$LOTUS_BUILTIN_ACTORS_V11
echo export LOTUS_PATH=~/.lotus-local-net 
echo export LOTUS_MINER_PATH=~/.lotus-miner-local-net
echo export LOTUS_SKIP_GENESIS_CHECK=_yes_ 
echo export CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__" 
echo export CGO_CFLAGS="-D__BLST_PORTABLE__" 
echo lotus wallet import bls-$KEY_1.keyinfo
echo lotus wallet import bls-$KEY_2.keyinfo
