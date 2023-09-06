package interchaintest

import (
	feesharetypes "github.com/Source-Protocol-Cosmos/source/v13/x/feeshare/types"
	simappparams "github.com/cosmos/cosmos-sdk/simapp/params"
	"github.com/strangelove-ventures/interchaintest/v4/chain/cosmos"
	"github.com/strangelove-ventures/interchaintest/v4/ibc"
)

var (
	SourceE2ERepo  = "ghcr.io/source-protocol-cosmos/source-e2e"
	SourceMainRepo = "ghcr.io/source-protocol-cosmos/source"

	sourceRepo, sourceVersion = GetDockerImageInfo()

	SourceImage = ibc.DockerImage{
		Repository: sourceRepo,
		Version:    sourceVersion,
		UidGid:     "1025:1025",
	}

	sourceConfig = ibc.ChainConfig{
		Type:                "cosmos",
		Name:                "source",
		ChainID:             "source-2",
		Images:              []ibc.DockerImage{SourceImage},
		Bin:                 "sourced",
		Bech32Prefix:        "source",
		Denom:               "usource",
		CoinType:            "118",
		GasPrices:           "0.0usource",
		GasAdjustment:       1.1,
		TrustingPeriod:      "112h",
		NoHostMount:         false,
		SkipGenTx:           false,
		PreGenesis:          nil,
		ModifyGenesis:       nil,
		ConfigFileOverrides: nil,
		EncodingConfig:      sourceEncoding(),
	}

	pathSourceGaia        = "source-gaia"
	genesisWalletAmount = int64(10_000_000)
)

// sourceEncoding registers the Source specific module codecs so that the associated types and msgs
// will be supported when writing to the blocksdb sqlite database.
func sourceEncoding() *simappparams.EncodingConfig {
	cfg := cosmos.DefaultEncoding()

	// register custom types
	feesharetypes.RegisterInterfaces(cfg.InterfaceRegistry)

	return &cfg
}
