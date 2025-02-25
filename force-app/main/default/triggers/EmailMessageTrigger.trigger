trigger EmailMessageTrigger on EmailMessage (after insert) {
    TH_EmailMessage handler = new TH_EmailMessage();
    handler.run();
} 