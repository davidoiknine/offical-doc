// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Certif {

    uint modulo = 10**16;
    event errorMessage(string message);
    event newPerson(string message, uint id);
    event newDocument(string message, uint id);

    struct Person {
        uint id;
        string name;
        uint birthdate;
    }
    
    struct Document {
        uint id;
        string name; // exemple: permis de conduire
        bool validity;
        string authority;
        uint ownerID;
    }

    
    //Person[] public persons;
    //Document[] public documents;
    mapping(uint => uint) public docToOwner;
    mapping(uint => Person) public persons;
    mapping(uint => Document) public documents;
    mapping(address => bool) public authority;

    constructor() {
        authority[0x71835B3Fd2878425734DCA893069E48bB9aFE38A] = true;
        authority[0xF35DC120B2668a154A54EEefaABb8Fc5aeB49DF8] = true;
    }

    
    // Genere un ID aléatoire
    function _generateID() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp))) % modulo;
    }

    // Crée une nouvelle personne
    function _createPerson(string memory _name, uint _birthdate) public {
        require(authority[msg.sender] == true, "Sender not authorized");
        uint personID = _generateID();
        persons[personID] = Person(personID, _name, _birthdate);
        emit newPerson("New person created!", personID);
    }

    function _getPerson(uint _personID) private view returns (Person memory) {
        return persons[_personID];
    }

    function _getDocument(uint _docID) public view returns (Document memory) {
        return documents[_docID];
    }

    // Crée un nouveau document
    function _createDocument(string memory _name, bool _validity, string memory _authority, uint _ownerID) public {
        require(authority[msg.sender] == true, "Sender not authorized");
        Person memory owner = _getPerson(_ownerID);
        if (owner.id != 0 && owner.birthdate != 0){
            uint docID = _generateID();
            documents[docID] = Document(docID, _name, _validity, _authority, _ownerID);
            docToOwner[docID] = _ownerID;
            emit newDocument("New document has been created!", docID);
        }
        else {
            emit errorMessage("There is no person created under this ID!");
        }
    }
    
    function checkDocumentValidity(uint _docID, uint _personID) public view returns (bool) {
        if (docToOwner[_docID] == _personID) {
            Document memory doc = _getDocument(_docID);
            return doc.validity;
        }
        return false;
    }
    
    function _DeleteDocument(uint _docID) public {
        require(authority[msg.sender] == true, "Sender not authorized");
        Document storage doc = documents[_docID];
        doc.validity = false;
    }
}