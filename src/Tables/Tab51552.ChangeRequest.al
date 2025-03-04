#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51552 "Change Request"
{

    DrillDownPageId = "Change Request List";
    LookupPageId = "Change Request List";


    fields
    {
        field(1; No; Code[30])
        {
            Editable = false;

            trigger OnValidate()
            begin
                if No <> xRec.No then begin
                    SalesSetup.Get;
                    NoSeriesMgt.TestManual(SalesSetup."Change Request No");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Type; Option)
        {
            // OptionCaption = ',BOSA Change';
            OptionMembers = "BOSA Change";
            InitValue = "BOSA Change";
            trigger OnValidate()
            begin
                "Account No" := '';
            end;
        }
        field(3; "Account No"; Code[50])
        {
            TableRelation = Customer."No." where("Customer Posting Group" = filter('MEMBER'));
            trigger OnValidate()
            begin
                Clear(Picture);
                // if ((Type = Type::"M-Banking Change") or (Type = Type::"ATM Change") or (Type = Type::"FOSA Change")) then begin
                //     vend.Reset;
                //     vend.SetRange(vend."No.", "Account No");
                //     if vend.Find('-') then begin
                //         Name := vend.Name;
                //         Branch := vend."Global Dimension 2 Code";
                //         Address := vend.Address;
                //         Picture := vend.Image;
                //         signinature := vend.Signature;
                //         Email := vend."E-Mail";
                //         "Mobile No" := vend."Mobile Phone No";
                //         "Phone No." := vend."Phone No.";
                //         "Mpesa mobile No." := vend."MPESA Mobile No";
                //         "SMS Notification" := vend."Sms Notification";
                //         "Mobile No" := vend."Mobile Phone No";
                //         "ID No" := vend."ID No.";
                //         "Personal No" := vend."Employer P/F";
                //         "Account Type" := vend."Account Type";
                //         City := vend.City;
                //         Section := vend.Section;
                //         "Card Expiry Date" := vend."Card Expiry Date";
                //         "Card No" := vend."Card No.";
                //         "Card Valid From" := vend."Card Valid From";
                //         "Card Valid To" := vend."Card Valid To";
                //         "Marital Status" := vend."Marital Status";
                //         "Reason for change" := vend."Reason For Blocking Account";
                //         Blocked := vend.Blocked;
                //         "Blocked (New)" := vend.Blocked;
                //         "Status." := vend.Status;
                //         "Status.(New)" := vend.Status;


                //     end;


                // end;
                if Type = Type::"BOSA Change" then begin
                    Memb.Reset;
                    Memb.SetRange(Memb."No.", "Account No");
                    if Memb.Find('-') then begin

                        Name := Memb.Name;
                        Branch := Memb."Global Dimension 2 Code";
                        Address := Memb.Address;
                        Email := Memb."E-Mail";
                        "Mobile No" := Memb."Mobile Phone No";
                        "ID No" := Memb."ID No.";
                        "Personal No" := Memb."Payroll/Staff No";
                        "Post Code" := Memb."Post Code";
                        City := Memb.City;
                        "SMS Notification" := Memb."Sms Notification";
                        Section := Memb.Section;
                        "Marital Status" := Memb."Marital Status";
                        "Monthly Contributions" := Memb."Monthly Contribution";
                        "Member Account Status" := Memb.Status;
                        "Member Account Status" := Memb.Status;
                        "Employer Code" := Memb."Employer Code";
                        "Status." := Memb.Status;
                        "Date Of Birth" := Memb."Date of Birth";
                        Occupation := Memb.Occupation;
                        Blocked := Memb.Blocked;
                        Picture := Memb.Image;
                        signinature := Memb.Signature;
                        "Bank Code(Old)" := Memb."Bank Code";
                        "Bank Account No(Old)" := Memb."Bank Account No.";
                        "KRA Pin(Old)" := Memb.Pin;
                        "Account Category" := Memb."Account Category";
                        "Bank Branch Name" := Memb."Bank Branch Name";
                        "Bank Name" := Memb."Bank Name";
                        "Bank Branch Code" := Memb."Bank Branch Code";
                    end;
                end;

            end;
        }
        field(4; "Mobile No"; Code[50])
        {
        }
        field(5; Name; Text[40])
        {
        }
        field(6; "No. Series"; Code[30])
        {
        }
        field(7; Address; Code[30])
        {
        }
        field(8; Branch; Code[30])
        {
        }
        field(9; Picture; Media)
        {
        }
        field(10; signinature; Media)
        {
        }
        field(11; City; Code[30])
        {
        }
        field(12; "E-mail"; Code[100])
        {
        }
        field(13; "Personal No"; Code[30])
        {
        }
        field(14; "ID No"; Code[40])
        {
        }
        field(15; "Marital Status"; Option)
        {
            OptionCaption = 'Married,Single';
            OptionMembers = Married,Single;
        }
        field(16; "Passport No."; Code[30])
        {
        }
        field(17; Status; Option)
        {
            OptionCaption = 'Open,Pending,Approved,Rejected';
            OptionMembers = Open,Pending,Approved,Rejected;
        }
        field(18; "Account Type"; Code[30])
        {
        }
        field(19; "Account Category"; Option)
        {
            OptionCaption = 'Single,Joint,Corporate,Group,Parish,Church,Church Department,Staff';
            OptionMembers = Single,Joint,Corporate,Group,Parish,Church,"Church Department",Staff;
        }
        field(20; Email; Text[100])
        {
            trigger OnValidate()
            var
                myInt: Integer;
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField(Email);

            end;
        }
        field(21; Section; Code[40])
        {
        }
        field(22; "Card No"; Code[30])
        {
        }
        field(23; "Home Address"; Code[30])
        {
        }
        field(24; Loaction; Code[20])
        {
        }
        field(25; "Sub-Location"; Code[30])
        {
        }
        field(26; District; Code[30])
        {
        }
        field(27; "Reason for change"; Text[50])
        {
        }
        field(28; "Signing Instructions"; Text[40])
        {
        }
        field(29; "S-Mobile No"; Code[10])
        {
        }
        field(30; "ATM Approve"; Code[30])
        {
        }
        field(31; "Card Expiry Date"; Date)
        {
        }
        field(32; "Card Valid From"; Date)
        {
        }
        field(33; "Card Valid To"; Date)
        {
        }
        field(34; "Date ATM Linked"; Date)
        {
        }
        field(35; "ATM No."; Code[16])
        {
        }
        field(36; "ATM Issued"; Boolean)
        {
        }
        field(37; "ATM Self Picked"; Boolean)
        {
        }
        field(38; "ATM Collector Name"; Code[30])
        {
        }
        field(39; "ATM Collectors ID"; Code[20])
        {
        }
        field(40; "Atm Collectors Moile"; Code[30])
        {
        }
        field(41; "Member Type"; Option)
        {
            OptionCaption = ' ,class A,class B';
            OptionMembers = " ","class A","class B";
        }
        field(42; "Monthly Contributions"; Decimal)
        {
        }
        field(43; "Captured by"; Code[50])
        {
            Editable = false;
        }
        field(44; "Capture Date"; Date)
        {
            Editable = false;
        }
        field(46; "Approved by"; Code[50])
        {
            Editable = false;
        }
        field(47; "Approval Date"; Date)
        {
            Editable = false;
        }
        field(48; Changed; Boolean)
        {
            Editable = false;
        }
        field(49; "Responsibility Centers"; Code[20])
        {
            TableRelation = "Responsibility Center";
        }
        field(50; "Member Cell Group"; Code[30])
        {
            TableRelation = "Hexa Binary";

            trigger OnValidate()
            begin
                if MemberCell.Get("Member Cell Group") then begin
                    // "Member Cell Name":=MemberCell."Cell Group Name";
                end;
            end;
        }
        field(51; "Member Cell Name"; Code[30])
        {
        }
        field(52; "Group Account No"; Code[30])
        {
            TableRelation = Customer."No." where("Group Account" = filter(true));
        }
        field(53; "Group Account Name"; Code[30])
        {
        }
        field(54; "Member Account Status"; Enum "Account Status")
        {
        }
        field(55; "Mobile No(New Value)"; Code[50])
        {
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                // if not SFactory.FnValidatePhoneNo("Mobile No(New Value)") then
                //     Error('Invalid Mobile phone number');
            end;
        }
        field(56; "Name(New Value)"; Text[40])
        {
        }
        field(57; "No. Series(New Value)"; Code[30])
        {
        }
        field(58; "Address(New Value)"; Code[30])
        {
        }
        field(59; "Branch(New Value)"; Code[30])
        {
        }
        field(60; "Picture(New Value)"; Media)
        {
        }
        field(61; "signinature(New Value)"; Media)
        {
        }
        field(62; "City(New Value)"; Code[30])
        {
        }
        field(63; "E-mail(New Value)"; Text[250])
        {
            trigger OnValidate()
            var
                myInt: Integer;
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("E-mail(New Value)");

            end;
        }
        field(64; "Personal No(New Value)"; Code[30])
        {
        }
        field(65; "ID No(New Value)"; Code[40])
        {
        }
        field(66; "Marital Status(New Value)"; Option)
        {
            OptionCaption = ' ,Single,Married,Devorced,Widower,Widow';
            OptionMembers = " ",Single,Married,Devorced,Widower,Widow;
        }
        field(67; "Passport No.(New Value)"; Code[30])
        {
        }
        field(68; "Status(New Value)"; Option)
        {
            OptionCaption = 'Open,Pending,Approved,Rejected';
            OptionMembers = Open,Pending,Approved,Rejected;
        }
        field(69; "Account Type(New Value)"; Code[30])
        {
        }
        field(70; "Account Category(New Value)"; Option)
        {
            OptionCaption = 'Single,Joint,Corporate,Group,Parish,Church,Church Department,Staff';
            OptionMembers = Single,Joint,Corporate,Group,Parish,Church,"Church Department",Staff;
        }
        field(71; "Email(New Value)"; Text[250])
        {
        }
        field(72; "Section(New Value)"; Code[40])
        {
        }
        field(73; "Card No(New Value)"; Code[30])
        {
        }
        field(74; "Home Address(New Value)"; Code[30])
        {
        }
        field(75; "Loaction(New Value)"; Code[20])
        {
        }
        field(76; "Sub-Location(New Value)"; Code[30])
        {
        }
        field(77; "District(New Value)"; Code[30])
        {
        }
        field(78; "Signing Instructions(NewValue)"; Text[40])
        {
        }
        field(79; "S-Mobile No(New Value)"; Code[10])
        {
        }
        field(80; "ATM No.(New Value)"; Date)
        {
        }
        field(81; "Monthly Contributions(NewValu)"; Decimal)
        {
        }
        field(82; "Member Account Status(NewValu)"; enum "Account Status")
        {
        }
        field(83; "Charge Reactivation Fee"; Boolean)
        {
        }
        field(84; "Phone No."; Code[20])
        {
        }
        field(85; "Phone No.(New)"; Code[20])

        {
            trigger Onvalidate()
            var
                myInt: Integer;
            begin
                // if not SFactory.FnValidatePhoneNo("Phone No.(New)") then
                //     error('Inavalid Phone Number entered');
            end;
        }
        field(86; Blocked; enum "Vendor Blocked")
        {
            // OptionCaption = ' ,Ship,Invoice,All';
            // OptionMembers = " ",Ship,Invoice,All;
        }
        field(87; "Blocked (New)"; enum "Vendor Blocked")
        {
            // OptionCaption = ' ,Ship,Invoice,All';
            // OptionMembers = " ",Ship,Invoice,All;
        }
        field(88; "Status (New Value)"; Option)
        {
            OptionCaption = 'Active,Frozen,Closed,Archived,New,Dormant,Deceased,Retired';
            OptionMembers = Active,Frozen,Closed,Archived,New,Dormant,Deceased,Retired;
        }
        field(89; "Employer Code"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Employer Code(New)"; Code[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sacco Employers".Code;
        }
        field(91; "Status."; Enum "Account Status")
        {
            DataClassification = ToBeClassified;
        }
        field(92; "Status.(New)"; Enum "Account Status")
        {
            DataClassification = ToBeClassified;
        }
        field(93; "Retirement Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(94; "Retirement Date(New)"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(95; "Date Of Birth"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Date Of Birth" <> 0D then begin
                    Age := Dates.DetermineAge("Date Of Birth", Today);
                end;
            end;
        }
        field(96; Disabled; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(97; "Occupation(New)"; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(98; Occupation; Code[40])
        {
            DataClassification = ToBeClassified;
        }
        field(99; "Bank Code(Old)"; Code[200])
        {
            DataClassification = ToBeClassified;
            TableRelation = Banks."Bank Code";

            trigger OnValidate()
            var
                Banks: Record Banks;
            begin

                /*Banks.RESET;
                Banks.SETRANGE(Banks.Code,"Bank Code");
                IF Banks.FIND('-') THEN
                  "Bank Name":=Banks."Bank Name";*/

            end;
        }
        field(100; "Bank Code(New)"; Code[200])
        {
            DataClassification = ToBeClassified;
            TableRelation = Banks."Bank Code";

            trigger OnValidate()
            var
                Banks: Record Banks;
            begin

                Banks.Reset;
                Banks.SetRange(Banks."Bank Code", "Bank Code(New)");
                if Banks.Find('-') then
                    "Bank Name (New)" := Banks."Bank Name";
            end;
        }
        field(101; "Bank Account No(Old)"; Code[200])
        {
            DataClassification = ToBeClassified;
        }
        field(102; "Bank Account No(New)"; Code[200])
        {
            DataClassification = ToBeClassified;
        }
        field(103; "KRA Pin(Old)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(104; "KRA Pin(New)"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(105; Age; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(106; Gender; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Male, Female';
            OptionMembers = " ",Male," Female";
        }
        field(107; "Bank Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(108; "Bank Name (New)"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(109; "Bank Branch Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(110; "Bank Branch Name(New)"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(111; "Bank Branch Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(112; "Bank Branch Code(New)"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Bank Branch"."Branch No";

            trigger OnValidate()
            begin
                Bankbranch.Reset;
                Bankbranch.SetRange(Bankbranch."Branch No", "Bank Branch Code(New)");
                if Bankbranch.Find('-') then
                    "Bank Branch Name(New)" := Bankbranch."Branch Name";
            end;
        }
        field(113; "Post Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(114; "Post Code (New)"; Code[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Post Code".Code;

            trigger OnValidate()
            begin
                PostCodes.Reset;
                PostCodes.SetRange(PostCodes.Code, "Post Code (New)");
                if PostCodes.Find('-') then
                    "City(New Value)" := PostCodes.City;
            end;
        }
        field(115; "Position In the Sacco"; enum "Position In the Sacco")
        {

        }
        field(116; "Position In the Sacco(New)"; enum "Position In the Sacco")
        {

        }
        field(117; "SMS Notification"; Boolean)
        {

        }
        field(118; "SMS Notification (New)"; Boolean)
        {

        }
        field(119; "Mpesa mobile No."; Code[20])
        {

        }
        field(120; "Mpesa mobile No.(New)"; Code[20])
        {

        }

    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin


        if No = '' then begin
            SalesSetup.Get;
            SalesSetup.TestField(SalesSetup."Change Request No");
            NoSeriesMgt.InitSeries(SalesSetup."Change Request No", xRec."No. Series", 0D, No, "No. Series");
        end;

        "Captured by" := UserId;
        "Capture Date" := Today;
    end;

    var
        SalesSetup: Record "Sacco No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        vend: Record Vendor;
        Memb: Record Customer;
        MemberCell: Record "Hexa Binary";
        SFactory: Codeunit "SURESTEP Factory";
        MediaId: Guid;
        Dates: Codeunit "Dates Calculation";
        MemmberExit: Record "Membership Withdrawals";
        Bankbranch: Record "Bank Branch";
        PostCodes: Record "Post Code";
}