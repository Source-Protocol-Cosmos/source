package main

import (
	"os"

	"github.com/Source-Protocol-Cosmos/source/v3/app"
	"github.com/Source-Protocol-Cosmos/source/v3/cmd/sourced/cmd"
	"github.com/cosmos/cosmos-sdk/server"

	svrcmd "github.com/cosmos/cosmos-sdk/server/cmd"
)

func main() {
	app.SetAddressPrefixes()
	rootCmd, _ := cmd.NewRootCmd()

	if err := svrcmd.Execute(rootCmd, app.DefaultNodeHome); err != nil {
		switch e := err.(type) {
		case server.ErrorCode:
			os.Exit(e.Code)

		default:
			os.Exit(1)
		}
	}
}
