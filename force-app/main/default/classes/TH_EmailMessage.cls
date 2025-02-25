public class TH_EmailMessage extends TriggerHandler {
    private List<EmailMessage> newEmailMessages;
    private Map<Id, EmailMessage> oldEmailMessages;
    
    public TH_EmailMessage() {
        this.newEmailMessages = (List<EmailMessage>) Trigger.new;
        this.oldEmailMessages = (Map<Id, EmailMessage>) Trigger.oldMap;
    }
    
    public override void afterInsert(List<SObject> newList) {
        List<EmailMessage> emailsToProcess = new List<EmailMessage>();
        
        for(EmailMessage email : (List<EmailMessage>)newList) {
            // Vérifier si l'email est attaché à un Case
            if(email.ParentId != null && String.valueOf(email.ParentId).startsWith('500')) {
                emailsToProcess.add(email);
            }
        }
        
        if(!emailsToProcess.isEmpty()) {
            // Utilisation de Queueable au lieu de future
            System.enqueueJob(new EmailMessageNotificationToAchille(emailsToProcess));
        }
    }
} 