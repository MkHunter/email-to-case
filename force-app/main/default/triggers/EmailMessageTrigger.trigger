trigger EmailMessageTrigger on EmailMessage (after insert) {
    new EmailMessageTriggerHandler().run();
}