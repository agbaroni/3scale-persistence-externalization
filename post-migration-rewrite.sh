oc exec -it deployment/system-app -n ${3SCALE_NAMESPACE} -- bash -c 'bundle exec rake backend:storage:rewrite'
