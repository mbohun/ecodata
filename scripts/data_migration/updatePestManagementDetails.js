var outputs = db.output.find({name:'Pest Management Details', 'data.pestManagement':{$exists:false}});

var outputCount = outputs.count();
var count = 0;

while (outputs.hasNext()) {
    var output = outputs.next();
    print("Updating Pest Management Details for activity: " + output.activityId + ", output: " + output.outputId);
    output.data.pestManagement= [];
    var methods = output.data.pestManagementMethod;

    for (var i=0; i<methods.length; i++) {
        var treatment = {};
        treatment.pestManagementMethod = output.data.pestManagementMethod[i];

        treatment.targetSpecies = output.data.targetSpecies;
        treatment.treatmentIncentiveMethod = output.data.treatmentIncentiveMethod;
        treatment.pestPriorityStatus = 'Other (specify in notes)';
        treatment.noUnknown = output.data.noUnknown;

        if (i == 0) {
            treatment.areaTreatedHa = output.data.areaTreatedHa;
            treatment.pestAnimalsTreatedNo = output.data.pestAnimalsTreatedNo;
            treatment.pestDensityPerHa = output.data.pestDensityPerHa;
        }
        else {
            treatment.areaTreatedHa = 0;
            treatment.pestAnimalsTreatedNo = 0;
            treatment.pestDensityPerHa = 0;
        }

        output.data.pestManagement.push(treatment);
    }

    var purpose = output.data.pestManagementPurpose;
    if (purpose == 'Experimental') {
        purpose = ['Trialing of experimental methods'];
    }
    else if (purpose == 'Management') {
        purpose = ['Manage threats to priority environmental assets'];
    }
    else {  // Research or Other
        purpose = [purpose];
    }
    output.data.treatmentObjective = purpose;

    delete output.data.pestManagementMethod;
    delete output.data.targetSpecies;
    delete output.data.treatmentIncentiveMethod;
    delete output.data.noUnknown;
    delete output.data.areaTreatedHa;
    delete output.data.pestAnimalsTreatedNo;
    delete output.data.pestDensityPerHa;
    delete output.data.pestManagementPurpose;

    db.output.save(output);
    count++;

}

if (outputCount != count) {
    print("Error! Expected "+outputCount+" but modified "+count+" Pest Management Details outputs");
}
else {
    print("Updated "+count+" Pest Management Details outputs");
}
