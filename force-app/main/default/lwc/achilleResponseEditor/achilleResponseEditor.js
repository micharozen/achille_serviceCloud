import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AchilleResponseEditor extends LightningElement {
    @api recordId;
    suggestionContent = '';
    userResponse = '';
    
    // Méthode pour récupérer la suggestion d'Achille AI
    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Case.Achille_Suggestion__c']
    })
    wiredCase({ error, data }) {
        if (data) {
            this.suggestionContent = data.fields.Achille_Suggestion__c.value;
        } else if (error) {
            this.showToast('Erreur', 'Impossible de charger la suggestion', 'error');
        }
    }

    handleUserResponseChange(event) {
        this.userResponse = event.target.value;
    }

    // Méthode pour insérer la suggestion dans l'éditeur Salesforce
    insertSuggestion() {
        // Dispatch d'un événement personnalisé pour communiquer avec le composant parent
        this.dispatchEvent(new CustomEvent('insertresponse', {
            detail: { response: this.suggestionContent }
        }));
    }

    // Méthode pour insérer la réponse de l'utilisateur
    insertUserResponse() {
        this.dispatchEvent(new CustomEvent('insertresponse', {
            detail: { response: this.userResponse }
        }));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
} 