//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

contract KYC{

    address  admin  ;// initialize with deployer's address

    constructor()  {
        admin = msg.sender;
    }

    modifier onlyAdmin {
    require(msg.sender == admin);
    _;
    }

    modifier onlyValidBank {
        require (msg.sender == banks[msg.sender].ethAddress, "Not a valid bank");
        _;
    }

    struct Customer {
        string userName;   
        string data;  
        address bank;

       //added
        bool KycStasus;
        uint Downvotes;
        uint Upvotes;
    }
    
    struct Bank {
        string name;
        address ethAddress;
        string regNumber;

        //added
        uint complaintsReported ;
        uint KYC_count ;
        bool isAllowedToVote ;
        
    }
    struct KYC_Request {
        string username;
        address bankAddress;
        string customerDataHash;
        bool isAllowed;
    }

    mapping(string => Customer)public customers;
    uint customerCount = 0;

    mapping(address => Bank)public banks;
    uint banksCount=0;

    mapping(string => KYC_Request)public requests;



    //bank interface

    // This function is used to add the KYC request to the kycRequests list. 
      function addRequest( string memory  _customerName, string memory  _customerHash) public onlyValidBank {  
        string memory userName = customers[_customerName].userName;
         address bankAddress = msg.sender;
          require(keccak256(abi.encode(customers[userName].data)) != keccak256(abi.encode(_customerHash)));
         requests[_customerName] = KYC_Request(_customerName,bankAddress,_customerHash,true);
         
    }

     // This function will add a customer to the customers list.
    function addCustomer(string memory _userName, string memory _customerData) public onlyValidBank {
        require(keccak256(abi.encode(customers[ _userName].data)) ==  keccak256(abi.encode(_customerData)), "Customer is already present, please call modifyCustomer to edit the customer data");
        customers[_userName].userName = _userName;
        customers[_userName].data = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].KycStasus = false;
        customers[_userName].Downvotes = 0;
        customers[_userName].Upvotes = 0;
        customerCount++;
    }

  // This function will remove the request from the kycRequests list.
   function removeRequest(string memory _customerName) public onlyValidBank{
             require(keccak256(abi.encode(requests[ _customerName].customerDataHash)) ==  keccak256(abi.encode(customers[_customerName].data)), "Customer is not present in the database");
             delete requests[_customerName];     
   }
    
     // This function allows a bank to view the details of a customer.
    // Returns - All the variables of the customer structure. 
    function viewCustomer(string memory _userName) public view returns (string memory , string memory , address) {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        return (customers[_userName].userName, customers[_userName].data, customers[_userName].bank);
    }

    // This function allows a bank to cast an upvote for a customer. 
    // This vote from a bank means that it accepts the customer details as well as acknowledges the KYC process done by some bank for the customer. 
    function upVoteCustomes(string memory _customerName) public onlyValidBank{
        require(customers[_customerName].bank != address(0),"customer in list");
         customers[_customerName].Upvotes ++;

         if( customers[_customerName].Upvotes > customers[_customerName].Downvotes && customers[_customerName].Downvotes < banksCount/3 ){
                customers[_customerName].KycStasus = true;
                return;
           }
    } 

     // This function allows a bank to cast a downvote for a customer. 
    // This vote from a bank means that it does not accept the customer details.
    function downVoteCustomes(string memory _customerName) public onlyValidBank{
        require(customers[_customerName].bank != address(0),"customer in list");

              customers[_customerName].Downvotes++;

            if(customers[_customerName].Downvotes >= banksCount/3 ){
               customers[_customerName].KycStasus = false;
               return;
            }
    
    }
    
    // This function allows a bank to modify a customer's data. 
    // This will remove the customer from the KYC request list and set the number of downvotes and upvotes to zero.
    function modifyCustomer(string memory _userName, string memory _newcustomerData) public onlyValidBank {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        customers[_userName].data = _newcustomerData;
    }    

    // This function will be used to fetch bank complaints from the smart contract.  
    // Returns - Integer number of complaintsReported against the bank.
    function getBankComplaints(address _bankAddress) public view returns ( uint ){
        return banks[_bankAddress].complaintsReported;
    }

    // This function is used to fetch the bank details.
    function viewBankDetails(address _bankAddress) public view returns (string memory,address,string memory,uint,uint,bool){
         require(banks[_bankAddress].ethAddress != address(0), "Bank is not present in the database");
        return (banks[_bankAddress].name, banks[_bankAddress].ethAddress, banks[_bankAddress].regNumber,banks[_bankAddress].complaintsReported,banks[_bankAddress].KYC_count,banks[_bankAddress].isAllowedToVote);
    }

    // This function is used to report a complaint against any bank in the network.
    function reportBank(address _bankAddress,string memory _bankName) public onlyValidBank{
        require(keccak256(abi.encode(banks[_bankAddress].name)) !=  keccak256(abi.encode( _bankName)));
        if(banks[_bankAddress].complaintsReported > banksCount/3){
          banks[_bankAddress].isAllowedToVote = false;
        }
    }
      
    
    //Implementation of Admin Interface functions

     // This function is used by the admin to add a bank to the KYC Contract. 
    function addBank(string memory _bankName, address _bankAddress,string memory _regNumber) public onlyAdmin  {
    require(keccak256(abi.encode(banks[_bankAddress].regNumber)) !=  keccak256(abi.encode( _regNumber)));
        banks[_bankAddress] = Bank(_bankName,_bankAddress,_regNumber,0,0,true);
        banksCount++;
    }
    // This function can only be used by the admin to change the status of isAllowedToVote of any of the banks at any point in time.
    function modifyBankToisAllowedToVote(address _bankAddress , bool _isAllowed) public onlyAdmin {
        require(banks[_bankAddress].ethAddress != address(0));

        banks[_bankAddress].isAllowedToVote = _isAllowed;
    }

    // This function is used by the admin to remove a bank from the KYC Contract.
    function removeBanks(address _bankAddress) public onlyAdmin {
         require(banks[_bankAddress].ethAddress == _bankAddress, "Bank not found");
         
        delete banks[_bankAddress];
        banksCount--;
    }
    
}    


