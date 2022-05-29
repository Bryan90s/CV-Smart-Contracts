pragma solidity >=0.7.0 <0.9.0;


contract CertificateOfDeposit
{
    uint256 _c;
    uint256 _N;
    address owner;
    mapping (uint=>bool) unsign_deposit;
    mapping (uint=>uint) deposit_block_num;
    mapping (uint=>uint) signed_deposit;
    mapping (uint256=>bool) record;
    mapping (uint=>address) deposit_sender;
    uint deposit_counter=0;
    uint _f;

    constructor(uint256 public_key, uint256 modular_N,uint handling_fee)
    {   
        owner = msg.sender;
        _c=public_key;
        _N=modular_N;
        _f= handling_fee;
    }

    function deposit(uint message_hash) public payable
    {
        require(!unsign_deposit[message_hash]);
        require(msg.value>=(1 +_f)*1 ether);
        unsign_deposit[message_hash]=true;
        deposit_sender[message_hash]=msg.sender;
        deposit_block_num[message_hash]=block.number;
        deposit_counter++;
    }

    uint counter=0;
    function refund_deposit(uint message_hash) public
    {
        require(block.number>=deposit_block_num[message_hash]+5000);
        require(deposit_sender[message_hash]==msg.sender);
        require(counter==0);
        counter++;
        delete unsign_deposit[message_hash];
        delete deposit_sender[message_hash];
        delete deposit_block_num[message_hash];
        address payable reciver = payable(msg.sender);
        reciver.transfer((1 +_f)*1 ether);
        deposit_counter--;
        counter=0;
    }

    function get_Message_Hash_int_mod_N(string memory message) public returns (uint) 
    {
        uint mh_mN = uint(sha256(abi.encodePacked(message)));
        return mh_mN % _N;
    }

    function set_signature(uint message_hash,uint signed_hash) public
    {
        require(unsign_deposit[message_hash]==true);
        signed_deposit[message_hash]=signed_hash;
        delete unsign_deposit[message_hash];
        delete deposit_sender[message_hash];
        delete deposit_block_num[message_hash];
    }

    function get_signed_message(uint message_hash)public returns (uint)
    {
        return signed_deposit[message_hash];
    }

    
    function withdrawl(string memory _s, uint256 cd)public 
    {
        require(!record[cd]);
        bytes32 _hs = sha256(abi.encodePacked(_s));
        uint _hsmodN = uint(_hs)%_N;
        
        record[cd]=true;
        uint cal_hsmN = pow_of_c_mod_n(cd);
        require(_hsmodN == cal_hsmN);
        require(counter==0);
        counter++;
        address payable reciver = payable(msg.sender);
        reciver.transfer(1 ether);
        deposit_counter--;
        counter=0;     
    }

    function pow_of_c_mod_n(uint cd)public returns (uint)
    {
        uint c=_c;
        uint _ans=1;
        uint cd_m_n = cd%_N;
        while (c>0){
            if(c%2==1)
            {
                _ans *= cd_m_n;
                _ans= _ans%_N;
            }
            cd_m_n = (cd_m_n*cd_m_n)%_N;
            c=c/2;
        }
        return _ans;
    }

    function recieve_handling_fee()public
    {
        require(msg.sender==owner);
        require(deposit_counter==0);
        address payable reciver =payable(owner);
    }
}