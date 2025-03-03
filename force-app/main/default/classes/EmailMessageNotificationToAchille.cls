public class EmailMessageNotificationToAchille implements Queueable, Database.AllowsCallouts {
    private List<EmailMessage> emailMessages;
    
    public EmailMessageNotificationToAchille(List<EmailMessage> emailMessages) {
        this.emailMessages = emailMessages;
    }
    
    public void execute(QueueableContext context) {
        for(EmailMessage email : emailMessages) {
            // Notifier Achille du nouveau message
            AchilleAPIService.notifyNewMessage(email.ParentId, email.Id);
        }
    }
} 