package timelock

import (
	addr "github.com/filecoin-project/go-address"
	"github.com/filecoin-project/go-state-types/abi"
	"github.com/filecoin-project/go-state-types/builtin"
	"github.com/ipfs/go-cid"
)

var Methods = map[abi.MethodNum]builtin.MethodMeta{
	1: {"Constructor", *new(func(*ConstructorParams) *abi.EmptyValue)},
	2: {"Decrypt", *new(func(params *DecryptParams) *DecryptParams)},
	builtin.MustGenerateFRCMethodNum("InvokeEVM"): {"InvokeContract", *new(func(bytes *abi.CborBytes) *abi.CborBytes)},
}

var TimelockKey = "timelock"
var CodeCid = mustMakeCid("bafk2bzacec6mmgj7dvig6oad4vncjipmvtjkthekg2zyc5gb72wxh3cmzrq7a")
var TimelockActorAddr = mustMakeAddress(11)

func mustMakeAddress(id uint64) addr.Address {
	address, err := addr.NewIDAddress(id)
	if err != nil {
		panic(err)
	}
	return address
}

func mustMakeCid(input string) cid.Cid {
	c, err := cid.Decode(input)
	if err != nil {
		panic(err)
	}
	return c
}
