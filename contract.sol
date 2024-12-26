
pragma solidity ^0.8.0;

contract BlockchainTimeCapsule {
    // Struct to store a time-locked message
    struct Capsule {
        string message;
        uint256 unlockTime;
        address owner;
        bool retrieved;
    }

    // Array to store all time capsules
    Capsule[] public capsules;

    // Mapping from user address to their message IDs
    mapping(address => uint256[]) public userCapsules;

    // Event emitted when a new message is stored
    event MessageStored(address indexed owner, uint256 indexed capsuleId, uint256 unlockTime);

    // Event emitted when a message is retrieved
    event MessageRetrieved(address indexed owner, uint256 indexed capsuleId, string message);

    /**
     * @dev Store a time-locked message.
     * @param _message The message to store.
     * @param _unlockTime The future timestamp when the message can be retrieved.
     */
    function storeMessage(string memory _message, uint256 _unlockTime) external {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");

        // Add the message to the capsules array
        capsules.push(Capsule({
            message: _message,
            unlockTime: _unlockTime,
            owner: msg.sender,
            retrieved: false
        }));

        uint256 capsuleId = capsules.length - 1;
        userCapsules[msg.sender].push(capsuleId);

        emit MessageStored(msg.sender, capsuleId, _unlockTime);
    }

    /**
     * @dev Retrieve a message after its unlock time.
     * @param _capsuleId The ID of the message to retrieve.
     */
    function retrieveMessage(uint256 _capsuleId) external returns (string memory) {
        require(_capsuleId < capsules.length, "Invalid capsule ID");

        Capsule storage capsule = capsules[_capsuleId];

        require(msg.sender == capsule.owner, "You are not the owner of this message");
        require(block.timestamp >= capsule.unlockTime, "Message is still locked");
        require(!capsule.retrieved, "Message already retrieved");

        capsule.retrieved = true;

        emit MessageRetrieved(msg.sender, _capsuleId, capsule.message);

        return capsule.message;
    }

    /**
     * @dev Get the total number of messages stored.
     */
    function getTotalCapsules() external view returns (uint256) {
        return capsules.length;
    }

    /**
     * @dev Get message IDs stored by a specific user.
     * @param _user The address of the user.
     */
    function getUserCapsules(address _user) external view returns (uint256[] memory) {
        return userCapsules[_user];
    }

    /**
     * @dev Get details of a specific capsule.
     * @param _capsuleId The ID of the capsule.
     */
    function getCapsuleDetails(uint256 _capsuleId) external view returns (string memory, uint256, address, bool) {
        require(_capsuleId < capsules.length, "Invalid capsule ID");

        Capsule memory capsule = capsules[_capsuleId];
        return (capsule.message, capsule.unlockTime, capsule.owner, capsule.retrieved);
    }
}
