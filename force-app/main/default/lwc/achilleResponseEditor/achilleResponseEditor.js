import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACHILLE_LOGO from '@salesforce/resourceUrl/achille_logo';
import ACHILLE_BG from '@salesforce/resourceUrl/achille_bg_editor';
import enrichText from '@salesforce/apex/AchilleAPIService.enrichText';
import getCaseLastInfo from '@salesforce/apex/AchilleAPIService.getCaseLastInfo';

export default class AchilleResponseEditor extends NavigationMixin(LightningElement) {
    @api recordId;
    achilleLogo = ACHILLE_LOGO;
    achilleBg = ACHILLE_BG;
    
    // États d'affichage
    showAnswer = false;
    showInfo = false;
    showError = false;
    showTransText = false;
    showSpinner = false;
    
    // Ajout de la propriété pour l'historique des réponses
    enrichedResponses = [];
    
    // Contenus
    answerContent = '';
    infoContent = '';
    errorContent = '';
    userText = '';
    infoTag = '';
    isTagError = false;
    
    // Méthodes de navigation
    handleAutoResponseTab() {
        this.showTransText = false;
        this.getLastTicketInfo();
    }
    
    handleEnrichTab() {
        this.hideAll();
        this.showTransText = true;
    }
    
    hideAll() {
        this.showAnswer = false;
        this.showInfo = false;
        this.showError = false;
        this.showSpinner = false;
    }
    
    // Appel API pour récupérer les informations
    async getLastTicketInfo() {
        try {
            this.showSpinner = true;
            const response = await getCaseLastInfo({caseId: this.recordId});
            
            if (!response) throw new Error('Erreur réseau');
                    
            console.log('data', response);
            this.processResponse(response);
            
        } catch (error) {
            this.showError = true;
            this.errorContent = "Une erreur est survenue lors de la communication avec Achille AI";
            this.showToast('Erreur', 'Problème de connexion', 'error');
        } finally {
            this.showSpinner = false;
        }
    }
    
    processResponse(data) {
        this.hideAll();
        console.log('data', data);
        if (data.MsgType === 'ASSISTANT') {
            this.showInfo = true;
            this.infoContent = "Achille est en attente d'une réponse du client.";
        } 
        else if (data.MsgType === 'CUSTOMER') {
            switch(data.MsgCode) {
                case 0:
                    this.showAnswer = true;
                    this.answerContent = data.Answer;
                    this.showToast('Succès', 'La suggestion d\'Achille est prête !', 'success');
                    break;
                case 5:
                    this.showInfo = true;
                    this.infoContent = data.Answer || "Achille vous laisse répondre à ce ticket.";
                    this.infoTag = "Lecture humaine requise";
                    this.isTagError = true;
                    break;
                // ... autres cas similaires à l'original
            }
        }
    }
    
    // Actions utilisateur
    handleUserTextChange(event) {
        this.userText = event.target.value;
    }
    
    async handleEnrichText() {
        if (!this.userText) return;
        
        try {
            this.showSpinner = true;
            const enrichedText = await enrichText({ 
                caseId: this.recordId, 
                text: this.userText 
            });
            console.log('enrichedText', enrichedText);
            
            if (enrichedText) {
                const now = new Date();
                const formattedTimestamp = new Intl.DateTimeFormat('fr-FR', {
                    day: '2-digit',
                    month: '2-digit',
                    year: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit'
                }).format(now);

                this.enrichedResponses = [...this.enrichedResponses, {
                    userText: this.userText,
                    enrichedText: enrichedText,
                    timestamp: now,
                    formattedTimestamp: formattedTimestamp
                }];

                this.showToast('Succès', 'Réponse enrichie !', 'success');
                this.userText = ''; // Réinitialisation du texte
            } else {
                throw new Error('Erreur lors de l\'enrichissement');
            }
            
        } catch (error) {
            this.showToast('Erreur', 'Problème lors de l\'enrichissement', 'error');
            console.error('Erreur enrichissement:', error);
        } finally {
            this.showSpinner = false;
        }
    }
    
    handleInsertSuggestion() {
        this.dispatchEvent(new CustomEvent('insertresponse', {
            detail: { response: this.answerContent }
        }));
        this.showToast('Succès', 'Suggestion insérée !', 'success');
    }
    
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
    
    // Getters pour les classes des onglets
    get autoResponseTabClass() {
        return `tab ${!this.showTransText ? 'active' : ''}`;
    }
    
    get enrichTabClass() {
        return `tab ${this.showTransText ? 'active' : ''}`;
    }
    
    // Ajouter cette méthode
    handleCopy(event) {
        const textToCopy = event.currentTarget.dataset.text;
        
        // Créer un élément temporaire pour nettoyer le HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = textToCopy;
        const cleanText = tempDiv.textContent || tempDiv.innerText || '';
        
        // Copier le texte dans le presse-papier
        navigator.clipboard.writeText(cleanText)
            .then(() => {
                this.showToast('Succès', 'Texte copié !', 'success');
            })
            .catch(err => {
                console.error('Erreur lors de la copie :', err);
                this.showToast('Erreur', 'Impossible de copier le texte', 'error');
            });
    }
    
    // Ajouter cette méthode
    handleEmail(event) {
        const emailText = event.currentTarget.dataset.text;
        
        // Nettoyer le texte HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = emailText;
        const cleanText = tempDiv.textContent || tempDiv.innerText || '';

        // Utiliser l'API de navigation pour ouvrir l'action rapide Email du Case
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName: 'Case.Email'
            },
            state: {
                recordId: this.recordId,
                defaultFieldValues: encodeURIComponent(`Body=${cleanText}`)
            }
        });
    }

    handleCancel() {
        this.hideAll();
    }

    // Ajout du getter pour le style du background
    get backgroundStyle() {
        return `--achille-bg-url: url(${this.achilleBg})`;
    }
} 