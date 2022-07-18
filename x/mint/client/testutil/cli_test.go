//go:build norace
// +build norace

package testutil

import (
	"testing"

	"github.com/Source-Protocol-Cosmos/source/v2/testutil/network"

	"github.com/stretchr/testify/suite"
)

func TestIntegrationTestSuite(t *testing.T) {
	cfg := network.DefaultConfig()
	cfg.NumValidators = 1
	suite.Run(t, NewIntegrationTestSuite(cfg))
}
