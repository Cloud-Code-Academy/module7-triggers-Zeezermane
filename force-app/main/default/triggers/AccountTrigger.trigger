trigger AccountTrigger on Account (before insert, before update, after insert) {
    List<Contact> contactsToInsert = new List<Contact>();

    // Set the account type to prospect.
    if (Trigger.isBefore) {
        for (Account account : Trigger.New) {
            // Set the account type to "Prospect" if not set
            if (account.Type == null) {
                account.Type = 'Prospect';
            }

            // Copy the shipping address to the billing address.
            if (Trigger.isInsert) {
                if (account.ShippingStreet != null) {
                    account.BillingStreet = account.ShippingStreet;
                    account.BillingCity = account.ShippingCity;
                    account.BillingState = account.ShippingState;
                    account.BillingPostalCode = account.ShippingPostalCode;
                    account.BillingCountry = account.ShippingCountry;
                }
            }

            // Set account rating to "Hot" 
            if (Trigger.isInsert) {
                if (account.Name != null && account.Website != null && account.Phone != null && account.Fax != null) {
                    account.Rating = 'Hot';
                }
            }
        }
    }

    // After insert: create a contact for each account inserted
    if (Trigger.isAfter && Trigger.isInsert) {
        for (Account accAfterInsert : Trigger.new) {
            Contact newContact = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = accAfterInsert.Id
            );
            contactsToInsert.add(newContact);
        }

        // Insert the contacts if there are any to insert
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}
