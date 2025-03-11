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
 # Approval Matrices Setup

## Step 1: Enable and Configure Objects

1. **Enable the Quote Object**
   - Search for `Quote` in **Quick Find**.
   - Enable it if not already enabled.

2. **Create Approver Fields in Quote Object**
   - Add three **Lookup Fields** (to User):
     - `First-Level Approver`
     - `Second-Level Approver`
     - `Third-Level Approver`

3. **Create Approval Matrices Object**
   - Create a custom object: `Approval Matrices`.
   - Add these fields:
     - `First-Level Approver` (Lookup to User)
     - `Second-Level Approver` (Lookup to User)
     - `Third-Level Approver` (Lookup to User)
     - `Account Country` (Picklist with 5 countries)
     - `Opportunity Type` (Picklist with:
       - New Business – New Customer
       - New Business – Existing Customer
       - Existing Business - Additional Order
       - Existing Business - Change Existing Order)

4. **Add Fields in Account and Opportunity**
   - **Account**: `Account Country` (Picklist with 5 countries)
   - **Opportunity**: `Opportunity Type` (Picklist with the above values)

# Approval Assignment Using Flow and Subflow in Salesforce

## Step 2: Create a Flow

### 1. Record-Triggered Flow (Main Flow)
- Go to **Setup > Flow**.
- Click **New Flow** and select **Record-Triggered Flow**.
- Configure the flow to trigger when a **Quote** record is created.
- Retrieve the appropriate **Approvers** based on the `Approval Matrices` object.

  ![Image](https://github.com/user-attachments/assets/b646c4eb-cca6-46fa-abe7-15454782defe)
  
#### Handling Missing Fields
If **Account Country** or **Opportunity Type** is NULL, display a **Custom Error Message**.

![Image](https://github.com/user-attachments/assets/1657f77a-771c-4d01-b7b5-62a70606bb39)
#### Fetching Approvers
If both fields are populated, call a **Subflow** to retrieve the approvers.

![Image](https://github.com/user-attachments/assets/a6cfd814-683a-4801-974a-e95907757516)
---

### 2. Autolaunched Flow (Subflow)
- Create a **New Flow**.
- Select **Autolaunched Flow (No Trigger)**.
- Get records based on **Account Country** and **Opportunity Type**.
  
![Image](https://github.com/user-attachments/assets/71aeeebb-7a01-4cef-a471-e986b2305ba5)

#### Matching Approval Matrices Record
If a matching record is found, assign the approvers to the Quote.
  ![Image](https://github.com/user-attachments/assets/2598a736-3a83-47c4-ba39-365e9b4b7f20)
  
#### No Matching Record Found
If no matching record exists, send a **Custom Notification**.

![Image](https://github.com/user-attachments/assets/31f1ddae-1c25-4536-9dd7-64c71e7bef1f)
---

### Outcome
This flow ensures that every **Quote** automatically assigns the correct approvers based on predefined conditions, improving approval efficiency and reducing manual effort.
#### Error Message
![Image](https://github.com/user-attachments/assets/c7a306a4-1dfa-47a9-b463-aa183c3002d3)

#### Custom Notification
![image](https://github.com/user-attachments/assets/e74d2c1a-662a-4975-91ab-52d5cc8ce567)

#### Assign the approvers to the Quote
![image](https://github.com/user-attachments/assets/d880c40a-118d-42a0-902a-543d1f97585e)


---      
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

## Trigger Answer
---
```apex
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

```apex
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
---
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
---  
## Answer 

- Created required fields on account object
- Apex class retrieves Account records with required fields and makes them available for use in LWC.
```apex

  public with sharing class getAccounttoDataTable {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounttoData(){
            return [select id,
                           name,
                           Account_Activation_Date__c,
                           Status__c,
                           Country__c,
                           Comments__c from account limit 10 ];
        
    }
 
}
```
### Custom Lightning Datatable
**CustomTypeData.js**
![code 1](https://github.com/user-attachments/assets/bd643bd8-4850-45c9-8c2d-3817aedf6423)


**Editing CustomTypeData.js File** 
- Modify the CustomTypeData.js file to implement a custom datatable as per your requirements.
![image](https://github.com/user-attachments/assets/e506d564-6cf0-4769-a8ab-c92c0767b54d)

- Created Custom HTML File on Custom Lightning Datatable.
  
![image](https://github.com/user-attachments/assets/7c774e42-66da-4d30-bcad-c0c14fbb568d)

- After HTML Add file.
![image](https://github.com/user-attachments/assets/1eb465a1-90f0-485f-bff4-69d1f85d199f)

```sh
CustomEditPicklist.html
customTypeData.css
customTypeData.html
customTypeData.js
customTypeData.js-meta.xml
displaytexthtml
icon.html
picklistvalue.html
```
## customTypeData.css
```css
:host .slds-table {
    /* Force columns to respect widths and allow wrapping */
    table-layout: fixed !important;
    width: 100% !important;
}

:host .slds-table td {
    white-space: normal !important;
    word-break: break-word !important;
    overflow-wrap: break-word !important;
}

```
## customTypeData.js
```jsx
import LightningDatatable from 'lightning/datatable';
import icon from './icon.html';
import picklistEditable from './CustomEditPicklist.html';
import picklistNotEditable from './picklistvalue.html';
import displaytext from './displaytext.html';
export default class CustomTypeData extends LightningDatatable  {
static customTypes={
    picklistColumn: {
        template: picklistNotEditable,
        editTemplate: picklistEditable,
        standardCellLayout: true,
        typeAttributes : ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
    },
    picklisticon: {
        template: icon,
        editTemplate: picklistEditable,
        standardCellLayout: true,
        typeAttributes : ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
    },
    Commenttype: {
        template: displaytext,
        typeAttributes: ['value', 'context','draftValues']
    }
};


}

```
## picklistvalue.html
```HTML
<template>
        <span class="slds-truncate" title={value}>{value}</span>
    </template>
```
## displaytext.html
```HTML

 <template>

   <!--call Component (Child LWC) areatext (Child Lwc) -->
   <c-area-text value={typeAttributes.value} context={typeAttributes.context} ></c-area-text>

</template>
```
## areatext (Child Lwc)
### areatext.html
```HTMl
<template>
   
    <template if:true={isViewMode} >
        <div class="slds-form-element"  onclick={toggleEdit}  
        onmouseenter={handleMouseEnter} 
        onmouseleave={handleMouseLeave}>
            <div class="slds-form-element__control custom-form-element">
                <div class="slds-form-element__static custom-static-text">
                    <p>{togglevalue} <lightning-icon if:true={showEditIcon}
                        icon-name="utility:edit" 
                        onclick={toggleEdit}
                        size="xx-small" 
                        class="slds-float_right" 
                        alternative-text="Edit">
                    </lightning-icon></p> 
                </div>
            </div>
        </div>
    </template>


    <template if:false={isViewMode}>
            <div class="slds-p-around_small">
                    <lightning-textarea 
                    class="textAreaBody"
                        label="Enter Comment" 
                        variant="label-hidden"
                        onblur={saveEdit}
                        value={togglevalue}
                        maxlength="140"
                        >
                    </lightning-textarea>
        
            </div>
    
    </template>
</template>  

```
## areaText.css
```css

.custom-static-text {
    white-space: normal;     
    word-break: break-word;  
    overflow-wrap: break-word; 
    line-height: 1.5;        
}
.custom-static-text p {
    margin: 0;              
    padding: 0;           
}
.textAreaBody {
    --sds-c-textarea-sizing-min-height:105px;
}
```
## areaText.js
```jsx
import { LightningElement,api,track } from 'lwc';

export default class AreaText extends LightningElement {
    @api value;
    @api context;
    @track togglevalue;
    @track isViewMode = true; 

    @track showEditIcon = false;
   renderedCallback() {
        this.togglevalue = this.value;
    }
  
    handleMouseLeave() {
        this.showEditIcon = false;
    }

    handleMouseEnter() {
        this.showEditIcon = true;
    }
    toggleEdit() {
        this.isViewMode = !this.isViewMode;
        this.showEditIcon = false;
    }

    saveEdit(event) {
        this.isViewMode = true; 
        event.preventDefault();
        
        let textarea = this.template.querySelector('lightning-textarea');
    
        if (textarea.value !== this.value) {
            this.value = textarea.value;
            this.togglevalue = textarea.value;
        

        const toggel = new CustomEvent('changecommunt', {
            composed:true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: textarea.value } 
            }
        });
        this.dispatchEvent(toggel);
    }
        
        
    }


}
```

### CustomEditPicklist.html
```HTML
<template>
    <lightning-combobox name="picklist" data-inputable="true" 
    label={typeAttributes.label} value={editedValue} 
    placeholder={typeAttributes.placeholder} options={typeAttributes.options}
    variant='label-hidden'
        dropdown-alignment="auto"></lightning-combobox>
</template>
```
### icon.html
```HTML
<template>

   <!-- Component (Child LWC) -->
    <c-icon-display value={value}></c-icon-display>
</template>

```
## iconDisplay (Child Lwc)
### iconDisplay.html
```html
<template>
    <lightning-icon icon-name={iconName} alternative-text={value} title={value} size="x-small" class="slds-float_right">
        </lightning-icon>
</template>
```
### iconDisplay.js
```jsx
import { LightningElement ,api} from 'lwc';

export default class IconDisplay extends LightningElement {
    @api value;
    get iconName() {
        const iconMap = {
            'Active': 'action:approval',
            'Inactive': 'action:reject',
            'Created': 'action:goal',
            'Closed': 'action:close'
        };
        return iconMap[this.value] || 'utility:question';
    }
}
```
# created lwc 
## accountDataTable.html
```html
<template>
   <lightning-card title="Account" icon-name="standard:account">
       <div class="slds-m-around_medium">

   <!-- custom DataTable Component (Child LWC) -->
           <c-custom-type-data
               key-field="Id"
               data={Accountdata}
               onsave={handleSave}
               columns={columns}
               oncancel={handleCancel}
            onchangecommunt={handleChange}
               draft-values={draftValues} 
               hide-checkbox-column="true">
           </c-custom-type-data>
       </div>
   </lightning-card>
</template>
```
## accountDataTable.js
```jsx
import { LightningElement,wire,track} from "lwc";
import  getAccounts  from "@salesforce/apex/getAccounttoDataTable.getAccounttoData";
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import  OBJECT_ACCOUNT from "@salesforce/schema/Account";
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from "@salesforce/schema/Account.Status__c";
import COUNTRY_FIELD from "@salesforce/schema/Account.Country__c";

const column=[{ label: 'Name', fieldName: 'Contactlink',type:'url', 
    typeAttributes: {
        label:{
            fieldName:"Name"
        },
        target:"_blank"
      } 
    },
    { label: 'Country', fieldName: 'Country__c', type: 'picklistColumn', editable: true,
        typeAttributes:{
            placeholder: 'Choose Country',
            options:{fieldName:"countrypicks"},
            value:{fieldName:'Country__c'},
            context:{fieldName:'Id'}
        } },
    { label: 'Status', fieldName: 'Status__c', type: 'picklisticon', editable: true ,
        typeAttributes:{
            placeholder: 'Choose Status',
            options:{fieldName:"Statuspicks"},
            value:{fieldName:'Status__c'},
            context:{fieldName:'Id'}
        }
    },
    { label: 'Account Activation Date', fieldName: 'Account_Activation_Date__c', type: 'date-local', editable: true },
    { 
        label: 'Comments', 
        fieldName: 'Comments__c', 
        type: 'Commenttype', 
        editable: false,
        typeAttributes: {
            value: { fieldName: 'Comments__c' },
            context: { fieldName: 'Id' }
        } 
    }
    

];
export default class AccountDataTable extends LightningElement {
  
    columns=column;
    @track Accountdata=[];
    wiredAccountResult;
    StatusPicklistValue;
    countrypicklistValue;
    @track draftValues =[];
     
 
    @wire(getObjectInfo,{objectApiName:OBJECT_ACCOUNT})
    objectInfo;


    @wire(getPicklistValues,{
        recordTypeId:"$objectInfo.data.defaultRecordTypeId",
        fieldApiName: STATUS_FIELD
    })
    stPicklistValue({data,error}){
            if(data){
                this.StatusPicklistValue=data.values;
          
            }else{
                
            }
        }
        
    @wire(getPicklistValues,{
            recordTypeId:"$objectInfo.data.defaultRecordTypeId",
            fieldApiName:COUNTRY_FIELD})ctPicklistValue({data,error}){
                if(data){
                    this.countrypicklistValue=data.values;
                } else if (error) {
                     }
            }

    @wire(getAccounts,{pickList: '$countrypicklistValue'}) wireReocrd(result){  
        this.wiredAccountResult=result;
        if(result.data){
            this.Accountdata=result.data.map((record)=>{
                let Contactlink="/"+record.Id;
                let Statuspicks=this.StatusPicklistValue;
                let countrypicks=this.countrypicklistValue;
                return{...record,Contactlink: Contactlink,Statuspicks:Statuspicks,countrypicks:countrypicks} 
            })
        }else if(result.errer){
            console.log(result.errer);
        }
    }

 handleSave(event) {
        let records = event.detail.draftValues;
        
        let updatesrecord = records.map(curr => ({ fields: { ...curr } }));
        this.updateRecords(updatesrecord);
        this.draftValues=[]; 
      

    }

     handleChange(event){
        event.stopPropagation();
        let updatedItem = { 
            Id: event.detail.data.context, 
            Comments__c: event.detail.data.value  
        };
    
        let draftValues = this.template.querySelector("c-custom-type-data").draftValues || [];
         let updatedDraftValues = draftValues.some(item => item.Id === updatedItem.Id) ? draftValues.map(item => item.Id === updatedItem.Id ? { ...item, ...updatedItem } : item): [...draftValues, updatedItem];
    
        this.template.querySelector("c-custom-type-data").draftValues = updatedDraftValues;
    
    }

 
 updateRecords(records){
    Promise.all(records.map(curr => updateRecord(curr))).then(result=>{
        this.ShowToast('Success',result.length+' record update successfully','success','dismissable');
        return this.refresh();
     }).catch(error => {
         this.ShowToast( 'Error updating records', error.body ? error.body.message : error.message,'error','dismissable');
         return this.refresh();
     });
  
 }


 ShowToast(title, message, variant, mode){
    const evt = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
}

async refresh() {
    await refreshApex(this.wiredAccountResult);
}



handleCancel(event){
    let savedeft=this.countrypicklistValue;
    this.Accountdata=[];
    this.countrypicklistValue=null;
    this.countrypicklistValue=savedeft;
    
}


}

```
## accountDataTable.js-meta.xml
```jsx
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
	<apiVersion>61.0</apiVersion>
	<isExposed>true</isExposed>
	<masterLabel>LWC Account</masterLabel>
	<targets>
		<target>lightning__AppPage</target>
		<target>lightning__Tab</target>
	</targets>
	<targetConfigs>
		<targetConfig targets="lightning__AppPage">
			<supportedFormFactors>
				<supportedFormFactor type="Small"/>
				<supportedFormFactor type="Large"/>
			</supportedFormFactors>
		</targetConfig>
	</targetConfigs>
</LightningComponentBundle>
```
---
# Output

![image](https://github.com/user-attachments/assets/67bf6af8-03f6-4120-8553-9edf70974e99)


![image](https://github.com/user-attachments/assets/752a4ade-a111-4dd2-976f-ac9254d71bb9)

![image](https://github.com/user-attachments/assets/e3994c18-464b-4f2c-8118-037000aba64f)


https://github.com/user-attachments/assets/a0e026fa-a4d6-4c71-925c-93ff9ba7a1bd












