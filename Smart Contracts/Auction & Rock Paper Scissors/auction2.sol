pragma solidity >=0.7.0 <0.9.0;

contract auction2
{
    mapping(address=>bytes32) bidding_Hash;    
    uint start_time;
    address payable winner;
    address payable owner;
    uint largest_Bid=0;
    uint refund;
    uint num_of_bids =0;
    uint number_of_calls=0;
    uint counter =0;

    constructor(uint guarante_fee)
    {
        owner = payable(msg.sender);
        start_time = block.number;
        refund = guarante_fee* 1 ether;
    }

    function join_Bidding(bytes32 bid_hash) payable public
    {
        require(msg.value==refund);
        require((block.number-start_time)<=5000);
        number_of_calls++;
        require(number_of_calls<=1);
        bidding_Hash[msg.sender]=bid_hash;
        number_of_calls--;
        num_of_bids++;
    }

    function reveal(uint nounce) payable public
    {
        require((block.number-start_time)>5000);
        uint price= msg.value;
        address payable bidder = payable(msg.sender);
        require(sha256(abi.encode(price,nounce))==bidding_Hash[bidder],"Wrong hashes");
        uint refund_value = refund;
        if(price>largest_Bid)
        {
            number_of_calls++;
            require(number_of_calls<=1);
            address payable temp_address = winner;
            uint temp_price = largest_Bid;                      
            winner=bidder;
            largest_Bid=price;
            if(counter>0){
                temp_address.send(temp_price);
            }
            number_of_calls--;              
        }
        else
        {
            refund_value+=msg.value;
        }
        require(number_of_calls<=1);
        number_of_calls++;
        bidder.send(refund_value);
        number_of_calls--;
        counter++;
    }
    
    function get_unrereveal_guarante_fee() public
    {
        require((block.number-start_time)>10000);
        owner.send((num_of_bids-counter)*refund);
    }

}