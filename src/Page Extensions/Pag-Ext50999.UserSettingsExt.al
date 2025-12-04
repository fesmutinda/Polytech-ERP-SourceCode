pageextension 50999 "User Settings Ext" extends "User Settings"
{

    trigger OnOpenPage()
    begin
        if (UserId <> 'SWIZZSOFTADMIN') and (UserId <> 'STEPHEN') then
            CurrPage.Editable := false;
    end;
}
