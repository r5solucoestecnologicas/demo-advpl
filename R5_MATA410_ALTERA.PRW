#include "PROTHEUS.CH" 

User Function xAltPed()
Local aCabec     := {} 
Local aItens     := {}
Local aLogErr    := {}                                                  
Local aLinPed    := {}
Local cFiltro	:= SC5->C5_FILIAL+SC5->C5_NUM     
Local nOpc := 4

Private lMsErroAuto     := .F.
Private lMsHelpAuto     := .T.     
 

     // Cabecalho
                      
     aAdd(aCabec, {"C5_NUM",SC5->C5_NUM,Nil}) // Numero do Pedido 
     aAdd(aCabec, {"C5_TIPO",SC5->C5_TIPO,Nil}) // Tipo do Pedido
     aAdd(aCabec, {"C5_CLIENTE",SC5->C5_CLIENTE,Nil}) // Codigo do Cliente
     aAdd(aCabec, {"C5_LOJACLI",SC5->C5_LOJACLI,Nil}) // Loja do Cliente
     aAdd(aCabec, {"C5_CLIENT",SC5->C5_CLIENT,Nil}) // Codigo do Cliente para entrega
//     aAdd(aCabec, {"C5_LOJAENT",SC5->C5_LOJAENT,Nil}) // Loja para entrega
//     aAdd(aCabec, {"C5_TIPOCLI",SC5->C5_TIPOCLI,Nil}) // Tipo do Cliente
     aAdd(aCabec, {"C5_CONDPAG",SC5->C5_CONDPAG,Nil}) // Condicao de pagamanto
//     aAdd(aCabec, {"C5_EMISSAO",SC5->C5_EMISSAO,Nil}) // Data de Emissao
//     aAdd(aCabec, {"C5_MOEDA",SC5->C5_MOEDA,Nil}) // Moeda 
//     aAdd(aCabec, {"C5_NATUREZ",SC5->C5_NATUREZ,Nil}) // 
//     aAdd(aCabec, {"C5_VEND1",SC5->C5_VEND1,Nil}) // 
//     aAdd(aCabec, {"C5_COMIS1",SC5->C5_COMIS1,Nil}) // 
//     aAdd(aCabec, {"C5_TRANSP",SC5->C5_TRANSP,Nil}) //  
//     aAdd(aCabec, {"C5_DESPESA",SC5->C5_DESPESA,Nil}) // 
//     aAdd(aCabec, {"C5_TPCARGA",SC5->C5_TPCARGA,Nil}) // 
//     aAdd(aCabec, {"C5_TPFRETE",SC5->C5_TPFRETE,Nil}) // 
//     aAdd(aCabec, {"C5_MENNOTA",SC5->C5_MENNOTA,Nil}) // 
     _Aux    := {}
     _Ajuste := {}
     aDados := {}

     dbSelectArea("SC6")
     SC6->(DbGoTop())
     SC6->(dbSetOrder(1))
     SC6->(dbSeek(cFiltro))
     _nItens := 0
     SX3->(DbSetOrder(2)) // Campo

     For nX := 1 To SC6->(FCount())
         If SX3->(DbSeek(SC6->(Field(nX)))) .AND. X3USO(SX3->X3_USADO) .And. SX3->X3_CONTEXT <> "V"
            aAdd(aDados,{SC6->(Field(nX)),SX3->X3_TIPO})
         Endif   
     Next nX

   	 while SC6->(!EOF()) .And. (SC6->C6_FILIAL+SC6->C6_NUM)==cFiltro
        If val(SC6->C6_ITEM) > _nItens
            _nItens := val(SC6->C6_ITEM)
        Endif    
		SC6->(dbSkip())
     EndDo
     _nItens++


     SC6->(DbGoTop())
     SC6->(dbSetOrder(1))
     SC6->(dbSeek(cFiltro))

	while SC6->(!EOF()) .And. (SC6->C6_FILIAL+SC6->C6_NUM)==cFiltro
        _nQtd := Fieldget(SC6->(Fieldpos("C6_QTDVEN")))

        If _nQtd > 1        //Será desdobrado em dois itens

            For _nn := 1 to SC6->(FCount())         //Varre todos os campos da tabela SC6
                _nPos := aScan(aDados,{|x| AllTrim(x[1])==SC6->(Field(_nn))}) 
                If  _nPos > 0       //Somente campos Usados e Reais do SX3
                    If aDados[_nPos,1] =="C6_QTDVEN"
                        aadd(_Aux,{"C6_QTDVEN",1,Nil})
                    Elseif aDados[_nPos,1] =="C6_VALOR"    
                        aadd(_Aux,{"C6_VALOR",SC6->C6_PRCVEN,Nil})
                    Elseif aDados[_nPos,1] =="C6_ITEM"
                        aAdd(_Aux, {"C6_ITEM",strzero(_nItens,2),Nil}) 
                    ElseIf ((SC5->C5_TIPO <> "D") .and. (aDados[_nPos,1] <> "C6_IPIDEV")) .or. ((SC5->C5_TIPO == "D") .and. (aDados[_nPos,1] == "C6_IPIDEV"))
                        _cAux := "SC6->"+aDados[_nPos,1]
                        If (aDados[_nPos,2] == "C" .and. alltrim(&_cAux) <> "") .or. (aDados[_nPos,2] == "N" ) .or. (aDados[_nPos,2] == "D" .and. dtoc(&_cAux) <> "  /  /  ") .or. (aDados[_nPos,2] == "L" ) .or. (aDados[_nPos,2] == "M" )
                            aadd(_Aux,{aDados[_nPos,1],&_cAux,Nil})//
                        Endif    
                    Endif  

                Endif
            Next _nn    


/*         aAdd(_Aux, {"C6_ITEM",strzero(_nItens,2),Nil}) // Numero do Item no Pedido
	     aAdd(_Aux, {"C6_PRODUTO",SC6->C6_PRODUTO,Nil}) // Codigo do Produto
	     aAdd(_Aux, {"C6_QTDVEN",1,Nil}) // Quantidade Vendida
	     aAdd(_Aux, {"C6_PRCVEN",SC6->C6_PRCVEN,Nil}) // Preco Venda
	     aAdd(_Aux, {"C6_PRUNIT",SC6->C6_PRUNIT,Nil}) // Preco Unitario
	     aAdd(_Aux, {"C6_VALOR",SC6->C6_PRCVEN,Nil}) // Valor Total do Item 
         aAdd(_Aux, {"C6_ENTREG",SC6->C6_ENTREG,Nil}) // Data da Entrega*/
         _nItens++
         _QtNew := _nQtd -1 
     	AAdd(_Ajuste,_Aux)
        _Aux     := {}

      Else          //Não sera desdobrado em dois itens pois já está na quantidade mínima

         _qtNew := _nQtd 

      Endif
      
        _VlNew := _QtNew * SC6->C6_PRCVEN

    	// Itens

            For _nn := 1 to SC6->(FCount())         //Varre todos os campos da tabela SC6
                _nPos := aScan(aDados,{|x| AllTrim(x[1])==SC6->(Field(_nn))}) 
                If _nPos > 0        //Somente campos Usados e Reais do SX3
                    If aDados[_nPos,1] =="C6_QTDVEN"
                        aAdd(aItens, {"C6_QTDVEN",_qtNew,Nil})
                    Elseif aDados[_nPos,1] =="C6_VALOR"    
                        aAdd(aItens, {"C6_VALOR",_VlNew,Nil})
                    Elseif aDados[_nPos,1] =="C6_ITEM"
                         aadd(aItens, {"LINPOS", "C6_ITEM", SC6->C6_ITEM}) 
                    ElseIf ((SC5->C5_TIPO <> "D") .and. (aDados[_nPos,1] <> "C6_IPIDEV")) .or. ((SC5->C5_TIPO == "D") .and. (aDados[_nPos,1] == "C6_IPIDEV"))
                        _cAux := "SC6->"+aDados[_nPos,1]
                        If (aDados[_nPos,2] == "C" .and. alltrim(&_cAux) <> "") .or. (aDados[_nPos,2] == "N" ) .or. (aDados[_nPos,2] == "D" .and. dtoc(&_cAux) <> "  /  /  ") .or. (aDados[_nPos,2] == "L" ) .or. (aDados[_nPos,2] == "M" )
                            aadd(_Aux,{aDados[_nPos,1],&_cAux,Nil})
                        Endif    
                    Endif  

                Endif
            Next _nn    

         aadd(aItens, {"AUTDELETA",  "N",           Nil})

/*         aadd(aItens, {"LINPOS",     "C6_ITEM",     SC6->C6_ITEM})
         aadd(aItens, {"AUTDELETA",  "N",           Nil})
	     aAdd(aItens, {"C6_PRODUTO",SC6->C6_PRODUTO,Nil}) // Codigo do Produto
	     aAdd(aItens, {"C6_QTDVEN",_qtNew,Nil}) // Quantidade Vendida
	     aAdd(aItens, {"C6_PRCVEN",SC6->C6_PRCVEN,Nil}) // Preco Venda
	     aAdd(aItens, {"C6_PRUNIT",SC6->C6_PRUNIT,Nil}) // Preco Unitario
	     aAdd(aItens, {"C6_VALOR",_VlNew,Nil}) // Valor Total do Item 
         aAdd(aItens, {"C6_ENTREG",SC6->C6_ENTREG,Nil}) // Data da Entrega*/

    	AAdd(aLinPed,aItens)
        aItens     := {}

       
		SC6->(dbSkip())
    EndDo

    For _i := 1 to len(_Ajuste)
        AAdd(aLinPed,_Ajuste[_i])
    Next _i
     
     MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aLinPed, nOpc) 
     
     If lMsErroAuto
             MostraErro()
     Else
          Alert("Funcionou!")
    EndIf
Return

Return
//--------------------------------------------------------------------------------------------------//
USER Function MA410MNU

aAdd(aRotina, {OemToAnsi("Ajusta Pedido"),"U_xAltPed()", 0 , 2})

Return()
