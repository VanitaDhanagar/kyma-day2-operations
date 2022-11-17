#!/usr/bin/env groovy
@Library(['piper-lib', 'piper-lib-os','lmit-jenkins-lib']) _

def checkacc() {
	
	withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.BTPCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){	  
				  sh '''
				  echo "************ Check if Subaccount exists *********************************"
				  echo "************************************************************************** " 
					   pip3 install -r requirements.txt
					   cd scripts
					   python3 installations.py
					   python3 subaccount_exists.py  
				 '''
				is_account_exists = readFile(file: 'myfile.txt')
				print(is_account_exists)	
				return is_account_exists
	}
	
}

node ('master') 
{
	 dockerExecuteOnKubernetes(script: this, dockerImage: 'docker.wdf.sap.corp:51010/sfext:v3-py' )
{

	try {
		 stage('Git-clone')
			{
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'GithubTools',usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']])
{
				deleteDir()
                checkout scm
				sh'''
				git clone https://$USERNAME:$PASSWORD@github.tools.sap/btp-ppu-test/ReusableActions.git --branch 'master'
				mv ./ReusableActions/* ./
				git clone https://github.com/SAP-samples/btp-kyma-day2-operations.git --branch 'main'
				mv ./btp-kyma-day2-operations/* ./
				'''
			}
			}
		 
		   
			
			stage ('check_Subaccount_exist') 
			{
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.BTPCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']])
{
				    writeJSON file: 'manifest.json', json: params.ManifestJsonFileContent
							data1 = readJSON file:'manifest.json'
							print(data1) 
				    sh '''
				    mv manifest.json ./config/
				    '''
				    is_account_exists = checkacc()
				    print(is_account_exists)	

				    if (is_account_exists == 'True') 
					{

					print("Subaccount already exists.")
					
				     } 
            
				       
}

				}	  
			
		
		stage('UI_Test_Execution')
		{
			withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.BTPCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){		
			    data = readJSON file: './config/manifest.json'		  
				paramSub = "${data.subaccounts[0].display_name}"
				print paramSub
				landscapeUrl = "${data.global_logon.landscape_url}"
				print landscapeUrl
				username = env.username
				print username
				password = env.password
				print password
				build job: 'Kyma_Day2Operations_UI_Factory', parameters: [[$class: 'StringParameterValue', name: 'URL', value: landscapeUrl],[$class: 'StringParameterValue', name: 'Username', value: username],[$class: 'StringParameterValue', name: 'Password', value: password],[$class: 'StringParameterValue', name: 'Subaccount', value: paramSub]]
                
			     
		}
		}
		stage('Delete_customer_subaccount')
		{
			build job: 'delete_kyma_customersubaccount'
		}
		
	stage('Delete Kyma-instances and apps')
	{
		node ('windowskymanode') 
       {	
		 deleteDir()

              withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'GithubTools',usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']])
              {
		withKubeConfig([credentialsId: 'kubeconfigday2']) 
{
             
 
                        sh '''
						 git clone https://github.com/VanitaDhanagar/kyma-day2-operations.git --branch 'main'
				         mv ./kyma-day2-operations/* ./
						 git clone https://github.com/SAP-samples/btp-kyma-day2-operations.git --branch 'main'
				         mv ./btp-kyma-day2-operations/* ./
                          kubectl version
						  
                          kubectl config view
                          pwd
						  chmod +x ./kyma-un-deployment.sh
						  ./kyma-un-deployment.sh

                        '''   
              
          }
           
	   }
	   }
		 }	
	stage('cloudFoundryDeleteService')
	{
	withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.BTPCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){
      data = readJSON file: './config/manifest.json'
	 paramOrg = "${data.subaccounts[0].org_name}"
	               print paramOrg
					paramSpace = "${data.subaccounts[0].space_name}"
					print paramSpace
					region = "${data.subaccounts[0].region}"
                             		print region					
					endpoint = "https://api.cf.${region}.hana.ondemand.com"
	 
	cloudFoundryDeleteService(script: this, cfApiEndpoint: endpoint, cfOrg: paramOrg, cfSpace: paramSpace,cfServiceInstance: 'EasyFranchiseHANADB',cfCredentialsId: env.BTPCredentialID)


	}
		
	}
	stage('Delete kyma-env')
	{
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:env.BTPCredentialID,usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]){
         data = readJSON file: './config/manifest.json'		  
		 subdomain = "${data.global_logon.subdomain}"
		 print subdomain
		subaccount_subdomain = "${data.subaccounts[0].subdomain_subaccount}"
		print subaccount_subdomain
		btplandscape=params.btpLandscape
		print btplandscape

		
		region = "${data.subaccounts[0].region}"
						
				deleteKymaEnvironment(
							btpCredentialsId: env.BTPCredentialID,
							btpGlobalAccountId:subdomain,
							btpSubdomainName: subaccount_subdomain,
							btpRegion:'us20',
							btpLandscape:'factory',
							kymaDisplayName:'kyma-day2-providerautomation1-93951304-9109-44bc-ac3f-53c3ac_kyma'
						)
	

	}
		
	}
	
	
	}	 
	catch(e){
		echo e.toString()
		echo 'This will run only if failed'
		currentBuild.result = "FAILURE"
	}
	finally {
		emailext body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to: 'vanita.dhanagar@sap.com'
	}

}
}











		 
