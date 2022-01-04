pragma solidity ^0.8.2;

contract ERC721 {
    


    event Transfer(address indexed _from, address indexed _to, uint256 _tokenID);
    event Approval(address indexed _owner, address indexed _to, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    mapping(address => uint256) internal _balances;    
    mapping(uint256 => address) internal _owners;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _tokenApprovals;

    //Returns the numbers of NFTS e assigned para um dono
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Address is zero");
        return _balances[owner];
    }

    //Acha o dono da NFT
    function ownerOf(uint256 tokenId) public view returns(address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "TokenID nao existe");
        return owner;
    }

    
    // Ativar ou desativar um operador que vai gerenciar todos os assets do msg.senders
    function setApprovalForAll(address operator, bool approved) public{
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    //Checa se é operador de outro endereço
    function isApprovedForAll(address owner, address operator) public view returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    //Atualiza o endereço aprovado de uma NFT
    function approve(address to, uint256 tokenId) public{
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Msg.sender nao eh o dono ou um operator aprovado");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // Pega o endereço aprovado de uma NFT
    function getApproved(uint256 tokenId) public view returns (address){
        require(_owners[tokenId] != address(0), "Token ID nao existe");
        return _tokenApprovals[tokenId];

    }


    // Transfere a ownership/posse de uma NFT.
    function transferFrom(address from, address to, uint256 tokenId) public{
        address owner = ownerOf(tokenId);
        require(
            msg.sender == owner ||
            getApproved(tokenId) == msg.sender ||
            isApprovedForAll(owner, msg.sender),
            "Msg.sender nao eh o dono ou aprovado pra transferir"
        );
        require(
            owner == from, "O endereco do from nao eh o dono."
        );
        require(to != address(0), "Endereco zero");
        require(_owners[tokenId] != address(0), "Token Id nao existe");
        approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    // Igual a transferFrom, mas também checa se  onERC721Received tá implementada quando enviada aos contratos inteligentes.
    //Metodo de seguranca para não enviarmos NFT para contratos que não estejam preparado para elas, e assim eprder pra sempre o NFT.
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public{
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(), "Receiver nao ta implementado");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public{
        safeTransferFrom(from, to, tokenId,"");
    }
   

    function _checkOnERC721Received() private pure returns (bool){
        return true;
    }

    //EIP165: Se o contrato implementa outra interface
    function supportsInterface(bytes4 interfaceId) public pure virtual returns(bool){
        return interfaceId == 0x80ac58cd;
    }

}