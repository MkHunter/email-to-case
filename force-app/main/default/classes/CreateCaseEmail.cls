
global class CreateCaseEmail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
   // Create an InboundEmailResult object for returning the result of the 
   // Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    // Add the email plain text into the local variable 
    String plainText= email.plainTextBody;

    String membership, priority, severity;

   // Try to look up any contacts based on the email from address
   // If there is more than one contact with the same email address,
   // an exception will be thrown and the catch statement will be called.
    try {
        Contact vCon = [SELECT Id, Name, Email
        FROM Contact
        WHERE Email = :email.fromAddress
        LIMIT 1];

        // New Case object to be created
        Case newCase = new Case(Description =  plainText,
            Status = 'New',
            Subject = email.subject,
            Origin = 'Email',
            ContactId =  vCon.Id);
        
        // Extract data from the Plain Text Email Body
        // you can either parse the body of your email OR get the values from the "email" and "envelope", 
        // which are their own entities, and are not getting their values from the email body   
        // here is how you might get it from the body content, as you seem to be trying to do
        if(plainText != Null && plainText != ''){
            String[] emailBodyRows = plainText.split('\n');
            for (String bodyRow:emailBodyRows) {
                String[] rowContents = bodyRow.split(':');
                String label = rowContents[0].trim();
                String value = rowContents[1].trim();
                switch on label {
                    // TODO Validations
                    when 'Priority' {
                        //Validate that priority is one of the following values: High, Medium, Low
                        newCase.Priority = value;
                    }	
                    when 'Severity' {
                        //Validate that priority is between 1-5
                        newCase.Severity__c = value;
                    }
                    when 'Membership' {
                        //Validate that priority is one of the following values: Vip, Gold, Silver
                        newCase.Membership__c = value;
                    }
                }
            }
             // Insert the new Case
            System.debug(newCase);
            insert newCase;
        }
        System.debug('New Case Object: ' + newCase );   
    }
    // If an exception occurs when the query accesses 
    // the contact record, a QueryException is called.
    // The exception is written to the Apex debug log.
    catch (QueryException e) {
        System.debug('Query Issue: ' + e);
        // TODO Reply to the email when...
        // a. Empty Priority, Severity or Membership
        // b. Not supported values for Priority, Severity or Membership
        // c. Not the correct format of email
    }
    
    // Set the result to true. No need to send an email back to the user 
    // with an error message
    result.success = true;
    
    // Return the result for the Apex Email Service
    return result;
    }
}