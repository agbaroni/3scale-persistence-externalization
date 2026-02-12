# Externalization of Red Hat 3scale persistence components

## Summary

This repository contains an Ansible playbook to automate the externalization process of persistent components for Red Hat 3scale API Management. With the appropriate initial configuration, the externalization process takes only a few dozen seconds. This playbook can be executed to simultaneously update multiple Red Hat 3scale API Management instances.

## Prerequisites

To run this playbook, the `mysql` command must be present on the machines where it will be executed. Additionally, the following Python libraries must be installed:

- PyMySQL
- kubernetes

## Configuration

The configuration resides in the `host_vars` and `group_vars` directories; these define the `bastions` group, which contains all hosts identified as bastions for their respective OpenShift clusters.

### Global variables

Global variables reside in `group_vars/bastions.yaml` and have the following structure:

```yaml
directory:
  backup: backups # Local directory where all information relevant to a potential recovery will be saved
external:
  mysql:
    test_query: "SELECT 1" # This query is executed to verify connectivity between OpenShift and the external MySQL
deployments:
  scaling_timeout: 30
  elements:
    - description: 3scale operator controller manager
      kind: Deployment
      name: threescale-operator-controller-manager-v2
      namespace: openshift-operators
    - description: APICast (production)
      name: apicast-production
    - description: APICast (staging)
      name: apicast-staging
    - description: System (app)
      name: system-app
    - description: System (sidekiq)
      name: system-sidekiq
    - description: Listener (backend)
      name: backend-listener
      replicas: 2 # Useful for setting a number of replicas other than 1
    - description: Worker (backend)
      name: backend-worker
    - description: Cron (backend)
      name: backend-cron
    - description: Memcache (system)
      name: system-memcache
    - description: Redis (system)
      name: system-redis
    - description: SearchD (system)
      name: system-searchd
    - description: Zync
      name: zync
    - description: Zync (queue)
      name: zync-que
    - description: Redis (backend)
      name: backend-redis
    - description: Zync (database)
      name: zync-database
    - description: MySQL (system)
      name: system-mysql
```

### Specific host variables

Instance-specific variables for Red Hat 3scale API Management reside in `host_vars/bastion0.yaml` and have the following structure:

```yaml
ansible_connection: local
ansible_host: localhost
project:
  threescale: "3scale" # Name of the namespace where the 3scale instance resides (the Operator may be in a different namespace)
external:
  mysql:
    database: some_database
    host: some_mysql_host # MySQL host reachable from OpenShift Pods
    other_host: some_mysql_other_host # Optional, defaults to host. MySQL IP address or DNS name reachable from the bastion
    password: some_password
    port: 3306
    other_port: 3306 # Optional, defaults to port. MySQL port reachable from the bastion
    user: some_user
  redis:
    backend:
      queues:
        host: some_redis0_host
        port: 6379
        password: some_password
      storage:
        host: some_redis1_host
        port: 6379
        password: some_password
    system:
      host: some_redis2_host
      port: 6379
      password: some_password
```

## Execution

Once the configuration is customized, you can run the playbook as follows:

```bash
ansible-playbook main.yaml
```
