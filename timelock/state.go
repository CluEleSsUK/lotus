package timelock

import (
	cbg "github.com/whyrusleeping/cbor-gen"
)

type State struct {
	cbg.CBORMarshaler
	cbg.CBORUnmarshaler
	empty uint64
}
