package simulation

import (
	"os"
)

func loadContract() {
	wasmBz, err := os.ReadFile("../x/wasm/keeper/testdata/test_contract.wasm")
	if err != nil {
		panic(err)
	}

	testContract = wasmBz
}
