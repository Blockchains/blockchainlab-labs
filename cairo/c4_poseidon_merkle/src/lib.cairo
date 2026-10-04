//! Lab C4 — Poseidon Merkle proofs, the STARK-friendly hash used across Starknet.
use core::poseidon::poseidon_hash_span;

pub fn hash_pair(a: felt252, b: felt252) -> felt252 {
    // sorted-pair hashing: proofs need no left/right flags (same scheme as OpenZeppelin's
    // MerkleProof)
    let (lo, hi) = if Into::<felt252, u256>::into(a) < b.into() {
        (a, b)
    } else {
        (b, a)
    };
    poseidon_hash_span(array![lo, hi].span())
}

pub fn verify(root: felt252, leaf: felt252, proof: Span<felt252>) -> bool {
    let mut node = leaf;
    for sibling in proof {
        node = hash_pair(node, *sibling);
    }
    node == root
}

#[cfg(test)]
mod tests {
    use super::*;

    fn leaves() -> Array<felt252> {
        array![
            poseidon_hash_span(array!['alice', 100].span()),
            poseidon_hash_span(array!['bob', 250].span()),
            poseidon_hash_span(array!['carol', 75].span()),
            poseidon_hash_span(array!['dave', 10].span()),
        ]
    }

    #[test]
    fn valid_proofs_for_every_leaf() {
        let l = leaves();
        let n01 = hash_pair(*l.at(0), *l.at(1));
        let n23 = hash_pair(*l.at(2), *l.at(3));
        let root = hash_pair(n01, n23);
        assert(verify(root, *l.at(0), array![*l.at(1), n23].span()), 'alice');
        assert(verify(root, *l.at(1), array![*l.at(0), n23].span()), 'bob');
        assert(verify(root, *l.at(2), array![*l.at(3), n01].span()), 'carol');
        assert(verify(root, *l.at(3), array![*l.at(2), n01].span()), 'dave');
    }

    #[test]
    fn tampered_amount_rejected() {
        let l = leaves();
        let n23 = hash_pair(*l.at(2), *l.at(3));
        let root = hash_pair(hash_pair(*l.at(0), *l.at(1)), n23);
        let forged = poseidon_hash_span(array!['alice', 1000].span());
        assert(!verify(root, forged, array![*l.at(1), n23].span()), 'forged leaf');
    }
}
