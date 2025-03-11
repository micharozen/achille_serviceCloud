import { LightningElement, api, wire } from 'lwc';
import ACHILLE_LOGO from '@salesforce/resourceUrl/achille_logo';
import ACHILLE_AISAT from '@salesforce/resourceUrl/achille_aisat';
import ACHILLE_PRIORITY from '@salesforce/resourceUrl/achille_priority';


// Apex Class Import
import getCaseLastInfo from '@salesforce/apex/AchilleAPIService.getCaseLastInfo';
import checkApiKey from '@salesforce/apex/AchilleAPIService.checkApiKey';

export default class AchilleStatusIndicator extends LightningElement {
    @api recordId;
    achilleLogo = ACHILLE_LOGO;
    achilleAisat = ACHILLE_AISAT;
    achillePriority = ACHILLE_PRIORITY;
    
    // Variables pour stocker les informations du ticket
    aisatValue = 'Aucun';
    priorityValue = 'Aucune';
    clientStatus = 'Non enregistré';
    messageStatus = '?';
    
    showApiKeyError = false;
    
    async connectedCallback() {
        try {
            const isValidApiKey = await checkApiKey();
            if (!isValidApiKey) {
                this.showApiKeyError = true;
                return;
            }
            
            if (this.recordId) {
                this.getLastTicketInfo();
            }
        } catch (error) {
            console.error('Erreur lors de la vérification de l\'API key:', error);
            this.showApiKeyError = true;
        }
    }
    
    async getLastTicketInfo() {
        
        
        // Le code API original est commenté pour une utilisation future
        try {
            const response = await getCaseLastInfo({ caseId: this.recordId });
            
            if (!response) {
                throw new Error('Erreur réseau');
            }
            
            this.updateIndicators(response);
            
        } catch (error) {
            console.error('Erreur lors de la récupération des informations:', error);
            this.setDefaultValues();
        }
    }
    
    updateIndicators(data) {
        // Mise à jour AISAT
        this.aisatValue = data.AISAT ? `${data.AISAT} %` : 'Aucun'; // Couleur aussi 
        
        // Mise à jour Priorité
        if (data.Urgency) {
            if (data.Urgency <= 50) this.priorityValue = 'Normale'; // Vert
            else if (data.Urgency <= 85) this.priorityValue = 'Urgent'; // Orange
            else this.priorityValue = 'Très urgent'; // Rouge
        }
        
        // Mise à jour statut client
        this.clientStatus = data.IsRealCustomer ? 'Enregistré' : 'Non enregistré';
        
        // Mise à jour type de message
        if (data.LastMsgType === 'ASSISTANT') {
            this.messageStatus = 'En attente...';
        } else if (data.LastMsgType === 'CUSTOMER') {
            switch(data.LastMsgCode) {
                case 0: this.messageStatus = 'Suggestion ok'; break;
                case 5: this.messageStatus = 'Humain requis !'; break;
                case 10: this.messageStatus = 'SPAM détecté'; break;
                case 11: this.messageStatus = 'Collaboration ?'; break;
                case 12: this.messageStatus = 'Répondeur auto'; break;
                case 13: this.messageStatus = 'Notification'; break;
                case 14: this.messageStatus = 'Aucun problème'; break;
                default: this.messageStatus = '?';
            }
        }
    }
    
    setDefaultValues() {
        this.aisatValue = 'Aucun';
        this.priorityValue = 'Aucune';
        this.clientStatus = 'En attente...';
        this.messageStatus = 'En attente...';
    }
    
    // Getters pour les classes CSS conditionnelles
    get aisatClass() {
        if (this.aisatValue === 'Aucun' || this.aisatValue === 'Aucune') {
            return 'indicator-value info-background';
        }
        const aisatNumber = parseInt(this.aisatValue);
        if (isNaN(aisatNumber)) return 'indicator-value info-background';
        if (aisatNumber <= 50) return 'indicator-value success-background';
        if (aisatNumber <= 85) return 'indicator-value warning-background';
        return 'indicator-value danger-background';
    }
    
    get priorityClass() {
        switch(this.priorityValue) {
            case 'Aucune':
            case 'Aucun': 
                return 'indicator-value info-background';
            case 'Normale': 
                return 'indicator-value success-background';
            case 'Urgent': 
                return 'indicator-value warning-background';
            case 'Très urgent': 
                return 'indicator-value danger-background';
            default: 
                return 'indicator-value info-background';
        }
    }
    
    get clientStatusClass() {
        return `indicator-value ${this.clientStatus === 'Enregistré' ? 'success-background' : 'info-background'}`;
    }
    
    get messageStatusClass() {
        return `indicator-value ${this.messageStatus === 'Suggestion ok' ? 'success-background' : 'info-background'}`;
    }
} 