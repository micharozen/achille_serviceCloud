import { LightningElement, api } from 'lwc';

const ICONS = {
    'info': 'utility:info',
    'warning': 'utility:warning',
    'error': 'utility:error'
};

const VARIANTS = {
    'info': 'slds-theme_info box-info',
    'warning': 'slds-theme_warning box-warning',
    'error': 'slds-theme_error box-error'
};

const ICONS_STYLE = {
    'info': 'icon-color-info',
    'warning': 'icon-color-warning',
    'error': 'icon-color-error'
};

export default class AchilleNotification extends LightningElement {
    @api type = 'info';
    @api title;
    @api message;

    get icon() {
        return ICONS[this.type];
    }

    get variant() {
        return "slds-p-around_xx-small slds-box slds-m-around_x-small " + VARIANTS[this.type];
    }

    get iconDecoration() {
        return ICONS_STYLE[this.type];
    }
} 