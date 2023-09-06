package feeshare_test

import (
	"encoding/json"

	abci "github.com/tendermint/tendermint/abci/types"
	"github.com/tendermint/tendermint/libs/log"
	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"
	dbm "github.com/tendermint/tm-db"

	sourceapp "github.com/Source-Protocol-Cosmos/source/v3/app"
	"github.com/cosmos/cosmos-sdk/simapp"

	"github.com/Source-Protocol-Cosmos/source/v3/x/mint/types"
	sdk "github.com/cosmos/cosmos-sdk/types"
)

// returns context and an app with updated mint keeper
func CreateTestApp(isCheckTx bool) (*sourceapp.App, sdk.Context) {
	app := Setup(isCheckTx)

	ctx := app.BaseApp.NewContext(isCheckTx, tmproto.Header{})
	app.MintKeeper.SetParams(ctx, types.DefaultParams())
	app.MintKeeper.SetMinter(ctx, types.DefaultInitialMinter())

	return app, ctx
}

func Setup(isCheckTx bool) *sourceapp.App {
	app, genesisState := GenApp(!isCheckTx, 5)
	if !isCheckTx {
		// init chain must be called to stop deliverState from being nil
		stateBytes, err := json.MarshalIndent(genesisState, "", " ")
		if err != nil {
			panic(err)
		}

		// Initialize the chain
		app.InitChain(
			abci.RequestInitChain{
				Validators:      []abci.ValidatorUpdate{},
				ConsensusParams: simapp.DefaultConsensusParams,
				AppStateBytes:   stateBytes,
			},
		)
	}

	return app
}

func GenApp(withGenesis bool, invCheckPeriod uint) (*sourceapp.App, sourceapp.GenesisState) {
	db := dbm.NewMemDB()
	encCdc := sourceapp.MakeEncodingConfig()
	app := sourceapp.New(
		log.NewNopLogger(),
		db,
		nil,
		true,
		map[int64]bool{},
		simapp.DefaultNodeHome,
		invCheckPeriod,
		encCdc,
		sourceapp.GetEnabledProposals(),
		simapp.EmptyAppOptions{},
		sourceapp.GetWasmOpts(simapp.EmptyAppOptions{}),
	)

	if withGenesis {
		return app, sourceapp.NewDefaultGenesisState(encCdc.Marshaler)
	}

	return app, sourceapp.GenesisState{}
}
