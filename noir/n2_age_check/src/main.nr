// Lab N2 — Selective disclosure: prove birth_year <= current_year - 18 without revealing the year.
// The credential commitment binds the private birth year to a public identifier.
fn main(birth_year: u32, salt: Field, current_year: pub u32, commitment: pub Field) {
    assert(std::hash::pedersen_hash([birth_year as Field, salt]) == commitment);
    assert(birth_year + 18 <= current_year);
}

#[test]
fn test_adult_passes() {
    let c = std::hash::pedersen_hash([1990, 77]);
    main(1990, 77, 2026, c);
}

#[test]
fn test_exactly_18_passes() {
    let c = std::hash::pedersen_hash([2008, 5]);
    main(2008, 5, 2026, c);
}

#[test(should_fail)]
fn test_minor_fails() {
    let c = std::hash::pedersen_hash([2010, 5]);
    main(2010, 5, 2026, c);
}

#[test(should_fail)]
fn test_lying_about_year_fails() {
    // commitment was made for 2010; prover tries to use 1990
    let c = std::hash::pedersen_hash([2010, 5]);
    main(1990, 5, 2026, c);
}
