trigger maxOpenCases on Case (before insert) {
    List<Case> ncase = Trigger.new;
    for(Case cs: ncase){
        Integer openCases = [SELECT COUNT() FROM CASE WHERE AccountId = :cs.AccountId AND Status <> 'Closed'];
        if(openCases>=5){
            cs.addError('You have reached the maximum number of open cases (5 cases)');
        }
    }
}