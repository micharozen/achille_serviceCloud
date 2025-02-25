import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACHILLE_LOGO from '@salesforce/resourceUrl/achille_logo';
import ACHILLE_BG from '@salesforce/resourceUrl/achille_bg_editor';
import enrichText from '@salesforce/apex/AchilleAPIService.enrichText';
import ACHILLE_MAIN_LOGO from '@salesforce/resourceUrl/achille_main_logo';
import getCaseLastInfo from '@salesforce/apex/AchilleAPIService.getCaseLastInfo';
import ACHILLE_WARRIOR from '@salesforce/resourceUrl/achille_warrior';
import ACHILLE_BACKGROUND from '@salesforce/resourceUrl/achille_bg_editor';
import ACHILLE_LOADER from '@salesforce/resourceUrl/achille_loader';

export default class AchilleResponseEditor extends NavigationMixin(LightningElement) {
    @api recordId;
    achilleLogo = ACHILLE_MAIN_LOGO;
    achilleBg = ACHILLE_BACKGROUND;
    achilleWarrior = ACHILLE_WARRIOR;
    achilleLoader = ACHILLE_LOADER;
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
    infoTagType = ''; // Type de tag: success, error, info
    errorMessage = '';
    
    // Propriétés pour les classes des onglets
    @track activeTab = 'autoresp';
    
    // Ajoutez cette propriété pour suivre si une réponse enrichie est disponible
    @track hasEnrichedResponse = false;
    @track lastEnrichedResponse = null;
    
    get autoResponseTabClass() {
        return this.activeTab === 'autoresp' ? 'tab tab-autoresp selected' : 'tab tab-autoresp';
    }
    
    get enrichTabClass() {
        return this.activeTab === 'transtext' ? 'tab tab-transtext selected' : 'tab tab-transtext';
    }
    
    get mainPanelAutoRespClass() {
        return this.activeTab === 'autoresp' ? 'mainpanel active' : 'mainpanel';
    }
    
    get mainPanelTransTextClass() {
        return this.activeTab === 'transtext' ? 'mainpanel active' : 'mainpanel';
    }
    
    get tagClass() {
        if (this.infoTagType === 'success') return 'panel-tag success';
        if (this.infoTagType === 'error') return 'panel-tag error';
        if (this.infoTagType === 'info') return 'panel-tag info';
        return 'panel-tag';
    }
    
    // Méthodes de navigation
    handleAutoResponseTab() {
        this.activeTab = 'autoresp';
        this.showTransText = false;
        this.getLastTicketInfo();
    }
    
    handleEnrichTab() {
        this.activeTab = 'transtext';
        this.hideAll();
        this.showTransText = true;
    }
    
    hideAll() {
        this.showAnswer = false;
        this.showInfo = false;
        this.showError = false;
        this.showSpinner = false;
    }
    
    connectedCallback() {
        this.getLastTicketInfo();
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
        if (data.LastMsgType === 'ASSISTANT') {
            this.showInfo = true;
            this.infoContent = "Achille est en attente d'une réponse du client.";
        } 
        else if (data.LastMsgType === 'CUSTOMER') {
            switch(data.LastMsgCode) {
                case 0:
                    this.showAnswer = true;
                    this.answerContent = data.Answer;
                    this.showToast('Succès', 'La suggestion d\'Achille est prête !', 'success');
                    break;
                case 5:
                    this.showInfo = true;
                    this.infoContent = data.Answer || "Achille vous laisse répondre à ce ticket.";
                    this.infoTag = "Lecture humaine requise";
                    this.infoTagType = 'error';
                    break;
                case 10:
                    this.showInfo = true;
                    this.infoContent = "Ce ticket semble être un SPAM.";
                    this.infoTag = "SPAM";
                    this.infoTagType = 'error';
                    this.showToast('Information', "Ce ticket semble être un SPAM.", 'info');
                    break;
                case 11:
                    this.showInfo = true;
                    this.infoContent = "Ce ticket semble être une demande de collaboration.";
                    this.infoTag = "Demande de partenariat";
                    this.infoTagType = 'info';
                    this.showToast('Information', "Ce ticket semble être une demande de collaboration.", 'info');
                    break;
                case 12:
                    this.showInfo = true;
                    this.infoContent = "Ce ticket semble provenir d'une réponse automatique.";
                    this.infoTag = "Répondeur automatique";
                    this.infoTagType = 'info';
                    this.showToast('Information', "Ce ticket semble provenir d'une réponse automatique.", 'info');
                    break;
                case 13:
                    this.showInfo = true;
                    this.infoContent = "Ce ticket semble être une notification.";
                    this.infoTag = "Notification";
                    this.infoTagType = 'info';
                    this.showToast('Information', "Ce ticket semble être une notification.", 'info');
                    break;
                case 14:
                    this.showInfo = true;
                    this.infoContent = "Ce ticket ne semble pas avoir besoin d'assistance.";
                    this.infoTag = "Assistance non nécessaire";
                    this.infoTagType = 'info';
                    this.showToast('Information', "Ce ticket ne semble pas avoir besoin d'assistance.", 'info');
                    break;
                default:
                    this.showInfo = true;
                    this.infoContent = "Achille n'a pas pu déterminer la nature de ce ticket.";
                    break;
            }
        } else {
            // Cas par défaut si le type de message n'est pas reconnu
            this.showInfo = true;
            this.infoContent = "Achille n'a pas pu déterminer la nature de ce ticket.";
        }
    }
    
    // Actions utilisateur
    handleUserTextChange(event) {
        this.userText = event.target.value;
    }
    
    handleEnrichText() {
        // Vérifier si du texte a été saisi
        if (!this.userText || this.userText.trim() === '') {
            // Afficher un message d'erreur ou une notification
            this.showToast('Erreur', 'Veuillez saisir du texte à enrichir', 'error');
            return;
        }
        
        // Afficher le spinner pendant l'appel API
        this.showSpinner = true;
        
        // Récupérer l'ID du case actuel
        const caseId = this.recordId;
        
        // Appeler le service Achille pour enrichir le texte
        enrichText({caseId: caseId, text: this.userText})
            .then(result => {
                // Masquer le spinner
                this.showSpinner = false;
                
                if (result) {
                    // Créer un nouvel objet de réponse enrichie
                    const timestamp = new Date();
                    const enrichedResponse = {
                        userText: this.userText,
                        enrichedText: result,
                        timestamp: timestamp,
                        formattedTimestamp: this.formatTimestamp(timestamp)
                    };
                    
                    // Ajouter la réponse à la liste des réponses enrichies
                    if (!this.enrichedResponses) {
                        this.enrichedResponses = [];
                    }
                    this.enrichedResponses.unshift(enrichedResponse); // Ajouter au début de la liste
                    
                    // Mettre à jour la dernière réponse enrichie pour un accès facile
                    this.lastEnrichedResponse = enrichedResponse;
                    
                    // Activer l'affichage de la réponse enrichie
                    this.hasEnrichedResponse = true;
                    
                    // Ajuster la hauteur de la textarea
                    this.adjustTextareaHeight();
                    
                    // Afficher un toast de succès
                    this.showToast('Succès', 'Texte enrichi avec succès !', 'success');
                } else {
                    // Gérer le cas où l'API retourne null ou une erreur
                    this.handleApiError('Impossible d\'enrichir le texte. Veuillez réessayer.');
                }
            })
            .catch(error => {
                // Masquer le spinner
                this.showSpinner = false;
                
                // Gérer l'erreur
                this.handleApiError('Une erreur s\'est produite lors de l\'enrichissement du texte: ' + error.message);
            });
    }
    
    // Méthode pour ajuster la hauteur de la textarea
    adjustTextareaHeight() {
        // Utiliser setTimeout pour s'assurer que le DOM est mis à jour
        setTimeout(() => {
            const textarea = this.template.querySelector('textarea');
            if (textarea) {
                if (this.hasEnrichedResponse) {
                    textarea.style.maxHeight = '150px';
                } else {
                    textarea.style.maxHeight = '200px';
                }
            }
        }, 0);
    }
    
    // Méthode pour formater l'horodatage
    formatTimestamp(timestamp) {
        return new Intl.DateTimeFormat('fr-FR', {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        }).format(timestamp);
    }
    
    // Méthode pour gérer les erreurs d'API
    handleApiError(errorMessage) {
        // Afficher un message d'erreur à l'utilisateur
        // Vous pouvez utiliser un toast ou un autre mécanisme de notification
        console.error(errorMessage);
        
        // Vous pourriez également définir une propriété pour afficher l'erreur dans l'interface
        this.errorMessage = errorMessage;
        this.showError = true;
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
        return this.activeTab === 'autoresp' ? 'tab tab-autoresp selected' : 'tab tab-autoresp';
    }
    
    get enrichTabClass() {
        return this.activeTab === 'transtext' ? 'tab tab-transtext selected' : 'tab tab-transtext';
    }
    
    get mainPanelAutoRespClass() {
        return this.activeTab === 'autoresp' ? 'mainpanel active' : 'mainpanel';
    }
    
    get mainPanelTransTextClass() {
        return this.activeTab === 'transtext' ? 'mainpanel active' : 'mainpanel';
    }
    
    // Ajouter cette méthode
    handleCopy(event) {
        const textToCopy = event.currentTarget.dataset.text;
        
        // Vérifier si l'utilisateur veut copier le texte formaté ou le texte brut
        const copyFormatted = event.currentTarget.dataset.formatted === 'true';
        
        if (copyFormatted) {
            // Copier le texte formaté (HTML)
            navigator.clipboard.writeText(textToCopy)
                .then(() => {
                    this.showToast('Succès', 'Texte formaté copié !', 'success');
                })
                .catch(err => {
                    console.error('Erreur lors de la copie :', err);
                    this.showToast('Erreur', 'Impossible de copier le texte', 'error');
                });
        } else {
            // Copier le texte brut (sans formatage)
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = textToCopy;
            const cleanText = tempDiv.textContent || tempDiv.innerText || '';
            
            navigator.clipboard.writeText(cleanText)
                .then(() => {
                    this.showToast('Succès', 'Texte copié !', 'success');
                })
                .catch(err => {
                    console.error('Erreur lors de la copie :', err);
                    this.showToast('Erreur', 'Impossible de copier le texte', 'error');
                });
        }
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
        this.userText = '';
        this.hasEnrichedResponse = false;
        this.lastEnrichedResponse = null;
        
        // Réinitialiser la hauteur de la textarea
        this.adjustTextareaHeight();
    }

    // Méthode pour fermer le panneau d'information
    handleClose() {
        this.hideAll();
    }

    // Ajout du getter pour le style du background
    get backgroundStyle() {
        return `--achille-bg-url: url(${this.achilleBg})`;
    }

    // Méthode appelée après le rendu du composant
    renderedCallback() {
        // Ajuster la hauteur de la textarea
        this.adjustTextareaHeight();
    }
} 