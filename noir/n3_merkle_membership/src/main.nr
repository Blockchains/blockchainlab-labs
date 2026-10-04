// Lab N3 — Anonymous allowlist: prove a leaf is in a depth-4 Merkle tree without revealing which one.
// Used by privacy pools, Semaphore-style voting and private airdrops.
global DEPTH: u32 = 4;

fn hash2(a: Field, b: Field) -> Field {
    std::hash::pedersen_hash([a, b])
}

fn compute_root(leaf: Field, index: Field, path: [Field; DEPTH]) -> Field {
    let bits: [bool; DEPTH] = index.to_le_bits();
    let mut node = leaf;
    for i in 0..DEPTH {
        node = if !bits[i] {
            hash2(node, path[i])
        } else {
            hash2(path[i], node)
        };
    }
    node
}

fn main(secret: Field, index: Field, path: [Field; DEPTH], root: pub Field, nullifier: pub Field) {
    let leaf = std::hash::pedersen_hash([secret]);
    assert(compute_root(leaf, index, path) == root);
    // nullifier stops the same member claiming twice without linking it to their leaf
    assert(std::hash::pedersen_hash([secret, 1]) == nullifier);
}

// Build a full tree of 16 leaves (secret i+100) in the test and prove membership of a few.
fn tree_and_path(target: u32) -> (Field, [Field; DEPTH]) {
    let mut level: [Field; 16] = [0; 16];
    for i in 0..16 {
        level[i] = std::hash::pedersen_hash([(i + 100) as Field]);
    }
    let mut path: [Field; DEPTH] = [0; DEPTH];
    let mut idx = target;
    let mut width = 16;
    for d in 0..DEPTH {
        path[d] = level[idx ^ 1];
        for j in 0..8 {
            if j < width / 2 {
                level[j] = hash2(level[2 * j], level[2 * j + 1]);
            }
        }
        idx = idx / 2;
        width = width / 2;
    }
    (level[0], path)
}

#[test]
fn test_member_0_and_13() {
    let (root, p0) = tree_and_path(0);
    main(100, 0, p0, root, std::hash::pedersen_hash([100, 1]));
    let (root2, p13) = tree_and_path(13);
    assert(root == root2);
    main(113, 13, p13, root, std::hash::pedersen_hash([113, 1]));
}

#[test(should_fail)]
fn test_non_member_fails() {
    let (root, p) = tree_and_path(3);
    main(999, 3, p, root, std::hash::pedersen_hash([999, 1]));
}

#[test(should_fail)]
fn test_wrong_nullifier_fails() {
    let (root, p) = tree_and_path(3);
    main(103, 3, p, root, std::hash::pedersen_hash([103, 2]));
}
