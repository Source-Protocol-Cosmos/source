package app

import (
	wasmkeeper "github.com/CosmWasm/wasmd/x/wasm/keeper"
)

const (
	// DefaultSourceInstanceCost is initially set the same as in wasmd
	DefaultSourceInstanceCost uint64 = 60_000
	// DefaultSourceCompileCost set to a large number for testing
	DefaultSourceCompileCost uint64 = 100
)

// SourceGasRegisterConfig is defaults plus a custom compile amount
func SourceGasRegisterConfig() wasmkeeper.WasmGasRegisterConfig {
	gasConfig := wasmkeeper.DefaultGasRegisterConfig()
	gasConfig.InstanceCost = DefaultSourceInstanceCost
	gasConfig.CompileCost = DefaultSourceCompileCost

	return gasConfig
}

func NewSourceWasmGasRegister() wasmkeeper.WasmGasRegister {
	return wasmkeeper.NewWasmGasRegister(SourceGasRegisterConfig())
}
