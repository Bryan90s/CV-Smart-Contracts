pragma solidity >=0.7.0 <0.9.0;

contract rps
{
    address payable Alice;
    address payable Bob;
    mapping(address => bytes32) rps_hash;
    mapping(address => bool) revealed;
    mapping(address => uint) choice;
    mapping(address=>uint) reward;
    uint number_of_players=0;
    uint start_block;
    
    constructor()
    {
        start_block=block.number;
    }

    function SetChoiceHash(bytes32 my_rps_hash) public payable
    {
        require(block.number<start_block+2500);
        require(number_of_players<2);
        require(msg.value == 1 ether);
        if(number_of_players==0){
            Alice = payable(msg.sender);
            rps_hash[Alice]=my_rps_hash;
            revealed[Alice]=false;
        }
        if(number_of_players==1){
            Bob = payable(msg.sender);
            rps_hash[Bob]=my_rps_hash;
            revealed[Bob]=false;
        }              
        number_of_players++;
    }

    uint number_of_calls=0;
    function revealChoice(uint rps_choice,uint nounce) public
    {
        require(block.number<start_block+5000);
        require(number_of_players==2);
        address payable winner;
        if(msg.sender == Alice && !revealed[Alice])
        {
            require(sha256(abi.encode(rps_choice,nounce))==rps_hash[Alice],"hashes not match");
            choice[Alice]=rps_choice;
            revealed[Alice]=true;
        }
        else if(msg.sender == Bob && !revealed[Bob])
        {
            require(sha256(abi.encode(rps_choice,nounce))==rps_hash[Bob],"hashes not match");
            choice[Bob]=rps_choice;
            revealed[Bob]=true;
        }
        if(revealed[Alice] && revealed[Bob])
        {
            uint Alice_rps = choice[Alice]%3;
            uint Bob_rps =choice[Bob]%3;
            bool draw=false;
            if(Alice_rps == Bob_rps)
            {
                reward[Alice]=1;
                reward[Bob]=1;
            }
            else if(Alice_rps == 0)
            {
                if(Bob_rps ==1)
                {
                    reward[Alice]=0;
                    reward[Bob]=2;
                }
                else
                {
                    reward[Alice]=2;
                    reward[Bob]=0;
                }
            }
            else if(Alice_rps == 1)
            {
                if(Bob_rps ==2)
                {
                    reward[Alice]=0;
                    reward[Bob]=2;
                }
                else
                {
                    reward[Alice]=2;
                    reward[Bob]=0;
                }
            }
            else if(Alice_rps == 2)
            {
                if(Bob_rps ==0)
                {
                    reward[Alice]=0;
                    reward[Bob]=2;
                }
                else
                {
                    reward[Alice]=2;
                    reward[Bob]=0;
                }
            }
        }
    }

    function claim_reward() public
    {
        address payable reciever = payable(msg.sender);
        require(reward[reciever]>0,"Sorry, you lose, no reward");
        require(number_of_calls==0);
        number_of_calls++;       
        reciever.send(reward[reciever]* (1 ether));
        number_of_calls--;
    }

    function reveal_cheating() public
    {
        require(block.number>start_block+5000);
        if(revealed[Alice] && !revealed[Bob])
        {
            Alice.send(address(this).balance);
        }
        if(revealed[Bob] && !revealed[Alice])
        {
            Bob.send(address(this).balance);
        }
    }

}