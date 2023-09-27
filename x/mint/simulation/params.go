package simulation

// DONTCOVER

import (
	"fmt"
	"math/rand"

	"github.com/cosmos/cosmos-sdk/x/simulation"

	"github.com/Source-Protocol-Cosmos/source/v3/x/mint/types"
	simtypes "github.com/cosmos/cosmos-sdk/types/simulation"
)

const (
	keyBlocksPerYear = "BlocksPerYear"
)

// ParamChanges defines the parameters that can be modified by param change proposals
// on the simulation
func ParamChanges(_ *rand.Rand) []simtypes.ParamChange {
	return []simtypes.ParamChange{
		simulation.NewSimParamChange(types.ModuleName, keyBlocksPerYear,
			func(r *rand.Rand) string {
				return fmt.Sprintf("\"%d\"", GenBlocksPerYear(r))
			},
		),
	}
}
