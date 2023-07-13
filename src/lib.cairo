use starknet::ContractAddress;

#[starknet::interface]
trait OwnableTrait<T> {
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn get_owner(self: @T) -> ContractAddress;
}
#[starknet::contract]
mod Ownable {
    use super::ContractAddress;
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        owner: ContractAddress, 
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_owner: ContractAddress) {
        self.owner.write(init_owner);
    }

    #[external(v0)]
    impl OwnableImpl of super::OwnableTrait<ContractState> {
        //external method
        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let prev_owner = self.owner.read();
            self.owner.write(new_owner);
            let ownershipTransferred = OwnershipTransfered {
                prev_owner: prev_owner, new_owner: new_owner, 
            };
            self.emit(Event::OwnershipTrasnfered(ownershipTransferred));
        }
        //internal method
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not the owner');
        }
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTrasnfered: OwnershipTransfered, 
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransfered {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }
}
