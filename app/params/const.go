package params

const (
	// Name defines the application name of the Source network.
	Name = "usource"

	// BondDenom defines the native staking token denomination.
	BondDenom = "usource"

	// DisplayDenom defines the name, symbol, and display value of the Source token.
	DisplayDenom = "SOURCE"

	// DefaultGasLimit - set to the same value as cosmos-sdk flags.DefaultGasLimit
	// this value is currently only used in tests.
	DefaultGasLimit = 200000
)
