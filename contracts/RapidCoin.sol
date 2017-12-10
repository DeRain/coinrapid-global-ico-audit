pragma solidity ^0.4.16;
contract Ownable {
    address public owner;

        modifier onlyOwner() { //This modifier is for checking owner is calling
        if (owner == msg.sender) {
            _;
        } else {
            revert();
        }

    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Mortal is Ownable {
    
    function kill()  public{
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}
contract Pausable is Mortal {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause()public onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause()public onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
 contract BasicToken is ERC20Basic, Pausable {
  using SafeMath for uint256;
  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public  returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
        require(_from != 0x0); //check addres is valid
        require(_to != 0x0); //check addres is valid
        require(_value > 0);
        if (balances[_from] >= _value && allowance(_from, _to) >= _value) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][_to] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract RapidCoin is StandardToken {
    string public constant name = 'Rapidpay';
    uint public constant decimals = 18;
    string public constant symbol = 'RDP';
    string public constant version = '1.0';
    uint amountRaised;
    uint public priceOfTokenPREICO=500000000000000;// 1 ETH = 2000 RDP
    uint public priceOfToken = 833333330000000; //1 ETH  =  1200 RDP
    uint256 tokenSaleLimit;
    uint256 preSaleStartDate;
    uint256 preSaleEndDate;
    uint256 saleStartDate;
    uint256 saleEndDate;

    //TODO presale 4 weeks but full sale start after 4 week
    function RapidCoin () public {
        totalSupply = 10 * (10 ** 9) * (10 ** decimals); //10 billion
        tokenSaleLimit = 475 * (10 ** 7) * (10 ** decimals); //4.75 billions
        uint256 ownerTokens = totalSupply ; //we assign 10 million to acccountant firstly. 
        balances[msg.sender] = ownerTokens;
        amountRaised = 0;
        owner = msg.sender;
        preSaleStartDate = now;//1516840000000; //January 25 2018 00 : 00  UTC
        preSaleEndDate = 1519611199999; // FEB 26 2018 00 : 00 UTC
        saleStartDate = 1516840000000; //January 25 2018 00 : 00  UTC
        saleEndDate = 1515571199000; //January 10 2018 UTC 8 AM and 4 week after presale
    }
    function () payable whenNotPaused {
        require(msg.sender !=0x0);
        require(now>=preSaleStartDate);
        require(now<=saleEndDate);
        uint256 tokens =0;
        if(now<preSaleEndDate){
            //presLe handle
             tokens = (msg.value * (10 ** decimals)) / priceOfTokenPREICO;
             uint bonus = 0;
             if(now < (preSaleStartDate  + 7 * 1  days)){
                 bonus = 10;
             }else if (now < (preSaleStartDate  +14 * 1  days)){
                 bonus = 5;
             }
            uint bonusTokens = (tokens * bonus) /100;
            tokens += bonusTokens;
            
        }
        else if(now>saleStartDate){
            //here sale start date
            tokens = (msg.value * (10 ** decimals)) / priceOfToken;
        }//end of else if for sale start date
        else {
            revert(); //this revert is between pre sale and sale time gap
        }
        allowed[owner][msg.sender]+=tokens;
        bool result =  transferFrom(owner,msg.sender,tokens);
    }//end of function callback
    
    //function ext

    /**
    * Transfer entire balance to any account (by owner and admin only)
    **/
    function transferFundToAccount(address _accountByOwner) public onlyOwner {
        require(amountRaised > 0);
        _accountByOwner.transfer(amountRaised);
    }

    function resetTokenOfAddress(address _userAdd)public onlyOwner {
      uint256 userBal=  balances[_userAdd] ;
      balances[_userAdd] = 0;
      balances[owner] +=userBal;
    }
    /**
    * Transfer part of balance to any account (by owner and admin only)
    **/
    function transferLimitedFundToAccount(address _accountByOwner, uint256 balanceToTransfer) public onlyOwner   {
        require(amountRaised > balanceToTransfer);
        _accountByOwner.transfer(balanceToTransfer);
        amountRaised -= balanceToTransfer;
    }
    
       /**
   * @dev called by the owner to extend deadline relative to last deadLine Time,
   * to accept ether and transfer tokens
   */
   function extendDeadline(uint daysToExtend)public onlyOwner{
       saleEndDate = saleEndDate +daysToExtend * 1 days;
   }

}//end of contract
