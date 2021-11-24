// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

/* 

// Create a user given a profile...
String usr_profile = 'Custom: Support Profile';
Profile p = [SELECT id FROM Profile WHERE name=:usr_profile];
// String usr_name = 'Patrick Mendoza'; // When using this use urc_name.split(usr_name,' ')[0] for firstname and [1] = lastname
User u = new User(alias = 'pmen', email='hvgkgmqdammfsboboc@mrvpt.com',
                emailencodingkey='UTF-8', firstName='Patrick', lastname='Mendoza', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.id,
                timezonesidkey='America/Mexico_City', username='hvgkgmqdammfsboboc@mrvpt.com');

insert u;
*/

// Create N queues of the same Object(Case) & Queue Member  a given a list of queue names
List<String> queue_names = new List<String>{'Vip','Gold','Silver'};

List<Group> queue_grp = new List<Group>();
List<QueueSObject> queues = new List<QueueSObject>();
List<GroupMember> queues_grp_mem = new List<GroupMember>();

for(String q_nm : queue_names) {
    queue_grp.add(new Group(Type='Queue', Name=q_nm));
}
insert queue_grp;

for(Group q : queue_grp) {
    queues.add(new QueueSObject(SobjectType='Case', QueueId=q.Id));
}
insert queues;

// Assign the same Queue Memeber for each Queue
List<Group> queues_ids = new List<Group>([SELECT Id FROM Group WHERE Name IN :queue_names]);
ID usr_id = [SELECT Id FROM User WHERE Name = 'Patrick Mendoza' LIMIT 1].Id;
System.debug(usr_id);
for (Group q : queues_ids) {
    System.debug(q.Id);
    queues_grp_mem.add(new GroupMember(GroupId = q.Id, UserOrGroupId = usr_id));
}
insert queues_grp_mem;
