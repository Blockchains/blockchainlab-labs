// Lab N4 — Proof of reserves: prove the sum of private account balances behind a public
// commitment is >= public liabilities, without revealing any individual balance.
global N: u32 = 8;

fn main(balances: [u64; N], salt: Field, commitment: pub Field, liabilities: pub u64) {
    let mut preimage: [Field; N + 1] = [0; N + 1];
    let mut total: u64 = 0;
    for i in 0..N {
        preimage[i] = balances[i] as Field;
        total += balances[i]; // u64 overflow is a constraint failure, so no wrap-around trick
    }
    preimage[N] = salt;
    assert(std::hash::pedersen_hash(preimage) == commitment);
    assert(total >= liabilities);
}

fn commit(b: [u64; N], salt: Field) -> Field {
    let mut p: [Field; N + 1] = [0; N + 1];
    for i in 0..N {
        p[i] = b[i] as Field;
    }
    p[N] = salt;
    std::hash::pedersen_hash(p)
}

#[test]
fn test_solvent() {
    let b = [100, 250, 0, 75, 1000, 5, 5, 65];
    main(b, 9, commit(b, 9), 1500);
}

#[test(should_fail)]
fn test_insolvent() {
    let b = [100, 250, 0, 75, 1000, 5, 5, 65];
    main(b, 9, commit(b, 9), 1501);
}

#[test(should_fail)]
fn test_inflated_balances_break_commitment() {
    let real = [100, 250, 0, 75, 1000, 5, 5, 65];
    let fake = [100, 250, 0, 75, 9000, 5, 5, 65];
    main(fake, 9, commit(real, 9), 5000);
}
