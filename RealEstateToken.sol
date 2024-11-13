// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstateToken is ERC721URIStorage, Ownable {
    uint256 private _currentTokenId;

    // Mapeamento para armazenar as frações de cada token
    mapping(uint256 => uint256) public propertyFractions;
    
    // Mapeamento para armazenar tokens associados a um imóvel
    mapping(uint256 => uint256[]) public propertyTokens;
    
    // Mapeamento para verificar a qual imóvel um token pertence
    mapping(uint256 => uint256) public tokenToProperty;
    
    // Controle do total de frações emitidas por imóvel
    mapping(uint256 => uint256) public totalFractionsPerProperty;

    // Evento para a criação de um novo imóvel
    event PropertyCreated(uint256 propertyId);
    
    // Evento para a criação de um novo token de fração
    event FractionMinted(uint256 propertyId, uint256 tokenId, uint256 fraction, address to);

    constructor(address initialOwner) ERC721("RealEstateToken", "RET") Ownable(initialOwner) {}

    // Função para criar um novo token representando a fração de um imóvel
    function mintFraction(
        address to,
        uint256 propertyId,
        uint256 fraction,
        string memory tokenURI
    ) external onlyOwner returns (uint256) {
        require(fraction > 0, "Fraction must be greater than 0");
        require(totalFractionsPerProperty[propertyId] + fraction <= 100, "Total fraction exceeds 100%");

        // Incrementa o ID do token
        _currentTokenId++;
        uint256 newTokenId = _currentTokenId;

        // Mint do token
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        // Associa o token ao imóvel e armazena a fração
        propertyFractions[newTokenId] = fraction;
        tokenToProperty[newTokenId] = propertyId;
        propertyTokens[propertyId].push(newTokenId);

        // Atualiza o total de frações emitidas para o imóvel
        totalFractionsPerProperty[propertyId] += fraction;

        emit FractionMinted(propertyId, newTokenId, fraction, to);

        return newTokenId;
    }

    // Função para obter os tokens associados a um imóvel
    function getPropertyTokens(uint256 propertyId) external view returns (uint256[] memory) {
        return propertyTokens[propertyId];
    }

    // Função para obter a fração associada a um token específico
    function getTokenFraction(uint256 tokenId) external view returns (uint256) {
        return propertyFractions[tokenId];
    }

    // Função para obter o imóvel associado a um token específico
    function getTokenProperty(uint256 tokenId) external view returns (uint256) {
        return tokenToProperty[tokenId];
    }

    // Função para obter o total de frações emitidas para um imóvel
    function getTotalFractions(uint256 propertyId) external view returns (uint256) {
        return totalFractionsPerProperty[propertyId];
    }

    // Função para transferir a propriedade de um token
    function transferProperty(address from, address to, uint256 tokenId) external {
        require(ownerOf(tokenId) == from, "You do not own this token");
        safeTransferFrom(from, to, tokenId);
    }
}
