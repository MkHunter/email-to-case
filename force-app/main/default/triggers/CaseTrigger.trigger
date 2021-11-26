/* 
    Last Edited by Miguel López ~ 24/11/21
*/
trigger CaseTrigger on Case (before insert) {
    /* 
    if (Trigger.isBefore && Trigger.isInsert) {
        CaseTrigger.CreateNewCase(Trigger.New);
    }
    */
    new CaseTriggerHandler().run();
}