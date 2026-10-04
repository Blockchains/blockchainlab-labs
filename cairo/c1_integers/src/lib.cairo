//! Lab C1 — Cairo numeric types: felt252 wraps modulo the STARK prime; uN integers panic on
//! overflow.

pub fn add_u8(a: u8, b: u8) -> u8 {
    a + b
}

pub fn felt_sub(a: felt252, b: felt252) -> felt252 {
    a - b
}

pub fn checked_add_u8(a: u8, b: u8) -> Option<u8> {
    core::num::traits::CheckedAdd::checked_add(a, b)
}

pub fn u256_mul(a: u256, b: u256) -> u256 {
    a * b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn felt_wraps_mod_p() {
        // 0 - 1 == P - 1, where P = 2^251 + 17 * 2^192 + 1
        let p_minus_1: felt252 = 0x800000000000011000000000000000000000000000000000000000000000000;
        assert(felt_sub(0, 1) == p_minus_1, 'felt wraps');
    }

    #[test]
    #[should_panic(expected: ('u8_add Overflow',))]
    fn u8_overflow_panics() {
        add_u8(200, 100);
    }

    #[test]
    fn checked_add() {
        assert(checked_add_u8(200, 55) == Option::Some(255), 'fits');
        assert(checked_add_u8(200, 56).is_none(), 'overflow is None');
    }

    #[test]
    fn u256_is_two_u128_limbs() {
        let x: u256 = u256_mul(0x100000000000000000000000000000000, 3); // 3 * 2^128
        assert(x.low == 0, 'low limb');
        assert(x.high == 3, 'high limb');
    }
}
