

<https://docs.openshift.com/container-platform/3.7/install_config/configuring_local.html#install-config-configuring-local>


1. Create loop devices om openshift-test-02.kb.dk with `create_local_storage.sh`
1. Configure master and node as in `master-config.yaml` and `node-config.yaml`
1. Restart openshift system to pick up config changes
1. Configure local storage
    Create a standalone namespace for local volume provisioner and its configuration, for example: 
    ```bash
    oc new-project local-storage
    ```
    1. Configure local volume provider with `local-volume-config.yaml`
    1. Configure local storage provisionor with `local-storage-provisionor-template.yaml`
 

Try example claim from `claims/`

More?
