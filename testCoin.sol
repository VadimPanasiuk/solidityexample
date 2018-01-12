pragma solidity ^0.4.17;
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;
 
  mapping(address => uint256) balances;
 
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}
contract Ownable {
    
  address public owner;
 
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }
 
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}
contract TestTokenCoin is StandardToken{
    
    string public constant name = "TestTokenCoin Token";
    
    string public constant symbol = "TTTT";
    
    uint32 public constant decimals = 3;
    
    uint256 public initialSupply = 1000000 * 1000;
 
  function TestTokenCoin() {
      
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
  }
    
}
contract simpleList is StandardToken {
  struct EntityStruct {
    address entityAddress;
    uint entityData;
    // more fields
  }
  EntityStruct[] public entityStructs;
  function newEntity(address entityAddress, uint entityData) public returns(uint rowNumber) {
    if (balances[entityAddress] == 0) {
    EntityStruct memory newEntity;
    newEntity.entityAddress = entityAddress;
    newEntity.entityData    = entityData;
    return entityStructs.push(newEntity)-1;
    }
  }
  function getEntityCount() public constant returns(uint entityCount) {
    return entityStructs.length;
  }
}
contract CrowdsaleTest is Ownable, TestTokenCoin, simpleList   {
  using SafeMath for uint;
    
  address multisig;
 
  address restricted;
 
  uint start;
    
  uint period;
 
  uint rate;
  
  uint256  totoal;
  
  uint restrictedTokens;
  
  event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
 
  function CrowdsaleTest()  {
    // The address to which the ether will be transferred
    multisig = 0x583031d1113ad414f02576bd6afabfb302140225;
    // The address to which tokens will be listed for the needs of the team
    restricted = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
    // 15% - for marketing; 10% - for team;
    rate = 1000;
    restrictedTokens = 250000 * rate;
    // 22 Sept 2017 01.00
    start = 1506211200;
    // Crowdsale period 15 days
    period = 15;
    
    transferTestCoin(restricted, restrictedTokens);
    
  }
  
  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }
  
  function transferTestCoin(address _to, uint _value) internal {
    
    // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balances[owner] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balances[owner] + balances[_to];
        // Subtract from the sender
        balances[owner] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(owner, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[owner] + balances[_to] == previousBalances);
    
    
//     totalSupply = totalSupply.sub(_value);
// 	balances[_to] = balances[_to].add(_value);
  }
  
  function() external payable {
    buyTokens();
  }
 
  function buyTokens() saleIsOn payable {
    
    address beneficiary = msg.sender;
    uint amount = (msg.value).div(1 ether).mul(rate);
    
    uint amountWithBonus = calculateAmountWithBunus(amount);
    
    simpleList.newEntity(beneficiary, amountWithBonus);
    
	transferTestCoin(beneficiary, amountWithBonus);
	TokenPurchase(beneficiary, msg.value, amountWithBonus);
	
	forwardFunds();
    
  }
  
  function calculateAmountWithBunus(uint tokens) internal returns (uint256) {
      uint resultAmount;
    if(now < start + (period * 1 days).add(1)) {    
        // 1 day
        resultAmount = tokens.mul(500);
    } else if(now < start.add(period * 1 days).add(5)) {
        // 1 - 5 days
        resultAmount = tokens.mul(400);
    } else if(now < start.add(period * 1 days).add(10)) {
        // 5 - 10 days
        resultAmount = tokens.mul(300);
    } else if(now < start.add(period * 1 days).add(15)) {
        // 10 - 15 days
        resultAmount = tokens.mul(250);
    }
    return resultAmount;
  }
 
 function finishSale() onlyOwner {
    uint256 remainder = balances[owner];
     for( uint256 i = 0; i < getEntityCount(); i ++) {
         address saler = entityStructs[i].entityAddress;
         transferTestCoin(saler, getFinishBonus(saler, remainder));
     }
 }
 
 function getFinishBonus(address _address, uint256 _remainder ) internal returns (uint256){
    // when sale is end
    uint256 bought = balances[_address];
    // ???
    uint256 percentageOfPurchased = bought.div((totalSupply.sub(_remainder).sub(restrictedTokens)).div(100));
    uint256 finishBonus = _remainder.div(100).mul(percentageOfPurchased);
     return finishBonus;
 }
 
 function forwardFunds() internal {
     multisig.transfer(msg.value);
 }
    
}
