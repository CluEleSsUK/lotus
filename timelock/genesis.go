package timelock

import (
	"context"
	"fmt"
	actorstypes "github.com/filecoin-project/go-state-types/actors"
	"github.com/filecoin-project/go-state-types/big"
	"github.com/filecoin-project/go-state-types/network"
	bstore "github.com/filecoin-project/lotus/blockstore"
	"github.com/filecoin-project/lotus/chain/state"
	"github.com/filecoin-project/lotus/chain/types"
	cbor "github.com/ipfs/go-ipld-cbor"
	"golang.org/x/xerrors"
)

func SetupTimelock(ctx context.Context, st *state.StateTree, bs bstore.Blockstore, nv network.Version) error {
	cst := cbor.NewCborStore(bs)
	av, err := actorstypes.VersionForNetwork(nv)
	if err != nil {
		return fmt.Errorf("failed to get actors version for network version %d: %w", nv, err)
	}

	if av < actorstypes.Version10 {
		// Not defined before version 10; migration has to create.
		return nil
	}

	//codecid, ok := actors.GetActorCodeID(av, "timelock")
	//if !ok {
	//	return fmt.Errorf("failed to get CodeID for Timelock during genesis")
	//}
	stateCid, err := cst.Put(ctx, &State{})
	if err != nil {
		return xerrors.Errorf("couldnt store timelock state: %v", err)
	}

	actor := &types.Actor{
		Code:    CodeCid,
		Head:    stateCid,
		Balance: big.Zero(),
	}

	if err := st.SetActor(TimelockActorAddr, actor); err != nil {
		return xerrors.Errorf("setup timelock actor: %w", err)
	}

	return nil
}
