//! Lab C2 — Ownership, snapshots, arrays, structs and traits (Cairo's linear type system).

#[derive(Drop, Copy, PartialEq, Debug)]
pub struct Position {
    pub size: u128,
    pub entry_price: u128,
}

pub trait PnlTrait {
    fn pnl(self: @Position, mark: u128) -> i128;
}

impl PnlImpl of PnlTrait {
    fn pnl(self: @Position, mark: u128) -> i128 {
        let p = *self;
        let mark_i: i128 = mark.try_into().unwrap();
        let entry_i: i128 = p.entry_price.try_into().unwrap();
        let size_i: i128 = p.size.try_into().unwrap();
        (mark_i - entry_i) * size_i
    }
}

/// Arrays are append-only; we take a snapshot (@) so the caller keeps ownership.
pub fn sum(xs: @Array<u64>) -> u64 {
    let mut total = 0;
    for x in xs.span() {
        total += *x;
    }
    total
}

pub fn fib(n: u32) -> Array<u64> {
    let mut out = array![0_u64, 1_u64];
    let mut i = 2;
    while i < n {
        let a = *out.at(i - 2);
        let b = *out.at(i - 1);
        out.append(a + b);
        i += 1;
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn snapshot_keeps_ownership() {
        let xs = array![1, 2, 3, 4];
        assert(sum(@xs) == 10, 'sum');
        assert(xs.len() == 4, 'still owned'); // usable after the call
    }

    #[test]
    fn fibonacci() {
        let f = fib(10);
        assert(f.len() == 10, 'len');
        assert(*f.at(9) == 34, 'fib(9)');
    }

    #[test]
    fn trait_on_struct() {
        let p = Position { size: 2, entry_price: 100 };
        assert(p.pnl(130) == 60, 'long profit');
        assert(p.pnl(90) == -20, 'long loss');
    }
}
