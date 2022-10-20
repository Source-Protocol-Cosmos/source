package main

import (
	"encoding/json"
	"fmt"
	"github.com/spf13/cobra"

	icacontrollertypes "github.com/cosmos/ibc-go/v3/modules/apps/27-interchain-accounts/controller/types"
	icahosttypes "github.com/cosmos/ibc-go/v3/modules/apps/27-interchain-accounts/host/types"
	icatypes "github.com/cosmos/ibc-go/v3/modules/apps/27-interchain-accounts/types"

	"github.com/cosmos/cosmos-sdk/client"
	"github.com/cosmos/cosmos-sdk/client/flags"
	"github.com/cosmos/cosmos-sdk/server"
	"github.com/cosmos/cosmos-sdk/x/genutil"
	genutiltypes "github.com/cosmos/cosmos-sdk/x/genutil/types"
)

// AddGenesisAccountCmd returns add-genesis-account cobra Command.
func AddGenesisIcaCmd(defaultNodeHome string) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "add-ica-config",
		Short: "Add ICA config to genesis.json",
		Long:  `Add default ICA configuration to genesis.json`,
		Args:  cobra.ExactArgs(0),
		RunE: func(cmd *cobra.Command, args []string) error {
			clientCtx := client.GetClientContextFromCmd(cmd)
			serverCtx := server.GetServerContextFromCmd(cmd)
			config := serverCtx.Config

			config.SetRoot(clientCtx.HomeDir)

			genFile := config.GenesisFile()
			appState, genDoc, err := genutiltypes.GenesisStateFromGenFile(genFile)
			if err != nil {
				return fmt.Errorf("failed to unmarshal genesis state: %w", err)
			}

			controllerGenesisState := icatypes.DefaultControllerGenesis()
			// no params set in upgrade handler, no params set here
			controllerGenesisState.Params = icacontrollertypes.Params{}

			hostGenesisState := icatypes.DefaultHostGenesis()
			// add the messages we want
			hostGenesisState.Params = icahosttypes.Params{
				HostEnabled: true,
				AllowMessages: []string{
					"/cosmos.bank.v1beta1.MsgSend",
					// uncomment this after v11 ships
					// "/cosmos.bank.v1beta1.MsgMultiSend",
					"/cosmos.staking.v1beta1.MsgDelegate",
					"/cosmos.staking.v1beta1.MsgUndelegate",
					"/cosmos.staking.v1beta1.MsgBeginRedelegate",
					"/cosmos.staking.v1beta1.MsgCreateValidator",
					"/cosmos.staking.v1beta1.MsgEditValidator",
					"/cosmos.distribution.v1beta1.MsgWithdrawDelegatorReward",
					"/cosmos.distribution.v1beta1.MsgSetWithdrawAddress",
					"/cosmos.distribution.v1beta1.MsgWithdrawValidatorCommission",
					"/cosmos.distribution.v1beta1.MsgFundCommunityPool",
					"/cosmos.gov.v1beta1.MsgVote",
					"/cosmos.gov.v1beta1.MsgVoteWeighted",
					"/cosmos.authz.v1beta1.MsgExec",
					"/cosmos.authz.v1beta1.MsgGrant",
					"/cosmos.authz.v1beta1.MsgRevoke",
					"/cosmwasm.wasm.v1.MsgStoreCode",
					"/cosmwasm.wasm.v1.MsgInstantiateContract",
					// uncomment this after v11 ships
					// "/cosmwasm.wasm.v1.InstantiateContract2",
					"/cosmwasm.wasm.v1.MsgExecuteContract",
					"/ibc.applications.transfer.v1.MsgTransfer",
				},
			}

			newIcaGenState := icatypes.NewGenesisState(controllerGenesisState, hostGenesisState)

			icaGenStateBz, err := clientCtx.Codec.MarshalJSON(newIcaGenState)
			if err != nil {
				return fmt.Errorf("failed to marshal auth genesis state: %w", err)
			}

			appState[icatypes.ModuleName] = icaGenStateBz

			appStateJSON, err := json.Marshal(appState)
			if err != nil {
				return fmt.Errorf("failed to marshal application genesis state: %w", err)
			}

			genDoc.AppState = appStateJSON
			return genutil.ExportGenesisFile(genDoc, genFile)
		},
	}

	cmd.Flags().String(flags.FlagHome, defaultNodeHome, "The application home directory")
	cmd.Flags().String(flags.FlagKeyringBackend, flags.DefaultKeyringBackend, "Select keyring's backend (os|file|kwallet|pass|test)")

	flags.AddQueryFlagsToCmd(cmd)

	return cmd
}
