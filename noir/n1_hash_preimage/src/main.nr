// Lab N1 — Prove you know a secret whose Pedersen hash is public, without revealing it.
fn main(secret: Field, hash: pub Field) {
    assert(std::hash::pedersen_hash([secret]) == hash);
}

#[test]
fn test_valid_preimage() {
    let secret = 1234567;
    main(secret, std::hash::pedersen_hash([secret]));
}

#[test(should_fail)]
fn test_wrong_preimage_rejected() {
    main(42, std::hash::pedersen_hash([43]));
}
