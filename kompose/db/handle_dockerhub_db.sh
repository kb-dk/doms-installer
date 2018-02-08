#!/usr/bin/env bash

#https://docs.openshift.org/latest/admin_guide/manage_scc.html#enable-dockerhub-images-that-require-root

oc create serviceaccount postgres -n doms-installer
oc adm policy add-scc-to-user anyuid system:serviceaccount:doms-installer:postgres

#Run oc adm policy remove-scc-from-user anyuid system:serviceaccount:doms-installer:deployer to remove the anyuid security context from a service account again
# See who has the context with oc describe scc anyuid