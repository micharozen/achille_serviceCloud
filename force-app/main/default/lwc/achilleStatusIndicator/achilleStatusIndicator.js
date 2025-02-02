import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACHILLE_LOGO from '@salesforce/resourceUrl/achille_logo';
import ACHILLE_AISAT from '@salesforce/resourceUrl/achille_aisat';
import ACHILLE_PRIORITY from '@salesforce/resourceUrl/achille_priority';

// Import des champs personnalisés (à adapter selon vos noms de champs)
import CURRENT_STATUS_FIELD from '@salesforce/schema/Case.Status';
import AISAT_FIELD from '@salesforce/schema/Case.Id';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import REGISTERED_CLIENT_FIELD from '@salesforce/schema/Case.Subject';

export default class AchilleStatusIndicator extends LightningElement {
    @api recordId;
    achilleLogo = ACHILLE_LOGO;
    achilleAisat = ACHILLE_AISAT;
    achillePriority = ACHILLE_PRIORITY;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CURRENT_STATUS_FIELD, AISAT_FIELD, PRIORITY_FIELD, REGISTERED_CLIENT_FIELD]
    })
    case;

    get aisat() {
        return '55';  // Valeur fixe pour correspondre à l'image
    }

    get priority() {
        return 'Normale';  // Valeur fixe pour correspondre à l'image
    }

    get currentStatus() {
        return getFieldValue(this.case.data, CURRENT_STATUS_FIELD);
    }

    get isRegisteredClient() {
        return false;  // Valeur fixe pour correspondre à l'image
    }
} 