use starknet::{ContractAddress, Into, TryInto, OptionTrait};
use starknet::syscalls::deploy_syscall;
use result::ResultTrait;
use array::{ArrayTrait, SpanTrait};
use snforge_std::{declare, ContractClassTrait};
use snforge_std::io::{FileTrait, read_txt};
use snforge_std::{start_prank, stop_prank};

use cairo1_v2::{OwnableTraitDispatcher, OwnableTraitDispatcherTrait};

mod Errors {
    const INVALID_OWNER: felt252 = 'Caller is not the owner';
}

mod Accounts {
    use traits::TryInto;
    use starknet::ContractAddress;

    fn admin() -> ContractAddress {
        'admin'.try_into().unwrap()
    }
    fn new_admin() -> ContractAddress {
        'new_admin'.try_into().unwrap()
    }
    fn bad_guy() -> ContractAddress {
        'bad_guy'.try_into().unwrap()
    }
}

fn deploy_contract(name: felt252) -> ContractAddress {
    // let account = Accounts::admin();
    let contract = declare(name);

    let file = FileTrait::new('data/calldata.txt');
    let calldata = read_txt(@file);
    //deploy contract
    contract.deploy(@calldata).unwrap()
}

#[test]
fn test_construct_with_admin() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address };
    let owner = dispatcher.owner();
    assert(owner == Accounts::admin(), Errors::INVALID_OWNER);
}

#[test]
fn test_transfer_ownership() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address };
    start_prank(contract_address, Accounts::admin());
    dispatcher.transfer_ownership(Accounts::new_admin());

    assert(dispatcher.owner() == Accounts::new_admin(), Errors::INVALID_OWNER);
}

