# Hands-On Challenge

## Interview Tasks

### Task 1: Flow and Subflow

#### Requirement Overview
Implement a solution in Salesforce using Flow and Sub-flow to automatically populate the **First Approver, Second Approver, and Third Approver** fields on a **Quote** record when it is created. The approvers will be determined based on specific conditions by comparing the **Account Country** and **Opportunity Type** fields with records in the **Approval Matrices** object.

#### Objects Involved
1. **Quote**
   - Fields:
     - Approver 1: Lookup field to the Custom User object
     - Approver 2: Lookup field to the Custom User object
     - Approver 3: Lookup field to the Custom User object

2. **Approval Matrices** (Custom Object)
   - Fields:
     - First-Level Approver: Lookup field to the User object
     - Second-Level Approver: Lookup field to the User object
     - Third-Level Approver: Lookup field to the User object
     - Account Country: Picklist (5 random countries)
     - Opportunity Type: Picklist with the following values:
       - New Business – New Customer
       - New Business – Existing Customer
       - Existing Business - Additional Order
       - Existing Business - Change Existing Order

3. **User** (Custom Object)
   - Fields:
     - First Name
     - Last Name
     - Email
   - Create 3-4 records for approvers.

4. **Account**
   - Fields:
     - Account Country (Picklist with same values as Approval Matrices)

5. **Opportunity**
   - Fields:
     - Opportunity Type (Picklist with same values as Approval Matrices)

#### Sample Records in Approval Matrices
| Account Country | Opportunity Type                       | First Level Approver | Second Level Approver | Third Level Approver |
|-----------------|--------------------------------------|----------------------|----------------------|----------------------|
| India          | New Business – New Customer         | User 1               | User 2               | User 3               |
| India          | Existing Business - Additional Order | User 2               | User 1               | User 3               |
| USA            | Existing Business - Change Existing Order | User 4         | User 5               | User 6               |
| UK             | New Business – Existing Customer     | User 3               | User 5               | User 6               |

#### Flow Implementation
- **Main Flow**: Triggers when a **Quote** is created.
- **Sub-flow**: Encapsulates logic for fetching approvers based on conditions to ensure reusability.

---
# Answer Task 1:
  step 1 : Enable the Quote object in Quick find 
     create the three approver Fields in quote Object (lookup to user)
     create the custom object Approval Matrices
     cerate Fields in Approval Matrices:
     - First-Level Approver: Lookup field to the User object
     - Second-Level Approver: Lookup field to the User object
     - Third-Level Approver: Lookup field to the User object
     - Account Country: Picklist (5 random countries) and cerate this fields in Account object.
     - Opportunity Type: Picklist with the following values and cerate this fields in Opportunity object.:
       - New Business – New Customer
       - New Business – Existing Customer
       - Existing Business - Additional Order
       - Existing Business - Change Existing Order

Step 2 : new flow 

           


       
### Task 2: Apex Trigger

#### Field Requirements
1. **Contact Object**
   - Annual Revenue: Currency field
   - Country: Single-select picklist
   - State: Single-select picklist
   - IsActive: Checkbox (Boolean field)

2. **Account Object**
   - Country: Single-select picklist
   - State: Multi-select picklist
   - Total Annual Revenue: Currency field

#### Functional Requirements
1. **Field Dependencies**
   - Country on **Contact**: Automatically populated from the related **Account** and must be read-only.
   - State on **Contact**: Should display only states corresponding to the selected country.

2. **State Rollup to Account**
   - For all **Active Contacts** (IsActive = true), retrieve their **State** values and update the **Account's State** multi-select picklist.

3. **Annual Revenue Calculation**
   - Sum the **Annual Revenue** of all **Active Contacts** (IsActive = true) and populate the **Account's Total Annual Revenue** field.

#### Trigger Requirements
- Execute on **Insert, Update, and Delete** events on **Contact**.
- Handle bulk records efficiently using **maps, sets, and collections** to stay within governor limits.

---

## Answer Ans

Trigger 
---
```jsx
trigger HandlerContact on Contact (before  insert,before update,after insert,after update,after undelete,after delete) {

    switch on Trigger.operationtype{
        when before_insert{
            ContactHandler.ValidationRule(trigger.new);
        }
        when before_update{
            ContactHandler.ValidationRule(trigger.new);
        }
        when After_insert{
            ContactHandler.AccountUpdate(trigger.new,null);
        }
        when After_update{
             ContactHandler.AccountUpdate(trigger.new,trigger.oldMap);
        }
         when After_delete{
             ContactHandler.AccountUpdate(trigger.old,null);
        }
          when After_undelete{
             ContactHandler.AccountUpdate(trigger.new,null);
        }
    }
}
```

Class 
---

```jsx
   public class ContactHandler {
 
    
    public Static void AccountUpdate(list<contact> NewlistContact ,map<id,contact> OldMap ){
        
        set<id> ListAccountId=new set<id>();
  
        for(Contact Contacts:NewListContact){ 
            
            if(Contacts.AccountId !=null && OldMap==null) { 
                ListAccountId.add(Contacts.AccountId);
            }
            else if((Contacts.AccountId !=null) && (Contacts.AccountId != OldMap.get(Contacts.Id).AccountID ||
                     Contacts.IsActive__c != OldMap.get(Contacts.Id).IsActive__c || 
                     Contacts.State__c != OldMap.get(Contacts.Id).State__c)) {
                                                                  ListAccountId.add(Contacts.AccountId);
                                                                     if(OldMap.get(Contacts.id).AccountId !=null){
                                                                         ListAccountId.add(OldMap.get(Contacts.id).AccountId);
                                                                     }
            }
            else  if(Contacts.AccountId==null && OldMap !=null){
                               ListAccountId.add(OldMap.get(Contacts.id).AccountId);
                     }
           
        }
        
          if(ListAccountId.isEmpty()){
            
            return;
        }
        
        map<id,Decimal> AnnualReveneAcc=new map<id,Decimal>();
        
        for(Aggregateresult result:[Select Sum(Annual_Revenue__c) TotalAnnualR,AccountID from Contact where IsActive__c =true and AccountId in:ListAccountId group by AccountId])
        {
            AnnualReveneAcc.put((id)result.get('AccountID'),(Decimal)result.get('TotalAnnualR'));
        }
        
        map<id,set<string>> StatesList=new map<id,set<string>>();
        for(Contact Contact:[Select id,State__c,AccountID from Contact where IsActive__c =true and AccountId in:ListAccountId And State__c != null])
        {
            if(!StatesList.containskey(Contact.AccountID)){
                
                StatesList.put(Contact.AccountID,new set<string>{Contact.State__c});
                
            }else{
                StatesList.get(Contact.AccountID).add(Contact.State__c);
            }
               
        }
        
  list<Account> listAccount=new list<Account>();
        
        for(id ids:ListAccountId){
            Account Acc=new account();
              acc.Id=ids;
              acc.States__c=StatesList.get(ids)!=null ? String.join(StatesList.get(ids),';') : '';
              acc.AnnualRevenue=AnnualReveneAcc.get(ids) ?? 0;
              listAccount.add(acc);
            
        }
        
        if(!listAccount.isEmpty()){
            
            update listAccount;
        }
        
    }
    
    
    Public static void ValidationRule(list<Contact> listContact){

       set<id> AccountId=new set<id>();
        for(Contact contact:listContact){
            if(contact.AccountId !=null){
                AccountId.add(Contact.AccountId);
            }
        }
        if(AccountId.isEmpty()){
            return;
        }
        map<id,string> CountryAccount= new map<id,string>();
        for(Account Account:[select id,name,Country__c from Account where id =:AccountId]){
            if(Account.Country__c !=null){
                  CountryAccount.put(Account.Id,Account.Country__c);
            }
        }
        
        for(Contact contacts:listContact){
            if(CountryAccount.get(contacts.AccountId) != contacts.Country__c){
                contacts.adderror('Country must be '+CountryAccount.get(contacts.AccountId)+' as per the related Account Country.');
            }
        }
          
    }
}
```
 

### Task 3: Lightning Web Component (LWC)

#### Scenario: Custom Datatable for Account Management

#### Objective
Create a tab named **"LWC Accounts"** to display and manage **Account** records using a **custom LWC datatable**. Users should be able to edit **Account** details **inline**.

#### Requirements
1. **Tab Name**
   - "LWC Accounts"

2. **Fields Required on Account Object**
   - Country: Picklist field
   - Status: Picklist field with values:
     - Active
     - Inactive
     - Created
     - Closed
   - Account Activation Date: Date field
   - Comments: Long Text Area field

3. **Custom Datatable Features**
   - Display the following fields:
     - **Country**: Editable picklist field
     - **Status with Icon**: Display an SLDS icon for each status
     - **Account Activation Date**: Editable date field
     - **Comments**: Editable text area

4. **Inline Editing**
   - Users should be able to **edit Account details** directly within the datatable.

