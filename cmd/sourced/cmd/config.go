package cmd

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"text/template"

	tmcli "github.com/tendermint/tendermint/libs/cli"

	"github.com/spf13/cobra"

	"github.com/cosmos/cosmos-sdk/client"
	scconfig "github.com/cosmos/cosmos-sdk/client/config"
	"github.com/cosmos/cosmos-sdk/client/flags"
	viper "github.com/spf13/viper"
)

type SourceCustomClient struct {
	scconfig.ClientConfig
	Gas           string `mapstructure:"gas" json:"gas"`
	GasPrices     string `mapstructure:"gas-prices" json:"gas-prices"`
	GasAdjustment string `mapstructure:"gas-adjustment" json:"gas-adjustment"`

	Fees       string `mapstructure:"fees" json:"fees"`
	FeeAccount string `mapstructure:"fee-account" json:"fee-account"`

	Note string `mapstructure:"note" json:"note"`
}

// ConfigCmd returns a CLI command to interactively create an application CLI
// config file.
func ConfigCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "config <key> [value]",
		Short: "Create or query an application CLI configuration file",
		RunE:  runConfigCmd,
		Args:  cobra.RangeArgs(0, 2),
	}
	return cmd
}

func runConfigCmd(cmd *cobra.Command, args []string) error {
	clientCtx := client.GetClientContextFromCmd(cmd)
	configPath := filepath.Join(clientCtx.HomeDir, "config")

	conf, err := getClientConfig(configPath, clientCtx.Viper)
	if err != nil {
		return fmt.Errorf("couldn't get client config: %v", err)
	}

	jcc := SourceCustomClient{
		*conf,
		os.Getenv("SOURCED_GAS"),
		os.Getenv("SOURCED_GAS_PRICES"),
		os.Getenv("SOURCED_GAS_ADJUSTMENT"),

		os.Getenv("SOURCED_FEES"),
		os.Getenv("SOURCED_FEE_ACCOUNT"),

		os.Getenv("SOURCED_NOTE"),
	}

	switch len(args) {
	case 0:
		s, err := json.MarshalIndent(jcc, "", "\t")
		if err != nil {
			return err
		}

		cmd.Println(string(s))

	case 1:
		// it's a get
		key := args[0]

		switch key {
		case flags.FlagChainID:
			cmd.Println(conf.ChainID)
		case flags.FlagKeyringBackend:
			cmd.Println(conf.KeyringBackend)
		case tmcli.OutputFlag:
			cmd.Println(conf.Output)
		case flags.FlagNode:
			cmd.Println(conf.Node)
		case flags.FlagBroadcastMode:
			cmd.Println(conf.BroadcastMode)

		// Custom flags
		case flags.FlagGas:
			cmd.Println(jcc.Gas)
		case flags.FlagGasPrices:
			cmd.Println(jcc.GasPrices)
		case flags.FlagGasAdjustment:
			cmd.Println(jcc.GasAdjustment)
		case flags.FlagFees:
			cmd.Println(jcc.Fees)
		case flags.FlagFeeAccount:
			cmd.Println(jcc.FeeAccount)
		case flags.FlagNote:
			cmd.Println(jcc.Note)
		default:
			err := errUnknownConfigKey(key)
			return fmt.Errorf("couldn't get the value for the key: %v, error:  %v", key, err)
		}

	case 2:
		// it's set
		key, value := args[0], args[1]

		switch key {
		case flags.FlagChainID:
			jcc.ChainID = value
		case flags.FlagKeyringBackend:
			jcc.KeyringBackend = value
		case tmcli.OutputFlag:
			jcc.Output = value
		case flags.FlagNode:
			jcc.Node = value
		case flags.FlagBroadcastMode:
			jcc.BroadcastMode = value
		case flags.FlagGas:
			jcc.Gas = value
		case flags.FlagGasPrices:
			jcc.GasPrices = value
			jcc.Fees = "" // resets since we can only use 1 at a time
		case flags.FlagGasAdjustment:
			jcc.GasAdjustment = value
		case flags.FlagFees:
			jcc.Fees = value
			jcc.GasPrices = "" // resets since we can only use 1 at a time
		case flags.FlagFeeAccount:
			jcc.FeeAccount = value
		case flags.FlagNote:
			jcc.Note = value
		default:
			return errUnknownConfigKey(key)
		}

		confFile := filepath.Join(configPath, "client.toml")
		if err := writeConfigToFile(confFile, &jcc); err != nil {
			return fmt.Errorf("could not write client config to the file: %v", err)
		}

	default:
		panic("cound not execute config command")
	}

	return nil
}

const defaultConfigTemplate = `# This is a TOML config file.
# For more information, see https://github.com/toml-lang/toml

###############################################################################
###                           Client Configuration                          ###
###############################################################################

# The network chain ID
chain-id = "{{ .ChainID }}"
# The keyring's backend, where the keys are stored (os|file|kwallet|pass|test|memory)
keyring-backend = "{{ .KeyringBackend }}"
# CLI output format (text|json)
output = "{{ .Output }}"
# <host>:<port> to Tendermint RPC interface for this chain
node = "{{ .Node }}"
# Transaction broadcasting mode (sync|async|block)
broadcast-mode = "{{ .BroadcastMode }}"

###############################################################################
###                          Source Tx Configuration                          ###
###############################################################################

# Amount of gas per transaction
gas = "{{ .Gas }}"
# Price per unit of gas (ex: 0.005usource)
gas-prices = "{{ .GasPrices }}"
gas-adjustment = "{{ .GasAdjustment }}"

# Fees to use instead of set gas prices
fees = "{{ .Fees }}"
fee-account = "{{ .FeeAccount }}"

# Memo to include in your Transactions
note = "{{ .Note }}"
`

// writeConfigToFile parses defaultConfigTemplate, renders config using the template and writes it to
// configFilePath.
func writeConfigToFile(configFilePath string, config *SourceCustomClient) error {
	var buffer bytes.Buffer

	tmpl := template.New("clientConfigFileTemplate")
	configTemplate, err := tmpl.Parse(defaultConfigTemplate)
	if err != nil {
		return err
	}

	if err := configTemplate.Execute(&buffer, config); err != nil {
		return err
	}

	return os.WriteFile(configFilePath, buffer.Bytes(), 0o600)
}

// getClientConfig reads values from client.toml file and unmarshalls them into ClientConfig
func getClientConfig(configPath string, v *viper.Viper) (*scconfig.ClientConfig, error) {
	v.AddConfigPath(configPath)
	v.SetConfigName("client")
	v.SetConfigType("toml")

	if err := v.ReadInConfig(); err != nil {
		return nil, err
	}

	conf := new(scconfig.ClientConfig)
	if err := v.Unmarshal(conf); err != nil {
		return nil, err
	}

	return conf, nil
}

func errUnknownConfigKey(key string) error {
	return fmt.Errorf("unknown configuration key: %q", key)
}
