#!/usr/bin/env bash
  echo "####################################################################################################"
  echo "# Step 1 - Un-Deployment of Application Components"
  echo "####################################################################################################"
  echo ""

  echo "Step 1.1 Un-deploy ui"  
  kubectl -n frontend delete -f  code/easyfranchise/deployment/k8s/ui.yaml || true

  echo "Step 1.2 Un-deploy broker"  
  kubectl -n integration delete -f code/easyfranchise/deployment/k8s/broker.yaml || true

  echo "Step 1.3 Un-deploy Approuter"  
 kubectl -n integration delete -f code/easyfranchise/deployment/k8s/approuter.yaml || true

  echo "Step 1.4 Un-deploy Backend"  
  kubectl -n integration delete -f code/easyfranchise/deployment/k8s/bp-service.yaml || true
  kubectl -n integration delete -f code/easyfranchise/deployment/k8s/db-service.yaml || true
  kubectl -n backend delete -f code/easyfranchise/deployment/k8s/ef-service.yaml || true
  kubectl -n mock delete -f code/easyfranchise/deployment/k8s/business-partner-mock.yaml || true
  kubectl -n integration delete -f code/easyfranchise/deployment/k8s/email-service.yaml || true
  
  echo "Step 1.5 Un-deploy day2-approuter"  
  helm delete day2-approuter --namespace day2-operations || true

  echo "Step 1.6 Un-deploy day2-service"  
  helm delete day2-service --namespace day2-operations || true

  echo "Step 1.7 Un-deploy day2-ui"  
  helm delete day2-ui --namespace day2-operations || true

  echo "######################################################################################################"
  echo "# Step 2 - Deelete all service instances (xsuaa, saas-registry and destination) and subscription APIRule"
  echo "######################################################################################################"
  echo ""

  echo "Step 2.1 Delete subscription apirule"  
  kubectl -n integration delete apirule subscription-apirule || true

  echo "Step 2.2 delete destination service binding"  
  kubectl -n integration delete servicebindings ef-destination-service-binding || true

  echo "Step 2.3 delete destination service binding"  
  kubectl -n integration delete servicebindings destination-service-binding || true
  
  echo "Step 2.4 delete destination service instance"  
  kubectl -n integration delete serviceinstances ef-destination-service || true

  echo "Step 2.5 delete saas-registry service binding"  
  kubectl -n integration delete servicebindings saas-registry-service-binding || true
  
  echo "Step 2.6 delete saas-registry service instance"  
 kubectl -n integration delete serviceinstances saas-registry-service || true

  echo "Step 2.7 delete xsuaa service binding"  
  kubectl -n integration delete servicebindings xsuaa-service-binding || true

  echo "Step 2.8 delete xsuaa service instance"  
  kubectl -n integration delete serviceinstances xsuaa-service || true

  
   
  
  echo
  echo "####################################################################################################"
  echo "# Un-Deployment Successful"
  echo "####################################################################################################"
  
