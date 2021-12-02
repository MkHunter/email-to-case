public class EmailMessageTriggerHandler extends TriggerHandler {
    private List<EmailMessage> newEmailMessageList;

    public EmailMessageTriggerHandler() {
        this.newEmailMessageList = Trigger.New;
    }

    public override void afterInsert(){
        updateCaseForwardEmail();
    }

    private void updateCaseForwardEmail(){
        // For every single case related to this List of Emails, Update Cases Forward_Email__c Field
        List<Case> cases = new List<Case>();
        for (EmailMessage msg : newEmailMessageList)
        {
            Case c = [SELECT id, Description, CaseNumber, Origin FROM Case WHERE Id = :msg.ParentId LIMIT 1];
            if (msg.CcAddress == null && c.Origin == 'Email'){
                c.Forward_Email__c = msg.ToAddress;
                cases.add(c);
            }
        }
        update cases;
    }
    
    /*
    // Single EmailMessage Logic
    private void updateCaseForwardEmail(){
        EmailMessage newEmailMessage = newEmailMessageList[0];

        String a = newEmailMessage.Id;
        // Take the Case that is related to the message
        Case related_Case = [SELECT Id, CaseNumber, SourceId, Forward_Email__c FROM Case WHERE SourceId = :a LIMIT 1];

        // Update it with the forward email in case it comes from an Email
        if (related_Case.Origin == 'Email' && newEmailMessageList.size() < 2) {
            related_Case.Forward_Email__c = newEmailMessage.ToAddress;
            update related_Case;
        }
    }
    */
}
