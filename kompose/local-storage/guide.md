

<https://docs.openshift.com/container-platform/3.7/install_config/configuring_local.html#install-config-configuring-local>


1. Create loop devices om openshift-test-02.kb.dk with `create_local_storage.sh`
1. Configure master and node as in `master-config.yaml` and `node-config.yaml`
1. Restart openshift system to pick up config changes

1. Configure local provisionor
    
    1. Create a standalone namespace for local volume provisioner and its configuration, for example: 
        ```bash
        oc new-project local-storage
       ```
    1. Configure local volume provider with `local-volume-config.yaml`
2. Deploy local provisionor
    1. Create service account
    ```bash
    oc create serviceaccount local-storage-admin
    oc adm policy add-scc-to-user hostmount-anyuid -z local-storage-admin
    ```
    2. Install the template
    ```bash
    oc create -f https://raw.githubusercontent.com/jsafrane/origin/local-storage/examples/storage-examples/local-examples/local-storage-provisioner-template.yaml
    ```
    3. Instantiate template
    ```bash
    oc new-app -p CONFIGMAP=local-volume-config \
      -p SERVICE_ACCOUNT=local-storage-admin \
      -p NAMESPACE=local-storage local-storage-provisioner
    ```

See volumes with `oc get pv`
