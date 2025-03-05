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