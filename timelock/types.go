package timelock

type ConstructorParams struct {
}

type DecryptParams struct {
	ciphertext []byte
	randomness []byte
}

type DecryptionResult struct {
	message []byte
}
