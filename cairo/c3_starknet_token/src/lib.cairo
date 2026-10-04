//! Lab C3 — A minimal Starknet token contract: storage maps, events, caller checks,
//! deployed and called in a test with deploy_syscall and the generated dispatcher.

#[starknet::interface]
pub trait IToken<T> {
    fn balance_of(self: @T, account: starknet::ContractAddress) -> u256;
    fn total_supply(self: @T) -> u256;
    fn transfer(ref self: T, to: starknet::ContractAddress, amount: u256);
    fn mint(ref self: T, to: starknet::ContractAddress, amount: u256);
}

#[starknet::contract]
pub mod Token {
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        supply: u256,
        balances: Map<ContractAddress, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Transfer {
        #[key]
        pub from: ContractAddress,
        #[key]
        pub to: ContractAddress,
        pub amount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl TokenImpl of super::IToken<ContractState> {
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.supply.read()
        }

        fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) {
            let from = get_caller_address();
            let bal = self.balances.read(from);
            assert(bal >= amount, 'insufficient balance');
            self.balances.write(from, bal - amount);
            self.balances.write(to, self.balances.read(to) + amount);
            self.emit(Transfer { from, to, amount });
        }

        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) {
            assert(get_caller_address() == self.owner.read(), 'only owner');
            self.supply.write(self.supply.read() + amount);
            self.balances.write(to, self.balances.read(to) + amount);
            self.emit(Transfer { from: 0.try_into().unwrap(), to, amount });
        }
    }
}

#[cfg(test)]
mod tests {
    use starknet::syscalls::deploy_syscall;
    use starknet::testing::set_caller_address;
    use starknet::{ContractAddress, SyscallResultTrait};
    use super::{ITokenDispatcher, ITokenDispatcherTrait, Token};

    fn addr(x: felt252) -> ContractAddress {
        x.try_into().unwrap()
    }

    fn deploy(owner: ContractAddress) -> ITokenDispatcher {
        let (a, _) = deploy_syscall(
            Token::TEST_CLASS_HASH.try_into().unwrap(), 0, array![owner.into()].span(), false,
        )
            .unwrap_syscall();
        ITokenDispatcher { contract_address: a }
    }

    #[test]
    fn mint_and_transfer() {
        let owner = addr(0x111);
        let t = deploy(owner);
        set_caller_address(owner);
        starknet::testing::set_contract_address(owner);
        t.mint(owner, 1000);
        t.transfer(addr(0x222), 250);
        assert(t.balance_of(owner) == 750, 'owner bal');
        assert(t.balance_of(addr(0x222)) == 250, 'recipient bal');
        assert(t.total_supply() == 1000, 'supply');
    }

    #[test]
    #[should_panic]
    fn non_owner_cannot_mint() {
        let t = deploy(addr(0x111));
        starknet::testing::set_contract_address(addr(0x999));
        t.mint(addr(0x999), 1);
    }

    #[test]
    #[should_panic]
    fn cannot_overspend() {
        let owner = addr(0x111);
        let t = deploy(owner);
        starknet::testing::set_contract_address(owner);
        t.mint(owner, 10);
        t.transfer(addr(0x222), 11);
    }
}
