#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch'

/*/{Protheus.doc} CORRSER
Correcao de series por pedido - SZ6010 (cabecalho) e SZ7010 (itens).
@author    Edson Ricardo (Conai)
@version   7.3 - Corrigido erro "Alias does not exist SZ6010" (FWBRWTABLE:SETALIAS).
Causa: ChkFile() apenas valida a existencia da tabela no dicionario
(SX2/SX3), ela NAO abre a area de trabalho. O FWMBrowse:SetAlias()
exige o alias ja aberto. Corrigido abrindo via DbUseArea antes do
SetAlias.
/*/
User Function CORRSER()
    Local oBrowse := FWMBrowse():New()

    // 1) Validacao de dicionario (mantido do original - nao abre a tabela)
    If !ChkFile('SZ6010')
        MsgAlert('Tabela SZ6010 nao encontrada no dicionario de dados (SX2/SX3).', 'CORRSER')
        Return Nil
    EndIf

    If !ChkFile('SZ7010')
        MsgAlert('Tabela SZ7010 nao encontrada no dicionario de dados (SX2/SX3).', 'CORRSER')
        Return Nil
    EndIf

    // 2) Abertura EFETIVA das areas de trabalho na thread
    //    (isso e o que faltava - ChkFile nao faz isso)
    If Select('SZ6010') == 0
        dbUseArea(.T., 'TOPCONN', RetSqlName('SZ6010'), 'SZ6010', .T., .F.)
        SZ6010->(dbSetOrder(1))
    EndIf

    If Select('SZ7010') == 0
        dbUseArea(.T., 'TOPCONN', RetSqlName('SZ7010'), 'SZ7010', .T., .F.)
        SZ7010->(dbSetOrder(1))
    EndIf

    oBrowse:SetAlias('SZ6010')
    oBrowse:SetDescription('Controle de Saida - Mercadoria')
    oBrowse:SetMenuDef('CORRSER')
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CORRSER" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.CORRSER" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.CORRSER" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.CORRSER" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
/*/
Static Function ModelDef()
    Local oModel     := Nil
    Local oStruSZ6 := FWFormStruct(1, 'SZ6010')
    Local oStruSZ7 := FWFormStruct(1, 'SZ7010')
    Local aRelacao := {}
    Local nOrdSZ7  := 1  // <<< CONFIRME NO SEU AMBIENTE: ordem de SZ7010 cuja chave seja
                         //     EXATAMENTE Z7_FILIAL+Z7_PEDIDO.

    oModel := MPFormModel():New('CORRSERM', /*bPre*/, /*bPos*/, {|oModel| VldCommit(oModel)}, /*bCancel*/)
    oModel:SetDescription('Controle de Saida - Mercadoria')

    oModel:AddFields('MASTER_SZ6', /*cOwner*/, oStruSZ6)

    // Chave primária da tabela SZ6010
    oModel:SetPrimaryKey({ 'Z6_FILIAL', 'Z6_PEDIDO' })

    AAdd(aRelacao, {'Z7_FILIAL', "xFilial('SZ7010')"})
    AAdd(aRelacao, {'Z7_PEDIDO', 'Z6_PEDIDO'})

    oModel:AddGrid('DETAIL_SZ7', 'MASTER_SZ6', oStruSZ7, /*bLinePre*/, {|oModelGrid, nLinha| VldSerie(oModelGrid, nLinha)})

    // Relacionamento apontando para o alias real SZ7010
    oModel:SetRelation('DETAIL_SZ7', aRelacao, SZ7010->(IndexKey(nOrdSZ7)))

    oModel:GetModel('MASTER_SZ6'):SetDescription('Pedido')
    oModel:GetModel('DETAIL_SZ7'):SetDescription('Series do pedido')

Return oModel

/*/{Protheus.doc} ViewDef
/*/
Static Function ViewDef()
    Local oModel     := FWLoadModel('CORRSER')
    Local oView      := Nil
    Local oStruSZ6 := FWFormStruct(2, 'SZ6010')
    Local oStruSZ7 := FWFormStruct(2, 'SZ7010')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_SZ6', oStruSZ6, 'MASTER_SZ6')
    oView:AddGrid('VIEW_SZ7', oStruSZ7, 'DETAIL_SZ7')

    oView:CreateHorizontalBox('CABEC', 30)
    oView:CreateHorizontalBox('GRID', 70)
    oView:SetOwnerView('VIEW_SZ6', 'CABEC')
    oView:SetOwnerView('VIEW_SZ7', 'GRID')
    oView:EnableTitleView('VIEW_SZ6', 'Pedido')
    oView:EnableTitleView('VIEW_SZ7', 'Series do pedido')

Return oView

/*/{Protheus.doc} VldSerie
Valida duplicidade fisica da serie (ordem por Z7_FILIAL+Z7_NRSERIE) com blindagem de
tipagem utilizando o alias SZ7010.
/*/
Static Function VldSerie(oGridModel, nLinha)
    Local lRet          := .T.
    Local cSerie        := cValToChar(oGridModel:GetValue('Z7_NRSERIE'))
    Local oModel        := FWModelActive()
    Local cPedidoCab    := cValToChar(oModel:GetValue('MASTER_SZ6', 'Z6_PEDIDO'))
    Local aAreaSZ7      := SZ7010->(GetArea())
    Local nOrdSZ7Atu    := SZ7010->(IndexOrd())

    If !oGridModel:IsDeleted() .And. !Empty(cSerie)

        SZ7010->(dbSetOrder(3))  // <<< CONFIRME NO SEU AMBIENTE: ordem cuja chave seja Z7_FILIAL+Z7_NRSERIE

        If SZ7010->(dbSeek(xFilial('SZ7010') + cSerie)) .And. !SZ7010->(Deleted())
            If AllTrim(SZ7010->Z7_PEDIDO) != AllTrim(cPedidoCab)
                Help(Nil, Nil, 'Serie ja utilizada', Nil, ;
                    'A serie ' + cSerie + ' ja esta vinculada ao pedido ' + ;
                    AllTrim(SZ7010->Z7_PEDIDO) + '.', 1, 0)
                lRet := .F.
            EndIf
        EndIf

        SZ7010->(dbSetOrder(nOrdSZ7Atu))
    EndIf

    RestArea(aAreaSZ7)
Return lRet

/*/{Protheus.doc} VldCommit
Bloqueia a gravacao do pedido se nao houver nenhuma serie informada no grid.
/*/
Static Function VldCommit(oModel)
    Local oGrid := oModel:GetModel('DETAIL_SZ7')
    Local lRet  := .T.

    If oGrid:Length() == 0 .Or. oGrid:IsEmpty()
        Help(Nil, Nil, 'Pedido sem series', Nil, ;
            'Inclua ao menos uma serie antes de confirmar o pedido.', 1, 0)
        lRet := .F.
    EndIf

Return lRet
