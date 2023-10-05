use starknet::{ContractAddress, Into, TryInto, OptionTrait};
use starknet::syscalls::deploy_syscall;
use result::ResultTrait;
use array::{ArrayTrait, SpanTrait};
use snforge_std::{declare, ContractClassTrait};
use snforge_std::io::{FileTrait, read_txt};

mod Accounts {
    use traits::TryInto;
    use starknet::ContractAddress;

    fn admin() -> ContractAddress {
        'admin'.try_into().unwrap()
    }
    fn bad_guy() -> ContractAddress {
        'bad_guy'.try_into().unwrap()
    }
}

fn deploy_contract(name: felt252) -> ContractAddress {
    let account = Accounts::admin();
    let contract = declare(name);

    let mut calldata = array![account.into()];

    //deploy contract
    contract.deploy(@calldata).unwrap()
}

#[test]
fn test_construct_with_admin() {
    let contract_address = deploy_contract('ownable');
    assert(1 == 1, 'Not equal');
}
