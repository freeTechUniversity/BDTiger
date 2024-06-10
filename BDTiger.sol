// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract BDTiger{
    address owner;
    mapping (address => uint) private balances;
    mapping (address => mapping (address => uint)) private allowances;
    string private constant tokenName = "BDTiger";
    string private constant tokenSymbol = "BDT";
    uint8 private constant decimal = 9;
    uint private constant tottalSupply = 10000000000*10**decimal;

    bool public tradingActive = false;
    mapping (address => bool) private excludedFromTradingLock; 



    event Transfer(address indexed from,address indexed to,uint value);
    event Approval(address indexed _owner,address indexed spender,uint value);

    modifier onlyOwner() {
        require(msg.sender == owner,"your are not owner");
        _;
    }

    constructor(){
        owner = msg.sender;
        balances[msg.sender] = tottalSupply;
        excludedFromTradingLock[msg.sender] = true;
        emit Transfer(address(0),msg.sender,tottalSupply);
    }

    function _excludedFromTradingLock(address account) external onlyOwner{
        excludedFromTradingLock[account] = true;
    }

    function enableTrading() external onlyOwner{
        tradingActive = true;
    }

    function _tokenName() external view virtual returns(string memory) {
        return tokenName;
    } 

    function _tokenSymbol() external view virtual returns(string memory){
        return tokenSymbol;
    }

    function _decimal() external view virtual returns(uint8){
        return decimal;
    }

    function _tottalSupply() external view virtual returns(uint){
        return tottalSupply;
    }

    function balanceOf(address account) external view virtual returns(uint){
        return balances[account];
    }

    function _transfer(address to,uint amount) external virtual  returns(bool){
        address _owner = msg.sender;
        require(_owner != to,"ERC20: transfer to address cannot be owner");
        transfer(_owner, to, amount);
        return true;
    }

    function _allowance(address _owner,address spender) public view virtual returns(uint){
        return allowances[_owner][spender];
    }

    function _approve(address spender,uint amount) external virtual returns(bool){
        address _owner = msg.sender;
        approve(_owner,spender,amount);
        return true;
    }

    function transferFrom(address from,address to,uint amount) external virtual returns(bool){
        address spender = msg.sender;
        require(spender != from,"ERC20: transferFrom spender can not be the from");
        spendAllowances(from, spender, amount);
        transfer(from,to,amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns(bool){
        address _owner = msg.sender;
        approve(_owner, spender, _allowance(_owner, spender) + addedValue);
        return true;
    }

    function deccreaseAllowanace(address spender, uint subtracdedValue) external virtual returns(bool){
        address _owner = msg.sender;
        uint cruentAllowances = _allowance(_owner,spender);
        require(cruentAllowances >= subtracdedValue,"ERC20: decreased allowance below zero");
        unchecked {
            approve(_owner,spender,cruentAllowances - subtracdedValue);
        }
        return true;
    }

    function transfer(address from,address to, uint amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        require(tradingActive || excludedFromTradingLock[from] || excludedFromTradingLock[to], "Trading is not active.");


        uint fromBalance = balances[from];
        require(fromBalance >= amount,"ERC20: transfer amount exceeds balance");
        unchecked {
            balances[from] = fromBalance - amount;
        }
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function approve(address _owner,address spender,uint amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function spendAllowances(address _owner,address spender,uint amount) internal virtual {
        uint cruentAllowances = _allowance(_owner,spender);
        if (cruentAllowances != type(uint).max) {
            require(cruentAllowances >= amount,"ERC20: insufficient allowance");

             unchecked {

            approve(_owner,spender,cruentAllowances - amount);
             }

        }

       
    }

}