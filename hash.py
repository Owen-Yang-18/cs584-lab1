from web3 import Web3

def keccak256_encode_packed(move, salt):
    """
    Computes keccak256(abi.encodePacked(move, salt)) similar to Solidity.

    :param move: The 'move' value, as a string or bytes.
    :param salt: The 'salt' value, as a string or bytes.
    :return: The Keccak-256 hash as a hexadecimal string.
    """
    # Convert to bytes if inputs are strings
    if isinstance(move, str):
        move = move.encode('utf-8')
    if isinstance(salt, str):
        salt = salt.encode('utf-8')
    
    # Ensure both move and salt are bytes32 (32 bytes each)
    # If they are shorter, pad them with zeros; if longer, truncate
    move_padded = move.ljust(32, b'\0')[:32]
    salt_padded = salt.ljust(32, b'\0')[:32]
    
    # Concatenate the padded bytes
    concatenated = move_padded + salt_padded
    
    # Compute Keccak-256 hash
    hash_bytes = Web3.keccak(concatenated)
    
    # Convert to hexadecimal string for readability
    return hash_bytes.hex()

# Example Usage
if __name__ == "__main__":
    move = "Rock"
    salt = "Owen"
    
    hash_result = keccak256_encode_packed(move, salt)
    print("hash_result")
