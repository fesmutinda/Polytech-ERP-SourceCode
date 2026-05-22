
xmlport 58000 "Wallet Transactions Import"
{
    Format = VariableText;
    Caption = 'Wallet Transactions Import';
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(walletTransactionLines; "Wallet Transaction Schedule")
            {
                fieldelement(lineNo; walletTransactionLines."No.") { }
                // fieldelement(walletNumber; walletTransactionLines."Destination Account No.") { }
                fieldelement(memberNumber; walletTransactionLines."Member Number") { }
                fieldelement(transAmount; walletTransactionLines.Amount) { }
            }
        }
    }
}
