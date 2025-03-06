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