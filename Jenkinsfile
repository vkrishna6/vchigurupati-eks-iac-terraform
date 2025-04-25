pipeline {
    agent any
    // parameters {
    //     choice(name: 'AWS_REGION',
    //             choices: ['us-east-1']
    //             description: 'Select ClusterName')
    //     choice(name: 'AvailabilityZone',
    //             choices: ["us-east-1a", "us-east-1b", "us-east-1c"]
    //             description: 'Select the Regions')
    //     string(name: 'SubnetCIDRs',
    //             defaultValue: 'none',
    //             description: 'Mention the list of subnet CIDRs')
    // }
    stages {
        stage('Pre-install requirements'){
            steps{
                sh 'echo "testAccess"'
                sh 'terraform --version'
            }
        }
    }
}
