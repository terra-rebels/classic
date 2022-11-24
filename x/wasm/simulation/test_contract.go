
package simulation

import (
	"io/ioutil"
)

func loadContract() {
	
	wasmBz, err := ioutil.ReadFile("../x/wasm/keeper/testdata/test_contract.wasm")
	
	if err != nil {
		panic(err)
	}
	
	testContract = wasmBz

}
