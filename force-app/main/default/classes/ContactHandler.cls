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