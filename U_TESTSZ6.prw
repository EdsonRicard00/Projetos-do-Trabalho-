#Include 'Protheus.ch'

/*/{Protheus.doc} TESTSZ6
Function isolada de 1 unico proposito: confirmar se a compilacao esta realmente
atualizando o RPO do ambiente que voce esta testando (P12mig / porta 10006).
Nao mexe em SZ6010/SZ7010 de verdade, so abre e fecha pra provar que o alias
consegue ser aberto.
@author Suporte
@version 1.0 - 26/08/2026
/*/
User Function TESTSZ6()

    If Select('SZ6010') == 0
        dbUseArea(.T., 'TOPCONN', RetSqlName('SZ6010'), 'SZ6010', .T., .F.)
        SZ6010->(dbSetOrder(1))
    EndIf

    If Select('SZ6010') > 0
        MsgInfo('OK - SZ6010 aberta com sucesso. Compilacao ' + ;
            '26/08/2026 as ' + Time() + ' esta ativa neste RPO.', 'TESTSZ6')
        SZ6010->(dbCloseArea())
    Else
        MsgAlert('FALHOU - SZ6010 nao abriu. Nao e problema de compilacao, ' + ;
            'e configuracao de banco/dicionario.', 'TESTSZ6')
    EndIf

Return Nil
