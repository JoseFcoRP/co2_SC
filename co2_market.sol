// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./co2_token.sol";

contract CO2Market {
    CO2Token token;
    // Mejora con una priority queue que ordene con la oferta mas baja, falta de ED en solidity
    struct oferta{
        address consumidor;
        uint256 price;
    }
    oferta [] ofertas;
    
    constructor (address _contract_address){
        token = CO2Token(_contract_address);
    }

    //1
    function capturarCO2(uint256 _amount) public{
        // Un consumidor de CO2 genera tokens nuevos
        token.mint(msg.sender, _amount);
    }

    //2
    function setPrice(uint256 _price) public{
        // Un consumidor de define su precio de venta de tokens
        bool no_cambiado = true;
        for (uint i=0; i< ofertas.length; i++){
            if (ofertas[i].consumidor == msg.sender){
                ofertas[i].price = _price;
                no_cambiado = false;
                break;
            }
        }
        if (no_cambiado){
            ofertas.push(oferta(msg.sender, _price));
        }
    }

    //3
    function comprarCO2(uint256 _amount) public payable{
        // Un productor compra el token mas barato
        address amejorOferta;
        uint256 mejorOferta = 2**256 - 1; // MAXUINT256
        for (uint i=0; i< ofertas.length; i++){
            if (ofertas[i].price < mejorOferta && token.balanceOf(ofertas[i].consumidor)>=_amount){
                amejorOferta = ofertas[i].consumidor;
                mejorOferta = ofertas[i].price;
            }
        }
        // Le pagaría al consumidor por la venta
        // require al principio
        uint256 precioTotal = mejorOferta*_amount;
        address payable _consumidorCO2 = payable(amejorOferta);
        // El comprador ha enviado al menos lo que tiene que pagar
        require(msg.value >= precioTotal);
        require(token.allowance(amejorOferta, address(this))>= _amount);
        // Trasnferir ETH del contract a _consumidorCO2 (amejorOferta)
        _consumidorCO2.transfer(precioTotal);
        token.transferFrom(amejorOferta, msg.sender, _amount);
    }

    //4
    function emitirCO2(uint256 _amount) public{
        // Un productor de CO2 usa tokens
        require(token.balanceOf(msg.sender)>=_amount);
        token.burn(msg.sender, _amount);
    }

    //5
    function mejorOfertaActual(uint256 _amount) public view returns(uint256){
        // Precio del token mas barato dada una cantidad para comprar
        uint256 mejorOferta = 2**256 - 1; // MAXUINT256
        for (uint i=0; i< ofertas.length; i++){
            if (ofertas[i].price < mejorOferta && token.balanceOf(ofertas[i].consumidor)>=_amount){
                mejorOferta = ofertas[i].price;
            }
        }
        return mejorOferta;
    }

    
}