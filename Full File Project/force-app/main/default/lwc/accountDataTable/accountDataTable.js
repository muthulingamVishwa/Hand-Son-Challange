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
        draftValues = [...draftValues, updatedItem];
    
        this.template.querySelector("c-custom-type-data").draftValues = draftValues;
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
