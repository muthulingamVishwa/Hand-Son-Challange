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