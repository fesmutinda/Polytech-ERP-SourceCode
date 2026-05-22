
report 50004 "Create M-wallet Account"
{
    ApplicationArea = All;
    Caption = 'Create M-wallet Account';
    UsageCategory = Administration;
    // DefaultLayout = RDLC;
    // RDLCLayout = './Layouts/Create Wallet Accounts.rdlc';
    ProcessingOnly = true;
    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            var
                walletAccount: Text[20];
                message: Text[1000];
            begin
                walletAccount := '';
                DialogBox.Open('Creating Wallet Account for ' + Customer."No." + ' ' + Customer.Name);
                //check if the member has a wallet acount
                walletAccount := SFactory.FnGetFosaAccount(Customer."No.");
                if walletAccount <> '' then
                    Error('Member ' + Customer.Name + ' already has M-Wallet Account Number ' + walletAccount);
                //create account
                message := swizzMobile.CreateMWallet(Customer."No.");

                walletAccount := SFactory.FnGetFosaAccount(Customer."No.");
                DialogBox.Close();
                if walletAccount <> '' then begin
                    Message(message);

                end else begin
                    Message('Account failed to be Created');
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    var
        swizzMobile: Codeunit SwizzKashMobile;
        SFactory: Codeunit "Swizzsoft Factory.";
        DialogBox: Dialog;
}
