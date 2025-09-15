#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TASKSMANEGER.CH"

PUBLISH MODEL REST NAME TASKSMANEGER 


/*/{Protheus.doc} TASKSMANEGER
Gerenciador de Tarefas
@type function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
/*/
Function TASKSMANEGER()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias('ZZG')
oBrowse:SetMenuDef('TASKSMANEGER')

//Status da Tarefa
oBrowse:AddLegend( "ZZG_SITUAC == '1'", "YELLOW", "Tarefa Pendente" )
oBrowse:AddLegend( "ZZG_SITUAC == '2'", "GRAY"	, "Tarefa em Andamento" )
oBrowse:AddLegend( "ZZG_SITUAC == '3'", "GREEN"	, "Tarefa Concluida" )
oBrowse:AddLegend( "ZZG_SITUAC == '4'", "RED"	, "Tarefa Cancelada" )

oBrowse:SetDescription(STR0001)//Gerenciador de Tarefas

oBrowse:Activate()
oBrowse:Destroy()

Return

/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type static function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
@return aRotina, retorna as opções do menu
/*/
Static Function MenuDef()
Local aRotina := {} 

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TASKSMANEGER' OPERATION OP_VISUALIZAR ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TASKSMANEGER' OPERATION OP_INCLUIR    ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TASKSMANEGER' OPERATION OP_ALTERAR    ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TASKSMANEGER' OPERATION OP_EXCLUIR    ACCESS 0 // Excluir

Return aRotina

/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type static function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
@return oModel, retorna o Objeto do Menu
/*/
Static Function ModelDef()
    Local oModel  := nil
    Local oStruZZG := FWFormStruct(1,'ZZG')
    Local oStruZZH := FWFormStruct(1,'ZZH')
    Local bPosVld  := {|oModel| TaskPosVld(oModel)}

    oStruZZH:AddField( ;
        AllTrim('') , ;               // [01] C Titulo do campo
        AllTrim('') , ;               // [02] C ToolTip do campo
        'ZZH_LEGEND' , ;               // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                      // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de validação do campo
        NIL , ;                     // [08] B Code-block de validação When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
        { || Iif(ZZH->ZZH_STATUS == '3', "BR_VERDE","BR_VERMELHO") } , ;           // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
        .T. , ;
        )                      // [14] L Indica se o campo é virtual 

    oModel := MPFormModel():New('TASKSMANEGER', /*bPreValidacao*/,bPosVld, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields('ZZGMASTER',/*cOwner*/,oStruZZG,/*bPre*/,/*bPos*/,/*bLoad*/)

    oModel:AddGrid('ZZHDETAIL','ZZGMASTER',oStruZZH,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*bLoad*/)
    oModel:SetRelation('ZZHDETAIL',{{ 'ZZH_FILIAL','ZZG_FILIAL'},{'ZZH_CODTAR','ZZG_CODIGO' }},ZZH->(IndexKey(1)))

    oModel:GetModel( 'ZZHDETAIL' ):SetUniqueLine( { 'ZZH_DESCRI' } )

    oModel:SetDescription(STR0001) //'Cadastros de Tarefas'
    oModel:GetModel('ZZGMASTER'):SetDescription(STR0006) //'Tarefas'
    oModel:GetModel('ZZHDETAIL'):SetDescription(STR0007) //"SubTarefas"

    oModel:SetPrimaryKey({'ZZG_FILIAL','ZZG_CODIGO'})

Return oModel

/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type static function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
@return oView, retorna o Objeto da View
/*/
Static Function ViewDef()
    Local oView		:= FWFormView():New()
    Local oModel	:= FwLoadModel('TASKSMANEGER')
    Local oStruZZG	:= FWFormStruct(2, 'ZZG')
    Local oStruZZH	:= FWFormStruct(2, 'ZZH')

    oStruZZH:AddField( ;                      // Ord. Tipo Desc.
        'ZZH_LEGEND'                        , ;        // [01] C   Nome do Campo
        "00"                             , ;     // [02] C   Ordem
        AllTrim( ''    )        , ;     // [03] C   Titulo do campo
        AllTrim( '' )       , ;     // [04] C   Descricao do campo
        { 'Legenda' }           , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'               , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                             , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo é alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                                        , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior opção do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo é virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                               , ;    // [18] L   Indica pulo de linha após o campo 
    )    

    oView:SetModel(oModel)

    oView:AddField('VIEW_ZZG' ,oStruZZG,'ZZGMASTER')
    oView:AddGrid('VIEW_ZZH'  ,oStruZZH,'ZZHDETAIL')

    oView:addIncrementField('VIEW_ZZH'  ,'ZZH_CODIGO')

    oView:CreateHorizontalBox('UPPER', 60)
    oView:CreateHorizontalBox('BOTTOM', 40)
    oView:SetOwnerView('VIEW_ZZG','UPPER')
    oView:SetOwnerView('VIEW_ZZH','BOTTOM')

    oView:SetDescription(STR0001) //'Cadastros de Tarefas'
    oView:EnableTitleView('VIEW_ZZG',STR0006)//'Tarefas'
    oView:EnableTitleView('VIEW_ZZH',STR0007)//"SubTarefas"

Return oView

/*/{Protheus.doc} VldTaskDate
Função responsavel pela a validação do campo Dt Conclusao (ZZG_DTCONC)
@type static function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
@return lRet, retorna se o contéudo do campo é valido 
/*/
Function VldTaskDate()
    local lRet := .T.

    if M->ZZG_DTCONC < M->ZZG_DTINC 
        // # A data de conclusão não pode ser menor do que a data de inclusão # Contéudo do Campo Dt Conclusao é inválido!
        FWAlertWarning(STR0008, STR0009)
        lRet := .F.
    endif

Return lRet

/*/{Protheus.doc} TaskPosVld
Pós validação do model, validação antes da gravação dos dados
@type static function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
@return lRet, retorna se os campos foram preenchidos corretamente
/*/
Static function TaskPosVld(oModel)
    Local lRet := .T.

    if oModel:GetModel("ZZGMASTER"):GetValue("ZZG_SITUAC") == '3'
        lRet := checkSubtks(oModel:GetModel("ZZHDETAIL"):GetValue("ZZH_CODTAR"))
        if !lRet
		    Help(,,'HELP',,'Não é possivel concluir esta tarefa, possui Subtarefas pendente ou em andamento',1,0)

        endif
    endif
return lRet

/*/{Protheus.doc} checkSubtks
Verifica se possui uma subtarefa pendente ou em andamento
@type static function
@version 12.1.2410 
@author giovanna.charlo
@since 14/09/2025
@return lRet, retorna se esta tarefa possui subtarefa pendente
/*/
static function checkSubtks(cCodTask)
    local lRet := .T.
    local cQuery := ""
	local nOrder := 1 
    local cAlias := ""
    local oStatement 

    default cCodTask := ''

    cQuery := "SELECT ? FROM ? ZZH "

    cQuery += " INNER JOIN ? ZZG "
	cQuery += " ON ZZH.ZZH_CODTAR  = ZZG.ZZG_CODIGO "
	cQuery += " AND ZZG.D_E_L_E_T_ = ?

	cQuery += " WHERE ZZH.ZZH_CODTAR = ? "
	cQuery += "  AND ZZH.D_E_L_E_T_ = ?

    cQuery := ChangeQuery(cQuery)

    oStatement := FWExecStatement():new(cQuery)

    oStatement:setUnsafe(nOrder++,"ZZH_CODTAR, ZZH_STATUS, ZZH_DTCONC")
	oStatement:setUnsafe(nOrder++, retSqlName("ZZH"))
	oStatement:setUnsafe(nOrder++, retSqlName("ZZG"))
    oStatement:setString(nOrder++, " ")
    oStatement:setString(nOrder++, cCodTask)
    oStatement:setString(nOrder++, " ")

    cAlias := oStatement:openAlias()

    (cAlias)->(dbGoTop())
    while !(cAlias)->(eof())
        if (cAlias)->ZZH_STATUS != "3"      
            lRet := .F.
            exit                                     
        endif
    	(cAlias)->(dbSkip())
	enddo
    (cAlias)->(dbCloseArea())
    FreeObj(oStatement)

return lRet

