# @version 0.3.10
"""
@dev
    this contract uses `token_id` instead of `id` for greater clarity
"""

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    token_id: indexed(uint256)  # FIXME EIP says address and it's wrong
    amount: uint256  # FIXME EIP says address here

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    token_id: indexed(uint256)
    amount: uint256


event OperatorSet:
    owner: indexed(address)
    spender: indexed(address)
    approved: bool


# token_id -> amount
totalSupply: public(HashMap[uint256, uint256])

# owner -> token_id -> amount
balanceOf: public(HashMap[address, HashMap[uint256, uint256]])

# owner -> spender -> id -> amount
allowance: public(HashMap[address, HashMap[address, HashMap[uint256, uint256]]])

# owner -> spender -> status
isOperator: public(HashMap[address, HashMap[address, bool]])


@external
def transfer(receiver: address, token_id: uint256, amount: uint256) -> bool:
    # FIXME add return bool in the EIP
    assert receiver not in [empty(address), self]

    self.balanceOf[msg.sender][token_id] -= amount
    self.balanceOf[receiver][token_id] += amount

    log Transfer(msg.sender, receiver, token_id, amount)
    return True


@external
def transferFrom(sender: address, receiver: address, token_id: uint256, amount: uint256) -> bool:
    """
    @dev doesn't log Approval when allowance is modified
    """
    # FIXME add return bool in the EIP
    assert receiver not in [empty(address), self]

    allowance: uint256 = self.allowance[sender][msg.sender][token_id]
    is_operator: bool = self.isOperator[sender][msg.sender]

    assert is_operator or allowance >= amount  # dev: must be operator of have sufficient allowance
    if not is_operator and allowance != max_value(uint256):
        self.allowance[sender][msg.sender][token_id] -= amount  # dev: insufficient allowance
    
    self.balanceOf[sender][token_id] -= amount
    self.balanceOf[receiver][token_id] += amount

    log Transfer(sender, receiver, token_id, amount)
    return True


@external
def approve(spender: address, token_id: uint256, amount: uint256) -> bool:
    # FIXME return bool in EIP
    self.allowance[msg.sender][spender][token_id] = amount

    log Approval(msg.sender, spender, token_id, amount)
    return True


@external
def setOperator(spender: address, approved: bool) -> bool:
    """
    @dev may log SetOperator if no change
    """
    self.isOperator[msg.sender][spender] = approved

    log OperatorSet(msg.sender, spender, approved)
    return True

