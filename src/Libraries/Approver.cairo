%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_not_equal

from starkware.cairo.common.math_cmp import is_not_zero


@storage_var
func firstSignAddress() -> (res: felt) {
}

@storage_var
func bearer(address: felt) -> (res: felt) {
}


@storage_var
func secondSignAddress() -> (res: felt) {
}

@storage_var
func signed(address: felt) -> (res: felt) {
}

@event
func ApproverAdded(user_account: felt) {
}

@event
func ApproverRemoved(user_account: felt) {
}

namespace Approver {
    @external
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _firstSignAddress: felt, _secondSignAddress: felt, initialApprover: felt
    ) {
        firstSignAddress.write(_firstSignAddress);
        secondSignAddress.write(_secondSignAddress);
        _addApprover(initialApprover);
        return ();
    }

    // # Modifier
    func onlyApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        let (caller) = get_caller_address();
        let _isApprover: felt = isApprover(caller);
        with_attr error_message("Approver::not allowed") {
            assert _isApprover = TRUE;
        }
        return ();
    }

    // # Getters

    @view
    func isApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
        res: felt
    ) {
        let res: felt = has(account);
        return (res,);
    }

    @view
    func isSigned{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) -> (
        res: felt
    ) {
        let res: felt = signed.read(account);
        return (res,);
    }

    @view
    func get_firstSigner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        res: felt
    ) {
        let res: felt = firstSignAddress.read();
        return (res,);
    }

    @view
    func get_secondSigner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        res: felt
    ) {
        let res: felt = secondSignAddress.read();
        return (res,);
    }

    @view
    func isEqual{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        param: felt, param_: felt
    ) -> (res: felt) {
        if (param == param_) {
            return (1,);
        } else {
            return (0,);
        }
    }

    @view
    func getOpposite{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(param: felt) -> (
        res: felt
    ) {
        if (param == TRUE) {
            return (FALSE,);
        } else {
            return (TRUE,);
        }
    }

    // # External Functions

    @external
    func addApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) {
        alloc_locals;
        let _firstSignAddress: felt = firstSignAddress.read();
        let _secondSignAddress: felt = secondSignAddress.read();
        let isSigned_first: felt = signed.read(_firstSignAddress);
        let isSigned_second: felt = signed.read(_secondSignAddress);
        let allSigned: felt = isEqual(isSigned_first, isSigned_second);
        with_attr error_message("Approver::first sign") {
            assert allSigned = 1;
        }
        _addApprover(account);
        signed.write(_firstSignAddress, FALSE);
        signed.write(_secondSignAddress, FALSE);
        return ();
    }

    @external
    func removeApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account: felt
    ) {
        alloc_locals;
        let _firstSignAddress: felt = firstSignAddress.read();
        let _secondSignAddress: felt = secondSignAddress.read();
        let isSigned_first: felt = signed.read(_firstSignAddress);
        let isSigned_second: felt = signed.read(_secondSignAddress);
        let allSigned: felt = isEqual(isSigned_first, isSigned_second);
        with_attr error_message("Approver::first sign") {
            assert allSigned = 1;
        }
        _removeApprover(account);
        signed.write(_firstSignAddress, FALSE);
        signed.write(_secondSignAddress, FALSE);
        return ();
    }

    @external
    func renounceApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        alloc_locals;

        let _firstSignAddress: felt = firstSignAddress.read();
        let _secondSignAddress: felt = secondSignAddress.read();
        let isSigned_first: felt = signed.read(_firstSignAddress);
        let isSigned_second: felt = signed.read(_secondSignAddress);
        let allSigned: felt = isEqual(isSigned_first, isSigned_second);
        let (caller) = get_caller_address();
        assert_not_equal(caller, 0);
        with_attr error_message("Approver::first sign") {
            assert allSigned = 1;
        }
        _removeApprover(caller);
        signed.write(_firstSignAddress, FALSE);
        signed.write(_secondSignAddress, FALSE);
        return ();
    }

    @external
    func add{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account_address: felt
    ) {
        let userStatus: felt = bearer.read(account_address);
        with_attr error_message("Role::already upgraded") {
            assert userStatus = FALSE;
        }
        bearer.write(account_address, TRUE);
        return ();
    }

    @external
    func remove{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account_address: felt
    ) {
        let userStatus: felt = bearer.read(account_address);
        with_attr error_message("Role::upgrade first") {
            assert userStatus = TRUE;
        }
        bearer.write(account_address, FALSE);
        return ();
    }

    func has{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account_address: felt
    ) -> (res: felt) {
        assert_not_equal(account_address, 0);
        let account_status: felt = bearer.read(account_address);
        return (account_status,);
    }

    // # Internal Functions

    func sign{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        alloc_locals;
        let _firstSignAddress: felt = firstSignAddress.read();
        let _secondSignAddress: felt = secondSignAddress.read();
        let (caller) = get_caller_address();
        assert_not_equal(caller, 0);
        let isFirstAddressValid: felt = isEqual(_firstSignAddress, caller);
        let isSecondAddressValid: felt = isEqual(_secondSignAddress, caller);
        let sum: felt = isFirstAddressValid + isSecondAddressValid;
        let res: felt = is_not_zero(sum);
        with_attr error_message("Approver::not signer") {
            assert res = 1;
        }
        let isSigned: felt = signed.read(caller);
        let oppositeStatus: felt = getOpposite(isSigned);
        with_attr error_message("Approver::already signed") {
            assert oppositeStatus = TRUE;
        }
        signed.write(caller, TRUE);
        return ();
    }

    func _addApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(account: felt) {
        add(account);
        ApproverAdded.emit(account);
        return ();
    }

    func _removeApprover{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        account: felt
    ) {
        remove(account);
        ApproverRemoved.emit(account);
        return ();
    }
}