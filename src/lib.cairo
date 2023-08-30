use starknet::account::Call;

#[starknet::interface]
trait IAccount<T> {
    fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
    // fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[starknet::contract]
mod Account {
    use super::IAccount;
    use ecdsa::check_esdsa_signature;
    #[storage]
    struct Storage {
        public_key: felt252
    }
    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.public_key.write(public_key)
    }
    #[external(v0)]
    impl AccountImpl of IAccount<ContractState> {
        fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252 {
            let is_valid_length = signature.len() == 2_u32;
            if !is_valid_length {
                return 0;
            }
            let is_valid = check_esdsa_signature(hash, self.public_key.read(0),*signature.at(0_32),*signature.at(1_32));
            if is_valid { 'VALID' } else { 0 };
        }
    }
    //#[external(v0)]
    // #[generate_trait]
    // impl ProtocolImpl of ProtocolTrait {
    //    fn __execute__(calls: Array<Call>) -> Array<Span<felt252>>;
     //   fn __validate__(calls: Array<Call>) -> felt252;
    // }
}