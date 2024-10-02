trigger OpportunityTrigger on Opportunity (before update, before delete) {

    // Handle 'before update' context for Opportunity Amount validation
    if (Trigger.isUpdate) {
        for (Opportunity oppBefore : Trigger.new) {
            if (oppBefore.Amount != null && oppBefore.Amount <= 5000) {
                oppBefore.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    // Handle 'before delete' context to prevent deletion of Closed Won opportunities for banking accounts
    if (Trigger.isDelete) {
        // Set to collect Account IDs of opportunities being deleted
        Set<Id> accountIds = new Set<Id>();

        // Collect Account IDs from Closed Won opportunities
        for (Opportunity oppDelete : Trigger.old) {
            if (oppDelete.StageName == 'Closed Won') {
                accountIds.add(oppDelete.AccountId);
            }
        }

        
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Industry FROM Account WHERE Id IN :accountIds AND Industry = 'Banking']
        );

        // Prevent deletion of Closed Won opportunities for Banking accounts
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && accountMap.containsKey(opp.AccountId)) {
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
        //Q7 Trigger
    if(Trigger.isUpdate){ 
        //get the Account Ids from the Opportunities
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : Trigger.new){
            if(opp.AccountId != null){
                accountIds.add(opp.AccountId);
            }

    }
    //for contacts with the title "CEO"
    Map<Id,Contact> ceoContactsMap = new Map <Id, Contact>();
    List<Contact> ceoContacts = [
        SELECT Id, AccountId, Title
        FROM Contact
        WHERE AccountId IN :accountIds AND Title = 'CEO'
    ];

    for (Contact ceo : ceoContacts){
        ceoContactsMap.put(ceo.AccountId, ceo);
    }
    //Iterate through updated Opportunities and set the primary contact
    for (Opportunity oppC: Trigger.new){
        if (ceoContactsMap.containsKey(oppC.AccountId)){
            oppC.Primary_Contact__c = ceoContactsMap.get(oppC.AccountId).Id;
        }
    }
}
}
